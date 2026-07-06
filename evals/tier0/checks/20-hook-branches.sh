#!/usr/bin/env bash
# Drive hooks/sdlc-lifecycle-gate (SessionStart) and hooks/sdlc-handoff-gate
# (Stop) the way Claude Code does: JSON on stdin, a transcript file path, an
# isolated $HOME (so the handoff gate's check-state.sh lookup hits THIS
# repo's script, not a deployed copy — the trick documented in
# .ai-sdlc/journal.md 2026-07-03), asserting exit code + stderr/stdout.

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$HERE/../lib/common.sh"

sandbox=$(mktemp -d)
trap 'rm -rf "$sandbox"' EXIT

# A fresh isolated git repo, used as the hook's cwd for every case.
repo="$sandbox/repo"
mkdir -p "$repo"
( cd "$repo" && git init -q && git config user.email t@example.com && git config user.name t \
  && git commit -q --allow-empty -m init )

# Fake $HOME with check-state.sh reachable at the path sdlc-handoff-gate
# looks for (only the first of its two candidate paths is populated).
fakehome="$sandbox/home"
mkdir -p "$fakehome/.agents/skills/sdlc-core/scripts" "$fakehome/tmp"
cp "$CHECK_STATE_SH" "$fakehome/.agents/skills/sdlc-core/scripts/check-state.sh"
chmod +x "$fakehome/.agents/skills/sdlc-core/scripts/check-state.sh"

# --- transcript builders ---------------------------------------------------

write_transcript() { # write_transcript <path> <assistant-text>
  local path="$1" text="$2"
  # jq -Rs turns arbitrary text into a valid JSON string, keeping this
  # robust to any special characters in the fixture text.
  local json_text
  json_text=$(printf '%s' "$text" | jq -Rs .)
  printf '{"type":"assistant","message":{"content":[{"type":"text","text":%s}]}}\n' "$json_text" > "$path"
}

# --- runners ----------------------------------------------------------------

HG_OUT=""; HG_ERR=""; HG_CODE=0
run_handoff() { # run_handoff <cwd> <session_id> <stop_hook_active> <transcript_path> [path_override]
  local cwd="$1" sid="$2" active="$3" transcript="$4" path_override="${5:-}"
  local stdin_json errfile
  stdin_json=$(printf '{"session_id":"%s","transcript_path":"%s","stop_hook_active":%s}' \
    "$sid" "$transcript" "$active")
  errfile=$(mktemp)
  if [ -n "$path_override" ]; then
    # BASH_ENV="" matters here: this environment's non-interactive bash
    # sources a global path-management rc (see $BASH_ENV) that otherwise
    # resets PATH on every invocation, silently undoing path_override.
    HG_OUT=$(cd "$cwd" && HOME="$fakehome" TMPDIR="$fakehome/tmp" PATH="$path_override" BASH_ENV="" \
      bash "$HOOK_HANDOFF" <<<"$stdin_json" 2>"$errfile")
  else
    HG_OUT=$(cd "$cwd" && HOME="$fakehome" TMPDIR="$fakehome/tmp" \
      bash "$HOOK_HANDOFF" <<<"$stdin_json" 2>"$errfile")
  fi
  HG_CODE=$?
  HG_ERR=$(cat "$errfile"); rm -f "$errfile"
}

marker_path() { printf '%s/sdlc-handoff-gate-%s' "$fakehome/tmp" "$1"; }

make_dirty() { # make_dirty <repo> -- adds an untracked file
  touch "$1/untracked-fixture.txt"
}
make_clean() { # make_clean <repo> -- removes untracked fixture mutations
  # No tracked files are ever mutated by this suite, so cleaning untracked
  # content is sufficient (a bare `git checkout -- .` errors on a repo with
  # no tracked files at all, which the fixture repo is).
  ( cd "$1" && git clean -fdq )
}

# ============================================================================
# sdlc-lifecycle-gate (SessionStart)
# ============================================================================

# L1 — inside a git repo: emits the routing text, exit 0.
out=$(cd "$repo" && bash "$HOOK_LIFECYCLE" 2>&1); code=$?
assert_exit "hook.lifecycle.git-repo.exit" "$code" 0
assert_contains "hook.lifecycle.git-repo.text" "$out" "SDLC LIFECYCLE"
assert_contains "hook.lifecycle.git-repo.start" "$out" "Skill(sdlc-start)"
assert_contains "hook.lifecycle.git-repo.finish" "$out" "Skill(sdlc-finish)"

# L2 — outside a git repo: silent, exit 0.
nongit="$sandbox/nongit"; mkdir -p "$nongit"
out=$(cd "$nongit" && bash "$HOOK_LIFECYCLE" 2>&1); code=$?
assert_exit "hook.lifecycle.non-git.exit" "$code" 0
assert_empty "hook.lifecycle.non-git.silent" "$out"

# ============================================================================
# sdlc-handoff-gate (Stop) — each case gets its own session_id (own marker).
# ============================================================================

empty_transcript="$sandbox/empty.jsonl"; : > "$empty_transcript"

# H1 — outside a git repo: silent, exit 0, no marker.
run_handoff "$nongit" "h1" false "$empty_transcript"
assert_exit "hook.handoff.non-git.exit" "$HG_CODE" 0
assert_empty "hook.handoff.non-git.stdout" "$HG_OUT"
assert_empty "hook.handoff.non-git.stderr" "$HG_ERR"
assert_file_absent "hook.handoff.non-git.no-marker" "$(marker_path h1)"

# H2 — stop_hook_active=true: silent, exit 0, no marker (short-circuits
# before any of the other logic, so a blocked stop can't re-block itself).
run_handoff "$repo" "h2" true "$empty_transcript"
assert_exit "hook.handoff.stop-active.exit" "$HG_CODE" 0
assert_empty "hook.handoff.stop-active.stdout" "$HG_OUT"
assert_empty "hook.handoff.stop-active.stderr" "$HG_ERR"
assert_file_absent "hook.handoff.stop-active.no-marker" "$(marker_path h2)"

# H3 — branch A: "Handoff report" issued, .ai-sdlc/ does not exist -> block.
t="$sandbox/h3.jsonl"; write_transcript "$t" "Handoff report
everything is done."
make_clean "$repo"
run_handoff "$repo" "h3" false "$t"
assert_exit "hook.handoff.branchA-missing-dir.exit" "$HG_CODE" 2
assert_contains "hook.handoff.branchA-missing-dir.msg" "$HG_ERR" "does not exist"
assert_contains "hook.handoff.branchA-missing-dir.msg2" "$HG_ERR" "nothing was persisted"

# H4 — branch A: Handoff report issued, .ai-sdlc/ exists but fails STATE-SPEC.
mkdir -p "$repo/.ai-sdlc"
write_valid_state_dir "$repo"
remove_markdown_section "$repo/.ai-sdlc/state.md" "## Now"
t="$sandbox/h4.jsonl"; write_transcript "$t" "Handoff report
done for real this time."
run_handoff "$repo" "h4" false "$t"
assert_exit "hook.handoff.branchA-check-fail.exit" "$HG_CODE" 2
assert_contains "hook.handoff.branchA-check-fail.msg" "$HG_ERR" "fail STATE-SPEC"
assert_contains "hook.handoff.branchA-check-fail.fail-line" "$HG_ERR" "missing '## Now' section"
rm -rf "$repo/.ai-sdlc"

# H5 — branch A: Handoff report issued, .ai-sdlc/ fully conformant -> exit 0.
mkdir -p "$repo/.ai-sdlc"; write_valid_state_dir "$repo"
t="$sandbox/h5.jsonl"; write_transcript "$t" "Handoff report
state.md and journal.md are current."
run_handoff "$repo" "h5" false "$t"
assert_exit "hook.handoff.branchA-pass.exit" "$HG_CODE" 0
assert_file_exists "hook.handoff.branchA-pass.marker" "$(marker_path h5)"
rm -rf "$repo/.ai-sdlc"

# H6 — branch B: "VERDICT: SHIP" issued with a dirty tree -> block.
make_dirty "$repo"
t="$sandbox/h6.jsonl"; write_transcript "$t" "VERDICT: SHIP
the change is validated."
run_handoff "$repo" "h6" false "$t"
assert_exit "hook.handoff.branchB-ship-dirty.exit" "$HG_CODE" 2
assert_contains "hook.handoff.branchB-ship-dirty.msg" "$HG_ERR" "validation returned SHIP but the working tree is dirty"
make_clean "$repo"

# H7 — branch B corollary: SHIP with a CLEAN tree does not block; falls
# through to C, which (first stop for this session_id) arms without nagging.
t="$sandbox/h7.jsonl"; write_transcript "$t" "VERDICT: SHIP
the change is validated and committed."
run_handoff "$repo" "h7" false "$t"
assert_exit "hook.handoff.branchB-ship-clean.exit" "$HG_CODE" 0
assert_file_exists "hook.handoff.branchB-ship-clean.marker" "$(marker_path h7)"

# H8 — branch C: first stop ever for this session (marker absent) arms the
# marker without nagging, even though the tree is dirty.
make_dirty "$repo"
run_handoff "$repo" "h8" false "$empty_transcript"
assert_exit "hook.handoff.branchC-first-stop.exit" "$HG_CODE" 0
assert_empty "hook.handoff.branchC-first-stop.stderr" "$HG_ERR"
assert_file_exists "hook.handoff.branchC-first-stop.marker" "$(marker_path h8)"

# H9 — branch C: marker older than 45 minutes, tree still dirty -> nag.
touch -t "$(past_touch_stamp 46)" "$(marker_path h8)"
run_handoff "$repo" "h8" false "$empty_transcript"
assert_exit "hook.handoff.branchC-nag.exit" "$HG_CODE" 2
assert_contains "hook.handoff.branchC-nag.msg" "$HG_ERR" "45 minutes"

# H10 — branch C: marker fresh (<45min), tree dirty -> no nag.
run_handoff "$repo" "h8" false "$empty_transcript"
assert_exit "hook.handoff.branchC-fresh-marker.exit" "$HG_CODE" 0
assert_empty "hook.handoff.branchC-fresh-marker.stderr" "$HG_ERR"

# H11 — branch C: marker present (any age) but tree clean -> no nag.
touch -t "$(past_touch_stamp 90)" "$(marker_path h8)"
make_clean "$repo"
run_handoff "$repo" "h8" false "$empty_transcript"
assert_exit "hook.handoff.branchC-clean-tree.exit" "$HG_CODE" 0
assert_empty "hook.handoff.branchC-clean-tree.stderr" "$HG_ERR"

# H12 — no jq on PATH: transcript inspection (A/B) is unavailable, so a
# "Handoff report" transcript is invisible and the hook degrades to branch C
# only (documented in the hook's own header comment).
restricted_path=$(printf '%s' "$PATH" | tr ':' '\n' | grep -v '^/usr/bin$' | paste -sd: -)
if ! command -v jq >/dev/null 2>&1; then
  warnrep "hook.handoff.no-jq" "jq not on PATH in this environment already — skipping"
elif printf '%s\n' "$restricted_path" | tr ':' '\n' | xargs -I{} test -x {}/jq 2>/dev/null; then
  warnrep "hook.handoff.no-jq" "could not build a jq-free PATH (jq present outside /usr/bin) — skipping"
else
  make_dirty "$repo"
  t="$sandbox/h12.jsonl"; write_transcript "$t" "Handoff report
should be invisible without jq."
  run_handoff "$repo" "h12" false "$t" "$restricted_path"
  assert_exit "hook.handoff.no-jq.exit" "$HG_CODE" 0
  assert_file_exists "hook.handoff.no-jq.marker" "$(marker_path h12)"
  make_clean "$repo"
fi
