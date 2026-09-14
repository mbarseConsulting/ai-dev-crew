# layering

> Chargé quand le contexte le demande. Deux étages :
> **Règles** fait autorité, **Pourquoi** explique. En cas de désaccord, Règles a raison.

## Règles

### What you MUST do

- Stop the persisted object at the service boundary: the service returns a DTO, the controller never receives the entity. This is mechanical, not stylistic — mapping outside the transaction fails on any unloaded lazy association; see `references/persistence.md` for why, it is not restated here
- Map **out of the entity in the service**, inside the transactional boundary, by calling a dedicated mapper — a mapper is a component the service invokes, never code living in the controller or on the entity itself
- Inbound, mirror it: the controller validates and hands a request or command object to the service; the service creates or updates the entity
- Define one type per direction and per use case — a single type reused for input and output couples two contracts that evolve separately, and the day one of them changes the other is dragged along
- Keep the dependency direction inward: the domain knows nothing of the transport, the web layer, or the persistence framework
- Keep a controller to adapting a transport to a use case: bind, validate, delegate, return

### What you NEVER do

- Never return a persisted entity from a controller, and never accept one as a request body — inbound it lets a client set any mapped field, including the ones the use case never meant to expose
- Never call a repository from a controller
- Never put business logic in a controller: no branching over domain state, no orchestration of several services to enforce a rule
- Never add a second, transport-specific mapping in the controller while the API shape and the use-case output still coincide — that second hop earns its place only once they genuinely diverge (a versioned API, several clients, a BFF), and building it before is layering for its own sake
- Never institutionalise a pass-through layer: a service that only forwards to a repository and returns is cost without benefit — flag it rather than adding a mapper and an interface around it
- Do NOT use these rules for how an entity is mapped, identified, audited, or fetched (`references/persistence.md`), to the shape of the exposed HTTP contract (`references/api-rest.md`), or to Spring's injection and proxy mechanics (`agent-java`)

### What you report but don't auto-fix

- Package layout by feature rather than by technical layer, when the project has already chosen one of the two
- Introducing a mapping library where hand-written mappers are working
- Splitting the use-case output from the response model where they currently coincide — a real divergence justifies it, an anticipated one does not

<!-- Customization hook — noms des couches, découpage en packages, mapper retenu : references/house-rules.md -->

### En un coup d'oeil

- Where the persisted object stops, and who maps out of it
- One type per direction and per use case
- Dependency direction: the domain depends on nothing
- Controller as transport adapter, not as a place for rules
- Layers that earn their existence versus layers added out of habit

---

## Pourquoi

> **Quoi et pourquoi.** Patterns vrais quel que soit l'employeur — et transverses au
> langage : ce qui suit vaut côté Java comme côté BFF Node. Les noms de couches, le
> découpage en packages et le mapper retenu vont dans `house-rules.md`, gitignoré.
>
> Dernière passe de veille : 2026-09-14
>
> Le *comment* du mapping d'entité (identité, audit, chargement) est dans
> `references/persistence.md`. La forme du contrat exposé est dans `references/api-rest.md`.

## 1. Qui mappe : le service, et l'argument est mécanique

La question « service ou controller ? » se tranche par une contrainte d'exécution, pas par
une préférence d'architecture.

Si le controller mappe, le mapping a lieu **après la fermeture de la transaction**. Toute
association lazy encore non chargée lève alors une `LazyInitializationException`. Et les
deux réflexes de correction sont pires que le mal :

- passer l'association en `EAGER` — on pénalise toutes les requêtes pour en réparer une ;
- laisser `spring.jpa.open-in-view` à `true` — c'est la **valeur par défaut** de Spring
  Boot, elle maintient la session ouverte pendant le rendu de la réponse, masque l'erreur
  de conception, et déplace l'émission de requêtes SQL dans la couche web, hors de tout
  contrôle transactionnel.

L'argument de principe pointe dans la même direction mais pèse moins : si le controller
reçoit l'entité pour la mapper, la frontière est **déjà franchie** à cet instant. Ce que le
controller en fait ensuite ne rattrape rien.

Dans l'autre sens, symétrie : le controller valide et transmet une commande, le service
crée ou met à jour l'entité. Accepter une entité comme corps de requête laisse en outre un
client positionner n'importe quel champ mappé — y compris ceux que le cas d'usage n'a
jamais voulu exposer (*mass assignment*).

## 2. Deux objets, un seul nom

Le faux débat vient d'une confusion : on appelle « DTO » deux choses différentes.

| | Modèle de réponse | Sortie du cas d'usage |
|---|---|---|
| Façonné par | le contrat HTTP : nommage, format, version | le besoin métier |
| Change quand | l'API change | la règle change |
| Appartient à | `references/api-rest.md` | ici |

**Dans la grande majorité des services, les deux coïncident** — un seul saut, fait par le
service, et son DTO sert de modèle de réponse. C'est le défaut correct.

Ils ne divergent que si l'API a sa propre vie : versionnée, plusieurs clients, un BFF qui
reshape. Alors seulement un second saut, transport-spécifique, se justifie dans le
controller. Le construire avant que la divergence existe, c'est payer une indirection
permanente pour un besoin hypothétique.

## 3. Où vit le code de mapping

Troisième question, distincte des deux premières : **dans un mapper dédié** (MapStruct ou
écrit à la main), que le service appelle. Ni dans le controller, ni sur l'entité.

Une méthode `toDto()` portée par l'entité donne au modèle de persistance une connaissance
du modèle d'exposition : la dépendance part dans le mauvais sens, et l'entité devient
impossible à réutiliser pour un autre cas d'usage.

Un mapper par direction. Un mapper bidirectionnel accumule les cas particuliers des deux
sens et devient l'endroit où les règles des deux contrats se mélangent.

## 4. Sens des dépendances

Le domaine ne connaît ni le transport, ni le framework web, ni le framework de persistance.
Le test concret : *puis-je compiler le domaine sans le web ni l'ORM au classpath ?* Si non,
la dépendance est inversée quelque part.

En pratique, ce qui viole cette règle le plus souvent : une annotation de sérialisation
(`@JsonProperty`) sur un objet de domaine, ou une exception technique de l'ORM qui remonte
telle quelle dans une signature de service.

## 5. La couche qui ne sert à rien

Une skill sur les couches pousse naturellement à en ajouter. La contre-règle compte autant :

Un service qui ne fait qu'appeler le repository et retourner n'ajoute **rien** — ni règle,
ni transaction utile, ni traduction. Il ajoute un fichier, un mock dans chaque test, et un
saut de plus à lire. Le signaler plutôt que de l'entourer d'une interface et d'un mapper.

Une couche se justifie par ce qu'elle **transforme, protège ou décide**. Si on ne peut
nommer aucun des trois, elle n'existe que par symétrie avec les autres.

## Sources

- [Spring Boot — `spring.jpa.open-in-view` et ses effets](https://docs.spring.io/spring-boot/reference/data/sql.html)
- [Martin Fowler — Local DTO](https://martinfowler.com/bliki/LocalDTO.html)
- [Martin Fowler — Anemic Domain Model](https://martinfowler.com/bliki/AnemicDomainModel.html)
