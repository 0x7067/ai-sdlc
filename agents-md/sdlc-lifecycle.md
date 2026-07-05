# SDLC Lifecycle routing snippet

Paste this section into your global agent instructions file (`~/.agents/AGENTS.md`,
`~/.claude/CLAUDE.md`, or your harness's equivalent). It is the cross-harness
baseline; harnesses that support session-start hooks should ALSO install
`hooks/sdlc-lifecycle-gate` (see the README) — instruction-file placement alone
is not reliably followed by smaller models.

---

## SDLC Lifecycle

- In project repos: `sdlc-start` before the first substantive task of the session, and again to plan any multi-step or risky change; execution itself is governed by the engineering standard in `sdlc-core`; `sdlc-finish` before declaring a change done and before the session ends with anything changed.
- Run start and finish even when the task looks too simple to need them. They exist to make the project resumable by the *next* session, so the current session never feels the gap they close.
