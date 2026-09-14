# _crew — doctrine d'arbitrage

Trois règles décident où va une règle, quelle taille fait un fichier, et quand un agent
mérite d'exister. Elles sont l'antidote à la duplication qu'interdit l'ADR 0008.

## 1. Placement

> **Une règle appartient à l'axe qui reste vrai si tu changes de techno.**

| Règle | Axe |
|---|---|
| Injection par constructeur | `java-craft` — n'a aucun sens hors Spring |
| Un contrôleur ne retourne jamais l'objet persistant | `layering-craft` — vrai aussi en Node |
| Pas de point final dans le `summary` OpenAPI | `api-rest-craft` — vrai Java **et** BFF |
| `@MappedSuperclass` ≠ `@Entity` | `persistence-craft` |

Si tu hésites entre deux cases, la règle est mal formulée — le schéma ne manque pas d'une case.

## 2. Granularité

> **Un fichier = ce qui tient dans une fenêtre de collage et se charge ensemble.**

Contrainte dérivée du terrain : sur site, les skills sont **collées à la main** dans un
modèle imposé. Un `SKILL.md` qui ne tient pas dans une fenêtre ne sert à rien. C'est
pourquoi `persistence-craft` est séparée de `java-craft` alors que la règle 1 seule les
fusionnerait.

## 3. Existence d'un agent

> **Un agent n'existe que par ce qu'il ne peut pas faire, ou par ce qu'il n'a pas vu.**

Les skills portent le comportement ; les agents ne portent que **contrainte** (`tools:`,
ADR 0004) et **isolation** (contexte vierge, ADR 0003). Un agent qui n'apporte ni l'une ni
l'autre est un alias de sa liste de skills.

## Composition — un graphe, pas un arbre

Quatre arêtes, aucune n'excluant les autres ([ADR 0014](./adr/0014-activity-first-skill-agent-pattern.md)) :
skill → ses références · skill → persona · persona → ses références · persona ou skill → autre skill.

Le premier niveau est l'**activité**, jamais le domaine de connaissance : l'activité est la seule
chose connue au moment de l'invocation. Le domaine se découvre pendant le travail, donc il se route.

## Contrat des deux fichiers de référence

| | `## Pourquoi` (dans une référence) | `references/house-rules.md` |
|---|---|---|
| Répond à | quoi et pourquoi | avec quoi ici |
| Source | veille, doc officielle | lecture de leur codebase |
| Rythme | passe périodique | gros à l'onboarding puis stable |
| Durée de vie | toute la carrière | meurt avec le poste |
| Committé | oui | **jamais** (gitignoré ; seul le template l'est) |

## Mode collage (modèle imposé, pas d'auto-chargement)

Les renvois par nom (« applique `testfix` ») supposent un harness capable de charger la
cible. En copier-coller, un pointeur vers un fichier absent est un lien mort. Les fichiers
d'entrée doivent donc déclarer en tête ce qu'il faut coller avec eux.
