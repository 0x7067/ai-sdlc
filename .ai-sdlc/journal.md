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
