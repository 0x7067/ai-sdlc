# ai-sdlc

A skill library that lets models carry a project's progress across sessions at
a consistent engineering standard. Two skills bracket the session lifecycle —
start (orient + plan) and finish (validate + hand off) — a shared core holds
the standard and the handoff file format, and a session-start hook makes
routing deterministic. Execution between the brackets is governed by the
standard, not scripted by a skill: the library states objectives and durable
contracts and leaves the *how* to the model.

Built for Claude Code, portable to any harness that loads `SKILL.md`-style skills.

## The lifecycle

```
session start ──> sdlc-start ──> execution (STANDARD.md) ──> sdlc-finish ──> session end
                  orient, plan                                validate, hand off
```

| Skill | When |
|---|---|
| `sdlc-start` | Before the first substantive task of a session, and again for any multi-step, risky, or ambiguous change. Two objectives: orient (goal, code, verification baseline, `.ai-sdlc/state.md`) and plan (observable success criteria, genuine forks, per-step verification). |
| `sdlc-finish` | Before declaring a nontrivial change done and before the session ends: hostile self-review of the full diff with quoted evidence, then persist state.md + journal so the next session cold-starts. |
| `sdlc-core` | Shared foundation the others reference: `references/STANDARD.md` (the engineering standard) and `references/STATE-SPEC.md` (the `.ai-sdlc/state.md` + `journal.md` handoff format). |

Start and finish are the gates; the work between them is governed by
`references/STANDARD.md` (root cause over patch, smallest coherent change,
verification ladder) rather than scripted by a skill — the standard states
the bar and the model decides how to clear it.
The handoff medium is two committed files per project:
`.ai-sdlc/state.md` (current truth, <60 lines) and `.ai-sdlc/journal.md`
(append-only session log), so any future session — any model, any harness —
can cold-start from the repo alone.

## Install

**Claude Code — as a plugin (zero manual steps):**

```
/plugin marketplace add 0x7067/ai-sdlc
/plugin install ai-sdlc@ai-sdlc
```

Skills and both hooks register automatically. Plugin installs namespace
the skills (`ai-sdlc:sdlc-start` etc.); the session-start gate teaches
those names, so routing still works. One-off trial without installing:
`claude --plugin-dir /path/to/ai-sdlc`.

**Any other harness — symlink install:**

```sh
./install.sh
```

Symlinks the skills into `~/.claude/skills` (override with `SKILLS_DIR=`,
e.g. `SKILLS_DIR=~/.agents/skills` for a shared cross-agent layer) and the
hooks into `~/.claude/hooks`, then prints the two manual steps:

1. **Register the hooks** in `~/.claude/settings.json` under
   `hooks.SessionStart` and `hooks.Stop` (entries printed by the script).
2. **Add the routing snippet** from `agents-md/sdlc-lifecycle.md` to your
   global instructions (`~/.claude/CLAUDE.md` / `~/.agents/AGENTS.md`).

## The mechanical layer

Judgment the skills can delegate to a script, they do — a weaker model
complies with a command it must run far better than with prose it must
imitate. In `skills/sdlc-core/scripts/`:

| Script | Does |
|---|---|
| `orient.sh` | One-command orientation for `sdlc-start`: git snapshot, state.md, journal tail, drift check, fill-in Orientation block. Scaffolds `.ai-sdlc/` on first use. |
| `check-state.sh [--strict] [repo-dir]` | Validates `.ai-sdlc/` against STATE-SPEC; advisory mode warns when compaction is due, while strict mode makes overdue hygiene fail handoff. |
| `scaffold-state.sh` | Emits the state.md skeleton, judgment slots marked `TODO-SDLC`. |
| `compact-journal.sh` | Journal compaction: byte-for-byte retention, digest carry, folded entries printed for summarizing. |
| `diff-inventory.sh` | One deterministic working-tree inventory (status, stats, untracked, stashes) for validate/handoff. |

`TODO-SDLC` is the contract between scripts and model: scripts mark every
judgment slot with it, and `check-state.sh` FAILs while any remains — so a
half-finished artifact cannot pass the gates.

A second hook, `hooks/sdlc-handoff-gate` (Stop), closes the far end of the
lifecycle the SessionStart gate opens. When the final response contains all
three report fields — `What changed:`, `What was verified:`, and
`Remaining risk:` — it runs `check-state.sh --strict`, blocking the stop with
the FAIL lines when the persisted artifacts do not support the report.
Independently, it nudges at most every ~45 minutes while uncommitted changes
sit.
`stop_hook_active` keeps it from looping; transcript inspection needs `jq`
and degrades to the dirty-tree nudge without it.

## Evals

`evals/OBJECTIVE.md` defines what "better" means for this library —
resumption fidelity, claim integrity, overhead — and maps every proxy this
repo tracks to one of those axes. Two gates keep the proxies honest:

- `bash evals/tier0/run.sh` — deterministic, seconds, no model calls. Run
  after any change to `skills/`, `hooks/`, or `scripts/`. `--self-test`
  seeds 7 mutations and asserts the suite catches them.
- `bash evals/tier1/run.sh` — model-in-the-loop scenarios graded on
  outcomes (resumption Q&A, stale-state trap, false-SHIP honesty,
  overhead), with a control-vs-sdlc A/B mode. `--dry-run` is free;
  real runs cost model calls.

## Why the hook exists

Empirically (headless Sonnet A/B tests against a real codebase; the
original transcripts were not preserved — `evals/tier1` re-runs A/Bs with
persisted artifacts, first real baseline 2026-07-07 in
`evals/tier1/baseline.json`):

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
.claude-plugin/                  plugin + marketplace manifests (Claude Code install)
skills/sdlc-*/SKILL.md           the three skills (start, finish, core)
skills/sdlc-core/references/     STANDARD.md, STATE-SPEC.md
skills/sdlc-core/scripts/        orient, check-state, scaffold-state, compact-journal, diff-inventory
hooks/sdlc-lifecycle-gate        SessionStart hook (git repos only)
hooks/sdlc-handoff-gate          Stop hook: handoff verification + dirty-tree nudge
hooks/hooks.json                 plugin hook registration (${CLAUDE_PLUGIN_ROOT})
agents-md/sdlc-lifecycle.md      routing snippet for AGENTS.md / CLAUDE.md
install.sh                       symlink installer for non-plugin harnesses
evals/                           OBJECTIVE.md (what "better" means) + tier0/tier1 gates
```

Skills reference the core as `~/.agents/skills/sdlc-core/...` with an explicit
fallback: `sdlc-core/` is always resolvable as a sibling of the invoking skill's
directory, which the symlink install preserves regardless of where this repo
lives.

## Precedence

Repo-local instructions (`AGENTS.md`, `CLAUDE.md`) and explicit user
instructions override the standard where they conflict. The standard fills
gaps; it does not fight the repo.
