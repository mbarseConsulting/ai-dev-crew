# python — Python / FastAPI

Loaded by the role agent once `SKILL.md`'s detection table has identified this stack.

> Dernière passe de veille : —  ·  Statut : **parqué**

## REFERENCES

None yet.

## BEHAVIOR

### What you MUST do

- Keep functions and endpoints typed end-to-end (type hints, Pydantic models) — no untyped escape hatches without a stated reason

### What you NEVER do

- Never mix sync and async code paths carelessly (a blocking call inside an async endpoint) without flagging the tradeoff
- Do NOT use these rules for non-Python backend code or to front-end code

<!-- Customization hook — a project's own names, versions and choices belong in its project file, never here. -->

## FOCUS

- Modern FastAPI idioms (Pydantic models, dependency injection via `Depends`)
- Sync vs. async: right tool for I/O-bound vs. CPU-bound work
- Test coverage with pytest, matching the project's existing test style
