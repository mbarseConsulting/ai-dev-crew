#!/usr/bin/env bash
# crew-doctor.sh — structural check of the ai-dev-crew library.
#
# Read-only. Checks what a reader cannot see at a glance and what breaks
# silently in paste mode:
#   1. every skill's frontmatter name matches its directory
#   2. every path a skill cites (agents/, references/, modes/, templates/)
#      exists relative to that skill's own directory
#   3. every techno has a row in crew's detection table, every role agent a flag
#   4. every crew reference is reachable from SKILL.md, an agent, or a techno
#   5. no skill names another skill (ADR 0016)
#   6. every launchable shell in .claude/agents/ preloads existing skills,
#      cites no .claude/skills/ path, and has its agent in crew/agents/
#   7. no stale vocabulary from earlier layouts survives in the library
#
# Exit status: 0 when every check passes, 1 otherwise.
set -euo pipefail

usage() {
  sed -n '2,16p' "$0" | sed 's/^# \{0,1\}//'
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS="$ROOT/.claude/skills"
AGENTS="$ROOT/.claude/agents"
errors=0

fail() {
  printf '  ✗ %s\n' "$1"
  errors=$((errors + 1))
}

section() {
  printf '\n%s\n' "$1"
}

skill_names() {
  for d in "$SKILLS"/*/; do basename "$d"; done
}

section "1. Skill names match their directory"
for d in "$SKILLS"/*/; do
  s="$(basename "$d")"
  name="$(sed -n 's/^name: *//p' "$d/SKILL.md" | head -1)"
  [ "$name" = "$s" ] || fail "$s/SKILL.md declares name '$name'"
done

section "2. Cited paths exist relative to their skill"
for d in "$SKILLS"/*/; do
  s="$(basename "$d")"
  grep -rhoE '(agents|references|modes|templates)/[A-Za-z0-9._-]+\.md' "$d" 2>/dev/null | sort -u |
    while read -r path; do
      case "$path" in
        *'{'*|*'<'*) continue ;;
      esac
      [ -f "$d/$path" ] || echo "$s: $path"
    done || true
done > "${TMPDIR:-/tmp}/crew-doctor.$$"
while read -r line; do fail "dead path — $line"; done < "${TMPDIR:-/tmp}/crew-doctor.$$"
rm -f "${TMPDIR:-/tmp}/crew-doctor.$$"

CREW="$SKILLS/crew"
if [ -d "$CREW" ]; then
  section "3. Every techno has a detection row, every role agent a flag"
  for p in "$CREW"/technos/*.md; do
    rel="technos/$(basename "$p")"
    grep -q "| \`$rel\` |" "$CREW/SKILL.md" || fail "no detection row for $rel"
  done
  for p in "$CREW"/agents/*.md; do
    rel="agents/$(basename "$p")"
    grep -q "| \`$rel\` |" "$CREW/SKILL.md" || fail "no flag for $rel"
  done

  section "4. Every reference is reachable"
  for r in "$CREW"/references/*.md; do
    rel="references/$(basename "$r")"
    grep -rqF "$rel" "$CREW/SKILL.md" "$CREW/agents" "$CREW/technos" || fail "unreachable $rel"
  done
fi

section "5. No skill names another skill"
for d in "$SKILLS"/*/; do
  s="$(basename "$d")"
  for other in $(skill_names); do
    [ "$other" = "$s" ] && continue
    # a skill name as a whole token: not glued to a letter, digit or hyphen
    if grep -rnE "(^|[^A-Za-z0-9-])$other([^A-Za-z0-9-]|$)" "$d" >/dev/null 2>&1; then
      grep -rnE "(^|[^A-Za-z0-9-])$other([^A-Za-z0-9-]|$)" "$d" | head -3 |
        while read -r hit; do echo "$s names $other — ${hit#$d}"; done || true
    fi
  done
done > "${TMPDIR:-/tmp}/crew-doctor.$$"
while read -r line; do fail "$line"; done < "${TMPDIR:-/tmp}/crew-doctor.$$"
rm -f "${TMPDIR:-/tmp}/crew-doctor.$$"

section "6. Agents preload existing skills and cite no repository path"
for a in "$AGENTS"/*.md; do
  n="$(basename "$a" .md)"
  sed -n '/^skills:/,/^[a-z]*:/p' "$a" | sed -n 's/^ *- *//p' |
    while read -r sk; do
      [ -f "$SKILLS/$sk/SKILL.md" ] || echo "$n preloads missing skill '$sk'"
    done || true
  if grep -q '\.claude/skills/' "$a"; then echo "$n cites a .claude/skills/ path"; fi
  [ -f "$CREW/agents/$n.md" ] || echo "$n has no agent at crew/agents/$n.md"
done > "${TMPDIR:-/tmp}/crew-doctor.$$" || true
while read -r line; do fail "$line"; done < "${TMPDIR:-/tmp}/crew-doctor.$$"
rm -f "${TMPDIR:-/tmp}/crew-doctor.$$"

section "7. No stale vocabulary"
STALE='modes/|agent-crew-|persona|dev-loop|test-craft|[a-z]+-craft\b|best-practices\.md|house-rules\.md|project-profile|profil projet|independent test pass|development loop|formal review gate'
if grep -rnE "$STALE" "$ROOT/.claude" >/dev/null 2>&1; then
  while read -r hit; do fail "stale — ${hit#$ROOT/}"; done < <(grep -rnE "$STALE" "$ROOT/.claude")
fi

printf '\n'
if [ "$errors" -eq 0 ]; then
  echo "crew-doctor: all checks passed"
  exit 0
fi
echo "crew-doctor: $errors error(s)"
exit 1
