#!/usr/bin/env bash
# evals/tier0 — deterministic regression suite for the ai-sdlc harness.
#
# Runs every check in checks/*.sh (each a self-contained script that prints
# one "STATUS  id  message" line per assertion, STATUS one of PASS/FAIL/WARN,
# and always exits 0 itself so one failed assertion doesn't stop the rest of
# that script's assertions from running). This driver aggregates all FAIL
# lines, reconciles them against evals/tier0/KNOWN-DRIFT, and is the only
# place that decides the suite's exit code.
#
# Usage:
#   bash evals/tier0/run.sh              run the suite against this repo
#   REPO_ROOT=/path bash evals/tier0/run.sh
#                                         run the suite against a different
#                                         checkout (used by --self-test to
#                                         point checks at a mutated sandbox)
#   bash evals/tier0/run.sh --self-test   seed deliberate regressions into a
#                                         mktemp sandbox copy and assert this
#                                         suite catches every one of them
#
# Exit 0 iff every FAIL is either absent, or listed in KNOWN-DRIFT (and every
# KNOWN-DRIFT entry DID fail this run — a listed entry that unexpectedly
# passes is a stale allowlist, and also fails the run).

set -uo pipefail

TIER0_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KNOWN_DRIFT_FILE="$TIER0_DIR/KNOWN-DRIFT"

if [ "${1:-}" = "--self-test" ]; then
  exec bash "$TIER0_DIR/selftest/run-selftest.sh"
fi

# --- collect --------------------------------------------------------------

results=$(mktemp)
trap 'rm -f "$results"' EXIT

any_script_crashed=0
for check in "$TIER0_DIR"/checks/*.sh; do
  name=$(basename "$check")
  out=$(bash "$check" 2>&1)
  code=$?
  if [ "$code" -ne 0 ]; then
    any_script_crashed=1
    printf 'FAIL  run.crashed.%s  check script exited %s unexpectedly (should always exit 0 and report via PASS/FAIL lines) — output follows:\n%s\n' \
      "${name%.sh}" "$code" "$out" >> "$results"
  else
    printf '%s\n' "$out" >> "$results"
  fi
done

fail_lines=$(grep -E '^FAIL' "$results" || true)
warn_lines=$(grep -E '^WARN' "$results" || true)
pass_count=$(grep -cE '^PASS' "$results" || true)

# fail id -> first whitespace-delimited token after the status
fail_ids=$(printf '%s\n' "$fail_lines" | awk '$1=="FAIL"{print $2}' | sort -u)

# --- reconcile against KNOWN-DRIFT ----------------------------------------

known_ids=""
if [ -f "$KNOWN_DRIFT_FILE" ]; then
  known_ids=$(grep -Ev '^\s*(#|$)' "$KNOWN_DRIFT_FILE" | awk '{print $1}' | sort -u)
fi

unexpected_fail_ids=""
expected_fail_ids=""
if [ -n "$fail_ids" ]; then
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    if printf '%s\n' "$known_ids" | grep -qxF -- "$id"; then
      expected_fail_ids="$expected_fail_ids
$id"
    else
      unexpected_fail_ids="$unexpected_fail_ids
$id"
    fi
  done <<< "$fail_ids"
fi

stale_drift_ids=""
if [ -n "$known_ids" ]; then
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    if ! printf '%s\n' "$fail_ids" | grep -qxF -- "$id"; then
      stale_drift_ids="$stale_drift_ids
$id"
    fi
  done <<< "$known_ids"
fi

# --- report ----------------------------------------------------------------

echo "== evals/tier0 =========================================================="
echo "PASS: $pass_count"
if [ -n "$warn_lines" ]; then
  echo
  echo "-- warnings (advisory, do not block) --"
  printf '%s\n' "$warn_lines"
fi

if [ -n "$expected_fail_ids" ]; then
  echo
  echo "-- KNOWN-DRIFT (expected failures — real findings, see evals/tier0/KNOWN-DRIFT) --"
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    printf '%s\n' "$fail_lines" | grep -F -- " $id " | sed 's/^FAIL/DRIFT/'
    grep -E "^$id[[:space:]]" "$KNOWN_DRIFT_FILE" | sed 's/^/    justification: /'
  done <<< "$(printf '%s\n' "$expected_fail_ids" | sed '/^$/d')"
fi

exit_code=0

if [ -n "$unexpected_fail_ids" ]; then
  echo
  echo "-- UNEXPECTED FAILURES (not in KNOWN-DRIFT) --"
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    printf '%s\n' "$fail_lines" | grep -F -- " $id "
  done <<< "$(printf '%s\n' "$unexpected_fail_ids" | sed '/^$/d')"
  exit_code=1
fi

if [ -n "$stale_drift_ids" ]; then
  echo
  echo "-- STALE KNOWN-DRIFT ENTRIES (listed as drift but did NOT fail this run) --"
  printf '%s\n' "$stale_drift_ids" | sed '/^$/d' | while IFS= read -r id; do
    echo "  $id — remove this line from evals/tier0/KNOWN-DRIFT (the underlying issue appears fixed) or investigate why it silently stopped firing"
  done
  exit_code=1
fi

if [ "$any_script_crashed" -ne 0 ]; then
  exit_code=1
fi

echo
if [ "$exit_code" -eq 0 ]; then
  echo "tier0: OK ($pass_count assertions passed$([ -n "$expected_fail_ids" ] && echo ", $(printf '%s\n' "$expected_fail_ids" | sed '/^$/d' | wc -l | tr -d ' ') known-drift finding(s) — see above"))"
else
  echo "tier0: FAILED"
fi

exit "$exit_code"
