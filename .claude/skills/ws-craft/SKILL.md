---
name: ws-craft
description: "Use when: (1) opening, closing, or authenticating a WebSocket session, (2) designing the message envelope exchanged over a socket, (3) handling reconnection, heartbeat, or backpressure, (4) deciding whether a piece of behaviour belongs on a socket or on plain HTTP."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Give every message a typed envelope — a discriminator plus a payload — so both ends route without guessing, and version that envelope from the first message rather than after the first incompatible change
- Authenticate at the handshake **and** re-check authorisation on anything sensitive: a long-lived socket outlives the token that opened it, and permissions revoked mid-session must take effect
- Validate inbound messages exactly as you would an HTTP body — a socket frame is external input like any other
- Reconnect with exponential backoff **and jitter**: without jitter, every client reconnects in step and turns a server blip into a thundering herd
- Resynchronise after reconnect rather than resuming: fetch current state, or replay from a sequence number the client carries. A reconnected socket is a new session, not a continuation
- Run an application-level heartbeat (ping/pong): a TCP connection can be dead for minutes without either side being told
- Bound the outbound queue per connection and decide explicitly what happens when it fills — drop, coalesce, or disconnect

### What you NEVER do

- Never use a socket for what request/response does better — a socket earns its cost only for server-initiated or continuous flow
- Never assume delivery, ordering, or continuity across a reconnect
- Never leave a session authorised for its whole lifetime on the handshake token alone
- Never broadcast without checking each recipient's authorisation — a room or topic is a routing mechanism, not an access-control decision
- Never buffer without a bound: a slow consumer then becomes a server-side memory leak
- Do NOT apply this skill to HTTP contracts (`api-rest-craft`) or broker-based events (`kafka-craft`)

### What you report but don't auto-fix

- Replacing the socket with Server-Sent Events when the flow is actually one-directional
- Introducing a broker behind the socket so several server instances can fan out to the right sessions

<!-- Customization hook — forme exacte de l'enveloppe, stratégie d'auth de handshake, intervalle de heartbeat : references/house-rules.md -->

## FOCUS

- Typed, versioned envelope
- Lifecycle: handshake, auth, heartbeat, reconnection, resynchronisation
- Backpressure and bounded buffers
- Socket versus HTTP: where the boundary actually is

## OUTPUT

Socket handlers, envelopes and configuration conforming to the rules above — or, in review mode, a short list of findings.
