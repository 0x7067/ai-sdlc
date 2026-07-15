# Journal

## 2026-07-07 — PR review branch pushed
- Did: pushed f0052cb to PR #1 and re-read thread-aware GitHub review state.
- Verified: original Devin thread isOutdated=true; gh-axi reports no CI checks configured; local branch matches origin.
- Learned: flat gh-axi review output still shows old inline text; GraphQL thread state is the useful source for outdated status.
- Left: no actionable PR review thread remains from the 2026-07-07 Devin comment.

## 2026-07-10 — merge harness hardening into main
- Did: merged `codex/harness-hardening` after 14 main-side commits; kept
  plugin/orient/leanness behavior and migrated hook, docs, and evals together.
- Verified: tier0 193/193; self-test caught 7/7; tier1 dry-run completed 8/8;
  shell syntax, strict state, and staged-diff checks passed.
- Learned: the retired Handoff/VERDICT tokens were embedded in tier0 and the
  objective, so hook-contract migration had to update executable proxies too.
- Left: parent remains pinned to `c7f89af`; it is now reachable from main.

## 2026-07-13 — validate Codex handoff transcripts
- Did: taught the canonical Stop gate to read Codex response-item assistant text.
- Verified: tier0 exits 0 with 195 assertions, including the Codex report branch.
- Learned: Claude and Codex store assistant text under different JSONL shapes.
- Left: scenario hardening and Sonnet-tier A/B remain unchanged.

## 2026-07-13 — harden current Stop event handling
- Did: preferred current assistant text, retained legacy transcript fallback, and timed only observed dirty periods.
- Did: made Claude plugin/direct Stop commands identical and taught the manifest check their fallback form.
- Verified: tier0 exits 0 with 203 assertions; both installed hook paths match this source and execute.
- Learned: transcript writes may lag Stop events; session-age markers falsely age later dirty work.
- Left: scenario hardening and Sonnet-tier A/B remain unchanged.

## 2026-07-14 — tier1 hardened + seeded variants; marketplace fix; sonnet/haiku baseline
- Did: 3 seeded fixture variants per scored scenario; resumption
  distractors, stale_state decoy, false_ship exit-0 runner; de-generified
  grader keywords; marketplace.json → explicit github plugin source
  ("./" fails on GitHub-added marketplaces); new two-model baseline.json.
- Verified: tier0 200 OK, self-test 7/7, dry-run 8/8 at prior scores;
  real runs 8/8 green per model + compare.sh OK; unseen seed=1 sonnet
  5/5 both arms; marketplace add+install+gate-fires in isolated HOME.
- Learned: outcome scores saturate >=haiku-4.5 even hardened; the A/B
  signal is cost (resumption sdlc ~75-80% of control, ceremony ~+2%,
  stale_state sdlc ~3x buying repair + validated handoff).
- Left: prompt-softened tier2 arms; overhead decomposition; deploy pull.

## 2026-07-15 — tier2 prompt-softened arms; fixture leak fixes; soft baseline
- Did: run.sh --prompt-style soft (guided prompts byte-identical) with
  canned soft dry-run fixtures; fixed fixture git-history leaks (commit
  messages carried disclosure keywords — git log alone earned passes);
  absolutized run.sh --out; folded soft baseline (sdlc cells gated).
- Verified: tier0 200 OK, self-test 7/7, dry-run 8/8 both styles,
  compare OK; A/Bs: resumption sdlc 5/5 x8 vs control flaky (3-5/5,
  distractor hits); stale_state saturated (every pass repaired=1);
  false_ship soft sonnet sdlc 4/6 vs control 1/6, haiku 3/6 vs 3/6.
- Learned: soft discriminates only for sonnet — the gate's small-edit
  carve-out misses ship-verdict claims; flaky cells = null + rate notes.
- Left: lifecycle-gate claim-vs-edit fix; overhead split; deploy pull.
