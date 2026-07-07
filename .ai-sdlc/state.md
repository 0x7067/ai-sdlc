# Project State
updated: 2026-07-07

## Goal
A skill library (sdlc-start + sdlc-finish + sdlc-core) that lets models —
including weaker ones — carry a project across sessions at a consistent
engineering standard. Mechanical layer does what scripts can; skills stay
advice-shaped. Installable as a Claude Code plugin; portable elsewhere via
install.sh. Execution between the gates is governed by STANDARD.md.

## Now
2026-07-07 milestone: the empirical loop is CLOSED — tier1 ran for real
(remote containers carry auth in env, not $HOME; IS_SANDBOX=1 needed as
root) and the first baseline is committed. Haiku 4.5 saturates all four
scenarios in both arms: outcome scores no longer discriminate at that
tier; cost does (resumption sdlc ≈40-60% of control tokens). Also landed:
orient.sh (one-command orientation), plugin packaging (verified end to
end with --plugin-dir + real model), reference files under the token
budget gate, tier0 portability fix (no-jq shim).

## Verification path
- `bash evals/tier0/run.sh` — exit 0, 167 assertions (2026-07-07).
- `bash evals/tier0/run.sh --self-test` — 7/7 mutations caught (2026-07-07).
- `IS_SANDBOX=1 bash evals/tier1/run.sh --scenario all --arm both --model
  claude-haiku-4-5-20251001` — all 8 runs green (2026-07-07); then
  `bash evals/tier1/compare.sh --baseline evals/tier1/baseline.json
  --results <results-file>` — OK.
- `bash skills/sdlc-core/scripts/check-state.sh .` — OK (2026-07-07).

## Decisions
- Frontmatter descriptions stay untouched; routing is the SessionStart
  hook's job (plugin installs auto-register it; gate teaches the
  ai-sdlc:* namespaced names).
- Judgment a script can absorb goes in a script; orient.sh is the read
  side (one command), diff-inventory.sh the write side.
- Size/word deltas are smell checks, never acceptance; acceptance =
  tier0/tier1 green (OBJECTIVE.md).
- Hook-grepped literals must be instructed by a live surface; hook + skill
  wording change atomically (tier0 enforces).
- Don't push main from an agent session — Pedro pushes. Feature-branch
  pushes to claude/* are fine (harness requirement, 2026-07-07).
- Journal compaction is the sole sanctioned journal rewrite.
- Equal A/B outcome scores at haiku tier mean the SCENARIOS saturated,
  not that sdlc has no effect — harden scenarios before reading them.

## Landmines
- Pedro's machine only: ~/.agents/skills resolves to a third checkout;
  ~/.claude/hooks are chezmoi COPIES. tier0 deploy-drift WARNs elsewhere
  (e.g. remote containers) — those WARNs are expected noise there.
- Never write the scaffold placeholder token literally into this repo's
  own .ai-sdlc files or committed eval code — construct at runtime
  (evals/*/lib/common.sh); skills scripts MAY contain it (scaffold/orient).
- tier0 asserts exact check-state.sh output substrings and the em-dash
  `## YYYY-MM-DD — ` journal header — wording edits must keep them or
  update checks in the same change.
- Skills cite core paths as `~/.agents/skills/sdlc-core/...` with sibling
  fallback — keep both forms. Plugin installs keep sibling resolution
  (all three skills ship in one plugin) — don't split them.
- tier0 self-test's build_sandbox copies an explicit dir list — any new
  top-level path a check reads must be added there (bit 2026-07-07 with
  .claude-plugin/).
- tier1 real runs as root need IS_SANDBOX=1 or every run errors
  "--dangerously-skip-permissions cannot be used with root".

## Next
1. tier1 scenario hardening so outcome scores discriminate again:
   randomized fixtures, harder resumption answer keys, non-keyword grading
   for false_ship/stale_state, spend guard; then re-baseline.
2. Run the A/B at Sonnet tier (haiku saturates) and cite results in
   README's empirics section — the 2026-07-07 baseline is cost-only
   evidence so far.
3. Verify marketplace install from GitHub after push (`/plugin marketplace
   add 0x7067/ai-sdlc`) — only `--plugin-dir` was verified locally.
4. Pedro (external): push main; pull the deployment clone.
5. Option A experiment (single `sdlc` skill) on branch experiment/one-skill
   — still unbuilt.
