# Project State
updated: 2026-07-14

## Goal
A skill library (sdlc-start/finish/core) that lets models — weaker ones
included — carry a project across sessions at a consistent standard.
Scripts do what scripts can; skills stay advice-shaped; Claude Code
plugin or install.sh; STANDARD.md governs execution.

## Now
tier1 scenarios hardened (distractors, stale-decoy, exit-0 trap), 3
seeded variants each; sonnet-5 + haiku baseline; marketplace install fixed.

## Verification path
- `bash evals/tier0/run.sh` — exit 0, 200 assertions; `--self-test` —
  7/7 caught (2026-07-14; deploy checks add 3 on Pedro's machine).
- `IS_SANDBOX=1 bash evals/tier1/run.sh --scenario all --arm both` then
  `compare.sh` vs baseline.json — OK for sonnet-5 + haiku; and
  `bash skills/sdlc-core/scripts/check-state.sh .` — OK (2026-07-14).

## Decisions
- Routing is the SessionStart hook's job; frontmatter stays untouched.
- Judgment a script can absorb goes in a script (orient/diff-inventory).
- Word/size deltas are smell checks; acceptance = tier0/tier1 green.
- Hook-grepped literals must be instructed by a live surface (tier0 C5/6).
- Never push main from agent sessions; claude/* branch pushes are fine.
- Outcome scores saturate at >=haiku-4.5 even hardened (verified genuine,
  incl. unseen seed=1); cost/turns are the discriminating A/B axis.
- Journal compaction is the sole sanctioned journal rewrite.
- Current Stop event text is authoritative; transcript parsing is
  compatibility fallback. Clean trees clear dirty-duration markers.

## Landmines
- Pedro's machine only: ~/.agents/skills → third checkout; ~/.claude/hooks
  are chezmoi copies. Deploy-drift WARNs elsewhere are expected noise.
- Scaffold placeholder token: construct at runtime in eval code and never
  put in .ai-sdlc files; skills scripts may contain it literally.
- tier0 asserts exact check-state.sh substrings ("target <=60", em-dash
  `## YYYY-MM-DD — ` header) — wording and checks change atomically.
- Keep `~/.agents/skills/sdlc-core/...` + sibling-fallback path forms;
  plugin keeps sibling resolution only while all skills ship together.
- tier0 self-test build_sandbox copies an explicit dir list — add any new
  top-level path a check reads (.claude-plugin bit this, 2026-07-07).
- Root tier1 runs error without IS_SANDBOX=1.
- GitHub-added marketplaces can't resolve relative "./" plugin sources
  (CLI 2.1.209) — keep the explicit github form; tier0 pins it.
- tier1 --seed is ignored under --dry-run (canned = canonical); keep
  per-variant keyword hygiene when growing variant pools.

## Next
1. Tier2: soften scenario prompts (drop the "actually run it" nudges) —
   discipline must come from the harness; likely the real discriminator.
2. Decompose overhead via stream-json (hook text vs skills vs turns);
   pull the deployment clone on Pedro's machine.

## History (digest through 2026-07-07)
- Six phase skills collapsed to start/finish + STANDARD.md; fenced
  templates and gated verdict tokens proved Sonnet-reproducible.
- Goodhart audit birthed OBJECTIVE.md + tier0/tier1 (coupled prose/grep
  pairs drift unless a check binds them); first haiku baseline 2026-07-07.
