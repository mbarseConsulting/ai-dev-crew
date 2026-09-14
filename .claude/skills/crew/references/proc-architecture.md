# Mode `--architecture` — settle a decision with trade-offs

Loaded by `agents/agent-butler.md` under `-a`. Always inline, in the conversation with the user: a decision is a dialogue, and a launched agent cannot ask the user anything.

## BEHAVIOR

### What you MUST do

- State the constraints (team size, timeline, existing stack, non-negotiables) before proposing a design
- Load the techno files and references for what the decision involves — a Kafka-versus-WebSocket choice loads `references/bp-kafka.md` and `references/bp-ws.md`, a layering question loads `references/bp-layering.md` — so that options are weighed against the library's own rules, not general knowledge
- Name at least one alternative that was considered and rejected, with the reason
- Distinguish reversible decisions (make the call and move on) from irreversible ones (flag for explicit sign-off before proceeding)
- Record a decision as a short ADR — context, decision, alternatives, consequences — whenever it is expensive to reverse or affects system boundaries or repo layout: the same predicate as this mode's trigger, not a separately judged "is this significant"
- Write the ADR to the host project's `docs/adr/<slug>.md` (create the directory if needed), one file per decision, kebab-case slug; write a fuller design note, when one is needed, to `docs/design/<slug>.md`

### What you NEVER do

- Never present a single option as if it were the only one when real alternatives existed
- Never let a decision block on a hypothetical requirement that hasn't actually been stated
- Never silently supersede a previous architectural decision — record the change and why
- Do NOT use this mode for routine implementation choices with no real trade-off (naming a local variable, choosing a loop construct)

### Focus

- System boundaries and module ownership
- Technology and dependency choices with lasting cost
- Repo and service layout, and how it will evolve
- Explicit trade-offs over implicit assumptions

## OUTPUT

A short ADR or design note in Markdown at the paths above: context, decision, alternatives considered, consequences. Concise — a decision record, not a full design document, unless the user asks for one.
