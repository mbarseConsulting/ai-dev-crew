# kafka — broker events

> Load when: a producer, a consumer, a topic, an event payload. Last watch: 2026-09-14

## MUST

- Treat every consumer as at-least-once and make the handler idempotent — redelivery is normal operation, and exactly-once exists only when someone configured it
- Choose the message key deliberately: events that must stay ordered share a key — Kafka orders within a partition, the key picks the partition, a `null` key means round-robin and no order at all
- Commit the offset after the work succeeded, never on receipt — otherwise a failing handler loses the record silently
- Carry an event id and an event timestamp in every envelope — the id makes deduplication possible, the timestamp makes an ordering problem diagnosable
- Evolve a schema additively, optional fields only, so producer and consumers deploy in any order — an imposed deploy order is a breaking change in disguise
- Route a message that cannot be processed to a dead-letter topic with the failure reason, topic, partition and offset, and monitor that topic — an unread DLQ is a slow silent skip
- Keep per-record work short, or raise `max.poll.interval.ms` deliberately — exceeding it makes the broker declare the consumer dead and rebalance

## NEVER

- Never assume global ordering across a topic
- Never assume exactly-once without a transactional producer and a `read_committed` consumer, explicitly configured
- Never leave `enable.auto.commit=true` where losing a record on handler failure is unacceptable — the offset advances on a timer, whether or not the work succeeded
- Never swallow a poison message — unbounded retry blocks its partition, a silent skip loses data without a trace
- Never break an event payload for existing consumers without flagging it and stopping — an event schema is a contract like an HTTP one, with old messages readable for the whole retention
- Never do long blocking work inside the poll loop
- Never rely on the key for ordering under a share group (queue semantics, KIP-932) — the broker hands records out one by one across the members reading the same partition, and only at-least-once applies

## Flag, don't fix

- Introducing a schema registry where none exists
- Moving to a transactional producer for exactly-once semantics
- Changing a topic's partition count — it remaps every key and can reorder events that were ordered

## Not here

- Synchronous HTTP contracts → `references/bp-api-rest.md`; socket sessions → `references/bp-ws.md`

## Sources

- [Apache Kafka — Design](https://kafka.apache.org/documentation/#design)
- [Apache Kafka — Consumer configuration](https://kafka.apache.org/documentation/#consumerconfigs)
- [Confluent — Message delivery guarantees](https://docs.confluent.io/kafka/design/delivery-semantics.html)
- [Spring Kafka — Queues (share groups)](https://docs.spring.io/spring-kafka/reference/kafka/kafka-queues.html)
