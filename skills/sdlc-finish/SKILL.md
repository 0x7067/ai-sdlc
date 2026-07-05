---
name: sdlc-finish
description: End-of-work discipline for project repos. Use before declaring any nontrivial change done (validation — hostile review of the diff with quoted evidence) and before the session ends with anything changed (handoff — settle the tree, make state.md the current truth, append the journal). Use even when the change feels too small to need it.
---

# sdlc-finish — validate, then hand off

Two objectives. The first earns the word "done"; the second makes the
project resumable by a session that remembers nothing of this one.

## Objective 1 — Validate before saying "done"

You wrote the change, which makes you its least suspicious reader. The
objective is to switch sides: re-read the work as a reviewer who assumes
it is broken, and let the evidence — not the memory of writing it — carry
the claim. Validation is done when:

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

## Objective 2 — Hand off before stopping

The next session starts with zero memory of this conversation. Handoff is
done when:

- **The tree is settled** — committed, or deliberately left dirty with the
  reason stated in state.md. No silent half-states.
- **`.ai-sdlc/state.md` is the current truth** — goals, decisions, next
  steps, and known landmines as they stand *now*, not as they stood when
  the session started. Format: `../sdlc-core/references/STATE-SPEC.md`.
  Stamp `updated:` with today's date every time, even for a small change —
  a stale date understates how current the file is. When a `Next` step
  depends on something outside this repo (a PR, a deploy, another agent's
  work), name that dependency explicitly so the next session re-verifies
  it instead of trusting a claim that may have moved on.
- **The journal has an entry** — what changed, why, and what a future
  session should distrust.
- **`bash ../sdlc-core/scripts/check-state.sh` exits 0.**

The acid test: a stranger given only state.md and the repo reaches the
same understanding you have right now. If they'd have to rediscover
something the hard way, it isn't written down yet.

## Pointers

- `../sdlc-core/references/STANDARD.md` — verification ladder §4,
  evidence report format §7
- `../sdlc-core/references/STATE-SPEC.md` — state.md / journal format
- `../sdlc-core/scripts/` — `check-state.sh`, `compact-journal.sh`
