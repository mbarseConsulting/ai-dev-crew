# 0002 — Three generic agents plus skills by work type, over one agent per technology

## Context

v1 shipped one dedicated agent per domain or technology (`agent-crew-reviewer`, `agent-crew-architect`, `agent-crew-security`, `agent-crew-angular`) — a pattern that multiplies agents linearly with every new technology or role the crew needs to cover. Adding Java or Python support the same way would mean two more agents, each re-stating the same boilerplate (test coverage, conventions, escalation rules) with only a technology-specific slice actually differing.

## Decision

Restructure to 3 generic, technology-agnostic agents (`agent-crew-butler` / `agent-crew-dev` / `agent-crew-critic`) that load work-type skills by name. All technology- and domain-specific knowledge (Angular conventions, Java conventions, code-quality checks, security checks) lives in skills, not in agent personas. Skills are portable Markdown; agents are the Claude-specific persona and dispatch layer on top of them.

## Alternatives considered

- **Keep one agent per technology**, adding `agent-crew-java`, `agent-crew-python`, etc. as needed. Rejected: agent count grows unbounded, and each new agent duplicates the same guardrail boilerplate that a shared `agent-crew-dev` only needs to state once.
- **One single do-everything agent.** Rejected: collapses the separation of duties a dedicated critic provides (see [ADR 0003](./0003-butler-critic-separation.md)), and makes the tool-allowlist enforcement in [ADR 0004](./0004-role-tool-allowlists.md) meaningless, since one agent would need every tool anyway.

## Consequences

Adding a new technology (say, Go) means adding one skill (`go-craft`) and, if it needs independent install, one `plugin.json` — no new agent. Skills are portable beyond Claude Code (plain Markdown, no agent-specific frontmatter beyond the house `name`/`description`), so the domain knowledge could in principle be reused by a different tool. Cost: `agent-crew-dev`'s persona is less specialized per technology than a dedicated agent would be; correctness now depends on it actually loading the right skill by name every time.
