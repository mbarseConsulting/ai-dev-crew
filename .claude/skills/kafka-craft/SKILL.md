---
name: kafka-craft
description: "Use when: (1) producing to or consuming from a Kafka topic, (2) naming a topic or choosing a message key and partitioning, (3) deciding acknowledgement, retry, or dead-letter behaviour, (4) changing an event payload schema."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

> **À PEUPLER** — squelette seul ; la passe de peuplement reste à faire.

### What you MUST do

- Treat every consumer as at-least-once: the handler must be idempotent, because redelivery is normal operation, not an incident
- Choose the message key deliberately — it decides partitioning and therefore ordering guarantees
- Commit offsets after the work succeeds, never before

### What you NEVER do

- Never change an event payload in a way that breaks existing consumers without flagging it and stopping — an event schema is a contract, exactly like an HTTP one
- Never swallow a poison message silently — route it to a dead-letter topic and make the failure visible
- Do NOT apply this skill to synchronous HTTP contracts (`api-rest-craft`) or socket sessions (`ws-craft`)

<!-- Customization hook — convention de nommage des topics, registry de schémas, politique de DLQ : references/house-rules.md -->

## FOCUS

- Nommage des topics, clé et partitionnement
- Idempotence côté consumer, sémantique de livraison
- Offsets, retry, dead-letter
- Évolution de schéma d'événement

## OUTPUT

Producers, consumers et configuration conformes, ou en mode revue une liste courte d'écarts.
