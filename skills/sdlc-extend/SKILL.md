---
name: sdlc-extend
description: >-
  Disciplined implementation loop for adding or modifying functionality —
  pre-flight the success criteria, mimic the nearest existing pattern, and
  alternate small edits with narrow verification. Use whenever you are about
  to write or change product code — "add a feature", "implement X", "support
  Y", "change the behavior of Z", "wire up", "extend", or executing a step
  from an sdlc-plan — even if the user never says "extend". Not for
  diagnosing wrong behavior (sdlc-debug) or for the pre-ship gate
  (sdlc-validate).
---

# sdlc-extend — implement a change

Read `~/.agents/skills/sdlc-core/references/STANDARD.md` (fallback: the `sdlc-core/` sibling of this skill's directory) now if you
have not this session. This skill is the implementation phase only: it starts
when you know roughly what to build and ends by handing to sdlc-validate. It
does not plan (sdlc-plan), diagnose bugs (sdlc-debug), or ship (sdlc-validate).

## Step 1 — Pre-flight: earn the right to edit

Before the first edit, state both of these explicitly in your visible response
or todo list (not in a project file) — one line each, so the gate leaves a
checkable trace instead of a claim:

- **Success criteria**: the observable behavior that means "done".
- **Verification path**: the exact command or observation that will prove it —
  a test invocation, a request to hit, a page to render.

Sources, in order: a plan from sdlc-plan if one exists; `.ai-sdlc/state.md`
(Verification path section) if present; otherwise establish both inline from the
task and the repo (find how this project runs its tests/build — README, CI config,
package manifest scripts). If you cannot write both lines after that, **stop —
you do not understand the task yet**; go back to the request or invoke sdlc-plan. Editing
without a verification path is how sessions produce work that looks finished
but isn't.

## Step 2 — Find the pattern: consistency beats preference

Locate the nearest existing code that does something similar to what you're adding
(a sibling endpoint, an adjacent command, a comparable component). Read it and its
tests before writing anything. Mimic it in:

- structure and file placement
- naming conventions
- error handling and logging style
- test style and location

WHY: the maintainer reads your code against the codebase, not against your taste.
A "better" idiom that matches nothing around it is a defect. If no similar code
exists anywhere, follow the language's plainest conventions and note the novelty
for your final report.

## Step 3 — The loop: small change, narrow check, repeat

Work in increments:

1. Make one small, coherent change (one function, one route, one case).
2. Run the **narrowest** verification that exercises it — one test, one command,
   one request. Not the full suite; that comes at validate time.
3. Green: the increment is done — commit it if this session's workflow uses
   incremental commits, otherwise just move on; either way take the next
   increment. Red: fix now, before adding anything on top.

Never accumulate ten edits before the first check. WHY: with one unverified change
a failure has one suspect; with ten it has ten, and you will spend longer bisecting
your own work than the edits took. If the project has no fast check at all (no
tests, slow build), create the narrowest possible probe — a scratch script in the
scratchpad, a REPL call, a curl — and use it each iteration.

## Step 4 — Scope guardrails

Smallest coherent change that fully accomplishes the task, per STANDARD §3 — no
drive-by refactors or style sweeps in code you touch incidentally. Additionally:

- No new dependencies unless the task requires one and nothing in-repo serves;
  say so explicitly when you add it.
- Improvements you notice but weren't asked for: record them as notes for the
  final report (or `.ai-sdlc/state.md` Next section at handoff) — do not do them.

WHY: every out-of-scope line enlarges the review surface and the blast radius of
your own diff.

## Step 5 — Tests for the behavior added

Write tests in the codebase's existing test idiom — same framework, same file
layout, same assertion style as the tests you found in Step 2. Cover the new
behavior and its most likely failure mode; don't gold-plate edge cases the task
doesn't imply. If the project has no tests at all, do not bolt on a framework
uninvited — verify via the runtime surface (run it, hit it, render it), state
that tests were skipped and why, and suggest testing as a follow-up note.

## Step 6 — Comments

Add a comment only for a constraint the code cannot express: a non-obvious
ordering requirement, a workaround with its upstream cause, a deliberate
deviation from the surrounding pattern. Never narrate what the code plainly does.

## Step 7 — Finish: implementation is not "it compiles"

Done here means: increments complete, each one verified narrowly, tests written,
scope notes collected. Then hand to **sdlc-validate** for the full verification
ladder, diff self-review, and evidence report — do not declare the task done
yourself, and do not skip validate because "everything already passed"; narrow
checks per increment are not the broad gates.

If the session ends before validate can run, invoke **sdlc-handoff** and record
exactly which increments are verified and which are not (STANDARD §5: claims
require evidence).
