# node-bff — Node.js BFF

Loaded by the role agent once `SKILL.md`'s detection table has identified this stack.

## REFERENCES

Load one when the task's context calls for it, never by default:

- `references/node-bff.md`

## BEHAVIOR

### What you MUST do

- Keep the BFF a composition layer: it aggregates, reshapes and protects. A business rule belongs to the backend that owns the data it governs
- Shape each endpoint around one screen's need — that is the entire point of a BFF, and the reason it may legitimately differ from the backend's own contract
- Put an explicit timeout on every outbound call, shorter than the BFF's own response budget, and decide per dependency what a failure means: degrade the response, or fail it
- Keep tokens and secrets server-side. What the browser receives is what the screen needs, never what happened to be in the upstream payload
- Propagate a correlation id through every outbound call, and log it — a BFF turns one user action into several calls, and without it a failure cannot be traced back
- Validate what comes from the browser before forwarding it: being closer to the front end does not make input trusted
- Retry only idempotent calls, with backoff — and count a retry against the same response budget as the original

### What you NEVER do

- Never duplicate a business rule already owned by a backend service: two copies of a rule will disagree, and the BFF's copy is the one nobody audits
- Never forward an upstream error verbatim — it carries internal detail, and its shape is the upstream's contract, not the one the browser was promised
- Never let the browser hold something it cannot protect: a token readable by page scripts is a token available to anything injected into the page
- Never retry a non-idempotent call after a timeout — a timeout means the outcome is unknown, not that nothing happened
- Never let one dependency without a timeout hold the whole aggregated response
- Never cache a per-user response in a shared cache without the user in the key
- Do NOT use these rules for Angular-side code (`technos/angular.md`), to the shape of the contract itself (`references/api-rest.md`), or to layer boundaries inside a backend (`references/layering.md`)

### What you report but don't auto-fix

- Adding a circuit breaker in front of a dependency that fails often
- Caching an aggregated response, which is a freshness decision the product owns
- Merging or splitting BFF endpoints as screens evolve

<!-- Customization hook — a project's own names, versions and choices belong in its project file, never here. -->

## FOCUS

- Aggregation and reshaping, without business rules
- Timeouts, deliberate degradation, retry only where it is safe
- Secrets, tokens, and what never reaches the browser
- Correlation and traceability across fan-out
- The boundary with the backend that owns the rule

