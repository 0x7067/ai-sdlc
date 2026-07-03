---
name: sdlc-onboard
description: Build the minimum mental model of a project in the first minutes of a session — read order, a verified verification path, and .ai-sdlc/state.md read or created. Use at the start of ANY session in a project repo, whether new or returning, before planning or touching code. Trigger on "get familiar with this repo", "pick up where we left off", "what's the state of this project", a cold start in an unfamiliar codebase, or any substantive task request when you have not yet oriented this session. If work is about to begin and you cannot name the goal, the verification path, and where the code lives — run this first.
---

# sdlc-onboard — orient before you work

Goal: in a few minutes and few tokens, know (1) what this project is and what's
active, (2) how to prove it works, (3) where this task's code lives. Nothing more.
This skill ends at orientation — planning belongs to sdlc-plan, changes to
sdlc-extend/sdlc-debug. Do not fix anything you find here; note it.

Read `~/.agents/skills/sdlc-core/references/STANDARD.md` (fallback: the `sdlc-core/` sibling of this skill's directory) now if you
have not this session — it defines the bar everything below serves.

## Step 1 — Read in this order; stop as soon as you're oriented

Each layer may make the next unnecessary. Never read the whole repo.

1. **`.ai-sdlc/state.md`** (and skim the last 1-2 entries of `.ai-sdlc/journal.md`).
   A healthy state.md is self-explanatory prose — read it directly; it should give
   you goal, verification path, decisions, landmines, and next steps in one read.
   Read `~/.agents/skills/sdlc-core/references/STATE-SPEC.md` only
   when you must create or repair state.md (Step 3).
2. **Repo instruction files**: `AGENTS.md`, `CLAUDE.md`, `README` (root, then the
   subdirectory you'll work in). These carry binding conventions — skipping them is
   how sessions violate house rules in the first edit.
3. **Targeted structure scan** — only to fill remaining gaps:
   - `git log --oneline -10` and `git status` (recent direction; uncommitted work
     you must not clobber).
   - A shallow file listing (`ls`, `rg --files | head -50`, or equivalent) to spot
     layout, manifests (`package.json`, `pyproject.toml`, `Makefile`, `go.mod`, …),
     and entry points.
   - Open only files the task points at, and read excerpts, not whole files.

## Step 2 — Establish the verification path by running it

The verification path is the command(s) that prove the project works. It must be
**observed, not assumed**: a stale "tests pass" in state.md or a plausible-looking
`Makefile` target is a claim, not evidence, and you will build on it all session.

- Find candidate commands from state.md, instruction files, manifests
  (scripts/targets), or CI config — in that order.
- Prefer one fast test (or actually running the app) as the recorded verification
  path. Lint/typecheck alone prove the code parses, not that it works (STANDARD
  §4) — record them only as a partial baseline when no test/run command exists.
  Run the fuller suite only if it's cheap or the task is risky.
- Record the exact command and its observed result (pass/fail). A pre-existing
  failure is fine — note it as the known baseline so you don't later mistake it
  for your breakage, or it for a reason to "fix" out of scope.
- If no check commands exist at all, the verification path is manual: how to run
  the project and what correct output looks like. State that explicitly.

## Step 3 — Reconcile state.md with reality

- **Missing**: create `.ai-sdlc/state.md` per STATE-SPEC from what you just learned.
  Sparse-but-true beats complete-but-guessed; leave sections thin rather than
  invent. Do not create `.ai-sdlc/journal.md` — sdlc-handoff creates it on first
  append. Do not commit the new file now: STATE-SPEC requires it committed, but
  committing belongs to sdlc-handoff, so you never entangle it with pre-existing
  uncommitted work (spotted in Step 1's structure scan).
- **Present but contradicting the repo** (commands that fail, files that don't
  exist, finished work listed as "Now"): the repo is right. Fix state.md now and
  remember the drift for the handoff journal entry (rule and rationale:
  STATE-SPEC Rules).
- **Present and accurate**: touch nothing.

When state.md is present, also run
`bash ~/.agents/skills/sdlc-core/scripts/check-state.sh` (fallback: the
`scripts/` dir in the `sdlc-core/` sibling of this skill's directory) —
each FAIL line is format drift against STATE-SPEC; fix it now like any
other drift.

## Step 4 — Cost discipline

- Time-box exploration: roughly 10-15 tool calls or ~5 minutes. If you're not
  oriented by then, you're reading too deep — narrow to the task's own files.
- Prefer listings, greps, and excerpts over full-file reads; prefer state.md and
  instruction files over re-deriving facts from source.
- **Stop condition** — stop exploring the moment you can answer all three:
  1. What is the goal / active work?
  2. What command proves things work, and did you see it run?
  3. Which files does the current task live in?

## Step 5 — Output the orientation summary

Before any substantive work, output this block, filled in:

```
Orientation
- Project + goal: <one line>
- Active work: <where things stand>
- Verification path: <exact command(s)> → <result observed THIS session>
- Task code lives in: <real paths>
- Landmines / drift: <what was found and what was fixed, or "none">
- Next: Skill(sdlc-plan) | Skill(sdlc-extend) | Skill(sdlc-debug) — <why, one line>
```

This summary is the contract for the rest of the session — no filled-in block,
no onboarding. If you cannot fill a line honestly, you are not done orienting.

**Exit → invoke the skill named on your Next line.** Substantive work outside
one of the sdlc-* skills is a routing violation, not a shortcut.
