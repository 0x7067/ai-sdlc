# Project State
updated: 2026-07-14

## Goal
A skill library (sdlc-start/finish/core) that lets models — weaker ones
included — carry a project across sessions at a consistent standard.
Scripts do what scripts can; skills stay advice-shaped. Claude Code
plugin install; install.sh elsewhere; STANDARD.md governs execution.

## Now
The Stop gate prefers the event's current assistant text, retains transcript
fallback for older harnesses, and times actual dirty-tree duration. Claude
plugin and direct registrations use one deduplicable command. Global Claude,
Codex, Pi, and oh-my-pi skill deployments point at this checkout.

## Verification path
- `bash evals/tier0/run.sh` — exit 0, 203 assertions (2026-07-14).
- `bash evals/tier0/run.sh --self-test` — 7/7 caught (2026-07-10).
- `IS_SANDBOX=1 bash evals/tier1/run.sh --scenario all --arm both` then
  `compare.sh --baseline evals/tier1/baseline.json --results <file>` — OK.
- `bash skills/sdlc-core/scripts/check-state.sh .` — OK (2026-07-07).

## Decisions
- Routing is the SessionStart hook's job; frontmatter stays untouched.
- Judgment a script can absorb goes in a script (orient/diff-inventory).
- Word/size deltas are smell checks; acceptance = tier0/tier1 green.
- Hook-grepped literals must be instructed by a live surface (tier0 C5/6).
- Never push main from agent sessions; claude/* branch pushes are fine.
- Equal A/B scores at haiku tier = saturated scenarios, not "no effect".
- Journal compaction is the sole sanctioned journal rewrite.
- Current Stop event text is authoritative; transcript parsing is compatibility
  fallback. Clean trees clear dirty-duration markers.

## Landmines
- Pedro's machine only: Claude/Codex/Pi/oh-my-pi skill paths and Claude hooks
  symlink to this checkout; repointing another checkout changes the live install.
- Scaffold placeholder token: construct at runtime in eval code and never
  put in .ai-sdlc files; skills scripts may contain it literally.
- tier0 asserts exact check-state.sh substrings ("target <=60", em-dash
  `## YYYY-MM-DD — ` header) — wording and checks change atomically.
- Keep `~/.agents/skills/sdlc-core/...` + sibling-fallback path forms;
  plugin keeps sibling resolution only while all skills ship together.
- tier0 self-test build_sandbox copies an explicit dir list — add any new
  top-level path a check reads (.claude-plugin bit this, 2026-07-07).
- Root tier1 runs error without IS_SANDBOX=1.

## Next
1. Resume scenario hardening and Sonnet-tier A/B.
2. Verify the Claude marketplace-add installation path.

## History (digest through 2026-07-07)
- Sonnet probes honored fenced contracts and script-triggered gates; toy repos
  with planted debris are a cheap compliance test.
- Tier1 isolated-home model runs work because remote auth arrives via env;
  preserve HOME isolation so the control arm stays clean.
- Claude plugin end-to-end via `--plugin-dir` passed; marketplace-add remains
  the unverified installation path.
