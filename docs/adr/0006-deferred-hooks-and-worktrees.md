# 0006 — Enforcement hooks and worktree mode deferred to v2.1

## Context

Two further upgrades were considered for this v2 restructure alongside the tool allowlists ([ADR 0004](./0004-role-tool-allowlists.md)) and the verification loop ([ADR 0005](./0005-verification-loop.md)): (1) plugin-shipped hooks that would mechanically enforce path-scoped rules `tools:` can't express — e.g. actually blocking `agent-crew-critic`'s `Write` outside `docs/reviews/`, instead of relying on its NEVER list; and (2) a worktree mode for `crew.sh` that would run `agent-crew-dev` in an isolated git worktree per task.

## Decision

Defer both to v2.1. v2 ships with tool-level allowlists and the verification loop as its mechanical/evidence-based upgrades; hooks and worktree mode are documented as roadmap items in the README only, not implemented in this pass.

## Alternatives considered

- **Ship hooks now, alongside the allowlists.** Rejected for this pass: hooks are plugin-scoped configuration with their own testing surface, and bundling them with the rest of this restructure risked delaying the core thin-agents/fat-skills change ([ADR 0002](./0002-thin-agents-fat-skills.md)) for a secondary enforcement layer that the `tools:` allowlists already substantially improve on.
- **Ship worktree mode now.** Rejected for this pass: `crew.sh`'s current single-directory launch model is simpler to reason about and sufficient for the sequential canonical flow. Worktrees mainly pay off for running multiple `agent-crew-dev` instances in parallel, a case `crew.sh`'s menu doesn't yet exercise.

## Consequences

The critic's write-scope-to-`docs/reviews/` rule remains behavioral, not mechanical, until v2.1. Running multiple `agent-crew-dev` instances in parallel on disjoint files today requires the user to manage isolation manually rather than `crew.sh` doing it. Both are explicit, tracked gaps — not silent ones — recorded here and in the README roadmap.
