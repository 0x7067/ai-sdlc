# Project State
updated: 2026-07-05

## Goal
A skill library (sdlc-start + sdlc-finish + sdlc-core) that lets models
carry a project across sessions at a consistent engineering standard.
Portable across harnesses; routing made deterministic by a SessionStart
hook. Execution between the gates is governed by STANDARD.md, not skills.

## Now
Bitter Lesson Phase 2 collapse landed (2026-07-05): the six phase skills
(onboard/plan/extend/debug/validate/handoff, ~720 SKILL.md lines) merged
into sdlc-start (orient + plan, 74 lines) and sdlc-finish (validate +
handoff, 57 lines), both advice-shaped — objectives + WHY, no step recipes.
Hooks, README, agents-md snippet, and core prose renamed; STANDARD.md
byte-identical; STATE-SPEC.md and script headers got name-only prose
updates. An Option A experiment (single merged `sdlc` skill) is planned as
branch `experiment/one-skill`. Prior milestone — mechanical layer landed
(2026-07-03): three new sdlc-core scripts
(scaffold-state.sh, compact-journal.sh, diff-inventory.sh), a scaffold
placeholder-token contract enforced by check-state.sh, and a Stop hook
(hooks/sdlc-handoff-gate) that verifies "Handoff report" claims via
check-state.sh, reminds on SHIP-with-dirty-tree, and nags a >45-min dirty
tree. Skills/STATE-SPEC/README/install.sh wired. All scripts and all 8 hook
branches verified against a fixture repo. Remaining milestone: real-codebase
A/B.

## Verification path
- `bash -n install.sh hooks/* skills/sdlc-core/scripts/*.sh` — passes
  (2026-07-03).
- Frontmatter + balanced-fence check: every `skills/*/SKILL.md` starts with
  `---` and has an even number of ``` lines — passes (2026-07-03).
- `bash skills/sdlc-core/scripts/check-state.sh .` — "check-state: OK"
  (2026-07-03).
- Script/hook *behavior*: fixture-repo runs — scaffold create/refuse/FAIL→OK,
  compact fold with byte-for-byte retained-tail diff, diff-inventory all
  change classes, hook all 8 branches (isolated $HOME so tests hit the
  edited check-state.sh) — all passed (2026-07-03; details in journal).
- Skill *behavior*: no automated test; Sonnet toy-repo probes, all six
  skills passed one probe each (2026-07-02).

## Decisions
- Frontmatter descriptions stay untouched — triggering is solved by the
  SessionStart hook (empirical, see README "Why the hook exists").
- Templates over prose for every checkable behavior; judgment a script can
  absorb goes in a script (README "The mechanical layer").
- Token budget: per-skill growth capped at ~±20% per tuning pass.
- Don't push main from an agent session — commit locally, leave pushing to
  Pedro.
- Journal compaction is the sole sanctioned journal rewrite; it is now
  script-executed (compact-journal.sh), model writes only the digest bullets.
- Stop hook blocks via exit 2 + stderr; self-limiting by stop_hook_active,
  a per-session marker file, and a 45-min nag throttle — chosen so it never
  nags every turn mid-work (2026-07-03).
- The terminal skill of a session intentionally has no `Exit →` chaining
  line (probe-confirmed harmless, 2026-07-02, on sdlc-handoff; the role now
  belongs to sdlc-finish).

## Landmines
- Skills are NOT live from this repo: `~/.claude/skills` and
  `~/.agents/skills` symlink into `~/.agents/ai-sdlc`, a pull-based
  deployment clone. Edits here go live only after that clone pulls.
- `~/.claude/hooks/*` are chezmoi-managed COPIES, not symlinks — copy the
  new file there and `chezmoi add` (auto-pushes the dotfiles repo).
- Never write the scaffold placeholder token literally into this repo's own
  .ai-sdlc files — check-state.sh greps for it and would FAIL the handoff
  (token defined in STATE-SPEC "Scripts and hygiene checks").
- Skills cite STANDARD.md/STATE-SPEC.md/scripts as
  `~/.agents/skills/sdlc-core/...` with a sibling-directory fallback — keep
  both path forms when editing.
- Frontmatter description lines and the `Read STANDARD.md` pointer lines are
  intentionally long (>90 cols); the line-length scan flags them — known
  baseline, not new damage.
- check-state.sh requires the em-dash form `## YYYY-MM-DD — ` for journal
  headers; hand-written journals using a hyphen FAIL on first onboard —
  intended drift repair, not a script bug.

## Next
1. Milestone 2 — headless Sonnet A/B on a real codebase (mirror the hook
     experiment in README "Why the hook exists"): one arm with current
     skills, one with pre-tuning versions extracted via
     `git show db79456:skills/<name>/SKILL.md` into a temp skills dir; same
     task both arms; compare trace compliance and outcome quality. Include a
     handoff task so the Stop gate's A-branch gets exercised for real. Done
     when results are written into .ai-sdlc/journal.md.
2. Single-command repo check: a script (e.g. `checks.sh`) bundling the
     bash -n + frontmatter/fence + `check-state.sh .` runs so the
     Verification path above collapses to one line; done when the script
     exists, passes, and state.md points at it.
