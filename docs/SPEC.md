# ai-dev-crew — SPEC

**Status:** authoritative. This document is the source of truth for what the ai-dev-crew crew IS: its roles, its flow, its contracts. It is not a how-to — see [`README.md`](../README.md) for install and usage. Any future evolution of the crew starts by updating this file (and, if it represents a new decision, adding an entry under [`docs/adr/`](./adr/)) *before* library files change. Decisions recorded here are not re-litigated verbally.

Shipped structure: **2 skills (`crew`, `crew-project`); inside `crew`, 4 role agents, 4 technos and 16 references; 4 launchable shells in `.claude/agents/`; no plugins.** See [ADR 0012](./adr/0012-claude-library-over-marketplace.md) and §9 for the two consumption modes.

## Doctrine: the crew is one skill + the file contract

Per [ADR 0008](./adr/0008-skills-first-doctrine.md) as amended by [ADR 0016](./adr/0016-one-crew-skill-role-as-mode.md): the `crew` skill (§3) plus the file contract (§4) **are** the crew. Every role, the butler included, is an agent file inside the skill. A launchable shell in `.claude/agents/` only adds a fresh context and a restricted toolset. Solo mode is first-class: every role can be run by hand in a plain conversation.

## 1. Roles and boundaries

One verb per role. All technology, domain and procedural knowledge lives in the skill ([ADR 0002](./adr/0002-thin-agents-fat-skills.md)).

### `agent-dev` — `/crew`, `/crew -d`

- **Develops.** Loads the techno file of the detected stack and the references it lists, implements, writes the tests in the right tier, designs missing end-to-end scenarios, and reports actual command output as evidence ([ADR 0005](./adr/0005-verification-loop.md)).
- **Boundary:** never launches anyone (`Agent` removed from its shell), never grades its own work.

### `agent-tester` — `/crew -t`

- **Runs the full suite**, not the author's targeted run, and flags disabled tests.
- When a test is red it already holds the output, so it fixes it under `references/testfix.md` (3 cycles at most) and lists **every file it modified**, source files first.
- **Boundary:** never implements features, never reviews, never launches anyone.

### `agent-review` — `/crew -r`

- **Reviews.** Quality and security lenses (`references/code-quality.md`, `references/security-review.md`), conventions from `references/conventions.md`, the techno file as a conventions lens. Findings marked blocking or non-blocking; one verdict: **approve**, **approve with suggestions**, **changes requested**.
- **Boundary:** never edits code — no `Edit` in its shell. `Bash` writes are closed by behavioral rule only ([ADR 0004](./adr/0004-role-tool-allowlists.md), [ADR 0007](./adr/0007-butler-topology-and-write-scope.md)).

### `agent-butler` — `/crew -b`, `-a`, `-w`

- **Orchestrates.** Qualifies the need; launches `agent-dev` ×N (one per technology, disjoint files), then `agent-tester`, then `agent-review`, with a user gate between phases; sanity-checks what `agent-dev` returns. As a whole session: `claude --agent agent-butler`, which also preloads `crew-project`.
- **Architecture (`-a`):** settles decisions with trade-offs in dialogue with the user, under `references/architecture.md`, writing to `docs/adr/` or `docs/design/`.
- **Watch (`-w`):** maintains the library's rules under `references/watch.md` ([ADR 0010](./adr/0010-watch-craft-maintenance-loop.md)). Never at a client site.
- **Boundary:** never develops (no `Edit`), never runs the suite, never reviews ([ADR 0003](./adr/0003-butler-critic-separation.md)). `Write` only to `docs/adr/` and `docs/design/`.

## 2. Canonical flow

```
/crew  →  detect techno  →  agents/agent-dev.md  →  technos/java.md  →  references
```

With the butler:

```
user ↔ agent-butler ─┬─ (-a, if a decision is needed)
                     ├→ agent-dev ×N ─→ agent-tester ─→ agent-review ─→ user
                     └─ gate between every phase
```

Phases never auto-chain. Each agent reports back to the butler, never to the next role. Parallel review: two `agent-review` instances, one per lens; the quality-lens instance alone writes the merged report.

The router reads the agent inline by default; `-c` launches it as a subagent. `-t` or `-r` run in a conversation that already ran `-d` on the same change are labelled **"Self-check — not the gate"** and give no verdict ([ADR 0016](./adr/0016-one-crew-skill-role-as-mode.md)).

## 3. Skills catalog

| Skill | Invoked when | Carries |
| --- | --- | --- |
| `crew` | developing, testing, reviewing, orchestrating, deciding, watching | router; `agents/` (4 roles); `technos/` (4); `references/` (16) |
| `crew-project` | the project's domain, stack or house names are not obvious from its files | the path → project router |

**A skill names no other skill** — without exception. A skill references only its own files, by paths relative to its directory. `.claude/agents/agent-butler.md` composes `crew` with `crew-project`.

Composition: router → agent → techno → references. Detection matches the nearest build file above the changed file. References load **by context**, never by default.

**Technology is detected; the domain is declared** ([ADR 0015](./adr/0015-library-project-boundary-and-domain-axis.md)): the domain comes from a project file.

[ADR 0013](./adr/0013-craft-skill-taxonomy.md)'s families organise `crew/references/`, plus the domain axis of ADR 0015. A reference carries **`## Règles`** (normative) and **`## Pourquoi`** (explanation); where they disagree, `## Règles` is right. For `java-spring.md` and `node-bff.md`, the rules are the techno file's MUST/NEVER.

**Nothing project- or employer-specific is committed.** Project files live in `crew-project/`, gitignored, deleted when the job ends.

## 4. File-handoff contract

Written in the **client project**:

| Path | Written by | Read by |
| --- | --- | --- |
| `docs/adr/` | `agent-butler` (`-a`) | `agent-dev`, `agent-review` |
| `docs/design/` | `agent-butler` (`-a`) | `agent-dev` |
| `docs/reviews/` | `agent-review` | user, `agent-butler` |

The `agent-dev` evidence report and the `agent-tester` report are conversational. The butler relays them, and the next `agent-review` brief carries the tester's list of modified files.

## 5. Upstream specs interface

The crew **consumes** specifications; it does not author them. Upstream tools (BMAD, Spec Kit, or an equivalent) produce PRDs, epics and stories; `-a` and `agent-dev` read `docs/adr/` and `docs/design/`, whoever wrote them.

## 6. Enforcement layers

- **Tool allowlists** in `.claude/agents/`: `agent-butler` — no `Edit`, `Write` scoped to `docs/adr/`/`docs/design/`; `agent-dev` — no `Agent`; `agent-tester` — `Read, Grep, Glob, Bash, Write, Edit`; `agent-review` — no `Edit`, no `Agent`, `Write` scoped to `docs/reviews/`. Guardrails, not sandboxes ([ADR 0004](./adr/0004-role-tool-allowlists.md)).
- **Skill preloading** (`skills:`): every shell preloads `crew`; `agent-butler` also preloads `crew-project`. `crew` must not set `disable-model-invocation`.
- **Verification loop**: `agent-dev` requires execution evidence ([ADR 0005](./adr/0005-verification-loop.md)).
- **Single source of truth per rule** ([ADR 0008](./adr/0008-skills-first-doctrine.md)).
- **Structural check**: `scripts/crew-doctor.sh`, run by the versioned `.githooks/pre-commit`.
- **Model routing**: the butler passes an explicit `model` in every launch (§8, [ADR 0009](./adr/0009-model-routing.md)).
- **Deferred**: path-scoped hooks and a worktree mode for parallel `agent-dev` instances ([ADR 0006](./adr/0006-deferred-hooks-and-worktrees.md)).

## 7. Change process

Any change to the crew's roles, flow or contracts starts with a PR that updates this file and, if it represents a new decision, adds an ADR under `docs/adr/`. Library files follow from the updated spec — never the other way around.

## 8. Model routing per role

**Scope:** harness mode only (§9). Where the model is imposed, no routing applies ([ADR 0012](./adr/0012-claude-library-over-marketplace.md)).

| Role / work | Model | Rationale |
| --- | --- | --- |
| `agent-butler` (incl. `-a`, `-w`) | session model | main conversation |
| Code exploration fan-out | Haiku | High volume, low reasoning |
| `agent-dev` | Sonnet | Implementation; cost/quality sweet spot |
| `agent-tester` | Sonnet | Suite execution; bounded fixes |
| `agent-review` (each lens) | strong model (Opus-class) | A false "pass" costs more than a strong dispatch |

The butler passes `model` **explicitly in every launch**. When `agent-dev` exhausts its repair budget, the butler may relaunch it once on the strong model. A `model-routing` section in the client project's `CLAUDE.md` overrides defaults; an unavailable model falls back to the session model, reported. `agents/agent-butler.md` carries the runtime copy; this section is authoritative.

## 9. Consumption modes

**Harness mode.** Claude Code discovers `.claude/skills/` and `.claude/agents/`; symlinking into `~/.claude/` makes them available across projects. Launching (§2, `-c`), tool allowlists (§6) and model routing (§8) apply here only.

**Paste mode.** No harness, no agents, an imposed model:

- **File size is a contract** ([ADR 0013](./adr/0013-craft-skill-taxonomy.md)): the router, each agent, each techno and each reference fits a paste window.
- **A pasted skill has only what it was given.** The router lists what to paste: project file · `SKILL.md` · the agent · the techno · its references. No paste ever needs a second skill.

Paste mode has no isolation: the separations of §1 hold only as discipline — a fresh conversation per role, and the independence guard.
