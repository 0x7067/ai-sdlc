#!/usr/bin/env bash
# Install the ai-sdlc skill library for Claude Code (and any harness that
# discovers skills from a directory of SKILL.md folders).
#
# What it does:
#   1. Symlinks each skills/sdlc-* directory into a skills dir
#      (default: ~/.claude/skills; override with SKILLS_DIR=...).
#   2. Symlinks hooks/sdlc-lifecycle-gate and hooks/sdlc-handoff-gate
#      into ~/.claude/hooks.
#   3. Prints the settings.json hook entry and the AGENTS.md/CLAUDE.md
#      routing snippet for you to add manually (the script never edits
#      your settings or instruction files).
#
# Symlinks (not copies) keep a `git pull` in this repo live everywhere,
# and keep the sdlc-core sibling-directory resolution intact.
#
# Idempotent: re-running replaces existing symlinks, refuses to touch
# real files/directories it did not create.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${SKILLS_DIR:-$HOME/.claude/skills}"
HOOKS_DIR="${HOOKS_DIR:-$HOME/.claude/hooks}"

link() { # link <target> <linkpath>
  local target="$1" linkpath="$2"
  if [ -e "$linkpath" ] && [ ! -L "$linkpath" ]; then
    echo "SKIP  $linkpath exists and is not a symlink — resolve manually" >&2
    return 0
  fi
  ln -sfn "$target" "$linkpath"
  echo "LINK  $linkpath -> $target"
}

mkdir -p "$SKILLS_DIR" "$HOOKS_DIR"

for skill in "$REPO_DIR"/skills/sdlc-*; do
  link "$skill" "$SKILLS_DIR/$(basename "$skill")"
done

link "$REPO_DIR/hooks/sdlc-lifecycle-gate" "$HOOKS_DIR/sdlc-lifecycle-gate"
link "$REPO_DIR/hooks/sdlc-handoff-gate" "$HOOKS_DIR/sdlc-handoff-gate"

cat <<EOF

Skills and hooks installed.

Two manual steps remain:

1. Register the hooks in ~/.claude/settings.json (SessionStart makes
   smaller models route through the skills; Stop makes them finish with
   a real, verified handoff):

     "hooks": {
       "SessionStart": [
         { "matcher": "", "hooks": [
           { "type": "command", "command": "~/.claude/hooks/sdlc-lifecycle-gate", "timeout": 10 }
         ] }
       ],
       "Stop": [
         { "hooks": [
           { "type": "command", "command": "~/.claude/hooks/sdlc-handoff-gate", "timeout": 10 }
         ] }
       ]
     }

2. Add the routing snippet to your global instructions
   (~/.claude/CLAUDE.md or ~/.agents/AGENTS.md) as a cross-harness baseline:

     see $REPO_DIR/agents-md/sdlc-lifecycle.md
EOF
