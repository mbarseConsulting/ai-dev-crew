# node-bff-craft — fonds universel

> **Quoi et pourquoi.** Le framework HTTP, les conventions de logging/tracing et la gestion
> des secrets retenus vont dans `house-rules.md`, gitignoré.
>
> Dernière passe de veille : 2026-09-14
>
> Le code Angular est dans `angular-craft`, la forme du contrat exposé dans `api-rest-craft`,
> les frontières internes d'un backend dans `layering-craft`.

## 1. Ce qu'un BFF est, et ce qu'il devient si on n'y prend pas garde

Un BFF existe pour une raison : **un écran a besoin d'une forme de données que le backend
générique ne fournit pas**, et faire porter cette forme au backend le coupleraient à une
interface utilisateur. Le BFF absorbe ce couplage et le tient à l'écart du domaine.

Il agrège, il reformate, il protège. Il ne décide pas.

La dérive se fait toujours par petites étapes raisonnables : une condition « juste pour cet
écran », un calcul « que le backend ne fait pas encore », une valeur par défaut « en
attendant ». Au bout de quelques mois, la règle métier existe en deux endroits, et c'est la
copie du BFF que personne n'audite, que personne ne teste au même niveau, et qui diverge.

Le test : *si un autre client — une appli mobile, un batch — devait appliquer cette règle,
devrait-elle être réécrite ?* Si oui, elle n'est pas à sa place.

## 2. Timeouts et dégradation

Un BFF transforme une action utilisateur en plusieurs appels. Sans timeout explicite, la
réponse est lente comme sa dépendance la plus lente — et une dépendance bloquée bloque un
handler, puis la pool de connexions, puis le BFF entier. Un incident sur un service
secondaire devient une panne totale.

Donc, par dépendance :

- un **timeout explicite**, plus court que le budget de réponse du BFF lui-même ;
- une **décision de criticité** : cette dépendance est-elle nécessaire à la réponse, ou son
  absence produit-elle une réponse partielle acceptable ?

C'est la valeur propre du BFF : il est le seul endroit qui connaît l'écran, donc le seul
qui puisse décider que les recommandations manquantes sont tolérables alors que le solde du
compte ne l'est pas.

## 3. Retry : seulement si c'est sûr

Un timeout **ne dit pas que rien ne s'est passé** — il dit que la réponse n'est pas
arrivée. La requête a pu aboutir.

Rejouer un appel idempotent (`GET`, `PUT`, `DELETE`) est sans danger. Rejouer un `POST`
crée un doublon : un paiement, une commande, un e-mail en double. Si le rejeu est
nécessaire sur une opération non idempotente, il passe par une clé d'idempotence portée par
l'appel — voir `api-rest-craft`.

Et un rejeu consomme le **même** budget de réponse que l'appel initial : trois tentatives à
deux secondes, c'est six secondes d'attente utilisateur.

## 4. Secrets et jetons

Le BFF est la frontière où s'arrêtent les secrets. Les identifiants des services amont, les
clés d'API, les jetons machine-à-machine restent côté serveur.

Pour la session utilisateur, le point sensible est ce que la page peut lire : un jeton
accessible aux scripts de la page est accessible à tout ce qui est injecté dans la page.
Un cookie `HttpOnly`, `Secure`, `SameSite` n'est pas lisible par le JavaScript de la page —
c'est ce qui fait la différence, pas l'endroit où on le range.

Et ce qui redescend au navigateur est ce dont l'écran a besoin : renvoyer le payload amont
tel quel expose des champs que personne n'a décidé d'exposer.

## 5. Erreurs

Une erreur amont ne traverse pas. Deux raisons distinctes :

- elle porte du détail interne — nom de service, trace, message technique ;
- sa **forme** est le contrat de l'amont, pas celui promis au navigateur. La laisser passer
  fait dépendre le front d'un contrat qu'il n'a jamais signé, et un changement amont casse
  le front sans que le BFF ait changé d'une ligne.

Le BFF traduit vers son propre contrat d'erreur (`api-rest-craft`), en conservant côté logs
l'erreur d'origine et l'identifiant de corrélation.

## 6. Corrélation

Une action utilisateur devient N appels. Sans identifiant propagé de bout en bout, une
erreur amont est introuvable : on sait qu'un appel a échoué, pas lequel des trois écrans
l'a déclenché ni dans quelle séquence.

Générer l'identifiant s'il n'existe pas, le propager dans chaque appel sortant, le journaliser
à l'entrée et à la sortie, et le renvoyer au client dans la réponse d'erreur — c'est ce qui
permet à un utilisateur de signaler un problème identifiable.

## 7. Cache

Le BFF est tentant comme endroit de cache, et c'est un piège classique : **une réponse
agrégée est presque toujours propre à un utilisateur**. Mise dans un cache partagé sans
l'utilisateur dans la clé, elle est servie à quelqu'un d'autre — une fuite de données, pas
un bug de performance.

Et la fraîcheur d'un écran est une décision produit, pas une optimisation technique :
cacher trente secondes un solde de compte n'est pas un arbitrage que la couche technique
peut prendre seule.

## Sources

- [Sam Newman — Pattern: Backends For Frontends](https://samnewman.io/patterns/architectural/bff/)
- [OWASP — HTML5 / Browser storage of tokens](https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html)
- [MDN — Set-Cookie: HttpOnly, Secure, SameSite](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie)
- [W3C — Trace Context](https://www.w3.org/TR/trace-context/)
