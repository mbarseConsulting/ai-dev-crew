---
name: layering-craft
description: "Use when: (1) deciding which type may cross which layer boundary (entity, DTO, command, view model), (2) writing or changing a mapper, or deciding who calls it, (3) placing a new class in the package structure, (4) judging whether logic belongs in a controller, a service, or the domain."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Stop the persisted object at the service boundary: the service returns a DTO, the controller never receives the entity. This is mechanical, not stylistic — mapping outside the transaction fails on any unloaded lazy association; see `persistence-craft` for why, it is not restated here
- Map **out of the entity in the service**, inside the transactional boundary, by calling a dedicated mapper — a mapper is a component the service invokes, never code living in the controller or on the entity itself
- Inbound, mirror it: the controller validates and hands a request or command object to the service; the service creates or updates the entity
- Define one type per direction and per use case — a single type reused for input and output couples two contracts that evolve separately, and the day one of them changes the other is dragged along
- Keep the dependency direction inward: the domain knows nothing of the transport, the web layer, or the persistence framework
- Keep a controller to adapting a transport to a use case: bind, validate, delegate, return

### What you NEVER do

- Never return a persisted entity from a controller, and never accept one as a request body — inbound it lets a client set any mapped field, including the ones the use case never meant to expose
- Never call a repository from a controller
- Never put business logic in a controller: no branching over domain state, no orchestration of several services to enforce a rule
- Never add a second, transport-specific mapping in the controller while the API shape and the use-case output still coincide — that second hop earns its place only once they genuinely diverge (a versioned API, several clients, a BFF), and building it before is layering for its own sake
- Never institutionalise a pass-through layer: a service that only forwards to a repository and returns is cost without benefit — flag it rather than adding a mapper and an interface around it
- Do NOT apply this skill to how an entity is mapped, identified, audited, or fetched (`persistence-craft`), to the shape of the exposed HTTP contract (`api-rest-craft`), or to Spring's injection and proxy mechanics (`java-craft`)

### What you report but don't auto-fix

- Package layout by feature rather than by technical layer, when the project has already chosen one of the two
- Introducing a mapping library where hand-written mappers are working
- Splitting the use-case output from the response model where they currently coincide — a real divergence justifies it, an anticipated one does not

<!-- Customization hook — noms des couches, découpage en packages, mapper retenu : references/house-rules.md -->

## FOCUS

- Where the persisted object stops, and who maps out of it
- One type per direction and per use case
- Dependency direction: the domain depends on nothing
- Controller as transport adapter, not as a place for rules
- Layers that earn their existence versus layers added out of habit

## OUTPUT

Controllers, services, DTOs and mappers respecting the boundaries above — or, in review mode, a short list of crossings found. Same two authorized consumers as the other craft skills: `agent-crew-dev` self-checking its work-in-progress, and `agent-crew-critic` loading this skill as a conventions-reference lens.
