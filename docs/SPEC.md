# ai-dev-crew — SPEC

**Status:** authoritative. This document is the source of truth for what the ai-dev-crew crew IS: its roles, its flow, its contracts. It is not a how-to — see [`README.md`](../README.md) for install and usage. Any future evolution of the crew starts by updating this file (and, if it represents a new decision, adding an entry under [`docs/adr/`](./adr/)) *before* library files change. Decisions recorded here are not re-litigated verbally.

Shipped structure this document describes: **5 skills, 4 technology personas and 8 agents in `.claude/`, no plugins.** Packaging is a flat library discovered without installation — see [ADR 0012](./adr/0012-claude-library-over-marketplace.md) and §9 for the two consumption modes.

## Doctrine: the crew is skills + the file contract

Per [ADR 0008](./adr/0008-skills-first-doctrine.md): the skills catalog (§3) plus the file contract (§4) **are** the crew. An agent is one instantiation of a role a human can equally well play by hand — load the same skills directly in a plain session, in the same order, and get the same result. `agent-crew-dev`, `agent-crew-tester`, and `agent-crew-critic` are **shells**: their entire behavioral content is "which skills to load by name," nothing more. The one deliberate exception is `agent-crew-butler`: routing, briefing multiple dispatches, and holding a user gate between phases run by different subagents require actual dispatch mechanics that no skill loaded in one session can reproduce, so the butler keeps genuine agent-level behavior of its own — and remains optional convenience, never a required capability. Solo mode is first-class, not a fallback: every phase below can be run by hand, no butler and no other agent involved, by loading the same skills in the same order.

## 1. Roles and boundaries

Four agents, one clear responsibility each. All domain, technology, and procedural knowledge lives in skills (§3), not in agent personas — see [ADR 0002](./adr/0002-thin-agents-fat-skills.md) and [ADR 0008](./adr/0008-skills-first-doctrine.md).

### `agent-crew-butler`

- Entry point, running as the **main-session persona** in normal use — not a dispatched subagent. See [ADR 0007](./adr/0007-butler-topology-and-write-scope.md). Qualifies the user's need before dispatching anything. Not a shell (§ Doctrine, above) — its dispatch/gating behavior is genuinely agent-level, not extractable to a skill.
- Dispatches `agent-crew-dev`, `agent-crew-tester`, and/or `agent-crew-critic` as subagents via its own `Agent` tool.
- Holds architecture decisions directly with the user via the `crew-architecture` skill — a real, iterative dialogue it conducts itself, never delegates — and writes the outcome to `docs/adr/` or `docs/design/` (`Write`, scoped to those two paths by behavioral rule; see ADR 0007).
- Runs a light sanity check on work returned by `agent-crew-dev` (did tests actually run? was the ADR/design respected?) before handing off to `agent-crew-tester` and/or `agent-crew-critic` for the thorough passes.
- **Boundary:** never implements code (no `Edit`); never performs independent test verification or the formal review itself. See [ADR 0003](./adr/0003-butler-critic-separation.md).

### `agent-crew-dev`

- Generic, technology-agnostic developer **shell**. Instantiable multiple times in parallel on disjoint files. Its entire behavior is `dev-loop`, loaded by name, alongside `dev-conventions` and the matching craft skill(s) for the task — which now means **one per axis touched**, not one per language: a language/framework skill, plus any Structure or Contracts skill the change crosses (§3, [ADR 0013](./adr/0013-craft-skill-taxonomy.md)). A change adding a REST endpoint over a new entity loads `java-craft`, `layering-craft`, `persistence-craft` and `api-rest-craft`.
- Reads `docs/adr/` and `docs/design/` before implementing a handed-off feature, and runs the code/tests and reports the actual output as evidence before claiming a task done — all `dev-loop`'s procedure, not restated here. See [ADR 0005](./adr/0005-verification-loop.md).
- When a test fails, `dev-loop` hands off to `testfix` (by name) for the source-vs-test classification and fix — the crew's one home for those rules.
- **Boundary:** never grades its own work — that is `agent-crew-critic`'s job (or a human doing that review directly, in solo mode).

### `agent-crew-tester`

- Test-strategy and independent-verification **shell**. Its entire behavior is `test-craft`, loaded by name. Runs as a fresh instance, independent of whichever `agent-crew-dev` instance implemented the change under test — the same fresh-eyes principle behind the butler/critic separation (ADR 0003).
- Decides unit/logic-tier vs. end-to-end/DOM-tier placement for a piece of behavior, designs missing end-to-end scenarios, and independently runs the **full** test suite (not just the author's targeted run) as its verification step.
- **Boundary:** never fixes a failing test itself — hands off to `testfix` (by name) or says so; never performs the formal quality/security gate — that is `agent-crew-critic`'s job.

### `agent-crew-critic`

- Quality and security guardian **shell**. Fresh instance per review, with no memory of having briefed the work under review. Its entire review content is `code-quality` and `security-review`, loaded by name as lenses (or a single lens, in parallel-review mode); what the agent adds beyond the skills is dispatch-specific coordination — the lens-default rule and, in parallel mode, which instance writes the merged report.
- Checks conformance to `docs/adr/` and harmony with existing project practice — via `code-quality`'s own MUST, not restated here.
- **Boundary:** never rewrites or edits code — no `Edit` tool at all, which blocks that specific tool. Its `Bash` access remains a known gap closed only by behavioral rule, not a sandboxed guarantee — see [ADR 0004](./adr/0004-role-tool-allowlists.md) and [ADR 0007](./adr/0007-butler-topology-and-write-scope.md). Never writes exploit code, never prints secrets in cleartext — both via `security-review`.

## 2. Canonical flow

**Topology:** `agent-crew-butler` runs as the main-session persona, not as a dispatched subagent, in normal operation (see [ADR 0007](./adr/0007-butler-topology-and-write-scope.md)). A session enters the butler's role by being told to *act as* the butler; `agent-crew-butler` is not dispatched through the `Agent` tool. (`scripts/crew.sh` used to perform this kickoff and is currently inoperative — it was built on plugin installation, removed by [ADR 0012](./adr/0012-claude-library-over-marketplace.md).) The butler then uses its own `Agent` tool to dispatch `agent-crew-dev`, `agent-crew-tester`, and `agent-crew-critic` as subagents. This is what gives the butler a real, iterative conversational channel with the user — a dispatched subagent has none.

```
user ↔ agent-crew-butler → agent-crew-dev ×N (craft skills) → agent-crew-tester → agent-crew-critic → user
```

Every arrow is a user-triggered step; phases never auto-chain. The butler enforces an explicit user gate between an architecture/design decision, implementation, and the critic's formal gate. After `agent-crew-dev` returns, the butler runs its light sanity check (§1) — reading the dev report directly from the dispatch result, not from a file — before that user gate; `agent-crew-tester`'s thorough, independent full-suite verification and `agent-crew-critic`'s formal gate are the two distinct checkpoints described in [ADR 0003](./adr/0003-butler-critic-separation.md), both fresh instances independent of the `agent-crew-dev` instance that implemented the change. The one exception to the sequential flow is parallel review: two `agent-crew-critic` instances (quality lens / security lens) run concurrently via agent teams and challenge each other's findings, and the quality-lens instance alone writes the merged report.

Solo mode runs the identical sequence by hand: `dev-loop` (+ craft skills) → `test-craft` → `code-quality` + `security-review`, loaded directly in a plain session, no agent dispatch at all. Same skills, same order, same result — see the Doctrine above and §9, which states what solo mode does *not* reproduce: isolation and tool restriction.

Tool allowlists are in §6, the file contract in §4, and the two consumption modes in §9.

## 3. Skills-by-work-type catalog

| Skill | Invoked when | Carries |
| --- | --- | --- |
| `crew-dev` | implementing or fixing application code | the develop→compile→test→verify loop, the technology detection table, 4 personas, 10 references |
| `crew-review` | a change must pass a formal gate | the review procedure; quality and security lenses as references |
| `crew-test` | a test is red, or a change needs independent verification | the tier criterion, scenario design, full-suite verification, testfix |
| `crew-architecture` | a decision has real trade-offs and is expensive to reverse | ADR discipline, alternatives, reversibility |
| `crew-watch` | the library's references risk going stale | the doctrinal diff, the digest, one PR per impacted file |

The top-level unit is the **activity**, not the knowledge domain — because the activity is the only thing known at the moment the skill is invoked by hand ([ADR 0014](./adr/0014-activity-first-skill-agent-pattern.md)). What technology a task touches, and what it crosses into, is discovered *during* the work, so it is routed, not typed.

Composition is a graph with four edges, none exclusive: a skill loads its own references; a skill loads a persona; a persona loads its own references; either may call another skill by name. References load **by context** — a DTO loads `layering.md`, an entity loads `persistence.md` — never by default.

**Technology is detected; the domain is declared** ([ADR 0015](./adr/0015-library-project-boundary-and-domain-axis.md)). `*.java` is an observable fact; nothing in a repository states that a project is IoT. The domain therefore comes from a **project profile** supplied by the operator — which is also the only reason such a profile needs to exist.

[ADR 0013](./adr/0013-craft-skill-taxonomy.md)'s four families and both arbitration rules still govern; they now organise `crew-dev/references/` rather than the top-level namespace.

A merged reference carries two sections: **`## Règles` is normative, `## Pourquoi` explains, and where they disagree `## Règles` is right** — the same asymmetry [ADR 0010](./adr/0010-watch-craft-maintenance-loop.md) established between files.

`crew-watch` is the only skill that maintains the library rather than serving client work; it is never pasted at a client site.

**Nothing project- or employer-specific is stored in this library.** It travels with its owner for life; a project is disposable. The project profile — domain, stack, and this project's own names — lives in the operator's own space, outside this repository and outside the client's, and is pointed at, never contained. Only `crew-project/templates/project-profile.md` is committed.

Skills are portable Markdown, self-contained, and referenced **by name only** — never by directory path — so they stay usable outside Claude Code and never cross-reference another skill's internals. `dev-loop`'s handoff to `testfix` for classify-and-fix rules is the canonical example of this pattern: `dev-loop` references `testfix` by name and does not restate its rules, which is exactly why those rules have exactly one home instead of two copies that can drift apart.

`agent-crew-critic` may additionally load the matching craft skill (e.g. `angular-craft`) as a conventions-reference lens when checking harmony with existing project practice, and `agent-crew-dev` may use a craft skill's review mode to self-check its own work-in-progress. These are the only two authorized consumers of a craft skill's review mode; neither substitutes for the formal `agent-crew-critic` gate.

## 4. File-handoff contract

Outside agent-teams parallel review, agents don't talk to each other spontaneously. Coordination is files — written in the **client project**, not this repo:

| Path | Written by | Read by |
| --- | --- | --- |
| `docs/adr/` | `agent-crew-butler` (via the `crew-architecture` skill; `Write` scoped to this path — [ADR 0007](./adr/0007-butler-topology-and-write-scope.md)) | `agent-crew-dev`, `agent-crew-critic` |
| `docs/design/` | `agent-crew-butler` (same scope) | `agent-crew-dev` |
| `docs/reviews/` | `code-quality` (Quality section) + `security-review` (Security section) — whether loaded via `agent-crew-critic` or directly, solo | user, `agent-crew-butler` (relaying the verdict) |

This path is written by the **skills themselves** (per the Doctrine, above), not exclusively by `agent-crew-critic` — a solo session loading `code-quality`/`security-review` directly writes the same file, using only the section(s) for whichever lens(es) it ran; see each skill's own OUTPUT. `agent-crew-butler`'s read of `docs/reviews/` (relaying the verdict to the user) is distinct from its **sanity check** in §2, which runs earlier, on `agent-crew-dev`'s conversational evidence report — not a file. `agent-crew-dev`'s evidence report and `agent-crew-tester`'s independent-verification report are both conversational only; neither is written to a file in this table.

`docs/security/` (v1) is retired: security findings now live in the Security section of the same merged report under `docs/reviews/`.

## 5. Upstream specs interface

The crew **consumes** specifications; it does not author them. Upstream spec-producing tools (BMAD, Spec Kit, or an equivalent) are expected to produce PRDs, epics, and stories ahead of the crew's involvement. Both `agent-crew-butler`'s architecture dialogue and `agent-crew-dev`'s implementation read from `docs/adr/` and `docs/design/` as their input — whether those were produced by the butler itself or handed in from an upstream spec tool. The crew has no opinion on which upstream tool a client project uses.

## 6. Enforcement layers

- **Tool allowlists** (`tools:` frontmatter): enforcement per role — the butler has `Write` scoped to `docs/adr/`/`docs/design/` and no `Edit`; the critic has `Write` scoped to `docs/reviews/` and no `Edit`; the tester has a near-full toolset (`Read, Grep, Glob, Bash, Write, Edit`, no `Agent`) since designing missing test scenarios needs file authorship but not dispatch. This mechanically blocks `Edit` where it's absent, but not `Bash`-based file writes, which are closed by behavioral rule only — `tools:` allowlists are guardrails, not sandboxes. See [ADR 0004](./adr/0004-role-tool-allowlists.md) and [ADR 0007](./adr/0007-butler-topology-and-write-scope.md).
- **Verification loop**: `dev-loop` requires execution evidence before claiming a task done. See [ADR 0005](./adr/0005-verification-loop.md).
- **Single source of truth per rule** (skills-first): a rule lives in exactly one skill and is referenced by name elsewhere, never duplicated — `testfix`'s classify-and-fix rules being the concrete example other skills point to rather than restate. See [ADR 0008](./adr/0008-skills-first-doctrine.md).
- **Model routing**: the butler passes an explicit `model` in every dispatch per the §8 table; behavioral rule, no mechanical enforcement. See [ADR 0009](./adr/0009-model-routing.md).
- **Deferred**: path-scoped enforcement hooks and a worktree mode for parallel `agent-crew-dev` instances. The hooks were previously framed as plugin-shipped; with the plugin format gone ([ADR 0012](./adr/0012-claude-library-over-marketplace.md)) they would ship as project settings instead. Still deferred, not redesigned. See [ADR 0006](./adr/0006-deferred-hooks-and-worktrees.md).

## 7. Change process

Any change to the crew's roles, flow, or contracts starts with a PR that updates this file and, if it represents a new decision, adds an ADR under `docs/adr/`. Library files follow from the updated spec — never the other way around.

## 8. Model routing per role

**Scope:** this section applies only where the model is selectable — that is, harness mode (§9). Where the model is imposed and is not Claude, no routing table applies, no strong-model review gate exists, and the checklists carry the whole load. Narrowed by [ADR 0012](./adr/0012-claude-library-over-marketplace.md).

Per [ADR 0009](./adr/0009-model-routing.md), dispatch-time model choice is doctrine, not accident. Defaults (overridable per project — see below):

| Role / work | Model | Rationale |
| --- | --- | --- |
| `agent-crew-butler` | session model | Main-session persona, never dispatched — inherits |
| Code exploration / navigation fan-out | Haiku | High volume, low reasoning |
| `agent-crew-dev` | Sonnet | High-volume implementation; cost/quality sweet spot |
| `agent-crew-tester` | Sonnet | Scenario design is mid-reasoning; suite execution is tool output |
| `agent-crew-critic` (both lenses) | strong model (Opus-class) | Gate verdicts cascade; a false "pass" costs more than a strong dispatch |

The butler passes the model **explicitly in every `Agent` dispatch** — `model:` frontmatter is never relied on. When `agent-crew-dev` exhausts `dev-loop`'s bounded repair budget, the butler may re-dispatch the task once on the strong model with the failure report as context (advisor escalation); no agent self-escalates. A `model-routing` section in the client project's `CLAUDE.md` overrides any default; an unavailable model falls back to the session model, reported to the user, never silently. In solo mode the table is a per-phase recommendation — same table, human choice.

The butler agent file carries a runtime copy of this table (it is read in projects that do not contain this repo); this section is the authoritative version, and §7's spec-first process is the guard against drift.

## 9. Consumption modes

The library is the product; agents are a convenience. Per [ADR 0012](./adr/0012-claude-library-over-marketplace.md) it is consumed two ways, both first-class.

**Harness mode.** Claude Code discovers `.claude/skills/` and `.claude/agents/` with no installation; symlinking into `~/.claude/` makes them available across projects. Agent dispatch, tool allowlists (§6) and model routing (§8) all apply here, and only here.

**Paste mode.** No harness, no agents, an imposed model: the relevant `SKILL.md` is opened and pasted into the conversation. This is the mode the current engagement runs in, and it sets two hard constraints:

- **File size is a contract.** A `SKILL.md` that does not fit a paste window is unusable regardless of how coherent it is — this is the granularity rule of [ADR 0013](./adr/0013-craft-skill-taxonomy.md), not a style preference.
- **Cross-references by name are dead links.** [ADR 0008](./adr/0008-skills-first-doctrine.md)'s "reference by name, never restate" assumes a harness able to load the named target; a bare conversation has only what it was given. The single-source-of-truth rule is unchanged — entry-point skills additionally declare at the top what must be pasted alongside them.

Paste mode has no agents, therefore no isolation and no tool restriction: nothing mechanically prevents the model from grading its own work. The separations of §1 survive there only as discipline held by the operator — running `test-craft` and the review lenses as deliberately separate passes, against the acceptance checklist, rather than as a continuation of the implementation.
