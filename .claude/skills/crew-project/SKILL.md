---
name: crew-project
description: "Use when: (1) working in a codebase whose domain, stack or house conventions are not obvious from its files, (2) starting on a project that has no entry here yet, (3) recording a convention discovered while working."
argument-hint: "[create | update <convention>]"
---

## OPTIONS

- **Route** — no argument. Identify the current project from the working directory and load it.
- **`create`** — register a project that has no entry yet.
- **`update <convention>`** — record a convention discovered while working.

## BEHAVIOR

A generic router holding no project data. `index.md` maps a filesystem path to a project file beside it:

```markdown
| Path | Project |
| --- | --- |
| /absolute/path/to/repository | acme-fleet |
```

The row above loads `acme-fleet.md`, next to `index.md`.

### What you MUST do

- **Route:** read `index.md`, match the working directory against its paths (longest prefix first), load `<project>.md`, and say which project was loaded before anything else happens
- No match, or no `index.md` → say so, name `create`, stop. Never guess the project from a directory name
- **Create:** ask the **domain first** — it is the one thing no file inspection can infer, and the reason this skill exists. Then the stack, then the conventions, from `references/project-template.md`
- Fill the convention rows by **reading the project's code**, not from memory
- Leave a row empty rather than guessing: empty reads as unknown, wrong reads as decided
- Fill `Références de domaine` with reference file names without extension (`iot`), or leave it empty
- **Create** ends by writing `<project>.md` (kebab-case name) and adding its row to `index.md` — creating `index.md` with the header above if it does not exist. A Route from that directory must then succeed
- **Update:** edit the project file in place

### What you NEVER do

- Never put universal knowledge in a project file: if a rule would still be true at the next project of the same domain or stack, it does not belong here
- Never invent a convention the code does not show
- Never commit a project file or `index.md` — they carry an employer's internal names and paths
- Never name or load another skill: this one only says where you are

## SUPPORTING FILES

```
crew-project/
  SKILL.md            this router — permanent
  index.md            path → project — never committed
  references/project-template.md  — permanent
  <project>.md        one file per project — never committed, deletable
```

The router and the template follow their owner for life. Project files are disposable: leaving a job means deleting them, and nothing else breaks.

## OUTPUT

**Route:** one line naming the project, then its content. Or an explicit "no project registered for this path".
**Create:** the project file and `index.md`, each with its path.
**Update:** the file written and its path.

**Tone:** factual, no filler.

## ACTIVATION - DEACTIVATION - HANDOFF

**`[CREW-PROJECT]`** — Display this immediately.

**Applies to this response only. Auto-resets after.**
