#!/usr/bin/env bash
# Surface budget gate: word-counts every injected surface (each SKILL.md,
# each hook's emitted text, the agents-md routing snippet) against the
# committed baseline in evals/tier0/budgets.txt, +/-20% tolerance.
#
# This is a TOKEN-OVERHEAD REGRESSION GATE, not a code-quality check: it
# exists because every word here lands in a session's context on every
# invocation. A FAIL means a surface grew or shrank enough to plausibly be
# an accident, not that the prose is bad.
#
# To deliberately re-baseline (intentional prose change, reviewed and
# wanted): recompute the baseline numbers with:
#   bash evals/tier0/checks/40-surface-budget.sh --print-actual
# and paste the output into evals/tier0/budgets.txt, noting why in the
# commit message. Do not silently widen the tolerance instead.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$HERE/../lib/common.sh"

BUDGETS_FILE="$TIER0_DIR/budgets.txt"

surface_word_count() { # surface_word_count <name>
  case "$1" in
    skill:sdlc-start)    wc -w < "$REPO_ROOT/skills/sdlc-start/SKILL.md" ;;
    skill:sdlc-finish)   wc -w < "$REPO_ROOT/skills/sdlc-finish/SKILL.md" ;;
    skill:sdlc-core)     wc -w < "$REPO_ROOT/skills/sdlc-core/SKILL.md" ;;
    hook:lifecycle-gate) extract_heredoc_body "$REPO_ROOT/hooks/sdlc-lifecycle-gate" EOF | wc -w ;;
    hook:lifecycle-gate-compact) extract_heredoc_body "$REPO_ROOT/hooks/sdlc-lifecycle-gate" COMPACT_EOF | wc -w ;;
    hook:handoff-gate)   extract_block_messages "$REPO_ROOT/hooks/sdlc-handoff-gate" | wc -w ;;
    agents-md:snippet)   wc -w < "$REPO_ROOT/agents-md/sdlc-lifecycle.md" ;;
    ref:standard-md)     wc -w < "$STANDARD_MD" ;;
    ref:state-spec-md)   wc -w < "$STATE_SPEC_MD" ;;
    *) echo 0 ;;
  esac
}

if [ "${1:-}" = "--print-actual" ]; then
  while IFS= read -r line; do
    case "$line" in ''|'#'*) continue ;; esac
    name=$(printf '%s' "$line" | awk '{print $1}')
    printf '%-28s%s\n' "$name" "$(surface_word_count "$name" | tr -d ' ')"
  done < "$BUDGETS_FILE"
  exit 0
fi

[ -f "$BUDGETS_FILE" ] || { fail "budget.baseline-file" "missing $BUDGETS_FILE"; exit 0; }

while IFS= read -r line; do
  case "$line" in ''|'#'*) continue ;; esac
  name=$(printf '%s' "$line" | awk '{print $1}')
  baseline=$(printf '%s' "$line" | awk '{print $2}')
  case "$baseline" in ''|*[!0-9]*)
    fail "budget.$name.baseline" "malformed baseline line in budgets.txt: $line"
    continue
    ;;
  esac

  actual=$(surface_word_count "$name" | tr -d ' ')
  lo=$(( baseline * 80 / 100 ))
  hi=$(( baseline * 120 / 100 ))

  if [ "$actual" -ge "$lo" ] && [ "$actual" -le "$hi" ]; then
    pass "budget.$name" "$actual words (baseline $baseline, range [$lo,$hi])"
  else
    fail "budget.$name" "TOKEN-OVERHEAD REGRESSION GATE: $actual words, outside +/-20% of baseline $baseline (range [$lo,$hi]). If this growth/shrinkage is deliberate, re-baseline: bash evals/tier0/checks/40-surface-budget.sh --print-actual, paste into evals/tier0/budgets.txt, and say why in the commit."
  fi
done < "$BUDGETS_FILE"
