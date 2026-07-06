#!/usr/bin/env bash
# Grade scenario (d) — sanity check only (did the trivial fix land).
# The overhead measurement itself (tokens/turns) is extracted by run.sh
# straight from the --output-format json result, not from here.
#
# Usage: grade.sh <ground_truth.json> <answer_text_file> <repo_dir>
# Prints: {"score":1|0,"max":1,"detail":{...},"note":"measurement scenario..."}

set -uo pipefail

gt="${1:?usage: grade.sh <ground_truth.json> <answer_text_file> <repo_dir>}"
answer_file="${2:?}"
repo_dir="${3:?}"

forbidden=$(jq -r '.forbidden_word' "$gt")
required=$(jq -r '.required_word' "$gt")

readme="$repo_dir/README.md"
score=0
reason="README.md missing"
if [ -f "$readme" ]; then
  if grep -qi -- "$forbidden" "$readme"; then
    reason="typo '$forbidden' still present in README.md"
    score=0
  elif grep -qi -- "$required" "$readme"; then
    reason="typo fixed: README.md now contains '$required', not '$forbidden'"
    score=1
  else
    reason="neither '$forbidden' nor '$required' found — unexpected edit"
    score=0
  fi
fi

jq -n \
  --argjson score "$score" \
  --arg reason "$reason" \
  --arg note "measurement scenario: score is a sanity check only, not the point — see run.sh's tokens/num_turns fields for the actual overhead comparison" \
  '{score: $score, max: 1, detail: {reason: $reason}, note: $note}'
