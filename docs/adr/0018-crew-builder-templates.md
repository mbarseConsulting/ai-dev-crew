# 0018 — `crew-builder`: files are created from templates, rules enter through watch

**Status:** accepted — 2026-09-14. Amends [ADR 0017](./0017-crew-maintenance-out-of-crew.md): the skill it introduced as `crew-maintenance` is renamed and gains a creation verb.

## Context

Adding a techno to `crew` was a hand job: copy a neighbour, adjust, remember the detection row, the manifest, the watch feeds. The doctor caught the structural misses after the fact, but nothing made creation deterministic, and nothing separated "the file exists and is wired" from "the file says true things". The knowledge files had also drifted into three shapes — rules only, rules plus an essay, an empty stub — until a single template was settled today.

## Decision

1. **`crew-maintenance` becomes `crew-builder`.** Same exception to "a skill names no other skill", same home, never copied to a client. Three verbs: `-n` creates, `-d` repairs, `-w` watches.
2. **Three templates live as files** in `crew-builder/references/`: `tpl-knowledge.md` (technos, `bp-`, `dom-`), `tpl-proc.md`, `tpl-agent.md`. `docs/doctrine.md` points to them and no longer carries them.
3. **`-n <kind> <name>` is a fixed procedure** (`proc-new.md`): name check, template copy, wiring where the file loads, manifest and sources rows, doctor. It writes no rule.
4. **Rules enter only through `-w`**, each with a cited source. `-w` launches one `sonnet` subagent per target, briefed with the target file and its feeds. A new file is populated by `-w --scoped <name>`.

## Consequences

- Creation and content are two passes. A wrong rule is always traceable to a watch run and its source; a structural miss is always caught by the doctor before the file is used.
- The doctor's exception (check 5) names `crew-builder`. The manifest lists the builder's own references, including the templates.
- ADR 0017's reasoning stands unchanged; only the name and the verb list move.

## Alternatives considered and rejected

- **Templates inside the doctrine as markdown blocks** (the state before this ADR): readable, but not copyable by a procedure, and two sources of truth once a file is created from memory.
- **A shell script generator**: deterministic, but the wiring step needs a judgement (which context loads this file), which a script cannot ask.
