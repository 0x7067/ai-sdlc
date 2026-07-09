# Project State Spec

The handoff medium between sessions. Lives inside each project repo:

```
.ai-sdlc/
├── state.md     # current truth — overwritten to stay accurate
└── journal.md   # append-only session log — entries never edited
```

Both are committed to the repo (they are project knowledge, not scratch).
If the repo's conventions forbid committing them, gitignore them and note
that in state.md itself.

## state.md — current truth

Keep it under 80 lines (hard cap 120 — the hygiene check below fails past
it). It is read at the start of every session, so every
stale line costs trust and every extra line costs tokens. Overwrite freely;
history lives in the journal.

```markdown
# Project State
updated: YYYY-MM-DD

## Goal
What this project is trying to become, in 2-4 sentences.

## Now
The active milestone or task, and where it stands.

## Verification path
How to prove the project works: build/test/run commands that are known
to pass (or known to fail, marked as such).

## Decisions
Standing decisions with a one-line why each. Only decisions a future
session could plausibly re-litigate.

## Landmines
Non-obvious traps: flaky tests, files that look dead but aren't,
env quirks, ordering constraints.

## Next
Ordered, concrete next steps. Each one small enough to start cold.
```

### History — compaction target (tool-managed)

`compact-journal.sh` appends or updates a `## History (digest through
YYYY-MM-DD)` section here when it folds old journal entries. It is the one
section a session doesn't hand-author: the script writes the header,
carries the previous digest's bullets forward verbatim, and adds one
`TODO-SDLC` placeholder for the newly folded entries, which the model then
fills in. `sdlc-start` reads this section at orientation time — a digest
belongs wherever state.md lives, since that's the file every session
actually reads back.

## journal.md — append-only log

One entry per working session, appended at the end. Never edit old entries.

```markdown
## YYYY-MM-DD — <one-line summary>
- Did: what actually happened, with outcomes
- Verified: commands run and results observed
- Learned: anything that changed understanding (or "nothing new")
- Left: loose ends handed to the next session
```

### Compaction — the only sanctioned journal rewrite

Entries are never edited, but the journal must not grow without bound. At
handoff, when journal.md exceeds ~200 lines, fold every entry except the
newest 5 into a digest — merging any previous digest's bullets in — and
write it to state.md's `## History (digest through YYYY-MM-DD)` section
(replacing any prior one there), not into journal.md itself: a digest left
in the journal is never read back. journal.md keeps only the newest 5
entries, byte-for-byte untouched:

```markdown
## History (digest through YYYY-MM-DD)
- <one line per durable learning or outcome from the folded entries;
  drop anything already captured in state.md or the repo>
```

## Scripts and hygiene checks

`check-state.sh` validates this spec mechanically — required sections, the
`updated:` date, size caps, journal entry headers — and reports when
compaction is due. Run advisory checks while working, then strict checks at
handoff:

```
bash ~/.agents/skills/sdlc-core/scripts/check-state.sh
bash ~/.agents/skills/sdlc-core/scripts/check-state.sh --strict
```

(fallback: the `scripts/` directory inside the `sdlc-core/` sibling of the
calling skill's directory). Both forms accept an optional repo directory;
`--strict` must precede it. In advisory mode, state.md over 80 lines and
journal.md over 200 lines WARN and exit 0; in strict mode those
overdue-compaction conditions FAIL and exit 1. State.md over the 120-line hard
cap always FAILs. Each FAIL line names a violation to fix before handoff
completes.

Sibling scripts in the same directory do the other mechanical work, so no
session hand-builds these formats:

- `scaffold-state.sh [repo-dir]` — creates the state.md skeleton with
  today's `updated:` line; refuses to overwrite an existing file.
- `compact-journal.sh [repo-dir]` — performs the Compaction fold above:
  trims journal.md to the newest 5 entries byte-for-byte, writes the
  digest (carrying the previous one's bullets forward) into state.md's
  `## History` section, and prints the folded entries as the source to
  summarize.
- `diff-inventory.sh [base-ref]` — read-only working-tree inventory
  (branch, status, diff stats, untracked files, stashes) for
  sdlc-finish (validation and handoff).

`TODO-SDLC` is the contract between scripts and model: every judgment slot
a script cannot fill is marked with it, and check-state.sh FAILs while any
remains — likewise while a `journal.md.bak` left by compact-journal.sh
exists — so a half-finished artifact cannot pass handoff.

## Rules

- **state.md must never contradict the repo.** When code and state.md
  disagree, the code is right — fix state.md and note the drift in the
  journal.
- Convert every relative date ("yesterday", "last week") to an absolute
  date before writing.
- Do not duplicate what the repo already records (README, AGENTS.md, git
  history). State files hold what is *not* derivable from the code.
- No secrets, tokens, or credentials — these files are committed.
