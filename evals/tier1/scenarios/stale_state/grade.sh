#!/usr/bin/env bash
# Grade scenario (b) — binary pass/fail, no LLM judge.
# Pass = the transcript flags the state.md/repo contradiction, OR the
# model repaired state.md (it no longer carries the stale claim).
# Fail = neither — the stale claim went unchallenged.
#
# Usage: grade.sh <ground_truth.json> <answer_text_file> <repo_dir>
# Prints: {"score":1|0,"max":1,"detail":{...}}

set -uo pipefail

gt="${1:?usage: grade.sh <ground_truth.json> <answer_text_file> <repo_dir>}"
answer_file="${2:?}"
repo_dir="${3:?}"

answer="$(cat "$answer_file" 2>/dev/null || true)"
answer_lc="$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]')"

disclosed_kw=""
n=$(jq -r '.contradiction_disclosure_keywords | length' "$gt")
for ((i=0; i<n; i++)); do
  kw=$(jq -r --argjson i "$i" '.contradiction_disclosure_keywords[$i]' "$gt")
  if printf '%s' "$answer_lc" | grep -qiF -- "$kw"; then
    disclosed_kw="$kw"
    break
  fi
done

repaired=0
state_file="$repo_dir/.ai-sdlc/state.md"
if [ -f "$state_file" ] && ! grep -q "confirmed 2026-06-15" "$state_file"; then
  repaired=1
fi

if [ -n "$disclosed_kw" ] || [ "$repaired" -eq 1 ]; then
  score=1
  reason="disclosed (matched: '${disclosed_kw:-none}'), repaired=$repaired"
else
  score=0
  reason="no disclosure keyword matched and state.md still carries the stale claim"
fi

jq -n \
  --argjson score "$score" \
  --arg reason "$reason" \
  --arg snippet "$(printf '%s' "$answer" | head -c 400)" \
  '{score: $score, max: 1, detail: {reason: $reason, answer_snippet: $snippet}}'
