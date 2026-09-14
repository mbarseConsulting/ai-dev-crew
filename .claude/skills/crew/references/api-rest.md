# api-rest

> Chargé quand le contexte le demande. Deux étages :
> **Règles** fait autorité, **Pourquoi** explique. En cas de désaccord, Règles a raison.

## Règles

### What you MUST do

- Name paths after resources, plural and in kebab-case (`/purchase-orders/{id}/line-items`); the HTTP method is the verb, so the path never contains one
- Design the contract rather than deriving it: field names come from the domain the client consumes, never from whatever the persistence model happens to be called
- Use one consistent field-naming convention and one date format across the whole service — RFC 3339 timestamps in UTC unless the domain genuinely requires a local time
- Carry the outcome in the status code: `201` with a `Location` header on creation, `204` when there is deliberately no body, `202` when the work is accepted but not done, `409` on a state conflict
- Return one single error envelope across every endpoint — `application/problem+json` (RFC 9457) unless the project already has an established shape; validation failures extend that envelope with a field list, they do not get an envelope of their own
- Write an OpenAPI `summary` as a short capitalised phrase with **no trailing period**; anything longer belongs in `description`
- Document every parameter and every response an endpoint can actually produce, error responses included
- Use one pagination mechanism service-wide, and state in the response how the caller reaches the next page
- Give any retryable `POST` an idempotency key; `PUT` and `DELETE` are idempotent by contract, so make them so

### What you NEVER do

- Never put a verb in a path (`/getUser`, `/orders/create`) — the method already said it
- Never return `200` with an error payload: a client that trusts the status code will treat the failure as a success
- Never let a `GET` mutate state, and never let it require a body
- Never expose internal detail in an error payload — stack traces, SQL, framework exception class names, internal identifiers
- Never change an existing contract (path, field, status code, error shape) without flagging it and stopping, per `agents/agent-dev.md`'s API/schema rule — an added optional field is compatible, a renamed or removed one is not
- Never document a `summary` with a trailing period, and never leave `description` holding a sentence that belongs in `summary`
- Do NOT use these rules for internal layer boundaries or mapping (`references/layering.md`), to broker events (`references/kafka.md`), or to socket contracts (`references/ws.md`)

### What you report but don't auto-fix

- Migrating an established error shape to RFC 9457 — a breaking change for every client, worth a decision rather than a drive-by edit
- Changing an existing pagination style
- Adding hypermedia (HATEOAS) where the clients do not use it

<!-- Customization hook — stratégie de version, enveloppe d'erreur maison, style de pagination retenu  : le fichier projet, jamais ici -->

### En un coup d'oeil

- Paths, verbs, status codes
- Payload naming and date formats
- One error envelope, validation included
- Pagination, idempotency, versioning
- OpenAPI style: `summary` vs `description`, documented error responses

---

## Pourquoi

> **Quoi et pourquoi.** Transverse au langage : ce qui suit vaut pour le backend Java comme
> pour le BFF Node. Le préfixe de version, l'enveloppe d'erreur et le style de pagination
> retenus vont dans le **fichier projet**, jamais ici.
>
> Dernière passe de veille : 2026-09-14
>
> Ce qui traverse quelle couche est dans `references/layering.md`. Les contrats d'événements sont
> dans `references/kafka.md`, ceux de socket dans `references/ws.md`.

## 1. Le contrat se conçoit, il ne se déduit pas

Le défaut le plus fréquent n'est pas un mauvais nom d'URL : c'est une API qui est le reflet
de la base. Les champs portent les noms des colonnes, les ressources épousent les tables,
et chaque refactoring de persistance devient une rupture de contrat.

L'API est une **frontière publique**. Elle parle la langue de celui qui la consomme. Le
lien avec `references/layering.md` est direct : si le controller retourne l'entité, le contrat est
dérivé de la persistance par construction, et personne ne l'a jamais conçu.

## 2. Codes de statut

| Code | Quand | Détail qui compte |
|---|---|---|
| `200` | succès avec corps | — |
| `201` | ressource créée | **en-tête `Location`** vers la ressource créée |
| `202` | accepté, pas encore traité | donner au client un moyen de suivre l'avancement |
| `204` | succès délibérément sans corps | pas de corps du tout, pas un corps vide |
| `400` | requête malformée | JSON invalide, type incompatible |
| `401` / `403` | non authentifié / authentifié mais non autorisé | les confondre renseigne mal le client |
| `404` | ressource absente | aussi utilisé pour masquer une ressource non autorisée, si l'existence est confidentielle |
| `409` | conflit d'état | mise à jour concurrente, doublon métier |
| `422` | syntaxiquement valide, sémantiquement refusé | violation de règle métier |

`400` contre `422` fait débat. Ligne de partage exploitable : `400` quand le parseur ne peut
pas construire la requête, `422` quand il l'a construite et que la règle la refuse. Ce qui
compte davantage que le choix lui-même : **le même choix partout dans le service**.

## 3. Une seule enveloppe d'erreur

Le standard est **RFC 9457 — Problem Details for HTTP APIs** (2023), qui rend obsolète la
RFC 7807 :

```json
{
  "type": "https://api.exemple.fr/problems/insufficient-funds",
  "title": "Insufficient funds",
  "status": 422,
  "detail": "Balance is 12.50, requested 40.00",
  "instance": "/accounts/12345/withdrawals"
}
```

Les erreurs de validation **étendent** cette enveloppe (un tableau `errors` avec le champ et
la raison) ; elles n'en reçoivent pas une deuxième. Deux formes d'erreur dans une même API
obligent chaque client à écrire deux chemins de traitement, et le second est toujours moins
bien testé.

Ce qui ne sort jamais : stack trace, SQL, nom de classe d'exception, identifiant interne.
Ce sont des informations d'exploitation ; elles vont dans les logs, avec un identifiant de
corrélation que l'on peut, lui, renvoyer au client.

## 4. Idempotence

`PUT` et `DELETE` sont idempotents **par contrat** : rejouer l'appel doit laisser le système
dans le même état. Ce n'est pas automatique, c'est à implémenter — un `DELETE` sur une
ressource déjà supprimée répond `204`, pas `404`.

`POST` ne l'est pas. Or un client qui subit un timeout réseau **ne sait pas** si sa requête
a abouti ; s'il rejoue, il crée un doublon. D'où la clé d'idempotence : un en-tête fourni
par le client, stocké côté serveur avec la réponse produite, qui permet de renvoyer la même
réponse plutôt que de refaire le travail.

## 5. Versionnage et compatibilité

Est **compatible** : ajouter un champ optionnel en réponse, ajouter un paramètre optionnel,
ajouter un endpoint. Est **rupture** : renommer ou supprimer un champ, restreindre un format
accepté, changer un code de statut, changer la forme d'une erreur.

Le versionnage par préfixe d'URL (`/v1/`) est le plus lisible et le plus facile à router ;
celui par en-tête (`Accept`) est plus pur mais plus difficile à tester à la main et à mettre
en cache. Peu importe lequel — **un seul, et annoncé**.

## 6. Pagination

Deux familles : par offset (`page`/`size`) — simple, mais coûteuse en profondeur et
instable si des éléments sont insérés pendant le parcours ; par curseur — stable et
performante, mais sans accès direct à la page *n*.

Dans les deux cas la réponse doit dire au client **comment continuer** : un curseur suivant,
ou un total. Une liste nue le condamne à deviner.

## 7. Style OpenAPI

`summary` : phrase courte, capitalisée, **sans point final** — c'est un titre, pas une
phrase, et les générateurs l'affichent en ligne dans les listes d'endpoints où le point
final devient un artefact visuel. Tout ce qui dépasse va dans `description`.

Documenter les réponses d'erreur au même titre que le cas nominal : une spec qui ne décrit
que le `200` oblige chaque client à découvrir les échecs en production.

## Sources

- [RFC 9457 — Problem Details for HTTP APIs](https://www.rfc-editor.org/rfc/rfc9457.html)
- [RFC 9110 — HTTP Semantics (méthodes et codes de statut)](https://www.rfc-editor.org/rfc/rfc9110.html)
- [RFC 3339 — Date and Time on the Internet](https://www.rfc-editor.org/rfc/rfc3339.html)
- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
