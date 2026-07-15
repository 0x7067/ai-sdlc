#!/usr/bin/env bash
# Scenario (a) — resumption fidelity.
#
# Materializes a fixture git repo whose .ai-sdlc/state.md was "written by a
# previous session": a specific goal, a named next step, an exact
# verification command, one landmine, and a dirty tree with a stated
# reason. Writes ground_truth.json alongside it for grade.sh.
#
# Two hardening passes over the original single-fixture version:
#
#   1. VARIANT POOL — three complete, coherent fixture variants (different
#      project, files, functions, next step, landmine, dirty reason, verify
#      command, ground truth) selected via lib/common.sh's `tier1_variant`.
#      Variant 0 is the canonical csv2json fixture the dry_run/ canned
#      transcripts are graded against — its ground truth is byte-identical
#      to the original single-fixture version, so those canned transcripts
#      still score control=1/5, sdlc=5/5.
#
#   2. DIFFICULTY — every variant (including 0) gets distractor content
#      that misleads a model which treats *any* plausible-looking file as
#      authoritative instead of deferring to .ai-sdlc/state.md: a stale
#      TODO.md (an already-done step posing as next, a wrong verify
#      command, an unrelated fake gotcha) and a README "Roadmap" section
#      naming a different future feature than state.md's Next. Keyword
#      hygiene is load-bearing here: within a variant, none of the
#      distractor files may contain any next/landmine/dirty keyword or the
#      verify command string — otherwise a distractor-derived answer could
#      accidentally score points it shouldn't. (GOAL is exempt: it's the
#      easy question, distractors are allowed to also mention the project
#      by name.)
#
# Usage: generate.sh <workdir>
#   Creates <workdir>/repo (git fixture) and <workdir>/ground_truth.json.
# Env: TIER1_SEED selects the variant — see lib/common.sh's tier1_variant().

set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "$HERE/../../lib/common.sh"

workdir="${1:?usage: generate.sh <workdir>}"
repo="$workdir/repo"

git_init_repo "$repo"

variant_idx="$(tier1_variant 3)"

# --- variant pool -----------------------------------------------------------
#
# Each branch sets a coherent bundle of scalars (project/file/function
# names, the verify command, keyword lists) plus a handful of larger prose
# blocks (state.md sections, journal entry, source file bodies, TODO.md,
# README roadmap) captured into variables via quoted heredocs (`<<'TAG'`)
# so backticks/`$`/quotes in markdown and Python bodies need no escaping.
# Shared code below (after the case) turns these variables into files —
# identically for every variant.
case "$variant_idx" in
  0)
    # csv2json — canonical fixture; ground truth matches the original
    # single-fixture version exactly (dry_run/ canned transcripts depend
    # on this).
    proj_name="csv2json"
    src_file="csv2json.py"
    func_core="convert"
    verify_file="verify.sh"
    fixture_file="sample.csv"
    # No trailing newline after the last row — deliberate, matches the
    # landmine documented in state.md below. ANSI-C quoting (not a
    # heredoc) so the variable truly holds no trailing newline.
    fixture_content=$'name,qty\nwidget,3\ngadget,7'
    readme_tagline="A small CLI that converts CSV files to JSON."

    goal_keywords_json='["csv2json", "csv", "json"]'
    next_keywords_json='["--pretty", "pretty", "indent"]'
    landmine_keywords_json='["sample.csv", "trailing newline", "no trailing", "DictReader", "line-based"]'
    dirty_keywords_json='["--pretty", "pretty", "WIP", "uncommitted", "wip"]'

    src_initial="$(cat <<'SRCI_EOF'
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
SRCI_EOF
)"

    src_dirty="$(cat <<'SRCD_EOF'
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
SRCD_EOF
)"

    state_md_head="$(cat <<'SMH_EOF'
## Goal
Ship `csv2json`, a small pip-installable CLI that converts CSV files to
JSON arrays of objects. Correctness and a tiny, dependency-free footprint
matter more than feature breadth.

## Now
Core conversion (`csv2json.py convert`) works and is tested against
`tests/fixtures/sample.csv`. Mid-way through adding a `--pretty` flag
for indented JSON output: `csv2json.py` has a WIP uncommitted edit that
starts the argument parsing for `--pretty` but does not wire it to the
JSON writer yet — expected, not a mistake, don't revert it.

## Verification path
- `bash verify.sh` — passes, confirms `convert`/`main` are present and
  named the way the CLI wiring expects.

## Decisions
- No third-party dependencies (stdlib `csv`/`json` only) — keeps the
  tool installable with zero setup.

## Landmines
- `tests/fixtures/sample.csv` intentionally has no trailing newline after
  the last row; a naive line-based parser miscounts rows there even though
  `csv.DictReader` handles it fine — don't "fix" the fixture file.
SMH_EOF
)"

    state_md_next="$(cat <<'SMN_EOF'
## Next
1. Finish the `--pretty` flag: wire the already-started argument parsing
   in `csv2json.py` to `json.dumps(..., indent=2)` when `--pretty` is
   passed, then re-run `bash verify.sh`.
SMN_EOF
)"

    journal_body="$(cat <<'JRN_EOF'
# Journal

## 2026-06-28 — started --pretty flag
- Did: sketched argument parsing for --pretty in csv2json.py; not wired to
  the JSON writer yet.
- Verified: bash verify.sh -> "verify: OK".
- Learned: nothing new.
- Left: wire --pretty through json.dumps(indent=2); tree is intentionally
  left dirty with the WIP edit.
JRN_EOF
)"

    # TODO.md: stale distractor. "Implement conversion" is already done
    # (convert() exists and works) but is posed as the next step; the
    # verify command is plausible-but-wrong; the gotcha is unrelated to
    # the real (sample.csv trailing-newline) landmine. None of these lines
    # may contain a next/landmine/dirty keyword or "bash verify.sh" — see
    # the grep check in the task brief's verification step.
    todo_body="$(cat <<'TODO_EOF'
# TODO

- [ ] Implement CSV parsing into JSON objects (see csv2json.py convert())
- [ ] Decide on a JSON schema validator before the 1.0 release

## Testing
Run the test suite:

    python3 -m pytest tests/

## Gotchas
- Watch for locale-dependent CSV delimiters on some systems (comma vs
  semicolon) — not handled yet.
TODO_EOF
)"

    roadmap_bullets="$(cat <<'RMB_EOF'
- Add a --delimiter flag to support semicolon- or tab-separated input files.
- Publish the tool to PyPI once the CLI surface stabilizes.
RMB_EOF
)"
    ;;

  1)
    # wordfreq — counts word frequency in a text file, prints JSON counts.
    proj_name="wordfreq"
    src_file="wordfreq.py"
    func_core="tokenize"
    verify_file="check.sh"
    fixture_file="sample.txt"
    # CRLF line endings — deliberate, matches the landmine documented in
    # state.md below.
    fixture_content=$'The quick brown fox jumps over the lazy dog.\r\nThe dog barks back at the fox loudly.\r\nFoxes and dogs rarely agree.\r\n'
    readme_tagline="A small CLI that counts word frequency in a text file and prints JSON counts."

    goal_keywords_json='["wordfreq", "word frequency", "word count"]'
    next_keywords_json='["--min-count", "min-count", "threshold"]'
    landmine_keywords_json='["sample.txt", "CRLF", "carriage return", "line ending"]'
    dirty_keywords_json='["--min-count", "min-count", "WIP", "uncommitted", "wip"]'

    src_initial="$(cat <<'SRCI_EOF'
#!/usr/bin/env python3
"""Count word frequency in a text file and print JSON counts."""
import collections
import json
import re
import sys


def tokenize(path):
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    return re.findall(r"[A-Za-z']+", text.lower())


def main(argv):
    if len(argv) != 2:
        print("usage: wordfreq.py FILE.txt", file=sys.stderr)
        return 2
    counts = collections.Counter(tokenize(argv[1]))
    print(json.dumps(counts))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
SRCI_EOF
)"

    src_dirty="$(cat <<'SRCD_EOF'
#!/usr/bin/env python3
"""Count word frequency in a text file and print JSON counts."""
import collections
import json
import re
import sys


def tokenize(path):
    with open(path, encoding="utf-8") as fh:
        text = fh.read()
    return re.findall(r"[A-Za-z']+", text.lower())


def main(argv):
    # WIP: --min-count N flag, not wired to the output filtering yet.
    min_count = None
    if "--min-count" in argv:
        idx = argv.index("--min-count")
        min_count = int(argv[idx + 1])
    if len(argv) != 2:
        print("usage: wordfreq.py FILE.txt", file=sys.stderr)
        return 2
    counts = collections.Counter(tokenize(argv[1]))
    print(json.dumps(counts))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
SRCD_EOF
)"

    state_md_head="$(cat <<'SMH_EOF'
## Goal
Ship `wordfreq`, a small pip-installable CLI that counts word frequency in
a text file and prints JSON counts. Correctness and a tiny,
dependency-free footprint matter more than feature breadth.

## Now
Core counting (`wordfreq.py tokenize`/`main`) works and is tested against
`tests/fixtures/sample.txt`. Mid-way through adding a `--min-count` flag
to only show words at or above a frequency threshold: `wordfreq.py` has a
WIP uncommitted edit that starts the argument parsing for `--min-count`
but does not wire it to the output filtering yet — expected, not a
mistake, don't revert it.

## Verification path
- `bash check.sh` — passes, confirms `tokenize`/`main` are present and
  named the way the CLI wiring expects.

## Decisions
- No third-party dependencies (stdlib `collections`/`json`/`re` only) —
  keeps the tool installable with zero setup.

## Landmines
- `tests/fixtures/sample.txt` intentionally uses CRLF line endings;
  `tokenize()`'s regex already strips the carriage return since it only
  matches letters, but a naive `.split("\n")` would leave a stray `\r`
  attached to the last word of each line — don't "fix" the fixture's
  line endings.
SMH_EOF
)"

    state_md_next="$(cat <<'SMN_EOF'
## Next
1. Finish the `--min-count` flag: wire the already-started argument
   parsing in `wordfreq.py` to filter the `Counter` output by a frequency
   threshold when `--min-count` is passed, then re-run `bash check.sh`.
SMN_EOF
)"

    journal_body="$(cat <<'JRN_EOF'
# Journal

## 2026-06-28 — started --min-count flag
- Did: sketched argument parsing for --min-count in wordfreq.py; not
  wired to the output filtering yet.
- Verified: bash check.sh -> "verify: OK".
- Learned: nothing new.
- Left: wire --min-count through the Counter output filter; tree is
  intentionally left dirty with the WIP edit.
JRN_EOF
)"

    todo_body="$(cat <<'TODO_EOF'
# TODO

- [ ] Implement word counting from a text file (see wordfreq.py tokenize())
- [ ] Consider a stopword list before the 1.0 release

## Testing
Run the test suite:

    python3 -m unittest discover -s tests

## Gotchas
- Large files may be slow since everything loads into memory at once —
  fine for now, not a blocker.
TODO_EOF
)"

    roadmap_bullets="$(cat <<'RMB_EOF'
- Add a --stopwords FILE flag to exclude common filler words from the counts.
- Support reading from stdin for pipeline use.
RMB_EOF
)"
    ;;

  2)
    # slugify — turns page titles into URL-safe slugs, prints JSON.
    proj_name="slugify"
    src_file="slugify.py"
    func_core="make_slug"
    verify_file="run_checks.sh"
    fixture_file="titles.txt"
    # A blank line in the middle — deliberate, matches the landmine
    # documented in state.md below.
    fixture_content=$'Getting Started\nAdvanced Usage\n\nAPI Reference\nFAQ\n'
    readme_tagline="A small CLI that turns page titles into URL-safe slugs and prints JSON."

    goal_keywords_json='["slugify", "slug", "titles"]'
    next_keywords_json='["--max-length", "max-length", "truncate"]'
    landmine_keywords_json='["titles.txt", "blank line", "empty title", "empty slug"]'
    dirty_keywords_json='["--max-length", "max-length", "WIP", "uncommitted", "wip"]'

    src_initial="$(cat <<'SRCI_EOF'
#!/usr/bin/env python3
"""Turn page titles into URL-safe slugs and print JSON."""
import json
import re
import sys
import unicodedata


def make_slug(title):
    normalized = unicodedata.normalize("NFKD", title)
    ascii_only = normalized.encode("ascii", "ignore").decode("ascii")
    slug = re.sub(r"[^a-z0-9]+", "-", ascii_only.lower()).strip("-")
    return slug


def main(argv):
    if len(argv) != 2:
        print("usage: slugify.py FILE.txt", file=sys.stderr)
        return 2
    with open(argv[1], encoding="utf-8") as fh:
        titles = [line.rstrip("\n") for line in fh]
    print(json.dumps({title: make_slug(title) for title in titles}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
SRCI_EOF
)"

    src_dirty="$(cat <<'SRCD_EOF'
#!/usr/bin/env python3
"""Turn page titles into URL-safe slugs and print JSON."""
import json
import re
import sys
import unicodedata


def make_slug(title):
    normalized = unicodedata.normalize("NFKD", title)
    ascii_only = normalized.encode("ascii", "ignore").decode("ascii")
    slug = re.sub(r"[^a-z0-9]+", "-", ascii_only.lower()).strip("-")
    return slug


def main(argv):
    # WIP: --max-length N flag, not wired to the truncation logic yet.
    max_length = None
    if "--max-length" in argv:
        idx = argv.index("--max-length")
        max_length = int(argv[idx + 1])
    if len(argv) != 2:
        print("usage: slugify.py FILE.txt", file=sys.stderr)
        return 2
    with open(argv[1], encoding="utf-8") as fh:
        titles = [line.rstrip("\n") for line in fh]
    print(json.dumps({title: make_slug(title) for title in titles}))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
SRCD_EOF
)"

    state_md_head="$(cat <<'SMH_EOF'
## Goal
Ship `slugify`, a small pip-installable CLI that turns page titles into
URL-safe slugs and prints them as JSON. Correctness and a tiny,
dependency-free footprint matter more than feature breadth.

## Now
Core slug generation (`slugify.py make_slug`/`main`) works and is tested
against `tests/fixtures/titles.txt`. Mid-way through adding a
`--max-length` flag to truncate long slugs: `slugify.py` has a WIP
uncommitted edit that starts the argument parsing for `--max-length` but
does not wire it to the truncation logic yet — expected, not a mistake,
don't revert it.

## Verification path
- `bash run_checks.sh` — passes, confirms `make_slug`/`main` are present
  and named the way the CLI wiring expects.

## Decisions
- No third-party dependencies (stdlib `re`/`json`/`unicodedata` only) —
  keeps the tool installable with zero setup.

## Landmines
- `tests/fixtures/titles.txt` intentionally has a blank line in the
  middle; `make_slug("")` returning an empty slug on purpose guards
  against a regression where blank titles used to crash the tool — don't
  delete the blank line.
SMH_EOF
)"

    state_md_next="$(cat <<'SMN_EOF'
## Next
1. Finish the `--max-length` flag: wire the already-started argument
   parsing in `slugify.py` to truncate slugs longer than N characters
   when `--max-length` is passed, then re-run `bash run_checks.sh`.
SMN_EOF
)"

    journal_body="$(cat <<'JRN_EOF'
# Journal

## 2026-06-28 — started --max-length flag
- Did: sketched argument parsing for --max-length in slugify.py; not
  wired to the truncation logic yet.
- Verified: bash run_checks.sh -> "verify: OK".
- Learned: nothing new.
- Left: wire --max-length through the slug truncation step; tree is
  intentionally left dirty with the WIP edit.
JRN_EOF
)"

    todo_body="$(cat <<'TODO_EOF'
# TODO

- [ ] Implement slug generation from page titles (see slugify.py make_slug())
- [ ] Pick a persistent storage format before the 1.0 release

## Testing
Run the test suite:

    python3 -m pytest -k slug

## Gotchas
- Very long titles may hit filesystem path limits on some systems — not
  handled yet.
TODO_EOF
)"

    roadmap_bullets="$(cat <<'RMB_EOF'
- Support a custom separator character instead of the default hyphen.
- Add a --language flag for locale-aware slug transliteration.
RMB_EOF
)"
    ;;

  *)
    echo "generate.sh: unexpected variant index '$variant_idx' from tier1_variant" >&2
    exit 1
    ;;
esac

# --- shared fixture-writing code, parameterized by the variant's variables --

fixture_dir="tests/fixtures"
module_name="${src_file%.py}"
verify_cmd="bash $verify_file"

cat > "$repo/README.md" <<EOF
# $proj_name

$readme_tagline
EOF

printf '%s\n' "$src_initial" > "$repo/$src_file"

mkdir -p "$repo/$fixture_dir"
printf '%s' "$fixture_content" > "$repo/$fixture_dir/$fixture_file"

cat > "$repo/$verify_file" <<EOF
#!/usr/bin/env bash
# Verification path named in .ai-sdlc/state.md — deterministic, no deps
# beyond bash/grep so it runs the same on any machine that can run this
# fixture.
set -euo pipefail
grep -q "def $func_core" $src_file
grep -q "def main" $src_file
echo "verify: OK"
EOF
chmod +x "$repo/$verify_file"

mkdir -p "$repo/.ai-sdlc"

# The "History" digest section is tool-managed (compact-journal.sh) in the
# real harness; a prior session that ran compaction but never came back to
# fill in the freshly-folded digest bullet is itself a realistic landmine
# texture. Constructed at runtime — see sdlc_placeholder_token() docstring.
# This is the ONLY place the token is assembled, regardless of variant, so
# it never needs to be (and never is) spelled out inside any of the
# per-variant heredocs above.
placeholder="$(sdlc_placeholder_token)"

{
  echo "# Project State"
  echo "updated: 2026-06-28"
  echo
  printf '%s\n' "$state_md_head"
  echo
  echo "## History (digest through 2026-06-20)"
  echo "- ${placeholder}: compact-journal.sh folded the pre-2026-06-20 entries here"
  echo "  but the digest bullet was never written up — treat this as unresolved,"
  echo "  not as real project history."
  echo
  printf '%s\n' "$state_md_next"
} > "$repo/.ai-sdlc/state.md"

printf '%s\n' "$journal_body" > "$repo/.ai-sdlc/journal.md"

# --- difficulty: distractors that only mislead a model NOT treating
# .ai-sdlc/state.md as authoritative. Keyword hygiene is enforced by the
# per-variant content above (each variant's TODO/roadmap/extra-file text
# was written to avoid every next/landmine/dirty keyword and the verify
# command string for THAT variant) and re-checked mechanically in the
# task's verification step, not just by eyeballing it here.
printf '%s\n' "$todo_body" > "$repo/TODO.md"

cat >> "$repo/README.md" <<EOF

## Roadmap
$roadmap_bullets
EOF

cat > "$repo/bench.py" <<EOF
#!/usr/bin/env python3
"""Rough timing helper for local profiling — not part of the public CLI."""
import importlib
import time

start = time.time()
importlib.import_module("$module_name")
print(f"import time: {time.time() - start:.4f}s")
EOF

mkdir -p "$repo/bin"
cat > "$repo/bin/wrapper.sh" <<EOF
#!/usr/bin/env bash
# Convenience wrapper so contributors don't need to remember the module path.
set -euo pipefail
python3 "\$(dirname "\$0")/../$src_file" "\$@"
EOF
chmod +x "$repo/bin/wrapper.sh"

git_commit_all "$repo" "initial: $proj_name core + state.md"

# Leave the tree dirty with exactly the WIP edit state.md describes: an
# uncommitted, half-finished feature-flag argument-parsing edit. Plain
# overwrite (no sed -i) sidesteps BSD-vs-GNU -i syntax differences.
printf '%s\n' "$src_dirty" > "$repo/$src_file"

# --- ground truth ---------------------------------------------------------
cat > "$workdir/ground_truth.json" <<EOF
{
  "goal_keywords": $goal_keywords_json,
  "next_keywords": $next_keywords_json,
  "verify_command": "$verify_cmd",
  "landmine_keywords": $landmine_keywords_json,
  "dirty_keywords": $dirty_keywords_json
}
EOF

echo "$repo"
