# SDLC Lifecycle routing snippet

Paste this section into your global agent instructions file (`~/.agents/AGENTS.md`,
`~/.claude/CLAUDE.md`, or your harness's equivalent). It is the cross-harness
baseline; harnesses that support session-start hooks should ALSO install
`hooks/sdlc-lifecycle-gate` (see the README) — instruction-file placement alone
is not reliably followed by smaller models.

---

## SDLC Lifecycle

- In project repos: `sdlc-start` before the first substantive task of the session, and again to plan any multi-step or risky change; execution itself is governed by the engineering standard in `sdlc-core`; `sdlc-finish` before declaring a change done and before the session ends with anything changed.
- `sdlc-finish` is keyed to the claim, not the diff: any done/verified/ship verdict — however small the edit — goes through validation first, because the next session builds on that claim unchecked.
- Run start and finish even when the task looks too simple to need them. They exist to make the project resumable by the *next* session, so the current session never feels the gap they close.
- After any context compaction, re-orient from `.ai-sdlc/state.md` before continuing: the summary is a paraphrase, not evidence — re-run a command before building on any pre-compaction claim.
