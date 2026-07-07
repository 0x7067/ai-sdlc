#!/usr/bin/env bash
# Functional tests for the sdlc-core mechanical scripts:
#   scaffold-state.sh   create / refuse
#   compact-journal.sh  byte-for-byte retained tail, digest carry, "nothing
#                       to fold" short-circuit
#   diff-inventory.sh   all documented change classes
#   orient.sh           scaffold path, newest-3 journal window, drift note,
#                       non-git fallback, always-exit-0 contract

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$HERE/../lib/common.sh"

tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT

# ============================================================================
# scaffold-state.sh
# ============================================================================

d="$tmp_root/scaffold"
out=$(bash "$SCAFFOLD_STATE_SH" "$d" 2>&1); code=$?
assert_exit "scaffold.create.exit" "$code" 0
assert_contains "scaffold.create.stdout" "$out" "CREATED"
assert_file_exists "scaffold.create.file" "$d/.ai-sdlc/state.md"
first_line=$(head -n1 "$d/.ai-sdlc/state.md")
assert_eq "scaffold.create.first-line" "$first_line" "# Project State"
assert_contains "scaffold.create.updated" "$(cat "$d/.ai-sdlc/state.md")" "updated: $(date +%F)"
assert_contains "scaffold.create.placeholder" "$(cat "$d/.ai-sdlc/state.md")" "$(placeholder_token)"

# Refuses to overwrite an existing state.md.
out=$(bash "$SCAFFOLD_STATE_SH" "$d" 2>&1); code=$?
assert_exit "scaffold.refuse.exit" "$code" 1
assert_contains "scaffold.refuse.stderr" "$out" "REFUSE"
assert_contains "scaffold.refuse.msg" "$out" "already exists"

# ============================================================================
# compact-journal.sh
# ============================================================================

# -- nothing-to-fold short circuit (<=5 dated entries) ----------------------
d="$tmp_root/compact-short"
mkdir -p "$d/.ai-sdlc"
{
  echo "# Journal"
  echo
  for i in 1 2 3; do
    echo "## 2026-01-0$i — entry $i"
    echo "- Did: fixture $i."
  done
} > "$d/.ai-sdlc/journal.md"
before=$(cat "$d/.ai-sdlc/journal.md")
out=$(bash "$COMPACT_JOURNAL_SH" "$d" 2>&1); code=$?
assert_exit "compact.nothing-to-fold.exit" "$code" 0
assert_contains "compact.nothing-to-fold.msg" "$out" "nothing to fold"
after=$(cat "$d/.ai-sdlc/journal.md")
assert_eq "compact.nothing-to-fold.untouched" "$after" "$before"

# -- real fold: 8 dated entries, KEEP=5 -> 3 folded, 5 retained ------------
d="$tmp_root/compact-fold"
mkdir -p "$d/.ai-sdlc"
{
  echo "# Journal"
  echo
  for i in 1 2 3 4 5 6 7 8; do
    day=$(printf '%02d' "$i")
    echo "## 2026-01-$day — entry $i"
    echo "- Did: fixture entry number $i, unique marker ENTRY-$i-MARKER."
    echo "- Verified: nothing, fixture."
    echo "- Learned: nothing new."
    echo "- Left: nothing."
    echo
  done
} > "$d/.ai-sdlc/journal.md"
# Drop the trailing blank line's duplicate at EOF for a clean compare later.
cp "$d/.ai-sdlc/journal.md" "$tmp_root/compact-fold-journal-before.md"

write_valid_state_only "$d"  # gives compact-journal.sh a state.md to write the digest into, without touching the journal we just built
rm -f "$d/.ai-sdlc/journal.md.bak" 2>/dev/null || true

# Expected retained tail: entries 4..8 (newest 5), byte-for-byte.
expected_tail=$(awk '/^## 2026-01-04 — entry 4$/{p=1} p' "$tmp_root/compact-fold-journal-before.md")

out=$(bash "$COMPACT_JOURNAL_SH" "$d" 2>&1); code=$?
assert_exit "compact.fold.exit" "$code" 0
assert_contains "compact.fold.folded-marker" "$out" "FOLDED ENTRIES"
assert_contains "compact.fold.entry1-printed" "$out" "ENTRY-1-MARKER"
assert_contains "compact.fold.entry3-printed" "$out" "ENTRY-3-MARKER"

actual_tail=$(awk '/^## 2026-01-04 — entry 4$/{p=1} p' "$d/.ai-sdlc/journal.md")
assert_eq "compact.fold.byte-for-byte-tail" "$actual_tail" "$expected_tail"
assert_not_contains "compact.fold.entry1-dropped" "$(cat "$d/.ai-sdlc/journal.md")" "ENTRY-1-MARKER"
assert_not_contains "compact.fold.entry3-dropped" "$(cat "$d/.ai-sdlc/journal.md")" "ENTRY-3-MARKER"

assert_file_exists "compact.fold.backup" "$d/.ai-sdlc/journal.md.bak"
assert_eq "compact.fold.backup-matches-original" \
  "$(cat "$d/.ai-sdlc/journal.md.bak")" "$(cat "$tmp_root/compact-fold-journal-before.md")"

assert_contains "compact.fold.state-history" "$(cat "$d/.ai-sdlc/state.md")" "## History (digest through 2026-01-03)"
assert_contains "compact.fold.state-todo" "$(cat "$d/.ai-sdlc/state.md")" "$(placeholder_token)"

# -- refuses to run again while a .bak is left from a prior compaction ----
out=$(bash "$COMPACT_JOURNAL_SH" "$d" 2>&1); code=$?
assert_exit "compact.refuse-with-bak.exit" "$code" 1
assert_contains "compact.refuse-with-bak.msg" "$out" "finish the previous compaction first"

# ============================================================================
# diff-inventory.sh
# ============================================================================

# Outside a git repo: errors.
d="$tmp_root/not-a-repo"; mkdir -p "$d"
out=$(cd "$d" && bash "$DIFF_INVENTORY_SH" 2>&1); code=$?
assert_exit "diff-inventory.non-git.exit" "$code" 1
assert_contains "diff-inventory.non-git.msg" "$out" "not inside a git repository"

# Real repo exercising every documented change class: committed baseline,
# an unstaged modification, a staged addition, an untracked file, a stash.
d="$tmp_root/repo"; mkdir -p "$d"
( cd "$d" \
  && git init -q \
  && git config user.email t@example.com && git config user.name t \
  && echo "line one" > tracked.txt \
  && git add tracked.txt && git commit -q -m "baseline" \
  && echo "throwaway change" >> tracked.txt \
  && git stash push -q -m throwaway \
  && echo "line two" >> tracked.txt \
  && echo "new content" > staged-new.txt && git add staged-new.txt \
  && printf '%s\n' '# COMMENT-FIXTURE: prescriptive marker' 'x=1' > commented.sh \
  && git add commented.sh \
  && printf '%s\n' '# md heading, not a comment' > doc-fixture.md \
  && git add doc-fixture.md \
  && echo "scratch" > untracked-fixture.txt )

out=$(cd "$d" && bash "$DIFF_INVENTORY_SH" 2>&1); code=$?
assert_exit "diff-inventory.repo.exit" "$code" 0
assert_contains "diff-inventory.repo.branch-section" "$out" "== branch =="
assert_contains "diff-inventory.repo.status-section" "$out" "== status (porcelain) =="
assert_contains "diff-inventory.repo.staged-section" "$out" "== staged diff stat =="
assert_contains "diff-inventory.repo.unstaged-section" "$out" "== unstaged diff stat =="
assert_contains "diff-inventory.repo.untracked-section" "$out" "== untracked files"
assert_contains "diff-inventory.repo.untracked-file" "$out" "untracked-fixture.txt"
assert_contains "diff-inventory.repo.staged-file" "$out" "staged-new.txt"
assert_contains "diff-inventory.repo.stash-section" "$out" "== stashes"
assert_contains "diff-inventory.repo.comments-section" "$out" "== added comment lines"
assert_contains "diff-inventory.repo.comment-surfaced" "$out" "COMMENT-FIXTURE"
assert_not_contains "diff-inventory.repo.md-excluded" "$out" "md heading, not a comment"

# base-ref form adds the extra stat section.
out=$(cd "$d" && bash "$DIFF_INVENTORY_SH" HEAD 2>&1); code=$?
assert_exit "diff-inventory.base-ref.exit" "$code" 0
assert_contains "diff-inventory.base-ref.section" "$out" "committed vs HEAD"

# ============================================================================
# orient.sh
# ============================================================================

orient_opts=$(grep -E '^set -[[:alnum:]]*o pipefail$' "$ORIENT_SH" | head -n1 || true)
assert_eq "orient.no-errexit.options" "$orient_opts" "set -uo pipefail"

# Fresh git repo, no .ai-sdlc: scaffolds, notes first session, exits 0.
d="$tmp_root/orient-fresh"; mkdir -p "$d"
( cd "$d" && git init -q && git config user.email t@example.com \
  && git config user.name t && git commit -q --allow-empty -m init )
out=$(bash "$ORIENT_SH" "$d" 2>&1); code=$?
assert_exit "orient.fresh.exit" "$code" 0
assert_contains "orient.fresh.scaffolded" "$out" "CREATED"
assert_contains "orient.fresh.first-session" "$out" "first session under sdlc"
assert_file_exists "orient.fresh.state-file" "$d/.ai-sdlc/state.md"
assert_contains "orient.fresh.git-section" "$out" "== git =="
assert_contains "orient.fresh.fill-block" "$out" "Orientation"
assert_contains "orient.fresh.fill-token" "$out" "$(placeholder_token)"

# Established repo: prints state.md, only the newest 3 journal entries, and
# a clean drift check; exit 0.
d="$tmp_root/orient-established"; mkdir -p "$d"
( cd "$d" && git init -q && git config user.email t@example.com \
  && git config user.name t && git commit -q --allow-empty -m init )
write_valid_state_only "$d"
{
  echo "# Journal"
  echo
  for i in 1 2 3 4 5; do
    echo "## 2026-01-0$i — entry $i"
    echo "- Did: fixture ORIENT-ENTRY-$i."
  done
} > "$d/.ai-sdlc/journal.md"
out=$(bash "$ORIENT_SH" "$d" 2>&1); code=$?
assert_exit "orient.established.exit" "$code" 0
assert_contains "orient.established.state" "$out" "Fixture goal"
assert_contains "orient.established.journal-newest" "$out" "ORIENT-ENTRY-5"
assert_contains "orient.established.journal-window-start" "$out" "ORIENT-ENTRY-3"
assert_not_contains "orient.established.journal-old-dropped" "$out" "ORIENT-ENTRY-2"
assert_contains "orient.established.drift-ok" "$out" "check-state: OK"

# Drifted artifacts (missing section): orient still exits 0 but surfaces the
# FAIL and the repair note — orientation is informational, handoff blocks.
remove_markdown_section "$d/.ai-sdlc/state.md" "## Now"
out=$(bash "$ORIENT_SH" "$d" 2>&1); code=$?
assert_exit "orient.drifted.exit" "$code" 0
assert_contains "orient.drifted.fail-surfaced" "$out" "missing '## Now' section"
assert_contains "orient.drifted.repair-note" "$out" "blocks handoff"

# Non-git directory with valid artifacts: degrades gracefully, exit 0.
d="$tmp_root/orient-nongit"; mkdir -p "$d"
write_valid_state_only "$d"
out=$(bash "$ORIENT_SH" "$d" 2>&1); code=$?
assert_exit "orient.non-git.exit" "$code" 0
assert_contains "orient.non-git.note" "$out" "(not a git repository)"
