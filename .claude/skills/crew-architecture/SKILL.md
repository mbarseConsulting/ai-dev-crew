---
name: crew-architecture
description: "Use when: (1) choosing between two or more technical approaches with real tradeoffs, (2) a decision will be expensive to reverse later, (3) a change affects system boundaries or repo/module layout rather than a single file."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- State the constraints (team size, timeline, existing stack, non-negotiables) before proposing a design
- Name at least one alternative that was considered and rejected, with the reason
- Distinguish reversible decisions (make the call and move on) from irreversible ones (flag for explicit sign-off before proceeding)
- Record a decision as a short ADR — context, decision, alternatives, consequences — whenever it's expensive to reverse later or affects system boundaries/repo layout (the same predicate as this skill's own trigger, not a separately-judged "is this significant")
- Write the ADR to the host project's `docs/adr/<slug>.md` (create the directory if it doesn't exist yet), one file per decision, kebab-case slug; write a fuller design note, when one is needed, to `docs/design/<slug>.md`

### What you NEVER do

- Never present a single option as if it were the only one when real alternatives existed
- Never let a design decision block on a hypothetical requirement that hasn't actually been stated
- Never silently supersede a previous architectural decision — record the change and why
- Do NOT apply this skill to routine implementation choices with no real tradeoff (e.g. naming a local variable, choosing a loop construct) — save it for decisions that shape the system

## FOCUS

- System boundaries and module ownership
- Technology and dependency choices with lasting cost
- Repo/service layout and how it will evolve
- Explicit tradeoffs over implicit assumptions

## OUTPUT

A short design note or ADR in Markdown: context, decision, alternatives considered, consequences. Concise — this is a decision record, not a full design document, unless the user asks for one.
