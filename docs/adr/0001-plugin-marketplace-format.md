# 0001 — Use the Claude Code plugin marketplace format over symlinks

**Status:** superseded by [ADR 0012](./0012-claude-library-over-marketplace.md) — 2026-09-14. Its *context*, not merely its decision, was falsified: the client environment allows no plugin installation, and there is exactly one consumer, so neither "install into any client project" nor per-plugin selective installation ever applied. Kept as a record of what was decided and why.

## Context

The crew needs to install into any client project, version each capability independently, and stay usable across many active client projects without tying every one of them to this exact machine and path. Ad hoc symlinks into a shared skills directory (the pattern used elsewhere in the author's toolkit) don't version independently, don't survive the source repo moving, and have no client-facing install story.

## Decision

Package the crew as a Claude Code plugin marketplace: `.claude-plugin/marketplace.json` at the repo root, one plugin per `plugins/<name>/` with its own `.claude-plugin/plugin.json`, installed into client projects via `/plugin marketplace add` and `/plugin install`.

## Alternatives considered

- **Symlinks into a shared skills directory.** Rejected: not portable across machines, no per-plugin versioning, no client-facing install story, breaks the moment the source repo moves.
- **A single monolithic plugin bundling everything.** Rejected: forces every client to install role/technology combinations they don't need, and blocks independent versioning of, say, the Angular skill against the core agents.

## Consequences

Each plugin gets independent semver and its own changelog entries; client projects install exactly what they need; the marketplace can be hosted on GitHub for team-wide `extraKnownMarketplaces` distribution once pushed. Cost: more manifest files to maintain (6 `plugin.json` files instead of one), and `marketplace.json` must stay in sync with `plugins/` — an entry can't point at a plugin directory that doesn't exist yet.
