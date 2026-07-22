# Project State
updated: 2026-07-22

## Goal
A skill library (sdlc-start/finish/core) letting models — weaker ones
included — carry a project across sessions at a consistent standard.
Scripts absorb what scripts can, skills stay advice-shaped; Claude Code
plugin or install.sh; STANDARD.md governs execution.

## Now
First local paid tier1 ran (haiku, guided+soft, dc7ded8): all outcome
cells matched baseline; ONE regression — overhead/sdlc +721% (626k tokens,
31 turns on a one-line task, full finish ceremony). Not re-baselined.

## Verification path
- `bash evals/tier0/run.sh` — 236/236; `--self-test` caught 9/9 seeded regressions (2026-07-22).
- `bash evals/tier1/run.sh --dry-run --scenario all --arm both` — 10/10 scenario-arm runs, guided and soft, without errors (2026-07-22); not a paid behavioral evaluation.
- `bash skills/sdlc-core/scripts/check-state.sh --strict` — OK (2026-07-22).
- `bash evals/tier1/run.sh --scenario all --arm both` + `--prompt-style soft` — paid haiku, 20/20 cells is_error=false; compare: outcome cells green, overhead/sdlc FAIL +721% (2026-07-22).

## Decisions
- Routing is the SessionStart hook's job; frontmatter stays untouched.
- Judgment a script can absorb goes in a script (orient/diff-inventory).
- Word/size deltas are smell checks; acceptance = tier0/tier1 green.
- Hook-grepped literals must be instructed by a live surface (tier0 C5/6).
- Push `main` only with direct user authorization; otherwise use feature branches.
- Guided saturates >=haiku-4.5; cost is the guided A/B axis; soft discriminates
  for sonnet. Gate only stable sdlc soft cells; flaky = score:null + rate notes.
- Journal compaction is the sole sanctioned journal rewrite.
- A PR carries its implementation, verification, state, and journal together; no SDLC-only cleanup PR.
- Current Stop event text is authoritative; transcript parsing is
  compatibility fallback. Only explicit three-field completion claims block.
- Xit owns task-item syntax only; state/current truth and journal/history remain separate.
- Compaction is a session boundary: SessionStart source=compact swaps in recovery text; execution keeps state.md <=1 completed step stale.
- Injected surfaces stay lean (each instruction once, rationale cut); clauses that encode a requirement stay on an always-on surface.

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
- Lifecycle-gate heredoc delimiters (EOF/COMPACT_EOF) are load-bearing: budget and coherence extraction key on them — rename only with 40/50 checks atomically.
- Headless `claude -p` always starts source=startup; tier1 compaction grades artifact-driven recovery, never the live compact injection (tier0 owns that).

## Next
[ ] ! Root-cause and bound the overhead regression: sdlc arm spends 626k tokens/31 turns on a one-line task (full finish ceremony on a trivial claim). Fix must not undo the false_ship claim-integrity wins. #id=overhead-regression #verify="paid overhead cell back within +50% of 76303 tokens"
[ ] Restart fresh harness sessions so they load the merged claim-blast-radius and run-stamp guidance. #id=restart-harnesses #owner=pedro #verify="fresh sessions expose current sdlc-start/core/finish"

## History (digest through 2026-07-20)
- Six phase skills → start/finish + STANDARD.md; Goodhart audit → OBJECTIVE.md + tier0/tier1; first haiku baseline 2026-07-07.
- Guided tiers saturated → soft arms added; claim-keyed gate + run-stamp contract restored haiku false-ship discrimination (12/12 vs 5/12).
- Installed across Claude/Codex/Pi/OMP via symlinks; exit-2 Stop reminders break Codex (removed); Xit profile adopted 2026-07-18.
