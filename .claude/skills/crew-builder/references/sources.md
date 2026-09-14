# sources — watch feeds

> **This file lists where to look**, not what justifies a rule. The `## Sources` section of
> each reference cites what **grounds** a rule; this file declares the feeds to **read** on
> every pass.
>
> The cost of a pass is bounded by this list. It is never widened mid-run: a gap goes in the
> digest and is fixed here, deliberately.
>
> Three consecutive passes producing nothing for a feed = review signal.

## Spring — `../crew/technos/spring.md`

- [JDK release notes](https://www.oracle.com/java/technologies/javase/jdk-relnotes-index.html)
- [JEP index](https://openjdk.org/jeps/0) — filter on `Closed/Delivered`
- [Spring Boot release notes (wiki)](https://github.com/spring-projects/spring-boot/wiki)
- [Spring Blog](https://spring.io/blog)
- [Hibernate ORM — migration guides](https://github.com/hibernate/hibernate-orm/blob/main/migration-guide.adoc) — in.relation.to answers 403 on its archives (watch 2026-09-14)
- [Spring Data JPA reference](https://docs.spring.io/spring-data/jpa/reference/)

## Angular — `../crew/technos/angular.md`

- [Angular CHANGELOG (raw)](https://raw.githubusercontent.com/angular/angular/main/CHANGELOG.md) — the blog answers 403 and the releases page renders without notes (watch 2026-09-14)
- [Angular update guide](https://angular.dev/update-guide)

## Node — `../crew/technos/node.md`

- [Node.js changelog](https://github.com/nodejs/node/blob/main/CHANGELOG.md)
- [Node.js release schedule](https://github.com/nodejs/release#release-schedule) — end of support dates

## REST API — `../crew/references/bp-api-rest.md`

- [RFC Editor — new HTTP RFCs](https://www.rfc-editor.org/search/rfc_search.php)
- [OpenAPI Specification releases](https://github.com/OAI/OpenAPI-Specification/releases)

## Kafka — `../crew/references/bp-kafka.md`

- [Apache Kafka — upgrade notes (raw)](https://raw.githubusercontent.com/apache/kafka/trunk/docs/upgrade.html) — kafka.apache.org renders as an empty shell to a fetch (watch 2026-09-14)
- [Apache Kafka — design (raw)](https://raw.githubusercontent.com/apache/kafka/trunk/docs/design.html)
- [Spring Kafka reference — what's new](https://docs.spring.io/spring-kafka/reference/whats-new.html)
- [Confluent blog](https://www.confluent.io/blog/)

## IoT domain — `../crew/references/dom-iot.md`

- [OASIS — MQTT](https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html)
- [OWASP — Internet of Things project](https://owasp.org/www-project-internet-of-things/)

## WebSocket — `../crew/references/bp-ws.md`

- [MDN WebSockets API](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
- [RFC Editor — WebSocket](https://www.rfc-editor.org/search/rfc_search.php)

## Tests — `../crew/references/proc-testfix.md`

- [JUnit 5 release notes](https://junit.org/junit5/docs/current/release-notes/)
- [Vitest releases (GitHub)](https://github.com/vitest-dev/vitest/releases)
- [pytest changelog](https://docs.pytest.org/en/stable/changelog.html)

## Security — `../crew/references/proc-security.md`

- [OWASP Top 10](https://top10.owasp.org/) — new edition
- [OWASP Cheat Sheet Series (GitHub)](https://github.com/OWASP/CheatSheetSeries/commits/master)

## Conventions — `../crew/references/bp-conventions.md`

- [Conventional Commits (GitHub)](https://github.com/conventional-commits/conventionalcommits.org/releases)
- [Semantic Versioning (GitHub)](https://github.com/semver/semver/releases)
- [Keep a Changelog (GitHub)](https://github.com/olivierlacan/keep-a-changelog/releases)

## Python — `../crew/technos/python.md` *(parked: out of scope while the techno is)*

## No declared feed

A techno or reference with no feed here cannot be watched. `-w` lists them in the digest's
"not watchable" line. As of today:

- `../crew/references/bp-layering.md` — stable architecture principles, no publication feed
- `../crew/references/proc-quality.md` — review procedure, no publication feed
- `../crew/references/proc-architecture.md` — decision procedure, no publication feed
- `../crew/references/bp-code.md` — stable practices, no publication feed
- `../crew/references/bp-bff.md` — architecture pattern, no publication feed
- `../crew/technos/node.md` — has feeds but empty content: nothing to maintain until populated
- `../crew/technos/python.md` — parked
