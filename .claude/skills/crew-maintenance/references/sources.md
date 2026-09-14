# sources — feeds de veille

> **Ce fichier liste où regarder**, pas ce qui justifie une règle. La distinction est nette
> et évite un doublon : la section `## Sources` de chaque référence cite ce qui
> **fonde** une règle donnée ; ce fichier-ci déclare les flux à **consulter** à chaque passe.
>
> Le coût d'une passe est borné par cette liste. On ne l'élargit pas en cours de route :
> une lacune se note dans le digest et se corrige ici, délibérément.
>
> Trois passes consécutives sans rien produire pour un flux = signal de révision.

## Java — `../crew/technos/java.md` · `../crew/technos/java-spring.md`

- [JDK release notes](https://www.oracle.com/java/technologies/javase/jdk-relnotes-index.html)
- [JEP index](https://openjdk.org/jeps/0) — filtrer sur `Closed/Delivered`
- [Spring Boot release notes (wiki)](https://github.com/spring-projects/spring-boot/wiki)
- [Spring Blog](https://spring.io/blog)

## Persistance — `../crew/technos/java-persistence.md`

- [Hibernate — in.relation.to](https://in.relation.to/)
- [Spring Data JPA reference](https://docs.spring.io/spring-data/jpa/reference/)

## Angular — `../crew/technos/angular.md` · `../crew/technos/angular-patterns.md`

- [Angular blog](https://blog.angular.dev/)
- [Angular releases (GitHub)](https://github.com/angular/angular/releases)

## Node — `../crew/technos/node.md`

- [Node.js changelog](https://github.com/nodejs/node/blob/main/CHANGELOG.md)
- [Node.js release schedule](https://github.com/nodejs/release#release-schedule) — fins de support

## API REST — `../crew/references/bp-api-rest.md`

- [RFC Editor — nouveaux RFC HTTP](https://www.rfc-editor.org/search/rfc_search.php)
- [OpenAPI Specification releases](https://github.com/OAI/OpenAPI-Specification/releases)

## Kafka — `../crew/references/bp-kafka.md`

- [Apache Kafka release notes](https://kafka.apache.org/downloads)
- [Confluent blog](https://www.confluent.io/blog/)

## Domaine IoT — `../crew/references/dom-iot.md`

- [OASIS — MQTT](https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html)
- [OWASP — Internet of Things project](https://owasp.org/www-project-internet-of-things/)

## WebSocket — `../crew/references/bp-ws.md`

- [MDN WebSockets API](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
- [RFC Editor — WebSocket](https://www.rfc-editor.org/search/rfc_search.php)

## Tests — `../crew/references/proc-testfix.md`

- [JUnit 5 release notes](https://junit.org/junit5/docs/current/release-notes/)
- [Vitest releases (GitHub)](https://github.com/vitest-dev/vitest/releases)
- [pytest changelog](https://docs.pytest.org/en/stable/changelog.html)

## Sécurité — `../crew/references/proc-security.md`

- [OWASP Top 10](https://owasp.org/Top10/) — nouvelle édition
- [OWASP Cheat Sheet Series (GitHub)](https://github.com/OWASP/CheatSheetSeries/commits/master)

## Conventions — `../crew/references/bp-conventions.md`

- [Conventional Commits (GitHub)](https://github.com/conventional-commits/conventionalcommits.org/releases)
- [Semantic Versioning (GitHub)](https://github.com/semver/semver/releases)
- [Keep a Changelog (GitHub)](https://github.com/olivierlacan/keep-a-changelog/releases)

## Python — `../crew/technos/python.md` *(parqué : hors périmètre tant que la techno l'est)*

## Sans flux déclaré

Une techno ou une référence sans flux ici ne peut pas être veillée. `-w` les liste
dans la ligne « not watchable » du digest. À ce jour :

- `../crew/references/bp-layering.md` — principes d'architecture stables, sans flux de publication
- `../crew/references/proc-quality.md` — procédure de revue, sans flux de publication
- `../crew/references/proc-architecture.md` — procédure de décision, sans flux de publication
- `../crew/references/bp-code.md` — pratiques stables, sans flux de publication
- `../crew/references/bp-bff.md` — pattern d'architecture, sans flux de publication
- `../crew/technos/node.md` — a des flux mais un contenu vide : rien à maintenir tant qu'il n'est pas peuplé
- `../crew/technos/angular-patterns.md` — a des flux mais un contenu vide : rien à maintenir
  tant qu'il n'est pas peuplé
- `../crew/technos/python.md` — parqué
