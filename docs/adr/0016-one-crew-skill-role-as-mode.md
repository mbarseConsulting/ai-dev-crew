# 0016 — One `crew` skill: roles are its agents, technologies its technos

**Status:** accepted — 2026-09-14. Amends [ADR 0008](./0008-skills-first-doctrine.md) (the butler exception), [ADR 0014](./0014-activity-first-skill-agent-pattern.md) (decisions 1, 2 and 5) and [ADR 0015](./0015-library-project-boundary-and-domain-axis.md) (decisions 1 and 5).

## Context

Commit `c7b8557` set a rule without recording it: **a skill names no other skill.** A skill is used on its own far more often than inside a harness able to load a named target, so every pointer to a sibling is a dead link in the normal case. `SPEC.md`, `doctrine.md` and [ADR 0014](./0014-activity-first-skill-agent-pattern.md)'s fourth graph edge kept teaching the opposite.

Applied to ADR 0014's activity skills, the rule left most of them unable to work: `crew-review`, `crew-test`, `crew-watch` and `crew-architecture` all needed the personas and references that lived in `crew-dev`. What those skills share is the **stack knowledge**; what differs is the **role** held against it.

Two further facts:

- **The butler exception rested on a false premise.** ADR 0008 kept the butler outside the skills because "no skill loaded in one session can reproduce" dispatch. A skill read in the main conversation has the `Agent` tool.
- **`crew-project` came back into the library** (`7863f65`, `cda2052`) without an ADR, reversing ADR 0015's "outside this repository".

## Decision

**1. One skill, `crew`, laid out as the house Skill+Agent template: `agents/` holds the roles.**

```
crew/
├── SKILL.md      router: role flag + technology detection
├── agents/       agent-dev · agent-tester · agent-review · agent-butler
├── technos/      java · angular · node-bff · python
└── references/   shared knowledge and agent-owned procedures
```

**2. The flow is one line.** `/crew` detects the technology and picks the role — `agent-dev` by default. The router reads `agents/agent-dev.md`; the agent reads `technos/java.md`; the techno lists its own references (`java-spring`, `persistence`), and `SKILL.md`'s shared table adds the cross-stack ones the change's context calls for (`conventions`, `layering`, `api-rest`, `kafka`, `ws`, `iot`). The agent develops.

| Flag | Agent |
| --- | --- |
| `-d` (default) | `agent-dev` — develops, writes the tests |
| `-t` | `agent-tester` — runs the full suite, fixes red tests from the output it holds, lists every file it modified |
| `-r` | `agent-review` — quality and security review, one verdict |
| `-b` | `agent-butler` — qualifies the need, launches the other roles, holds the gates |
| `-a` | `agent-butler` with `references/architecture.md` — a decision is a dialogue |
| `-w` | `agent-butler` with `references/watch.md` — library maintenance |

**3. An agent is a role; a technology is a techno.** Technologies are no longer agents. A technology still gets its own context when the butler launches one `agent-dev` per technology, on disjoint files.

**4. `-c` launches instead of reading.** The router reads the agent inline by default; `-c` launches it as a subagent — except the butler, which talks to the user and so always runs inline or as the whole session. `.claude/agents/agent-{dev,tester,review,butler}.md` are launchable shells: they preload `crew` through `skills:`, point at the matching `crew/agents/` file, and carry the toolset (no `Agent` for dev, tester and review; no `Edit` for review and butler).

**5. One verb per role.** Only the butler launches other agents.

**6. A skill names no other skill, without exception.** Composing `crew` with `crew-project` is an agent's job: `.claude/agents/agent-butler.md` preloads both.

**7. Independence.** `-t` or `-r` in a conversation that wrote or briefed the same change (it ran `-d` or `-b` on it) is labelled **"Self-check — not the gate"** and gives no verdict. A fresh conversation, or `-c`, avoids it.

**8. Project files live in `crew-project/`, gitignored.** `SKILL.md` is committed and permanent; `index.md` and `<project>.md` are never committed. ADR 0015 decision 5 (no generator) is superseded.

## Alternatives considered

- **Keep separate skills and supply the needed files as input.** Rejected: personas and references are the library's own content.
- **Copy the needed rules into each skill.** Rejected by ADR 0008: two copies of a rule drift.
- **Revert `c7b8557` and allow naming.** Rejected: paste mode — the mode [ADR 0012](./0012-claude-library-over-marketplace.md) calls the one that governs — would be full of dead links.
- **Technologies as agents, as in ADR 0014.** Rejected: a role and a technology are different axes; the per-technology context is obtained by launching one `agent-dev` per technology.

## Consequences

- Skills: `crew`, `crew-project`. Launchable agents: `agent-dev`, `agent-tester`, `agent-review`, `agent-butler`.
- The review verdict scale lives in `agents/agent-review.md`, so every review gives the same verdict.
- The model-routing table's runtime copy lives in `agents/agent-butler.md`; `SPEC.md` §8 stays authoritative.
- `crew` must not set `disable-model-invocation`: it also prevents preloading into subagents.
- `scripts/crew-doctor.sh` guards the layout, run by the versioned `pre-commit` hook.
