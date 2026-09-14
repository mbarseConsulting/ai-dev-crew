# layering-craft — fonds universel

> **Quoi et pourquoi.** Patterns vrais quel que soit l'employeur — et transverses au
> langage : ce qui suit vaut côté Java comme côté BFF Node. Les noms de couches, le
> découpage en packages et le mapper retenu vont dans `house-rules.md`, gitignoré.
>
> Dernière passe de veille : 2026-09-14
>
> Le *comment* du mapping d'entité (identité, audit, chargement) est dans
> `persistence-craft`. La forme du contrat exposé est dans `api-rest-craft`.

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
| Appartient à | `api-rest-craft` | ici |

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
