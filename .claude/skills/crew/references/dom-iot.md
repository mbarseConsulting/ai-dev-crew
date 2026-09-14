# iot — connected devices

> Load when: the project file's `Domain references` line lists `iot`. Last watch: 2026-09-14

## MUST

- Carry both timestamps on every telemetry message, device time and server receipt time, and store both — device clocks drift and reset, the server only knows when it received the message, and the gap between the two is the fleet's health signal
- Treat every device as intermittently connected: it buffers offline and dumps on reconnect, so late and out-of-order arrival is normal traffic
- Key telemetry by device id — one device's messages stay ordered relative to each other
- Make ingestion idempotent on `(device id, device timestamp)` — a device that got no ack replays, and it has no memory of what was confirmed
- Give every device its own revocable credential and design rotation before the first one ships — a device is physically accessible, and a ten-year field life outlives any certificate
- Bound what a device may push: message rate, payload size, number of distinct series — time-series stores die of series count, not point count
- Version the message schema from the first message and keep every change additive, forever — a fleet is never fully upgraded, so old formats keep arriving with no end date
- Give every downstream command an id, an acknowledgement and an expiry — sent is not delivered, and a command without expiry runs when the device wakes up a month later in a context that no longer exists

## NEVER

- Never use the device clock as the ordering authority
- Never ship one shared credential across a fleet — one compromised device compromises all, and nothing can be revoked without bricking the rest
- Never turn a device-supplied free string into a series tag — only a closed server-side enumeration; anything else is a cardinality explosion nobody decided
- Never assume a command was received because it was sent
- Never design a change that needs the whole fleet online at once
- Never size ingestion on the average rate — a fleet reconnecting after an outage delivers hours of buffer in minutes, correlated, all at once

## Not here

- Broker mechanics → `references/bp-kafka.md`; socket lifecycle → `references/bp-ws.md`

## Sources

- [OASIS — MQTT 5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html)
- [OWASP — Internet of Things project](https://owasp.org/www-project-internet-of-things/)
- [InfluxDB — Resolve high series cardinality](https://docs.influxdata.com/influxdb/latest/write-data/best-practices/resolve-high-cardinality/)
