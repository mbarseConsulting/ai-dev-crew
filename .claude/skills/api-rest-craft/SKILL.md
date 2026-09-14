---
name: api-rest-craft
description: "Use when: (1) designing or changing an HTTP endpoint's path, verb, or status codes, (2) naming or shaping a request/response payload, (3) writing or reviewing OpenAPI annotations, (4) deciding the error, pagination, idempotency, or versioning shape of an exposed API."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Name paths after resources, plural and in kebab-case (`/purchase-orders/{id}/line-items`); the HTTP method is the verb, so the path never contains one
- Design the contract rather than deriving it: field names come from the domain the client consumes, never from whatever the persistence model happens to be called
- Use one consistent field-naming convention and one date format across the whole service — RFC 3339 timestamps in UTC unless the domain genuinely requires a local time
- Carry the outcome in the status code: `201` with a `Location` header on creation, `204` when there is deliberately no body, `202` when the work is accepted but not done, `409` on a state conflict
- Return one single error envelope across every endpoint — `application/problem+json` (RFC 9457) unless the project already has an established shape; validation failures extend that envelope with a field list, they do not get an envelope of their own
- Write an OpenAPI `summary` as a short capitalised phrase with **no trailing period**; anything longer belongs in `description`
- Document every parameter and every response an endpoint can actually produce, error responses included
- Use one pagination mechanism service-wide, and state in the response how the caller reaches the next page
- Give any retryable `POST` an idempotency key; `PUT` and `DELETE` are idempotent by contract, so make them so

### What you NEVER do

- Never put a verb in a path (`/getUser`, `/orders/create`) — the method already said it
- Never return `200` with an error payload: a client that trusts the status code will treat the failure as a success
- Never let a `GET` mutate state, and never let it require a body
- Never expose internal detail in an error payload — stack traces, SQL, framework exception class names, internal identifiers
- Never change an existing contract (path, field, status code, error shape) without flagging it and stopping, per `dev-loop`'s API rule — an added optional field is compatible, a renamed or removed one is not
- Never document a `summary` with a trailing period, and never leave `description` holding a sentence that belongs in `summary`
- Do NOT apply this skill to internal layer boundaries or mapping (`layering-craft`), to broker events (`kafka-craft`), or to socket contracts (`ws-craft`)

### What you report but don't auto-fix

- Migrating an established error shape to RFC 9457 — a breaking change for every client, worth a decision rather than a drive-by edit
- Changing an existing pagination style
- Adding hypermedia (HATEOAS) where the clients do not use it

<!-- Customization hook — stratégie de version, enveloppe d'erreur maison, style de pagination retenu : references/house-rules.md -->

## FOCUS

- Paths, verbs, status codes
- Payload naming and date formats
- One error envelope, validation included
- Pagination, idempotency, versioning
- OpenAPI style: `summary` vs `description`, documented error responses

## OUTPUT

Controllers, exposed DTOs and OpenAPI annotations conforming to the rules above — or, in review mode, a short list of contract findings. Transverse skill: it applies to the Java backend and the Node BFF alike.
