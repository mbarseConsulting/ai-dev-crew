---
name: kafka-craft
description: "Use when: (1) producing to or consuming from a Kafka topic, (2) naming a topic or choosing a message key and partitioning, (3) deciding acknowledgement, retry, or dead-letter behaviour, (4) changing an event payload schema."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Treat every consumer as at-least-once: make the handler idempotent, because redelivery is normal operation and not an incident
- Choose the message key deliberately — it decides the partition, and the partition is the only unit in which Kafka guarantees ordering. Events that must stay ordered relative to each other share a key
- Commit the offset **after** the work has succeeded, not when the record was received
- Carry an event id and an event timestamp in every envelope: the id is what makes consumer-side deduplication possible, the timestamp is what makes an ordering problem diagnosable
- Evolve a schema additively — new optional fields only — and keep producers and consumers deployable in either order
- Route a message that cannot be processed to a dead-letter topic, together with the failure reason and enough context to replay it
- Keep per-record processing short, or increase `max.poll.interval.ms` deliberately: exceeding it makes the broker consider the consumer dead and triggers a rebalance

### What you NEVER do

- Never assume global ordering — Kafka orders within a partition, never across a topic
- Never assume exactly-once: it exists only with the transactional producer and a read-committed consumer, explicitly configured. Absent that, design for at-least-once
- Never leave `enable.auto.commit=true` where losing a record on handler failure is unacceptable — the offset advances whether or not the work succeeded
- Never swallow a poison message: an unbounded retry blocks its partition, and a silent skip loses data with no trace
- Never change an event payload in a way that breaks existing consumers without flagging it and stopping — an event schema is a contract exactly like an HTTP one
- Never perform long blocking work inside the poll loop
- Do NOT apply this skill to synchronous HTTP contracts (`api-rest-craft`) or socket sessions (`ws-craft`)

### What you report but don't auto-fix

- Introducing a schema registry where none exists
- Moving to a transactional producer for exactly-once semantics
- Changing a topic's partition count — it remaps every key, so previously ordered events can be reordered

<!-- Customization hook — convention de nommage des topics, registry, politique de DLQ et de rejeu : references/house-rules.md -->

## FOCUS

- Topic naming, key choice, and what ordering actually guarantees
- Delivery semantics and consumer idempotence
- Offsets, retry, dead-letter
- Event schema evolution as a contract

## OUTPUT

Producers, consumers, envelopes and configuration conforming to the rules above — or, in review mode, a short list of findings.
