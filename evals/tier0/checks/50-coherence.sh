#!/usr/bin/env bash
# Spec<->script coherence: every literal string a mechanical surface (a
# hook, check-state.sh) depends on must be instructed by at least one live
# surface a model actually reads (a skill's SKILL.md, STANDARD.md,
# STATE-SPEC.md) — otherwise the mechanism is checking for something no one
# was ever told to produce. A FAIL here is a genuine finding: register it in
# evals/tier0/KNOWN-DRIFT with a one-line justification, don't weaken the
# check.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$HERE/../lib/common.sh"

# live_surfaces_contain <needle> — true if the needle literal appears in any
# surface a model actually reads at run time (the skills + core references).
live_surfaces_contain() {
  local needle="$1"
  grep -rqF -- "$needle" \
    "$REPO_ROOT/skills/sdlc-start/SKILL.md" \
    "$REPO_ROOT/skills/sdlc-finish/SKILL.md" \
    "$REPO_ROOT/skills/sdlc-core/SKILL.md" \
    "$STANDARD_MD" \
    "$STATE_SPEC_MD" \
    2>/dev/null
}

# --- C1: the six required section names appear in STATE-SPEC's own template
for sec in "Goal" "Now" "Verification path" "Decisions" "Landmines" "Next"; do
  slug=$(printf '%s' "$sec" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
  if grep -qF -- "## $sec" "$STATE_SPEC_MD"; then
    pass "coherence.sections-in-spec.$slug" "'## $sec' documented in STATE-SPEC.md"
  else
    fail "coherence.sections-in-spec.$slug" "check-state.sh requires '## $sec' but STATE-SPEC.md's template does not show it"
  fi
done

# --- C2: em-dash journal header form is documented where journals are specced
emdash_pattern='## YYYY-MM-DD'
if grep -F -- "$emdash_pattern" "$STATE_SPEC_MD" | grep -q '—'; then
  pass "coherence.emdash-doc" "STATE-SPEC.md documents the em-dash journal header form"
else
  fail "coherence.emdash-doc" "check-state.sh requires an em-dash journal header but STATE-SPEC.md does not show the em-dash form"
fi

# --- C3: the scaffold-placeholder token contract is documented in STATE-SPEC
tok=$(placeholder_token)
if grep -qF -- "$tok" "$STATE_SPEC_MD"; then
  pass "coherence.todo-contract-doc" "STATE-SPEC.md documents the $tok contract"
else
  fail "coherence.todo-contract-doc" "check-state.sh/scaffold-state.sh/compact-journal.sh all key off the $tok marker but STATE-SPEC.md never names it"
fi

# --- C4: journal.md.bak handling is documented in STATE-SPEC ---------------
if grep -qF -- "journal.md.bak" "$STATE_SPEC_MD"; then
  pass "coherence.bak-doc" "STATE-SPEC.md documents journal.md.bak handling"
else
  fail "coherence.bak-doc" "check-state.sh FAILs on a leftover journal.md.bak but STATE-SPEC.md never mentions it"
fi

# --- C5-C7: every literal string sdlc-handoff-gate greps the transcript for
# must be a phrase some live surface actually instructs the model to
# produce, or the gate is checking for a claim no one was ever told to make.
for needle in "What changed:" "What was verified:" "Remaining risk:"; do
  slug=$(printf '%s' "$needle" | tr -c '[:alnum:]' '-' | tr '[:upper:]' '[:lower:]' | sed -E 's/-+/-/g; s/^-|-$//g')
  if live_surfaces_contain "$needle"; then
    pass "coherence.hook-string.$slug" "'$needle' (grepped by sdlc-handoff-gate) is instructed by a live surface"
  else
    fail "coherence.hook-string.$slug" "hooks/sdlc-handoff-gate greps the transcript for '$needle' but no live surface (sdlc-start/sdlc-finish/sdlc-core SKILL.md, STANDARD.md, STATE-SPEC.md) instructs the model to produce that literal phrase"
  fi
done

# --- C8: state.md's documented size caps match check-state.sh's constants -
for cap in 60 120; do
  if grep -qF -- "$cap" "$STATE_SPEC_MD"; then
    pass "coherence.size-cap-doc.$cap" "STATE-SPEC.md documents the $cap-line cap"
  else
    fail "coherence.size-cap-doc.$cap" "check-state.sh enforces a $cap-line threshold but STATE-SPEC.md never states $cap"
  fi
done

# --- C9: compact-journal.sh's KEEP constant matches STATE-SPEC's "newest 5"
keep_const=$(grep -E '^KEEP=' "$COMPACT_JOURNAL_SH" | head -1 | cut -d= -f2)
if [ -n "$keep_const" ] && grep -qF -- "newest $keep_const" "$STATE_SPEC_MD"; then
  pass "coherence.compact-keep-match" "compact-journal.sh KEEP=$keep_const matches STATE-SPEC's 'newest $keep_const entries' wording"
else
  fail "coherence.compact-keep-match" "compact-journal.sh has KEEP=${keep_const:-?} but STATE-SPEC.md does not say 'newest ${keep_const:-?} entries'"
fi

# --- C10/C11: hooks reference skills that actually exist -------------------
for skill in sdlc-start sdlc-finish; do
  if [ -f "$REPO_ROOT/skills/$skill/SKILL.md" ]; then
    pass "coherence.skill-exists.$skill" "skills/$skill/SKILL.md exists"
  else
    fail "coherence.skill-exists.$skill" "hooks reference Skill($skill) but skills/$skill/SKILL.md does not exist"
  fi
done
if grep -qF "Skill(sdlc-start)" "$HOOK_LIFECYCLE" && grep -qF "Skill(sdlc-finish)" "$HOOK_LIFECYCLE"; then
  pass "coherence.lifecycle-gate-skill-refs" "sdlc-lifecycle-gate references both skills by name"
else
  fail "coherence.lifecycle-gate-skill-refs" "sdlc-lifecycle-gate does not reference both Skill(sdlc-start) and Skill(sdlc-finish)"
fi
if grep -qF "Skill(sdlc-finish)" "$HOOK_HANDOFF"; then
  pass "coherence.handoff-gate-skill-ref" "sdlc-handoff-gate references sdlc-finish by name"
else
  fail "coherence.handoff-gate-skill-ref" "sdlc-handoff-gate's messages do not reference Skill(sdlc-finish)"
fi
