# 0003 — The orchestrator never grades the work it briefed

## Context

v1's `agent-crew-reviewer` existed independently of the agents that designed or implemented the work, so separation of duties was implicit — it never briefed the work it reviewed. In v2, `agent-crew-butler` both routes work and reads the code back to run its own sanity check, so it would be easy to let it also perform the formal review. That would collapse brief-writer and grader into the same agent and undermine the fresh-eyes principle a review exists to provide.

## Decision

`agent-crew-butler` performs only a light sanity check on returned work (did tests actually run? was the ADR/design respected?) — never the formal quality/security gate. The formal review is always `agent-crew-critic`, a fresh instance with no memory of having briefed the work.

## Alternatives considered

- **Let the butler also perform the formal review**, since it already has full context of the task. Rejected: whoever wrote the brief is primed to see the code succeed at what they asked for, not to find what's actually wrong with it — fresh eyes catch more.
- **Skip the butler's sanity check entirely**, rely solely on the critic. Rejected: a fast, cheap sanity check (did tests actually run?) catches obviously incomplete work before spending a full critic pass on it.

## Consequences

Two distinct checkpoints sit between implementation and "done": a cheap butler sanity check, then a full critic gate. Slightly more overhead than a single review step, but higher confidence the review is actually independent.
