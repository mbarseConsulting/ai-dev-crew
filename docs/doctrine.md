# ai-dev-crew — doctrine d'arbitrage

Quatre règles décident où va une règle, quelle taille fait un fichier, ce qu'une skill a le
droit de citer, et quand un agent mérite d'exister. Elles sont l'antidote à la duplication
qu'interdit l'ADR 0008.

## 1. Placement

> **Une règle appartient à l'axe qui reste vrai si tu changes de techno — et au domaine si elle disparaît quand le domaine change.**

| Règle | Domicile |
|---|---|
| Injection par constructeur | `technos/java.md` — n'a aucun sens hors Spring |
| Un contrôleur ne retourne jamais l'objet persistant | `references/layering.md` — vrai aussi en Node |
| Pas de point final dans le `summary` OpenAPI | `references/api-rest.md` — vrai Java **et** BFF |
| `@MappedSuperclass` ≠ `@Entity` | `references/persistence.md` |
| Porter l'horloge device **et** l'horloge serveur | `references/iot.md` — disparaît hors IoT |

Si tu hésites entre deux cases, la règle est mal formulée — le schéma ne manque pas d'une case.

## 2. Granularité

> **Un fichier = ce qui tient dans une fenêtre de collage et se charge ensemble.**

Contrainte dérivée du terrain : sur site, les skills sont **collées à la main** dans un
modèle imposé. Un fichier qui ne tient pas dans une fenêtre ne sert à rien. C'est pourquoi
`references/persistence.md` est séparée de `technos/java.md` alors que la règle 1 seule les
fusionnerait, et pourquoi `crew/SKILL.md` est un routeur court qui laisse chaque procédure
à son agent.

## 3. Autonomie

> **Une skill ne nomme aucune autre skill.**

Une skill ne référence que ses propres fichiers, par chemin relatif à son répertoire. Un
renvoi vers une autre skill est un lien mort dès qu'on l'utilise seule — c'est-à-dire
presque toujours, et toujours en collage. Si deux activités ont besoin du même savoir,
elles sont deux **agents** de la même skill, pas deux skills qui se citent
([ADR 0016](./adr/0016-one-crew-skill-role-as-mode.md)).

Composer deux skills est le travail d'un agent : `.claude/agents/agent-butler.md` précharge `crew` et `crew-project`.

## 4. Existence d'un agent

> **Un agent n'existe que par ce qu'il ne peut pas faire, ou par ce qu'il n'a pas vu.**

Les skills portent le comportement ; les agents ne portent que **contrainte** (`tools:`,
ADR 0004) et **isolation** (contexte vierge, ADR 0003). Un agent qui n'apporte ni l'une ni
l'autre est un alias de sa liste de skills.

## Composition

Une chaîne : routeur → agent (le rôle) → techno → références.

Le premier niveau est ce qu'on sait au moment de taper la commande : quelle skill, quel
rôle. La techno se découvre pendant le travail, donc elle se route
([ADR 0014](./adr/0014-activity-first-skill-agent-pattern.md), [ADR 0016](./adr/0016-one-crew-skill-role-as-mode.md)).

## Contrat des deux sources de savoir

| | Référence (`## Règles` / `## Pourquoi`) | Fichier projet (`crew-project/<projet>.md`) |
|---|---|---|
| Répond à | quoi et pourquoi | avec quoi ici |
| Source | veille, doc officielle | lecture de leur codebase |
| Rythme | `crew -w` | gros à l'onboarding puis stable |
| Durée de vie | toute la carrière | meurt avec le poste |
| Committé | oui | **jamais** (gitignoré) |

## Mode collage (modèle imposé, pas d'auto-chargement)

Rien n'est chargé pour toi. Le routeur `crew/SKILL.md` liste les fichiers à coller
ensemble, fichier projet en premier. Comme aucune skill n'en nomme une autre, un collage
n'a jamais besoin d'une deuxième skill.
