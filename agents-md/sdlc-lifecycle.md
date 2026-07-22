# SDLC Lifecycle routing snippet

Paste the section below into your global agent instructions file
(`~/.agents/AGENTS.md`, `~/.claude/CLAUDE.md`, or equivalent). It is the
cross-harness baseline; harnesses with session-start hooks should ALSO
install `hooks/sdlc-lifecycle-gate` (see the README) — instruction-file
placement alone is not reliably followed by smaller models.

---

## SDLC Lifecycle

- In project repos: `sdlc-start` before the first substantive task and to plan any multi-step or risky change; execute to the `sdlc-core` engineering standard; `sdlc-finish` before claiming anything done and before ending a session that changed anything.
- The claim, not the diff, triggers `sdlc-finish`: any done/verified/ship verdict — however small the edit — goes through validation first.
- After any context compaction, re-orient from `.ai-sdlc/state.md`: the summary is a paraphrase, not evidence — re-run a command before building on any pre-compaction claim.
