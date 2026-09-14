# security — the security lens of a review

> Run by: `agents/agent-review.md`. Last watch: 2026-09-14 · Target: OWASP Top 10:2025

## Steps

1. **Read the whole change** and locate its security surface: auth, input, secrets, dependencies, configuration. No surface (pure UI, docs) → say so and stop.
2. **Check it against the OWASP Top 10:2025 classes that apply:** broken access control, security misconfiguration, software supply chain failures, cryptographic failures, injection, insecure design, authentication failures, software or data integrity failures, security logging and alerting failures, mishandling of exceptional conditions. When the change touches an LLM surface (agent, prompt, tool call, RAG), check it against OWASP's LLM Prompt Injection Prevention and AI Agent Security cheat sheets too.
3. **Check dependencies and the supply chain:** known CVEs, abandoned packages, and pipeline integrity (build scripts, CI permissions, secrets in CI), with version and advisory when known.
4. **Write each finding** with severity, location, impact and a concrete remediation — never just "looks risky".
5. **Order:** critical findings (live secret, auth bypass, RCE-class) first, in the report and in the first line of the reply.

## NEVER

- Never print a secret in cleartext — a truncated form only, in every output, log or file
- Never write or run exploit code, even as a proof of concept
- Never run an active or intrusive scan against a live system without explicit, already-confirmed authorisation
- Never silently downgrade or omit a finding

## Output

The **Security** section of `docs/reviews/<slug>.md`: findings with severity, location, impact and remediation, critical first, secrets redacted.

## Sources

- [OWASP Top 10:2025](https://top10.owasp.org/2025)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
