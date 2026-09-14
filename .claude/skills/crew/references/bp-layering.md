# layering — where the persisted object stops, who maps it

> Load when: a DTO, a mapper, a controller returning data, a layer boundary. Last watch: 2026-09-14

## MUST

- Stop the persisted object at the service boundary: the service returns a DTO, the controller never receives the entity — mapping outside the transaction throws on the first unloaded lazy association, and the two reflex fixes (`EAGER`, `open-in-view`) are worse than the bug
- Map out of the entity **in the service**, inside the transaction, through a dedicated mapper the service calls — a `toDto()` on the entity makes persistence depend on exposure, and mapping code in the controller runs after the transaction closed
- Mirror it inbound: the controller validates and hands a request or command object to the service, the service creates or updates the entity
- Define one type per direction and per use case — a type reused for input and output couples two contracts that evolve apart, and the day one changes the other is dragged along
- Keep the dependency direction inward: the domain knows nothing of transport, web or persistence framework — the test is "does the domain compile without the web and the ORM on the classpath?"
- Keep a controller to adapting a transport to a use case: bind, validate, delegate, return

## NEVER

- Never return a persisted entity from a controller, and never accept one as a request body — inbound, a client can then set any mapped field, including the ones the use case never meant to expose
- Never call a repository from a controller
- Never put business logic in a controller — no branching over domain state, no orchestrating several services to enforce a rule
- Never add a second, transport-specific mapping while the API shape and the use-case output still coincide — it earns its place only once they diverge (a versioned API, several clients, a BFF); before that it is indirection paid for a hypothesis
- Never institutionalise a pass-through layer — a service that only forwards to a repository adds a file, a mock in every test and one more hop to read; flag it rather than wrapping it in an interface and a mapper

## Flag, don't fix

- Package layout by feature versus by technical layer, when the project already chose one
- Introducing a mapping library where hand-written mappers work
- Splitting the use-case output from the response model where they currently coincide

## Not here

- How an entity is mapped, identified, audited, fetched → `technos/spring.md`
- Shape of the exposed HTTP contract → `references/bp-api-rest.md`

## Sources

- [Spring Boot — `spring.jpa.open-in-view`](https://docs.spring.io/spring-boot/reference/data/sql.html)
- [Martin Fowler — Local DTO](https://martinfowler.com/bliki/LocalDTO.html)
