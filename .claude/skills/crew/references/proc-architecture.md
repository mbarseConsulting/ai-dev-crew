# architecture — settle a decision with trade-offs

> Run by: `agents/agent-butler.md` under `-a`, always inline — a decision is a dialogue with the user, and a launched agent cannot ask anything.

## Steps

1. **State the constraints** before any design: team size, timeline, existing stack, non-negotiables.
2. **Load what the decision involves** — Kafka versus WebSocket loads `references/bp-kafka.md` and `references/bp-ws.md`, a layering question loads `references/bp-layering.md` — so options are weighed against the library's rules, not general knowledge.
3. **Name at least one alternative** considered and rejected, with the reason.
4. **Classify:** reversible → decide and move on; irreversible → explicit sign-off before proceeding.
5. **Record it** as an ADR in the host project's `docs/adr/<slug>.md` — context, decision, alternatives, consequences — whenever it is expensive to reverse or affects boundaries or layout. A fuller design note, when needed, goes to `docs/design/<slug>.md`.

## NEVER

- Never present one option as the only one when real alternatives existed
- Never block on a hypothetical requirement nobody stated
- Never silently supersede a previous decision — record the change and why
- Never use this for a choice with no real trade-off (a variable name, a loop construct)

## Output

A short ADR or design note at the paths above. A decision record, not a design document, unless the user asks for one.
