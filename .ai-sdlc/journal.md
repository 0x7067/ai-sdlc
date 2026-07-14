# Journal

## 2026-07-10 — merge harness hardening into main
- Did: merged `codex/harness-hardening` after 14 main-side commits; kept
  plugin/orient/leanness behavior and migrated hook, docs, and evals together.
- Verified: tier0 193/193; self-test caught 7/7; tier1 dry-run completed 8/8;
  shell syntax, strict state, and staged-diff checks passed.
- Learned: the retired Handoff/VERDICT tokens were embedded in tier0 and the
  objective, so hook-contract migration had to update executable proxies too.
- Left: parent remains pinned to `c7f89af`; it is now reachable from main.

## 2026-07-13 — validate Codex handoff transcripts
- Did: taught the canonical Stop gate to read Codex response-item assistant text.
- Verified: tier0 exits 0 with 195 assertions, including the Codex report branch.
- Learned: Claude and Codex store assistant text under different JSONL shapes.
- Left: scenario hardening and Sonnet-tier A/B remain unchanged.

## 2026-07-13 — harden current Stop event handling
- Did: preferred current assistant text, retained legacy transcript fallback, and timed only observed dirty periods.
- Did: made Claude plugin/direct Stop commands identical and taught the manifest check their fallback form.
- Verified: tier0 exits 0 with 203 assertions; both installed hook paths match this source and execute.
- Learned: transcript writes may lag Stop events; session-age markers falsely age later dirty work.
- Left: scenario hardening and Sonnet-tier A/B remain unchanged.

## 2026-07-14 — install globally for Claude Code and Codex
- Did: repointed both global skill directories and Claude hook symlinks to this checkout; merged the missing SessionStart registration.
- Verified: all eight symlinks resolve; hook emits only in git repos; tier0 exits 0 with 203 assertions and no deployment warnings.
- Learned: global routing and the Stop registration already existed, so both were preserved.
- Left: restart Claude Code and Codex sessions to load the new global skill targets.

## 2026-07-14 — extend global install to Pi and oh-my-pi
- Did: linked all three skills into Pi and oh-my-pi's native user skill directories.
- Verified: all six links resolve to this checkout; both harness instruction files contain SDLC routing; client versions execute.
- Learned: Pi uses ~/.pi/agent/skills; oh-my-pi uses ~/.omp/agent/skills.
- Left: restart Pi and oh-my-pi sessions to load the new skills.
