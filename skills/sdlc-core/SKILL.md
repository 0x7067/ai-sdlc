---
name: sdlc-core
description: "Shared foundation for the sdlc-* skill library: the engineering standard every session must meet, and the .ai-sdlc/state.md / journal.md file spec for cross-session handoff. Load when any sdlc-* skill references it or when reading/writing those files."
---

# sdlc-core

Foundation shared by `sdlc-start` and `sdlc-finish`:

- `references/STANDARD.md` — the engineering standard: what "done well"
  means for any change. Read it once per session before substantive work
  under any sdlc-* skill.
- `references/STATE-SPEC.md` — the format of `.ai-sdlc/state.md` and
  `.ai-sdlc/journal.md`, the handoff medium between sessions. Read it
  before reading or writing either file.

Portability: sibling skills reference these files as
`~/.agents/skills/sdlc-core/...`; when the library is installed elsewhere,
`sdlc-core/` is always a sibling of the invoking skill's directory.

Precedence: repo-local instructions (AGENTS.md, CLAUDE.md) and explicit
user instructions override the standard. It fills gaps; it does not fight
the repo.
