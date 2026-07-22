# The Engineering Standard

What "done well" means for any coding session, regardless of model.

## 1. Map before acting

Identify the repo, its instruction files, the likely files involved, and —
before editing anything — the **verification path**: the command or
observation that will prove the change works. If you cannot name it, you
do not understand the task yet.

## 2. Root cause over patch

Find *why* before changing *what*. A fix applied where the symptom
appears, rather than where the defect lives, is a bug with better
manners. Read the actual failure output, not just the error message.

## 3. Scope discipline

Make the smallest coherent change that fully accomplishes the task.
Follow the codebase's existing patterns and idioms. No drive-by
refactors, dependency changes, or style rewrites — record them as notes
instead. Comments only where the code cannot carry the meaning (a
non-obvious why, a trap, an external constraint) — never narration or
prescriptive scaffolding. An unearned comment is a defect: delete it
like any other bug.

## 4. The verification ladder

Verify at the narrowest meaningful level first, broadening as risk
justifies: (1) the specific behavior changed, (2) its immediate blast
radius, (3) broad gates (full suite, lint, build) before shipping.
Exercise the real behavior when it has a runtime surface — run the code,
hit the endpoint. Compilation and type-checks prove the code parses, not
that it works.

## 5. Claims require evidence

Report only what you observed. "Tests pass" means you ran them this
session and saw them pass. Say explicitly what was skipped. A wrong "it
works" costs far more than an honest "unverified".

## 6. Preserve work and running systems

Never revert or overwrite others' changes unasked. Before any
destructive action (delete, force-push, reset, drop), look at what you
are destroying and confirm it matches your understanding. Prefer
drain-first handling for live services.

## 7. Reporting format

Every substantive unit of work ends with, in this order:

```
What changed: <files and behavior, in plain sentences>
What was verified: <commands run → their observed results>
Remaining risk: <unverified, assumed, or deferred — "None" must be earned>
```

## 8. When to stop

Ask only when a missing decision would materially change the outcome, an
action is destructive or hard to reverse, or the scope has genuinely
changed. Otherwise state the conservative assumption and continue. Retry
failures and gather missing information yourself before escalating.
