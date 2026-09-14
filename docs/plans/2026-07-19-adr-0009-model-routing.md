# ADR 0009 Model Routing Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ratify and implement the model-routing doctrine from `docs/design/2026-07-18-routing-watch-selfimprove-design.md` Part 1: ADR 0009, SPEC routing section, butler dispatch rules.

**Architecture:** Documentation-and-doctrine change only — no executable code. Three artifacts: the ADR (decision record), a new SPEC section (authoritative doctrine), and the butler agent file (runtime behavior, self-contained because the plugin ships to client projects without this repo). Per SPEC §7, ADR + SPEC land before the plugin file.

**Tech Stack:** Markdown only. Repo: `/Users/maelledalmeris/Projets/apps/ai-dev-crew`.

## Global Constraints

- All artifacts in English (operator's standing rule).
- The routing table appears in SPEC §8 (authoritative) and in the butler agent file (runtime copy). The two MUST stay word-for-word aligned on model names: exploration → Haiku, `agent-crew-dev` → Sonnet, `agent-crew-tester` → Sonnet, `agent-crew-critic` → strong model (Opus-class), butler → session model.
- Override key name is exactly `model-routing` (a section in the client project's `CLAUDE.md`).
- Repo is on `main` with unrelated untracked files (`docs/`, `CHANGELOG.md`, `.claude-plugin/`). Work on a branch; `git add` only the exact paths named in each task — never `git add .` or `git add docs/`.
- Do not renumber existing SPEC sections; the routing section is appended as §8.

---

### Task 1: Branch + ADR 0009

**Files:**
- Create: `docs/adr/0009-model-routing.md`

**Interfaces:**
- Produces: the decision record that SPEC §8 (Task 2) and the butler file (Task 3) cite as "ADR 0009". Model names and the `model-routing` override key defined here are reused verbatim by both.

- [ ] **Step 1: Create the working branch**

```bash
cd /Users/maelledalmeris/Projets/apps/ai-dev-crew
git checkout -b feat/adr-0009-model-routing
```

Expected: `Switched to a new branch 'feat/adr-0009-model-routing'`

- [ ] **Step 2: Write the ADR**

Create `docs/adr/0009-model-routing.md` with exactly this content:

```markdown
# ADR 0009 — Model routing per role

**Status:** accepted — 2026-07-19

## Context

The SPEC had no cost doctrine. The operator runs the crew primarily on a personal subscription (~€20/month); industry evidence puts per-step model routing at 30–50% cost reduction with equal or better output, and a three-tier routing at ~51% versus uniform strong-model deployment. Two additional facts shape the mechanism: (1) `model:` frontmatter is ignored on named agent spawns, so routing cannot be delegated to agent files; (2) the butler is the single dispatch point for every crew agent (ADR 0007), so dispatch-time routing has exactly one home.

## Decision

1. **Default routing table** (crew defaults, not absolutes):
   - `agent-crew-butler`: session model (main-session persona, never dispatched — inherits).
   - Code exploration / navigation fan-out: Haiku.
   - `agent-crew-dev`: Sonnet.
   - `agent-crew-tester`: Sonnet.
   - `agent-crew-critic` (both lenses): strong model (Opus-class) — gate verdicts cascade downstream; a false "pass" costs more than a strong-model dispatch.
2. **Explicit model on every dispatch.** The butler passes `model` explicitly in every `Agent` call. Frontmatter is never relied on.
3. **Advisor escalation.** When `agent-crew-dev` exhausts `dev-loop`'s bounded repair budget and reports failure (existing behavior, unchanged), the butler MAY re-dispatch the same task once on the strong model, with the failure report as context. No self-escalation by any agent: the butler pays, the butler decides.
4. **Per-project override.** A `model-routing` section in the client project's `CLAUDE.md` overrides any default. Absent section → defaults above. Model unavailable at dispatch → fall back to the session model and tell the user; never silent.
5. **Solo mode.** The table is a per-phase recommendation for humans running skills by hand; same table, same logic, human choice.

## Consequences

- SPEC gains §8 (authoritative doctrine). The butler agent file carries a runtime copy of the table because the plugin is installed in client projects that do not contain this repo; SPEC §7's spec-first change process is the guard against drift between the two.
- Enforcement is behavioral, consistent with ADR 0004: no `routing.yml`, no hooks, no consumption metering until the behavioral rule is shown to leak.
- ADR 0011 (bounded self-improvement) is only activatable once this ADR is implemented — routing is what makes a self-improvement run viable on a subscription budget.

## Alternatives considered and rejected

- **Tooled enforcement (`routing.yml` + hook):** premature optimization; build mechanical enforcement only after the routing table proves its value and the behavioral rule leaks.
- **Critic on Sonnet with advisor escalation:** saves tokens at the one point where model capability changes the verdict; rejected — the review gate is the wrong place to economize.
```

- [ ] **Step 3: Verify the ADR is complete and linked correctly**

```bash
cd /Users/maelledalmeris/Projets/apps/ai-dev-crew
grep -c "model-routing" docs/adr/0009-model-routing.md
grep -n "Status:" docs/adr/0009-model-routing.md
```

Expected: first command prints a count ≥ 2; second prints the accepted status line. No "TBD"/"TODO" anywhere in the file (`grep -in "TBD\|TODO" docs/adr/0009-model-routing.md` prints nothing).

- [ ] **Step 4: Commit**

```bash
cd /Users/maelledalmeris/Projets/apps/ai-dev-crew
git add docs/adr/0009-model-routing.md
git commit -m "docs(adr): add ADR 0009 model routing per role"
```

---

### Task 2: SPEC §8 — Model routing

**Files:**
- Modify: `docs/SPEC.md` (append new §8 after §7 "Change process"; add one bullet to §6 "Enforcement layers")

**Interfaces:**
- Consumes: ADR 0009 (Task 1) — cited by path.
- Produces: the authoritative routing table that the butler file (Task 3) mirrors.

- [ ] **Step 1: Append §8 to SPEC.md**

Add at the end of `docs/SPEC.md` (after the §7 paragraph ending "never the other way around."):

```markdown

## 8. Model routing per role

Per [ADR 0009](./adr/0009-model-routing.md), dispatch-time model choice is doctrine, not accident. Defaults (overridable per project — see below):

| Role / work | Model | Rationale |
| --- | --- | --- |
| `agent-crew-butler` | session model | Main-session persona, never dispatched — inherits |
| Code exploration / navigation fan-out | Haiku | High volume, low reasoning |
| `agent-crew-dev` | Sonnet | High-volume implementation; cost/quality sweet spot |
| `agent-crew-tester` | Sonnet | Scenario design is mid-reasoning; suite execution is tool output |
| `agent-crew-critic` (both lenses) | strong model (Opus-class) | Gate verdicts cascade; a false "pass" costs more than a strong dispatch |

The butler passes the model **explicitly in every `Agent` dispatch** — `model:` frontmatter is never relied on. When `agent-crew-dev` exhausts `dev-loop`'s bounded repair budget, the butler may re-dispatch the task once on the strong model with the failure report as context (advisor escalation); no agent self-escalates. A `model-routing` section in the client project's `CLAUDE.md` overrides any default; an unavailable model falls back to the session model, reported to the user, never silently. In solo mode the table is a per-phase recommendation — same table, human choice.

The butler agent file carries a runtime copy of this table (the plugin ships to client projects without this repo); this section is the authoritative version, and §7's spec-first process is the guard against drift.
```

- [ ] **Step 2: Add the enforcement bullet to §6**

In `docs/SPEC.md` §6 "Enforcement layers", after the bullet beginning "- **Single source of truth per rule**", insert:

```markdown
- **Model routing**: the butler passes an explicit `model` in every dispatch per the §8 table; behavioral rule, no mechanical enforcement. See [ADR 0009](./adr/0009-model-routing.md).
```

- [ ] **Step 3: Verify consistency**

```bash
cd /Users/maelledalmeris/Projets/apps/ai-dev-crew
grep -n "0009" docs/SPEC.md
grep -n "## 8. Model routing" docs/SPEC.md
```

Expected: two references to ADR 0009 (§6 bullet + §8), one §8 heading.

- [ ] **Step 4: Commit**

```bash
cd /Users/maelledalmeris/Projets/apps/ai-dev-crew
git add docs/SPEC.md
git commit -m "docs(spec): add §8 model routing doctrine (ADR 0009)"
```

---

### Task 3: Butler runtime rules

**Files:**
- Modify: `plugins/crew-core/agents/agent-crew-butler.md`

**Interfaces:**
- Consumes: model names and override key from ADR 0009 / SPEC §8 — verbatim.
- Produces: the shipped runtime behavior.

- [ ] **Step 1: Add the routing bullet to FOCUS**

In `plugins/crew-core/agents/agent-crew-butler.md`, in the `## FOCUS` list, after the line `- A light sanity pass on returned dev work, distinct from the tester's independent verification and the critic's formal review`, add:

```markdown
- Explicit model on every dispatch, per the MODEL ROUTING table below — never rely on frontmatter
```

- [ ] **Step 2: Add MUST rules**

In the `### What you MUST do` list, after the line ending "before handing off to `agent-crew-tester` and/or `agent-crew-critic`", add:

```markdown
- Pass `model` explicitly in every `Agent` dispatch, following the MODEL ROUTING table below; check the client project's `CLAUDE.md` for a `model-routing` section first and let it override the defaults
- On `agent-crew-dev` repair-budget exhaustion, you may re-dispatch the same task once on the strong model with the failure report as context — advisor escalation is your decision, never the agent's
- If a routed model is unavailable, fall back to the session model and say so to the user — never fail or substitute silently
```

- [ ] **Step 3: Add the MODEL ROUTING section**

Insert before the `## OUTPUT` section:

```markdown
## MODEL ROUTING

Defaults per [ADR 0009] (authoritative table: SPEC §8 in the ai-dev-crew repo). A `model-routing` section in the client project's `CLAUDE.md` overrides them.

| Dispatch | Model |
| --- | --- |
| Code exploration / navigation fan-out | `haiku` |
| `agent-crew-dev` | `sonnet` |
| `agent-crew-tester` | `sonnet` |
| `agent-crew-critic` (each lens) | strong model (`opus`-class) |

Escalation: one re-dispatch of a failed dev task on the strong model, with the failure report in the brief. Unavailable model → session model, reported.
```

- [ ] **Step 4: Verify consistency with SPEC**

```bash
cd /Users/maelledalmeris/Projets/apps/ai-dev-crew
grep -n "MODEL ROUTING" plugins/crew-core/agents/agent-crew-butler.md
grep -c "sonnet" plugins/crew-core/agents/agent-crew-butler.md
grep -n "model-routing" plugins/crew-core/agents/agent-crew-butler.md
```

Expected: one `## MODEL ROUTING` heading (plus references in FOCUS/MUST), `sonnet` count ≥ 2, at least two `model-routing` override mentions.

- [ ] **Step 5: Commit**

```bash
cd /Users/maelledalmeris/Projets/apps/ai-dev-crew
git add plugins/crew-core/agents/agent-crew-butler.md
git commit -m "feat(crew-core): butler explicit model routing per ADR 0009"
```

---

### Task 4: Cross-file consistency gate

**Files:**
- Read-only check across: `docs/adr/0009-model-routing.md`, `docs/SPEC.md`, `plugins/crew-core/agents/agent-crew-butler.md`

**Interfaces:**
- Consumes: all three artifacts.
- Produces: the verified, shippable branch.

- [ ] **Step 1: Verify the three files agree**

```bash
cd /Users/maelledalmeris/Projets/apps/ai-dev-crew
for f in docs/adr/0009-model-routing.md docs/SPEC.md plugins/crew-core/agents/agent-crew-butler.md; do echo "== $f"; grep -in "haiku\|sonnet\|opus\|model-routing" "$f" | head -12; done
```

Expected: every file maps exploration→Haiku, dev→Sonnet, tester→Sonnet, critic→Opus-class, and uses the key `model-routing`. Any mismatch (e.g. a file routing tester to Haiku) is a bug — fix the deviating file to match SPEC §8 before proceeding.

- [ ] **Step 2: Verify nothing unrelated is staged or committed**

```bash
cd /Users/maelledalmeris/Projets/apps/ai-dev-crew
git log --oneline main..HEAD
git diff --stat main..HEAD
```

Expected: exactly 3 commits; diff touches exactly 3 files (`docs/adr/0009-model-routing.md`, `docs/SPEC.md`, `plugins/crew-core/agents/agent-crew-butler.md`). Untracked files remain untracked.

- [ ] **Step 3: Report**

Report branch name, the 3 commits, and the consistency-check output to the user. Do not merge, do not push — the PR decision is the operator's.
