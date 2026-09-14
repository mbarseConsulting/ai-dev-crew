---
name: crew-project
description: "Use when: (1) working in a codebase whose domain, stack or house conventions are not obvious from its files, (2) starting on a project that has no entry here yet, (3) recording a convention discovered while working, (4) a session needs to know where it is before doing anything else."
---

## OPTIONS

- **Route** — identify the current project from the working directory and load it. Default.
- **Create** — register a project that has no entry yet.
- **Update** — record a convention or a decision discovered while working.

## BEHAVIOR

This file is a generic router. It holds no project data: every project is a directory beside it, and `index.md` maps a filesystem path to one of them.

### What you MUST do

**Route (default)**

1. Read `index.md`. Match the current working directory against its registered paths, longest prefix first.
2. No match → say so plainly, name Create as the way to register it, and stop. Never guess which project this is from directory names.
3. Match → load, in this order:
   - `<project>/core/domain.md` — the business domain, which no file inspection can infer
   - `<project>/core/stack.md` — technologies and their roles
   - `<project>/index.md` → the current snapshot number
   - `<project>/snapshots/{current}/conventions.md` — the house names and retained choices as of now
4. State which project was loaded and from which snapshot, before anything else happens in the session.

**Create**

1. Ask the **domain first** — it is the one thing no detection can infer, and the reason this skill exists.
2. Then the stack, then the conventions, from `templates/project.md`, one question at a time.
3. Fill the convention tables from the project's actual code — read it — not from memory.
4. Leave a row empty rather than guessing: empty reads as unknown, wrong reads as decided.
5. Register the path in `index.md` and open snapshot `001`.

**Update**

Write into a **new** snapshot rather than editing the current one when a convention changes; edit in place only when correcting a mistake. A snapshot is what makes it possible to know when a rule changed, and why.

### What you NEVER do

- Never put universal knowledge in a project: if a rule would still be true at the next project of the same domain or stack, it does not belong here
- Never invent a convention the code does not show
- Never commit a project directory or `index.md` — they carry an employer's internal names and paths
- Never edit an old snapshot to make history look consistent
- Never name or load another skill: a session loads what it needs, this one only says where it is

## SUPPORTING FILES

```
crew-project/
  SKILL.md            this router — permanent, no data
  index.md            path → project registry — never committed
  templates/
    project.md        creation template — permanent
  <project>/          never committed, deletable without breaking anything
    core/             domain.md · stack.md — what the project IS
    index.md          current snapshot
    snapshots/{NNN}/  conventions.md — what it BECAME
```

The router and the template are permanent and follow their owner. Project directories are disposable: leaving a job means deleting them, and everything else still works.

## OUTPUT

**Route:** one line naming the project and its snapshot, then the loaded content. Or an explicit "no project registered for this path".

**Create / Update:** the files written, and their paths.

**Tone:** factual, no filler.

## ACTIVATION - DEACTIVATION - HANDOFF

**`[CREW-PROJECT]`** — Display this immediately.

**Applies to this response only. Auto-resets after.**
