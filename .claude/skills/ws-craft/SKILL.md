---
name: ws-craft
description: "Use when: (1) opening, closing, or authenticating a WebSocket session, (2) designing the message envelope exchanged over a socket, (3) handling reconnection, heartbeat, or backpressure, (4) deciding whether a piece of behaviour belongs on a socket or on plain HTTP."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

> **À PEUPLER** — squelette seul ; la passe de peuplement reste à faire.

### What you MUST do

- Give every message a typed envelope (type discriminator + payload) so both ends can route without guessing
- Treat the connection as unreliable by design: reconnection with backoff, and resynchronisation of state after reconnect
- Authenticate at handshake and re-check authorisation on sensitive messages — a long-lived socket outlives the token that opened it

### What you NEVER do

- Never use a socket for what a request/response would do better — a socket is for server-initiated or continuous flow
- Never assume delivery order or delivery at all after a reconnect without a resynchronisation step
- Do NOT apply this skill to HTTP contracts (`api-rest-craft`) or broker-based events (`kafka-craft`)

<!-- Customization hook — forme exacte de l'enveloppe maison, stratégie d'auth de handshake, intervalle de heartbeat : references/house-rules.md -->

## FOCUS

- Enveloppe de message et typage
- Cycle de vie : handshake, auth, heartbeat, reconnexion, resynchronisation
- Backpressure et volumétrie
- Socket vs HTTP : la bonne frontière

## OUTPUT

Handlers de socket, enveloppes et configuration conformes, ou en mode revue une liste courte d'écarts.
