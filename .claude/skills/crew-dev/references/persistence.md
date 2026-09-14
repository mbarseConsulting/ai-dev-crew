# persistence

> Chargé quand le contexte le demande. Deux étages :
> **Règles** fait autorité, **Pourquoi** explique. En cas de désaccord, Règles a raison.

## Règles

### What you MUST do

- Put shared entity fields (`id`, audit columns, `@Version`) on an `abstract` base class annotated `@MappedSuperclass` — never `@Entity`, which would give the base class a table of its own
- Populate audit fields declaratively: `@CreatedDate`/`@LastModifiedDate` (plus `@CreatedBy`/`@LastModifiedBy` with an `AuditorAware`) via `@EntityListeners(AuditingEntityListener.class)`, with `@EnableJpaAuditing` on the configuration — never by hand in a service
- Implement `equals`/`hashCode` on an entity so they are stable across the transient → persisted transition (see `references/best-practices.md` for the three valid strategies)
- Use `instanceof` (or `Hibernate.getClass()`) in `equals`, never `getClass() != o.getClass()` — the latter makes a lazy proxy unequal to the entity it proxies
- Add `@Version` for optimistic locking on entities that concurrent requests can update
- Keep the transactional boundary in the service layer, on a public method, and name the read-only ones `@Transactional(readOnly = true)`
- State the fetch strategy explicitly: associations `LAZY` by default, widened per query with a `JOIN FETCH` or an entity graph — never by flipping the mapping to `EAGER`

### What you NEVER do

- Never build `hashCode()` from a database-generated id — it is `null` before `persist()` and changes after, so an entity already inside a `HashSet` becomes unfindable in its own set
- Never use `@Inheritance` merely to share columns — that is what `@MappedSuperclass` is for; `@Inheritance` is for real polymorphic querying and costs a table or a discriminator
- Never nest entity inheritance more than one level deep without flagging it — deep hierarchies and JPA combine badly
- Never reference a lazy association from `toString()` — it throws `LazyInitializationException` outside a session, usually from a log line
- Never resolve an N+1 by widening the mapping to `EAGER`; fix the query that caused it
- Never let a schema change ride along silently — flag it and stop, per `crew-dev`'s API/schema rule
- Do NOT use these rules for which layer may see an entity, or to entity → DTO → mapper boundaries — that is `references/layering.md`

<!-- Customization hook — les noms et signatures maison (classe de base, stratégie d'id, colonnes d'audit) vivent dans references/house-rules.md, jamais ici. -->

### En un coup d'oeil

- Base class: `@MappedSuperclass` vs `@Inheritance`, and what belongs on it
- Identity and equality across the transient → persisted transition
- Declarative auditing rather than hand-written timestamps
- Fetch strategy, N+1, and lazy-proxy pitfalls
- Transaction boundaries and optimistic locking

---

## Pourquoi

> **Quoi et pourquoi.** Patterns vrais quel que soit l'employeur. Ce qui est spécifique à
> une boîte (noms de classes, packages, stratégie d'id retenue) va dans `house-rules.md`.
>
> Dernière passe de veille : 2026-09-14 · Cible : Spring Boot 3.x / Jakarta Persistence 3.x

## 1. La classe de base d'entité est une ABC

« ABC » = *Abstract Base Class* : une classe non instanciable qui définit ce que les
sous-classes partagent. En JPA le pattern canonique est :

```java
@MappedSuperclass
public abstract class BaseAuditedEntity {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @CreatedDate   @Column(updatable = false) private Instant createdAt;
    @LastModifiedDate                          private Instant updatedAt;
    @CreatedBy     @Column(updatable = false) private String  createdBy;
    @LastModifiedBy                            private String  updatedBy;

    @Version private long version;
}
```

Trois choses s'y jouent, et un modèle faible se trompe sur les trois :

- **`abstract`** — la base ne doit pas être instanciable. C'est un contrat, pas un objet.
- **`@MappedSuperclass`, pas `@Entity`** — une `@MappedSuperclass` n'a pas de table à
  elle ; ses colonnes descendent dans la table de chaque fille. Avec `@Entity` +
  `@Inheritance`, tu crées une table (ou un discriminateur) dont tu n'as pas besoin.
- **Partager des colonnes n'est pas de l'héritage d'entités.** `@Inheritance` se justifie
  seulement quand tu veux *interroger polymorphiquement* (`from Vehicle` renvoyant des
  `Car` et des `Truck`). Sinon c'est du coût pur.

Corollaire : pas plus d'un niveau de hiérarchie d'entités sans raison explicite.

## 2. L'audit est déclaratif

`@EnableJpaAuditing` sur la configuration, `@EntityListeners(AuditingEntityListener.class)`
sur la base, un bean `AuditorAware<String>` pour `@CreatedBy`/`@LastModifiedBy`.

Jamais de `entity.setUpdatedAt(Instant.now())` dans un service : le jour où une entité est
modifiée par un chemin qui a oublié la ligne, l'audit ment. Et un audit qui ment est pire
qu'un audit absent.

## 3. `equals`/`hashCode` — le piège de l'id généré

**Le problème.** Un id `@GeneratedValue` vaut `null` avant `persist()` et prend une valeur
après. Si `hashCode()` dépend de l'id, il change en cours de vie de l'objet. Une entité
rangée dans un `HashSet` *avant* le flush tombe dans un autre bucket *après* : elle devient
introuvable dans son propre set, et `set.contains(e)` renvoie `false` sur `e` lui-même.

**Les trois stratégies valides** — en choisir une, la même partout :

| Stratégie | `equals` | `hashCode` | Quand |
|---|---|---|---|
| Clé métier | sur la clé naturelle | sur la clé naturelle | il existe une vraie clé naturelle immuable |
| UUID applicatif | sur l'UUID posé au constructeur | sur l'UUID | par défaut, le plus sûr |
| hashCode constant | id, avec garde `null` | `getClass().hashCode()` | base héritée qu'on ne peut pas changer |

La troisième dégrade les `HashSet` en listes chaînées — acceptable, les collections
d'entités en mémoire sont petites. Ce qui n'est jamais acceptable, c'est un hash instable.

**Et les proxies.** Sous Hibernate, une association lazy est un proxy d'une sous-classe
générée. Donc `getClass() != o.getClass()` rend un proxy non égal à son entité. Utiliser
`instanceof`, ou `Hibernate.getClass(o)`.

## 4. Chargement

- Associations `LAZY` par défaut. On élargit **par requête** (`JOIN FETCH`, `@EntityGraph`),
  jamais en repassant le mapping en `EAGER` : un `EAGER` pénalise toutes les requêtes pour
  résoudre le problème d'une seule.
- `toString()` ne touche jamais une association lazy. La `LazyInitializationException` la
  plus fréquente vient d'une ligne de log, pas du code métier.
- Un N+1 se corrige dans la requête, jamais dans le mapping.

## 5. Transactions

Frontière dans la couche service, sur une méthode `public` (le proxy Spring ne
s'applique pas aux méthodes privées — un `@Transactional` privé est silencieusement
inopérant). Lectures en `@Transactional(readOnly = true)`.

## Sources

- [Jakarta Persistence — inheritance](https://jakarta.ee/specifications/persistence/)
- [Baeldung — Hibernate Inheritance Mapping](https://www.baeldung.com/hibernate-inheritance)
- [Thorben Janssen — Complete Guide: Inheritance strategies with JPA and Hibernate](https://thorben-janssen.com/complete-guide-inheritance-strategies-jpa-hibernate/)
- [Spring Data JPA — Auditing](https://docs.spring.io/spring-data/jpa/reference/auditing.html)
