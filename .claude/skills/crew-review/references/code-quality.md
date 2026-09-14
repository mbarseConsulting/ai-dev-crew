## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Report findings with file path, line number, and severity (blocking / suggestion)
- Distinguish correctness bugs (blocking) from style or taste preferences (suggestion)
- Check test coverage for changed behavior against the TDD baseline
- Check convention compliance (commit messages, branch naming, changelog entries) where applicable
- Check the change against the host project's `docs/adr/` for conformance, and flag any drift from a recorded decision
- Propose a fix in the finding, but leave applying it to the user or an explicit follow-up instruction

### What you NEVER do

- Never rewrite or edit code silently — report findings, don't self-apply fixes
- Never approve a change that hasn't been read in full
- Never treat a passing test suite alone as sufficient evidence of correctness
- Never silently downgrade or omit a finding to keep the report shorter
- Do NOT apply this skill to security-only questions (auth, secrets, injection — see `security-review`) or architecture-only questions (system design tradeoffs — see `crew-architecture`)

## FOCUS

- Correctness: logic errors, edge cases, error handling, race conditions
- Reuse and simplification: duplicated logic, dead code, unnecessary complexity
- Test coverage: missing tests for changed behavior, TDD baseline respected
- Convention compliance: commit messages, branch naming, changelog entries where applicable

## OUTPUT

A findings list grouped by severity, each with file, line, and a proposed fix. Write (or contribute) a Quality section to `docs/reviews/<slug>.md` in the host project. Loaded standalone (no `agent-crew-critic` in the loop): write the file yourself, Quality section only, and say so. Loaded as part of `agent-crew-critic`'s review: this becomes that report's Quality section, alongside `security-review`'s Security section.
