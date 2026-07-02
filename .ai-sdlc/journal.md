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
