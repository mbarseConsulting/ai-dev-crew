# ai-dev-crew — doctrine

## One rule, one file

Specific to a framework → `technos/<framework>.md`, named after the framework, not the language
(`spring`, not `java`). True everywhere → `references/bp-<topic>.md`. Gone when the domain
changes → `references/dom-<domain>.md`. A role's procedure → `references/proc-<procedure>.md`.
A role → `agents/agent-<role>.md`.

A file grows as much as it needs. When it becomes unreadable, it splits by sub-topic:
`technos/<framework>-<topic>.md`, listed in `technos/<framework>.md`, loaded by context.

## A skill names no other skill

One exception: `crew-builder` names `crew`, which it maintains. Composing two skills is an
agent's job: every shell in `.claude/agents/` preloads `crew` and `crew-project`.

## Three templates, in English

A techno and a `bp-` differ by folder, not by form. Every new file starts from its template
in `crew-builder/references/`, through `crew-builder -n`:

| Template | For |
| --- | --- |
| `tpl-knowledge.md` | `technos/*.md`, `references/bp-*.md`, `references/dom-*.md` — one `MUST` list, one `NEVER` list, each rule with its why as a trailing clause |
| `tpl-proc.md` | `references/proc-*.md` — numbered steps |
| `tpl-agent.md` | `agents/agent-*.md` — one intention, a few steps, the other roles' verbs as NEVER |

The why is a clause after the rule, never a section. A rule without its why is incomplete;
a why that adds a rule is misplaced. A rule enters a file only through `crew-builder -w`,
with its source.
