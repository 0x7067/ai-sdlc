#!/usr/bin/env bash
# Deployment drift (advisory): the copies that actually run — ~/.claude/hooks/*
# and the live skills behind ~/.agents/skills — must match this repo's source,
# or a fix tested here silently doesn't run there, and a hand-patch applied
# there silently vanishes at the next deploy. WARN-only by design: this check
# reads machine state outside the repo, so it must not fail the suite on a
# machine laid out differently (CI, another workstation, fresh install).

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$HERE/../lib/common.sh"

for h in sdlc-lifecycle-gate sdlc-handoff-gate; do
  deployed="$HOME/.claude/hooks/$h"
  if [ ! -f "$deployed" ]; then
    warnrep "deploy.hook.$h" "no deployed copy at ~/.claude/hooks/$h — hook not installed on this machine (or different layout)"
  elif diff -q "$REPO_ROOT/hooks/$h" "$deployed" >/dev/null 2>&1; then
    pass "deploy.hook.$h" "deployed copy matches hooks/$h"
  else
    warnrep "deploy.hook.$h" "deployed ~/.claude/hooks/$h differs from hooks/$h — reconcile before trusting fixes landed here (port the delta into source, or redeploy via chezmoi)"
  fi
done

for s in sdlc-core sdlc-start sdlc-finish; do
  live="$HOME/.agents/skills/$s"
  if [ ! -e "$live" ]; then
    warnrep "deploy.skill.$s" "no live skill at ~/.agents/skills/$s on this machine"
  elif diff -rq "$REPO_ROOT/skills/$s" "$live" >/dev/null 2>&1; then
    pass "deploy.skill.$s" "live skill matches skills/$s"
  else
    warnrep "deploy.skill.$s" "live ~/.agents/skills/$s differs from skills/$s — the deployment clone has not pulled this repo's edits (or carries its own)"
  fi
done

exit 0
