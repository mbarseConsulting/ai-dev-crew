# python — Python / FastAPI

Loaded by the role agent once `SKILL.md`'s detection table has identified this stack.

## REFERENCES

Load one when the task's context calls for it, never by default:

- `references/layering.md`
- `references/api-rest.md`

## BEHAVIOR

### What you MUST do

- Match the Python and FastAPI version and conventions already in use in the project before introducing new ones
- Keep functions and endpoints typed end-to-end (type hints, Pydantic models) — no untyped escape hatches without a stated reason
- Write or update a test (pytest) alongside any behavior change
- Flag when a requested change implies an API contract or database schema change, and stop rather than guessing

### What you NEVER do

- Never introduce a new framework, ORM, or major dependency without flagging it as a decision for the user first
- Never mix sync and async code paths carelessly (a blocking call inside an async endpoint) without flagging the tradeoff
- Never drop existing input validation while touching an endpoint
- Do NOT use these rules for non-Python backend code or to front-end code

<!-- Customization hook — a project's own names, versions and choices belong in its project file, never here. -->

## FOCUS

- Modern FastAPI idioms (Pydantic models, dependency injection via `Depends`)
- Sync vs. async: right tool for I/O-bound vs. CPU-bound work
- Layering: router / service / repository boundaries
- Test coverage with pytest, matching the project's existing test style

