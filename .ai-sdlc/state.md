# Project State
updated: 2026-07-07

## Goal
A skill library (sdlc-start/finish/core) that lets models — weaker ones
included — carry a project across sessions at a consistent standard.
Scripts do what scripts can; skills stay advice-shaped. Claude Code
plugin install; install.sh elsewhere; STANDARD.md governs execution.

## Now
Empirical loop closed 2026-07-07: tier1 runs for real in remote
containers (auth is env-carried; IS_SANDBOX=1 as root), first haiku
baseline committed. Haiku saturates all scenarios in both arms — cost
discriminates (sdlc resumption ≈40-60% of control tokens), scores don't.
Leanness now enforced: state target 60 lines, newest journal entry warns
>12; unearned comments are validation defects surfaced by diff-inventory.

## Verification path
- `bash evals/tier0/run.sh` — exit 0, 175 assertions (2026-07-07).
- `bash evals/tier0/run.sh --self-test` — 7/7 caught (2026-07-07).
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

## Next
1. Harden tier1 scenarios (randomized fixtures, harder answer keys,
   non-keyword grading, spend guard) so scores discriminate; re-baseline.
2. Sonnet-tier A/B; cite results in README empirics (haiku is cost-only).
3. After GitHub push: verify `/plugin marketplace add 0x7067/ai-sdlc`
   install path (only --plugin-dir verified).
4. Pedro (external): push main; pull the deployment clone.
5. Option A (single `sdlc` skill) on experiment/one-skill — unbuilt.
