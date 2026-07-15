# Project State
updated: 2026-07-15

## Goal
A skill library (sdlc-start/finish/core) letting models — weaker ones
included — carry a project across sessions at a consistent standard.
Scripts absorb what scripts can, skills stay advice-shaped; Claude Code
plugin or install.sh; STANDARD.md governs execution.

## Now
Local main contains origin/main's eval/marketplace work and the standalone
deployment record via merge. Claude/Codex global skills and hooks resolve to
this checkout; local main is ahead of origin and deliberately unpushed.

## Verification path
- `bash evals/tier0/run.sh` — exit 0, 205 assertions on Pedro's machine;
  `--self-test` — 7/7 caught (2026-07-15).
- `IS_SANDBOX=1 bash evals/tier1/run.sh --scenario all --arm both` +
  `compare.sh` — guided OK 2026-07-14, soft gated cells OK 2026-07-15;
  dry-run 8/8 both styles; and
  `bash skills/sdlc-core/scripts/check-state.sh .` — OK (2026-07-15).

## Decisions
- Routing is the SessionStart hook's job; frontmatter stays untouched.
- Judgment a script can absorb goes in a script (orient/diff-inventory).
- Word/size deltas are smell checks; acceptance = tier0/tier1 green.
- Hook-grepped literals must be instructed by a live surface (tier0 C5/6).
- Never push main from agent sessions; claude/* branch pushes are fine.
- Guided outcomes saturate >=haiku-4.5; cost is the guided A/B axis;
  soft (tier2) discriminates for sonnet. Gate only stable sdlc soft
  cells; flaky cells (control, false_ship) = score:null + rate notes.
- Journal compaction is the sole sanctioned journal rewrite.
- Current Stop event text is authoritative; transcript parsing is
  compatibility fallback. Clean trees clear dirty-duration markers.

## Landmines
- Pedro's machine only: Claude/Codex/Pi/oh-my-pi skills and Claude hooks
  symlink to this checkout; repointing another checkout changes the live install.
- Scaffold placeholder token: construct at runtime in eval code and never
  put in .ai-sdlc files; skills scripts may contain it literally.
- tier0 asserts exact check-state.sh substrings ("target <=60", em-dash
  `## YYYY-MM-DD — ` header) — wording and checks change atomically.
- Keep `~/.agents/skills/sdlc-core/...` + sibling-fallback path forms;
  plugin keeps sibling resolution only while all skills ship together.
- tier0 self-test build_sandbox copies an explicit dir list — add any new
  top-level path a check reads (.claude-plugin bit this, 2026-07-07).
- Root tier1 needs IS_SANDBOX=1; --seed is ignored in dry-run (canonical).
- GitHub-added marketplaces need the explicit github source; tier0 pins it.
- Fixture commit messages must never carry disclosure keywords.

## Next
1. Close false_ship-soft gap: key ceremony on claim blast radius; re-measure.
2. Pedro may push local main; agent sessions must not push main.

## History (digest through 2026-07-07)
- Six phase skills → start/finish + STANDARD.md; fenced templates and
  gated verdict tokens proved Sonnet-reproducible. Goodhart audit birthed
  OBJECTIVE.md + tier0/tier1; first haiku baseline 2026-07-07.
