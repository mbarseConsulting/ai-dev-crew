# bff — Backend For Frontend

> Load when: an endpoint that aggregates or reshapes backend calls for one front end. Last watch: 2026-09-14

## MUST

- Keep the BFF a composition layer: aggregate, reshape, protect — a business rule belongs to the backend that owns the data, and the BFF's copy is the one nobody audits
- Shape each endpoint around one screen's need — that is the whole point, and the only reason it may differ from the backend contract
- Put an explicit timeout on every outbound call, shorter than the BFF's own response budget, and decide per dependency whether its failure degrades the response or fails it — without it the response is as slow as the slowest dependency, and one stuck upstream drains the whole connection pool
- Keep tokens and secrets server-side; a session token lives in an `HttpOnly`, `Secure`, `SameSite` cookie — a token page scripts can read is available to anything injected into the page
- Send the browser what the screen needs, never the upstream payload as is — that exposes fields nobody decided to expose
- Propagate a correlation id through every outbound call and log it — one user action becomes several calls, and without it a failure cannot be traced to its screen
- Validate what comes from the browser before forwarding — proximity to the front end does not make input trusted
- Retry only idempotent calls, with backoff, inside the same response budget as the original — three tries at two seconds is six seconds of user wait

## NEVER

- Never forward an upstream error verbatim — it carries internal detail, and its shape is the upstream's contract, not the one the browser was promised; translate to the BFF's own error envelope and keep the original in the logs
- Never retry a non-idempotent call after a timeout — a timeout means the outcome is unknown, not that nothing happened
- Never let one dependency without a timeout hold the whole aggregated response
- Never cache a per-user response in a shared cache without the user in the key — that is a data leak, not a performance bug

## Flag, don't fix

- A circuit breaker in front of a dependency that fails often
- Caching an aggregated response — freshness is a product decision
- Merging or splitting endpoints as screens evolve

## Not here

- Shape of the contract → `references/bp-api-rest.md`; layers inside a backend → `references/bp-layering.md`

## Sources

- [Sam Newman — Backends For Frontends](https://samnewman.io/patterns/architectural/bff/)
- [OWASP — HTML5 Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html)
- [MDN — Set-Cookie](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie)
- [W3C — Trace Context](https://www.w3.org/TR/trace-context/)
