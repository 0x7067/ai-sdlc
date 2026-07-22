# Project State Spec

The handoff medium between sessions, inside each project repo:

```
.ai-sdlc/
├── state.md     # current truth — overwritten to stay accurate
└── journal.md   # append-only session log — entries never edited
```

Both are committed (project knowledge, not scratch). If the repo's
conventions forbid committing them, gitignore them and note that in
state.md itself.

When work ships through a pull request, these artifacts travel with the
implementation on the same pull request and describe its settled state
before final CI and merge; amend the original branch when they go stale.
Never create a follow-up AI-SDLC-only pull request just to repair a
handoff. Post-merge readback belongs in the final report unless it
uncovers a substantive new defect.

## state.md — current truth

Keep it under 60 lines (hard cap 120 — the hygiene check fails past it).
Every session reads it at start: stale lines cost trust, extra lines cost
tokens. Overwrite freely; history lives in the journal. Clipped bullets
only — a line that isn't a decision, a trap, a command, or a next step
gets cut.

```markdown
# Project State
updated: YYYY-MM-DD

## Goal
What this project is trying to become, in 2-4 sentences.

## Now
The active milestone or task, and where it stands.

## Verification path
Build/test/run commands that prove the project works (or are known to
fail, marked as such), each stamped with the date it last actually ran.

## Decisions
Standing decisions a future session could re-litigate, one-line why each.

## Landmines
Non-obvious traps: flaky tests, files that look dead but aren't, env
quirks, ordering constraints.

## Next
[ ] One concrete, cold-startable outcome. #id=task-1 #verify="command proving completion"
```

### Xit task-item profile

`Next` is empty or one [Xit 1.1](https://github.com/jotaen/xit/blob/main/Specification.md) item per line:

```
[status] [priority ]imperative outcome [tags] [-> due date]
```

- Statuses: `[ ]` queued, `[@]` active, `[x]` verified, `[~]` terminal,
  `[?]` needs decision.
- Priorities: none normal, `!` important, `!!` milestone-blocking.
- Tags: `#id`, `#owner`, `#after`, `#blocked-by`, `#needs`, `#verify`.
  Deadlines `-> YYYY-MM-DD`, never estimates.

One `[@]` per owner. Statuses move at step boundaries during execution,
not only at handoff: flip a step to `[x]` when its `#verify` proof runs.
Keeping state.md never more than one completed step stale is what lets an
interrupted session (compaction, crash, kill) resume from this file
instead of a lossy summary. At handoff, journal and remove `[x]`/`[~]`
items. Keep state/journal separate; no `tasks.xit` unless canonical.

### Verification-path run stamps

Every entry carries the date it last actually ran. Strict check-state.sh
(run by the Stop hook on every ship report) requires the newest stamp in
the section to be from that same day: re-run and re-stamp, or mark an
entry `not re-run (YYYY-MM-DD)` with today's date — a disclosed gap
beats implied coverage. A stamp is a claim about a run that happened;
re-stamping without re-running is exactly the drift this check surfaces.

### History — compaction target (tool-managed)

`compact-journal.sh` writes or updates a `## History (digest through
YYYY-MM-DD)` section here when it folds old journal entries: it carries
the previous digest's bullets forward verbatim and leaves one TODO-SDLC
placeholder for the newly folded entries, which the model then fills in.
This is the one section a session never hand-authors.

## journal.md — append-only log

One entry per working session, appended at the end; never edit old
entries. Telegrams, not narratives — aim for ~8 lines (the hygiene check
warns past 12, newest entry only):

```markdown
## YYYY-MM-DD — <one-line summary>
- Did: what actually happened, with outcomes
- Verified: commands run and results observed
- Learned: anything that changed understanding (or "nothing new")
- Left: loose ends handed to the next session
```

### Compaction — the only sanctioned journal rewrite

When journal.md exceeds ~200 lines at handoff, fold every entry except
the newest 5 into the `## History` digest in state.md (merging any
previous digest's bullets); journal.md keeps only the newest 5 entries,
byte-for-byte untouched. A digest left in the journal is never read back
— it belongs in state.md.

## Scripts and hygiene checks

`check-state.sh` validates this spec mechanically — advisory while
working, strict at handoff:

```
bash ~/.agents/skills/sdlc-core/scripts/check-state.sh [--strict] [repo-dir]
```

(fallback: the `scripts/` directory inside the `sdlc-core/` sibling of
the calling skill's directory; `--strict` must precede the optional repo
dir). Advisory mode WARNs at state.md over 60 lines or journal.md over
200; strict mode FAILs those. state.md over the 120-line hard cap always
FAILs. Each FAIL line names a violation to fix before handoff completes.

Sibling scripts do the rest of the mechanical work: `orient.sh` (session
orientation, scaffolds `.ai-sdlc/` on first use), `scaffold-state.sh`
(state.md skeleton, refuses to overwrite), `compact-journal.sh` (the
History fold above), `diff-inventory.sh` (read-only working-tree
inventory).

`TODO-SDLC` is the scripts↔model contract: every judgment slot a script
cannot fill is marked with it, and check-state.sh FAILs while any remains
— likewise while a `journal.md.bak` left by compact-journal.sh exists —
so a half-finished artifact cannot pass handoff.

## Rules

- **state.md must never contradict the repo.** When they disagree, the
  code is right — fix state.md and note the drift in the journal.
- Absolute dates only; convert "yesterday"/"last week" before writing.
- Do not duplicate what the repo already records (README, AGENTS.md, git
  history); state files hold what is not derivable from the code.
- No secrets, tokens, or credentials — these files are committed.
