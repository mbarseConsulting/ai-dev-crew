# Profil projet — <nom du projet>

> Emplacement par défaut : `~/.crew/projects/<projet>.md`. Hors dépôt crew, hors dépôt client, supprimable.
> En mode collage, c'est le premier fichier à coller.

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
