#!/usr/bin/env bash
# One-command session orientation for sdlc-start: bundles every mechanical
# read a session owes before substantive edits — git snapshot, state.md,
# the newest journal entries, the drift check — so no step gets skipped,
# then prints the orientation block to fill in. Read-only, except that a
# missing .ai-sdlc/state.md is scaffolded (first session of a project).
#
# Usage: orient.sh [repo-dir]     (default: current directory)
#
# Always exits 0: orientation is informational. Drift the check reports is
# repaired as part of the work, and blocks at handoff, not here.

set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
cd "${1:-.}"

echo "== git =="
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git branch --show-current 2>/dev/null || true
  git log --oneline -3 2>/dev/null || echo "(no commits yet)"
  dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  echo "uncommitted paths: $dirty (inherited — none of it is this session's work)"
else
  echo "(not a git repository)"
fi

echo
echo "== .ai-sdlc/state.md =="
if [ ! -f .ai-sdlc/state.md ]; then
  bash "$HERE/scaffold-state.sh" .
  echo "(scaffolded just now — first session under sdlc for this project)"
  echo
fi
cat .ai-sdlc/state.md

echo
echo "== journal (newest 3 entries) =="
if [ -f .ai-sdlc/journal.md ]; then
  total=$(grep -c '^## ' .ai-sdlc/journal.md 2>/dev/null || true)
  if [ "${total:-0}" -gt 0 ]; then
    start=$(( total > 3 ? total - 2 : 1 ))
    awk -v s="$start" '/^## /{c++} c>=s' .ai-sdlc/journal.md
  else
    echo "(journal has no dated entries yet)"
  fi
else
  echo "(no journal yet — sdlc-finish creates it on first handoff)"
fi

echo
echo "== drift check =="
if ! bash "$HERE/check-state.sh" .; then
  echo "NOTE  the FAILs above are scaffold slots to fill or drift left by an"
  echo "      earlier session — repairing them is part of this session's work;"
  echo "      check-state.sh blocks handoff while any remain."
fi

echo
cat <<'EOF'
== orient — fill this block in your reply; no slot may be guessed ==
Orientation
- Goal: TODO-SDLC what the user wants from THIS session, not the first plausible reading
- Code: TODO-SDLC where the relevant code lives, from files opened this session
- Verify: TODO-SDLC the project's check command, RUN NOW, and the baseline observed
- Resuming: TODO-SDLC what the last session left (state.md Next + journal), or "fresh start"
A slot you cannot fill truthfully is the gap to close before editing anything.
EOF
