# Project State
updated: 2026-07-18

## Goal
A skill library (sdlc-start/finish/core) letting models — weaker ones
included — carry a project across sessions at a consistent standard.
Scripts absorb what scripts can, skills stay advice-shaped; Claude Code
plugin or install.sh; STANDARD.md governs execution.

## Now
Branch claude/tune-instructions-hooks-ciulko, reconciled with main's Xit
task grammar, keys sdlc-finish ceremony on claim blast radius (gate, both
skills, snippet). Re-measured false_ship-soft (rates in baseline notes):
sonnet sdlc 6/6 (was 4/6), haiku sdlc 5/6 (was 3/6); controls drifted up
too (4/6, 5/6), so haiku still shows no arm discrimination.

## Verification path
- `bash evals/tier0/run.sh` — exit 0 in remote container 2026-07-18
  (deploy WARNs expected uninstalled); `--self-test` — 7/7 caught.
- `bash evals/tier1/run.sh --dry-run --scenario all --arm both` — exit 0
  both prompt styles (2026-07-18); false_ship soft A/B 24/24 runs
  completed 2026-07-18 (2 rounds x 3 seeds x 2 arms x 2 models).
- `bash skills/sdlc-core/scripts/check-state.sh .` — OK (2026-07-18).

## Decisions
- Routing is the SessionStart hook's job; frontmatter stays untouched.
- Judgment a script can absorb goes in a script (orient/diff-inventory).
- Word/size deltas are smell checks; acceptance = tier0/tier1 green.
- Hook-grepped literals must be instructed by a live surface (tier0 C5/6).
- Push `main` only with direct user authorization; otherwise use feature branches.
- Guided outcomes saturate >=haiku-4.5; cost is the guided A/B axis;
  soft (tier2) discriminates for sonnet. Gate only stable sdlc soft
  cells; flaky cells (control, false_ship) = score:null + rate notes.
- Journal compaction is the sole sanctioned journal rewrite.
- Current Stop event text is authoritative; transcript parsing is
  compatibility fallback. Clean trees clear dirty-duration markers.
- Xit owns task-item syntax only; state/current truth and journal/history remain separate.

## Landmines
- Pedro's global agent skills and Claude hooks symlink here; edits change the live install.
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
[ ] Make sdlc-finish demand the project's verification baseline ran this session (or an explicit not-run disclosure) before any ship verdict. #id=finish-baseline-rerun #verify="IS_SANDBOX=1 bash evals/tier1/run.sh --scenario false_ship --arm both --prompt-style soft"

## History (digest through 2026-07-07)
- Six phase skills → start/finish + STANDARD.md; fenced templates and
  gated verdict tokens proved Sonnet-reproducible. Goodhart audit birthed
  OBJECTIVE.md + tier0/tier1; first haiku baseline 2026-07-07.
