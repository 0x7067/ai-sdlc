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

## 2026-07-14 — install globally for Claude Code and Codex
- Did: repointed both global skill directories and Claude hook symlinks to this checkout; merged the missing SessionStart registration.
- Verified: all eight symlinks resolve; hook emits only in git repos; tier0 exits 0 with 203 assertions and no deployment warnings.
- Learned: global routing and the Stop registration already existed, so both were preserved.
- Left: restart Claude Code and Codex sessions to load the new global skill targets.

## 2026-07-14 — extend global install to Pi and oh-my-pi
- Did: linked all three skills into Pi and oh-my-pi's native user skill directories.
- Verified: all six links resolve to this checkout; both harness instruction files contain SDLC routing; client versions execute.
- Learned: Pi uses ~/.pi/agent/skills; oh-my-pi uses ~/.omp/agent/skills.
- Left: restart Pi and oh-my-pi sessions to load the new skills.

## 2026-07-15 — tier2 prompt-softened arms; fixture leak fixes; soft baseline
- Did: run.sh --prompt-style soft (guided byte-identical) + canned soft
  dry-run fixtures; fixed fixture git-history keyword leaks (git log
  earned passes); absolutized --out; folded soft baseline (sdlc gated).
- Verified: tier0 200 OK, self-test 7/7, dry-run 8/8 both styles, compare
  OK; A/Bs: resumption sdlc 5/5 x8 vs flaky control; stale_state
  saturated (all repaired=1); false_ship sonnet 4/6 vs 1/6, haiku 3/6 tie.
- Learned: soft discriminates only for sonnet (gate's small-edit carve-out
  misses ship-verdict claims); flaky cells = null + rate notes. Overhead
  delta = one-time ~500-tok session-start tax (hook text ~200 + skill
  digest ~290), no skill reads, Stop hook ~0, no compounding.
- Left: lifecycle-gate claim-vs-edit fix; deploy pull on Pedro's machine.

## 2026-07-15 — reconcile main and refresh Claude/Codex installs
- Did: merged origin/main into local main, preserving the deployment commit;
  unioned state/journal conflicts and refreshed both global skill roots/hooks.
- Verified: both parent histories reachable; 8/8 links resolve; Claude and
  Codex hook registrations target this checkout; tier0 205/205.
- Learned: Codex Stop resolves through ~/.agents/ai-sdlc; Claude owns both gates.
- Left: local main remains unpushed per standing policy.

## 2026-07-20 — remove the Codex-breaking dirty-tree Stop timer
- Did: removed the 45-minute blocking reminder, its marker state, tests, and docs; retained strict validation for explicit three-field completion claims.
- Verified: tier0 182/182, self-test 7/7, dirty ordinary-response regression, and diff check passed.
- Learned: the live Codex hook resolves through agentctl's ai-sdlc checkout, not this standalone copy; both were updated.
- Left: changes are intentionally uncommitted and unpushed; tier1 was not rerun.

## 2026-07-18 — key lifecycle ceremony on claim blast radius
- Did: lifecycle gate, start/finish skills, and routing snippet now route
  any done/verified/ship claim through sdlc-finish regardless of edit
  size; sdlc-finish description states the claim trigger; budgets.txt
  re-baselined via --print-actual paste (untouched surfaces synced too).
- Verified: tier0 200/200 + self-test 7/7 (remote container; 5 deploy
  WARNs expected uninstalled); tier1 dry-run exit 0, guided and soft.
- Learned: wording-only fix — the 2026-07-15 false_ship-soft gap (haiku
  3/6 tie) stays unmeasured until a real soft A/B runs.
- Left: re-run false_ship soft A/B; deploy pull on Pedro's machine.

## 2026-07-18 — adopt the Xit task-item profile
- Did: specified Xit plans/Next, added scaffold and strict validation, migrated tier fixtures, and updated start/finish behavior.
- Verified: tier0 225/225, self-test 7/7, tier1 dry-run 8/8, shell syntax, surface budgets, and strict state.
- Learned: validate mechanical line shape only; ownership, dependencies, deadlines, and proof quality remain model judgment.
- Left: detached checkout is intentionally dirty/unpushed; publish through a branch and parent pin after review.

## 2026-07-18 — publish the Xit profile branch
- Did: committed the complete profile as `edcc330` on `codex/xit-task-profile` and pushed it to origin.
- Verified: remote branch resolved to the implementation commit before this handoff update; strict state and diff hygiene passed.
- Learned: feature-branch publication preserves the standing no-direct-main-push decision for AI-SDLC.
- Left: parent agentctl must pin and publish this final handoff commit.

## 2026-07-18 — fast-forward Xit into AI-SDLC main
- Did: fast-forwarded `main` through `d672b9f` and pushed it with the user's direct authorization.
- Verified: the merge was linear from `286c2d9`; origin/main matched `d672b9f` before this handoff update.
- Learned: direct authorization permits main publication; feature branches remain the default otherwise.
- Left: parent agentctl must pin and publish this final main handoff commit.

## 2026-07-18 — re-measure false_ship-soft under the claim-keyed gate
- Did: reran the 2026-07-15 protocol headless (2 rounds x 3 seeds x 2
  arms x 2 models, soft); folded rates into baseline.json notes;
  resolved [x] #id=false-ship-soft (its #verify ran, seeds 0-2).
- Verified: 24/24 runs, no errors; sonnet sdlc 6/6 vs control 4/6;
  haiku sdlc 5/6 vs control 5/6 (2026-07-15: 4/6 v 1/6, 3/6 v 3/6).
- Learned: controls drifted up (different machine/CLI/day) — attribution
  weak, rates comparable same-day only. Residual haiku miss ran full
  finish ceremony without ever running the suite (→ finish-baseline-rerun).
- Left: deploy pull on Pedro's machine.
## 2026-07-18 — run-stamp contract closes the haiku false-ship gap
- Did: Verification-path run-date stamps — strict check-state FAILs a
  ship report unless the section's newest stamp is from that day (or a
  dated 'not re-run' disclosure); spec, finish skill, tier0 fixtures,
  matrix cases, and self-test mutation #8 moved atomically.
- Verified: tier0 228/228, self-test 8/8; same-day soft A/B (36 runs):
  haiku sdlc 12/12 vs control 5/12, sonnet 6/6 vs 2/6; every sdlc pass
  names the specific failing test. Resolved [x] finish-baseline-rerun.
- Learned: the missing discriminator was mechanical — a freshness check
  models must satisfy beats prose they imitate shallowly.
- Left: deploy pull; branch merge to main awaits user decision.

## 2026-07-19 — carry Pi-safe metadata over the merged main
- Did: rebased the YAML-quoting change onto PR #2, retaining its newer claim-blast-radius wording, and refreshed the main handoff truth.
- Verified: tier0 233/233, strict state, clean rebase, and all three skill descriptions parse as quoted YAML scalars.
- Learned: the run-stamp gate correctly blocks publication when a prior-day verification section is merely inherited.
- Left: tier0 self-test and tier1 were explicitly not rerun; fresh harness sessions still need to reload the merged guidance.

## 2026-07-20 — remove the Codex-breaking dirty-tree Stop timer
- Did: removed the 45-minute blocking reminder and marker state from the canonical live hook; updated regression tests, docs, and its reduced surface budget.
- Verified: tier0 214/214, self-test 8/8, dirty ordinary-response regression, and diff check passed.
- Learned: a Stop-hook reminder implemented with exit 2 becomes a new Codex user turn and disrupts the answer it meant to annotate.
- Left: changes are intentionally uncommitted and unpushed; tier1 and a fresh Codex-process probe were not run.

## 2026-07-20 — authorize timer-removal publication
- Did: finalized the canonical live checkout for direct main publication; explicit completion-claim blocking remains unchanged.
- Verified: tier0 214/214, self-test 8/8, direct live-hook smoke, strict state, and diff hygiene passed.
- Learned: the older standalone checkout shares this remote and must merge the published head rather than push a competing main.
- Left: tier1 and a fresh Codex-process probe were not rerun; the parent must pin the final reconciled ai-sdlc SHA.
