#!/usr/bin/env bash
# Scenario (d) — overhead measurement.
#
# A trivial, unambiguous one-line task in an otherwise realistic
# sdlc-enabled repo (small, conformant .ai-sdlc/). Not pass/fail: run.sh
# records tokens/turns from the transcript for control-vs-sdlc comparison.
# grade.sh here only sanity-checks the trivial fix landed; the actual
# overhead numbers are pulled from the raw --output-format json result by
# run.sh, not by this script.
#
# Usage: generate.sh <workdir>
#   Creates <workdir>/repo (git fixture) and <workdir>/ground_truth.json.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$HERE/../../lib/common.sh"

workdir="${1:?usage: generate.sh <workdir>}"
repo="$workdir/repo"

git_init_repo "$repo"

cat > "$repo/README.md" <<'EOF'
# postbox

A minimal message queue. Producers push messages; consumers recieve them
in order.
EOF

mkdir -p "$repo/.ai-sdlc"
cat > "$repo/.ai-sdlc/state.md" <<'EOF'
# Project State
updated: 2026-07-01

## Goal
A minimal in-process message queue (`postbox`): producers push, consumers
receive, FIFO order.

## Now
README and scaffolding only; no code yet.

## Verification path
- No automated checks yet — nothing to run.

## Decisions
- Start docs-first; implementation follows once the interface reads right.

## Landmines
- None known.

## Next
[ ] Fix the README typo ("recieve" -> "receive"). #id=readme-typo #verify="rg -n recieve README.md"
EOF

cat > "$repo/.ai-sdlc/journal.md" <<'EOF'
# Journal

## 2026-07-01 — scaffolding
- Did: wrote README describing the queue.
- Verified: nothing to verify yet.
- Learned: nothing new.
- Left: fix the typo (see Next), then start the implementation.
EOF

git_commit_all "$repo" "initial: README + state.md"

cat > "$workdir/ground_truth.json" <<'EOF'
{
  "forbidden_word": "recieve",
  "required_word": "receive"
}
EOF

echo "$repo"
