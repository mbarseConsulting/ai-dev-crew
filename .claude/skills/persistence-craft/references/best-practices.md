# persistence-craft — fonds universel

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
