# python — Python / FastAPI

> Load when: the change touches `*.py` under a `pyproject.toml` whose dependencies include `fastapi`. Last watch: — · Target: Python 3.12 / FastAPI 0.11x · Status: parked

## MUST

- Type functions and endpoints end to end, with type hints and Pydantic models — an untyped boundary is validated by nobody
- Inject dependencies through `Depends` — it is what FastAPI can override in tests

## NEVER

- Never block inside an `async` endpoint (a sync HTTP client, a sync driver) without flagging it — it stalls the event loop for every request

## Not here

- Shape of the HTTP contract → `references/bp-api-rest.md`
- Practices every stack shares → `references/bp-code.md`
