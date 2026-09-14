# spring — Java 21 / Spring Boot 3

> Load when: the change touches `*.java` under a `pom.xml` or `build.gradle(.kts)`. Last watch: 2026-09-14 · Target: Java 21 LTS / Spring Boot 3.x / Jakarta Persistence 3.x

## MUST

- Inject through the constructor, `final` fields, no `@Autowired` on a sole constructor — a field-injected bean cannot be built in a plain unit test and hides the cyclic dependencies constructor injection fails on at startup
- Use a `record` for immutable carriers (DTO, event, value object) — `equals`/`hashCode`/`toString` come generated and correct; a JPA entity is never one, it needs a no-arg constructor and mutable fields
- Return `Optional` only as a method result — as a field it is not serialisable, as a parameter the caller has three cases, in a collection an empty one already says "nothing"
- Model a closed set of cases as a `sealed` hierarchy with a pattern-matching `switch` — the compiler checks exhaustiveness, an `instanceof` chain silently ignores the case added next year
- Group configuration in a `@ConfigurationProperties` type — validated, typed, testable without a context; scattered `@Value` are none of that
- Compose a meta-annotation when the same set of annotations repeats across classes or methods — it names the intent and keeps every use identical
- Translate exceptions to HTTP in one `@RestControllerAdvice` — a `try/catch` building a `ResponseEntity` in a controller duplicates it and will diverge
- Validate inbound payloads with Bean Validation (`@Valid` plus constraints) — a hand-rolled `if` chain is neither declarative nor reported as a field list
- Log through SLF4J with parameterised messages (`log.debug("orderId={}", id)`) — concatenation builds the string even when the level is off, and `System.out` bypasses every appender
- Put shared entity fields (`id`, audit columns, `@Version`) on an `abstract` `@MappedSuperclass` base — `@Entity` on the base gives it a table or a discriminator nobody needs
- Populate audit fields with `@CreatedDate`/`@LastModifiedDate`, `@EntityListeners(AuditingEntityListener.class)` and `@EnableJpaAuditing` — a `setUpdatedAt(now())` in a service is skipped by the first code path that forgets it, and an audit that lies is worse than none
- Base `equals`/`hashCode` on a business key or an application-set UUID, compared with `instanceof` — one strategy for the whole codebase
- Add `@Version` to any entity concurrent requests can update — optimistic locking is the only cheap protection against lost updates
- Keep `@Transactional` on a `public` service method, `readOnly = true` for reads — the proxy intercepts nothing else
- Keep associations `LAZY` and widen per query with `JOIN FETCH` or an entity graph — the mapping is shared by every query, the fetch need is not
- Put a test in the tier its behavior belongs to — plain JUnit or a slice (`@WebMvcTest`, `@DataJpaTest`, `@JsonTest`) for one concern, `@SpringBootTest` only for real wiring
- Mock collaborators with `@MockitoBean` and `@MockitoSpyBean` — `@MockBean` and `@SpyBean` are deprecated in Boot 3.4 and removed in 4.0
- With Spring Kafka, wire a `DeadLetterPublishingRecoverer` into the error handler and create the dead-letter topic beforehand, with at least as many partitions as the source — the default handler retries 9 times, then logs and drops the record, which is the silent skip the Kafka rules forbid

## NEVER

- Never call a proxied method (`@Transactional`, `@Cacheable`, `@Async`, `@Retryable`) from the same bean — `this.method()` bypasses the proxy and the annotation silently does nothing; move the method to another bean
- Never put a proxy-based annotation on a `private`, `protected`, `final` or package-private method — the proxy cannot intercept it, so nothing happens and nothing warns
- Never build `hashCode` on a generated id — it is `null` before `persist()` and changes after, so an entity already in a `HashSet` becomes unfindable in its own set
- Never compare with `getClass() != o.getClass()` in `equals` — a lazy proxy is a generated subclass and becomes unequal to the entity it proxies
- Never use `@Inheritance` just to share columns — that is `@MappedSuperclass`; `@Inheritance` is for polymorphic queries and costs a table or a discriminator
- Never nest entity inheritance more than one level without flagging it — deep hierarchies and JPA combine badly
- Never touch a lazy association from `toString()` — the most common `LazyInitializationException` comes from a log line
- Never fix an N+1 by switching the mapping to `EAGER` — it taxes every query to repair one
- Never reach for `@SpringBootTest` where a slice proves the same — it boots the whole context per test class, and a slow suite ends up paid in tests nobody writes

## Flag, don't fix

- Virtual threads (`spring.threads.virtual.enabled`, Boot 3.2+) for I/O-bound handling — real gain, but `synchronized` blocks pin the carrier thread
- Converting an existing `instanceof` chain to a `sealed` hierarchy — a modelling decision, not a drive-by edit
- Replacing working `@Value` injections with `@ConfigurationProperties`

## Not here

- Which layer may see the entity, who maps out of it and with what → `references/bp-layering.md`
- Shape of the HTTP contract, error envelope → `references/bp-api-rest.md`
- Practices every stack shares: empty collections, catch-all, stack traces → `references/bp-code.md`

## Sources

- [Spring Framework — Understanding AOP proxies](https://docs.spring.io/spring-framework/reference/core/aop/proxying.html)
- [Spring Framework — Declarative transaction management](https://docs.spring.io/spring-framework/reference/data-access/transaction/declarative.html)
- [Spring Boot — Testing, test slices](https://docs.spring.io/spring-boot/reference/testing/spring-boot-applications.html)
- [Spring Data JPA — Auditing](https://docs.spring.io/spring-data/jpa/reference/auditing.html)
- [Jakarta Persistence — inheritance](https://jakarta.ee/specifications/persistence/)
- [Thorben Janssen — Inheritance strategies with JPA and Hibernate](https://thorben-janssen.com/complete-guide-inheritance-strategies-jpa-hibernate/)
- [JEP 441 — Pattern Matching for switch](https://openjdk.org/jeps/441)
- [Spring Boot 4.0 Migration Guide — @MockBean removal](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-4.0-Migration-Guide)
- [Spring Kafka — Error handling](https://docs.spring.io/spring-kafka/reference/kafka/annotation-error-handling.html)
