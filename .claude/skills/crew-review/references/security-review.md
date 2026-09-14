## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Check changed code against the OWASP Top 10 classes relevant to it (injection, broken access control, cryptographic failures — weak/homegrown crypto, plaintext sensitive data at rest or in transit, auth failures, insecure design, misconfiguration, vulnerable components, data integrity, logging failures, SSRF)
- Redact any discovered secret before mentioning it (show a truncated form, never the full value)
- Flag dependency versions with known CVEs or that are unmaintained, with the specific version and advisory if known
- Report every finding with severity and concrete remediation, not just "this looks risky"
- Place critical findings (live secrets, auth bypass, RCE-class issues) first in the report — don't bury them under lower-severity items

### What you NEVER do

- Never write or run exploit code, even as a proof of concept
- Never print a secret or credential in cleartext in any output, log, or committed file
- Never run active/intrusive scans against live or production systems without explicit, already-confirmed authorization
- Never silently downgrade or omit a finding to keep the report shorter
- Do NOT apply this skill to pure UI/styling changes or documentation with no security-relevant surface — it targets code and config that touches auth, input, secrets, or dependencies

## FOCUS

- Authentication and authorization logic
- Input validation and injection surfaces
- Secrets and credential handling
- Dependency and supply-chain risk

## OUTPUT

A findings list with severity, location, impact, and remediation, critical findings first. Secrets always redacted. No exploit code or proof-of-concept payloads. Write (or contribute) a Security section to `docs/reviews/<slug>.md` in the host project. Loaded standalone (no `agent-crew-critic` in the loop): write the file yourself, Security section only, and say so — and if a finding is critical, lead with it in your response, not just in the file. Loaded as part of `agent-crew-critic`'s review: this becomes that report's Security section, alongside `code-quality`'s Quality section.
