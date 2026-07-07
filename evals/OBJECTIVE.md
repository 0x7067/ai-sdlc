# What "better" means for this harness

The harness exists so that sessions produce work that is actually done and
the next session resumes it correctly, at the lowest overhead that still
achieves that. Everything else this repo measures is a proxy. Three axes,
in priority order:

1. **Resumption fidelity** (primary). A cold session, given only the repo
   and `.ai-sdlc/state.md`, reaches the same understanding and intended
   next action the ending session had. Measured by outcomes — can it name
   the goal, the next step, the exact verify command, the landmine — never
   by whether ceremony text was emitted.
2. **Claim integrity.** Every "done"/SHIP claim reproduces: the named
   verification command passes when re-run, and pre-existing failures are
   reported rather than absorbed. A wrong "it works" is the costliest
   output this system can produce.
3. **Overhead** (guard metric). Injected-context tokens (hook text,
   SKILL.md bodies, state.md) and ceremony turns stay bounded; hook
   false-positive/nag rate ~0. Overhead never *justifies* a change alone —
   it bounds how axes 1–2 may be pursued.

**Better** = axis 1 or 2 measurably up without axis 3 up, or axis 3 down
without 1–2 down. A change that only moves a proxy (line counts, probe
compliance, word deltas) is not better yet — it is unmeasured.

## The proxy map

Every number this repo tracks, and what it stands in for. A metric not in
this table is a smell until it is added with its axis and failure mode.

| Proxy | Axis | Goodhart failure mode | Re-coupling |
|---|---|---|---|
| `check-state.sh` exit 0 | 1, 2 | validates form, not truth — a stale state.md passes | path-existence WARN; tier1 resumption eval measures truth directly |
| `updated:` freshness (mtime WARN) | 1 | re-stamp the date without re-verifying content | WARN wording now instructs re-verify-then-stamp |
| state.md line caps (60/120) | 3 | trim Landmines/Decisions — the highest-value lines — to satisfy the cap | WARN names safe trim targets (History/plan prose) |
| Hook grep tokens (`Handoff report`, `VERDICT: SHIP`) | 2 | skill prose and hook greps drift apart; branches go dead silently | tier0 coherence check: every grepped literal must be instructed by a live surface |
| ±20% per-skill word budget | 3 | treated as acceptance evidence for content edits; padding/trimming to the number | demoted to smell check; acceptance = tier0/tier1 green |
| Probe "trace blocks emitted" | none | measures ceremony compliance, not outcomes | replaced by tier1 outcome grading (answer keys, repo state) |
| "verified 2026-MM-DD" journal claims | 2 | one-off manual runs decay silently; nothing re-runs them | tier0 persists them as executable checks |
| Deployed == source | 2 | fixes tested here don't run there; hand-patches there vanish on deploy | tier0 deploy-drift advisory check |

## Regression gates

- **tier0** (`bash evals/tier0/run.sh`) — deterministic, seconds, zero
  model calls. Run after every change to `skills/`, `hooks/`, or
  `scripts/`. `--self-test` proves the suite can still fail (7 seeded
  mutations must be caught). Unexpected FAIL blocks; KNOWN-DRIFT entries
  are visible, justified, and expire (a listed entry that passes fails the
  run).
- **tier1** (`bash evals/tier1/run.sh`) — model-in-the-loop, costs real
  calls. Run before/after any skill-text or hook-text change that claims a
  behavioral effect, and for the control-vs-sdlc A/B. Scenarios grade
  outcomes: resumption Q&A against an answer key, stale-state trap,
  false-SHIP honesty, ceremony overhead. `--dry-run` exercises the
  pipeline without spend; `compare.sh` gates a results file against
  `baseline.json`.

Re-baselining (budgets.txt, baseline.json) is legitimate only as a
deliberate act with the reason recorded in the commit that changes it —
never to make a red run green.

## Anti-Goodhart rules

- No proxy is acceptance evidence by itself. Size deltas, exit codes, and
  compliance counts are smell checks; acceptance is the relevant tier
  passing.
- Any literal string a hook greps for must be instructed by a live surface
  a model actually reads (enforced by tier0 coherence — treat hook wording
  and skill wording as one atomic edit).
- "Verified" in a journal or state.md must name a re-runnable command, not
  describe a bygone manual run.
- When a check teaches a remediation, the remediation must repair the true
  target, not the measurement (the `updated:` WARN is the canonical
  example — it once said "re-stamp to today").

## Audit findings disposition (2026-07-06)

| # | Finding | Status |
|---|---|---|
| F1 | Stop-hook branches A/B dead — greps for tokens no skill instructs | **Fixed**: sdlc-finish now instructs both literals; tier0 coherence prevents recurrence |
| F2 | check-state validates form not truth; live stale instance in this repo's own state.md | **Partial**: WARN re-worded, path-existence advisory added, state.md corrected; full truth measurement is tier1's job |
| F3 | Deployed hooks carried uncommitted exemption logic | **Fixed**: carve-outs ported into `hooks/` source; deploy-drift advisory added |
| F4 | "Verified" claims were one-off manual runs | **Fixed**: tier0 persists them; self-test proves the suite can fail |
| F5 | README's "empirically" A/B claim has no surviving artifact | **Noted in README**; tier1 A/B mode re-runs it with persisted results |
| F6 | ±20% word budget used as acceptance evidence twice | **Demoted** to smell check (this doc; state.md decision updated) |
| F7 | Line-cap pressure on Landmines/Decisions | **Mitigated**: WARN names safe trim targets |

Full audit report with evidence quotes: session journal 2026-07-06 and the
workflow transcript that produced it.
