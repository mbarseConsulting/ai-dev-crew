#!/usr/bin/env bash
# crew-doctor.sh — structural check of the ai-dev-crew library.
#
# Read-only. Checks what a reader cannot see at a glance and what breaks
# silently in paste mode. The layout rules it enforces live in docs/doctrine.md.
#   1. every skill's frontmatter name matches its directory
#   2. every path a skill cites (agents/, references/, technos/, and
#      ../<skill>/… for crew-maintenance) exists relative to that skill
#   3. every techno (technos/<name>.md, no hyphen) has a detection row, every
#      techno reference (technos/<name>-<topic>.md) has its techno, every role
#      agent a flag
#   4. every crew reference is loaded: references/ files carry a known prefix
#      (bp-, dom-, proc-) and are named in SKILL.md; technos/<name>-*.md are
#      listed as "- `technos/<name>-<topic>.md`" in technos/<name>.md
#   5. no skill names another skill (ADR 0016) — except crew-maintenance,
#      which may name crew (ADR 0017)
#   6. every launchable shell in .claude/agents/ preloads existing skills,
#      cites no .claude/skills/ path, and has its agent in crew/agents/
#   7. no stale vocabulary from earlier layouts survives in the library
#   8. docs/skill-manifest.csv reference counts match the files
#
# Exit status: 0 when every check passes, 1 otherwise.
set -euo pipefail

usage() {
  sed -n '2,22p' "$0" | sed 's/^# \{0,1\}//'
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS="$ROOT/.claude/skills"
AGENTS="$ROOT/.claude/agents"
CREW="$SKILLS/crew"
TMP="${TMPDIR:-/tmp}/crew-doctor.$$"
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

# Replays the lines collected in $TMP as failures.
flush() {
  while read -r line; do fail "$line"; done < "$TMP"
  rm -f "$TMP"
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
  grep -rhoE '(\.\./[a-z-]+/)?(agents|references|technos)/[A-Za-z0-9._-]+\.md' "$d" 2>/dev/null | sort -u |
    while read -r path; do
      [ -f "$d/$path" ] || echo "dead path — $s: $path"
    done || true
done > "$TMP"
flush

if [ -d "$CREW" ]; then
  section "3. Technos, techno references and role agents are wired"
  for p in "$CREW"/technos/*.md; do
    base="$(basename "$p" .md)"
    case "$base" in
      *-*)
        owner="${base%%-*}"
        [ -f "$CREW/technos/$owner.md" ] || fail "technos/$base.md has no techno technos/$owner.md"
        ;;
      *)
        grep -q "| \`technos/$base.md\` |" "$CREW/SKILL.md" || fail "no detection row for technos/$base.md"
        ;;
    esac
  done
  for p in "$CREW"/agents/*.md; do
    rel="agents/$(basename "$p")"
    grep -q "| \`$rel\` |" "$CREW/SKILL.md" || fail "no flag for $rel"
  done

  section "4. Every reference is loaded"
  for r in "$CREW"/references/*.md; do
    base="$(basename "$r")"
    case "$base" in
      bp-*|dom-*|proc-*) ;;
      *) fail "references/$base has no known prefix (bp-, dom-, proc-)" ;;
    esac
    grep -qF "\`references/$base\`" "$CREW/SKILL.md" || fail "never loaded references/$base — not named in SKILL.md"
  done
  for p in "$CREW"/technos/*-*.md; do
    [ -f "$p" ] || continue
    base="$(basename "$p")"
    owner="${base%%-*}"
    [ -f "$CREW/technos/$owner.md" ] || continue
    grep -qxF -- "- \`technos/$base\`" "$CREW/technos/$owner.md" || fail "never loaded technos/$base — not listed in technos/$owner.md"
  done
fi

section "5. No skill names another skill"
for d in "$SKILLS"/*/; do
  s="$(basename "$d")"
  for other in $(skill_names); do
    [ "$other" = "$s" ] && continue
    [ "$s" = "crew-maintenance" ] && [ "$other" = "crew" ] && continue
    # a skill name as a whole token: not glued to a letter, digit or hyphen
    grep -rnE "(^|[^A-Za-z0-9-])$other([^A-Za-z0-9-]|$)" "$d" 2>/dev/null | head -3 |
      while read -r hit; do echo "$s names $other — ${hit#$d}"; done || true
  done
done > "$TMP"
flush

section "6. Agents preload existing skills and cite no repository path"
for a in "$AGENTS"/*.md; do
  n="$(basename "$a" .md)"
  sed -n '/^skills:/,/^[a-z]*:/p' "$a" | sed -n 's/^ *- *//p' |
    while read -r sk; do
      [ -f "$SKILLS/$sk/SKILL.md" ] || echo "$n preloads missing skill '$sk'"
    done || true
  if grep -q '\.claude/skills/' "$a"; then echo "$n cites a .claude/skills/ path"; fi
  [ -f "$CREW/agents/$n.md" ] || echo "$n has no agent at crew/agents/$n.md"
done > "$TMP" || true
flush

section "7. No stale vocabulary"
STALE='modes/|agent-crew-|persona|dev-loop|test-craft|[a-z]+-craft\b|best-practices\.md|house-rules\.md|project-profile|profil projet|independent test pass|development loop|formal review gate|technos/node-bff'
if grep -rnE "$STALE" "$SKILLS" "$AGENTS" >/dev/null 2>&1; then
  while read -r hit; do fail "stale — ${hit#$ROOT/}"; done < <(grep -rnE "$STALE" "$SKILLS" "$AGENTS")
fi
# crew's references before the bp-/dom-/proc- prefixes (ADR 0017)
OLD_REFS='references/(layering|api-rest|kafka|ws|conventions|iot|testfix|code-quality|security-review|architecture|java-spring|persistence|angular-patterns|node-bff|watch|sources)\.md'
if grep -rnE "$OLD_REFS" "$CREW" "$AGENTS" >/dev/null 2>&1; then
  while read -r hit; do fail "stale — ${hit#$ROOT/}"; done < <(grep -rnE "$OLD_REFS" "$CREW" "$AGENTS")
fi

MANIFEST="$ROOT/docs/skill-manifest.csv"
if [ -f "$MANIFEST" ] && [ -d "$CREW" ]; then
  section "8. Manifest reference counts match the files"
  while IFS=, read -r type name _ _ count; do
    case "$type" in
      skill) [ "$name" = crew ] || continue
             actual="$(find "$CREW/references" -name '*.md' | wc -l | tr -d ' ')" ;;
      techno) actual="$(grep -c '^- `technos/' "$CREW/technos/$name.md" || true)" ;;
      *) continue ;;
    esac
    [ "$count" = "$actual" ] || fail "manifest: $type $name declares $count references, files show $actual"
  done < "$MANIFEST"
fi

printf '\n'
if [ "$errors" -eq 0 ]; then
  echo "crew-doctor: all checks passed"
  exit 0
fi
echo "crew-doctor: $errors error(s)"
exit 1
