# quality — the quality lens of a review

> Run by: `agents/agent-review.md`. Last watch: —

## Steps

1. **Read the whole change**, and the `docs/adr/` or `docs/design/` file it came from when one exists.
2. **Check correctness:** logic errors, edge cases, error handling, race conditions.
3. **Check reuse and simplicity:** duplicated logic, dead code, complexity the change did not need.
4. **Check tests:** every changed behavior has one, per `references/bp-conventions.md`; a green suite alone proves nothing about coverage.
5. **Check conformance:** the techno file's rules and every loaded reference, as a conventions lens; commit, version and changelog per `references/bp-conventions.md`; the host project's `docs/adr/`, flagging any drift from a recorded decision.
6. **Write each finding** with file, line, severity (blocking / non-blocking) and a proposed fix. A correctness bug is blocking, a taste preference is not.

## NEVER

- Never approve a change you have not read in full
- Never silently downgrade or omit a finding to keep the report short
- Never apply a fix — findings are proposed, the user or a follow-up applies them
- Never cover security here (auth, secrets, injection) — that is `references/proc-security.md`

## Output

The **Quality** section of `docs/reviews/<slug>.md`: findings grouped by severity, each with file, line and a proposed fix.
