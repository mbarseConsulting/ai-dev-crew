# 0017 — The watch leaves `crew` for `crew-maintenance`; references are prefixed by nature

**Status:** accepted — 2026-09-14. Amends [ADR 0016](./0016-one-crew-skill-role-as-mode.md) (decisions 2 and 6) and [ADR 0010](./0010-watch-craft-maintenance-loop.md) (where the watch lives).

## Context

An audit of `crew` after ADR 0016 found four problems with one root: the skill mixed what travels to a client site with what only its maintainer needs, and techno files mixed framework rules with rules true everywhere.

- **`-w` could not run.** `references/watch.md` writes to `docs/watch/` and opens PRs; the butler that held it may write only to `docs/adr/` and `docs/design/`, has no `Edit` and no `WebFetch`. `docs/watch/` was empty while seven references showed a watch date.
- **The watch travelled to the client.** Copying `crew` to a site copied the feeds and the maintenance procedure with it.
- **Shared references were silently dropped.** The merge into `crew` lost the `layering`, `api-rest`, `kafka` and `ws` rows of the shared table; `crew-doctor` passed because a "Do NOT use" mention counted as reachable.
- **Technos carried rules that were not theirs.** "Flag an API contract change" sat in three technos and `agent-dev`; `technos/node-bff.md` held no Node rule at all — only the BFF pattern, true in any language; `persistence.md` sat among shared references while being JPA-only.

## Decision

**1. `crew-maintenance` is a separate skill, committed, never copied to a client.** Modes: `-d` runs `scripts/crew-doctor.sh` and repairs structure; `-w` runs the watch (`references/proc-watch.md`, `references/sources.md`). No agent: the main session has the tools. `crew` loses `-w`.

**2. `crew-maintenance` may name `crew` — the one exception to ADR 0016 decision 6.** The rule prevents dead links when a skill is used alone; this skill is never used alone. No skill may name `crew-maintenance`. `crew-doctor` enforces both directions.

**3. The folder says the nature, the prefix says the subject.** `technos/<techno>.md` holds a framework's rules, `technos/<techno>-<topic>.md` its references; `references/` holds only what every framework shares, prefixed `bp-` (practice), `dom-` (domain) or `proc-` (a role's procedure). `docs/doctrine.md` §2 is the one description of this layout.

**4. A techno repeats neither a shared rule nor an agent rule.** Duplicates were deleted; rules true everywhere moved to `references/bp-code.md`; the BFF pattern became `references/bp-bff.md`; `technos/node.md` is empty until Node-specific rules are written.

## Alternatives considered

- **Keep `-w` in the butler and widen its rights.** Rejected: breaks the butler's write scope (ADR 0004, 0007), and the watch still travels to the client.
- **Name no skill, address `crew` by a path pattern.** Rejected: it follows the letter of the rule while depending on `crew` all the same — a hidden dependency is worse than a declared one.
- **A `README.md` inside `crew` for the layout rules.** Rejected: only `SKILL.md` is loaded, it would travel to the client, and the layout was already described in three places.
- **Merge the watch into `crew-doctor.sh`.** Rejected: the doctor is deterministic and gates every commit; the watch is judgement, network and PRs.

## Consequences

- Skills: `crew`, `crew-project`, `crew-maintenance`. `crew` holds 12 references and 3 techno references.
- `crew-doctor` checks prefixes, that every shared reference is named in `SKILL.md`, that every techno reference is listed by its techno, and the manifest counts.
- A watch date is set only by a run that wrote a digest.
