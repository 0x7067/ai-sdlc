#!/usr/bin/env bash
# Validate a repo's .ai-sdlc/ artifacts against STATE-SPEC.md.
#
# Usage: check-state.sh [repo-dir]     (default: current directory)
#
# Exit 0: artifacts conform (WARN lines are advisory).
# Exit 1: one FAIL line per violation — fix each before handoff completes.
#
# Mechanical checks only; judgment calls (what belongs in a digest, whether
# a section is *true*) stay with the model per STATE-SPEC.

set -euo pipefail

DIR="${1:-.}/.ai-sdlc"
STATE="$DIR/state.md"
JOURNAL="$DIR/journal.md"

fails=0
fail() { echo "FAIL  $*"; fails=$((fails + 1)); }
warn() { echo "WARN  $*"; }

if [ ! -f "$STATE" ]; then
  fail "state.md missing ($STATE)"
  echo "check-state: 1 violation"
  exit 1
fi

head -n 1 "$STATE" | grep -q '^# Project State$' \
  || fail "state.md: first line must be '# Project State'"
grep -Eq '^updated: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$STATE" \
  || fail "state.md: missing 'updated: YYYY-MM-DD' line"
for sec in "Goal" "Now" "Verification path" "Decisions" "Landmines" "Next"; do
  grep -q "^## $sec\$" "$STATE" \
    || fail "state.md: missing '## $sec' section"
done

state_lines=$(wc -l < "$STATE" | tr -d ' ')
if [ "$state_lines" -gt 120 ]; then
  fail "state.md: $state_lines lines (hard cap 120 — cut stale detail; history belongs in the journal)"
elif [ "$state_lines" -gt 80 ]; then
  warn "state.md: $state_lines lines (target <=80)"
fi

if [ -f "$JOURNAL" ]; then
  # Entry headers: '## YYYY-MM-DD — <summary>' or the digest header.
  bad_headers=$(grep -n '^## ' "$JOURNAL" \
    | grep -Ev '^[0-9]+:## ([0-9]{4}-[0-9]{2}-[0-9]{2} — .+|Digest \(through [0-9]{4}-[0-9]{2}-[0-9]{2}\))$' \
    || true)
  [ -z "$bad_headers" ] || fail "journal.md: malformed entry header(s):
$bad_headers"

  journal_lines=$(wc -l < "$JOURNAL" | tr -d ' ')
  if [ "$journal_lines" -gt 200 ]; then
    warn "journal.md: $journal_lines lines — compaction due: fold all but the newest 5 entries into a digest (STATE-SPEC 'Compaction')"
  fi
fi

if [ "$fails" -gt 0 ]; then
  echo "check-state: $fails violation(s)"
  exit 1
fi
echo "check-state: OK"
