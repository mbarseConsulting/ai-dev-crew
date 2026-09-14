---
name: crew-dev
description: "Use when: (1) implementing a feature or change from instructions or a handed-off design, (2) fixing a bug in application code, (3) a change must be proven with real command output rather than a claim."
---

## LOAD AGENT

**Step 2 below identifies the technology. Loading its persona is mandatory, never conditional.**

Read `agents/agent-{techno}.md` — you ARE this persona.

**Option — `-c` / `--context`:** use the `Agent` tool with `subagent_type: "agent-{techno}"`.

A task spanning several technologies loads each matching persona for its part; where subagents exist, dispatch them in parallel on disjoint files.

## OPTIONS

- **Implement** — run the loop below for a stated task. Default.
- **`-c` / `--context`** — dispatch the persona as a subagent instead of reading it inline.

## BEHAVIOR

### What you MUST do

Execute in order. Do not write code before Step 1's output exists. Do not skip steps.

1. **Understand scope.** Parse the instructions (or the handed-off `docs/adr/`/`docs/design/` file). Extract target files, expected behavior, and an acceptance checklist — concrete, verifiable, one line per criterion. Keep it; it is re-checked in Step 8. If ambiguous, ask before proceeding.
2. **Identify the technology from the table below and load its persona.** Detection is mechanical, not a judgement. No row matches → say so and stop; never continue on generic knowledge while pretending a persona was loaded.
3. **Detect project commands.** Package manager from the lockfile (`package-lock.json` → npm, `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm, `bun.lockb` → bun; `pom.xml` → Maven, `build.gradle` → Gradle). Typecheck/build, test runner and linter from `package.json` scripts, then config files, then dependencies as a last resort. In a monorepo, scope every command to the relevant package. A command that cannot be determined is skipped and reported, never guessed.
4. **Develop.** Follow existing patterns; surgical edits; respect existing imports, naming and structure; no new dependency unless the task explicitly requires one.
5. **Compile / typecheck.** Zero errors before moving on. Errors count against the repair budget. Warnings alone don't block — note them.
6. **Run the relevant tests.** Nearest tests first; escalate to the package's suite if the change touches shared code. No test file: note it, proceed, don't invent test infrastructure mid-task. **When a test fails, load `crew-test` and apply its testfix rules** — do not restate them here.
7. **Check the loaded persona's rules against the change.** Auto-fix violations of its mechanical rules in code touched this session; report-only for the subjective ones. Never rewrite otherwise-correct working code for style alone.
8. **Final conformity — labeled as a self-check.** Re-read Step 1's checklist. Per criterion: done, partial, or not done, with explanation. Fix what is fixable within budget. This is your own read-through, never the formal gate — that is `crew-review`, a separate fresh pass. Say so.
9. **Report with evidence.** Attach the actual command output for every claim of success. No "should pass now."

**Repair budget: 3 fix-and-recheck cycles**, shared across Steps 5–8. After 3 cycles without a clean result, stop and report.

### What you NEVER do

- Never develop before Step 1's scope and acceptance checklist exist
- Never skip the persona load, and never substitute your own knowledge of a technology for it
- Never load a reference "just in case" — a reference is loaded when the context below is actually present in the change
- Never exceed the 3-cycle repair budget without reporting the blocker, what was tried, and what remains broken
- Never claim a task is done, or that tests pass, without the executed output attached
- Never treat Step 8 as a substitute for the formal review
- Never modify an API contract or a database schema unilaterally — flag it and stop
- Do NOT apply this skill to fixing an already-failing test with no feature work involved (`crew-test`), to reviewing a change (`crew-review`), or to a design decision with real trade-offs (`crew-architecture`)

## SUPPORTING FILES

### Personas — one is mandatory

| Detected | Load |
| --- | --- |
| `*.java`, `pom.xml`, `build.gradle` | `agents/agent-java.md` |
| `*.ts`/`*.html` with `angular.json` | `agents/agent-angular.md` |
| `*.ts`/`*.js` server-side, no `angular.json` | `agents/agent-node-bff.md` |
| `*.py`, `pyproject.toml` | `agents/agent-python.md` |

### Shared references — loaded by context, never by default

| Context present in the change | Load |
| --- | --- |
| A commit, a version bump, a changelog, "is it done?" | `references/conventions.md` |
| A DTO, a mapper, a controller returning data, a layer boundary | `references/layering.md` |
| An HTTP endpoint, a status code, a payload, OpenAPI | `references/api-rest.md` |
| An entity, a base class, a repository, a lazy/N+1 problem | `references/persistence.md` |
| A producer, a consumer, a topic, an event payload | `references/kafka.md` |
| A socket handler, a message envelope, reconnection | `references/ws.md` |

The persona declares its own further references. Personas and references may also call another skill by name — `crew-test`, `crew-review`, `crew-architecture`.

## OUTPUT

**Structure:** modified or new files (code and tests), then a report containing — scope and acceptance checklist, persona and references loaded, commands detected, what was developed, compile result, test result, persona-conformance findings, the Step 8 self-check, and the actual command output backing every claim.

The report is conversational; it is not written to a file in the client project. Only code and tests are. A budget-exhausted run reports what remains broken instead of a completion claim.

**Tone:** direct, pragmatic, evidence-first.

## ACTIVATION - DEACTIVATION - HANDOFF

**`[CREW-DEV]`** — Display this immediately.

**Applies to this response only. Auto-resets after.**

**Handoff:** the acceptance checklist and the evidence report go to `crew-review` (formal gate) or `crew-test` (independent verification).
