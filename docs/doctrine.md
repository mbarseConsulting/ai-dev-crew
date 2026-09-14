# ai-dev-crew — doctrine d'arbitrage

Ces règles décident où va une règle, comment s'appelle son fichier, quelle taille il fait, ce
qu'une skill a le droit de citer, et quand un agent mérite d'exister. Elles sont l'antidote à
la duplication qu'interdit l'ADR 0008.

**Ce fichier est la seule source de l'organisation des fichiers.** `README.md` et `SPEC.md` y
renvoient sans la répéter ; `scripts/crew-doctor.sh` la vérifie ; `crew-maintenance -d` la lit
avant de réparer.

## 1. Placement

> **Une règle propre à un framework va dans son techno. Une règle vraie quel que soit le framework va dans les références partagées de la skill. Une règle qui disparaît quand le domaine change va dans le domaine.**

| Règle | Domicile |
|---|---|
| Injection par constructeur | `technos/java.md` — n'a aucun sens hors Spring |
| `@MappedSuperclass` ≠ `@Entity` | `technos/java-persistence.md` — n'existe qu'en JPA |
| Un contrôleur ne retourne jamais l'objet persistant | `references/bp-layering.md` — vrai aussi en Node |
| Pas de point final dans le `summary` OpenAPI | `references/bp-api-rest.md` — vrai Java **et** BFF |
| Une collection vide, jamais `null` | `references/bp-code.md` — vrai dans tous les langages |
| Porter l'horloge device **et** l'horloge serveur | `references/dom-iot.md` — disparaît hors IoT |

Un techno ne répète ni une règle partagée, ni une règle d'agent : « signaler un changement de
contrat » est une règle de `agent-dev`, pas de chaque techno. Si tu hésites entre deux cases, la
règle est mal formulée — le schéma ne manque pas d'une case.

## 2. Organisation des fichiers de `crew`

Le dossier dit la nature, le préfixe dit le sujet.

| Chemin | Nature | Chargé par |
|---|---|---|
| `agents/agent-<rôle>.md` | un rôle | le flag de `SKILL.md` |
| `technos/<techno>.md` (sans tiret) | les règles d'un framework | la table de détection de `SKILL.md` |
| `technos/<techno>-<sujet>.md` | le `## Pourquoi` ou un sous-sujet de ce framework | la liste `REFERENCES` de `technos/<techno>.md` |
| `references/bp-<sujet>.md` | bonne pratique partagée | la table partagée de `SKILL.md`, par contexte |
| `references/dom-<domaine>.md` | domaine métier | la table partagée, quand le fichier projet le déclare |
| `references/proc-<procédure>.md` | procédure d'un rôle | son agent |

Un fichier de `references/` sans préfixe connu, ou qui n'est cité nulle part où il se charge,
est une erreur du doctor.

## 3. Granularité

> **Un fichier = ce qui tient dans une fenêtre de collage et se charge ensemble.**

Contrainte dérivée du terrain : sur site, les skills sont **collées à la main** dans un
modèle imposé. Un fichier qui ne tient pas dans une fenêtre ne sert à rien. C'est pourquoi
`technos/java-persistence.md` est séparée de `technos/java.md`, et pourquoi `crew/SKILL.md`
est un routeur court qui laisse chaque procédure à son agent.

## 4. Autonomie

> **Une skill ne nomme aucune autre skill.**

Une skill ne référence que ses propres fichiers, par chemin relatif à son répertoire. Un
renvoi vers une autre skill est un lien mort dès qu'on l'utilise seule — c'est-à-dire
presque toujours, et toujours en collage. Si deux activités ont besoin du même savoir,
elles sont deux **agents** de la même skill, pas deux skills qui se citent
([ADR 0016](./adr/0016-one-crew-skill-role-as-mode.md)).

**Une exception, une seule : `crew-maintenance` nomme `crew`.** Elle n'existe que pour
maintenir `crew`, dans ce dépôt, et n'est jamais utilisée seule ni copiée chez un client : le
motif de la règle ne s'y applique pas. Aucune skill ne nomme `crew-maintenance`. Le doctor
vérifie les deux sens ([ADR 0017](./adr/0017-crew-maintenance-out-of-crew.md)).

Composer deux skills est le travail d'un agent : chaque shell de `.claude/agents/` précharge `crew` et `crew-project`.

## 5. Existence d'un agent

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
| Rythme | `crew-maintenance -w` | gros à l'onboarding puis stable |
| Durée de vie | toute la carrière | meurt avec le poste |
| Committé | oui | **jamais** (gitignoré) |

## Mode collage (modèle imposé, pas d'auto-chargement)

Rien n'est chargé pour toi. Le routeur `crew/SKILL.md` liste les fichiers à coller
ensemble, fichier projet en premier. Comme aucune skill collée n'en nomme une autre, un
collage n'a jamais besoin d'une deuxième skill. `crew-maintenance` ne se colle jamais.
