# The Engineering Standard

What "done well" means for any coding session, regardless of model. Each rule
exists because skipping it is the main way sessions produce work that looks
finished but isn't.

## 1. Map before acting

Identify the repo, its instruction files, the likely files involved, and —
before editing anything — the **verification path**: the concrete command or
observation that will prove the change works. If you cannot name the
verification path, you do not understand the task yet.

## 2. Root cause over patch

When behavior is wrong, find *why* before changing *what*. A fix applied
where the symptom appears, rather than where the defect lives, is a bug with
better manners. Read the actual failure output; never fix from the error
message alone when the source is available.

## 3. Scope discipline

Make the smallest coherent change that fully accomplishes the task. Follow
the codebase's existing patterns, naming, and idioms — consistency beats
personal preference. No drive-by refactors, dependency changes, or style
rewrites; if you notice one worth doing, record it as a note, don't do it.

Comments follow the same discipline: add one only when the code cannot
carry the meaning — a non-obvious *why*, a trap, an external constraint.
Never narrate what the code already says, and never leave prescriptive
scaffolding ("do X here", section banners, change markers).

## 4. The verification ladder

Verify at the narrowest meaningful level first, then broaden only as risk
justifies:

1. The specific behavior you changed (one test, one command, one request).
2. The immediate blast radius (the module's test file, the affected flow).
3. Broad gates (full test suite, lint, build) before shipping.

Exercise the real behavior when it has a runtime surface — run the code,
hit the endpoint, render the page. Type-checking and compilation are not
verification; they prove the code parses, not that it works.

## 5. Claims require evidence

Report only what you observed. "Tests pass" means you ran them this session
and saw them pass. If a step was skipped, say so explicitly. A wrong "it
works" costs far more than an honest "unverified" — the reader will act on
your claim without re-checking it.

## 6. Preserve work and running systems

Never revert or overwrite changes you didn't make without being asked.
Before any destructive action (delete, force-push, reset, drop), look at
what you're destroying and confirm it matches your understanding. For live
services and workers, prefer drain-first handling.

## 7. Reporting format

Every substantive unit of work ends by filling in, in this order:

```
What changed: <files and behavior, in plain sentences>
What was verified: <commands run → their observed results>
Remaining risk: <unverified, assumed, or deferred — "None" must be earned, not defaulted>
```

## 8. When to stop

Stop and ask only when a missing decision would materially change the
outcome, an action is destructive or hard to reverse, or the task's scope
has genuinely changed. Otherwise make the conservative assumption, state
it, and continue. Retry failures and gather missing information yourself
before escalating.
