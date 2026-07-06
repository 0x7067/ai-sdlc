#!/usr/bin/env bash
# Scenario (a) — resumption fidelity.
#
# Materializes a fixture git repo whose .ai-sdlc/state.md was "written by a
# previous session": a specific goal, a named next step, an exact
# verification command, one landmine, and a dirty tree with a stated
# reason. Writes ground_truth.json alongside it for grade.sh.
#
# Usage: generate.sh <workdir>
#   Creates <workdir>/repo (git fixture) and <workdir>/ground_truth.json.

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$HERE/../../lib/common.sh"

workdir="${1:?usage: generate.sh <workdir>}"
repo="$workdir/repo"

git_init_repo "$repo"

cat > "$repo/README.md" <<'EOF'
# csv2json

A small CLI that converts CSV files to JSON.
EOF

cat > "$repo/csv2json.py" <<'EOF'
#!/usr/bin/env python3
"""Convert a CSV file to a JSON array of objects."""
import csv
import json
import sys


def convert(path):
    with open(path, newline="") as fh:
        return list(csv.DictReader(fh))


def main(argv):
    if len(argv) != 2:
        print("usage: csv2json.py FILE.csv", file=sys.stderr)
        return 2
    rows = convert(argv[1])
    print(json.dumps(rows))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
EOF

mkdir -p "$repo/tests/fixtures"
# No trailing newline after the last row — deliberate, matches the landmine
# state.md documents below. printf (not a heredoc) so the file truly ends
# without one.
printf 'name,qty\nwidget,3\ngadget,7' > "$repo/tests/fixtures/sample.csv"

cat > "$repo/verify.sh" <<'EOF'
#!/usr/bin/env bash
# Verification path named in .ai-sdlc/state.md — deterministic, no deps
# beyond bash/grep so it runs the same on any machine that can run this
# fixture.
set -euo pipefail
grep -q "def convert" csv2json.py
grep -q "def main" csv2json.py
echo "verify: OK"
EOF
chmod +x "$repo/verify.sh"

mkdir -p "$repo/.ai-sdlc"

# The "History" digest section is tool-managed (compact-journal.sh) in the
# real harness; a prior session that ran compaction but never came back to
# fill in the freshly-folded digest bullet is itself a realistic landmine
# texture. Constructed at runtime — see sdlc_placeholder_token() docstring.
placeholder="$(sdlc_placeholder_token)"

cat > "$repo/.ai-sdlc/state.md" <<EOF
# Project State
updated: 2026-06-28

## Goal
Ship \`csv2json\`, a small pip-installable CLI that converts CSV files to
JSON arrays of objects. Correctness and a tiny, dependency-free footprint
matter more than feature breadth.

## Now
Core conversion (\`csv2json.py convert\`) works and is tested against
\`tests/fixtures/sample.csv\`. Mid-way through adding a \`--pretty\` flag
for indented JSON output: \`csv2json.py\` has a WIP uncommitted edit that
starts the argument parsing for \`--pretty\` but does not wire it to the
JSON writer yet — expected, not a mistake, don't revert it.

## Verification path
- \`bash verify.sh\` — passes, confirms \`convert\`/\`main\` are present and
  named the way the CLI wiring expects.

## Decisions
- No third-party dependencies (stdlib \`csv\`/\`json\` only) — keeps the
  tool installable with zero setup.

## Landmines
- \`tests/fixtures/sample.csv\` intentionally has no trailing newline after
  the last row; a naive line-based parser miscounts rows there even though
  \`csv.DictReader\` handles it fine — don't "fix" the fixture file.

## History (digest through 2026-06-20)
- ${placeholder}: compact-journal.sh folded the pre-2026-06-20 entries here
  but the digest bullet was never written up — treat this as unresolved,
  not as real project history.

## Next
1. Finish the \`--pretty\` flag: wire the already-started argument parsing
   in \`csv2json.py\` to \`json.dumps(..., indent=2)\` when \`--pretty\` is
   passed, then re-run \`bash verify.sh\`.
EOF

cat > "$repo/.ai-sdlc/journal.md" <<'EOF'
# Journal

## 2026-06-28 — started --pretty flag
- Did: sketched argument parsing for --pretty in csv2json.py; not wired to
  the JSON writer yet.
- Verified: bash verify.sh -> "verify: OK".
- Learned: nothing new.
- Left: wire --pretty through json.dumps(indent=2); tree is intentionally
  left dirty with the WIP edit.
EOF

git_commit_all "$repo" "initial: csv2json core + state.md"

# Leave the tree dirty with exactly the WIP edit state.md describes: an
# uncommitted, half-finished --pretty argument-parsing edit. Plain
# overwrite (no sed -i) sidesteps BSD-vs-GNU -i syntax differences.
cat > "$repo/csv2json.py" <<'EOF'
#!/usr/bin/env python3
"""Convert a CSV file to a JSON array of objects."""
import csv
import json
import sys


def convert(path):
    with open(path, newline="") as fh:
        return list(csv.DictReader(fh))


def main(argv):
    # WIP: --pretty flag, not wired to the writer yet.
    pretty = "--pretty" in argv
    if len(argv) != 2:
        print("usage: csv2json.py FILE.csv", file=sys.stderr)
        return 2
    rows = convert(argv[1])
    print(json.dumps(rows))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
EOF

# --- ground truth ---------------------------------------------------------
cat > "$workdir/ground_truth.json" <<EOF
{
  "goal_keywords": ["csv2json", "csv", "json"],
  "next_keywords": ["--pretty", "pretty", "indent"],
  "verify_command": "bash verify.sh",
  "landmine_keywords": ["sample.csv", "trailing newline", "no trailing", "DictReader", "line-based"],
  "dirty_keywords": ["--pretty", "pretty", "WIP", "uncommitted", "wip"]
}
EOF

echo "$repo"
