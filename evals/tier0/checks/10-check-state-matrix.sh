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

run_check_strict() { # run_check_strict <dir> -> sets CS_OUT, CS_CODE
  CS_OUT=$(bash "$CHECK_STATE_SH" --strict "$1" 2>&1)
  CS_CODE=$?
}

tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT

append_xit_filler_lines() { # append_xit_filler_lines <file> <count>
  local file="$1" count="$2" i
  i=1
  while [ "$i" -le "$count" ]; do
    echo "[ ] Fixture line $i. #id=filler-$i" >> "$file"
    i=$((i + 1))
  done
}

# --- a. fully valid state ---------------------------------------------
d="$tmp_root/valid"; write_valid_state_dir "$d"
run_check "$d"
assert_exit "check-state.valid.exit" "$CS_CODE" 0
assert_contains "check-state.valid.ok" "$CS_OUT" "check-state: OK"

# --- a2. all unresolved Xit statuses and supported priorities ------------
d="$tmp_root/xit-valid"; write_valid_state_dir "$d"
truncate_after_heading "$d/.ai-sdlc/state.md" "## Next"
cat >> "$d/.ai-sdlc/state.md" <<'EOF'
[ ] Queue normal work. #id=normal
[@] ! Run important work. #id=active #owner=terra
[?] !! Resolve the milestone decision. #id=decision #needs=user
EOF
run_check "$d"
assert_exit "check-state.xit-valid.exit" "$CS_CODE" 0
assert_contains "check-state.xit-valid.ok" "$CS_OUT" "check-state: OK"

# --- a3. a settled project may have an empty Next list -------------------
d="$tmp_root/xit-empty"; write_valid_state_dir "$d"
truncate_after_heading "$d/.ai-sdlc/state.md" "## Next"
run_check "$d"
assert_exit "check-state.xit-empty.exit" "$CS_CODE" 0
assert_contains "check-state.xit-empty.ok" "$CS_OUT" "check-state: OK"

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
append_xit_filler_lines "$d/.ai-sdlc/state.md" 110
run_check "$d"
lines=$(wc -l < "$d/.ai-sdlc/state.md" | tr -d ' ')
if [ "$lines" -le 120 ]; then
  fail "check-state.hard-cap.fixture" "fixture only has $lines lines, need >120 — fixture bug"
fi
assert_exit "check-state.hard-cap.exit" "$CS_CODE" 1
assert_contains "check-state.hard-cap.msg" "$CS_OUT" "hard cap 120"

# --- h. state.md warn zone (61-120 lines) --------------------------------
d="$tmp_root/warn-zone"; write_valid_state_dir "$d"
base_lines=$(wc -l < "$d/.ai-sdlc/state.md" | tr -d ' ')
want=80
append_xit_filler_lines "$d/.ai-sdlc/state.md" "$((want - base_lines))"
run_check "$d"
lines=$(wc -l < "$d/.ai-sdlc/state.md" | tr -d ' ')
if [ "$lines" -le 60 ] || [ "$lines" -gt 120 ]; then
  fail "check-state.warn-zone.fixture" "fixture has $lines lines, need 61-120 — fixture bug"
fi
assert_exit "check-state.warn-zone.exit" "$CS_CODE" 0
assert_contains "check-state.warn-zone.ok" "$CS_OUT" "check-state: OK"
assert_contains "check-state.warn-zone.warn" "$CS_OUT" "target <=60"
run_check_strict "$d"
assert_exit "check-state.warn-zone.strict-exit" "$CS_CODE" 1
assert_contains "check-state.warn-zone.strict-msg" "$CS_OUT" "target <=60 in strict mode"

# --- i. stale 'updated:' header (mtime far past the claimed date) -------
d="$tmp_root/stale-updated"; write_valid_state_dir "$d"
set_line "$d/.ai-sdlc/state.md" 2 "updated: 2020-01-01"
run_check "$d"
assert_exit "check-state.stale-updated.exit" "$CS_CODE" 0
assert_contains "check-state.stale-updated.warn" "$CS_OUT" "modified more than 24h after"

# --- j. 'Next' references external state (PR/deploy/other agent) --------
d="$tmp_root/next-external"; write_valid_state_dir "$d"
truncate_after_heading "$d/.ai-sdlc/state.md" "## Next"
echo "[ ] Wait for PR #42 to merge, then continue. #id=external" >> "$d/.ai-sdlc/state.md"
run_check "$d"
assert_exit "check-state.next-external.exit" "$CS_CODE" 0
assert_contains "check-state.next-external.warn" "$CS_OUT" "references external state"

# --- j2. legacy/non-Xit Next line ----------------------------------------
d="$tmp_root/next-legacy"; write_valid_state_dir "$d"
truncate_after_heading "$d/.ai-sdlc/state.md" "## Next"
echo "1. Legacy numbered task." >> "$d/.ai-sdlc/state.md"
run_check "$d"
assert_exit "check-state.next-legacy.exit" "$CS_CODE" 1
assert_contains "check-state.next-legacy.msg" "$CS_OUT" "invalid Xit task item"

# --- j3. unsupported priority token -------------------------------------
for priority in '!!!' '..!'; do
  slug=$(printf '%s' "$priority" | tr '.!' 'di')
  d="$tmp_root/next-priority-$slug"; write_valid_state_dir "$d"
  truncate_after_heading "$d/.ai-sdlc/state.md" "## Next"
  echo "[ ] $priority Invalid priority. #id=bad-priority" >> "$d/.ai-sdlc/state.md"
  run_check "$d"
  assert_exit "check-state.next-priority.$slug.exit" "$CS_CODE" 1
  assert_contains "check-state.next-priority.$slug.msg" "$CS_OUT" "invalid Xit task item"
done

# --- j4. terminal tasks are advisory while working, strict at handoff ---
d="$tmp_root/next-terminal"; write_valid_state_dir "$d"
truncate_after_heading "$d/.ai-sdlc/state.md" "## Next"
cat >> "$d/.ai-sdlc/state.md" <<'EOF'
[x]  Verified completed task. #id=done #verify=fixture-check
[~] Superseded task. #id=old #after=done
EOF
run_check "$d"
assert_exit "check-state.next-terminal.exit" "$CS_CODE" 0
assert_contains "check-state.next-terminal.warn" "$CS_OUT" "terminal [x]/[~] item(s) remain"
run_check_strict "$d"
assert_exit "check-state.next-terminal.strict-exit" "$CS_CODE" 1
assert_contains "check-state.next-terminal.strict-msg" "$CS_OUT" "remove them before handoff"

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
run_check_strict "$d"
assert_exit "check-state.journal-long.strict-exit" "$CS_CODE" 1
assert_contains "check-state.journal-long.strict-msg" "$CS_OUT" "compaction required in strict mode"

# --- n2. newest journal entry over the telegram cap (>12 lines) ----------
d="$tmp_root/journal-long-entry"; write_valid_state_dir "$d"
{
  echo "## 2026-02-01 — long fixture entry"
  for i in $(seq 1 14); do echo "- process narrative line $i."; done
} >> "$d/.ai-sdlc/journal.md"
run_check "$d"
assert_exit "check-state.journal-long-entry.exit" "$CS_CODE" 0
assert_contains "check-state.journal-long-entry.warn" "$CS_OUT" "newest entry is"
assert_contains "check-state.journal-long-entry.remedy" "$CS_OUT" "newest entry only"

# --- n3. newest entry within cap: no entry-length warn --------------------
d="$tmp_root/journal-short-entry"; write_valid_state_dir "$d"
run_check "$d"
assert_exit "check-state.journal-short-entry.exit" "$CS_CODE" 0
assert_not_contains "check-state.journal-short-entry.quiet" "$CS_OUT" "newest entry is"

# --- n. leftover journal.md.bak -------------------------------------------
d="$tmp_root/journal-bak"; write_valid_state_dir "$d"
cp "$d/.ai-sdlc/journal.md" "$d/.ai-sdlc/journal.md.bak"
run_check "$d"
assert_exit "check-state.journal-bak.exit" "$CS_CODE" 1
assert_contains "check-state.journal-bak.msg" "$CS_OUT" "journal.md.bak present"
