# java — Java / Spring Boot

Loaded by the role agent once `SKILL.md`'s detection table has identified this stack.

## REFERENCES

Load one when the task's context calls for it, never by default:

- `references/java-spring.md`
- `references/persistence.md`
- `references/kafka.md`
- `references/ws.md`

## BEHAVIOR

### What you MUST do

- Match the Java and Spring Boot version and conventions already in use in the project before introducing new ones
- Inject through the constructor, with `final` fields; omit `@Autowired` on a sole constructor, where it has been redundant since Spring 4.3
- Use a `record` for immutable data carriers (DTOs, value objects, events); reach for a class only when identity or mutable state is genuinely needed
- Use `Optional` as a return type only — never as a field, a parameter, or a collection element
- Model a closed set of cases with a `sealed` hierarchy and a pattern-matching `switch` rather than a chain of `instanceof`
- Group configuration in a `@ConfigurationProperties` type rather than scattering `@Value` across beans
- Centralise exception-to-response translation in a `@RestControllerAdvice` (the *shape* of the payload belongs to `references/api-rest.md`, not here)
- Validate inbound payloads with Bean Validation (`@Valid` plus constraint annotations), not hand-rolled `if` chains
- Log through SLF4J with parameterised messages (`log.debug("orderId={}", id)`) — never string concatenation, never `System.out`
- Place a test in the tier its behavior belongs to: the fast tier is a plain JUnit test or a slice (`@WebMvcTest`, `@DataJpaTest`, `@JsonTest`), the wide tier is `@SpringBootTest`
- Write or update a JUnit test alongside any behavior change
- Flag when a requested change implies an API contract or database schema change, and stop rather than guessing

### What you NEVER do

- Never inject into a field (`@Autowired` on a field): it cannot be constructed in a plain unit test and it hides cyclic dependencies that constructor injection would have failed on at startup
- Never call a proxied method (`@Transactional`, `@Cacheable`, `@Async`, `@Retryable`) from another method of the same bean — self-invocation bypasses the Spring proxy and the annotation silently does nothing
- Never put a proxy-based annotation on a `private`, `protected`, `final`, or package-private method, for the same reason: the proxy cannot intercept it
- Never catch `Exception` or `Throwable` broadly, and never swallow one without either logging it with its stack trace or rethrowing
- Never return `null` in place of an empty collection
- Never reach for `@SpringBootTest` where a slice would prove the same thing — it boots the whole context for every test that uses it
- Never introduce a new framework, ORM, or major dependency without flagging it as a decision for the user first
- Never drop existing input validation or error handling while touching a method
- Do NOT use these rules for entity mapping, identity, auditing, fetch strategy, or transaction placement (`references/persistence.md`), to layer boundaries and DTO/mapper direction (`references/layering.md`), to the shape of the exposed HTTP contract (`references/api-rest.md`), or to non-Java code

### What you report but don't auto-fix

Same objective/subjective split as `agents/agent-dev.md` Step 7: the rules above are mechanical enough to auto-fix in code touched this session. These are broader guidelines — worth flagging, never worth silently rewriting working code over:

- Virtual threads (`spring.threads.virtual.enabled`) for I/O-bound request handling on Java 21+
- Converting an existing `instanceof` chain to a `sealed` hierarchy — a modelling decision, not a drive-by edit
- Replacing working `@Value` injections with `@ConfigurationProperties`

<!-- Customization hook — a project's own names, versions and choices belong in its project file, never here. -->

## FOCUS

- Constructor injection, immutability, and what the container can actually intercept
- Modern Java carriers: records, sealed types, pattern matching, `Optional` discipline
- Configuration, centralised exception handling, Bean Validation
- SLF4J discipline
- Spring test slices: which behavior belongs in which slice

