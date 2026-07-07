# Journal

## 2026-07-02 — Sonnet-tuning pass across all lifecycle skills
- Did: added Sonnet-class compliance scaffolding to the six lifecycle
  SKILL.md files and STANDARD.md §7 — fenced fill-in templates for every
  checkable output (pre-flight, skip check, orientation summary, hypothesis
  ledger, validation report with VERDICT token + SHIP precondition, acid
  test, handoff report), written skip-gates, quoted-output evidence rules, a
  hard 3-edits-without-a-check cap, repro-output gate in debug, and bold
  `Exit →` chaining lines. Created .ai-sdlc/ state files (repo's first).
- Verified: `bash -n install.sh hooks/sdlc-lifecycle-gate` → "SYNTAX OK";
  frontmatter + balanced-fence check over all SKILL.md → OK; wc -w total
  6299 → ~6725 (+6.8%). Two Sonnet subagent probes against a toy repo with
  planted debris: sdlc-plan probe produced the filled Skip check block, ran
  and quoted the baseline test, routed to sdlc-extend; sdlc-validate probe
  produced the verbatim report block, caught the planted DEBUG print and
  untracked debug.log, applied fix-then-revalidate, correct VERDICT: SHIP.
- Learned: Sonnet reproduces fenced fill-in blocks verbatim and honors
  precondition-gated verdict tokens; probe agents also respected scope
  discipline (left out-of-scope debris alone in the plan probe). The
  toy-repo + planted-debris probe method is cheap and reusable.
- Left: real-codebase headless A/B (Next 1), probes for the four unprobed
  skills (Next 2), single-command check script (Next 3). Branch main is
  unpushed — pushing left to Pedro.

## 2026-07-02 — Artifact hygiene: compaction policy, check-state.sh, full probe coverage
- Did: added to STATE-SPEC a journal compaction policy (>~200 lines →
  fold all but newest 5 entries into a digest; sole sanctioned rewrite),
  state.md caps (target 80 / hard fail 120 lines), and a Hygiene checks
  section. New `skills/sdlc-core/scripts/check-state.sh` enforces the spec
  mechanically. Wired it into sdlc-handoff (post-journal check, compaction
  step, 5th acid-test line) and sdlc-onboard (Step 3 drift check). Probed
  the four previously unprobed skills with Sonnet subagents on toy repos.
- Verified: `bash -n` on all scripts → SYNTAX OK; fence/frontmatter checks
  → OK; `check-state.sh .` → exit 0 "check-state: OK"; broken fixture →
  exit 1 with 8 named FAILs; word deltas handoff +7.2% / onboard +4.0%
  (≤20% budget); all four probes produced their required trace blocks
  (Orientation / Pre-flight / hypothesis ledger + quoted repro / 5-line
  acid test + handoff report); handoff probe compacted its journal
  210→72 lines with a correct digest and byte-identical retained entries.
- Learned: Sonnet honors script-triggered imperatives — it compacted on a
  WARN even though exit code was 0; script-backed checks + prose judgment
  is the right split. sdlc-handoff's missing `Exit →` line is by design
  (terminal skill); the probe flagged it and handled it correctly.
- Left: real-codebase A/B (Next 1); single-command check script (Next 2).
  Branch main is unpushed — pushing left to Pedro per standing decision.

## 2026-07-03 — mechanical layer: three scripts, placeholder contract, Stop-hook handoff gate
- Did: added sdlc-core/scripts/{scaffold-state,compact-journal,diff-inventory}.sh;
  extended check-state.sh to FAIL on unfilled scaffold placeholders and on a
  leftover journal.md.bak; added hooks/sdlc-handoff-gate (Stop hook: verifies
  "Handoff report" via check-state.sh, reminds on SHIP+dirty tree, 45-min
  dirty-tree nag, self-limited by stop_hook_active + marker file); wired
  onboard/validate/handoff skills, STATE-SPEC, README, install.sh.
- Verified: bash -n all bash → OK; frontmatter/fence scan → OK;
  check-state.sh . → OK; fixture-repo functional runs of all three scripts
  (incl. byte-for-byte retained-tail diff for compaction) and 8 hook-branch
  simulations (exit 0/2 as designed) — all observed passing 2026-07-03.
- Learned: ~/.agents/skills/sdlc-* resolve to ~/.agents/ai-sdlc, a separate
  pull-based deployment clone — NOT this repo; a stale deployed
  check-state.sh made one hook test false-pass until $HOME was isolated.
  ~/.claude/hooks/* are chezmoi-managed copies, not symlinks.
- Left: milestone 2 (real-codebase A/B, now incl. a handoff task for the
  Stop gate) and the checks.sh bundler, per state.md Next.

## 2026-07-05 — Phase 2 Bitter Lesson collapse: six phase skills -> start/finish
- Merged onboard+plan into sdlc-start (74 lines) and validate+handoff into
  sdlc-finish (57 lines); deleted extend/debug outright — execution is now
  governed by STANDARD.md alone. Both new skills are advice-shaped:
  objectives + rationale + pointers, no step recipes, no "routing
  violation"/"binding" language.
- Renamed references in hooks (lifecycle gate text, handoff gate messages),
  README, agents-md snippet, sdlc-core SKILL.md; name-only prose updates in
  STATE-SPEC.md and script headers. STANDARD.md byte-identical. Hook
  filenames unchanged, so installed settings.json entries stay valid.
- Distrust next session: the merged frontmatter descriptions have NOT been
  probe-tested for auto-triggering (old decision "descriptions stay
  untouched, hook solves routing" still stands, but the hook text changed
  too). The 2026-07-03 fixture verification of hook branches predates the
  message-text edits — mechanics untouched, but re-run fixtures before
  trusting branch A/B wording claims.
- Option A (single `sdlc` skill) to be built on branch experiment/one-skill
  for comparison; main deploys the two-skill shape.

## 2026-07-06 — Objective function, tier0/tier1 evals, Goodhart audit + fixes
- Did: defined "better" in evals/OBJECTIVE.md (resumption fidelity > claim
  integrity > overhead; proxy map + anti-Goodhart rules). Built
  evals/tier0 (deterministic: check-state matrix, hook branches, script
  functional, surface token budgets, spec<->script coherence, deploy-drift
  advisory, KNOWN-DRIFT allowlist with staleness detection, --self-test
  mutation harness) and evals/tier1 (behavioral: resumption/stale-state/
  false-SHIP/overhead scenarios, control-vs-sdlc arms, isolated $HOME,
  deterministic graders, baseline compare). Ran a 3-agent workflow
  (auditor + two builders); audit confirmed 7 Goodhart drifts. Fixed: dead
  Stop-hook branches (sdlc-finish now instructs the literal "VERDICT:
  SHIP/NO-SHIP" and "Handoff report" tokens); check-state.sh WARN wording
  no longer teaches date-restamping and the 80-line WARN names safe trim
  targets; new advisory WARN flags Verification-path files missing from
  the repo; deployed-hook exemption logic (AI_SDLC_SCRATCH,
  agentctl.config.json) ported from ~/.claude/hooks into hooks/ source;
  state.md's stale six-skill probe claim corrected.
- Verified: evals/tier0/run.sh exit 0 (141 assertions); --self-test 7/7
  mutations caught; tier1 --dry-run all 8 scenario×arm combos green and
  graders discriminate (control 1/5 vs sdlc 5/5 on resumption);
  check-state.sh path-WARN fires on a synthetic missing path and stays
  quiet on this repo; diff hooks/ vs ~/.claude/hooks/ → identical;
  bash -n on all touched bash → OK. NOT verified: tier1 against a real
  model (isolated $HOME has no login; needs CLAUDE_CODE_OAUTH_TOKEN —
  exact blocker in evals/tier1/SMOKE.md).
- Learned: the Phase 2 collapse silently killed both content-verifying
  hook branches — coupled prose/grep pairs drift unless a check binds
  them (now tier0 coherence). The deployed copies carried hand-patched
  logic that existed nowhere in git; "tested here" != "runs there" until
  the deploy-drift check said so. One tier0 builder died mid-run
  (API connection drop); the workflow resume + journal cache recovered it
  without rework.
- Left: tier1 real-model baseline (Next 1, needs Pedro's token); deploy
  clone pull (Next 3); the 2 KNOWN-DRIFT coherence entries were fixed and
  removed same-session, so the allowlist is empty — keep it that way.

## 2026-07-07 — tier1 unblocked + first real baseline; plugin packaging; orient.sh
- Did: closed the empirical loop — remote containers carry claude auth in
  env (not $HOME), so tier1's isolated-$HOME harness just works; root needs
  IS_SANDBOX=1. Ran all 8 scenario×arm haiku runs, wrote baseline.json,
  verified compare.sh green. Packaged the repo as a Claude Code plugin
  (.claude-plugin/{plugin,marketplace}.json, hooks/hooks.json; gate now
  teaches ai-sdlc:* names, "installed policy" phrasing). Added orient.sh
  (one-command orientation; sdlc-start instructs it; sdlc-finish now names
  diff-inventory.sh). Put STANDARD/STATE-SPEC under the token budget gate;
  re-baselined budgets. Fixed tier0 no-jq check (shim PATH — /bin symlinks
  /usr/bin here) and self-test sandbox (.claude-plugin copy).
- Verified: tier0 167 assertions exit 0; --self-test 7/7; tier1 8/8 runs
  is_error=false + compare.sh OK; plugin end-to-end via --plugin-dir in an
  isolated $HOME (real haiku quoted the injected gate text and listed all
  three namespaced skills); check-state.sh OK.
- Learned: haiku 4.5 saturates every tier1 scenario in BOTH arms — outcome
  scores stopped discriminating at this tier; cost still discriminates
  (resumption sdlc ≈40-60% of control tokens, fewer turns). Equal scores
  mean weak scenarios, not "sdlc does nothing". Also: PATH-prefixed
  commands resolve the command word with the NEW path (shim must include
  bash itself).
- Left: scenario hardening + Sonnet-tier A/B (state.md Next 1-2);
  marketplace-add install unverified until the repo is on GitHub (Next 3);
  branch pushed to claude/ai-sdlc-framework-lean-avh8fi, main untouched.

## 2026-07-07 — leanness enforced: caps tightened, unearned comments = defects
- Did: state.md target 80→60 (hard 120 stays); newest-journal-entry WARN
  >12 lines (older entries immutable, so newest only); diff-inventory.sh
  now surfaces every added comment line (code files, md excluded) for the
  STANDARD §3 review; §3 names unearned comments validation defects;
  sdlc-finish hunts them. Trimmed this repo's state.md 80→60.
- Verified: tier0 175 assertions exit 0; --self-test 7/7; check-state.sh
  OK (no WARNs on own artifacts); new matrix fixtures cover warn/quiet.
- Learned: journal fixture (m) appends filler inside the newest entry —
  entry-length checks must stay WARN-only or that fixture wedges.
- Left: state.md Next unchanged (scenario hardening still #1).
