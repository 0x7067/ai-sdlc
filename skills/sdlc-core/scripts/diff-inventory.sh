#!/usr/bin/env bash
# Canonical working-tree inventory for sdlc-finish (validation and handoff):
# branch, status, staged/unstaged diff stats, untracked files, and
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

# Comment-looking added lines from staged + unstaged diffs, code files only
# (markdown headings would false-positive). A surfacing heuristic for the
# STANDARD §3 review, not a judgment: the model decides what each line earns.
echo "== added comment lines — each must earn its place (STANDARD §3: non-obvious why, trap, external constraint — never narration or prescriptive scaffolding) =="
{ git diff -- . ':(exclude)*.md' ':(exclude)*.markdown'; \
  git diff --cached -- . ':(exclude)*.md' ':(exclude)*.markdown'; } \
  | grep -E '^\+[^+]' \
  | grep -E '^\+[[:space:]]*(#|//|/\*|\*[[:space:]]|<!--|--[[:space:]]|;[[:space:]])' \
  || echo "(none)"

echo "== untracked files — READ EACH ONE IN FULL during review =="
git ls-files --others --exclude-standard

echo "== stashes — must be empty at handoff (STATE-SPEC: stashes are invisible to the next session) =="
git stash list
