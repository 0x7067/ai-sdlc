#!/usr/bin/env bash
# Validate a repo's .ai-sdlc/ artifacts against STATE-SPEC.md.
#
# Usage: check-state.sh [--strict] [repo-dir]     (default: current directory)
#
# Exit 0: artifacts conform (WARN lines are advisory outside strict mode).
# Exit 1: one FAIL line per violation — fix each before handoff completes.
#
# Mechanical checks only; judgment calls (what belongs in a digest, whether
# a section is *true*) stay with the model per STATE-SPEC.

set -euo pipefail

strict=0
if [ "${1:-}" = "--strict" ]; then
  strict=1
  shift
fi

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

# Advisory: file edited well after its 'updated:' header claims — the header
# is a promise about freshness, and mtime is the only cheap way to catch it
# going stale without re-deriving the whole file's truth.
updated_date=$(grep -E '^updated: [0-9]{4}-[0-9]{2}-[0-9]{2}$' "$STATE" | head -1 | sed 's/^updated: //')
if [ -n "$updated_date" ]; then
  # Try GNU stat's format flag first, then BSD's — whichever binary answers
  # first on a given machine, the other flag reads as noise, not an error
  # (BSD `-f` and GNU `-c` mean different things), so validate the result
  # is purely numeric rather than trusting a zero exit status alone.
  mtime_epoch=$(stat -c %Y "$STATE" 2>/dev/null || stat -f %m "$STATE" 2>/dev/null || echo 0)
  case "$mtime_epoch" in ''|*[!0-9]*) mtime_epoch=0 ;; esac
  updated_epoch=$(date -d "$updated_date" '+%s' 2>/dev/null \
    || date -j -f '%Y-%m-%d' "$updated_date" '+%s' 2>/dev/null || echo 0)
  case "$updated_epoch" in ''|*[!0-9]*) updated_epoch=0 ;; esac
  if [ "$mtime_epoch" != 0 ] && [ "$updated_epoch" != 0 ] \
    && [ "$((mtime_epoch - updated_epoch))" -gt 86400 ]; then
    warn "state.md: file modified more than 24h after its 'updated: $updated_date' header — re-stamp updated: to today"
  fi
fi

# Advisory: a 'Next' step naming external state (a PR, a deploy, another
# agent's work) is a claim that may have moved on since it was written.
next_start=$(grep -n '^## Next$' "$STATE" | head -1 | cut -d: -f1 || true)
if [ -n "$next_start" ]; then
  next_end=$(awk -v s="$next_start" 'NR > s && /^## / { print NR - 1; exit }' "$STATE")
  [ -z "$next_end" ] && next_end=$(wc -l < "$STATE" | tr -d ' ')
  next_body=$(sed -n "$((next_start + 1)),${next_end}p" "$STATE")
  if printf '%s' "$next_body" | grep -qiE 'PR ?#|pull request|deploy|\bmerged?\b|other agent|another agent'; then
    warn "state.md: 'Next' references external state (PR/deploy/other agent) — re-verify it before trusting, don't assume it still holds"
  fi
fi

if grep -q 'TODO-SDLC' "$STATE"; then
  fail "state.md: unfilled TODO-SDLC placeholder(s) — replace each with real content (scaffold-state.sh leaves them; sparse-but-true beats complete-but-guessed)"
fi

state_lines=$(wc -l < "$STATE" | tr -d ' ')
if [ "$state_lines" -gt 120 ]; then
  fail "state.md: $state_lines lines (hard cap 120 — cut stale detail; history belongs in the journal)"
elif [ "$state_lines" -gt 80 ]; then
  if [ "$strict" -eq 1 ]; then
    fail "state.md: $state_lines lines (target <=80 in strict mode)"
  else
    warn "state.md: $state_lines lines (target <=80)"
  fi
fi

if [ -f "$JOURNAL" ]; then
  # Entry headers: '## YYYY-MM-DD — <summary>' or the digest header.
  bad_headers=$(grep -n '^## ' "$JOURNAL" \
    | grep -Ev '^[0-9]+:## ([0-9]{4}-[0-9]{2}-[0-9]{2} — .+|Digest \(through [0-9]{4}-[0-9]{2}-[0-9]{2}\))$' \
    || true)
  [ -z "$bad_headers" ] || fail "journal.md: malformed entry header(s):
$bad_headers"

  if grep -q 'TODO-SDLC' "$JOURNAL"; then
    fail "journal.md: unfilled TODO-SDLC digest line — compact-journal.sh printed the folded entries; summarize them into digest bullets"
  fi

  journal_lines=$(wc -l < "$JOURNAL" | tr -d ' ')
  if [ "$journal_lines" -gt 200 ]; then
    if [ "$strict" -eq 1 ]; then
      fail "journal.md: $journal_lines lines — compaction required in strict mode: fold all but the newest 5 entries into a digest (STATE-SPEC 'Compaction')"
    else
      warn "journal.md: $journal_lines lines — compaction due: fold all but the newest 5 entries into a digest (STATE-SPEC 'Compaction')"
    fi
  fi
fi

if [ -f "$JOURNAL.bak" ]; then
  fail "journal.md.bak present — compaction unfinished: fill the digest, verify journal.md, then delete the backup"
fi

if [ "$fails" -gt 0 ]; then
  echo "check-state: $fails violation(s)"
  exit 1
fi
echo "check-state: OK"
