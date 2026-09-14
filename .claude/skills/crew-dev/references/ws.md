# ws

> Chargé quand le contexte le demande. Deux étages :
> **Règles** fait autorité, **Pourquoi** explique. En cas de désaccord, Règles a raison.

## Règles

### What you MUST do

- Give every message a typed envelope — a discriminator plus a payload — so both ends route without guessing, and version that envelope from the first message rather than after the first incompatible change
- Authenticate at the handshake **and** re-check authorisation on anything sensitive: a long-lived socket outlives the token that opened it, and permissions revoked mid-session must take effect
- Validate inbound messages exactly as you would an HTTP body — a socket frame is external input like any other
- Reconnect with exponential backoff **and jitter**: without jitter, every client reconnects in step and turns a server blip into a thundering herd
- Resynchronise after reconnect rather than resuming: fetch current state, or replay from a sequence number the client carries. A reconnected socket is a new session, not a continuation
- Run an application-level heartbeat (ping/pong): a TCP connection can be dead for minutes without either side being told
- Bound the outbound queue per connection and decide explicitly what happens when it fills — drop, coalesce, or disconnect

### What you NEVER do

- Never use a socket for what request/response does better — a socket earns its cost only for server-initiated or continuous flow
- Never assume delivery, ordering, or continuity across a reconnect
- Never leave a session authorised for its whole lifetime on the handshake token alone
- Never broadcast without checking each recipient's authorisation — a room or topic is a routing mechanism, not an access-control decision
- Never buffer without a bound: a slow consumer then becomes a server-side memory leak
- Do NOT use these rules for HTTP contracts (`references/api-rest.md`) or broker-based events (`references/kafka.md`)

### What you report but don't auto-fix

- Replacing the socket with Server-Sent Events when the flow is actually one-directional
- Introducing a broker behind the socket so several server instances can fan out to the right sessions

<!-- Customization hook — forme exacte de l'enveloppe, stratégie d'auth de handshake, intervalle de heartbeat : le profil projet (hors bibliothèque) -->

### En un coup d'oeil

- Typed, versioned envelope
- Lifecycle: handshake, auth, heartbeat, reconnection, resynchronisation
- Backpressure and bounded buffers
- Socket versus HTTP: where the boundary actually is

---

## Pourquoi

> **Quoi et pourquoi.** L'enveloppe exacte, la stratégie d'auth du handshake et l'intervalle
> de heartbeat retenus vont dans le **profil projet**, tenu hors de cette bibliothèque.
>
> Dernière passe de veille : 2026-09-14
>
> Les contrats HTTP sont dans `references/api-rest.md`, les événements de broker dans `references/kafka.md`.

## 1. Socket, SSE ou HTTP : choisir avant de coder

| Besoin | Choix | Pourquoi |
|---|---|---|
| Le client demande, le serveur répond | HTTP | cache, rejeu, outillage, débogage triviaux |
| Le serveur pousse, le client écoute | **SSE** | reconnexion automatique intégrée, passe les proxys, bien plus simple |
| Les deux sens, en continu, à faible latence | **WebSocket** | seul cas où le coût se justifie |

Le coût d'un socket est réel : état de connexion par client, authentification qui ne suit
plus le modèle requête/réponse, reconnexion à écrire, montée en charge multi-instance,
absence de cache. Un flux unidirectionnel traité en WebSocket est presque toujours du SSE
réécrit à la main, moins bien.

## 2. Authentification et autorisation

Un socket **survit à son jeton**. Une session ouverte le matin avec un token d'une heure est
toujours ouverte l'après-midi : si l'autorisation n'est vérifiée qu'au handshake, une
permission révoquée ne prend jamais effet.

Donc : authentifier au handshake **et** revérifier l'autorisation sur tout message
sensible. Prévoir aussi la fermeture côté serveur quand les droits changent.

Et la diffusion : appartenir à une *room* ou à un *topic* est un mécanisme de **routage**,
pas une décision de contrôle d'accès. Diffuser à une room sans vérifier chaque destinataire
revient à déléguer l'autorisation à la structure de routage.

## 3. Reconnexion : backoff **et** jitter

Le backoff exponentiel seul ne suffit pas. Si le serveur a eu une micro-coupure, tous les
clients se sont déconnectés **au même instant** ; avec le même backoff, ils se
reconnectent tous au même instant, puis retentent ensemble. Une coupure d'une seconde
devient une panne entretenue par ses propres clients.

Le jitter — une part aléatoire dans le délai — est ce qui étale la reprise. Ce n'est pas un
raffinement, c'est ce qui empêche le troupeau.

## 4. Resynchroniser, pas reprendre

Une reconnexion n'est pas la suite de la session précédente : des messages ont pu être émis
pendant la coupure, et rien ne les a conservés. Deux stratégies :

- **État courant** — au retour, le client redemande l'état complet et repart de là. Simple,
  suffisant dans la plupart des cas.
- **Numéro de séquence** — le client mémorise le dernier numéro reçu et le serveur rejoue à
  partir de là. Plus fin, mais impose au serveur de conserver un tampon par session.

Ce qui n'est jamais correct, c'est de supposer la continuité.

## 5. Heartbeat

Une connexion TCP peut être morte plusieurs minutes sans que ni l'un ni l'autre des côtés
en soit informé — un NAT qui a expiré l'entrée, un boîtier intermédiaire qui a coupé, un
client dont le réseau a disparu sans FIN. Les deux extrémités croient la session vivante :
le serveur garde de la mémoire pour un client absent, le client attend des messages qui
n'arriveront pas.

Le ping/pong applicatif est la seule détection fiable. Il fixe aussi la borne haute du
délai de détection d'une déconnexion.

## 6. Backpressure

Un client lent est un problème **serveur**. Si la file d'émission par connexion n'est pas
bornée, un consommateur lent fait croître la mémoire du serveur jusqu'à l'incident, et il
suffit d'un client sur un réseau dégradé.

Borner la file, et décider explicitement du comportement quand elle se remplit : jeter les
messages les plus anciens (acceptable pour un flux d'état où seul le dernier compte),
fusionner (coalescing) si seule la valeur courante importe, ou fermer la connexion en
laissant le client resynchroniser. Le choix dépend du flux — l'absence de choix, non.

## 7. Plusieurs instances serveur

Une session est attachée à **une** instance. Un événement produit sur une autre instance ne
peut donc pas atteindre le client sans relais : un broker (Redis pub/sub, Kafka) auquel
toutes les instances sont abonnées, chacune ne poussant qu'aux sessions qu'elle détient.
Une architecture socket qui fonctionne en mono-instance et qu'on scale horizontalement sans
ce relais perd des messages de façon apparemment aléatoire.

## Sources

- [RFC 6455 — The WebSocket Protocol](https://www.rfc-editor.org/rfc/rfc6455.html)
- [MDN — Writing WebSocket servers](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API/Writing_WebSocket_servers)
- [MDN — Server-Sent Events](https://developer.mozilla.org/en-US/docs/Web/API/Server-sent_events/Using_server-sent_events)
- [AWS Architecture Blog — Exponential backoff and jitter](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
