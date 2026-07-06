# tier1 smoke test

## What was attempted

One real headless run of scenario (a) `resumption`, arm `control`, model
`claude-haiku-4-5-20251001`, exactly as required:

```
bash evals/tier1/run.sh --scenario resumption --arm control \
  --model claude-haiku-4-5-20251001
```

`run.sh` did everything short of getting a real model answer:

1. `scenarios/resumption/generate.sh` built a fresh fixture repo in a
   `mktemp -d` directory with a seeded `.ai-sdlc/state.md`, a dirty working
   tree, and `ground_truth.json` — verified by hand afterward, matches spec.
2. `setup_control_home` built an isolated `$HOME` for the run —
   confirmed empty of `.claude/skills` and `.claude/hooks` (only the
   session bookkeeping `claude` itself writes on first launch).
3. `run.sh` invoked the real `claude` CLI:
   `env HOME="$iso_home" claude -p "$PROMPT" --model claude-haiku-4-5-20251001
   --output-format json --permission-mode bypassPermissions
   --no-session-persistence`, cwd'd into the fixture repo.

## The blocker

The isolated `$HOME` has no Claude Code login state (no `~/.claude.json`),
so the CLI refuses to place the API call at all — this is a client-side
gate, not a rejection from the model or the sandbox's local API proxy.
Exact captured output (`evals/tier1/results/raw/resumption-control-*.json`):

```json
{"type":"result","subtype":"success","is_error":true, ... ,
 "result":"Not logged in · Please run /login", ...,
 "usage":{"input_tokens":0,"output_tokens":0, ...}}
```

`run.sh` classified this correctly on its own (`is_error: true`, `score:
null`, `error_message` captured) rather than silently grading garbage as a
wrong answer — see the full record in the results file above.

## Why isolating `$HOME` causes this

Confirmed empirically before building the harness:

- A fully isolated `$HOME` (no `~/.claude.json`) → `Not logged in`.
- `CLAUDE_CONFIG_DIR` pointed at an isolated dir (leaving `$HOME` alone)
  → still `Not logged in`: `CLAUDE_CONFIG_DIR` relocates the account/login
  state (`.claude.json`) together with skills/hooks, not just the latter.
- The account's actual OAuth material is not readable by this agent
  (attempting to enumerate it — keychain lookups, cat'ing `~/.claude.json`
  — is correctly denied by the sandbox as credential exploration, and
  copying credentials into a fixture `$HOME` would violate "never handle
  secrets" regardless).
- The CLI does document a legitimate headless-auth path for exactly this
  situation: `claude setup-token` mints a long-lived
  `CLAUDE_CODE_OAUTH_TOKEN` (confirmed present as a real, documented env
  var by inspecting the binary's strings — this is the mechanism Claude
  Code's own GitHub Actions integration uses). It requires one *interactive*
  browser-based login by whoever owns the account; an agent cannot mint it
  for itself.

`run.sh` is wired to use this the moment it exists: if the invoking shell
already has `CLAUDE_CODE_OAUTH_TOKEN` or `ANTHROPIC_API_KEY` exported, it is
passed through into the isolated `$HOME` verbatim (never read/derived by
the harness itself — see `run.sh`'s `pass_env` array). Neither was set in
this session, so the smoke run hit the blocker above.

## To get a real run

```
claude setup-token          # interactive, once, as Pedro
export CLAUDE_CODE_OAUTH_TOKEN=...   # the token it prints
bash evals/tier1/run.sh --scenario resumption --arm control \
  --model claude-haiku-4-5-20251001
```

## What *did* run for real

- `claude -p` itself works fine non-interactively and even nested inside
  another Claude Code session (no auth/nesting block there) — confirmed
  with a real `PONG` round-trip against the real account `$HOME` before
  isolation was introduced.
- Both arms' isolated-`$HOME` construction was verified directly on disk:
  `control` → no `.claude/skills`, no `.claude/hooks`; `sdlc` → correct
  symlinks into this repo's `skills/sdlc-{core,start,finish}` and
  `hooks/sdlc-{lifecycle,handoff}-gate`, plus a `settings.json` registering
  the SessionStart/Stop hooks exactly as `install.sh`'s printed
  instructions describe.
- `compare.sh`'s regression detection was verified against a synthetic
  baseline + a deliberately regressed results file (score drop and token
  blowup both correctly caught, both exit 1; a same-vs-same comparison
  correctly exits 0).

## Harness verified end-to-end via `--dry-run`

```
bash evals/tier1/run.sh --scenario all --arm both --dry-run
```

exercises generator → (stubbed model call) → grader → results file for
all 4 scenarios × 2 arms using the canned transcripts in `evals/tier1/dry_run/`.
Output (scores as designed — canned "sdlc" answers are seeded to be
correct, canned "control" answers seeded to be wrong, so the grader's
discrimination is visible, not assumed):

```
resumption/control: score=1/5   resumption/sdlc: score=5/5
stale_state/control: score=0/1  stale_state/sdlc: score=1/1
false_ship/control: score=0/1   false_ship/sdlc: score=1/1
overhead/control: turns=2 tokens_total=1440
overhead/sdlc:    turns=7 tokens_total=34840
```

(`overhead`'s sanity-check score is 0 in both dry-run arms — correctly so:
a canned transcript never actually edits the fixture's README.md, and
`grade.sh` checks the real file, not the claimed text. That's a feature,
not a bug: it means the grader can't be fooled by a transcript that merely
*claims* the fix landed.)

## Update 2026-07-06 (second session): workarounds ruled out

Attempted unblocks, all landing back on `claude setup-token`:

- Seeding the isolated `$HOME` with a copy of `~/.claude.json` → still
  `Not logged in` (~20ms, purely local check fails).
- Same, unsandboxed (in case the sandbox blocked the child's Keychain
  read) → identical result. On macOS the Keychain path derives from
  `$HOME` (`$HOME/Library/Keychains`), so isolating `$HOME` severs
  credentials regardless of sandboxing.
- `CLAUDE_CONFIG_DIR=<iso>` with seeded `.claude.json` and the *real*
  `$HOME` (Keychain reachable) → still `Not logged in`; account state in
  `.claude.json` alone does not satisfy the login check.
- Enumerating where credentials actually live (file store vs keychain vs
  apiKeyHelper) is credential exploration and was correctly denied by the
  permission layer — do not retry that route.

Conclusion: the one sanctioned path stands — Pedro runs
`claude setup-token` interactively (own terminal), then invokes
`CLAUDE_CODE_OAUTH_TOKEN=<token> bash evals/tier1/run.sh --scenario all
--arm both` (or exports the var before launching an agent session so
run.sh's pass_env forwards it). Keep the token out of chat transcripts.
