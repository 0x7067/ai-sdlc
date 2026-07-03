# Project State
updated: 2026-07-02

## Goal
A skill library (sdlc-onboard/plan/extend/debug/validate/handoff + sdlc-core)
that lets cheaper models carry a project across sessions at a consistent
engineering standard. Portable across harnesses; routing made deterministic
by a SessionStart hook.

## Now
Artifact-hygiene pass complete and committed (d9f6e13): STATE-SPEC defines
journal compaction (>~200 lines → fold all but newest 5 entries into a
digest) and state.md caps (target 80 / fail 120 lines);
`skills/sdlc-core/scripts/check-state.sh` enforces both mechanically;
sdlc-handoff (post-journal check + compaction + 5th acid-test line) and
sdlc-onboard (Step 3 drift check) invoke it. All six skills are now
probe-validated — four new Sonnet toy-repo probes 2026-07-02, all required
trace blocks produced; the handoff probe exercised compaction end-to-end.
Remaining milestone: real-codebase A/B.

## Verification path
- `bash -n install.sh hooks/sdlc-lifecycle-gate
  skills/sdlc-core/scripts/check-state.sh` — passes (2026-07-02).
- Frontmatter + balanced-fence check: every `skills/*/SKILL.md` starts with
  `---` and has an even number of ``` lines — passes (2026-07-02).
- `bash skills/sdlc-core/scripts/check-state.sh .` — "check-state: OK"
  (2026-07-02).
- Skill *behavior*: no automated test. Method: build a toy repo with
  planted debris, spawn Sonnet subagents told to follow one SKILL.md
  exactly, check the output contains the skill's required trace blocks and
  catches the debris. All six skills passed one probe each (2026-07-02).

## Decisions
- Frontmatter descriptions stay untouched — triggering is solved by the
  SessionStart hook (empirical, see README "Why the hook exists").
- Templates over prose for every checkable behavior — Sonnet complies with
  literal fill-in blocks far better than descriptions of desired output.
- Token budget: per-skill growth capped at ~±20% per tuning pass.
- Don't push main from an agent session — commit locally, leave pushing to
  Pedro.
- Artifact hygiene is script-backed, not prose-only: mechanical format/cap
  checks live in `sdlc-core/scripts/check-state.sh`; prose guides only the
  judgment parts (what goes in a digest). Same empirical lesson as the
  SessionStart hook (2026-07-02).
- Journal compaction is the sole sanctioned journal rewrite, performed at
  handoff when >200 lines: fold all but the newest 5 entries into one
  digest entry — never edit retained entries.
- sdlc-handoff intentionally has no `Exit →` chaining line — it is the
  terminal skill of a session (probe-confirmed harmless, 2026-07-02).

## Landmines
- Skills are live-symlinked: `~/.claude/skills → ~/.agents/skills → this
  repo`. Edits take effect immediately in every session, including running
  ones.
- Skills cite STANDARD.md/STATE-SPEC.md/check-state.sh as
  `~/.agents/skills/sdlc-core/...` with a sibling-directory fallback — keep
  both path forms when editing.
- Frontmatter description lines and the `Read STANDARD.md` pointer lines are
  intentionally long (>90 cols); the line-length scan flags them — that is
  the known baseline, not new damage.
- check-state.sh requires the em-dash form `## YYYY-MM-DD — ` for journal
  headers; hand-written journals using a hyphen FAIL on first onboard —
  intended drift repair, not a script bug.

## Next
1. Milestone 2 — headless Sonnet A/B on a real codebase (mirror the hook
     experiment in README "Why the hook exists"): one arm with current
     skills, one with pre-tuning versions extracted via
     `git show db79456:skills/<name>/SKILL.md` into a temp skills dir; same
     task both arms; compare trace compliance and outcome quality. Done
     when results are written into .ai-sdlc/journal.md.
2. Single-command repo check: a script (e.g. `checks.sh`) bundling the
     bash -n + frontmatter/fence + `check-state.sh .` runs so the
     Verification path above collapses to one line; done when the script
     exists, passes, and state.md points at it.
