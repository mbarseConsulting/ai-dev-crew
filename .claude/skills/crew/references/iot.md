# iot — domaine : objets connectés

> Chargé quand le fichier projet déclare le domaine IoT. Deux étages :
> **Règles** fait autorité, **Pourquoi** explique. En cas de désaccord, Règles a raison.
>
> Dernière passe de veille : 2026-09-14
>
> La mécanique de broker est dans `references/kafka.md`, le cycle de vie des sockets dans
> `references/ws.md`. Ici : ce qui disparaît si le domaine change.

## Règles

### What you MUST do

- Carry **both** timestamps on every telemetry message — when the device says the event happened, and when the server received it. Store both; decide per query which one the question is about
- Treat every device as intermittently connected: it buffers offline and dumps on reconnect, so ingestion must accept late and out-of-order arrival as normal traffic
- Key telemetry by device identifier, so one device's own messages stay ordered relative to each other
- Make ingestion idempotent on `(device id, device timestamp)` — a reconnecting device replays, and replay is normal operation
- Give every device its own revocable credential, and design rotation before the first device ships
- Bound what a device may push: message rate, payload size, and the number of distinct series it can create
- Version the message schema from the very first message, and keep every change additive — a fleet is never fully upgraded
- Acknowledge every command sent to a device, and give it an expiry: an unacknowledged command is an unknown outcome, not a delivered one

### What you NEVER do

- Never treat the device clock as the ordering authority: devices lose time across power cycles, drift without NTP, and reconnect with a clock hours off
- Never ship one shared credential across a fleet — a single compromised device then compromises all of them, and nothing can be revoked without bricking the rest
- Never let a device-supplied string create an unbounded series: a tag per device is fine, a tag per free-text field is a cardinality explosion
- Never assume a command was received because it was sent
- Never design an upgrade, migration or schema change that requires the whole fleet to be online at once
- Never size ingestion on the average rate: a fleet reconnecting after an outage delivers hours of buffered traffic in minutes
- Do NOT use these rules for broker mechanics (`references/kafka.md`) or socket lifecycle (`references/ws.md`)

### En un coup d'oeil

- Deux horloges, toujours
- Connectivité intermittente comme cas nominal, pas comme incident
- Identité par device, révocable
- Cardinalité bornée
- Schéma additif à vie, flotte jamais toute en ligne
- Commande acquittée ou inconnue

---

## Pourquoi

### 1. Les deux horloges

Un device perd l'heure à chaque coupure d'alimentation si son RTC n'est pas sauvegardé, dérive sans NTP, et peut se reconnecter avec une horloge fausse de plusieurs heures. Un serveur, lui, ne sait qu'une chose de façon fiable : **quand le message est arrivé**.

Ordonner par horodatage serveur est faux : un device qui a bufferisé trois jours livre d'un coup des événements anciens, qui apparaîtraient comme les plus récents. Ordonner par horloge device seule est invérifiable : rien ne distingue un capteur en avance d'un capteur mal réglé.

D'où la règle : porter les deux. L'horodatage device répond « quand est-ce arrivé », l'horodatage serveur répond « depuis quand le sait-on ». Ce sont deux questions différentes, et une supervision a besoin des deux — l'écart entre elles **est** le signal de santé de la flotte.

### 2. La connectivité intermittente est le cas nominal

Un device n'est pas un service : il est hors ligne par conception (batterie, couverture, veille). Il accumule et déverse.

Conséquences sur l'ingestion : les fenêtres d'agrégation doivent tolérer l'arrivée tardive, l'ordre d'arrivée n'a aucune valeur sémantique, et le dimensionnement ne se fait **pas** sur le débit moyen. Après une coupure réseau régionale, une flotte entière se reconnecte et livre des heures de tampon en quelques minutes — c'est le pic qui dimensionne, et il est corrélé, donc il arrive en une fois.

### 3. La cardinalité, pas le volume

Les bases temporelles ne meurent presque jamais du nombre de points ; elles meurent du nombre de **séries distinctes**. Une série se crée par combinaison de tags.

Un tag `device_id` sur 100 000 devices : 100 000 séries, tenable. Ajouter un tag alimenté par une chaîne libre remontée par le device — version de firmware mal formatée, nom de site saisi à la main, code d'erreur non normalisé — et le produit cartésien explose sans que personne ne l'ait décidé.

La règle opérationnelle : ce qui vient du device ne devient jamais un tag sans passer par une énumération fermée côté serveur.

### 4. Identité et révocation

Un secret partagé sur une flotte n'a pas de politique de révocation possible : le retirer coupe tous les devices, le garder après compromission laisse tout ouvert. Et contrairement à un serveur, un device est **physiquement accessible** — on peut le démonter, lire sa mémoire, extraire sa clé.

Donc : un identifiant et un secret par device, une rotation pensée avant expédition (un device en production pendant dix ans verra expirer ses certificats), et une révocation unitaire qui n'affecte pas ses voisins.

### 5. Idempotence et rejeu

Un device qui n'a pas reçu d'acquittement rejoue. C'est du fonctionnement normal, pas un incident — même logique qu'`at-least-once` côté broker, mais l'émetteur est ici hors de ton contrôle et n'a souvent aucune mémoire de ce qui a été confirmé.

La clé de déduplication naturelle est `(device id, horodatage device)`, éventuellement plus un compteur de séquence embarqué si le device en fournit un.

### 6. La flotte n'est jamais toute en ligne

C'est la différence la plus structurante avec un backend : on ne « déploie » pas une flotte. À tout instant, une partie des devices est hors ligne, une autre tourne sur une version vieille de deux ans, une autre ne sera jamais mise à jour.

Donc tout changement de schéma est **additif, définitivement**. Il n'existe pas de fenêtre où l'on pourrait retirer un champ : les messages de l'ancien format continueront d'arriver. C'est la contrainte de compatibilité d'`references/kafka.md`, mais sans date de fin.

### 7. Les commandes descendantes

Envoyer une commande n'est pas la délivrer. Un device peut être hors ligne, l'avoir reçue sans l'exécuter, ou l'exécuter sans que l'acquittement remonte.

Donc une commande porte un identifiant, attend un acquittement, et **expire**. Sans expiration, une commande envoyée à un device éteint pendant un mois s'exécute à son réveil — dans un contexte qui n'a plus rien à voir avec celui où elle a été émise.

## Sources

- [OASIS — MQTT 5.0](https://docs.oasis-open.org/mqtt/mqtt/v5.0/mqtt-v5.0.html)
- [OWASP — Internet of Things project](https://owasp.org/www-project-internet-of-things/)
- [RFC 3339 — Date and Time on the Internet](https://www.rfc-editor.org/rfc/rfc3339.html)
- [InfluxDB — Resolve high series cardinality](https://docs.influxdata.com/influxdb/latest/write-data/best-practices/resolve-high-cardinality/)
