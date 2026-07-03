---
name: sdlc-handoff
description: End-of-session handoff — persist everything the next session needs into .ai-sdlc/state.md and .ai-sdlc/journal.md, commit or explain every change in the working tree, and leave cold-startable next steps. Trigger when the user says to wrap up, hand off, pause, stop for the day, or switch tasks; when context is nearly exhausted; or when you are about to end any working session that changed code, plans, or understanding. Do not use for planning (sdlc-plan) or the pre-ship quality gate (sdlc-validate) — this skill only persists session state.
---

# sdlc-handoff — leave the session cold-startable

You are ending a working session. The next session starts with zero memory of
this one — not the same model, not the same context, nothing. Everything it
needs must survive in the repo. A handoff that requires asking the human "what
was I doing?" is a failed handoff.

First, Read `~/.agents/skills/sdlc-core/references/STATE-SPEC.md` (fallback: the `sdlc-core/` sibling of this skill's directory).
It defines the exact format of state.md and journal.md. Follow it precisely;
do not improvise sections.

## Step 1 — Settle the working tree

Run `bash ~/.agents/skills/sdlc-core/scripts/diff-inventory.sh` (fallback:
the `scripts/` dir in the `sdlc-core/` sibling of this skill's directory) —
it also surfaces the stashes and untracked files you must account for.
Then, for every change:

- **Completed, verified work**: commit it now, in logical units, following the
  repo's commit conventions (check `git log --oneline -10` for style). If
  pushing is clearly expected, push the current branch only — never the
  default branch, and never merge. If you cannot tell whether pushing is
  expected, commit locally, skip the push, and note in state.md that the
  branch is unpushed and why. WHY: a wrong push is publicly visible and hard
  to undo; everything else in this skill is local.
- **Incomplete or unverified work**: leave it uncommitted (or commit to a WIP
  branch if the repo's flow prefers that), and record in state.md **what it
  is, why it exists, and why it isn't committed** — file paths included.
- **Mystery changes you don't recognize**: do NOT commit or revert them. List
  them under Landmines with your best guess. WHY: a mystery dirty tree is the
  single most common handoff failure — the next session either loses work
  reverting it or ships something nobody understands.

Never `git stash` at handoff: stashes are invisible to a fresh session reading
state.md.

## Step 2 — Overwrite state.md to current truth

If `.ai-sdlc/state.md` does not exist, this is the repo's first handoff: run
`bash ~/.agents/skills/sdlc-core/scripts/scaffold-state.sh` (fallback: the
`scripts/` dir in the `sdlc-core/` sibling of this skill's directory) and
replace every `TODO-SDLC` placeholder; journal.md is created by Step 3's
append (committing vs. gitignoring them: STATE-SPEC's rule).

Rewrite state.md completely — it is current truth, not a log. Every section
must be true *right now*:

- **Goal** — update only if the session changed it.
- **Now** — where the active task actually stands after this session.
- **Verification path** — this is standing project knowledge, not a session
  log: keep the commands inherited from the previous state.md. Update the
  status of commands you actually ran this session; for commands you did not
  run, keep them but mark their status as of their last known run (or
  "unverified") — a stale "passing" claim is a trap. Add commands you
  established; delete one only if it no longer exists or no longer proves
  anything.
- **Decisions** — add decisions made this session, with the one-line why.
- **Landmines** — add traps you discovered (flaky tests, deceptive files, env
  quirks) and any mystery diffs from Step 1.
- **Next** — see Step 4; this section carries the whole handoff.

Delete anything no longer true. Stale lines are worse than missing lines —
the next session will act on them.

## Step 3 — Append the journal entry

Append one entry to `.ai-sdlc/journal.md` per STATE-SPEC's journal format.
Handoff-specific additions: "Verified" lists only commands you actually ran
*this session* with the results you observed; if you verified nothing, write
"nothing verified" rather than omitting the line.

Then run the hygiene check:
`bash ~/.agents/skills/sdlc-core/scripts/check-state.sh` (fallback: the
`scripts/` dir in the `sdlc-core/` sibling of this skill's directory). Fix
every FAIL line now. If it warns compaction is due, run
`bash ~/.agents/skills/sdlc-core/scripts/compact-journal.sh` (same fallback) —
it does the mechanical fold per STATE-SPEC and leaves a `TODO-SDLC` digest
line plus a `journal.md.bak`. Replace that line with digest bullets
summarizing the folded entries it printed, delete the `.bak`, then re-run
the check until it prints `check-state: OK`.

## Step 4 — Make Next steps cold-startable

Each item in **Next** must let a fresh model begin without archaeology. That
means each step names:

- the **files** involved (real paths, not "the auth module"),
- the **command(s)** to run or the concrete first action,
- the **acceptance criterion** — how the step knows it is done.

Bad: "finish the retry logic". Good: "Add retry with backoff to
`src/client/fetch.ts:requestWithAuth` (3 attempts, jitter); done when
`bun test src/client/fetch.test.ts` passes including the new
429-retry case (test currently missing — write it first)."

Order steps; put the resumption point of interrupted work first.

## Step 5 — The acid test

Reread state.md as if you were a fresh session that has read *only* it plus
STATE-SPEC — **could it resume from this file alone, without asking the human
anything?** Answer these four in your response, yes or no, no hedging:

```
Acid test
- Now matches reality: yes|no
- Verification path runnable verbatim: yes|no
- Every uncommitted change explained: yes|no
- Next step 1 startable cold: yes|no
- check-state.sh printed "check-state: OK": yes|no
```

Any "no": fix state.md and answer again — only an all-yes acid test ends the
handoff. Then commit the `.ai-sdlc/` changes themselves (unless gitignored per
STATE-SPEC) — an uncommitted handoff can be lost with the worktree.

## Report

End by filling in:

```
Handoff report
- Committed: <hashes, one line each>
- Left uncommitted: <paths + why — or "nothing">
- State files: state.md overwritten, journal.md appended, committed as <hash>
- Top next step: <one line>
```
