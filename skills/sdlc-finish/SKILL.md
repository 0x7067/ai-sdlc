---
name: sdlc-finish
description: "End-of-work discipline for project repos: hostile validation of the diff before declaring work done, and handoff (settle the tree, update state.md, append the journal) before ending a session with changes. Triggered by the claim, not the diff — use before any done/ship verdict, even for small edits."
---

# sdlc-finish — validate, then hand off

Two objectives: the first earns the word "done"; the second makes the
project resumable by a session that remembers nothing of this one.

## Objective 1 — Validate before saying "done"

You wrote the change, so you are its least suspicious reader. Re-read it
as a reviewer who assumes it is broken; let evidence, not memory, carry
the claim. Depth scales with the blast radius of the claim, not the diff
size — a done/ship verdict is inherited unchecked downstream, so a
one-line edit under that verdict still earns the full hostile read.
Validation is done when:

- **The full diff was re-read cold** — run
  `bash ../sdlc-core/scripts/diff-inventory.sh`, then read the actual
  changes: look for the bug, the scope creep, the forgotten file, and
  comments the code didn't earn (STANDARD §3) — every added comment line
  the inventory lists must state a why the code can't.
- **Every success criterion has evidence** — a command run *this
  session*, output quoted. Compare against the orientation baseline: a
  suite that was already failing proves nothing about your change.
- **The must-NOT-change list is confirmed** — by running, not inspection.
- **The verification baseline ran this session** — re-run state.md's
  `Verification path` commands now and re-stamp them with today's date;
  the strict check refuses a stale stamp. Mark a command that cannot run
  here `not re-run (today's date)` and say so in the report — a
  disclosed gap is honest; an implied pass on an unrun suite is the
  false-SHIP failure this library exists to stop.
- **The evidence report** (STANDARD §7) states what was verified at
  which rung of the ladder, and what was not.

If a criterion can't be checked with what exists, say so rather than
substituting a weaker check that can.

## Objective 2 — Hand off before stopping

Handoff is done when:

- **The tree is settled** — committed, or deliberately dirty with the
  reason stated in state.md.
- **A pull request is self-contained** — implementation, verification
  evidence, state.md, and journal.md settle on the same pull request
  before final CI and merge; if the handoff changes while the PR is
  open, update that branch and rerun its checks. Never open a
  follow-up AI-SDLC-only pull request to close or repair a handoff.
  Post-merge readback goes in the final report; only a substantive new
  defect starts new work.
- **state.md is the current truth** (format: STATE-SPEC.md) — stamp
  `updated:` with today's date; name any external dependency (a PR, a
  deploy, another agent) a `Next` step relies on, so the next session
  re-verifies it.
- **`Next` is settled** — journal and remove terminal `[x]`/`[~]` items;
  `[x]` only after its `#verify` proof ran.
- **The journal has an entry** — what changed, what was verified, what a
  future session should distrust; terse bullets, not narrative.
- **`bash ../sdlc-core/scripts/check-state.sh --strict` exits 0.**

End the final response with the STANDARD §7 evidence report, each field
at the start of its line: `What changed:`, `What was verified:`, and
`Remaining risk:`. The Stop hook recognizes exactly that three-field
contract and runs the strict state check before the session may end.

Acid test: a stranger given only state.md and the repo reaches your
current understanding. Anything they would rediscover the hard way is
not written down yet.

## Pointers

- `../sdlc-core/references/STANDARD.md` — ladder §4, report format §7
- `../sdlc-core/references/STATE-SPEC.md` — state.md / journal format
- `../sdlc-core/scripts/` — `diff-inventory.sh`, `check-state.sh`,
  `compact-journal.sh`
