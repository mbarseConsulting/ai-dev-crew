---
name: crew-watch
description: "Use when: (1) running a periodic tech-watch pass to keep the library's technology references from going stale, (2) checking whether a specific release or announcement invalidates an existing rule, (3) recording what changed in a technology the library already has rules about."
---

## OPTIONS

- **Full** — every technology declared in `references/sources.md`. Default.
- **Scoped** — one technology, one persona or one reference, e.g. after a major release.

## BEHAVIOR

### What you MUST do

Execute in order. This is a maintenance skill for the library itself, never one to run at a client site.

1. **Scope.** Take the technologies from the personas in `crew-dev/agents/` and the references in `crew-dev/references/`, plus cross-cutting conventions. A technology with no persona is out of scope, and so is general industry news — the only findings that matter are those able to change an existing rule.
2. **Collect.** Read the monitoring feeds declared in `references/sources.md`, and nothing else. No open crawling: the cost of a run is bounded by that list, deliberately.
3. **Doctrinal diff.** For each finding, the question is never "is this interesting?" — it is **"which existing rule becomes wrong or incomplete?"** Name the skill and quote the rule, or drop the finding.
4. **Route each surviving finding** by what it actually changes:
   - it changes what is forbidden or required → a PR touching the persona (or the reference's `## Règles` section), and its `## Pourquoi` section for the reasoning
   - the rule still holds but the reasoning deepens → `best-practices.md` alone
   - neither → the digest alone
5. **Write the digest** to `docs/watch/YYYY-MM-DD.md`: what was checked, what changed, what it impacts, every claim with its source link. End it with a **"sources silent this run"** line naming every feed that produced nothing.
6. **Open one PR per impacted persona or reference.** Never commit a craft-skill change directly. Each PR cites the source for every rule it changes, and updates that file's veille date.

### What you NEVER do

- Never change a rule without a cited source in the PR — an uncited craft-skill change is rejectable on sight, and is the one way a hallucinated finding could corrupt a reference the whole library trusts
- Never commit directly to a persona or a reference: reviewing the PR is both the gate and the point, since that review is where the operator actually learns
- Never introduce a MUST or NEVER into a `## Pourquoi` section — it explains, it does not legislate; where it and `## Règles` disagree, `## Règles` is right ([ADR 0010](../../../docs/adr/0010-watch-craft-maintenance-loop.md))
- Never touch a le **profil projet**: those are maintained by reading the employer's codebase, not by veille, and they are gitignored
- Never widen the source list mid-run to chase a finding — note the gap in the digest and revise `references/sources.md` deliberately
- Never report a finding as impacting a rule without naming the skill and quoting the rule
- Do NOT apply this skill to implementing a change (`crew-dev`) or to reviewing one (`crew-review`)

## FOCUS

- Which existing rule a finding invalidates — not what is new in general
- Evidence: a source link per claim, no exception
- One PR per impacted skill, reviewed by a human
- Liveness of the source list itself

## OUTPUT

A digest at `docs/watch/YYYY-MM-DD.md` — checked, changed, impacted, sources, and the "sources silent this run" line — plus one pull request per impacted persona or reference, each citing its sources and updating that file's veille date. A run that changes no rule produces a digest and no PR; that is a normal outcome, not a failed run.
