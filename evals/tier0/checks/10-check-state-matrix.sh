#!/usr/bin/env bash
# check-state.sh fixture matrix: one runtime-generated .ai-sdlc fixture per
# violation class check-state.sh knows, asserting the exact FAIL/WARN string
# and exit code. See skills/sdlc-core/scripts/check-state.sh (source of
# truth for what "violation class" means).

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$HERE/../lib/common.sh"

run_check() { # run_check <dir> -> sets CS_OUT, CS_CODE
  CS_OUT=$(bash "$CHECK_STATE_SH" "$1" 2>&1)
  CS_CODE=$?
}

tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT

# --- a. fully valid state ---------------------------------------------
d="$tmp_root/valid"; write_valid_state_dir "$d"
run_check "$d"
assert_exit "check-state.valid.exit" "$CS_CODE" 0
assert_contains "check-state.valid.ok" "$CS_OUT" "check-state: OK"

# --- b. state.md missing entirely --------------------------------------
d="$tmp_root/missing-file"; mkdir -p "$d/.ai-sdlc"
run_check "$d"
assert_exit "check-state.missing-file.exit" "$CS_CODE" 1
assert_contains "check-state.missing-file.msg" "$CS_OUT" "state.md missing"

# --- c. bad first line ---------------------------------------------------
d="$tmp_root/bad-first-line"; write_valid_state_dir "$d"
set_line "$d/.ai-sdlc/state.md" 1 "# Wrong Header"
run_check "$d"
assert_exit "check-state.bad-first-line.exit" "$CS_CODE" 1
assert_contains "check-state.bad-first-line.msg" "$CS_OUT" "first line must be '# Project State'"

# --- d. missing 'updated:' line ------------------------------------------
d="$tmp_root/missing-updated"; write_valid_state_dir "$d"
set_line "$d/.ai-sdlc/state.md" 2 ""
run_check "$d"
assert_exit "check-state.missing-updated.exit" "$CS_CODE" 1
assert_contains "check-state.missing-updated.msg" "$CS_OUT" "missing 'updated: YYYY-MM-DD' line"

# --- e. missing required section (one fixture per section) --------------
for sec in "Goal" "Now" "Verification path" "Decisions" "Landmines" "Next"; do
  slug=$(printf '%s' "$sec" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
  d="$tmp_root/missing-section-$slug"; write_valid_state_dir "$d"
  remove_markdown_section "$d/.ai-sdlc/state.md" "## $sec"
  run_check "$d"
  assert_exit "check-state.missing-section.$slug.exit" "$CS_CODE" 1
  assert_contains "check-state.missing-section.$slug.msg" "$CS_OUT" "missing '## $sec' section"
done

# --- f. unfilled scaffold-placeholder token in state.md ------------------
d="$tmp_root/todo-placeholder"; write_valid_state_dir "$d"
echo "Extra: $(placeholder_token) filler" >> "$d/.ai-sdlc/state.md"
run_check "$d"
assert_exit "check-state.todo-placeholder.exit" "$CS_CODE" 1
assert_contains "check-state.todo-placeholder.msg" "$CS_OUT" "unfilled $(placeholder_token) placeholder(s)"

# --- g. state.md hard cap (>120 lines) -----------------------------------
d="$tmp_root/hard-cap"; write_valid_state_dir "$d"
append_filler_lines "$d/.ai-sdlc/state.md" 110
run_check "$d"
lines=$(wc -l < "$d/.ai-sdlc/state.md" | tr -d ' ')
if [ "$lines" -le 120 ]; then
  fail "check-state.hard-cap.fixture" "fixture only has $lines lines, need >120 — fixture bug"
fi
assert_exit "check-state.hard-cap.exit" "$CS_CODE" 1
assert_contains "check-state.hard-cap.msg" "$CS_OUT" "hard cap 120"

# --- h. state.md warn zone (81-120 lines) --------------------------------
d="$tmp_root/warn-zone"; write_valid_state_dir "$d"
base_lines=$(wc -l < "$d/.ai-sdlc/state.md" | tr -d ' ')
want=95
append_filler_lines "$d/.ai-sdlc/state.md" "$((want - base_lines))"
run_check "$d"
lines=$(wc -l < "$d/.ai-sdlc/state.md" | tr -d ' ')
if [ "$lines" -le 80 ] || [ "$lines" -gt 120 ]; then
  fail "check-state.warn-zone.fixture" "fixture has $lines lines, need 81-120 — fixture bug"
fi
assert_exit "check-state.warn-zone.exit" "$CS_CODE" 0
assert_contains "check-state.warn-zone.ok" "$CS_OUT" "check-state: OK"
assert_contains "check-state.warn-zone.warn" "$CS_OUT" "target <=80"

# --- i. stale 'updated:' header (mtime far past the claimed date) -------
d="$tmp_root/stale-updated"; write_valid_state_dir "$d"
set_line "$d/.ai-sdlc/state.md" 2 "updated: 2020-01-01"
run_check "$d"
assert_exit "check-state.stale-updated.exit" "$CS_CODE" 0
assert_contains "check-state.stale-updated.warn" "$CS_OUT" "modified more than 24h after"

# --- j. 'Next' references external state (PR/deploy/other agent) --------
d="$tmp_root/next-external"; write_valid_state_dir "$d"
truncate_after_heading "$d/.ai-sdlc/state.md" "## Next"
echo "1. Wait for PR #42 to merge, then continue." >> "$d/.ai-sdlc/state.md"
run_check "$d"
assert_exit "check-state.next-external.exit" "$CS_CODE" 0
assert_contains "check-state.next-external.warn" "$CS_OUT" "references external state"

# --- k. journal.md malformed entry header (hyphen, not em dash) ---------
d="$tmp_root/journal-bad-header"; write_valid_state_dir "$d"
set_line "$d/.ai-sdlc/journal.md" 3 "## $(date +%F) - fixture entry"
run_check "$d"
assert_exit "check-state.journal-bad-header.exit" "$CS_CODE" 1
assert_contains "check-state.journal-bad-header.msg" "$CS_OUT" "malformed entry header(s)"

# --- l. journal.md unfilled scaffold-placeholder digest line -------------
d="$tmp_root/journal-todo"; write_valid_state_dir "$d"
echo "- Left: $(placeholder_token): summarize folded entries." >> "$d/.ai-sdlc/journal.md"
run_check "$d"
assert_exit "check-state.journal-todo.exit" "$CS_CODE" 1
assert_contains "check-state.journal-todo.msg" "$CS_OUT" "unfilled $(placeholder_token) digest line"

# --- m. journal.md compaction-due warning (>200 lines) -------------------
d="$tmp_root/journal-long"; write_valid_state_dir "$d"
append_filler_lines "$d/.ai-sdlc/journal.md" 210
run_check "$d"
jlines=$(wc -l < "$d/.ai-sdlc/journal.md" | tr -d ' ')
if [ "$jlines" -le 200 ]; then
  fail "check-state.journal-long.fixture" "fixture only has $jlines lines, need >200 — fixture bug"
fi
assert_exit "check-state.journal-long.exit" "$CS_CODE" 0
assert_contains "check-state.journal-long.warn" "$CS_OUT" "compaction due"

# --- n. leftover journal.md.bak -------------------------------------------
d="$tmp_root/journal-bak"; write_valid_state_dir "$d"
cp "$d/.ai-sdlc/journal.md" "$d/.ai-sdlc/journal.md.bak"
run_check "$d"
assert_exit "check-state.journal-bak.exit" "$CS_CODE" 1
assert_contains "check-state.journal-bak.msg" "$CS_OUT" "journal.md.bak present"
