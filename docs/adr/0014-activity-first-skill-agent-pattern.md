# 0014 — Index by activity, not by knowledge domain; Skill+Agent as the unit

**Status:** accepted — 2026-09-14. Amends [ADR 0013](./0013-craft-skill-taxonomy.md).

## Context

[ADR 0013](./0013-craft-skill-taxonomy.md) made each knowledge domain a top-level skill: `java-craft`, `persistence-craft`, `api-rest-craft`, and so on — seventeen skills in all. Three facts, surfaced within hours of writing it, show the taxonomy was right and its *exposure level* wrong.

**1. Skills are invoked by hand.** The operator types `/name`; `disable-model-invocation` exists precisely to make that the only path. So the top-level list is not a discovery index the model searches — it is a menu of seventeen entries a human must hold in mind. The real cost was never tokens (the seventeen descriptions total 4.5 KB); it was that the operator had to know which of seventeen names applied before starting.

**2. The invocation axis must be knowable at invocation time.** "I am developing" is known when the command is typed. "I am touching an audited entity and exposing an endpoint" is not — it is a property of code not yet written, discovered during the work. ADR 0013 put at the invocation level information that does not exist at the invocation level. `/persistence-craft` is a command nobody will ever type, because *doing persistence* is not an intention, it is a retrospective observation.

**3. The Skill+Agent pattern was already the house standard.** The operator's own `skill-template.md` carries it verbatim — `## LOAD AGENT` / *"Read `agents/{agent-name}.md` — you ARE this persona"* / *"Option `-c`: use the `Agent` tool with `subagent_type`"*. Here "agent" means a persona file **inside** a skill, and the `-c` option is what binds that same file to a real dispatchable subagent where subagents exist.

## Decision

**1. The top-level unit is the activity.** Five skills: `crew-dev`, `crew-review`, `crew-test`, `crew-architecture`, `crew-watch`. Each is something the operator decides to do.

**2. Composition is a graph, not a tree.** Four edges, none exclusive of the others:

- a skill loads **its own** references (the shared ones, by context)
- a skill loads a **persona** (`agents/agent-{techno}.md`)
- a persona loads **its own** references
- a persona or a skill may call **another skill** by name

The fourth edge removes a problem the previous structure had: `crew-review` no longer reaches into a sibling skill's files to check conventions — it calls `agent-java` as a lens.

**3. References load by context, never by default.** A detection table keyed on observable facts — file extensions, build files, annotations — not on judgement. Touching a DTO loads `layering.md`; touching an entity loads `persistence.md`. Nothing loads "just in case."

**4. The persona hop is mandatory, and its failure must be loud.** One routing decision now governs everything downstream, where seventeen descriptions previously offered seventeen chances to fire. A stack matching no row is a stop-and-report, never a silent fallback to generic knowledge.

**5. One persona file, two modes.** `.claude/agents/agent-java.md` is a shell pointing at `crew-dev/agents/agent-java.md`; the persona is the single source. Dispatched, it runs in an isolated context — which is what it adds over inline reading, and what makes it satisfy the criterion in `doctrine.md`: *an agent exists only by what it cannot do, or by what it has not seen.* A full-stack feature dispatches `agent-java` and `agent-angular` in parallel on disjoint files, and neither pollutes the other's context nor the main session's.

**6. ADR 0013's taxonomy survives, one level down.** The four families and both arbitration rules still govern — they now organise `references/` instead of the top-level namespace. What is amended is only the exposure level.

**7. The normative/explanatory split moves from two files to two sections.** [ADR 0010](./0010-watch-craft-maintenance-loop.md) put the rule in `SKILL.md` and the reasoning in `best-practices.md`. A merged reference now carries `## Règles` and `## Pourquoi`. The asymmetry is unchanged and still decides conflicts: **`## Règles` is normative, `## Pourquoi` explains, and where they disagree `## Règles` is right.**

## Alternatives considered

- **Keep seventeen skills, strengthen `dev-loop` into a router.** Rejected: it answers a token-cost problem the operator never had, and leaves the seventeen-entry menu exactly as it was.
- **Move technology knowledge into real subagents only.** Rejected outright: there are no subagents where this library is actually used, so it would rebuild the failure [ADR 0012](./0012-claude-library-over-marketplace.md) removed — capability locked behind a mechanism absent at the point of use. The persona-file form is what makes the same content work in both modes.
- **Have `SKILL.md` carry every reference mapping, personas carrying none.** This is what the house `ai-expert` skill does, and it keeps every hop to one. Rejected for this skill: adding a technology would then mean editing `SKILL.md` every time, and the file grows with the stack. Accepted price: two hops (skill → persona → reference), never three.

## Consequences

- Seventeen skills become five. No content is rewritten; it is relocated: `java-craft/SKILL.md` → `crew-dev/agents/agent-java.md`, `persistence-craft/*` → `crew-dev/references/persistence.md`.
- A structural check now guards the routing: every path cited by `SKILL.md` must exist, every persona must have a detection row, and every reference must be reachable from either the skill or a persona. It caught one real ambiguity on first run — a `references/testfix.md` citation that resolved against the wrong skill.
- `agent-crew-dev`'s NEVER rule is amended: it may dispatch its own technology personas. Dispatching another *role* — review, test, architecture — remains the butler's. [ADR 0003](./0003-butler-critic-separation.md) protects who *grades* the work, not who splits it.
- `house-rules.md` consolidates to one gitignored file per skill, sectioned by domain, instead of one per craft skill.
- The live routing test — a fresh agent given only `crew-dev/SKILL.md` and a Java task — is **not** run in this change. Recorded as owed, not as done.
