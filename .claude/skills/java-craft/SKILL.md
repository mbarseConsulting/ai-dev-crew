---
name: java-craft
description: "Use when: (1) writing or modifying Java or Spring Boot code, (2) reviewing Java for adherence to modern idioms, (3) deciding on dependency injection, configuration, exception handling, or logging in a Spring service, (4) choosing the Spring test slice for a piece of behavior."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Match the Java and Spring Boot version and conventions already in use in the project before introducing new ones
- Inject through the constructor, with `final` fields; omit `@Autowired` on a sole constructor, where it has been redundant since Spring 4.3
- Use a `record` for immutable data carriers (DTOs, value objects, events); reach for a class only when identity or mutable state is genuinely needed
- Use `Optional` as a return type only — never as a field, a parameter, or a collection element
- Model a closed set of cases with a `sealed` hierarchy and a pattern-matching `switch` rather than a chain of `instanceof`
- Group configuration in a `@ConfigurationProperties` type rather than scattering `@Value` across beans
- Centralise exception-to-response translation in a `@RestControllerAdvice` (the *shape* of the payload belongs to `api-rest-craft`, not here)
- Validate inbound payloads with Bean Validation (`@Valid` plus constraint annotations), not hand-rolled `if` chains
- Log through SLF4J with parameterised messages (`log.debug("orderId={}", id)`) — never string concatenation, never `System.out`
- Apply `test-craft`'s tier criterion by name — it is not restated here — and express it in Spring: the fast tier is a plain JUnit test or a slice (`@WebMvcTest`, `@DataJpaTest`, `@JsonTest`), the wide tier is `@SpringBootTest`
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
- Do NOT apply this skill to entity mapping, identity, auditing, fetch strategy, or transaction placement (`persistence-craft`), to layer boundaries and DTO/mapper direction (`layering-craft`), to the shape of the exposed HTTP contract (`api-rest-craft`), or to non-Java code

### What you report but don't auto-fix

Same objective/subjective split used elsewhere in the crew: the rules above are mechanical enough to auto-fix in code touched this session. These are broader guidelines — worth flagging, never worth silently rewriting working code over:

- Virtual threads (`spring.threads.virtual.enabled`) for I/O-bound request handling on Java 21+
- Converting an existing `instanceof` chain to a `sealed` hierarchy — a modelling decision, not a drive-by edit
- Replacing working `@Value` injections with `@ConfigurationProperties`

<!-- Customization hook — build tool, module layout, style guide and framework versions retenus : references/house-rules.md -->

## FOCUS

- Constructor injection, immutability, and what the container can actually intercept
- Modern Java carriers: records, sealed types, pattern matching, `Optional` discipline
- Configuration, centralised exception handling, Bean Validation
- SLF4J discipline
- Spring test slices as the expression of `test-craft`'s tier criterion

## OUTPUT

Component, service and test code following the rules above — or, in review mode, a short list of adherence findings. Two authorized consumers only: `agent-crew-dev` self-checking its work-in-progress (never a substitute for the formal gate), and `agent-crew-critic` loading this skill as a conventions-reference lens.
