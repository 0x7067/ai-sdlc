# Journal

## 2026-07-20 — attempt the paid guided Tier 1 evaluation
- Did: invoked the real all-scenario, both-arm Tier 1 command; it stopped before model calls.
- Verified: Claude CLI is logged in, but neither supported token variable is exported; no calls or charges occurred.
- Learned: the isolated A/B homes cannot safely reuse the normal Claude profile without contaminating control.
- Left: export `CLAUDE_CODE_OAUTH_TOKEN` or `ANTHROPIC_API_KEY`, then rerun the recorded command.

## 2026-07-20 — authorize direct-main publication of the one-PR rule
- Did: finalized the implementation, regression guard, state, and journal for one atomic direct-main commit.
- Verified: local main matched origin/main before commit; tier0 216/216, self-test 8/8, strict state, and diff hygiene passed.
- Learned: the failed paid Tier 1 attempt remains a disclosed follow-up, not publication evidence.
- Left: export supported auth and run paid Tier 1; restart fresh harness sessions to load the guidance.

## 2026-07-22 — compaction becomes a session boundary
- Did: made sdlc-lifecycle-gate source-aware (compact-source recovery
  injection), added the step-checkpoint invariant to sdlc-start/STATE-SPEC/
  snippet, tier0 coverage with a 9th self-test mutation, and a tier1
  compaction scenario (3 variants, guided+soft, dry-run fixtures).
- Verified: tier0 236/236; self-test 9/9; tier1 dry-run 10/10 guided and
  10/10 soft; one adversarial reviewer reproduced all evidence, verdict
  SHIP WITH FIXES — all three findings applied and gates re-run green.
- Learned: headless -p sessions always start source=startup, so tier1 can
  only grade artifact-driven recovery; the injection itself is tier0's job.
- Left: committed on feat/compaction-boundary, unpushed; no paid tier1 run.

## 2026-07-22 — lean pass over every injected surface
- Did: rewrote both hook texts, the three SKILL.md files, STANDARD.md,
  STATE-SPEC.md, and the agents-md snippet to state each instruction once
  and cut rationale (3974->2934 words, -26%; per-session hook tax -40%);
  budgets re-baselined to the new actuals.
- Verified: tier0 236/236; self-test 9/9; tier1 dry-run 10/10 guided and
  10/10 soft, grading identical to the pre-lean contract; reviewer said
  SHIP — its one minor fixed by restoring the config clause to the gate.
- Learned: line-wrapping silently breaks coherence needles — grepped
  literals must stay contiguous on one line.
- Left: committed on feat/lean-surfaces, unpushed; prose behavioral
  neutrality is unproven until the paid tier1 A/B runs.

## 2026-07-22 — first local paid tier1 run (haiku, guided + soft)
- Did: ran all 5 scenarios x 2 arms in both prompt styles (~5.6M haiku
  tokens) via a user-minted setup-token; added compaction cells to
  baseline.json as ungated rate notes; fixed a grader hyphenation miss
  ("parsing-only").
- Verified: compare gate — every pre-existing outcome cell matched
  baseline exactly; overhead/sdlc FAILED at +721% (626,632 vs 76,303
  tokens, 31 turns on the one-line task). Deliberately not re-baselined.
- Learned: compaction at haiku splits by style — guided recovers the
  work silently; soft discloses but leaves it unfinished.
- Left: overhead-regression is the open milestone-relevant item; token
  env file stays untracked at ~/.claude/tier1-auth.env.
