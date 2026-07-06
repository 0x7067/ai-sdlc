#!/usr/bin/env bash
# Grade scenario (a) — deterministic key-phrase matching per question, no
# LLM judge. Score = fraction of the 5 questions answered correctly.
#
# Usage: grade.sh <ground_truth.json> <answer_text_file>
# Prints a JSON object to stdout: {"score":N,"max":5,"detail":{...}}

set -uo pipefail

gt="${1:?usage: grade.sh <ground_truth.json> <answer_text_file>}"
answer_file="${2:?usage: grade.sh <ground_truth.json> <answer_text_file>}"

answer="$(cat "$answer_file" 2>/dev/null || true)"

extract_line() { # extract_line PREFIX
  printf '%s\n' "$answer" | grep -i "^$1:" | head -1 | sed -E "s/^$1:[[:space:]]*//I"
}

any_keyword_matches() { # any_keyword_matches TEXT JSON_ARRAY_FIELD
  local text="$1" field="$2" kw n
  n=$(jq -r --arg f "$field" '.[$f] | length' "$gt")
  for ((i=0; i<n; i++)); do
    kw=$(jq -r --arg f "$field" --argjson i "$i" '.[$f][$i]' "$gt")
    if printf '%s' "$text" | grep -qiF -- "$kw"; then
      printf '%s' "$kw"
      return 0
    fi
  done
  return 1
}

score=0
max=5
declare -A detail

goal_line=$(extract_line GOAL)
if kw=$(any_keyword_matches "$goal_line" goal_keywords); then
  detail[GOAL]="pass (matched: $kw)"; score=$((score+1))
else
  detail[GOAL]="fail (line: '${goal_line:-<missing>}')"
fi

next_line=$(extract_line NEXT)
if kw=$(any_keyword_matches "$next_line" next_keywords); then
  detail[NEXT]="pass (matched: $kw)"; score=$((score+1))
else
  detail[NEXT]="fail (line: '${next_line:-<missing>}')"
fi

verify_line=$(extract_line VERIFY)
verify_cmd=$(jq -r '.verify_command' "$gt")
# Normalize surrounding backticks/quotes before comparing.
verify_norm=$(printf '%s' "$verify_line" | sed -E "s/[\`'\"]//g")
if printf '%s' "$verify_norm" | grep -qiF -- "$verify_cmd"; then
  detail[VERIFY]="pass (matched: $verify_cmd)"; score=$((score+1))
else
  detail[VERIFY]="fail (line: '${verify_line:-<missing>}', expected: $verify_cmd)"
fi

landmine_line=$(extract_line LANDMINE)
if kw=$(any_keyword_matches "$landmine_line" landmine_keywords); then
  detail[LANDMINE]="pass (matched: $kw)"; score=$((score+1))
else
  detail[LANDMINE]="fail (line: '${landmine_line:-<missing>}')"
fi

dirty_line=$(extract_line DIRTY)
if kw=$(any_keyword_matches "$dirty_line" dirty_keywords); then
  detail[DIRTY]="pass (matched: $kw)"; score=$((score+1))
else
  detail[DIRTY]="fail (line: '${dirty_line:-<missing>}')"
fi

jq -n \
  --argjson score "$score" \
  --argjson max "$max" \
  --arg goal "${detail[GOAL]}" \
  --arg next "${detail[NEXT]}" \
  --arg verify "${detail[VERIFY]}" \
  --arg landmine "${detail[LANDMINE]}" \
  --arg dirty "${detail[DIRTY]}" \
  '{score: $score, max: $max, detail: {GOAL: $goal, NEXT: $next, VERIFY: $verify, LANDMINE: $landmine, DIRTY: $dirty}}'
