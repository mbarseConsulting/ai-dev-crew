# kafka

> Chargé quand le contexte le demande. Deux étages :
> **Règles** fait autorité, **Pourquoi** explique. En cas de désaccord, Règles a raison.

## Règles

### What you MUST do

- Treat every consumer as at-least-once: make the handler idempotent, because redelivery is normal operation and not an incident
- Choose the message key deliberately — it decides the partition, and the partition is the only unit in which Kafka guarantees ordering. Events that must stay ordered relative to each other share a key
- Commit the offset **after** the work has succeeded, not when the record was received
- Carry an event id and an event timestamp in every envelope: the id is what makes consumer-side deduplication possible, the timestamp is what makes an ordering problem diagnosable
- Evolve a schema additively — new optional fields only — and keep producers and consumers deployable in either order
- Route a message that cannot be processed to a dead-letter topic, together with the failure reason and enough context to replay it
- Keep per-record processing short, or increase `max.poll.interval.ms` deliberately: exceeding it makes the broker consider the consumer dead and triggers a rebalance

### What you NEVER do

- Never assume global ordering — Kafka orders within a partition, never across a topic
- Never assume exactly-once: it exists only with the transactional producer and a read-committed consumer, explicitly configured. Absent that, design for at-least-once
- Never leave `enable.auto.commit=true` where losing a record on handler failure is unacceptable — the offset advances whether or not the work succeeded
- Never swallow a poison message: an unbounded retry blocks its partition, and a silent skip loses data with no trace
- Never change an event payload in a way that breaks existing consumers without flagging it and stopping — an event schema is a contract exactly like an HTTP one
- Never perform long blocking work inside the poll loop
- Do NOT use these rules for synchronous HTTP contracts (`references/api-rest.md`) or socket sessions (`references/ws.md`)

### What you report but don't auto-fix

- Introducing a schema registry where none exists
- Moving to a transactional producer for exactly-once semantics
- Changing a topic's partition count — it remaps every key, so previously ordered events can be reordered

<!-- Customization hook — convention de nommage des topics, registry, politique de DLQ et de rejeu  : le fichier projet, jamais ici -->

### En un coup d'oeil

- Topic naming, key choice, and what ordering actually guarantees
- Delivery semantics and consumer idempotence
- Offsets, retry, dead-letter
- Event schema evolution as a contract

---

## Pourquoi

> **Quoi et pourquoi.** Le nommage des topics, le registry et la politique de rejeu retenus
> vont dans le **fichier projet**, jamais ici.
>
> Dernière passe de veille : 2026-09-14
>
> Les contrats HTTP sont dans `references/api-rest.md`, les sockets dans `references/ws.md`.

## 1. L'ordre est une propriété de la partition, jamais du topic

C'est le malentendu le plus coûteux, parce qu'il ne se manifeste qu'en production, sous
charge, quand deux événements du même agrégat arrivent dans le désordre.

Kafka garantit l'ordre **à l'intérieur d'une partition**. La partition est choisie par
hachage de la **clé** du message. Donc :

- même clé → même partition → ordre garanti entre ces messages ;
- clé `null` → répartition round-robin → **aucune** garantie d'ordre.

D'où la règle de conception : la clé, c'est l'identité de ce dont l'ordre compte. Pour des
événements de commande, c'est l'identifiant de commande — pas un UUID d'événement, qui
disperserait dans toutes les partitions les événements d'une même commande.

Corollaire souvent oublié : **changer le nombre de partitions remappe toutes les clés**.
Des messages jusque-là ordonnés entre eux peuvent se retrouver dans des partitions
différentes. Ce n'est pas une opération de capacité anodine.

## 2. Sémantiques de livraison

| Sémantique | Comment on l'obtient | Ce qu'on paie |
|---|---|---|
| At-most-once | commit de l'offset **avant** traitement (`enable.auto.commit=true` en pratique) | perte de message si le handler échoue |
| At-least-once | commit **après** traitement réussi | doublons, donc handler idempotent obligatoire |
| Exactly-once | producer transactionnel + consumer `read_committed`, configuré explicitement | débit réduit, complexité réelle |

**Le défaut raisonnable est at-least-once.** « Exactly-once » n'existe pas par accident :
si personne n'a configuré les transactions, le système est at-least-once, et un handler non
idempotent est un bug en attente d'un rebalance.

`enable.auto.commit=true` mérite une mention à part : l'offset avance sur un timer, sans
rapport avec la réussite du traitement. Un handler qui échoue voit malgré tout son offset
commité — le message est perdu, silencieusement.

## 3. Rendre un consumer idempotent

Deux voies :

- **Naturellement idempotente** — l'opération est un `upsert` par clé, ou un passage à un
  état terminal. Rejouer ne change rien. C'est la voie à préférer.
- **Déduplication explicite** — l'enveloppe porte un `eventId`, le consumer garde une trace
  des identifiants traités (table, cache avec TTL) et ignore les redites. Le TTL doit
  couvrir la fenêtre de rejeu réaliste, pas quelques secondes.

D'où la présence obligatoire d'un `eventId` et d'un `timestamp` dans l'enveloppe : sans
identifiant, la déduplication est impossible ; sans horodatage, un problème d'ordre est
indiagnosticable après coup.

## 4. Message empoisonné et DLQ

Un message que le handler ne saura jamais traiter — payload corrompu, schéma inconnu,
référence absente — a deux issues incorrectes :

- **retry infini** : la partition est bloquée derrière lui, et tout ce qui suit s'arrête ;
- **skip silencieux** : la donnée est perdue sans trace.

La bonne issue est un topic de rejet, avec le message d'origine, la raison de l'échec, et
assez de contexte (topic, partition, offset, horodatage) pour rejouer une fois la cause
corrigée. Une DLQ que personne ne consulte n'est qu'un skip silencieux plus lent : elle
doit être supervisée.

## 5. Évolution de schéma

Un événement est un contrat, au même titre qu'une réponse HTTP — avec une difficulté en
plus : les consommateurs ne se redéploient pas en même temps que le producteur, et les
anciens messages restent lisibles dans le topic pendant toute la rétention.

Compatible : ajouter un champ optionnel. Rupture : renommer, supprimer, changer un type,
restreindre une énumération côté consumer.

Le critère opérationnel : **producteur et consommateurs doivent pouvoir être déployés dans
n'importe quel ordre.** Si un ordre est imposé, le changement est une rupture déguisée.

## 6. Rebalance

Dépasser `max.poll.interval.ms` entre deux `poll()` fait considérer le consumer comme mort
et déclenche un rebalance — qui redistribue les partitions, interrompt les traitements en
cours et peut enchaîner en cascade si la cause persiste.

C'est ce qui arrive quand on fait du travail long et bloquant dans la boucle de poll. Deux
sorties : réduire le temps par enregistrement, ou augmenter l'intervalle **délibérément**,
en sachant qu'on allonge d'autant le délai de détection d'un vrai consumer mort.

## Sources

- [Apache Kafka — Design et garanties](https://kafka.apache.org/documentation/#design)
- [Apache Kafka — Consumer configuration](https://kafka.apache.org/documentation/#consumerconfigs)
- [Confluent — Message delivery guarantees](https://docs.confluent.io/kafka/design/delivery-semantics.html)
