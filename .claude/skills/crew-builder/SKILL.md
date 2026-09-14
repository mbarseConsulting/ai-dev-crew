---
name: crew-builder
description: "Use when: (1) adding a techno, a reference, a procedure or a role to the crew skill, (2) checking that crew's rules are still true against release notes and standards, (3) crew-doctor reports a structural error to repair. Not for client work."
argument-hint: "[-n <techno|bp|dom|proc|agent> <name> | -d | -w [--scoped <target>]]"
---

## WHAT THIS IS

The builder of the `crew` skill: it creates its files from templates, repairs its structure, and keeps its rules current. It exists only for the person who maintains `crew`, in the library's repository.

**Not standalone — the one exception to "a skill names no other skill".** It reads and edits `crew`'s files through `../crew/`, and is useless without them. It is never copied to a client site.

## OPTIONS

| Flag | Does |
| --- | --- |
| `-n` / `--new <kind> <name>` | creates a `techno`, `bp`, `dom`, `proc` or `agent` from its template and wires it — `references/proc-new.md` |
| `-d` / `--doctor` — default | runs the structural check and repairs what it reports |
| `-w` / `--watch [--scoped <target>]` | tech-watch pass on `crew`'s rules — `references/proc-watch.md` |

## BEHAVIOR

### What you MUST do

- Resolve `../crew/` against the directory holding this `SKILL.md`. No `../crew/SKILL.md` there → say so and stop
- Read `docs/doctrine.md` at the repository root before changing anything: it says where a file goes and which template it follows
- **`-n`:** follow `references/proc-new.md` step by step; it ends with a passing doctor
- **`-d`:** run `scripts/crew-doctor.sh` from the repository root. For each `✗`, repair the layout — a path, a name, a list entry, a manifest count — then run it again, until it passes or only content decisions remain
- **`-w`:** follow `references/proc-watch.md` step by step
- Say which mode ran, in the first line of the output

### What you NEVER do

- Never write a crew file from memory — every new file starts from its template in `references/tpl-*.md`
- Never change what a rule says under `-d` or `-n`: a rule changes only through `-w` and its cited source
- Never weaken a check in `scripts/crew-doctor.sh` to make it pass
- Never run at a client site, and never touch a project file

## SUPPORTING FILES

```
crew-builder/
  SKILL.md
  references/
    tpl-knowledge.md   template for technos/*.md, references/bp-*.md, references/dom-*.md
    tpl-proc.md        template for references/proc-*.md
    tpl-agent.md       template for agents/agent-*.md
    proc-new.md        how -n creates and wires a file
    proc-watch.md      how -w keeps rules current
    sources.md         the feeds -w reads, per target
```

## OUTPUT

**`-n`:** every file created or edited, with its path, and the doctor's final line.
**`-d`:** the doctor's first output, each repair with its file, the final output — or what remains and why it needs a decision.
**`-w`:** defined by `references/proc-watch.md`.

**Tone:** factual, evidence-first.

## ACTIVATION - DEACTIVATION - HANDOFF

**`[CREW-BUILDER]`** — Display this immediately.

**Applies to this response only. Auto-resets after.**
