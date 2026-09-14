---
name: persistence-craft
description: "Use when: (1) creating or modifying a persisted entity, its base class, or its mapping, (2) deciding how entity identity, equality, or auditing works, (3) diagnosing a lazy-loading, N+1, or transaction-boundary problem."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Put shared entity fields (`id`, audit columns, `@Version`) on an `abstract` base class annotated `@MappedSuperclass` — never `@Entity`, which would give the base class a table of its own
- Populate audit fields declaratively: `@CreatedDate`/`@LastModifiedDate` (plus `@CreatedBy`/`@LastModifiedBy` with an `AuditorAware`) via `@EntityListeners(AuditingEntityListener.class)`, with `@EnableJpaAuditing` on the configuration — never by hand in a service
- Implement `equals`/`hashCode` on an entity so they are stable across the transient → persisted transition (see `references/best-practices.md` for the three valid strategies)
- Use `instanceof` (or `Hibernate.getClass()`) in `equals`, never `getClass() != o.getClass()` — the latter makes a lazy proxy unequal to the entity it proxies
- Add `@Version` for optimistic locking on entities that concurrent requests can update
- Keep the transactional boundary in the service layer, on a public method, and name the read-only ones `@Transactional(readOnly = true)`
- State the fetch strategy explicitly: associations `LAZY` by default, widened per query with a `JOIN FETCH` or an entity graph — never by flipping the mapping to `EAGER`

### What you NEVER do

- Never build `hashCode()` from a database-generated id — it is `null` before `persist()` and changes after, so an entity already inside a `HashSet` becomes unfindable in its own set
- Never use `@Inheritance` merely to share columns — that is what `@MappedSuperclass` is for; `@Inheritance` is for real polymorphic querying and costs a table or a discriminator
- Never nest entity inheritance more than one level deep without flagging it — deep hierarchies and JPA combine badly
- Never reference a lazy association from `toString()` — it throws `LazyInitializationException` outside a session, usually from a log line
- Never resolve an N+1 by widening the mapping to `EAGER`; fix the query that caused it
- Never let a schema change ride along silently — flag it and stop, per `dev-loop`'s API/schema rule
- Do NOT apply this skill to which layer may see an entity, or to entity → DTO → mapper boundaries — that is `layering-craft`

<!-- Customization hook — les noms et signatures maison (classe de base, stratégie d'id, colonnes d'audit) vivent dans references/house-rules.md, jamais ici. -->

## FOCUS

- Base class: `@MappedSuperclass` vs `@Inheritance`, and what belongs on it
- Identity and equality across the transient → persisted transition
- Declarative auditing rather than hand-written timestamps
- Fetch strategy, N+1, and lazy-proxy pitfalls
- Transaction boundaries and optimistic locking

## OUTPUT

Entity, base-class, and repository code following the rules above — or, in review mode, a short list of adherence findings. Same two authorized consumers as the other craft skills: `agent-crew-dev` self-checking its work-in-progress, and `agent-crew-critic` using this skill as a conventions-reference lens.
