#!/usr/bin/env bash
# Deliberate regressions seeded into a mktemp sandbox copy of the repo
# surfaces evals/tier0 protects, one function per mutation. Each takes the
# sandbox root ($1, mirroring skills/, hooks/, agents-md/, README.md) and
# edits exactly one file to break exactly one guarantee.
#
# Naming: mutate_<id> — <id> is used as the scenario name in run-selftest.sh
# output. Each mutation locates a unique anchor line via grep -nF (fixed
# string, no regex escaping headaches) and replaces it, so these survive
# reformatting better than a fragile line-number literal would.

set -uo pipefail

# replace_line_containing <file> <fixed-string anchor> <new content>
replace_line_containing() {
  local file="$1" anchor="$2" new="$3" n
  n=$(grep -nF -- "$anchor" "$file" | head -1 | cut -d: -f1)
  [ -n "$n" ] || { echo "MUTATION ERROR: anchor not found in $file: $anchor" >&2; return 1; }
  awk -v n="$n" -v c="$new" 'NR==n{print c; next}{print}' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
}

# check-state.sh: stop failing on a missing required section. Breaks the
# 10-check-state-matrix.sh "missing section" fixtures (they expect FAIL).
mutate_check_state_missing_section() {
  local root="$1"
  replace_line_containing \
    "$root/skills/sdlc-core/scripts/check-state.sh" \
    'for sec in "Goal" "Now" "Verification path" "Decisions" "Landmines" "Next"; do' \
    'for sec in; do true # MUTATED: section-missing check neutralized, loop body skipped'
}

# sdlc-handoff-gate: stop blocking branch A's missing-.ai-sdlc case. Breaks
# 20-hook-branches.sh's hook.handoff.branchA-missing-dir.exit assertion.
mutate_hook_handoff_missing_dir() {
  local root="$1"
  replace_line_containing \
    "$root/hooks/sdlc-handoff-gate" \
    'if [ ! -d .ai-sdlc ]; then' \
    '  if false; then # MUTATED: missing-.ai-sdlc block neutralized'
}

# scaffold-state.sh: stop refusing to overwrite an existing state.md. Breaks
# 30-script-functional.sh's scaffold.refuse.exit assertion.
mutate_scaffold_refuse() {
  local root="$1"
  replace_line_containing \
    "$root/skills/sdlc-core/scripts/scaffold-state.sh" \
    'if [ -f "$STATE" ]; then' \
    'if false; then # MUTATED: overwrite-refusal neutralized'
}

# compact-journal.sh: corrupt the byte-for-byte retained-tail guarantee by
# appending a marker to every line of the new journal.md. Breaks
# 30-script-functional.sh's compact.fold.byte-for-byte-tail assertion.
mutate_compact_journal_retained_tail() {
  local root="$1"
  replace_line_containing \
    "$root/skills/sdlc-core/scripts/compact-journal.sh" \
    '} > "$tmp"' \
    "} | sed 's/\$/ MUTATED-TAIL/' > \"\$tmp\" # MUTATED: retained tail no longer byte-for-byte"
}

# diff-inventory.sh: drop the untracked-files section entirely. Breaks
# 30-script-functional.sh's diff-inventory.repo.untracked-section assertion.
mutate_diff_inventory_untracked() {
  local root="$1"
  local f="$root/skills/sdlc-core/scripts/diff-inventory.sh"
  awk '
    /^echo "== untracked files/ { print "# MUTATED: untracked-files section removed"; skip=1; next }
    skip==1 && /^git ls-files --others --exclude-standard$/ { skip=0; next }
    skip==1 { next }
    { print }
  ' "$f" > "$f.tmp" && mv "$f.tmp" "$f"
}

# skills/sdlc-start/SKILL.md: bloat well past the +20% budget tolerance.
# Breaks 40-surface-budget.sh's budget.skill:sdlc-start assertion.
mutate_skill_bloat() {
  local root="$1"
  local f="$root/skills/sdlc-start/SKILL.md"
  {
    echo
    echo "## MUTATED filler section"
    for i in $(seq 1 400); do
      echo "filler word number $i padding this skill well past its token budget."
    done
  } >> "$f"
}

# check-state.sh: stop failing on a stale Verification-path run stamp in
# strict mode. Breaks 10-check-state-matrix.sh's vp-stale.strict assertions.
mutate_check_state_vp_freshness() {
  local root="$1"
  replace_line_containing \
    "$root/skills/sdlc-core/scripts/check-state.sh" \
    'elif [ "$vp_newest" != "$today" ]; then' \
    '  elif false; then # MUTATED: vp run-stamp freshness check neutralized'
}

# STATE-SPEC.md: remove the em-dash journal header documentation. Breaks
# 50-coherence.sh's coherence.emdash-doc assertion.
mutate_spec_remove_emdash_doc() {
  local root="$1"
  replace_line_containing \
    "$root/skills/sdlc-core/references/STATE-SPEC.md" \
    '## YYYY-MM-DD — <one-line summary>' \
    '## MUTATED (em dash doc removed)'
}
