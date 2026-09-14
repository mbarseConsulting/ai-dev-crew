# Mode `--watch` — keep this skill's rules from going stale

Loaded by `agents/agent-butler.md` under `-w`. Options: **Full** (default) — every target declared in `references/sources.md`; `--scoped <target>` — one techno or one reference, e.g. after a major release.

A maintenance mode for this library itself, never one to run at a client site.

## BEHAVIOR

### What you MUST do

Execute in order.

1. **Scope.** The targets are this skill's techno files in `technos/` and references in `references/`. A target with no feed in `references/sources.md` cannot be watched: list it in the digest. General industry news is out of scope — the only findings that matter are those able to change an existing rule.
2. **Collect.** Read the feeds declared in `references/sources.md`, and nothing else. No open crawling: the cost of a run is bounded by that list, deliberately.
3. **Doctrinal diff.** For each finding, the question is never "is this interesting?" — it is **"which existing rule becomes wrong or incomplete?"** Name the file and quote the rule, or drop the finding.
4. **Route each surviving finding** by what it actually changes:
   - it changes what is forbidden or required → the techno file's MUST/NEVER, or the reference's `## Règles`, plus the reasoning in its `## Pourquoi`
   - the rule still holds but the reasoning deepens → the reference's `## Pourquoi` alone
   - neither → the digest alone
5. **Write the digest** to `docs/watch/YYYY-MM-DD.md` in this library's repository: what was checked, what changed, what it impacts, every claim with its source link. End it with a **"sources silent this run"** line naming every feed that produced nothing, and a **"not watchable"** line naming every target without a feed.
6. **Open one PR per impacted file.** Each PR cites the source for every rule it changes and updates that file's `Dernière passe de veille` date.

### What you NEVER do

- Never change a rule without a cited source in the PR — an uncited change is rejectable on sight, and is the one way a hallucinated finding could corrupt a file the whole library trusts
- Never commit directly to a techno file or a reference: reviewing the PR is both the gate and the point, since that review is where the operator actually learns
- Never put a MUST or NEVER into a `## Pourquoi` section — it explains, it does not legislate; where it and `## Règles` disagree, `## Règles` is right
- Never touch a project file: those are maintained by reading the employer's codebase, not by watch
- Never widen the source list mid-run to chase a finding — note the gap in the digest and revise `references/sources.md` deliberately
- Do NOT use this mode to implement a change (`--dev`) or to review one (`--review`)

## OUTPUT

A digest at `docs/watch/YYYY-MM-DD.md` — checked, changed, impacted, sources, the "sources silent this run" and "not watchable" lines — plus one pull request per impacted techno file or reference, each citing its sources and updating that file's watch date. A run that changes no rule produces a digest and no PR; that is a normal outcome, not a failed run.
