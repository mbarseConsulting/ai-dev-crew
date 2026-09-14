# Template de création d'un projet

> Crée `<projet>/` à côté de ce dossier, puis enregistre son chemin dans `index.md`.
> Un projet est jetable : le supprimer ne casse rien.

## `<projet>/core/domain.md`

```markdown
# Domaine

> Ce qu'aucune inspection de fichiers ne peut déduire. C'est la raison d'être de ce dossier.

**Domaine :** <ex : IoT — supervision de flotte d'équipements>

**Ce que ça change concrètement :**
- <ex : les équipements sont hors ligne par intermittence, les données arrivent en retard et dans le désordre>
- <ex : la volumétrie se dimensionne sur le pic de reconnexion, pas sur le débit moyen>

**Références de domaine à charger :** <ex : iot>

**Vocabulaire métier :** les mots que l'équipe emploie et leur sens exact ici.

| Terme | Sens ici |
|---|---|
| | |
```

## `<projet>/core/stack.md`

```markdown
# Stack

| Couche | Techno et version | Rôle ici |
|---|---|---|
| Back | | |
| Front | | |
| BFF | | |
| Messaging | | |
| Temps réel | | |
| Base | | |

**Particularités qui trompent la détection automatique :** monorepo hétérogène, module isolé,
techno minoritaire, build non standard.
```

## `<projet>/index.md`

```markdown
# Snapshots

**Courant :** 001

| N° | Date | Ce qui a changé |
|---|---|---|
| 001 | <date> | création |
```

## `<projet>/snapshots/001/conventions.md`

> « Comment ça s'appelle ici », jamais « pourquoi ». Une ligne vide se lit comme *inconnu* ;
> une ligne fausse se lit comme *décidé*. Laisser vide plutôt que deviner.
>
> Remplir en **lisant le code**, pas de mémoire.

```markdown
# Conventions — snapshot 001

## Persistance
| Question | Réponse ici |
|---|---|
| Classe de base d'entité | |
| Stratégie equals/hashCode | |
| Type d'identifiant | |

## Couches
| Rôle | Nom ici |
|---|---|
| Mapper | |
| Découpage en packages | |

## API
| Question | Réponse ici |
|---|---|
| Stratégie de version | |
| Enveloppe d'erreur | |
| Pagination | |

## Messaging
| Question | Réponse ici |
|---|---|
| Nommage des topics | |
| Registry de schémas | |
| DLQ et rejeu | |

## Temps réel
| Question | Réponse ici |
|---|---|
| Enveloppe de message | |
| Auth du handshake | |
| Heartbeat | |

## Écarts assumés
| Règle générale | Ce qu'on fait ici | Pourquoi |
|---|---|---|
```

## `index.md` du routeur

Ajouter la ligne :

```markdown
| /chemin/absolu/vers/le/depot | <projet> |
```
