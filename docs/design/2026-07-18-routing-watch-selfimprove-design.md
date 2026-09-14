# Design — Model Routing, Watch Loop, Bounded Self-Improvement

**Status:** validated design, approved in session on 2026-07-18. Supersedes the open questions of [`premise-freelance-vision.md`](./premise-freelance-vision.md). Implementation must ratify each part as an ADR (0009, 0010, 0011) and update [`SPEC.md`](../SPEC.md) *before* plugin files change, per SPEC §7.

**Scope decision:** of the premise's eight drivers, five are already ratified and shipped (unit-first = solo-mode doctrine; crew mode = the four agents; critic = `agent-crew-critic`). The genuinely new scope is the three parts below, sequenced: routing first (it conditions the economic viability of the other two), then watch, then self-improvement. BMAD is **not** used for this cycle — the scope fits three ADRs, and SPEC §5 already defines BMAD as an upstream tool for client specs, not for the crew's own evolution.

---

## Part 1 — ADR 0009: model routing per role

**Problem.** SPEC has no cost doctrine. The operator runs on a ~€20/month subscription; industry evidence puts per-step model routing at 30–50% cost reduction with equal or better output. The existing memory rule "always pass model explicitly in Agent dispatches; frontmatter is ignored on named spawns" is not yet doctrine.

**Default routing table** (crew defaults, not absolutes):

| Role / work | Model | Rationale |
| --- | --- | --- |
| `agent-crew-butler` | session model | Main-session persona, never dispatched — inherits, nothing to route |
| Code exploration / navigation (search fan-out) | Haiku | High volume, low reasoning; ~15× cheaper than Opus-class |
| `agent-crew-dev` | Sonnet | High-volume implementation; documented cost/quality sweet spot |
| `agent-crew-tester` | Sonnet | Scenario design is mid-reasoning; suite execution is tool output, not model work |
| `agent-crew-critic` (both lenses) | strong model (Opus-class) | Gate verdicts cascade downstream — the one place capability changes the outcome. A false "pass" costs more than a strong-model dispatch |

**Advisor escalation — grafted onto the existing loop.** `dev-loop` already has a bounded repair budget. On budget exhaustion the dev stops and reports (current behavior, unchanged); the butler then re-dispatches the same task **once** on the strong model, with the failure report as context. No self-escalation by the agent: the butler pays, the butler decides.

**Mechanism.** The model is explicit in every butler dispatch — never delegated to agent frontmatter. In solo mode the table is documented as a per-phase recommendation; the human picks the model, same table, same logic.

**Per-project override.** A `model-routing` section in the client project's `CLAUDE.md` overrides the defaults (e.g. a Bedrock client without Haiku, a client imposing a model). Absent section → SPEC defaults. Model unavailable at dispatch → fall back to the session model and tell the user; never silent.

**Non-goals.** No `routing.yml`, no hooks, no consumption metering. Behavioral enforcement first, following the deferred-enforcement pattern of [ADR 0006](../adr/0006-deferred-hooks-and-worktrees.md) (explicit, tracked gaps); tooling waits for evidence that the behavioral rule leaks.

---

## Part 2 — ADR 0010: watch → craft maintenance loop

> **Ratified 2026-09-14** as [ADR 0010](../adr/0010-watch-craft-maintenance-loop.md). That ADR keeps this shape and settles the duplication objection raised just below, which [ADR 0013](../adr/0013-craft-skill-taxonomy.md) had made concrete: `SKILL.md` is normative, `best-practices.md` explains, and `SKILL.md` wins any disagreement.

**Problem.** Searching the web for best practices at usage time is too costly, but a parallel `best-practices.md` would create a second home for rules that already live in `angular-craft` / `java-craft` / `python-craft` / `dev-conventions`, violating ADR 0008. The premise's §4 (local best-practices reference) and §8 (tech-watch agent) are one feature: the **update process** for the craft skills.

**Shape.** Skills-first, like the rest of the crew: a `crew-watch` skill carries the whole procedure; an agent shell is optional (a human can run the skill by hand in solo mode).

**Procedure carried by the skill:**

1. **Scope:** the technologies of the installed craft skills plus cross-cutting conventions. No general "AI is moving" watch — only findings that can change an existing craft-skill rule.
2. **Collection:** per-technology sources declared inside the skill (official release notes, reference guides). No open crawling; cost is bounded per run.
3. **Doctrinal diff:** for each finding, the question is not "is this interesting?" but "**which existing rule becomes wrong or incomplete?**". No rule impacted → digest only, no PR.
4. **Dual output:**
   - `docs/watch/YYYY-MM-DD.md` — short, sourced digest (the operator's learning support);
   - **one PR per impacted craft skill** — never a direct commit. Reviewing the PR *is* the learning moment, and the gate that keeps a hallucinated watch from corrupting the references.
5. **Evidence rule:** no rule change without a cited source in the PR. An uncited craft-skill change is rejectable on sight.

**Source-list liveness.** Watch quality is bounded by the declared source list. The list lives *inside* the skill, versioned. Each digest ends with a "sources silent this run" line; three consecutive silent runs for a source = signal to revise the list.

**Placement.** Repo-local in ai-dev-crew (`.claude/skills/crew-watch` + optional agent shell), **not** a shipped plugin: clients consume up-to-date craft skills, they do not maintain them. Shipping watch later is a separate product decision, not a default.

**Trigger.** Manual first (`/crew-watch`); weekly cadence as target. Automated scheduling is **out of this ADR** — it belongs to ADR 0011, because "when does it run unattended" is exactly the quota question 0011 arbitrates. Model: Sonnet (research + synthesis, no architecture arbitration).

---

## Part 3 — ADR 0011: bounded self-improvement

**Problem.** Agents working on the crew's own product must be *possible* but never *required*, on a subscription budget that primarily serves client missions.

**Principle: dogfooding, not a fleet.** ai-dev-crew becomes a client project of its own crew — same canonical flow (butler → dev → tester → critic), same skills, same file contract. No new infrastructure: "agents work on my product" = a crew session pointed at the ai-dev-crew repo.

**The bounds (they are the ADR):**

1. **Account:** the operator's own account only, never a client's. Crew improvement is never billed — in tokens or in confusion — to a mission.
2. **Trigger:** manual by default. Nominal case: available quota (end of window, idle period) → launch `crew.sh` on the repo → the run consumes what would have expired. Scheduled runs (weekly, paired with the watch run) exist but are **opt-in, disabled by default** — no background consumption that was not explicitly armed.
3. **Unit of work:** one run = **one backlog item**, never "improve the product". Item sources: watch digests (Part 2), `docs/reviews/` reports, operator notes — consolidated in a versioned backlog file at `docs/backlog.md`. No item ready → the run stops there, at near-zero cost.
4. **Output:** a **PR, never a merge**. The final gate stays human, exactly like watch PRs. SPEC §7 applies to the crew itself: a self-improvement run touching roles or contracts must include the SPEC/ADR update in its PR, or the critic rejects it.
5. **Economics:** Part 1 routing applies in full — it is what makes a run viable at ~€20/month. Explicit dependency: ADR 0011 is only activatable after ADR 0009.

**Considered and rejected: Morpho-style 24/7 fleet.** Recorded in the ADR as a rejected alternative, with motive: subscription budget rules out mandatory background consumption, and current industry practice itself moves toward on-demand generated agent teams rather than resident fleets. The question is closed in writing.

---

## Implementation order

1. ADR 0009 + SPEC routing section + butler dispatch-brief updates.
2. ADR 0010 + `crew-watch` skill + optional shell agent.
3. ADR 0011 + backlog file convention + `crew.sh` self-improvement entry point.

Each step is independently shippable; each later step depends on the earlier ones.
