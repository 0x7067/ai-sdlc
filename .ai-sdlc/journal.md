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
