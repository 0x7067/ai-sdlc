#!/usr/bin/env bash
# Scaffold a repo's .ai-sdlc/state.md skeleton per STATE-SPEC.md.
#
# Usage: scaffold-state.sh [repo-dir]     (default: current directory)
#
# Mechanical part only: emits the exact required sections and today's
# `updated:` line, with every judgment slot marked `TODO-SDLC: ...`.
# The model replaces the placeholders; check-state.sh FAILs while any
# remain. journal.md is NOT created here — sdlc-handoff creates it on
# first append.
#
# Refuses to overwrite an existing state.md.

set -euo pipefail

DIR="${1:-.}/.ai-sdlc"
STATE="$DIR/state.md"

if [ -f "$STATE" ]; then
  echo "REFUSE  $STATE already exists — edit it instead" >&2
  exit 1
fi

mkdir -p "$DIR"
cat > "$STATE" <<EOF
# Project State
updated: $(date +%F)

## Goal
TODO-SDLC: what this project is trying to become, in 2-4 sentences.

## Now
TODO-SDLC: the active milestone or task, and where it stands.

## Verification path
TODO-SDLC: build/test/run commands with the result observed this session
(pass/fail), or the manual run + what correct output looks like.

## Decisions
TODO-SDLC: standing decisions with a one-line why each — or "None yet."

## Landmines
TODO-SDLC: non-obvious traps (flaky tests, deceptive files, env quirks)
— or "None known."

## Next
1. TODO-SDLC: ordered, concrete, cold-startable steps.
EOF

echo "CREATED  $STATE"
echo "NEXT     replace every TODO-SDLC line with real content (sparse-but-true"
echo "         beats complete-but-guessed); check-state.sh FAILs while any remain."
