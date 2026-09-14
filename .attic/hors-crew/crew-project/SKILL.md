---
name: crew-project
description: "Use when: (1) starting work on a project this library has no profile for, (2) the domain, stack or house conventions of a project must be recorded, (3) checking whether an existing profile still matches the library, (4) a crew skill reported that no project profile was supplied."
---

## OPTIONS

- **Create** — build a profile for a project that has none. Default.
- **Update** — record a convention discovered while working.
- **Validate** — check an existing profile against the current library.

## BEHAVIOR

### What you MUST do

- Write the profile **outside this library and outside the client repository**, default `~/.crew/projects/<project>.md`, or a path the operator gives instead
- Start from `templates/project-profile.md` and fill it by asking one question at a time
- Ask the **domain** first: it is the only thing no detection can infer, and it is why this profile exists
- Fill the house-conventions tables from the project's actual code — read it — rather than from what the operator remembers
- Leave a row empty rather than guessing: an empty row reads as unknown, a wrong row reads as decided
- On **Validate**, report three things: references cited that no longer exist in the library, personas cited that no longer exist, and library references whose domain or stack the profile never declared
- Tell the operator where the profile ended up, and that it is the **first** file to paste when working without a harness

### What you NEVER do

- Never write a profile, or any part of one, inside this library — not in `references/`, not in `docs/`, nowhere. That is the rule this skill exists to enforce
- Never put universal knowledge in a profile: if a rule would still be true at the next project of the same domain or stack, it belongs in a library reference, not here
- Never invent a house convention the code does not show
- Never commit a filled profile
- Do NOT use this skill to write application code (`crew-dev`) or to record an architectural decision (`crew-architecture`)

## SUPPORTING FILES

### Templates

Read `templates/project-profile.md` before creating or updating a profile.

## OUTPUT

**Structure:** one Markdown profile at the operator-supplied path, following the template — domain, stack, house conventions, assumed deviations. Plus a one-line statement of where it was written.

On Validate: a short findings list, or an explicit "profile matches the library" when there is nothing to report.

**Tone:** direct, factual, no filler.

## ACTIVATION - DEACTIVATION - HANDOFF

**`[CREW-PROJECT]`** — Display this immediately.

**Applies to this response only. Auto-resets after.**

**Handoff:** the profile path goes to `crew-dev`, whose Step 0 reads it.
