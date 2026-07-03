#!/usr/bin/env bash
# Mechanically fold a repo's .ai-sdlc/journal.md per STATE-SPEC "Compaction":
# keep the newest KEEP dated entries byte-for-byte, fold everything older
# (carrying any previous digest's bullets) into one digest entry at the top.
#
# Usage: compact-journal.sh [repo-dir]     (default: current directory)
#
# Mechanical part only. The judgment part — what the folded entries taught —
# stays with the model: the new digest gets the old digest's bullets verbatim
# plus one `TODO-SDLC` line, and the folded entries are printed to stdout as
# the source to summarize. check-state.sh FAILs while the TODO-SDLC line or
# the journal.md.bak backup remains.

set -euo pipefail

KEEP=5
DIR="${1:-.}/.ai-sdlc"
JOURNAL="$DIR/journal.md"
BAK="$JOURNAL.bak"

[ -f "$JOURNAL" ] || { echo "ERROR  $JOURNAL not found" >&2; exit 1; }
if [ -f "$BAK" ]; then
  echo "ERROR  $BAK already exists — finish the previous compaction first" >&2
  echo "       (fill the TODO-SDLC digest line, verify, then delete the .bak)" >&2
  exit 1
fi

# Dated entry headers: '## YYYY-MM-DD — <summary>' (em dash, per STATE-SPEC).
dated=$(grep -nE '^## [0-9]{4}-[0-9]{2}-[0-9]{2} — ' "$JOURNAL" || true)
n=$(printf '%s' "$dated" | grep -c . || true)

if [ "$n" -le "$KEEP" ]; then
  echo "OK  nothing to fold — $n dated entr$([ "$n" = 1 ] && echo y || echo ies), keep threshold is $KEEP"
  exit 0
fi

# Retained region starts at the (n-KEEP+1)-th dated header; the through-date
# of the new digest is the date of the newest folded entry, the one before it.
keep_start=$(printf '%s\n' "$dated" | sed -n "$((n - KEEP + 1))p" | cut -d: -f1)
thru_date=$(printf '%s\n' "$dated" | sed -n "$((n - KEEP))p" \
  | sed -E 's/^[0-9]+:## ([0-9]{4}-[0-9]{2}-[0-9]{2}) — .*/\1/')
first_dated=$(printf '%s\n' "$dated" | sed -n '1p' | cut -d: -f1)

# Previous digest (if any): carry its bullet lines verbatim into the new one.
old_bullets=""
dig_start=$(grep -nE '^## Digest \(through [0-9]{4}-[0-9]{2}-[0-9]{2}\)$' "$JOURNAL" \
  | head -1 | cut -d: -f1 || true)
if [ -n "$dig_start" ]; then
  dig_end=$(awk -v s="$dig_start" 'NR > s && /^## / { print NR - 1; exit }' "$JOURNAL")
  old_bullets=$(sed -n "$((dig_start + 1)),${dig_end}p" "$JOURNAL" | grep -E '^- ' || true)
fi

# Preamble: anything before the first header (rare; preserved verbatim).
pre_end=$first_dated
[ -n "$dig_start" ] && [ "$dig_start" -lt "$pre_end" ] && pre_end=$dig_start
pre_end=$((pre_end - 1))

folded=$(sed -n "${first_dated},$((keep_start - 1))p" "$JOURNAL")

cp "$JOURNAL" "$BAK"
tmp=$(mktemp)
{
  [ "$pre_end" -ge 1 ] && sed -n "1,${pre_end}p" "$JOURNAL"
  echo "## Digest (through $thru_date)"
  [ -n "$old_bullets" ] && printf '%s\n' "$old_bullets"
  echo "- TODO-SDLC: replace this line with one bullet per durable learning or"
  echo "  outcome from the folded entries printed by compact-journal.sh; drop"
  echo "  anything already captured in state.md or the repo."
  echo
  sed -n "${keep_start},\$p" "$JOURNAL"
} > "$tmp"
mv "$tmp" "$JOURNAL"

echo "FOLDED ENTRIES (the source for the digest — summarize, do not re-append):"
echo "----8<----"
printf '%s\n' "$folded"
echo "----8<----"
echo "WROTE   $JOURNAL — digest header + newest $KEEP entries kept byte-for-byte"
echo "BACKUP  $BAK"
echo "NEXT    1. replace the TODO-SDLC line in $JOURNAL with digest bullets"
echo "        2. rm $BAK"
echo "        3. re-run check-state.sh until it prints 'check-state: OK'"
