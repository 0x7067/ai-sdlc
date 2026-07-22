---
name: sdlc-start
description: "Start-of-work discipline for project repos: orientation before the first substantive task of a session, and planning whenever a task is multi-step, risky, ambiguous, or touches config that propagates beyond this machine. Execution is governed by sdlc-core."
---

# sdlc-start — orient, then plan

Two objectives, not a procedure: show they are met before substantive
edits begin. Scale effort to blast radius, not file count — config that
propagates to other agents or machines is high blast radius even when
the diff is small.

## Objective 1 — Orient

You are oriented when you can state, without guessing:

- **The goal** — what the user actually wants, not the first plausible
  reading of it.
- **Where the relevant code lives** — from files opened this session.
- **How the project verifies changes** — commands you have run this
  session, with their current baseline. A stale verification command
  inherited from state.md is worse than none; run it.
- **What the last session left** — run
  `bash ../sdlc-core/scripts/orient.sh` once: it scaffolds `.ai-sdlc/`
  if missing, prints state.md, the newest journal entries, the drift
  check, and a git snapshot, ending in an Orientation block. Fill every
  slot of that block truthfully in your reply; an unfillable slot is a
  gap to close before editing.

Trust nothing that isn't reproduced: claims in state.md were true when
written, not necessarily now.

## Objective 2 — Plan, when the work is non-trivial

Small, reversible, obvious edits skip planning (never the done-claim —
that goes through `sdlc-finish`). Everything else gets a plan recorded
in `.ai-sdlc/state.md` before source files change:

- **Success criteria as observable outcomes** — checkable by command,
  plus what must NOT change.
- **The genuine forks** — where options diverge, which you chose, why.
  Ask only if the fork materially changes the outcome and only the user
  can resolve it (STANDARD §8); otherwise state the assumption and move.
- **A verification path per step** — each step stoppable, each provable.
  Checkpoint as you execute: flip a step's Xit status and stamp its
  verify in state.md when it completes, not at handoff. That keeps
  state.md never more than one completed step stale, so an interruption
  (compaction, crash, kill) loses one step, not the plan.
- **Tasks in the Xit profile** under state.md `Next` (see
  STATE-SPEC.md): `[@]` only for active work, `[x]` only after its
  `#verify` proof ran.

Ground every step in files you have opened; a plan built on an imagined
codebase fails on contact.

## Execution

The standard governs it (`../sdlc-core/references/STANDARD.md`): root
cause over patch, smallest coherent change, verification ladder (§4).
Before claiming done — at any diff size — or ending a session with
changes, pick up `sdlc-finish`.

## After compaction

The conversation is now a summary — a paraphrase, not evidence.
Re-orient from the files: `.ai-sdlc/state.md` and the in-flight plan win
where the summary disagrees, and the command behind any pre-compaction
claim is re-run before building on it. Kept-current checkpoints make
this cheap — recovery is reading one file.

## Pointers

- `../sdlc-core/references/STANDARD.md` — the bar (root cause, ladder
  §4, evidence §7, when to ask §8)
- `../sdlc-core/references/STATE-SPEC.md` — state.md / journal format
- `../sdlc-core/scripts/` — `orient.sh`, `check-state.sh`,
  `scaffold-state.sh`, `compact-journal.sh`, `diff-inventory.sh`
