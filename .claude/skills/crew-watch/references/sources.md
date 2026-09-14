# watch — feeds de veille

> **Ce fichier liste où regarder**, pas ce qui justifie une règle. La distinction est nette
> et évite un doublon : la section `## Sources` de chaque `best-practices.md` cite ce qui
> **fonde** une règle donnée ; ce fichier-ci déclare les flux à **consulter** à chaque passe.
>
> Le coût d'une passe est borné par cette liste. On ne l'élargit pas en cours de route :
> une lacune se note dans le digest et se corrige ici, délibérément.
>
> Trois passes consécutives sans rien produire pour un flux = signal de révision.

## Java — `agent-java`

- [JDK release notes](https://www.oracle.com/java/technologies/javase/jdk-relnotes-index.html)
- [JEP index](https://openjdk.org/jeps/0) — filtrer sur `Closed/Delivered`
- [Spring Boot release notes (wiki)](https://github.com/spring-projects/spring-boot/wiki)
- [Spring Blog](https://spring.io/blog)

## Persistance — `references/persistence.md`

- [Hibernate — in.relation.to](https://in.relation.to/)
- [Spring Data JPA reference](https://docs.spring.io/spring-data/jpa/reference/)

## Angular — `agent-angular`

- [Angular blog](https://blog.angular.dev/)
- [Angular releases (GitHub)](https://github.com/angular/angular/releases)

## Node / BFF — `agent-node-bff`

- [Node.js changelog](https://github.com/nodejs/node/blob/main/CHANGELOG.md)
- [Node.js release schedule](https://github.com/nodejs/release#release-schedule) — fins de support

## API REST — `references/api-rest.md`

- [RFC Editor — nouveaux RFC HTTP](https://www.rfc-editor.org/search/rfc_search.php)
- [OpenAPI Specification releases](https://github.com/OAI/OpenAPI-Specification/releases)

## Kafka — `references/kafka.md`

- [Apache Kafka release notes](https://kafka.apache.org/downloads)
- [Confluent blog](https://www.confluent.io/blog/)

## Domaine IoT — `references/iot.md`

- [OASIS — MQTT](https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html)
- [OWASP — Internet of Things project](https://owasp.org/www-project-internet-of-things/)

## WebSocket — `references/ws.md`

- [MDN WebSockets API](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
- [RFC Editor — WebSocket](https://www.rfc-editor.org/search/rfc_search.php)

## Python — `agent-python` *(parqué : hors périmètre tant que la skill l'est)*

## Sans flux déclaré

Une persona ou une référence sans flux ici ne peut pas être veillée. À ce jour :

- `agent-angular` a des flux mais un `best-practices.md` vide — il n'y a rien à maintenir
  tant qu'il n'est pas peuplé.
