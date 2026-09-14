# ws — WebSocket sessions

> Load when: a socket handler, a message envelope, reconnection. Last watch: 2026-09-14

## MUST

- Choose the transport before coding: request/response → HTTP; server push only → SSE over HTTP/2; both directions, continuous, low latency → WebSocket — a one-way flow on a socket is SSE rewritten by hand, worse, and SSE on HTTP/1.1 hits the browser's cap of 6 connections per origin
- Validate the `Origin` header at the handshake before upgrading — the protocol enforces no same-origin policy, so a server that skips it accepts a socket from any page, with the visitor's cookies
- Negotiate the subprotocol through `Sec-WebSocket-Protocol`, picking zero or one of what the client offered — a conformant client aborts on anything it did not propose
- Give every message a typed envelope, discriminator plus payload, versioned from the first message — both ends route without guessing
- Authenticate at the handshake **and** re-check authorisation on every sensitive message — a socket outlives the token that opened it, and a permission revoked mid-session must take effect
- Validate inbound frames as you would an HTTP body — a frame is external input
- Reconnect with exponential backoff **and jitter** — without jitter every client that dropped at the same instant retries at the same instant, and a one-second blip becomes an outage sustained by its own clients
- Resynchronise after reconnect, current state or replay from a client-held sequence number — a reconnected socket is a new session, and nothing kept what was emitted meanwhile
- Run an application-level heartbeat — a TCP connection can be dead for minutes without either side being told
- Bound the outbound queue per connection and decide what happens when it fills: drop oldest, coalesce, or disconnect — a slow client is otherwise a server-side memory leak
- Relay through a broker when several server instances fan out — a session belongs to one instance, and an event produced elsewhere cannot reach it otherwise

## NEVER

- Never use a socket for what request/response does better
- Never assume delivery, ordering or continuity across a reconnect
- Never leave a session authorised for its whole life on the handshake token alone
- Never broadcast to a room or topic without checking each recipient — a room is routing, not access control
- Never buffer without a bound

## Flag, don't fix

- Replacing the socket with SSE when the flow is one-directional
- Introducing the broker that multi-instance fan-out needs
- Bootstrapping the socket as an Extended CONNECT stream on HTTP/2 or HTTP/3 (RFC 8441, RFC 9220) — it rides the multiplexed connection and survives proxies and per-host caps a raw Upgrade does not, when the stack supports it

## Not here

- HTTP contracts → `references/bp-api-rest.md`; broker events → `references/bp-kafka.md`

## Sources

- [RFC 6455 — The WebSocket Protocol](https://www.rfc-editor.org/rfc/rfc6455.html)
- [MDN — Server-Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events)
- [AWS — Exponential backoff and jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
- [RFC 8441 — Bootstrapping WebSockets with HTTP/2](https://www.rfc-editor.org/rfc/rfc8441.html)
- [RFC 9220 — Bootstrapping WebSockets with HTTP/3](https://www.rfc-editor.org/rfc/rfc9220.html)
