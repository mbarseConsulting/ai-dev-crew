# new — add a file to crew without guessing

> Run by: `SKILL.md` under `-n <kind> <name>`. Kinds: `techno`, `bp`, `dom`, `proc`, `agent`.

## Steps

1. **Check the name.** Kebab-case, letters and digits only. A `techno` is named after the framework, not the language (`spring`, not `java`), and has no hyphen — a hyphen means a sub-topic of an existing techno. The target path must not exist yet.
2. **Copy the template** to its home, every placeholder replaced or the line removed, nothing added from memory:

   | Kind | Template | Home |
   | --- | --- | --- |
   | `techno` | `references/tpl-knowledge.md` | `../crew/technos/<name>.md` |
   | `bp` | `references/tpl-knowledge.md` | `../crew/references/bp-<name>.md` |
   | `dom` | `references/tpl-knowledge.md` | `../crew/references/dom-<name>.md` |
   | `proc` | `references/tpl-proc.md` | `../crew/references/proc-<name>.md` |
   | `agent` | `references/tpl-agent.md` | `../crew/agents/agent-<name>.md` |

3. **Wire it where it loads** — the doctor fails otherwise:
   - `techno`: a detection row in `../crew/SKILL.md`'s table — ask the user for the file pattern and the nearest build file if the brief does not give them
   - `bp` / `dom`: a row in `../crew/SKILL.md`'s shared table, with the context that loads it
   - `proc`: a `references/proc-<name>.md` mention in the agent that runs it, and in `../crew/SKILL.md`'s agent-owned list
   - `agent`: a flag row in `../crew/SKILL.md`'s options table, and a launchable shell in `.claude/agents/agent-<name>.md` when it needs a fresh context or a tool restriction
4. **Declare it:** a row in `docs/skill-manifest.csv`; for a `techno`, `bp` or `dom`, a section in `references/sources.md` with at least one feed, or a line under "No declared feed" saying why.
5. **Run `scripts/crew-doctor.sh`** from the repository root. Repair until it passes.
6. **Populate the rules** through `-w --scoped <name>`: every rule enters with a cited source, never from memory.

## NEVER

- Never create a file without its template
- Never skip step 3 — a file nothing loads is dead
- Never write rules under `-n` — creation and content are two separate passes, so a wrong rule can always be traced to its source

## Output

Every file created or edited, with its path, then the doctor's final line.
