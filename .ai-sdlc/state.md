# Project State
updated: 2026-07-06

## Goal
A skill library (sdlc-start + sdlc-finish + sdlc-core) that lets models
carry a project across sessions at a consistent engineering standard.
Portable across harnesses; routing made deterministic by a SessionStart
hook. Execution between the gates is governed by STANDARD.md, not skills.

## Now
Evals milestone landed (2026-07-06): `evals/OBJECTIVE.md` defines "better"
(resumption fidelity, claim integrity, overhead) and maps every proxy to an
axis; `evals/tier0/` is a deterministic regression suite (141 assertions +
7-mutation self-test); `evals/tier1/` is a behavioral harness (resumption
Q&A, stale-state trap, false-SHIP honesty, overhead; control-vs-sdlc arms) —
dry-run verified, real runs blocked on auth (see Next 1). A Goodhart audit
found 7 drifts; the worst (Stop-hook branches A/B dead — no live surface
instructed "Handoff report"/"VERDICT: SHIP" after the Phase 2 collapse) is
fixed: sdlc-finish now instructs both literals and a tier0 coherence check
prevents recurrence. Deployed-hook carve-outs (AI_SDLC_SCRATCH, agentctl
exemptions) were hand-patched only in ~/.claude/hooks — now ported into
hooks/ source. Option A experiment (single `sdlc` skill) still pending on
branch experiment/one-skill.

## Verification path
- `bash evals/tier0/run.sh` — exit 0, 141 assertions (2026-07-06).
- `bash evals/tier0/run.sh --self-test` — 7/7 seeded regressions caught
  (2026-07-06).
- `bash evals/tier1/run.sh --scenario all --arm both --dry-run` — full
  generate→invoke→grade pipeline green (2026-07-06); real model runs
  unverified (auth blocker, evals/tier1/SMOKE.md).
- `bash skills/sdlc-core/scripts/check-state.sh .` — OK (2026-07-06).

## Decisions
- Frontmatter descriptions stay untouched — triggering is solved by the
  SessionStart hook (empirical, README "Why the hook exists"; transcripts
  not preserved — tier1 A/B exists to re-ground this).
- Templates over prose for every checkable behavior; judgment a script can
  absorb goes in a script.
- Size/word deltas (±20% budget) are a smell check only, never acceptance
  evidence; acceptance = tier0/tier1 green (2026-07-06, per OBJECTIVE.md).
- Any literal a hook greps for must be instructed by a live surface; hook
  wording + skill wording change as one atomic edit (tier0 enforces).
- Don't push main from an agent session — commit locally, Pedro pushes.
- Journal compaction is the sole sanctioned journal rewrite
  (compact-journal.sh); Stop hook blocks via exit 2 + stderr, self-limited.

## Landmines
- Skills are NOT live from this repo: `~/.agents/skills` resolves through
  `~/.agents/ai-sdlc` to a third checkout, `~/Development/agentctl/ai-sdlc`
  (pull-based). tier0's deploy-drift check WARNs until it pulls.
- `~/.claude/hooks/*` are chezmoi-managed COPIES; hooks/ source and copies
  are byte-identical as of 2026-07-06 — keep them that way (tier0 WARNs).
- Never write the scaffold placeholder token literally into this repo's own
  .ai-sdlc files or committed eval code — construct it at runtime
  (evals/*/lib/common.sh show how).
- tier0 asserts exact check-state.sh output substrings ("target <=80",
  "modified more than 24h after") — wording edits must preserve them or
  update evals/tier0/checks/10-check-state-matrix.sh in the same change.
- Skills cite core paths as `~/.agents/skills/sdlc-core/...` with a sibling
  fallback — keep both forms when editing.
- check-state.sh requires the em-dash `## YYYY-MM-DD — ` journal header;
  hyphen forms FAIL on first onboard (intended drift repair).

## Next
1. Run tier1 for real: needs `claude setup-token` →
   `CLAUDE_CODE_OAUTH_TOKEN` (external: Pedro's auth). Baseline both arms
   (haiku first), write evals/tier1/baseline.json, record in journal.
2. Milestone 2 (real-codebase A/B) now = tier1 `--arm control|sdlc` runs;
   done when results land in journal and README's empirics claim cites them.
3. Deployment: push/pull so ~/Development/agentctl/ai-sdlc picks up today's
   skill + script edits (external: Pedro pushes); confirm deploy-drift
   WARNs clear.
4. tier1 hardening: randomized fixtures, non-keyword grading for
   false_ship/stale_state, spend guard for batch runs.
