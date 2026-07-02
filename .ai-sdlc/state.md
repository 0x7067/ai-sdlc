# Project State
updated: 2026-07-02

## Goal
A skill library (sdlc-onboard/plan/extend/debug/validate/handoff + sdlc-core)
that lets cheaper models carry a project across sessions at a consistent
engineering standard. Portable across harnesses; routing made deterministic
by a SessionStart hook.

## Now
Sonnet-tuning pass complete and committed: every skill now uses literal
fenced output templates (pre-flight, skip check, orientation, hypothesis
ledger, validation report + VERDICT token, acid test, handoff report),
written skip-gates, quoted-output evidence rules, a 3-edits-without-a-check
cap, and bold `Exit →` chaining lines. Validated by two Sonnet subagent
probes on a toy repo (both produced the required traces; the validate probe
caught planted debris). Real-codebase A/B not yet run.

## Verification path
- `bash -n install.sh hooks/sdlc-lifecycle-gate` — passes (2026-07-02).
- Frontmatter + balanced-fence check: every `skills/*/SKILL.md` starts with
  `---` and has an even number of ``` lines — passes (2026-07-02).
- Skill *behavior*: no automated test. Method used 2026-07-02: build a toy
  repo with planted debris (debug print in the diff, untracked scratch
  file), spawn Sonnet subagents told to follow one SKILL.md exactly, check
  the output contains the skill's required trace blocks and catches the
  debris.

## Decisions
- Frontmatter descriptions stay untouched — triggering is solved by the
  SessionStart hook (empirical, see README "Why the hook exists").
- Templates over prose for every checkable behavior — Sonnet complies with
  literal fill-in blocks far better than descriptions of desired output
  (2026-07-02 probes: both Sonnet agents reproduced the blocks verbatim).
- Token budget: per-skill growth capped at ~±20%; this pass cost +6.8%
  total words.
- Don't push main from an agent session — commit locally, leave pushing to
  Pedro.

## Landmines
- Skills are live-symlinked: `~/.claude/skills → ~/.agents/skills → this
  repo`. Edits take effect immediately in every session, including running
  ones.
- Skills cite STANDARD.md/STATE-SPEC.md as `~/.agents/skills/sdlc-core/...`
  with a sibling-directory fallback — keep both path forms when editing.
- Frontmatter description lines and the `Read STANDARD.md` pointer lines are
  intentionally long (>90 cols); the line-length scan flags them — that is
  the known baseline, not new damage.

## Next
1. Run the definitive behavioral test: headless Sonnet A/B on a real
     codebase (mirror the hook experiment in README "Why the hook exists") —
     one arm with current skills, one with pre-tuning versions
     (`git show db79456:skills/...`), same task; compare trace compliance
     and outcome quality. Done when results are written into the journal.
2. Extend probe coverage to the unprobed skills (sdlc-onboard, sdlc-extend,
     sdlc-debug, sdlc-handoff) using the 2026-07-02 toy-repo method above;
     done when each produces its required trace block in one probe run.
3. Consider a `make check` / script that runs the frontmatter + fence +
     bash -n checks in one command, so the Verification path is one line;
     done when the script exists and state.md points at it.
