# ai-sdlc

A skill library that lets cheaper models (Sonnet, Haiku, Opus) carry a project's
progress across sessions at a consistent engineering standard. Seven skills cover
the session lifecycle; a shared core holds the standard and the handoff file
format; a session-start hook makes routing deterministic.

Built for Claude Code, portable to any harness that loads `SKILL.md`-style skills.

## The lifecycle

```
session start ──> sdlc-onboard ──> sdlc-plan ────┐
                                   sdlc-extend ──┼──> sdlc-validate ──> sdlc-handoff ──> session end
                                   sdlc-debug ───┘
```

| Skill | When |
|---|---|
| `sdlc-onboard` | Start of any session in a project repo, before touching code. Builds the minimum mental model; reads or creates `.ai-sdlc/state.md`. |
| `sdlc-plan` | Multi-step, risky, or ambiguous changes. Produces ordered steps, each with its own verification, recorded in state. |
| `sdlc-extend` | Adding or modifying functionality. Pre-flight success criteria, mimic the nearest pattern, small edits + narrow verification. |
| `sdlc-debug` | Wrong behavior: reproduce → isolate → root-cause → smallest fix → regression proof. |
| `sdlc-validate` | Pre-ship gate: verification ladder narrowest-first, hostile self-review of the diff, evidence report with ship/fix/escalate. |
| `sdlc-handoff` | End of session: persist state, commit or explain every working-tree change, leave cold-startable next steps. |
| `sdlc-core` | Shared foundation the others reference: `references/STANDARD.md` (the engineering standard) and `references/STATE-SPEC.md` (the `.ai-sdlc/state.md` + `journal.md` handoff format). |

Onboard, validate, and handoff are mandatory gates; plan/extend/debug route by
the shape of the work. The handoff medium is two committed files per project:
`.ai-sdlc/state.md` (current truth, <80 lines) and `.ai-sdlc/journal.md`
(append-only session log), so any future session — any model, any harness —
can cold-start from the repo alone.

## Install

```sh
./install.sh
```

Symlinks the skills into `~/.claude/skills` (override with `SKILLS_DIR=`,
e.g. `SKILLS_DIR=~/.agents/skills` for a shared cross-agent layer) and the
hook into `~/.claude/hooks`, then prints the two manual steps:

1. **Register the hook** in `~/.claude/settings.json` under
   `hooks.SessionStart` (entry printed by the script).
2. **Add the routing snippet** from `agents-md/sdlc-lifecycle.md` to your
   global instructions (`~/.claude/CLAUDE.md` / `~/.agents/AGENTS.md`).

## Why the hook exists

Empirically (headless Sonnet A/B tests against a real codebase):

- Skill **descriptions alone never trigger** process-discipline skills — the
  model feels no capability gap, so it never reaches for them.
- A routing rule in **CLAUDE.md is in context but still ignored** in real
  sessions; system-prompt placement lacks salience.
- The same rule **injected at session start** (hook output lands as a fresh
  contextual message) produces full lifecycle compliance, and the skills then
  chain each other for the rest of the session.

`hooks/sdlc-lifecycle-gate` emits the gate only inside git work trees, so
scratch directories and config sessions stay quiet. The instructions-file
snippet remains as the cross-harness baseline for harnesses without hooks.

## Layout

```
skills/sdlc-*/SKILL.md           the seven skills
skills/sdlc-core/references/     STANDARD.md, STATE-SPEC.md
hooks/sdlc-lifecycle-gate        SessionStart hook (git repos only)
agents-md/sdlc-lifecycle.md      routing snippet for AGENTS.md / CLAUDE.md
install.sh                       symlink installer
```

Skills reference the core as `~/.agents/skills/sdlc-core/...` with an explicit
fallback: `sdlc-core/` is always resolvable as a sibling of the invoking skill's
directory, which the symlink install preserves regardless of where this repo
lives.

## Precedence

Repo-local instructions (`AGENTS.md`, `CLAUDE.md`) and explicit user
instructions override the standard where they conflict. The standard fills
gaps; it does not fight the repo.
