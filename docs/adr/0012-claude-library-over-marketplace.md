# 0012 — A flat `.claude/` library replaces the plugin marketplace

**Status:** accepted — 2026-09-14. Supersedes [ADR 0001](./0001-plugin-marketplace-format.md).

## Context

[ADR 0001](./0001-plugin-marketplace-format.md) packaged the crew as a Claude Code plugin marketplace so it could "install into any client project" via `/plugin marketplace add` and `/plugin install`, with one plugin per capability so "client projects install exactly what they need."

Both halves of that context turned out to be false in the only environment that matters:

- **No installation is possible.** The operator now works inside a high-security enterprise where plugins cannot be downloaded or installed. The library is consulted from a personal directory and pasted by hand.
- **No model choice is possible.** The imposed model is neither Claude nor selectable, which also removes the dispatch-time routing of [ADR 0009](./0009-model-routing.md) from that environment.
- **There is exactly one consumer.** No client ever installs anything, so per-plugin semver and selective installation — ADR 0001's two stated benefits, and its stated reason for rejecting a monolith — buy nothing.
- **The engagement is now a three-year position, not freelance rotation.** `docs/design/premise-freelance-vision.md`'s driver ("project-agnostic, trivially installable on a new project") no longer describes the work. Breadth across unknown codebases is worth little; depth in one stack, amortised over three years, is worth a great deal.

Measured cost of the packaging at the moment of this decision: 8 manifests (7 `plugin.json` + `marketplace.json`), a `plugins/crew-back-python/` directory holding exactly one file, and four levels of nesting to reach a checklist. The fragmentation looked modular while buying nothing: nobody installs "just Angular" — a full-stack engagement takes all of it or none.

Meanwhile [ADR 0008](./0008-skills-first-doctrine.md) had already declared solo mode first-class. The doctrine was right; the packaging contradicted it by binding the library to an install mechanism unavailable where the work happens.

## Decision

**Skills and agents live in `.claude/`, discovered without installation.**

- `.claude/skills/<name>/SKILL.md` — one directory per skill, discovered automatically by Claude Code, readable and pasteable by hand anywhere else.
- `.claude/agents/agent-crew-*.md` — the four agents, unchanged in content.
- No `plugin.json`, no `marketplace.json`, no `plugins/` directory.

**Two consumption modes, both first-class.**

1. *Harness mode* — Claude Code discovers the library automatically; symlinking into `~/.claude/` makes it available across projects.
2. *Paste mode* — no harness, no agents, an imposed model: the operator opens the relevant `SKILL.md` and pastes it. This is the mode the enterprise engagement runs in, and it is the constraint that governs file size (see [ADR 0013](./0013-craft-skill-taxonomy.md)).

**Paste mode changes what a cross-reference means.** [ADR 0008](./0008-skills-first-doctrine.md)'s "reference by name, never restate" assumes a harness able to load the named target. Pasted into a bare conversation, a pointer to an unavailable file is a dead link. The single-source-of-truth rule is unchanged; entry-point skills additionally declare at the top what must be pasted alongside them.

**Nothing is deleted on migration.** Everything removed moves to a gitignored `.attic/`, kept until the migration is validated.

## Alternatives considered

- **One monolithic plugin instead of seven.** Rejected: it reduces 8 manifests to 1 but preserves `plugins/<plugin>/skills/<skill>/SKILL.md` nesting and still requires an installation that is impossible at the client. It addresses the symptom the operator named, not the cause.
- **Keep a flat source and generate the plugin tree with a build script.** Rejected *for now*, not on principle: it keeps a distribution option alive that no one has asked for, at the price of a build step and a source/output drift risk. The asymmetry decides it — plugins can always be generated from a flat library later; a fragmented distribution others depend on cannot easily be un-fragmented.
- **Keep the marketplace and treat `.claude/` as a degraded fallback.** Rejected: that is the current state, and it optimises the case that never occurs while degrading the one that always does.

## Consequences

- Depth to reach a checklist drops from four levels to three, and to two from `~/.claude/`. The library can be symlinked, copied, or read file by file with no tooling.
- `scripts/crew.sh` and `scripts/crew-doctor.sh` are inoperative: both are built on `require_plugins` and marketplace-registration checks. Tracked as open work, not silently left as if functional.
- ADR 0001 is superseded, not amended — its context, not merely its decision, was falsified.
- [ADR 0009](./0009-model-routing.md) is scoped to environments where the model is selectable. Where it is imposed, the routing table does not apply and the checklists carry the whole load, since no strong-model gate exists to catch what a weak model produces.
- `docs/design/premise-freelance-vision.md` is retained as a historical record but no longer a design driver.
- Per-capability semver disappears. With one consumer this costs nothing; if distribution ever becomes real, it returns with the generated-plugin option above.
