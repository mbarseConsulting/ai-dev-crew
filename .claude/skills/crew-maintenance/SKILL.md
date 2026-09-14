---
name: crew-maintenance
description: "Use when: (1) maintaining the crew skill in its library repository, (2) checking that crew's rules are still true against release notes and standards, (3) crew-doctor reports a structural error to repair. Not for client work."
argument-hint: "[-d | -w [--scoped <target>]]"
---

## WHAT THIS IS

The maintenance kit of the `crew` skill. It exists only for the person who maintains `crew`, in the library's repository.

**Not standalone — the one exception to "a skill names no other skill".** It reads and edits `crew`'s files through `../crew/`, and is useless without them. It is never copied to a client site: the watch and its sources stay home ([ADR 0017](../../../docs/adr/0017-crew-maintenance-out-of-crew.md)).

## OPTIONS

| Flag | Does |
| --- | --- |
| `-d` / `--doctor` — default | runs the structural check and repairs what it reports |
| `-w` / `--watch` | tech-watch pass on `crew`'s rules — reads `references/proc-watch.md` and `references/sources.md` |

## BEHAVIOR

### What you MUST do

- Resolve `../crew/` against the directory holding this `SKILL.md`. No `../crew/SKILL.md` there → say so and stop
- Read `docs/doctrine.md` at the repository root before changing anything: it is the one source for where a file goes and how it is named
- **`-d`:** run `scripts/crew-doctor.sh` from the repository root. For each `✗`, repair the layout — a path, a name, a list entry, a manifest count — then run it again, until it passes or only content decisions remain
- **`-w`:** follow `references/proc-watch.md` step by step
- Say which mode ran, in the first line of the output

### What you NEVER do

- Never change what a rule says under `-d`: the doctor repairs structure; a wrong rule goes through `-w` and its cited PR
- Never weaken a check in `scripts/crew-doctor.sh` to make it pass
- Never run at a client site, and never touch a project file

## OUTPUT

**`-d`:** the doctor's first output, each repair with its file, the final output — or what remains and why it needs a decision.
**`-w`:** defined by `references/proc-watch.md`.

**Tone:** factual, evidence-first.

## ACTIVATION - DEACTIVATION - HANDOFF

**`[CREW-MAINTENANCE]`** — Display this immediately.

**Applies to this response only. Auto-resets after.**
