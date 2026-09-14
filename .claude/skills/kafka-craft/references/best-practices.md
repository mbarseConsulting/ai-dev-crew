# kafka-craft — fonds universel

> **Quoi et pourquoi.** Le nommage des topics, le registry et la politique de rejeu retenus
> vont dans `house-rules.md`, gitignoré.
>
> Dernière passe de veille : 2026-09-14
>
> Les contrats HTTP sont dans `api-rest-craft`, les sockets dans `ws-craft`.

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
