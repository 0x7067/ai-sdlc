#!/usr/bin/env bash
# Shared helpers for the tier1 behavioral eval harness.
# Source this; do not execute directly.
#
# Portability: bash, macOS/BSD + GNU tolerant (mirrors sdlc-core/scripts style
# — see skills/sdlc-core/scripts/check-state.sh for the conventions this
# copies: `stat -c || stat -f` fallback, `set -euo pipefail`, portable mktemp).

set -uo pipefail

# --- paths -------------------------------------------------------------

# Absolute path to evals/tier1 (this file's directory's parent).
tier1_dir() {
  local lib_dir
  lib_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  (cd "$lib_dir/.." && pwd)
}

# Absolute path to the ai-sdlc repo root (read-only — builders write only
# under evals/tier1/, but run.sh needs this to locate install.sh, skills/,
# hooks/ to install into an isolated HOME for the sdlc arm).
repo_root() {
  git -C "$(tier1_dir)" rev-parse --show-toplevel
}

# --- the scaffold placeholder token --------------------------------------
#
# HARD LANDMINE (see task brief / STATE-SPEC.md "Scripts and hygiene
# checks"): the literal token check-state.sh greps for must never appear
# contiguously in any file this harness writes or commits — doing so would
# make check-state.sh FAIL if ever run against this repo's own .ai-sdlc/.
# Every caller that needs the token (e.g. to plant a realistic "previous
# session left a digest placeholder unfilled" trap in a fixture, or to
# assert check-state.sh's own FAIL behavior) must go through this function
# rather than spelling it out.
sdlc_placeholder_token() {
  local part1="TOD" part2="O" part3="-SDLC"
  printf '%s' "${part1}${part2}${part3}"
}

# --- fixture repo construction ------------------------------------------

# Create an empty git repo at $1 with a stable local identity and a
# deterministic default branch name ("main"), independent of the host's
# global git config (init.defaultBranch may be unset or different).
git_init_repo() {
  local dir="$1"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" symbolic-ref HEAD refs/heads/main
  git -C "$dir" config user.email "fixture@tier1.local"
  git -C "$dir" config user.name "tier1-fixture"
  git -C "$dir" config commit.gpgsign false
}

git_commit_all() {
  local dir="$1" msg="$2"
  git -C "$dir" add -A
  git -C "$dir" commit -q -m "$msg"
}

# --- isolated HOME construction -----------------------------------------

# Build a control-arm HOME: exists, but carries no ~/.claude at all, so no
# skills, no hooks, no settings — a clean baseline.
setup_control_home() {
  local iso_home="$1"
  mkdir -p "$iso_home"
}

# Build an sdlc-arm HOME the way install.sh would: symlink this repo's
# skills/sdlc-* and hooks/sdlc-* into the isolated ~/.claude, then register
# the SessionStart/Stop hooks in settings.json exactly as install.sh's
# printed instructions describe (install.sh itself never touches
# settings.json, so this mirrors that manual step programmatically).
setup_sdlc_home() {
  local iso_home="$1" root
  root="$(repo_root)"
  mkdir -p "$iso_home"
  SKILLS_DIR="$iso_home/.claude/skills" HOOKS_DIR="$iso_home/.claude/hooks" \
    bash "$root/install.sh" >/dev/null

  cat > "$iso_home/.claude/settings.json" <<'EOF'
{
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
}
EOF
}

# --- fixture variants ------------------------------------------------------
#
# Each scenario ships a small pool of complete, coherent fixture variants —
# project name, file names, landmine, and ground-truth keywords change
# together, so keyword hygiene (distractors never contain answer keywords)
# holds per variant, not just per scenario. TIER1_SEED selects one:
# unset / empty / "canonical" -> variant 0, the canonical fixture that the
# dry_run/ canned transcripts are graded against; any non-negative integer
# -> seed % pool size. run.sh records the seed so runs are reproducible.
tier1_variant() { # tier1_variant POOL_SIZE -> prints the selected index
  local pool="$1" seed="${TIER1_SEED:-}"
  case "$seed" in
    ''|canonical) echo 0 ;;
    *[!0-9]*)
      echo "tier1: TIER1_SEED must be a non-negative integer or 'canonical' (got '$seed')" >&2
      return 1 ;;
    *) echo $(( seed % pool )) ;;
  esac
}

# --- misc ----------------------------------------------------------------

# Portable mtime-independent timestamp for filenames.
ts_now() {
  date -u +%Y%m%dT%H%M%SZ
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { echo "tier1: missing required command '$1'" >&2; exit 1; }
}
