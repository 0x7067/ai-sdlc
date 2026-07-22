---
name: sdlc-start
description: "Start-of-work discipline for project repos: orientation before the first substantive task of a session, and planning whenever a task is multi-step, risky, ambiguous, or touches config that propagates beyond this machine. Execution is governed by sdlc-core."
---

# sdlc-start — orient, then plan

Two objectives, not a procedure. You decide how to reach them; what matters
is being able to show they're met before substantive edits begin.

## Why this exists

Sessions are amnesiac. The durable artifacts — `.ai-sdlc/state.md` and the
journal — are the project's memory, and this skill is the read side of that
contract. Orientation stops you from re-deriving context the last session
already paid for; planning stops you from discovering the real goal halfway
through a diff. Scale the effort to blast radius, not file count: config
that propagates to other agents or machines counts as high blast radius
even when the diff is small.

## Objective 1 — Orient

You are oriented when you can state, without guessing:

- **The goal** — what the user actually wants, not the first plausible
  reading of it.
- **Where the relevant code lives** — from files you have opened this
  session, not from memory of similar projects.
- **How this project verifies changes** — test/build/lint commands you have
  actually run, with their current baseline (what passes today). A stale
  verification command inherited from state.md is worse than none; run it.
- **What the last session left unfinished** — run
  `bash ../sdlc-core/scripts/orient.sh` once. It scaffolds `.ai-sdlc/` if
  missing, then prints state.md (format:
  `../sdlc-core/references/STATE-SPEC.md`), the newest journal entries,
  the drift check, and a git snapshot, ending in an Orientation block.
  Fill every slot of that block in your reply — a slot you cannot fill
  truthfully is a gap to close before editing.

Trust nothing that isn't reproduced: claims in state.md were true when
written, which is not the same as true now.

## Objective 2 — Plan, when the work is non-trivial

Small, reversible, obvious edits go straight to the change — planning
ceremony there is pure overhead. (That exemption covers the planning,
never the claim: declaring the result done, at any diff size, goes
through `sdlc-finish`.) Everything else deserves a plan recorded
in `.ai-sdlc/state.md` before source files change. A plan is done when it
records:

- **Success criteria as observable outcomes** — things a skeptic could
  check by running a command, not intentions ("users can X", "command Y
  exits 0"), plus what must NOT change.
- **The genuine forks** — where options really diverge, which one you
  chose, and why. If a fork would materially change the outcome and only
  the user can resolve it, ask (STANDARD §8); otherwise state your working
  assumption and keep moving.
- **A verification path per step** — each step stoppable, each provable.
  Checkpoint as you execute: when a step completes, flip its Xit status
  and stamp its verify in state.md *then*, not at handoff — state.md is
  never more than one completed step stale, so whatever interrupts the
  session (compaction, crash, kill) loses one step, not the plan.
- **The Xit task profile** — record plan items under `state.md` `Next` using
  `STATE-SPEC.md`; use `[@]` only for active work and `[x]` only after its
  `#verify` proof has run.

Ground every step in files you have actually opened. A plan built on an
imagined codebase reads fine and fails on contact.

## Execution

No skill scripts execution — the standard governs it: root cause over
patch, smallest coherent change that fully solves the problem, and the
verification ladder (`../sdlc-core/references/STANDARD.md`, §4). Before
claiming the change is done — at any diff size — or when the session is
ending with anything nontrivial changed, pick up `sdlc-finish`.

## After compaction

Context compaction is a session boundary that arrives mid-task: the
conversation is replaced by a summary — a paraphrase, not evidence, and
never a substitute for the artifacts. Re-orient from the files, where
`.ai-sdlc/state.md` and the in-flight plan win wherever the summary
disagrees, and re-establish any pre-compaction claim (a passing test, a
completed step) by re-running its command before building on it. The
checkpoint discipline above is what makes this cheap: if statuses and run
stamps were kept current at step boundaries, recovery is reading one
file, not re-deriving the session.

## Pointers

- `../sdlc-core/references/STANDARD.md` — the engineering bar (root cause,
  verification ladder §4, evidence §7, when to ask §8)
- `../sdlc-core/references/STATE-SPEC.md` — state.md / journal format
- `../sdlc-core/scripts/` — `orient.sh`, `check-state.sh`,
  `scaffold-state.sh`, `compact-journal.sh`, `diff-inventory.sh`
