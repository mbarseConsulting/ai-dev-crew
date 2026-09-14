---
name: node-bff-craft
description: "Use when: (1) writing or modifying a Node.js Backend-For-Frontend, (2) aggregating or reshaping several backend calls for one front-end screen, (3) deciding what a BFF may cache, hold, or decide on its own, (4) handling errors, timeouts, or secrets in a BFF."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

> **À PEUPLER** — squelette seul ; la passe de peuplement reste à faire.

### What you MUST do

- Keep the BFF a composition layer: it aggregates, reshapes and protects — business rules stay in the backend that owns them
- Give every outbound call an explicit timeout, and degrade the response deliberately when one dependency fails
- Keep secrets and tokens on the BFF side; the browser never receives what it does not need

### What you NEVER do

- Never duplicate a business rule already owned by a backend service — a rule in two places is a rule waiting to diverge
- Never forward an upstream error verbatim to the browser, internal details included
- Do NOT apply this skill to Angular-side code (`angular-craft`) nor to the exposed contract's shape (`api-rest-craft`)

<!-- Customization hook — framework HTTP retenu, conventions de logging/tracing, gestion des secrets : references/house-rules.md -->

## FOCUS

- Rôle du BFF : agrégation, reshaping, protection — pas de métier
- Timeouts, résilience, dégradation contrôlée
- Secrets, tokens, ce qui ne descend jamais au navigateur
- Frontière avec le backend propriétaire de la règle

## OUTPUT

Routes, agrégateurs et clients HTTP conformes, ou en mode revue une liste courte d'écarts.
