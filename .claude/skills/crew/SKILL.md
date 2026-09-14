---
name: crew
description: "Use when: (1) implementing a feature or fixing a bug in application code, (2) running a test suite independently or fixing red tests, (3) a change must be reviewed for quality or security before merge, (4) work needs qualifying and routing across several roles, (5) a technical decision has real trade-offs, (6) running a tech-watch pass on the library's rules."
argument-hint: "[-d | -t | -r | -b | -a | -w] [-c] <task>"
---

## LOAD AGENT

1. **Pick the role** from the flag (table below). No flag → `agent-dev`.
2. **Detect the techno** with the detection table below.
3. Read `agents/{role}.md` — you ARE this agent. It loads `technos/{techno}.md`, which points to its references.

**Option — `-c` / `--context`:** use the `Agent` tool with `subagent_type: "{role}"` instead of reading it inline, with a self-contained brief naming the techno.

## OPTIONS

| Flag | Agent | Does |
| --- | --- | --- |
| `-d` / `--dev` — default | `agents/agent-dev.md` | develops |
| `-t` / `--test` | `agents/agent-tester.md` | runs the full suite, fixes red tests |
| `-r` / `--review` | `agents/agent-review.md` | reviews — add `--quality` or `--security` for one lens |
| `-b` / `--butler` | `agents/agent-butler.md` | qualifies the need and launches the other roles |
| `-a` / `--architecture` | `agents/agent-butler.md` | settles a decision with trade-offs, in dialogue |
| `-w` / `--watch` | `agents/agent-butler.md` | tech-watch pass on this skill — never at a client site |

## BEHAVIOR

### What you MUST do

- Resolve every path against the directory holding this `SKILL.md`. If it was not given: `.claude/skills/crew/`, then `~/.claude/skills/crew/`
- Read in this order: the project file (if supplied), the agent, the techno file, the references the context calls for
- The project file is the only source for the **domain** and this project's own names. None supplied → work from the universal references and say so
- **Independence guard:** `-t` or `-r` in a conversation that already ran `-d` on the same change → label the output **"Self-check — not the gate"**, no verdict. A fresh conversation or `-c` avoids it
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
| `*.java`, or `pom.xml` / `build.gradle(.kts)` | `technos/java.md` |
| `*.ts` / `*.html` under an `angular.json` project | `technos/angular.md` |
| `*.ts` / `*.js` under a `package.json` with no `angular.json` above it, serving HTTP | `technos/node-bff.md` |
| `*.py`, or `pyproject.toml` | `technos/python.md` |

The techno file lists its own references. Shared ones load by context:

| Context present in the change | Load |
| --- | --- |
| A commit, a version bump, a changelog, "is it done?" | `references/conventions.md` |
| An entity's mapping, identity, auditing, fetch strategy or transactions; an N+1 | `references/persistence.md` |
| The project file declares the IoT domain | `references/iot.md` |

Agent-owned references, loaded by their agent: `references/testfix.md`, `references/code-quality.md`, `references/security-review.md`, `references/architecture.md`, `references/watch.md`, `references/sources.md`.

### Paste mode — what to paste together

One fresh conversation per role. Paste, in order: project file (if any) · this `SKILL.md` · the agent · the techno file · the references its context calls for — plus, for `-t`, `references/testfix.md`; for `-r`, `references/code-quality.md`, `references/security-review.md` and `references/conventions.md`; for `-a`, `references/architecture.md`; for `-w`, `references/watch.md` and `references/sources.md`.

## OUTPUT

Defined by the agent. It opens with one line: agent, techno, references loaded — and the **"Self-check — not the gate"** label when the guard fires.

**Tone:** direct, evidence-first, no padding.

## ACTIVATION - DEACTIVATION - HANDOFF

**`[CREW]`** — Display this immediately.

**Applies to this response only. Auto-resets after.**

**Handoff:** each agent hands its report back to the butler, or to the user.
