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

