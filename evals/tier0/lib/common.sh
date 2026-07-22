#!/usr/bin/env bash
# Shared helpers for evals/tier0 check scripts.
#
# Every check script sources this, then prints one line per assertion in the
# form "STATUS  id  message" (STATUS one of PASS/FAIL/WARN). run.sh parses
# those lines; check scripts themselves always exit 0 so a single failed
# assertion doesn't stop the rest of the script's assertions from running.
#
# Conventions (must match skills/sdlc-core/scripts/*.sh):
#   - bash, set -uo pipefail (no -e: assertions must not abort the script)
#   - macOS/BSD + GNU tolerant (see date/stat fallback patterns below)

set -uo pipefail

# --- paths -------------------------------------------------------------

# evals/tier0 directory (parent of lib/).
TIER0_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Repo root: overridable so --self-test can point checks at a mutated
# sandbox copy instead of the real repo.
REPO_ROOT="${REPO_ROOT:-$(cd "$TIER0_DIR/../.." && pwd)}"

CHECK_STATE_SH="$REPO_ROOT/skills/sdlc-core/scripts/check-state.sh"
SCAFFOLD_STATE_SH="$REPO_ROOT/skills/sdlc-core/scripts/scaffold-state.sh"
COMPACT_JOURNAL_SH="$REPO_ROOT/skills/sdlc-core/scripts/compact-journal.sh"
DIFF_INVENTORY_SH="$REPO_ROOT/skills/sdlc-core/scripts/diff-inventory.sh"
ORIENT_SH="$REPO_ROOT/skills/sdlc-core/scripts/orient.sh"
HOOK_LIFECYCLE="$REPO_ROOT/hooks/sdlc-lifecycle-gate"
HOOK_HANDOFF="$REPO_ROOT/hooks/sdlc-handoff-gate"
STANDARD_MD="$REPO_ROOT/skills/sdlc-core/references/STANDARD.md"
STATE_SPEC_MD="$REPO_ROOT/skills/sdlc-core/references/STATE-SPEC.md"

# --- the scaffold placeholder marker, built at runtime ------------------
#
# HARD LANDMINE: never write this token as one literal string anywhere in
# committed source (it would false-positive check-state.sh's own grep if it
# ever landed in a real .ai-sdlc file). Every use below goes through this
# function so the literal never appears joined in our source text.
placeholder_token() {
  printf '%s' "TODO"
  printf '%s' "-SDLC"
}

# --- reporting -----------------------------------------------------------
# Each check script emits lines like:  PASS  check-state.valid.exit  ok
# run.sh greps these; the id must be a single whitespace-free token.

report() { # report <STATUS> <id> [message...]
  local status="$1" id="$2"
  shift 2 || true
  printf '%-4s %s %s\n' "$status" "$id" "$*"
}
pass() { report PASS "$1" "${2:-}"; }
fail() { report FAIL "$1" "${2:-}"; }
warnrep() { report WARN "$1" "${2:-}"; }

# assert_exit <id> <actual> <expected>
assert_exit() {
  local id="$1" actual="$2" expected="$3"
  if [ "$actual" -eq "$expected" ]; then
    pass "$id" "exit $actual (expected $expected)"
  else
    fail "$id" "exit $actual (expected $expected)"
  fi
}

# assert_contains <id> <haystack> <needle>
assert_contains() {
  local id="$1" haystack="$2" needle="$3"
  if printf '%s' "$haystack" | grep -qF -- "$needle"; then
    pass "$id" "contains '$needle'"
  else
    fail "$id" "expected to contain '$needle'; got: $(printf '%s' "$haystack" | tr '\n' '|')"
  fi
}

# assert_not_contains <id> <haystack> <needle>
assert_not_contains() {
  local id="$1" haystack="$2" needle="$3"
  if printf '%s' "$haystack" | grep -qF -- "$needle"; then
    fail "$id" "expected NOT to contain '$needle'; got: $(printf '%s' "$haystack" | tr '\n' '|')"
  else
    pass "$id" "does not contain '$needle'"
  fi
}

# assert_empty <id> <haystack>
assert_empty() {
  local id="$1" haystack="$2"
  if [ -z "$haystack" ]; then
    pass "$id" "empty as expected"
  else
    fail "$id" "expected empty; got: $(printf '%s' "$haystack" | tr '\n' '|')"
  fi
}

# assert_file_exists <id> <path>
assert_file_exists() {
  local id="$1" path="$2"
  if [ -f "$path" ]; then
    pass "$id" "exists: $path"
  else
    fail "$id" "missing: $path"
  fi
}

# assert_file_absent <id> <path>
assert_file_absent() {
  local id="$1" path="$2"
  if [ -f "$path" ]; then
    fail "$id" "expected absent, found: $path"
  else
    pass "$id" "absent: $path"
  fi
}

# assert_eq <id> <actual> <expected>
assert_eq() {
  local id="$1" actual="$2" expected="$3"
  if [ "$actual" = "$expected" ]; then
    pass "$id" "equal"
  else
    fail "$id" "not equal — expected [$expected] got [$actual]"
  fi
}

# --- portable date helpers (mirrors check-state.sh's own fallback style) --

# past_touch_stamp <minutes> -> touch -t compatible timestamp N minutes ago
past_touch_stamp() {
  local mins="$1"
  date -d "-${mins} minutes" '+%Y%m%d%H%M.%S' 2>/dev/null \
    || date -v-"${mins}"M '+%Y%m%d%H%M.%S' 2>/dev/null
}

# --- markdown fixture helpers ---------------------------------------------

# write_valid_state_dir <dir> — writes a fully STATE-SPEC-conformant
# .ai-sdlc/{state.md,journal.md} pair under <dir>.
write_valid_state_dir() {
  local dir="$1"
  mkdir -p "$dir/.ai-sdlc"
  cat > "$dir/.ai-sdlc/state.md" <<EOF
# Project State
updated: $(date +%F)

## Goal
Fixture goal: exercise check-state.sh against a conformant state.md.

## Now
Fixture now: nothing real, this is a tier0 test fixture.

## Verification path
Fixture verification path: none, synthetic fixture (last ran $(date +%F)).

## Decisions
None yet.

## Landmines
None known.

## Next
[ ] Complete the fixture next step. #id=fixture-next #verify=fixture-check
EOF
  cat > "$dir/.ai-sdlc/journal.md" <<EOF
# Journal

## $(date +%F) — fixture entry
- Did: fixture.
- Verified: fixture.
- Learned: nothing new.
- Left: nothing.
EOF
}

# write_valid_state_only <dir> — like write_valid_state_dir but writes only
# state.md, leaving any existing journal.md (or absence of one) untouched.
write_valid_state_only() {
  local dir="$1"
  mkdir -p "$dir/.ai-sdlc"
  cat > "$dir/.ai-sdlc/state.md" <<EOF
# Project State
updated: $(date +%F)

## Goal
Fixture goal: exercise a sdlc-core script against a conformant state.md.

## Now
Fixture now: nothing real, this is a tier0 test fixture.

## Verification path
Fixture verification path: none, synthetic fixture (last ran $(date +%F)).

## Decisions
None yet.

## Landmines
None known.

## Next
[ ] Complete the fixture next step. #id=fixture-next #verify=fixture-check
EOF
}

# set_line <file> <line-no> <content> — replace one line, portable (no sed -i).
set_line() {
  local file="$1" n="$2" content="$3"
  awk -v n="$n" -v c="$content" 'NR==n{print c; next}{print}' "$file" > "$file.tmp" \
    && mv "$file.tmp" "$file"
}

# remove_markdown_section <file> <heading-line e.g. "## Now"> — drops the
# heading and its body up to (not including) the next "## " heading or EOF.
remove_markdown_section() {
  local file="$1" heading="$2"
  awk -v h="$heading" '
    BEGIN{skip=0}
    $0==h {skip=1; next}
    skip==1 && /^## / {skip=0}
    skip==1 {next}
    {print}
  ' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# truncate_after_heading <file> <heading-line> — keeps everything through
# the heading line, drops the rest (caller appends new body after).
truncate_after_heading() {
  local file="$1" heading="$2"
  awk -v h="$heading" '{print} $0==h{exit}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# append_filler_lines <file> <count> — append N throwaway non-heading lines.
append_filler_lines() {
  local file="$1" count="$2" i
  for ((i = 0; i < count; i++)); do
    echo "- filler line $i for line-count fixtures" >> "$file"
  done
}

# --- extraction for the surface-budget gate --------------------------------

# extract_heredoc_body <file> <delim> — body of the `cat <<'DELIM' ... DELIM`
# heredoc with that exact delimiter (hooks/sdlc-lifecycle-gate emits two:
# EOF for the standard gate, COMPACT_EOF for the compaction-recovery text).
extract_heredoc_body() {
  local f="$1" d="$2" start end
  start=$(grep -nF "cat <<'$d'" "$f" | head -1 | cut -d: -f1)
  [ -n "$start" ] || return 1
  end=$(awk -v s="$start" -v d="$d" 'NR>s && $0==d {print NR; exit}' "$f")
  [ -n "$end" ] || return 1
  sed -n "$((start + 1)),$((end - 1))p" "$f"
}

# extract_block_messages <file> — concatenates the literal string argument
# of every `block "..."` call in hooks/sdlc-handoff-gate (its only
# user-facing output). Assumes no embedded literal double-quotes inside a
# message, true of the current file; re-baseline if that ever changes.
extract_block_messages() {
  local f="$1"
  awk '
    inmsg==1 {
      line=$0
      if (index(line, "\"") > 0) {
        pos = index(line, "\"")
        print substr(line, 1, pos - 1)
        inmsg = 0
        next
      } else { print line; next }
    }
    /block "/ {
      line = $0
      sub(/^.*block "/, "", line)
      if (index(line, "\"") > 0) {
        pos = index(line, "\"")
        print substr(line, 1, pos - 1)
      } else {
        print line
        inmsg = 1
      }
      next
    }
  ' "$f"
}
