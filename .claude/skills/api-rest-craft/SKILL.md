---
name: api-rest-craft
description: "Use when: (1) designing or changing an HTTP endpoint's path, verb, or status codes, (2) naming or shaping a request/response payload, (3) writing or reviewing OpenAPI annotations, (4) deciding the error, pagination, or versioning shape of an exposed API."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

> **À PEUPLER** — seules les règles d'ancrage validées en conception sont posées.
> La passe de peuplement complète reste à faire.

### What you MUST do

- Name paths after resources in the plural and in kebab-case (`/purchase-orders/{id}/line-items`), never after actions or a method name
- Write OpenAPI `summary` as a short capitalised phrase with **no trailing period**; put anything longer in `description`
- Return a consistent error payload across every endpoint of the service
- Carry the applicable status code rather than a 200 with an error body

### What you NEVER do

- Never put a verb in a path — the HTTP method is the verb
- Never change an existing contract (path, payload field, status code) without flagging it and stopping, per `dev-loop`'s API rule
- Do NOT apply this skill to internal layering or mapping — that is `layering-craft`
- Do NOT apply this skill to event or socket contracts — those are `kafka-craft` and `ws-craft`

<!-- Customization hook — préfixe de version, forme exacte du payload d'erreur maison, conventions de pagination : references/house-rules.md -->

## FOCUS

- Paths, verbes, codes de statut
- Nommage et forme des payloads
- Forme d'erreur unifiée, pagination, versionnage
- Style OpenAPI (summary/description, exemples)

## OUTPUT

Contrôleurs, DTOs exposés et annotations OpenAPI conformes, ou en mode revue une liste courte d'écarts. Skill transverse : elle s'applique au backend Java **et** au BFF Node.
