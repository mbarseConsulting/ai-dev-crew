#!/usr/bin/env bash
# crew.sh — task-aware launcher for the ai-dev-crew agents.
#
# Asks what you need FIRST, then launches only the agent(s) that need — never
# launches "all agents" by default. Run from the client project root.
#
# This script only READS Claude Code's local plugin state to verify what is
# installed. It never writes to any settings or plugin state file: if a
# required plugin is missing, it tells you to run crew-doctor.sh and exits.
set -euo pipefail

MARKETPLACE_NAME="ai-dev-crew"
INSTALLED_PLUGINS_FILE="$HOME/.claude/plugins/installed_plugins.json"

usage() {
  cat <<'EOF'
Usage: crew.sh [--help]

Interactive launcher: asks what you need, verifies the required ai-dev-crew
plugin(s) are installed, then runs `claude "<kickoff prompt>"` for you.

Menu:
  0) Talk to the butler (default) — crew-core + crew-dev
  1) Front Angular feature         — crew-core + crew-dev + crew-front-angular + crew-critic
  2) Design / architecture         — crew-core
  3) Security audit                — crew-critic
  4) Parallel review (diff)        — crew-critic, agent-teams mode (critic x2, quality/security lenses)
  5) Full flow (design -> implement -> review) — crew-core + crew-dev + crew-critic
                                      (+ crew-tester's independent verification, when installed;
                                      + the matching techno plugin, flagged by agent-crew-dev if missing)
  6) Test verification (independent) — crew-tester

If a required plugin is missing, this script does NOT install it — it tells
you to run ./scripts/crew-doctor.sh for the exact remediation command, then
exits 1.
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

if ! command -v claude >/dev/null 2>&1; then
  echo "✗ claude CLI not found on PATH."
  echo "  → run ./scripts/crew-doctor.sh for the exact install command."
  exit 1
fi

plugin_installed() {
  local plugin_id="$1@$MARKETPLACE_NAME"
  [ -f "$INSTALLED_PLUGINS_FILE" ] || return 1
  if [ "$HAVE_JQ" = "1" ]; then
    jq -e --arg id "$plugin_id" '.plugins | has($id)' "$INSTALLED_PLUGINS_FILE" >/dev/null 2>&1
  else
    grep -q "\"$plugin_id\"" "$INSTALLED_PLUGINS_FILE"
  fi
}

# require_plugins <plugin> [<plugin> ...]
# Prints missing plugins and exits 1 if any are not installed.
require_plugins() {
  local missing=()
  for plugin in "$@"; do
    if ! plugin_installed "$plugin"; then
      missing+=("$plugin")
    fi
  done
  if [ "${#missing[@]}" -gt 0 ]; then
    echo ""
    echo "✗ Missing required plugin(s): ${missing[*]}"
    echo "  → run ./scripts/crew-doctor.sh for the exact 'claude plugin install' command(s)."
    exit 1
  fi
}

echo "ai-dev-crew — what do you need?"
echo ""
echo "  0) Talk to the butler (default)"
echo "  1) Front Angular feature"
echo "  2) Design / architecture"
echo "  3) Security audit"
echo "  4) Parallel review (diff)"
echo "  5) Full flow (design -> implement -> review)"
echo "  6) Test verification (independent)"
echo ""
read -rp "Choice [0-6] (default 0): " CHOICE
CHOICE="${CHOICE:-0}"

case "$CHOICE" in
  1)
    read -rp "Does this need an architecture decision first (new module boundary, new dependency, a real tradeoff)? [y/N] " NEED_ARCH
    ;;
  0 | 2 | 3 | 4 | 5 | 6) ;;
  *)
    echo "Invalid choice: $CHOICE"
    exit 1
    ;;
esac

read -rp "Describe the task in one line: " TASK_DESC
while [ -z "$TASK_DESC" ]; do
  read -rp "Task description can't be empty. Describe the task in one line: " TASK_DESC
done

AGENT_TEAMS=0
KICKOFF_PROMPT=""

case "$CHOICE" in
  0)
    require_plugins crew-core crew-dev
    KICKOFF_PROMPT="Use agent-crew-butler to help with: ${TASK_DESC}. Qualify what's actually needed before doing anything — work type, architecture decision, or both — then route to agent-crew-dev and/or agent-crew-critic accordingly, with a user gate between phases. If routing to agent-crew-critic turns out to be needed but that plugin isn't installed, say so instead of proceeding, and name the exact plugin to install."
    ;;
  1)
    # The critic gate is part of this flow's kickoff prompt (butler -> dev -> critic),
    # so crew-critic is required here even though it isn't a plugin dedicated to Angular.
    require_plugins crew-core crew-dev crew-front-angular crew-critic
    if [[ "$NEED_ARCH" =~ ^[Yy]$ ]]; then
      KICKOFF_PROMPT="Use agent-crew-butler to hold an architecture dialogue with me for: ${TASK_DESC}, using the architecture skill. Pause after the decision is recorded for my review before any implementation. Once I approve it, use agent-crew-dev (loading the angular-craft skill) to implement it. Once implementation is done, STOP and wait for my explicit approval before invoking agent-crew-critic — do not chain straight into the review. After I approve, use agent-crew-critic to run the quality and security gate."
    else
      KICKOFF_PROMPT="Use agent-crew-dev (loading the angular-craft skill) to implement: ${TASK_DESC}. Once implemented, STOP and wait for my explicit approval before invoking agent-crew-critic — do not chain straight into the review. After I approve, use agent-crew-critic to run the quality and security gate."
    fi
    ;;
  2)
    require_plugins crew-core
    KICKOFF_PROMPT="Use agent-crew-butler to hold an architecture dialogue with me for: ${TASK_DESC}, using the architecture skill, and record the decision as an ADR."
    ;;
  3)
    require_plugins crew-critic
    KICKOFF_PROMPT="Use agent-crew-critic with the security-review lens to audit: ${TASK_DESC}."
    ;;
  4)
    require_plugins crew-critic
    AGENT_TEAMS=1
    KICKOFF_PROMPT="Spawn agent-crew-critic twice as teammates to review this change together: ${TASK_DESC} — one instance using the code-quality lens only, the other using the security-review lens only. Have them challenge each other's findings before reconciling into one merged report."
    ;;
  5)
    require_plugins crew-core crew-dev crew-critic
    TESTER_PHASE=""
    if plugin_installed crew-tester; then
      TESTER_PHASE=" Once that sanity check passes, use agent-crew-tester to independently verify the change — the full test suite, not just what agent-crew-dev ran itself — then STOP and wait for my explicit approval before continuing to Phase 3."
    fi
    KICKOFF_PROMPT="Run the full crew workflow for: ${TASK_DESC}. Phase 1: use agent-crew-butler to hold an architecture dialogue with me and record the decision, then STOP and wait for my explicit approval before continuing — do not proceed automatically. Phase 2 (only after my approval): use agent-crew-dev, loading the matching craft skill(s) for the task's technology, to implement the approved design — if no matching craft skill/plugin is installed, it should flag that rather than guess. Once Phase 2 returns, use agent-crew-butler to run its light sanity check on the returned work (did tests actually run? was the design/ADR respected?), then STOP and wait for my explicit approval before continuing — do not chain straight into the review.${TESTER_PHASE} Phase 3 (only after my approval): use agent-crew-critic to run the quality and security gate on the diff, then STOP again and wait for my approval. Never chain any of these phases without asking me first — every phase boundary ends with a pause for my review."
    ;;
  6)
    require_plugins crew-tester
    KICKOFF_PROMPT="Use agent-crew-tester to independently verify: ${TASK_DESC} — decide unit-vs-e2e tier placement where relevant, design any missing scenarios, and run the full test suite rather than just a targeted subset."
    ;;
esac

echo ""
echo "Launching:"
echo "  $KICKOFF_PROMPT"
echo ""

if [ "$AGENT_TEAMS" = "1" ]; then
  CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude "$KICKOFF_PROMPT"
else
  claude "$KICKOFF_PROMPT"
fi
