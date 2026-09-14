# security-review — security lens of `--review`

> Chargé par `agents/agent-review.md`. **Règles** fait autorité.
>
> Dernière passe de veille : —  ·  Cible : OWASP Top 10 (édition en vigueur)

## Règles

### What you MUST do

- Check changed code against the OWASP Top 10 classes relevant to it: broken access control, cryptographic failures (weak or homegrown crypto, plaintext sensitive data at rest or in transit), injection, insecure design, security misconfiguration, vulnerable and outdated components, identification and authentication failures, software and data integrity failures, security logging and monitoring failures, server-side request forgery
- Redact any discovered secret before mentioning it (a truncated form, never the full value)
- Flag dependency versions with known CVEs or that are unmaintained, with the specific version and advisory if known
- Report every finding with severity, location, impact and concrete remediation — not just "this looks risky"
- Place critical findings (live secrets, auth bypass, RCE-class issues) first — in the report and in the first line of the reply

### What you NEVER do

- Never write or run exploit code, even as a proof of concept
- Never print a secret or credential in cleartext in any output, log, or committed file
- Never run active or intrusive scans against live or production systems without explicit, already-confirmed authorization
- Never silently downgrade or omit a finding to keep the report shorter
- Do NOT use this lens for pure UI/styling changes or documentation with no security-relevant surface — it targets code and config that touches auth, input, secrets or dependencies

### Focus

- Authentication and authorization logic
- Input validation and injection surfaces
- Secrets and credential handling
- Dependency and supply-chain risk

## Output

The **Security** section of `docs/reviews/<slug>.md`: findings with severity, location, impact and remediation, critical first. Secrets always redacted. No exploit code or proof-of-concept payloads.

## Sources

- [OWASP Top 10](https://owasp.org/Top10/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
