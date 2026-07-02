---
name: sdlc-plan
description: Plan a non-trivial code change before touching source — turn the task into observable success criteria, ground the plan in real files, produce ordered steps each with its own verification, and record it in .ai-sdlc/state.md so any future session can execute it. Use whenever a request is multi-step, risky, ambiguous, or spans several files ("migrate Y", "redesign Z", "how should we build/approach X?"), or the user says plan, design, approach, or break this down — even if they never name this skill. Skip it for small, reversible, obvious edits; those go straight to sdlc-extend.
---

# sdlc-plan — plan before code

You are planning, not implementing. The output of this skill is an accepted plan
recorded in `.ai-sdlc/state.md` — zero source files change. Execution belongs to
sdlc-extend (features) or sdlc-debug (wrong behavior), possibly in a different
session, so the plan must stand on its own without your current context.

First, Read `~/.agents/skills/sdlc-core/references/STANDARD.md` (fallback: the `sdlc-core/` sibling of this skill's directory).
The plan you produce is graded against it — especially §1 (verification path)
and §4 (verification ladder).

## Step 0 — Decide whether to plan at all

Skip planning and go straight to sdlc-extend when ALL hold: the change is small
(roughly one file / one sitting), reversible with `git revert`, and you can
already name its verification path. Planning an obvious change wastes the tokens
that should pay for verification. If any of the three fails, plan.

## Step 1 — Restate the task as success criteria

Write 2–5 criteria that are **observable outcomes, not activities**. "Refactor
the auth module" is an activity; "`login` succeeds with a session cookie and the
old `/v1/auth` route returns 410" is an outcome someone could check without
reading your diff. Include what must NOT change (existing behavior to preserve).
If a criterion can't be phrased as something checkable, you don't understand the
task yet — investigate or ask before proceeding (per STANDARD §8).

## Step 2 — Explore just enough code to ground the plan

A plan that names no real files is a guess wearing a suit. Before writing steps:

- If `.ai-sdlc/state.md` exists, Read it FIRST — sdlc-onboard leaves Goal,
  Verification path, Decisions, and Landmines there. Reuse its Verification
  path as your baseline check instead of rediscovering one, and treat its
  Decisions and Landmines as constraints the plan must not violate.
- Locate the files, functions, and tests the change touches (`rg`, `git log`
  on the relevant paths, read the entry points). Name real symbols.
- Find the existing pattern for this kind of change — the codebase almost
  always has one; your plan should extend it, not invent a parallel one.
- Establish the verification baseline: run the project's narrowest relevant
  check NOW and record whether it passes. A plan whose step 1 is "discover the
  tests were already broken" is not a plan. If `.ai-sdlc/state.md` exists and
  its Verification path has drifted from what actually works, update it —
  code wins over the doc (per STATE-SPEC).
- If the project has no tests: identify the manual verification you'll use
  (run the binary, curl the endpoint, render the page) and write it down as a
  concrete command or observation — it becomes each step's verification.

Stop exploring once you can name the files/symbols for every step and have run
the baseline check. If after ~10–15 tool calls you still can't, stop anyway:
record what's unknown as a Step-5 risk with a spike step to resolve it, and
move on — deep exploration is sdlc-onboard's job.

## Step 3 — Options only when genuinely divergent

If there is one reasonable approach, state it and move on — do not manufacture
alternatives. Present options only when approaches genuinely diverge (different
data model, different blast radius, different rollback story), and then:
2–3 options max, one line of tradeoff each, and **always a recommendation with
a reason**. A menu without an opinion pushes the decision back to someone with
less context than you have right now.

## Step 4 — Write the plan

Ordered steps. Each step MUST have:

- **Change** — what is edited/added, naming real files and symbols from Step 2.
- **Verify** — the specific command or observation proving that step works,
  at the narrowest rung of STANDARD §4's ladder that covers it.
- **Stoppable** — sized so that if the session dies right after this step, the
  repo still builds and passes its checks. If a step leaves the repo broken
  until the next step lands, merge them or resequence.

Prefer 3–7 steps. More than ~8 means the task should be split into milestones —
plan the first milestone in full, list the rest as one line each under Next.

## Step 5 — Risks and unknowns, each with a resolution

List anything that could invalidate the plan: unverified assumptions, unclear
requirements, fragile-looking code, migration/rollback concerns. For EACH one,
say how it gets resolved — "spike in step 2", "ask the user before step 4",
"covered by the regression test in step 5". A risk without a resolution is a
surprise scheduled for later. If there are truly none, write "None identified"
so the executor knows you looked.

## Step 6 — Get acceptance, then record into .ai-sdlc/state.md

Present the plan to the user for acceptance FIRST; if executing autonomously,
state your recommendation as the working assumption and proceed. Only the
accepted (or assumed) plan gets recorded — a rejected plan written into the
handoff file becomes the next cold session's marching orders.

Once accepted, Read
`~/.agents/skills/sdlc-core/references/STATE-SPEC.md`, then:

- If `.ai-sdlc/state.md` is missing, create it with the spec's full template
  (fill Goal and Verification path from what you learned in Step 2).
- Put the active task + accepted approach + success criteria under **Now**.
- Put the plan's steps under **Next**, in order, each with its verification —
  each entry must be cold-startable by a session that never saw this one.
- Add any accepted Step-3 decision (with its one-line why) under **Decisions**,
  and Step-5 risks that are traps rather than tasks under **Landmines**.

Then hand off: implementation continues under sdlc-extend (features) or
sdlc-debug (fixing wrong behavior). Do not start editing source files inside
this skill.
