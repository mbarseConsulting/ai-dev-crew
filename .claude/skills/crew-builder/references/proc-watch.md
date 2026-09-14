# watch — keep crew's rules from going stale

> Run by: `SKILL.md` under `-w`. Full (default): every target in `references/sources.md`. `--scoped <target>`: one techno or reference, e.g. after a major release.

## Steps

1. **Scope.** The targets are the files in `../crew/technos/` and `../crew/references/`. A target with no feed in `references/sources.md` cannot be watched: list it in the digest. General industry news is out of scope — only findings able to change an existing rule matter.
2. **Launch one subagent per target**, in parallel, on `sonnet`, with a self-contained brief: the target file's full content, its feeds from `references/sources.md`, and the one question — *which existing rule becomes wrong or incomplete, and which rule is missing that the feeds now make mandatory?* Each returns findings with a source link, or "nothing". No subagent available → do the targets one by one, inline.
3. **Collect** only from the declared feeds. No open crawling: the cost of a run is bounded by that list, deliberately.
4. **Doctrinal diff.** For each finding, name the file and quote the rule, or drop the finding. "Interesting" is not a criterion.
5. **Route each surviving finding:** it changes what is forbidden or required → the MUST or NEVER list, rule and why clause together; the rule holds but the reasoning deepens → the why clause alone; neither → the digest alone.
6. **Write the digest** to `docs/watch/YYYY-MM-DD.md` at the repository root: what was checked, what changed, what it impacts, every claim with its source link. End with a **"sources silent this run"** line naming every feed that produced nothing, and a **"not watchable"** line naming every target without a feed.
7. **Open one PR per impacted file.** Each PR cites the source for every rule it changes and updates that file's `Last watch` date.

## NEVER

- Never change a rule without a cited source — an uncited change is rejectable on sight, and is the one way a hallucinated finding could corrupt a file the whole library trusts
- Never commit directly to a techno file or a reference — reviewing the PR is both the gate and the point
- Never set a `Last watch` date without a digest for that run
- Never write a rule without its why clause, and never let the why clause add a second rule — one line, one rule, one reason
- Never touch a project file — those are maintained by reading the employer's codebase
- Never widen the source list mid-run — note the gap in the digest and revise `references/sources.md` deliberately

## Output

The digest at `docs/watch/YYYY-MM-DD.md`, plus one pull request per impacted file. A run that changes no rule produces a digest and no PR; that is a normal outcome.
