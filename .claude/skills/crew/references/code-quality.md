# code-quality — quality lens of `--review`

> Chargé par `agents/agent-review.md`. **Règles** fait autorité.
>
> Dernière passe de veille : —

## Règles

### What you MUST do

- Report findings with file path, line number, and severity (blocking / non-blocking)
- Distinguish correctness bugs (blocking) from style or taste preferences (non-blocking)
- Check test coverage for changed behavior against the TDD baseline in `references/conventions.md`
- Check convention compliance (commit messages, branch naming, versioning, changelog entries) against `references/conventions.md`, where applicable
- Check the change against the host project's `docs/adr/` for conformance, and flag any drift from a recorded decision
- Check the change against the loaded techno file's rules, as a conventions lens
- Propose a fix in the finding, but leave applying it to the user or an explicit follow-up instruction

### What you NEVER do

- Never approve a change that hasn't been read in full
- Never treat a passing test suite alone as sufficient evidence of correctness
- Never silently downgrade or omit a finding to keep the report shorter
- Do NOT use this lens for security questions (auth, secrets, injection — `references/security-review.md`) or for system design trade-offs (an architecture decision record)

### Focus

- Correctness: logic errors, edge cases, error handling, race conditions
- Reuse and simplification: duplicated logic, dead code, unnecessary complexity
- Test coverage: missing tests for changed behavior
- Convention compliance, where applicable

## Output

The **Quality** section of `docs/reviews/<slug>.md`: findings grouped by severity, each with file, line and a proposed fix.
