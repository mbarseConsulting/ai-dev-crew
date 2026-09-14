# 0010 — Watch → craft maintenance loop

**Status:** accepted — 2026-09-14. Shape established in [`docs/design/2026-07-18-routing-watch-selfimprove-design.md`](../design/2026-07-18-routing-watch-selfimprove-design.md) Part 2; this ADR ratifies it and settles the one question that design left open.

## Context

The craft skills now carry roughly 700 lines of best-practice material, each file stamped with a veille date and a source list. Nothing yet makes them age well. A reference that silently goes stale is worse than an absent one: it overrides a model's fresher knowledge with confident, outdated rules, and it does so with the authority of a checklist.

Searching the web at usage time is not the answer — too slow, too costly, and non-deterministic at the exact moment a decision is being made. The premise's §4 (a local best-practices reference) and §8 (a tech-watch agent) are therefore not two features: they are the **update process** for the craft skills.

**The objection the design doc raised, and which must be settled first.** That design warned that a `best-practices.md` sitting beside a craft skill would create "a second home for rules that already live in `angular-craft` / `java-craft`," violating [ADR 0008](./0008-skills-first-doctrine.md). [ADR 0013](./0013-craft-skill-taxonomy.md) then introduced exactly those files. The tension is real and is not resolved by asserting the two files "feel different."

## Decision

**1. The single-source-of-truth rule governs the normative statement, not the explanation.**

| | `SKILL.md` | `references/best-practices.md` |
| --- | --- | --- |
| Carries | the opposable rule — MUST / NEVER | the mechanism, the reason, the alternatives, the sources |
| Answers | *what is forbidden here* | *why, and what the options were* |
| Read by | a reviewer checking code, a model about to write some | a human deciding, or revising the rule |
| Authority | **normative** | explanatory only |

`best-practices.md` restates a rule only as the subject of its explanation, the way a commentary quotes the text it comments. It never introduces a normative rule that `SKILL.md` does not carry. **Where the two disagree, `SKILL.md` wins and `best-practices.md` is the file that is wrong** — that asymmetry is what keeps this from being two homes for one rule.

Operationally this is checkable: a MUST or NEVER appearing only in `best-practices.md` is a defect, and either belongs in `SKILL.md` or is not a rule.

**2. A `watch` skill carries the whole procedure.** Skills-first like the rest of the crew; an agent shell is optional, and a human can run the skill by hand.

1. **Scope** — the technologies of the installed craft skills, plus cross-cutting conventions. No general "AI is moving" watch: only findings able to change an existing rule.
2. **Collection** — per-technology sources declared inside the skill (release notes, reference guides). No open crawling; cost is bounded per run.
3. **Doctrinal diff** — for each finding the question is never "is this interesting?" but "**which existing rule becomes wrong or incomplete?**". No rule impacted → digest only.
4. **Routing the finding**, which follows directly from decision 1:
   - it changes what is forbidden or required → a PR on `SKILL.md`, and on `best-practices.md` for the reasoning;
   - it only deepens the reasoning, the rule standing → `best-practices.md` alone;
   - it affects neither → the digest alone.
5. **Dual output** — `docs/watch/YYYY-MM-DD.md`, a short sourced digest; and **one PR per impacted craft skill**, never a direct commit. Reviewing the PR *is* the learning moment, and the gate that stops a hallucinated finding from corrupting the references.
6. **Evidence rule** — no rule change without a cited source in the PR. An uncited craft-skill change is rejectable on sight.

**3. Source-list liveness.** Watch quality is bounded by the declared source list, which lives inside the skill, versioned. Each digest ends with a "sources silent this run" line; three consecutive silent runs for one source is the signal to revise it.

**4. `house-rules.md` is out of scope.** Those files are maintained by reading the employer's codebase, not by veille. No watch run ever touches them — which is consistent with their being gitignored.

**5. Trigger and cost.** Manual first (`/watch`), weekly as a target. Unattended scheduling belongs to ADR 0011, because "when does it run on its own" is the quota question that ADR arbitrates. The run is a maintenance task on the library itself, so it happens where Claude Code and model choice exist — [ADR 0009](./0009-model-routing.md)'s routing applies, and Sonnet fits: research and synthesis, no architectural arbitration.

## Alternatives considered

- **Search the web at usage time instead of maintaining a local reference.** Rejected: unbounded cost on every task, and a non-deterministic answer at the moment a rule is needed. The premise ruled this out from the start.
- **Let watch commit directly to the craft skills.** Rejected: it removes the only gate between a hallucinated finding and a reference the whole library trusts, and it removes the review that is the operator's actual learning.
- **Put everything in `SKILL.md` and drop `best-practices.md`.** Rejected: `SKILL.md` must fit a paste window ([ADR 0013](./0013-craft-skill-taxonomy.md) granularity rule). Reasoning and sources do not fit, and dropping them would leave rules no one can re-derive or challenge — which is precisely how a reference rots.

## Consequences

- The veille date and `## Sources` section already present in every `best-practices.md` become machinery rather than decoration: the first is what makes staleness visible, the second is what a run reads and reports on.
- `watch` lives in `.claude/skills/watch/`, alongside the skills it maintains. Post-[ADR 0012](./0012-claude-library-over-marketplace.md) there is nothing to ship, so the design's "repo-local, not shipped" placement is now simply the only option; the substance survives — watch is a maintenance skill for the library, never one pasted at a client site.
- ADR 0011 gains a prerequisite: unattended self-improvement has no value until there is something worth running unattended, and this loop is it.
- A craft skill with no declared sources cannot be watched. That is an accepted, visible gap rather than a silent one — `angular-craft`'s `best-practices.md` is empty today, so it has nothing to maintain and will show up as such.
