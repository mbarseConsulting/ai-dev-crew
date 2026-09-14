# java-spring — Java 21 / Spring Boot

> **Quoi et pourquoi.** Patterns vrais quel que soit l'employeur. Les noms, versions et
> choix retenus d'un projet vont dans son **fichier projet**, jamais ici.
>
> Ce fichier n'a pas de `## Règles` : elles sont les MUST/NEVER de `technos/java.md`.
> Il en est le `## Pourquoi`. En cas de désaccord, le fichier techno a raison.
>
> Dernière passe de veille : 2026-09-14 · Cible : Java 21 LTS / Spring Boot 3.x
>
> Ce qui relève du mapping, de l'identité d'entité ou des frontières transactionnelles est
> dans `technos/java-persistence.md`. Ce qui relève des couches est dans `references/bp-layering.md`. Ce qui
> relève de la forme du contrat HTTP est dans `references/bp-api-rest.md`.

## Pourquoi

## 1. Le proxy Spring — le piège le plus coûteux

Spring implémente `@Transactional`, `@Cacheable`, `@Async` et `@Retryable` par **proxy** :
le conteneur n'injecte pas ton bean, il injecte un objet qui l'enveloppe. L'annotation
n'agit que si l'appel **traverse** ce proxy.

```java
@Service
public class OrderService {
    public void importAll(List<Order> orders) {
        orders.forEach(this::saveOne);   // ← appel interne : le proxy est contourné
    }

    @Transactional
    public void saveOne(Order o) { ... } // ← aucune transaction ici
}
```

Trois conséquences, toutes silencieuses — rien ne plante, le comportement est simplement
absent :

- **Auto-invocation.** `this.method()` part directement sur l'instance, pas sur le proxy.
  Correctifs : sortir la méthode dans un autre bean (le plus propre), s'auto-injecter, ou
  passer par `TransactionTemplate`.
- **Visibilité.** Le proxy JDK n'intercepte que le `public`. Une méthode `private`,
  `protected` ou package-private annotée ne fait rien.
- **`final`.** Le proxy CGLIB sous-classe ; une méthode ou une classe `final` ne peut pas
  être surchargée, donc pas interceptée.

C'est exactement le type de règle qui justifie une checklist : un modèle produit
spontanément la version cassée, et rien dans la compilation ni dans les tests d'intégration
habituels ne la signale.

## 2. Injection

Injection par **constructeur**, champs `final`. Pas d'`@Autowired` sur un constructeur
unique (redondant depuis Spring 4.3).

Pourquoi pas l'injection par champ : le bean devient impossible à instancier dans un test
unitaire sans conteneur ni réflexion, et une dépendance cyclique qui aurait fait échouer le
démarrage en injection par constructeur passe inaperçue. L'injection par champ ne simplifie
que l'écriture — elle complique tout le reste.

## 3. Java moderne

**`record`** pour tout porteur de données immuable : DTO, value object, événement.
`equals`/`hashCode`/`toString` sont générés et corrects. Une classe ne se justifie que si
l'objet a une identité propre ou un état mutable. *(Une entité JPA n'est pas un `record` :
JPA exige un constructeur sans argument et des champs mutables — voir `technos/java-persistence.md`.)*

**`Optional`** en **type de retour uniquement**. Jamais en champ (non sérialisable,
surcoût mémoire), jamais en paramètre (l'appelant a alors trois cas : valeur, vide, `null`),
jamais dans une collection (une collection vide dit déjà « rien »).

**`sealed` + `switch` à patterns** pour un ensemble fermé de cas : le compilateur vérifie
l'exhaustivité. Une chaîne d'`instanceof` ne le fait pas, et le jour où un cas est ajouté
elle continue de compiler en oubliant silencieusement le nouveau.

**Collections** : retourner une collection vide, jamais `null`. `List.of()`, `Collections.emptyList()`.

## 4. Exceptions

- Pas de `catch (Exception e)` global : il attrape aussi ce qu'on ne sait pas traiter, y
  compris les erreurs de programmation qu'on voulait voir remonter.
- Pas de `catch` vide ni de `catch` qui log sans la stack trace : `log.error("msg", e)`,
  pas `log.error("msg " + e.getMessage())`.
- Traduction exception → réponse HTTP centralisée dans un `@RestControllerAdvice`. Un
  `try/catch` qui construit une `ResponseEntity` dans un contrôleur est une duplication de
  ce mécanisme, et elle divergera.

## 5. Configuration

`@ConfigurationProperties` sur un type dédié plutôt que des `@Value` dispersés : le
regroupement est validable (`@Validated`), typé, documenté par sa classe, et testable sans
contexte Spring. Un `@Value` isolé reste acceptable pour une valeur ponctuelle.

## 6. Logging

SLF4J, messages paramétrés : `log.debug("orderId={}", id)`. La concaténation construit la
chaîne **même quand le niveau est désactivé** ; la forme paramétrée ne la construit que si
le log est émis. Jamais de `System.out` dans du code applicatif.

## 7. Tests — quel étage pour quel comportement

Côté Spring :

| Étage | Outil | Pour quoi |
|---|---|---|
| Rapide | JUnit nu, sans Spring | logique pure, un service dont on mocke les collaborateurs |
| Rapide | `@WebMvcTest`, `@DataJpaTest`, `@JsonTest` | une seule tranche du contexte |
| Large | `@SpringBootTest` | câblage réel, bout en bout |

`@SpringBootTest` démarre le contexte complet à chaque classe qui l'utilise. Employé par
défaut, il transforme une suite de quelques secondes en suite de plusieurs minutes, et la
lenteur finit par être payée en tests qu'on n'écrit plus.

## 8. À surveiller, pas à appliquer mécaniquement

- **Threads virtuels** (Java 21, `spring.threads.virtual.enabled` depuis Spring Boot 3.2) :
  gain réel sur du traitement I/O-bound, mais attention aux sections `synchronized` qui
  épinglent le thread porteur.

## Sources

- [Spring Framework — Understanding AOP proxies](https://docs.spring.io/spring-framework/reference/core/aop/proxying.html)
- [Spring Framework — Declarative transaction management](https://docs.spring.io/spring-framework/reference/data-access/transaction/declarative.html)
- [Baeldung — Why field injection is not recommended](https://www.baeldung.com/java-spring-field-injection-cons)
- [JEP 441 — Pattern Matching for switch](https://openjdk.org/jeps/441)
- [Spring Boot — Testing, test slices](https://docs.spring.io/spring-boot/reference/testing/spring-boot-applications.html)
