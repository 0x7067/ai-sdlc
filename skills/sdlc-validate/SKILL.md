---
name: sdlc-validate
description: Pre-ship gate after any substantive change and before commit, PR, or handoff. Runs the verification ladder narrowest-first, self-reviews the full diff as a hostile reviewer, and produces an evidence report with an explicit ship / fix / escalate decision. Trigger when the user says "validate", "verify this", "is it done", "ready to ship/commit/PR?", or whenever you are about to declare a nontrivial change finished — even if nobody asked for a gate.
---

# sdlc-validate — the pre-ship gate

You are about to claim a change is done. This skill exists because "looks done"
and "is done" diverge constantly, and the reader will act on your claim without
re-checking. Nothing ships until it passes this gate.

First, Read `~/.agents/skills/sdlc-core/references/STANDARD.md` (fallback: the `sdlc-core/` sibling of this skill's directory) —
§4 (verification ladder), §5 (evidence), and §7 (report format) are the
contract this skill enforces. Do not proceed from memory of it.

## Step 1 — Pin down the diff under review

Establish exactly what is being validated. Run
`bash ~/.agents/skills/sdlc-core/scripts/diff-inventory.sh` (fallback: the
`scripts/` dir in the `sdlc-core/` sibling of this skill's directory; pass
the base ref when work spans commits) — one deterministic block: branch,
status, staged/unstaged stats, untracked files, stashes. Then read the hunks
themselves with `git diff` (plus `git diff --cached` if staged).

Untracked files have no hunks, so a hunk-only review misses them — and they
are where leftover temp files, debug scripts, and secrets most often live.
Read each file the inventory lists as untracked in full as part of Step 3.

No git repo? Diff against whatever baseline exists (backup copies, the
task description) and note the weaker baseline in the report.

## Step 2 — Run the verification ladder (STANDARD §4)

Climb the §4 ladder in order — narrowest rung first, then blast radius,
then the broad gates — and if the change has a runtime surface, exercise
it for real as §4 requires. Find the project's commands in
`.ai-sdlc/state.md` (Verification path section), CI config, package
manifests, or Makefile — in that order.

**No tests in this project?** That does not waive the gate. Verify by
exercising the behavior directly — run the actual code paths with real
inputs, capture the observed output — and state plainly in the report that
verification was manual because no test suite exists.

Record every command you run **with its decisive output line quoted
verbatim** as you go; you will need them in Step 4. A result you cannot
quote is a result you did not observe.

## Step 3 — Hostile self-review of the diff

Read **every hunk** of the diff as a reviewer trying to reject it — not
skimming for familiarity, reading for defects. WHY: you wrote this code
minutes ago; familiarity is exactly what hides the bug. Check each hunk for:

- **Correctness**: off-by-ones, inverted conditions, unhandled error paths,
  wrong edge behavior.
- **Debris**: leftover debug prints, commented-out code, TODO placeholders,
  temp files, unused imports.
- **Scope creep**: changes unrelated to the task — revert them or explicitly
  justify each one (STANDARD §3).
- **Accidental deletions**: every removed line — did you mean to remove it,
  and does anything still reference it?
- **Secrets**: keys, tokens, credentials, internal URLs. These block shipping
  unconditionally.

Anything found here means fixes. **Revalidation rule**: after any fix,
rerun Step 2 starting at the narrowest rung the fix touches and re-climb
through the broad gates before issuing a verdict. A diff edited after
verification is an unverified diff.

## Step 4 — Evidence report (STANDARD §7)

Produce the report by filling in this block — every line, no omissions:

```
## Validation report
What changed: <files and behavior, plain sentences>
What was verified:
- `<command>` → "<quoted decisive output line>"   (run this session, current diff)
- ...one line per command from Step 2...
Unverified: <anything NOT run this session against the current diff — or "nothing">
Remaining risk: <assumed, deferred, or untested — "None" must be earned, not defaulted>
VERDICT: <SHIP | FIX, THEN REVALIDATE | ESCALATE>
```

"Verified" means run *this session* against the *current diff*, output quoted.
Anything else goes under **Unverified** — never assumed, never inherited from
an earlier run against different code.

## Step 5 — Gate decision

End with exactly one verdict:

- **SHIP** — every rung green, diff clean, no unexplained results.
  **Precondition**: every command under "What was verified" has quoted
  output from this session against the current diff. If any line lacks a
  quote, SHIP is not available — run the command or list it as Unverified
  and downgrade the verdict.
- **FIX, THEN REVALIDATE** — name the defects, fix, and apply the Step 3
  revalidation rule: rerun Step 2 from the narrowest rung the fix touches
  and re-climb through the broad gates. Never only the failing command.
- **ESCALATE** — a blocker you cannot resolve (missing decision, broken
  environment, red result you cannot explain). State the specific blocker
  and what you tried (STANDARD §8).

Never ship on a red or unexplained result — "probably flaky" is a hypothesis
to prove (rerun it; find the cause), not a waiver. If validation passes and a
session handoff follows, that is sdlc-handoff's job, with this report as input.
