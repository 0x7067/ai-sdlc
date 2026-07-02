# SDLC Lifecycle routing snippet

Paste this section into your global agent instructions file (`~/.agents/AGENTS.md`,
`~/.claude/CLAUDE.md`, or your harness's equivalent). It is the cross-harness
baseline; harnesses that support session-start hooks should ALSO install
`hooks/sdlc-lifecycle-gate` (see the README) — instruction-file placement alone
is not reliably followed by smaller models.

---

## SDLC Lifecycle

- In project repos, route coding work through the `sdlc-*` skills: `sdlc-onboard` before the first substantive task of the session, then `sdlc-plan` / `sdlc-extend` / `sdlc-debug` as the work dictates, `sdlc-validate` before declaring a change done, and `sdlc-handoff` before the session ends.
- Treat onboard, validate, and handoff as mandatory gates, not suggestions — run them even when the task looks too simple to need them. They exist to make the project resumable by the *next* session, so the current session never feels the gap they close.
