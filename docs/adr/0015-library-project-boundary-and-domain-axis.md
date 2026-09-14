# 0015 — Nothing project-specific lives in the library; the domain is declared, not detected

**Status:** accepted — 2026-09-14. Amends [ADR 0013](./0013-craft-skill-taxonomy.md) (adds a third reference axis) and [ADR 0014](./0014-activity-first-skill-agent-pattern.md) (adds Step 0).

## Context

Two facts arrived together.

**The library is permanent; a project is disposable.** The operator carries this library from job to job, for life. `house-rules.md` — the employer's own class names and package layout — was nonetheless stored inside it, at `crew-dev/references/house-rules.md`. Gitignored, but present in the tree: copy the library to another machine or another job and either the previous employer's internals travel along, or they are silently lost. The `.gitignore` entry treated a structural error as a publication problem.

**Some knowledge is neither technological nor structural.** Working on IoT surfaced rules that belong to none of ADR 0013's three families: carry both the device timestamp and the server receipt timestamp; treat intermittent connectivity as nominal traffic; bound the cardinality a device may create; never ship one credential across a fleet. These are not Java rules, not layering rules, not Kafka rules. They are **domain** rules, and they are entirely universal — they will follow the operator to the next IoT project, and they are publishable.

The temptation was to put the domain in the project file. That would bury reusable, veille-able knowledge in a disposable per-project artifact and lose it at the next project — the same mistake as storing house rules in the library, mirrored.

## Decision

**1. The library contains only what travels with its owner for life.** Universal rules, their reasoning, their sources. No project profile, no employer conventions, no client names. Anything project-scoped lives in the operator's own space, outside this repository and outside the client's, and is **pointed at**, never contained.

**2. A third reference axis: the business domain.** ADR 0013's placement rule extends cleanly:

> A rule belongs to the **domain** axis if it disappears when the domain changes.

"A consumer must be idempotent" survives a change of domain → `kafka.md`. "Always carry both the device clock and the server clock" does not → `iot.md`.

**3. Technology is detected; the domain is declared.** `*.java` → `agent-java` is an observable fact. Nothing in a repository states that a project is IoT. No detection table can infer it.

This asymmetry is the reason a project profile must exist at all — not tooling convenience. It is the only place the domain can be declared, and the only place this project's own names can be recorded.

**4. `crew-dev` gains Step 0:** read the project profile if one was supplied; absent, work from the universal references only and **say so**, rather than assuming defaults.

**5. No generator, for now.** `crew-project/templates/project-profile.md` is committed; instances are not. A profile is created a couple of times a year, and a template copied by hand delivers nearly all of the value. The one real argument for tooling — a profile may cite a reference that no longer exists — is a **validation** concern, answered by extending the existing structural routing check, not by generating files. This follows the deferred-enforcement precedent of [ADR 0006](./0006-deferred-hooks-and-worktrees.md) and [ADR 0009](./0009-model-routing.md): behavioural rule first, tooling only once it leaks.

## Alternatives considered

- **Keep `house-rules.md` in the library, rely on `.gitignore`.** Rejected: `.gitignore` governs publication, not portability. The file was still in the tree that gets copied, and the failure it causes — carrying or losing an employer's internals on a machine change — happens with or without git.
- **Put the domain in the project profile.** Rejected: it would move universal, publishable, veille-able knowledge into a disposable artifact, and lose it at the next project of the same domain.
- **Build a `/crew-project` generator now.** Deferred, not rejected. See decision 5.

## Consequences

- `crew-dev/references/house-rules.md` is removed. `docs/templates/house-rules.template.md` is replaced by `crew-project/templates/project-profile.md`, which additionally declares the domain and the stack.
- `.gitignore` keeps a guard against reintroduction, now stated as a portability rule rather than a leak rule.
- `crew-dev` carries an explicit NEVER: nothing project- or employer-specific is stored in this library.
- `references/iot.md` is the first domain reference. It is maintained by `crew-watch` like any other, and its sources join `crew-watch/references/sources.md`.
- A profile is the **first** file to paste in paste mode, before `crew-dev/SKILL.md` — it is what makes the domain known.
- The domain row in the detection table is the only one keyed on a declaration rather than an observation. That distinction is stated in the table itself, so a future reader does not try to make it detectable.
