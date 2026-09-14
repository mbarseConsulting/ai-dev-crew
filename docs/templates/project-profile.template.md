# Profil projet — <nom du projet>

> **Ce fichier ne vit PAS dans le crew.** Le crew ne contient que ce qui suit son porteur à
> vie ; un projet est jetable. Range ce profil dans ton espace à toi, hors du dépôt du crew
> et hors du dépôt client — un fichier par projet, supprimable sans rien casser.
>
> Il répond à deux questions qu'aucune détection automatique ne peut trancher :
> **quel est le domaine** (indétectable depuis l'arborescence) et **comment ça s'appelle ici**.
>
> En mode collage, c'est le premier fichier à coller, avant `crew-dev/SKILL.md`.

## Domaine

> Détermine les références de domaine à charger. Une seule détection n'y suffit pas :
> rien dans un dépôt ne dit « ce projet fait de l'IoT ».

| Domaine | Référence à charger |
|---|---|
| _ex : IoT_ | `references/iot.md` |

## Stack

> Redondant avec la table de détection quand elle suffit ; utile quand elle ne suffit pas
> (monorepo hétérogène, module isolé, techno minoritaire).

| Couche | Techno | Persona |
|---|---|---|
| Back | | `agent-java` |
| Front | | `agent-angular` |
| BFF | | `agent-node-bff` |
| Messaging | | `references/kafka.md` |
| Temps réel | | `references/ws.md` |

## Conventions maison

> « Comment ça s'appelle ici », jamais « pourquoi » — le pourquoi est dans les sections
> `## Pourquoi` des références, et lui est publiable.

### Java / Spring

| Rôle | Nom ici | Emplacement |
|---|---|---|
| | | |

### Persistance

| Question ouverte dans `persistence.md` | Réponse ici |
|---|---|
| Classe de base d'entité | |
| Stratégie `equals`/`hashCode` retenue | |
| Type d'identifiant | |

### Couches

| Rôle | Nom ici |
|---|---|
| Mapper | |
| Découpage en packages | |

### API REST

| Question | Réponse ici |
|---|---|
| Stratégie de version | |
| Enveloppe d'erreur | |
| Style de pagination | |

### Kafka

| Question | Réponse ici |
|---|---|
| Nommage des topics | |
| Registry de schémas | |
| Politique de DLQ et de rejeu | |

### WebSocket

| Question | Réponse ici |
|---|---|
| Forme de l'enveloppe | |
| Auth du handshake | |
| Heartbeat | |

## Écarts assumés par rapport aux références

| Règle universelle | Ce qu'on fait ici | Pourquoi |
|---|---|---|
