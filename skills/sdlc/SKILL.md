---
name: sdlc
description: Full lifecycle discipline for project repos, in one skill. Use at session start (orientation), before any multi-step or risky change (planning), before declaring a nontrivial change done (validation), and before the session ends with anything changed (handoff). Also holds the engineering standard for execution and the .ai-sdlc/state.md + journal.md file spec — load it when reading or writing either file, or when asked what standard applies to coding work.
---

# sdlc — the whole lifecycle, one skill

Four objectives spanning a session's life: **orient**, **plan**, then after
execution, **validate**, **hand off**. None is a procedure; each defines a
state you must be able to demonstrate. Scale ceremony with blast radius, not
file count — config that propagates to other agents or machines counts as
high blast radius even when the diff is small.

Execution between plan and validation is governed by the engineering
standard (`references/STANDARD.md`): root cause over patch, smallest
coherent change that fully solves the problem, verification ladder (§4).
Read it once per session before substantive work; it is short by design.

## Why this exists

Sessions are amnesiac. The durable artifacts — `.ai-sdlc/state.md` and the
journal (format: `references/STATE-SPEC.md`) — are the project's memory.
Orientation and planning are the read side of that contract; validation and
handoff are the write side.

## Objective 1 — Orient (before the first substantive task)

You are oriented when you can state, without guessing:

- **The goal** — what the user actually wants, not the first plausible
  reading of it.
- **Where the relevant code lives** — from files you have opened this
  session, not from memory of similar projects.
- **How this project verifies changes** — test/build/lint commands you have
  actually run, with their current baseline (what passes today). A stale
  verification command inherited from state.md is worse than none; run it.
- **What the last session left unfinished** — read `.ai-sdlc/state.md` and
  run `bash scripts/check-state.sh` (from this skill's directory). If the
  file is missing, `scripts/scaffold-state.sh` creates it.

Trust nothing that isn't reproduced: claims in state.md were true when
written, which is not the same as true now.

## Objective 2 — Plan, when the work is non-trivial

Small, reversible, obvious edits go straight to the change — planning
ceremony there is pure overhead. Everything else deserves a plan recorded
in `.ai-sdlc/state.md` before source files change. A plan is done when it
records:

- **Success criteria as observable outcomes** — things a skeptic could
  check by running a command, not intentions ("users can X", "command Y
  exits 0"), plus what must NOT change.
- **The genuine forks** — where options really diverge, which one you
  chose, and why. If a fork would materially change the outcome and only
  the user can resolve it, ask (STANDARD §8); otherwise state your working
  assumption and keep moving.
- **A verification path per step** — each step stoppable, each provable,
  so a killed session loses one step, not the plan.

Ground every step in files you have actually opened. A plan built on an
imagined codebase reads fine and fails on contact.

## Objective 3 — Validate before saying "done"

You wrote the change, which makes you its least suspicious reader. Switch
sides: re-read the work as a reviewer who assumes it is broken, and let the
evidence — not the memory of writing it — carry the claim. Validation is
done when:

- **You have re-read the full diff cold** — `git diff` plus untracked
  files, not a paraphrase from memory. Read it looking for the bug, the
  scope creep, the file you forgot you touched.
- **Every success criterion has evidence** — a command you ran *this
  session*, output quoted, not paraphrased. "Tests pass" without the run
  in front of you is a claim, not evidence. Compare against the baseline
  you took at orientation: a suite that was already failing proves
  nothing about your change.
- **The must-NOT-change list is confirmed**, the same way — by running,
  not by inspection.
- **The evidence report** (format: STANDARD §7) states what was verified
  at which rung of the ladder, and — honestly — what was not.

If a criterion can't be checked with what exists, say so explicitly
rather than substituting a weaker check that can.

## Objective 4 — Hand off before stopping

The next session starts with zero memory of this conversation. Handoff is
done when:

- **The tree is settled** — committed, or deliberately left dirty with the
  reason stated in state.md. No silent half-states.
- **`.ai-sdlc/state.md` is the current truth** — goals, decisions, next
  steps, and known landmines as they stand *now*, not as they stood when
  the session started.
- **The journal has an entry** — what changed, why, and what a future
  session should distrust.
- **`bash scripts/check-state.sh` exits 0.**

The acid test: a stranger given only state.md and the repo reaches the
same understanding you have right now. If they'd have to rediscover
something the hard way, it isn't written down yet.

## Precedence and portability

Repo-local instructions (AGENTS.md, CLAUDE.md) and explicit user
instructions override this standard where they conflict. The standard
fills gaps; it does not fight the repo. All paths above are relative to
this skill's own directory, wherever it is installed.

## Pointers

- `references/STANDARD.md` — the engineering bar (root cause, verification
  ladder §4, evidence §7, when to ask §8)
- `references/STATE-SPEC.md` — state.md / journal format
- `scripts/` — `check-state.sh`, `scaffold-state.sh`, `compact-journal.sh`,
  `diff-inventory.sh`
