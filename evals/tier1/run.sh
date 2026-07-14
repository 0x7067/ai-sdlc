#!/usr/bin/env bash
# tier1 behavioral eval harness — headless runner.
#
# Invokes the Claude Code CLI non-interactively against generated fixture
# repos, in two arms:
#   control — isolated $HOME with no ai-sdlc skills/hooks installed.
#   sdlc    — isolated $HOME with this repo's skills+hooks installed the
#             way install.sh would (symlinks + settings.json hook wiring).
# Isolation matters both ways: it keeps Pedro's *global* hooks/skills
# (~/.claude on this machine) out of both arms, and keeps the sdlc arm's
# installed skills out of the control arm.
#
# Usage:
#   run.sh --scenario <resumption|stale_state|false_ship|overhead|all>
#          --arm <control|sdlc|both>
#          [--model MODEL] [--dry-run] [--out DIR] [--seed N]
#   run.sh --compare NEW_RESULTS.json [--baseline BASELINE.json] [--tolerance N]
#
# Exit: 0 on completion of requested runs (grading pass/fail is recorded in
# the results file, not the exit code — use --compare for a pass/fail gate).

set -uo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"

DEFAULT_MODEL="claude-haiku-4-5-20251001"
ALL_SCENARIOS=(resumption stale_state false_ship overhead)
ALL_ARMS=(control sdlc)

scenario_arg="all"
arm_arg="both"
model="$DEFAULT_MODEL"
dry_run=0
seed_arg=""
out_dir="$HERE/results"
compare_file=""
baseline_file="$HERE/baseline.json"
tolerance_override=""

usage() { sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

while [ $# -gt 0 ]; do
  case "$1" in
    --scenario) scenario_arg="$2"; shift 2 ;;
    --arm) arm_arg="$2"; shift 2 ;;
    --model) model="$2"; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    --seed) seed_arg="$2"; shift 2 ;;
    --out) out_dir="$2"; shift 2 ;;
    --compare) compare_file="$2"; shift 2 ;;
    --baseline) baseline_file="$2"; shift 2 ;;
    --tolerance) tolerance_override="$2"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "run.sh: unknown arg '$1'" >&2; usage; exit 1 ;;
  esac
done

if [ -n "$compare_file" ]; then
  args=(--baseline "$baseline_file" --results "$compare_file")
  [ -n "$tolerance_override" ] && args+=(--tolerance "$tolerance_override")
  exec bash "$HERE/compare.sh" "${args[@]}"
fi

if [ "$scenario_arg" = "all" ]; then
  scenarios=("${ALL_SCENARIOS[@]}")
else
  scenarios=("$scenario_arg")
fi
if [ "$arm_arg" = "both" ]; then
  arms=("${ALL_ARMS[@]}")
else
  arms=("$arm_arg")
fi

require_cmd jq
require_cmd git
[ "$dry_run" -eq 1 ] || require_cmd claude

# Dry-run canned transcripts are written against the canonical (variant 0)
# fixtures — a nonzero seed would grade them against a different variant's
# ground truth and fail spuriously.
if [ "$dry_run" -eq 1 ] && [ -n "$seed_arg" ] && [ "$seed_arg" != "canonical" ]; then
  echo "run.sh: --seed is ignored with --dry-run (canned transcripts are canonical-only)" >&2
  seed_arg=""
fi

mkdir -p "$out_dir/raw"
results_file="$out_dir/results-$(ts_now).json"
records_tmp="$(mktemp)"
echo "[" > "$records_tmp"
first=1

# CLAUDE_CODE_OAUTH_TOKEN / ANTHROPIC_API_KEY: if the invoking environment
# already has one exported (e.g. Pedro ran `claude setup-token` once), pass
# it through into the isolated HOME so real (non-dry-run) auth works
# without ever reading/copying credential files ourselves. Never sourced
# or discovered here — only forwarded if the caller already set it.
pass_env=()
[ -n "${CLAUDE_CODE_OAUTH_TOKEN:-}" ] && pass_env+=(CLAUDE_CODE_OAUTH_TOKEN="$CLAUDE_CODE_OAUTH_TOKEN")
[ -n "${ANTHROPIC_API_KEY:-}" ] && pass_env+=(ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY")

run_one() {
  local scenario="$1" arm="$2"
  local scen_dir="$HERE/scenarios/$scenario"
  local workdir iso_home repo gt prompt raw_json answer_file
  local num_turns=null input_tokens=0 output_tokens=0 cache_read=0 cache_creation=0
  local is_error=false result_text="" grade_json='{}'

  workdir="$(mktemp -d "${TMPDIR:-/tmp}/tier1-work.XXXXXX")"
  TIER1_SEED="$seed_arg" bash "$scen_dir/generate.sh" "$workdir" >/dev/null
  repo="$workdir/repo"
  gt="$workdir/ground_truth.json"
  prompt="$(cat "$scen_dir/prompt.txt")"

  iso_home="$(mktemp -d "${TMPDIR:-/tmp}/tier1-home.XXXXXX")"
  if [ "$arm" = "sdlc" ]; then
    setup_sdlc_home "$iso_home"
  else
    setup_control_home "$iso_home"
  fi

  raw_json="$out_dir/raw/${scenario}-${arm}-$(ts_now).json"

  if [ "$dry_run" -eq 1 ]; then
    canned="$HERE/dry_run/${scenario}-${arm}.json"
    if [ ! -f "$canned" ]; then
      echo "run.sh: no dry-run fixture for $scenario/$arm at $canned" >&2
      return 1
    fi
    cp "$canned" "$raw_json"
  else
    (
      cd "$repo" && \
      env HOME="$iso_home" "${pass_env[@]}" \
        claude -p "$prompt" \
          --model "$model" \
          --output-format json \
          --permission-mode bypassPermissions \
          --no-session-persistence \
          > "$raw_json" 2> "$raw_json.stderr"
    )
  fi

  if ! jq -e . "$raw_json" >/dev/null 2>&1; then
    echo "run.sh: $scenario/$arm produced non-JSON output — see $raw_json / $raw_json.stderr" >&2
    is_error=true
    result_text="$(cat "$raw_json" "$raw_json.stderr" 2>/dev/null | head -c 2000)"
  else
    is_error="$(jq -r '.is_error // false' "$raw_json")"
    result_text="$(jq -r '.result // ""' "$raw_json")"
    num_turns="$(jq -r '.num_turns // "null"' "$raw_json")"
    input_tokens="$(jq -r '.usage.input_tokens // 0' "$raw_json")"
    output_tokens="$(jq -r '.usage.output_tokens // 0' "$raw_json")"
    cache_read="$(jq -r '.usage.cache_read_input_tokens // 0' "$raw_json")"
    cache_creation="$(jq -r '.usage.cache_creation_input_tokens // 0' "$raw_json")"
  fi

  answer_file="$(mktemp)"
  printf '%s' "$result_text" > "$answer_file"

  if [ "$is_error" = "true" ]; then
    grade_json="$(jq -n --arg msg "$result_text" '{score: null, max: null, detail: {reason: "run errored before grading", error_message: $msg}}')"
  else
    case "$scenario" in
      resumption)  grade_json="$(bash "$scen_dir/grade.sh" "$gt" "$answer_file")" ;;
      stale_state) grade_json="$(bash "$scen_dir/grade.sh" "$gt" "$answer_file" "$repo")" ;;
      false_ship)  grade_json="$(bash "$scen_dir/grade.sh" "$gt" "$answer_file")" ;;
      overhead)    grade_json="$(bash "$scen_dir/grade.sh" "$gt" "$answer_file" "$repo")" ;;
    esac
  fi

  record="$(jq -n \
    --arg scenario "$scenario" \
    --arg arm "$arm" \
    --arg model "$model" \
    --arg seed "${seed_arg:-canonical}" \
    --argjson dry_run "$([ "$dry_run" -eq 1 ] && echo true || echo false)" \
    --argjson is_error "$is_error" \
    --argjson grade "$grade_json" \
    --argjson num_turns "$num_turns" \
    --argjson input_tokens "$input_tokens" \
    --argjson output_tokens "$output_tokens" \
    --argjson cache_read_input_tokens "$cache_read" \
    --argjson cache_creation_input_tokens "$cache_creation" \
    --arg raw_json_path "$raw_json" \
    --arg repo_path "$repo" \
    '{
      scenario: $scenario, arm: $arm, model: $model, seed: $seed, dry_run: $dry_run,
      is_error: $is_error,
      score: $grade.score, max: $grade.max, detail: $grade.detail,
      note: ($grade.note // null),
      num_turns: $num_turns,
      tokens: {
        input: $input_tokens, output: $output_tokens,
        cache_read: $cache_read_input_tokens, cache_creation: $cache_creation_input_tokens,
        total: ($input_tokens + $output_tokens + $cache_read_input_tokens + $cache_creation_input_tokens)
      },
      raw_json_path: $raw_json_path,
      repo_path: $repo_path
    }')"

  if [ "$first" -eq 1 ]; then first=0; else echo "," >> "$records_tmp"; fi
  printf '%s\n' "$record" >> "$records_tmp"

  echo "  $scenario/$arm: score=$(jq -r '.score' <<<"$grade_json")/$(jq -r '.max' <<<"$grade_json") is_error=$is_error turns=$num_turns tokens_total=$((input_tokens + output_tokens + cache_read + cache_creation))" >&2
}

echo "tier1: model=$model dry_run=$dry_run seed=${seed_arg:-canonical} scenarios=(${scenarios[*]}) arms=(${arms[*]})" >&2
for scenario in "${scenarios[@]}"; do
  for arm in "${arms[@]}"; do
    run_one "$scenario" "$arm"
  done
done

echo "]" >> "$records_tmp"
jq '{generated: (now | strftime("%Y-%m-%dT%H:%M:%SZ")), results: .}' "$records_tmp" > "$results_file"
rm -f "$records_tmp"

echo "tier1: wrote $results_file" >&2
cat "$results_file"
