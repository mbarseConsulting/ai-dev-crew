# ADR 0009 — Model routing per role

**Status:** accepted — 2026-07-19

## Context

The SPEC had no cost doctrine. The operator runs the crew primarily on a personal subscription (~€20/month); industry evidence puts per-step model routing at 30–50% cost reduction with equal or better output, and a three-tier routing at ~51% versus uniform strong-model deployment. Two additional facts shape the mechanism: (1) `model:` frontmatter is ignored on named agent spawns, so routing cannot be delegated to agent files; (2) the butler is the single dispatch point for every crew agent (ADR 0007), so dispatch-time routing has exactly one home.

## Decision

1. **Default routing table** (crew defaults, not absolutes):
   - `agent-crew-butler`: session model (main-session persona, never dispatched — inherits).
   - Code exploration / navigation fan-out: Haiku.
   - `agent-crew-dev`: Sonnet.
   - `agent-crew-tester`: Sonnet.
   - `agent-crew-critic` (both lenses): strong model (Opus-class) — gate verdicts cascade downstream; a false "pass" costs more than a strong-model dispatch.
2. **Explicit model on every dispatch.** The butler passes `model` explicitly in every `Agent` call. Frontmatter is never relied on.
3. **Advisor escalation.** When `agent-crew-dev` exhausts `dev-loop`'s bounded repair budget and reports failure (existing behavior, unchanged), the butler MAY re-dispatch the same task once on the strong model, with the failure report as context. No self-escalation by any agent: the butler pays, the butler decides.
4. **Per-project override.** A `model-routing` section in the client project's `CLAUDE.md` overrides any default. Absent section → defaults above. Model unavailable at dispatch → fall back to the session model and tell the user; never silent.
5. **Solo mode.** The table is a per-phase recommendation for humans running skills by hand; same table, same logic, human choice.

## Consequences

- SPEC gains §8 (authoritative doctrine). The butler agent file carries a runtime copy of the table because the plugin is installed in client projects that do not contain this repo; SPEC §7's spec-first change process is the guard against drift between the two.
- Enforcement is behavioral for now, following the deferred-enforcement pattern of [ADR 0006](./0006-deferred-hooks-and-worktrees.md) (explicit, tracked gaps): no `routing.yml`, no hooks, no consumption metering until the behavioral rule is shown to leak.
- ADR 0011 (bounded self-improvement) is only activatable once this ADR is implemented — routing is what makes a self-improvement run viable on a subscription budget.

## Alternatives considered and rejected

- **Tooled enforcement (`routing.yml` + hook):** premature optimization; build mechanical enforcement only after the routing table proves its value and the behavioral rule leaks.
- **Critic on Sonnet with advisor escalation:** saves tokens at the one point where model capability changes the verdict; rejected — the review gate is the wrong place to economize.
