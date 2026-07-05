---
name: sdlc-core
description: >-
  Shared foundation for the sdlc-* skill library: the engineering standard
  every session must meet, and the project-state file spec used for
  cross-session handoff. Load when any sdlc-* skill references it, when asked
  what standard applies to coding work, or when reading/writing a project's
  .ai-sdlc/state.md or .ai-sdlc/journal.md.
---

# sdlc-core

Foundation for the sdlc lifecycle skills (`sdlc-start`, `sdlc-finish`). It
holds the two things they share, so neither skill restates them:

- `references/STANDARD.md` — the engineering standard: what "done well" means
  for any change, regardless of which model executes it. Read it once per
  session before doing substantive work under any sdlc-* skill; it is short
  by design.
- `references/STATE-SPEC.md` — the format of a project's `.ai-sdlc/state.md`
  and `.ai-sdlc/journal.md`, the handoff medium between sessions. Read it
  before reading or writing either file.

Portability: sibling skills reference these files as
`~/.agents/skills/sdlc-core/...`. When the library is installed elsewhere,
resolve them from the skills root instead — `sdlc-core/` is always a sibling
directory of the invoking skill.

Precedence: repo-local instructions (AGENTS.md, CLAUDE.md) and explicit user
instructions override this standard where they conflict. The standard fills
gaps; it does not fight the repo.
