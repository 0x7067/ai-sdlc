---
name: sdlc-debug
description: Diagnose and fix wrong behavior — a bug report, failing test, crash, stack trace, or red CI — through reproduce, isolate, root-cause, smallest fix, and regression proof. Use whenever behavior differs from expectation, even if the user just pastes an error, says "X is broken / doesn't work / used to work", or asks to "fix the failing test" without naming this skill. Not for building new features (sdlc-extend) or for the pre-ship gate (sdlc-validate).
---

# sdlc-debug — from wrong behavior to proven fix

Read `~/.agents/skills/sdlc-core/references/STANDARD.md` (fallback: the `sdlc-core/` sibling of this skill's directory) now — §2
(root cause over patch), §3 (scope), and §4 (verification ladder) govern this
skill.

Scope: this skill ends when the repro passes and a regression test exists. Broad
gates before shipping belong to sdlc-validate; session wrap-up to sdlc-handoff.

## Step 1 — Reproduce FIRST

Before reading source, before theorizing: make the failure happen on demand with
the cheapest command you can find. One test > module tests > full suite; a curl
or small script > booting the whole app. WHY: a bug you cannot reproduce, you
cannot prove fixed — any "fix" without a repro is a guess you'll ship.

- If `.ai-sdlc/state.md` exists, check its Verification path and Landmines
  sections for the right commands and known flakiness before hunting.
- Record the exact repro command; you will run it after every candidate fix.
- Can't reproduce? Vary environment (versions, env vars, data, ordering,
  repeated runs for flakiness) before touching code. If it's genuinely
  irreproducible, say so and switch to instrumenting (logs/assertions) —
  do not "fix" blind.

## Step 2 — Read the actual failure, then the actual source

Capture the full failure output — whole stack trace, whole assertion diff, real
CI log — not a paraphrase. Then open the implicated files and read the code as
it is today. Never patch from the error message or from memory of an API alone:
error text names the symptom's location, and your memory may not match this
version. The defect usually lives upstream of where the error fires.

## Step 3 — Isolate

Cheapest suspects first:

1. **Recent diff.** If this worked before: `git log --oneline -15 -- <suspect
   paths>` and `git diff` against the last known-good ref. Most bugs are in
   whatever changed last. `git stash` your own uncommitted edits to test whether
   *you* introduced it. Use `git bisect` when the breaking commit isn't obvious
   and a cheap repro exists.
2. **Shrink the repro.** Strip inputs, config, and code paths until the smallest
   thing that still fails remains. Every piece removed halves the search space.
3. **Find the boundary.** Locate where data is last correct and first wrong —
   with print/log statements, a debugger, or intermediate assertions. The defect
   lies between those two points.

## Step 4 — Hypothesis discipline

Loop, explicitly:

1. State the hypothesis in one sentence ("X is null because Y runs before Z").
2. Run the CHEAPEST test that discriminates it — a print, a one-line script,
   a targeted assertion. Not a speculative code edit.
3. Confirmed → fix. Refuted → count it and form the next hypothesis from what
   the evidence actually showed.

**After ~3 refuted hypotheses, STOP iterating in place.** WHY: thrashing —
re-editing the same file on hunches — is how debugging sessions burn their
budget with nothing to show. Instead widen: question an assumption you marked
"certain" (is the code you're reading even the code that runs? right branch,
build not stale, correct env/config?), re-read the failure output from the top,
search the codebase for other callers/consumers, and check the dependency's real
behavior, not your memory of it.

## Step 5 — Fix at the root cause

Apply the smallest change at the point where the defect lives, not where the
symptom appears (STANDARD §2-3). Catching the exception, widening a type, or
special-casing the failing input are symptom patches — reject them unless you
can argue the symptom point genuinely is the root cause.

## Step 6 — Prove it

1. Run the recorded repro command — the exact one from Step 1 — and observe it
   pass.
2. Add a regression test that fails without the fix and passes with it, in the
   project's existing test framework and style. Verify the fails-without-fix
   half: cheapest is to write the test and watch it fail BEFORE applying the
   fix; if the fix is already in place, stash only the fixed files
   (`git stash push -- <fix paths>`), watch the test fail, then
   `git stash pop`. Do NOT plain-`git stash` — that removes the new test too
   and the run errors instead of failing. WHY: a test that never failed
   proves nothing.
3. No test infrastructure in the project? Don't install one — write the
   smallest runnable check the repo supports (script, make target, documented
   manual command) and record it as the repro in your report.
4. Run the immediate blast radius (the affected module's tests). Full-suite and
   lint gates are sdlc-validate's job.

## Step 7 — Record the landmine

If the root cause was non-obvious — a trap the next session could re-hit (flaky
test, misleading name, env quirk, ordering constraint) — add one line to the
Landmines section of `.ai-sdlc/state.md`, per the format in
`~/.agents/skills/sdlc-core/references/STATE-SPEC.md`. If the file
doesn't exist, don't scaffold the full state system mid-debug; put the trap in
your final report instead.

Report per STANDARD §7: what changed, what was verified (repro before/after,
regression test observed failing then passing), remaining risk. Then hand to
sdlc-validate for the broad pre-ship gates; if the session ends here instead,
invoke sdlc-handoff.
