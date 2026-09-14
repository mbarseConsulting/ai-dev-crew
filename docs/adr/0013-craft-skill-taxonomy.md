# 0013 — Craft skills are indexed by subject, on two axes, with origin split inside

**Status:** accepted — 2026-09-14.

## Context

Craft skills were indexed on a single axis: one skill per language or framework (`java-craft`, `angular-craft`, `python-craft`). Two pressures broke that axis.

**Cross-cutting concerns had nowhere to go.** REST contracts, Kafka topics, WebSocket envelopes and the entity/DTO/mapper discipline all span several technologies at once — they apply to the Java backend *and* the Node BFF. Filing them under `java-craft` would duplicate them into every other language skill, which is precisely the failure mode [ADR 0008](./0008-skills-first-doctrine.md) forbids: *"two copies of a rule are a single source of truth waiting to disagree with itself."* A live instance already exists — `angular-craft` restates `test-craft`'s tier-routing rules almost verbatim.

**Rules have two different origins, and they are maintained differently.** A shared audited base class carries genuinely universal content — a `@MappedSuperclass` that is not an `@Entity`, declarative auditing, an `equals`/`hashCode` that survives the transient → persisted transition. It also carries content true only at one employer: the class's name, its package, whether its id is a sequence or a UUID. Mixed into one file, the universal part cannot be maintained by veille and the house part cannot be kept out of a public remote.

A third pressure comes from [ADR 0012](./0012-claude-library-over-marketplace.md): in paste mode, a file that does not fit a paste window is unusable, whatever its logical coherence.

## Decision

**The loading axis is the subject; the origin axis lives one level down.** Work arrives as a subject ("I am touching the REST API"), so that is what selects a skill. Origin is a maintenance concern, so it belongs inside the skill:

```
.claude/skills/<subject>-craft/
├── SKILL.md                        short, opposable MUST/NEVER; fits a paste window
└── references/
    ├── best-practices.md           the pattern and its reason — publishable
    └── house-rules.md              names and choices here — gitignored
```

**Four families of subject:**

| Family | Skills |
| --- | --- |
| Procedure | `dev-loop` · `testfix` · `test-craft` · `code-quality` · `security-review` · `dev-conventions` · `architecture` |
| Language / framework | `java-craft` · `angular-craft` · `node-bff-craft` · `python-craft` |
| Structure | `layering-craft` · `persistence-craft` |
| Contracts | `api-rest-craft` · `kafka-craft` · `ws-craft` |

Structure and Contracts are **transverse to language** by construction; that is why they cannot live inside `java-craft`.

**Two distinct rules decide placement and size.** They answer different questions and must not be conflated:

1. **Placement** — *a rule belongs to the axis that stays true if you change technology.* Constructor injection is meaningless outside Spring → `java-craft`. "A controller never returns the persisted object" holds in Node too → `layering-craft`. "No trailing period in an OpenAPI summary" holds on both sides → `api-rest-craft`. Hesitating between two homes means the rule is badly phrased, not that the taxonomy lacks a slot.
2. **Granularity** — *one file is what fits a paste window and loads together.* This is what separates `persistence-craft` from `java-craft`, which rule 1 alone would merge: today, in this stack, persistence is Java/JPA. But a `java-craft` covering language, Spring, JPA and identity pitfalls would not fit a paste window, and an over-thin `java-craft` is the symmetric failure.

**The two reference files carry different contracts:** `best-practices.md` answers *what and why*, `house-rules.md` answers *with what here*. Only the first is committed; the second is gitignored, with `docs/templates/house-rules.template.md` as the committed skeleton.

## Alternatives considered

- **Keep a single language axis and accept duplication.** Rejected on the evidence: the `angular-craft`/`test-craft` overlap already shows the drift starting, and ADR 0008 rejects duplication as a safety net.
- **Split craft skills by origin at the top level** (a universal tree and a house tree). Rejected: it doubles the number of directories a reader must consult for one subject, and the loading decision — which is by subject — would have to consult both.
- **One `best-practices.md` per family instead of per skill.** Rejected: ADR 0010 (reserved: watch → craft maintenance loop) will maintain these files by periodic veille, which is per-technology work; a shared file would have no single owner and no coherent update cadence.

## Consequences

- Six skills are added: `layering-craft`, `persistence-craft`, `api-rest-craft`, `kafka-craft`, `ws-craft`, and `node-bff-craft` — the last closing a documented gap, the Node BFF having been excluded by both `angular-craft` and `java-craft` while `dev-loop` forbids working in a technology with no matching craft skill.
- `persistence-craft` is populated as the reference for the format, and `java-craft` — previously four generic MUST lines — is brought to the same depth. All six are populated, `layering-craft` and `api-rest-craft` — the two bricks that motivated the transverse axes — first. One gap remains and is recorded rather than hidden: `angular-craft` carries a rich `SKILL.md` but an empty `references/best-practices.md`, the only craft skill without a fonds.
- `house-rules.md` being gitignored is a security requirement, not tidiness: those files name an employer's internal classes and package layout.
- The `angular-craft` / `test-craft` duplication is repaired: `test-craft` owns the tier criterion, stated generically, and `angular-craft` keeps only its Angular expression (file suffixes, tooling, artifact list). Repairing it surfaced a leak in the opposite direction — `test-craft`, nominally technology-agnostic, enumerated Angular/NgRx artifacts (guards, pipes, interceptors, reducers, effects) that no Java or Kafka work could use. A third copy of the disabled-suite rule was found in `angular-craft` and removed.
- `python-craft` is parked — retained, not maintained, since the current stack does not use it.
