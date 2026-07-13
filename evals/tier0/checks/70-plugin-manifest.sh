#!/usr/bin/env bash
# Claude Code plugin packaging coherence: the manifests must stay valid and
# keep pointing at scripts that exist, or a plugin install silently ships a
# broken lifecycle (hooks that never fire are the exact failure the
# 2026-07-06 Goodhart audit found in prose form).

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../lib/common.sh
source "$HERE/../lib/common.sh"

PLUGIN_JSON="$REPO_ROOT/.claude-plugin/plugin.json"
MARKETPLACE_JSON="$REPO_ROOT/.claude-plugin/marketplace.json"
HOOKS_JSON="$REPO_ROOT/hooks/hooks.json"

if ! command -v jq >/dev/null 2>&1; then
  warnrep "plugin.jq-missing" "jq not on PATH — plugin manifest checks skipped"
  exit 0
fi

# --- P1: plugin.json parses and names the plugin -----------------------
if jq -e . "$PLUGIN_JSON" >/dev/null 2>&1; then
  pass "plugin.manifest.parses" ".claude-plugin/plugin.json is valid JSON"
else
  fail "plugin.manifest.parses" ".claude-plugin/plugin.json missing or invalid JSON"
fi
name=$(jq -r '.name // ""' "$PLUGIN_JSON" 2>/dev/null)
assert_eq "plugin.manifest.name" "$name" "ai-sdlc"

# --- P2: marketplace.json parses and lists the same plugin name --------
if jq -e . "$MARKETPLACE_JSON" >/dev/null 2>&1; then
  pass "plugin.marketplace.parses" ".claude-plugin/marketplace.json is valid JSON"
else
  fail "plugin.marketplace.parses" ".claude-plugin/marketplace.json missing or invalid JSON"
fi
mkt_name=$(jq -r '.plugins[0].name // ""' "$MARKETPLACE_JSON" 2>/dev/null)
assert_eq "plugin.marketplace.plugin-name" "$mkt_name" "$name"

# --- P3: hooks.json parses; every command resolves to an executable ----
if jq -e . "$HOOKS_JSON" >/dev/null 2>&1; then
  pass "plugin.hooks.parses" "hooks/hooks.json is valid JSON"
else
  fail "plugin.hooks.parses" "hooks/hooks.json missing or invalid JSON"
fi
for event in SessionStart Stop; do
  cmd=$(jq -r ".hooks.$event[0].hooks[0].command // \"\"" "$HOOKS_JSON" 2>/dev/null)
  if [ -z "$cmd" ]; then
    fail "plugin.hooks.$event" "no command registered for $event in hooks/hooks.json"
    continue
  fi
  # Resolve a direct ${CLAUDE_PLUGIN_ROOT} command first. Stop may use the
  # installed user hook before falling back to this plugin's copy; in that
  # case validate the fallback path shipped by the plugin.
  script=$(printf '%s' "$cmd" | sed -e 's/"//g' -e "s|\${CLAUDE_PLUGIN_ROOT}|$REPO_ROOT|")
  if [ ! -x "$script" ]; then
    plugin_relative=$(printf '%s' "$cmd" \
      | sed -nE 's|.*\$CLAUDE_PLUGIN_ROOT/(hooks/[^"; ]+).*|\1|p')
    [ -n "$plugin_relative" ] && script="$REPO_ROOT/$plugin_relative"
  fi
  if [ -x "$script" ]; then
    pass "plugin.hooks.$event" "$event -> $(basename "$script") exists and is executable"
  else
    fail "plugin.hooks.$event" "$event command '$cmd' does not resolve to an executable file"
  fi
done

# --- P4: the namespaced skill names the gate teaches actually exist ----
for skill in sdlc-start sdlc-finish; do
  if grep -qF "ai-sdlc:$skill" "$HOOK_LIFECYCLE"; then
    pass "plugin.namespace-hint.$skill" "lifecycle gate teaches the plugin-namespaced name ai-sdlc:$skill"
  else
    fail "plugin.namespace-hint.$skill" "plugin installs namespace skills as ai-sdlc:$skill but the lifecycle gate never mentions that form"
  fi
done
