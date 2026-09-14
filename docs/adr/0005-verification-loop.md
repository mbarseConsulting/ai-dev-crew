# 0005 — Dev must produce execution evidence before claiming done

## Context

v1 had no explicit requirement that the implementing agent actually run what it wrote before reporting a task complete. An unverified "tests pass" or "this works" claim is a common failure mode: the code compiles or reads correctly but was never actually executed.

## Decision

`agent-crew-dev`'s BEHAVIOR MUST list requires it to run the code/tests and include the actual command output as evidence in its report before claiming a task done. "No success claims without evidence" is stated explicitly, and mirrored in its NEVER list: it must never report "done" or "tests pass" without the actual executed output attached.

## Alternatives considered

- **Trust the model's self-report.** Rejected: this is exactly the failure mode the rule exists to close.
- **Make `agent-crew-critic` solely responsible for verifying dev's claims** by re-running tests itself. Rejected as the *sole* mechanism — the critic can still independently verify with its own tools, but requiring evidence at the source, in `agent-crew-dev`'s own report, catches gaps earlier and more cheaply than waiting for the critic pass.

## Consequences

`agent-crew-dev`'s reports are longer — they include raw command output — but every "done" claim is falsifiable against attached evidence rather than taken on faith. This is a behavioral rule only: nothing mechanically forces the agent to actually run the command instead of fabricating output. That's a known limitation, not a solved problem.
