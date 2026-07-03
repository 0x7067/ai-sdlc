#!/usr/bin/env bash
# Canonical working-tree inventory for sdlc-validate Step 1 and sdlc-handoff
# Step 1: branch, status, staged/unstaged diff stats, untracked files, and
# stashes in one deterministic, read-only block — so no category of change
# gets skipped by an improvised git invocation.
#
# Usage: diff-inventory.sh [base-ref]     (run from inside the repo)
#
# Pass base-ref when the work under review spans commits: adds a
# `<base-ref>...HEAD` stat section.

set -euo pipefail

git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
  || { echo "ERROR  not inside a git repository" >&2; exit 1; }

base="${1:-}"

echo "== branch =="
git branch --show-current 2>/dev/null || true
git log --oneline -3 2>/dev/null || echo "(no commits yet)"

echo "== status (porcelain) =="
git status --porcelain

echo "== staged diff stat =="
git diff --cached --stat

echo "== unstaged diff stat =="
git diff --stat

if [ -n "$base" ]; then
  echo "== committed vs $base ($base...HEAD stat) =="
  git diff --stat "$base...HEAD"
fi

echo "== untracked files — READ EACH ONE IN FULL during review =="
git ls-files --others --exclude-standard

echo "== stashes — must be empty at handoff (STATE-SPEC: stashes are invisible to the next session) =="
git stash list
