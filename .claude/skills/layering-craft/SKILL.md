---
name: layering-craft
description: "Use when: (1) deciding which type may cross which layer boundary (entity, DTO, command, view model), (2) writing or changing a mapper, (3) placing a new class in the package structure, (4) judging whether logic belongs in a controller, a service, or the domain."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

> **À PEUPLER** — seules les règles d'ancrage validées en conception sont posées.
> La passe de peuplement complète reste à faire.

### What you MUST do

- Never expose a persisted entity beyond the service layer: a controller returns a DTO, never the entity
- Define a DTO per use case rather than one shared DTO reused in both directions
- Keep mapping in one direction per mapper, and out of both the controller and the entity

### What you NEVER do

- Never put business logic in a controller — a controller adapts a transport to a use case, nothing more
- Do NOT apply this skill to how an entity is mapped, identified, or audited — that is `persistence-craft`
- Do NOT apply this skill to the shape of the exposed HTTP contract (paths, verbs, payload naming) — that is `api-rest-craft`

<!-- Customization hook — découpage en packages, noms des couches et des mappers : references/house-rules.md -->

## FOCUS

- Frontières entity / DTO / command / view model : ce qui traverse quoi
- Sens et emplacement du mapping
- Placement : controller vs service vs domaine
- Découpage en packages

## OUTPUT

Code respectant les frontières ci-dessus, ou en mode revue une liste courte d'écarts. Mêmes consommateurs autorisés que les autres craft skills : `agent-crew-dev` en auto-contrôle, `agent-crew-critic` en lentille de conformité.
