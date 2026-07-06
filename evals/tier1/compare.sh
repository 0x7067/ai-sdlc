#!/usr/bin/env bash
# Compare a tier1 results file against baseline.json; exit nonzero on
# regression beyond the stated tolerance. Records are matched by
# (scenario, arm, model). A baseline record with score:null is a
# placeholder — "no baseline established yet" — and is skipped, not
# treated as a regression floor of zero.
#
# Usage: compare.sh --baseline baseline.json --results results.json
#                    [--tolerance N]   (overrides both tolerances, as a
#                                       fraction, e.g. 0.1 == 10%)

set -uo pipefail

baseline=""
results=""
tolerance_override=""

while [ $# -gt 0 ]; do
  case "$1" in
    --baseline) baseline="$2"; shift 2 ;;
    --results) results="$2"; shift 2 ;;
    --tolerance) tolerance_override="$2"; shift 2 ;;
    *) echo "compare.sh: unknown arg '$1'" >&2; exit 1 ;;
  esac
done

[ -n "$baseline" ] || { echo "compare.sh: --baseline required" >&2; exit 1; }
[ -n "$results" ] || { echo "compare.sh: --results required" >&2; exit 1; }
[ -f "$baseline" ] || { echo "compare.sh: baseline file not found: $baseline" >&2; exit 1; }
[ -f "$results" ] || { echo "compare.sh: results file not found: $results" >&2; exit 1; }

score_drop_tol="$(jq -r '.tolerance.score_drop_fraction // 0.1' "$baseline")"
overhead_tol_pct="$(jq -r '.tolerance.overhead_total_tokens_increase_pct // 50' "$baseline")"
[ -n "$tolerance_override" ] && score_drop_tol="$tolerance_override"

regressions=0
report=()

n="$(jq -r '.results | length' "$baseline")"
for ((i=0; i<n; i++)); do
  scenario="$(jq -r ".results[$i].scenario" "$baseline")"
  arm="$(jq -r ".results[$i].arm" "$baseline")"
  model="$(jq -r ".results[$i].model" "$baseline")"
  base_score="$(jq -r ".results[$i].score" "$baseline")"
  base_max="$(jq -r ".results[$i].max" "$baseline")"

  new_rec="$(jq -c --arg s "$scenario" --arg a "$arm" --arg m "$model" \
    '.results[] | select(.scenario==$s and .arm==$a and .model==$m)' "$results" | tail -1)"

  if [ -z "$new_rec" ]; then
    report+=("SKIP  $scenario/$arm/$model — no matching record in new results")
    continue
  fi

  if [ "$scenario" = "overhead" ]; then
    base_total="$(jq -r ".results[$i].tokens.total // \"null\"" "$baseline")"
    new_total="$(jq -r '.tokens.total // "null"' <<<"$new_rec")"
    if [ "$base_total" = "null" ] || [ -z "$base_total" ]; then
      report+=("SKIP  $scenario/$arm/$model — no baseline token count yet (placeholder)")
      continue
    fi
    pct=$(awk -v b="$base_total" -v n="$new_total" 'BEGIN { if (b==0) { print "inf" } else { printf "%.1f", (n-b)/b*100 } }')
    over=$(awk -v p="$pct" -v t="$overhead_tol_pct" 'BEGIN { print (p+0 > t) ? "1" : "0" }')
    if [ "$over" = "1" ]; then
      regressions=$((regressions+1))
      report+=("FAIL  $scenario/$arm/$model — tokens $base_total -> $new_total (+${pct}%, tolerance ${overhead_tol_pct}%)")
    else
      report+=("OK    $scenario/$arm/$model — tokens $base_total -> $new_total (${pct}%)")
    fi
    continue
  fi

  if [ "$base_score" = "null" ] || [ -z "$base_score" ]; then
    report+=("SKIP  $scenario/$arm/$model — no baseline score yet (placeholder)")
    continue
  fi

  new_score="$(jq -r '.score // "null"' <<<"$new_rec")"
  new_max="$(jq -r '.max // "null"' <<<"$new_rec")"
  if [ "$new_score" = "null" ]; then
    regressions=$((regressions+1))
    report+=("FAIL  $scenario/$arm/$model — new run errored (score: null)")
    continue
  fi

  drop=$(awk -v bs="$base_score" -v bm="$base_max" -v ns="$new_score" -v nm="$new_max" \
    'BEGIN { bf = (bm>0)? bs/bm : 0; nf = (nm>0)? ns/nm : 0; printf "%.4f", bf-nf }')
  regressed=$(awk -v d="$drop" -v t="$score_drop_tol" 'BEGIN { print (d > t) ? "1" : "0" }')
  if [ "$regressed" = "1" ]; then
    regressions=$((regressions+1))
    report+=("FAIL  $scenario/$arm/$model — score $base_score/$base_max -> $new_score/$new_max (drop $drop > tolerance $score_drop_tol)")
  else
    report+=("OK    $scenario/$arm/$model — score $base_score/$base_max -> $new_score/$new_max")
  fi
done

printf '%s\n' "${report[@]}"
if [ "$regressions" -gt 0 ]; then
  echo "compare: $regressions regression(s) beyond tolerance"
  exit 1
fi
echo "compare: OK — no regression beyond tolerance"
exit 0
