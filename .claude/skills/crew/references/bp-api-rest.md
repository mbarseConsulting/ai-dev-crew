# api-rest — the HTTP contract

> Load when: an HTTP endpoint, a status code, a payload, OpenAPI. Last watch: 2026-09-14

## MUST

- Name paths after resources, plural, kebab-case (`/purchase-orders/{id}/line-items`) — the method is the verb
- Design the contract from the domain the client consumes, never from the persistence model — an API that mirrors the database turns every schema refactoring into a breaking change
- Use one field-naming convention and one date format service-wide, RFC 3339 in UTC unless the domain needs local time
- Carry the outcome in the status code: `201` with `Location` on creation, `202` accepted but not done, `204` deliberately no body, `400` unparseable, `401`/`403` unauthenticated/unauthorised, `404` absent, `409` state conflict, `422` valid but refused by a rule — and the same choice everywhere in the service
- Return one error envelope for every endpoint, `application/problem+json` (RFC 9457) unless the project has an established shape; validation errors extend it with a field list — a second error shape doubles every client's error path, and the second one is always less tested
- Check the IANA "HTTP Problem Types" registry before minting a project `type` URI — a custom URI for a registered problem fragments the tooling built around the standard ones
- Check every level of a nested path against its parent — `/structures/{structureId}/lockers/{lockerId}` authorised at structure level must verify the locker belongs to that structure, or a caller swaps in any locker id from another structure (IDOR, OWASP A01)
- Give any retryable `POST` an `Idempotency-Key` header (the IETF draft's name, expired without becoming an RFC, still the de-facto one); make `PUT` and `DELETE` idempotent in fact — a client that timed out does not know whether the request landed, and replaying a `POST` creates a duplicate
- Use one pagination mechanism service-wide and tell the caller how to reach the next page — a bare list leaves it guessing
- Version once, announced, by URL prefix or header — either works, two do not
- Write an OpenAPI `summary` as a short capitalised phrase with no trailing period, and document every response the endpoint can produce, errors included — a spec that only describes `200` makes each client discover failures in production

## NEVER

- Never put a verb in a path (`/getUser`, `/orders/create`)
- Never return `200` with an error payload — a client that trusts the status code treats the failure as a success
- Never let a `GET` mutate state or require a body
- Never expose internal detail in an error payload — stack trace, SQL, exception class, internal id; they go to the logs, with a correlation id the client may receive
- Never change an existing contract (path, field, status code, error shape) without flagging it and stopping — an added optional field is compatible, a renamed or removed one is not

## Flag, don't fix

- Migrating an established error shape to RFC 9457 — breaking for every client
- Changing an existing pagination style
- Adding hypermedia where no client uses it
- Advertising quotas with the `RateLimit` and `RateLimit-Policy` response headers — still an IETF draft; a client that only learns its quota from a `429` cannot pace itself

## Not here

- Layer boundaries and mapping → `references/bp-layering.md`
- Broker events → `references/bp-kafka.md`; socket contracts → `references/bp-ws.md`

## Sources

- [RFC 9457 — Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc9457.html)
- [RFC 9110 — HTTP Semantics](https://www.rfc-editor.org/rfc/rfc9110.html)
- [RFC 3339 — Date and Time on the Internet](https://www.rfc-editor.org/rfc/rfc3339.html)
- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
- [IETF draft — Idempotency-Key header](https://datatracker.ietf.org/doc/draft-ietf-httpapi-idempotency-key-header/)
- [IETF draft — RateLimit headers](https://datatracker.ietf.org/doc/draft-ietf-httpapi-ratelimit-headers/)
