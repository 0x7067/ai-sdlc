#!/usr/bin/env bash
# --self-test driver: for every mutation in mutations.sh, build a fresh
# mktemp sandbox copy of the repo surfaces evals/tier0 protects, confirm the
# PRISTINE copy passes the suite (control — proves any later failure comes
# from the mutation, not sandbox setup), apply the mutation, then assert
# `run.sh` (pointed at the mutated sandbox via REPO_ROOT) now exits nonzero.
#
# A regression suite that cannot fail is decoration: this is what proves
# evals/tier0 actually notices when the thing it protects breaks.

set -uo pipefail

TIER0_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REAL_REPO_ROOT="$(cd "$TIER0_DIR/../.." && pwd)"
# shellcheck source=./mutations.sh
source "$TIER0_DIR/selftest/mutations.sh"

MUTATIONS=(
  "mutate_check_state_missing_section|check-state.sh: missing-section FAIL neutralized"
  "mutate_hook_handoff_missing_dir|sdlc-handoff-gate: branch-A missing-.ai-sdlc block neutralized"
  "mutate_scaffold_refuse|scaffold-state.sh: overwrite-refusal neutralized"
  "mutate_compact_journal_retained_tail|compact-journal.sh: retained tail no longer byte-for-byte"
  "mutate_diff_inventory_untracked|diff-inventory.sh: untracked-files section removed"
  "mutate_skill_bloat|sdlc-start/SKILL.md: bloated past the +20% budget"
  "mutate_spec_remove_emdash_doc|STATE-SPEC.md: em-dash journal-header doc removed"
)

build_sandbox() { # build_sandbox -> prints sandbox path
  local sandbox
  sandbox=$(mktemp -d)
  cp -R "$REAL_REPO_ROOT/skills" "$sandbox/skills"
  cp -R "$REAL_REPO_ROOT/hooks" "$sandbox/hooks"
  cp -R "$REAL_REPO_ROOT/agents-md" "$sandbox/agents-md"
  cp "$REAL_REPO_ROOT/README.md" "$sandbox/README.md"
  chmod +x "$sandbox"/hooks/* "$sandbox"/skills/sdlc-core/scripts/*.sh
  printf '%s' "$sandbox"
}

total=0
caught=0
infra_failures=0
report_lines=""

for entry in "${MUTATIONS[@]}"; do
  fn="${entry%%|*}"
  label="${entry#*|}"
  total=$((total + 1))

  sandbox=$(build_sandbox)

  # Control: the pristine sandbox must pass, exactly like the real repo.
  if ! REPO_ROOT="$sandbox" bash "$TIER0_DIR/run.sh" > /dev/null 2>&1; then
    infra_failures=$((infra_failures + 1))
    report_lines="$report_lines
FAIL  selftest.$fn.control  pristine sandbox copy did not pass the suite BEFORE mutation — self-test infra bug, not a caught regression (label: $label)"
    rm -rf "$sandbox"
    continue
  fi

  "$fn" "$sandbox"

  if REPO_ROOT="$sandbox" bash "$TIER0_DIR/run.sh" > /dev/null 2>&1; then
    report_lines="$report_lines
FAIL  selftest.$fn  regression NOT caught — run.sh still exited 0 after seeding: $label"
  else
    caught=$((caught + 1))
    report_lines="$report_lines
PASS  selftest.$fn  regression caught — run.sh exited nonzero after seeding: $label"
  fi

  rm -rf "$sandbox"
done

echo "== evals/tier0 --self-test =============================================="
printf '%s\n' "$report_lines" | sed '/^$/d'
echo
echo "caught $caught/$total regressions ($infra_failures infra failure(s))"

if [ "$caught" -eq "$total" ] && [ "$infra_failures" -eq 0 ]; then
  echo "self-test: OK"
  exit 0
else
  echo "self-test: FAILED — the suite has a blind spot (see FAIL lines above)"
  exit 1
fi
