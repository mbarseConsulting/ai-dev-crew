#!/usr/bin/env bash
# crew-doctor.sh — verify the ai-dev-crew marketplace and its plugins are usable
# from the current machine / project.
#
# This script only READS Claude Code's local state (~/.claude/plugins/*.json,
# ~/.claude/settings.json). It NEVER writes to any settings or plugin state
# file — for every failed check it prints the exact command to run yourself.
set -euo pipefail

MARKETPLACE_NAME="ai-dev-crew"
MARKETPLACE_PATH="$HOME/Projets/apps/ai-dev-crew"
REQUIRED_PLUGINS=(crew-core crew-dev crew-tester crew-critic crew-front-angular crew-back-java crew-back-python)
KNOWN_MARKETPLACES_FILE="$HOME/.claude/plugins/known_marketplaces.json"
INSTALLED_PLUGINS_FILE="$HOME/.claude/plugins/installed_plugins.json"
SETTINGS_FILE="$HOME/.claude/settings.json"

usage() {
  cat <<'EOF'
Usage: crew-doctor.sh [--help]

Checks that the ai-dev-crew marketplace and its plugins are installed and
usable, and prints the exact remediation command for anything missing.

Checks performed:
  - claude CLI present, and its version
  - ai-dev-crew marketplace known to Claude Code
  - which crew-* plugins are installed, and at what scope
  - CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS set (optional — only needed for
    crew.sh's parallel-review mode)
  - BMAD installed in the current project via a _bmad/ directory (optional)

This script is read-only: it never modifies any settings or plugin file.

Exit status:
  0  claude CLI is present AND the ai-dev-crew marketplace is registered
  1  one of those two required checks failed
EOF
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

HAVE_JQ=0
if command -v jq >/dev/null 2>&1; then
  HAVE_JQ=1
fi

USE_COLOR=0
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  USE_COLOR=1
fi

color() {
  # color <code> <text>
  if [ "$USE_COLOR" = "1" ]; then
    printf '\033[%sm%s\033[0m' "$1" "$2"
  else
    printf '%s' "$2"
  fi
}

REQUIRED_FAILS=0

ok() {
  echo "$(color '32' '✓') $1"
}

required_fail() {
  echo "$(color '31' '✗') $1"
  if [ -n "${2:-}" ]; then
    echo "    → $2"
  fi
  REQUIRED_FAILS=$((REQUIRED_FAILS + 1))
}

optional_fail() {
  echo "$(color '33' '✗') $1 $(color '33' '(optional)')"
  if [ -n "${2:-}" ]; then
    echo "    → $2"
  fi
}

echo "ai-dev-crew doctor"
echo "=================="
echo ""

# --- claude CLI present -----------------------------------------------------
if command -v claude >/dev/null 2>&1; then
  CLAUDE_VERSION="$(claude --version 2>/dev/null || echo 'unknown version')"
  ok "claude CLI present ($CLAUDE_VERSION)"
else
  required_fail "claude CLI not found on PATH" \
    "install it: curl -fsSL https://claude.ai/install.sh | bash   (macOS/Linux/WSL; see https://code.claude.com/docs/en/quickstart for Homebrew/WinGet/apt/dnf/apk)"
fi

# --- marketplace known -------------------------------------------------------
marketplace_known() {
  [ -f "$KNOWN_MARKETPLACES_FILE" ] || return 1
  if [ "$HAVE_JQ" = "1" ]; then
    jq -e --arg name "$MARKETPLACE_NAME" 'has($name)' "$KNOWN_MARKETPLACES_FILE" >/dev/null 2>&1
  else
    grep -q "\"$MARKETPLACE_NAME\"[[:space:]]*:" "$KNOWN_MARKETPLACES_FILE"
  fi
}

if marketplace_known; then
  ok "ai-dev-crew marketplace registered"
else
  required_fail "ai-dev-crew marketplace not registered" \
    "claude plugin marketplace add $MARKETPLACE_PATH"
fi

# --- installed plugins, with scope ------------------------------------------
echo ""
echo "Plugins:"

plugin_scopes() {
  # prints comma-separated scopes for "$1@$MARKETPLACE_NAME", empty if absent
  local plugin_id="$1@$MARKETPLACE_NAME"
  [ -f "$INSTALLED_PLUGINS_FILE" ] || return 0
  if [ "$HAVE_JQ" = "1" ]; then
    jq -r --arg id "$plugin_id" '.plugins[$id] // [] | map(.scope) | join(", ")' "$INSTALLED_PLUGINS_FILE" 2>/dev/null
  else
    if grep -q "\"$plugin_id\"" "$INSTALLED_PLUGINS_FILE"; then
      echo "installed (scope unknown — install jq for detail)"
    fi
  fi
}

for plugin in "${REQUIRED_PLUGINS[@]}"; do
  scopes="$(plugin_scopes "$plugin")"
  if [ -n "$scopes" ]; then
    ok "$plugin@$MARKETPLACE_NAME installed (scope: $scopes)"
  else
    optional_fail "$plugin@$MARKETPLACE_NAME not installed" \
      "claude plugin install $plugin@$MARKETPLACE_NAME"
  fi
done

echo ""
echo "Optional extras:"

# --- CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS -----------------------------------
agent_teams_enabled() {
  case "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-}" in
    1 | true | TRUE | True) return 0 ;;
  esac
  [ -f "$SETTINGS_FILE" ] || return 1
  if [ "$HAVE_JQ" = "1" ]; then
    local val
    val="$(jq -r '.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS // empty' "$SETTINGS_FILE" 2>/dev/null)"
    case "$val" in
      1 | true | TRUE | True) return 0 ;;
      *) return 1 ;;
    esac
  else
    grep -Eq '"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS"[[:space:]]*:[[:space:]]*"?(1|true)"?' "$SETTINGS_FILE"
  fi
}

if agent_teams_enabled; then
  ok "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS enabled"
else
  optional_fail "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS not set — needed only for parallel-review mode (crew.sh option 4)" \
    "export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1   (or add \"env\": {\"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS\": \"1\"} to ~/.claude/settings.json yourself)"
fi

# --- BMAD in current project -------------------------------------------------
if [ -d "_bmad" ]; then
  ok "BMAD installed in the current project (_bmad/ found)"
else
  optional_fail "BMAD not installed in the current project" \
    "npx bmad-method install   (run at the project root; interactive)"
fi

echo ""
echo "=================="
if [ "$REQUIRED_FAILS" -eq 0 ]; then
  echo "$(color '32' 'All required checks passed.')"
  exit 0
else
  echo "$(color '31' "$REQUIRED_FAILS required check(s) failed.")" "See the remediation commands above."
  exit 1
fi
