# 0004 — Mechanical enforcement via `tools:` frontmatter

## Context

v1's guardrails ("never rewrites code silently," "never implements") were entirely behavioral — stated in an agent's NEVER list but not enforced by anything beyond the model following its own instructions. Nothing stopped a confused or adversarial invocation from calling `Edit` or `Write` against the rule.

## Decision

Use each agent's `tools:` frontmatter as a mechanical allowlist matching its role:

- `agent-crew-butler`: `Read, Grep, Glob, Bash, Agent, Write` — no `Edit`, so it still can't silently rewrite existing application code. `Write` is scoped by behavioral rule to `docs/adr/` and `docs/design/` only (see [ADR 0007](./0007-butler-topology-and-write-scope.md), which also settles the butler's main-session topology).
- `agent-crew-critic`: `Read, Grep, Glob, Bash, Write` — no `Edit` at all, which blocks that specific tool. `Write` is scoped to its own report by behavioral rule only, since path-level restriction isn't expressible in `tools:` (see [ADR 0006](./0006-deferred-hooks-and-worktrees.md)).
- `agent-crew-dev`: no `tools:` field — full toolset, since implementation legitimately needs everything.

Verified against the Claude Code subagent docs before writing: the tool used to dispatch subagents is named `Agent` in `tools:` (not `Task`), and `AskUserQuestion` is explicitly listed as unavailable to subagents even when named in `tools:` — so it was left out of the butler's allowlist; asking the user happens through plain conversational text instead.

## Alternatives considered

- **Behavioral guardrails only** (the v1 approach). Rejected as insufficient on its own now that mechanical enforcement is available and cheap to add.
- **Path-scoped enforcement via hooks** (e.g. actually blocking `Write` outside `docs/reviews/`). Deferred, not rejected — see [ADR 0006](./0006-deferred-hooks-and-worktrees.md).

## Consequences

A butler invocation cannot call `Edit` at all — the tool isn't in its resolved tool set — so it cannot silently rewrite existing application code. The critic likewise cannot call `Edit`. Confidence in the "never rewrites silently" guarantee for `Edit` specifically moves from "the model was told not to" to "the tool isn't there."

**Known gap, stated honestly (not the "mechanically impossible" framing this ADR originally used): `tools:` allowlists are guardrails, not sandboxes.** Both the butler and the critic keep `Bash` in their allowlist, and `Bash` can create or modify files just as effectively as `Write`/`Edit` (`echo ... > file`, `sed -i`, heredocs). Nothing in the `tools:` field stops that. This gap is closed behaviorally, not mechanically, by a NEVER rule on both agents (added in [ADR 0007](./0007-butler-topology-and-write-scope.md)): never use `Bash` to create or modify files. That rule is exactly as enforceable as any other behavioral NEVER in this repo — which is to say, not mechanically. Full mechanical enforcement, including the Bash bypass and the critic's `docs/reviews/`-only scope, needs the path-scoped hooks already deferred to v2.1 (ADR 0006).
