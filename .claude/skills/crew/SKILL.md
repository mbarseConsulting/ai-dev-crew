---
name: crew
description: "Use when: (1) implementing a feature or fixing a bug in Java/Spring, Angular, Node or Python/FastAPI code, (2) running a test suite independently or fixing red tests, (3) a change must be reviewed for quality or security before merge, (4) work needs qualifying and routing across several roles, (5) a technical decision has real trade-offs."
argument-hint: "[-d | -t | -r [--quality | --security] | -b | -a] [-c] <task>"
---

## LOAD AGENT

1. **Pick the role** from the flag (table below). No flag → `agent-dev`.
2. **Detect the techno** with the detection table below.
3. Read `agents/{role}.md` — you ARE this agent. The agent says when to read `technos/{techno}.md`, which lists its own `technos/{techno}-*.md` references: never read it before the agent asks.

**Option — `-c` / `--context`:** use the `Agent` tool with `subagent_type: "{role}"` instead of reading it inline, with a self-contained brief naming the techno. Never for `-b` or `-a`: the butler talks to the user, so it always runs inline — ignore `-c` and say so.

## OPTIONS

| Flag | Agent | Does |
| --- | --- | --- |
| `-d` / `--dev` — default | `agents/agent-dev.md` | develops |
| `-t` / `--test` | `agents/agent-tester.md` | runs the full suite, fixes red tests |
| `-r` / `--review` | `agents/agent-review.md` | reviews — add `--quality` or `--security` for one lens |
| `-b` / `--butler` | `agents/agent-butler.md` | qualifies the need and launches the other roles |
| `-a` / `--architecture` | `agents/agent-butler.md` | settles a decision with trade-offs, in dialogue |

## BEHAVIOR

### What you MUST do

- Resolve every path against the directory holding this `SKILL.md`. If it was not given: `.claude/skills/crew/`, then `~/.claude/skills/crew/`
- Read in this order: the project file (if supplied), the agent, then the techno file and the references the context calls for — when the agent's steps reach them
- The project file is the only source for the **domain** and this project's own names. None supplied → work from the shared references and say so
- **Independence guard:** `-t` or `-r` in a conversation that wrote or briefed the same change (it ran `-d` or `-b` on it) → label the output **"Self-check — not the gate"**, no verdict. A fresh conversation or `-c` avoids it
- Say which agent, techno and references were loaded, in the first lines of the output

### What you NEVER do

- Never name, load or defer to another skill — this skill works from its own files only
- Never continue on generic knowledge when no detection row matches: say so and stop
- Never load a reference "just in case" — only when its context is present in the change
- Never store a project file, an employer's conventions, or anything project-specific inside this skill

## SUPPORTING FILES

### Detection — technology is detected

Match the changed file and the **nearest** build file above it, never the repository root alone: a monorepo can hold an Angular app and a Node BFF side by side.

| Nearest to the changed file | Techno |
| --- | --- |
| `*.java`, or a `pom.xml` / `build.gradle(.kts)` itself | `technos/java.md` |
| `*.ts` / `*.html` / `*.scss` / `*.css` under an `angular.json` project | `technos/angular.md` |
| `*.ts` / `*.js` under a `package.json` with no `angular.json` above it, whose dependencies include `express`, `fastify`, `koa`, `hono` or `@nestjs/core` | `technos/node.md` |
| `*.py` under a `pyproject.toml` whose dependencies include `fastapi` | `technos/python.md` |

A file matching no row — `*.kt`, a Node library, a Django app — has no techno: say so and stop.

### Shared references — loaded by context, whatever the techno

| Context present in the change | Load |
| --- | --- |
| Any change to source code | `references/bp-code.md` |
| A commit, a version bump, a changelog, "is it done?" | `references/bp-conventions.md` |
| A DTO, a mapper, a controller returning data, a layer boundary | `references/bp-layering.md` |
| An HTTP endpoint, a status code, a payload, OpenAPI | `references/bp-api-rest.md` |
| An endpoint that aggregates or reshapes backend calls for one front end | `references/bp-bff.md` |
| A producer, a consumer, a topic, an event payload | `references/bp-kafka.md` |
| A socket handler, a message envelope, reconnection | `references/bp-ws.md` |
| The project file's `Références de domaine` line lists `iot` | `references/dom-iot.md` |

Agent-owned procedures, loaded by their agent: `references/proc-testfix.md`, `references/proc-quality.md`, `references/proc-security.md`, `references/proc-architecture.md`.

### Paste mode — what to paste together

One fresh conversation per role. Paste, in order: project file (if any) · this `SKILL.md` · the agent · the techno file · the references its context calls for — plus, for `-t`, `references/proc-testfix.md`, and the techno file only once a fix touches source code; for `-r`, `references/proc-quality.md`, `references/proc-security.md` and `references/bp-conventions.md`; for `-a`, `references/proc-architecture.md`.

## OUTPUT

Defined by the agent. It opens with one line: agent, techno, references loaded — and the **"Self-check — not the gate"** label when the guard fires.

**Tone:** direct, evidence-first, no padding.

## ACTIVATION - DEACTIVATION - HANDOFF

**`[CREW]`** — Display this immediately.

**Applies to this response only. Auto-resets after.**

**Handoff:** each agent hands its report back to the butler, or to the user.
