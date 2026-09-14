# bff — Backend For Frontend

> Chargé quand le contexte le demande. Deux étages :
> **Règles** fait autorité, **Pourquoi** explique. En cas de désaccord, Règles a raison.

## Règles

### What you MUST do

- Keep the BFF a composition layer: it aggregates, reshapes and protects. A business rule belongs to the backend that owns the data it governs
- Shape each endpoint around one screen's need — that is the entire point of a BFF, and the reason it may legitimately differ from the backend's own contract
- Put an explicit timeout on every outbound call, shorter than the BFF's own response budget, and decide per dependency what a failure means: degrade the response, or fail it
- Keep tokens and secrets server-side. What the browser receives is what the screen needs, never what happened to be in the upstream payload
- Propagate a correlation id through every outbound call, and log it — a BFF turns one user action into several calls, and without it a failure cannot be traced back
- Validate what comes from the browser before forwarding it: being closer to the front end does not make input trusted
- Retry only idempotent calls, with backoff — and count a retry against the same response budget as the original

### What you NEVER do

- Never duplicate a business rule already owned by a backend service: two copies of a rule will disagree, and the BFF's copy is the one nobody audits
- Never forward an upstream error verbatim — it carries internal detail, and its shape is the upstream's contract, not the one the browser was promised
- Never let the browser hold something it cannot protect: a token readable by page scripts is a token available to anything injected into the page
- Never retry a non-idempotent call after a timeout — a timeout means the outcome is unknown, not that nothing happened
- Never let one dependency without a timeout hold the whole aggregated response
- Never cache a per-user response in a shared cache without the user in the key
- Do NOT use these rules for front-end code, to the shape of the contract itself (`references/bp-api-rest.md`), or to layer boundaries inside a backend (`references/bp-layering.md`)

### What you report but don't auto-fix

- Adding a circuit breaker in front of a dependency that fails often
- Caching an aggregated response, which is a freshness decision the product owns
- Merging or splitting BFF endpoints as screens evolve

### En un coup d'oeil

- Aggregation and reshaping, without business rules
- Timeouts, deliberate degradation, retry only where it is safe
- Secrets, tokens, and what never reaches the browser
- Correlation and traceability across fan-out
- The boundary with the backend that owns the rule

---

## Pourquoi

> **Quoi et pourquoi.** Vrai quel que soit le langage du BFF. Le framework HTTP, les
> conventions de logging/tracing et la gestion des secrets retenus d'un projet vont dans son
> **fichier projet**, jamais ici.
>
> Dernière passe de veille : 2026-09-14

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
l'appel — voir `references/bp-api-rest.md`.

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

Le BFF traduit vers son propre contrat d'erreur (`references/bp-api-rest.md`), en conservant côté logs
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
