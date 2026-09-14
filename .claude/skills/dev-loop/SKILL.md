---
name: dev-loop
description: "Use when: (1) implementing a feature or change from instructions or a handed-off design, (2) needing a disciplined develop-compile-test-verify loop with a bounded repair budget, (3) proving a change works with actual command output instead of a claim."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

Execute the following steps in order. Do not start writing code before Step 1's output exists. Do not skip steps.

1. **Understand scope.** Parse the instructions (or the handed-off `docs/adr/`/`docs/design/` file). Extract: target files, expected behavior, and an acceptance checklist — concrete, verifiable, one line per criterion. Save the checklist; it's re-checked in the conformity step. If ambiguous, ask before proceeding.
2. **Identify technology and load craft skill(s) by name** — `angular-craft`, `java-craft`, `python-craft`, or whichever matches the task. A task spanning several technologies loads each matching skill for its part. Also load `dev-conventions` for commit style, versioning, and changelog entries; if it isn't installed (it ships in the separate `crew-core` plugin), flag that and fall back to the host project's own documented conventions instead of silently skipping the rule.
3. **Detect project commands.** Package manager from the lockfile (`package-lock.json` → npm, `yarn.lock` → yarn, `pnpm-lock.yaml` → pnpm, `bun.lockb` → bun). Typecheck/build, test runner, and linter from `package.json` scripts first, then config files (`tsconfig.json`, `vitest.config.*`, `jest.config.*`, `cypress.config.*`, `playwright.config.*`, `.eslintrc.*`, `eslint.config.*`, `biome.json`), `devDependencies` as a last resort. In a monorepo (Nx, Turborepo, Lerna, workspaces), scope every command to the relevant package. If a command can't be determined, skip that step and say so in the summary rather than guessing.
4. **Develop.** Follow the existing code patterns; surgical edits; respect existing imports, naming, and structure; no new dependencies unless the task explicitly requires one.
5. **Compile / typecheck.** Zero errors before moving on. Errors count against the repair budget (below). Warnings alone don't block — note them and proceed.
6. **Run the relevant tests.** Nearest tests to the change first; if the change touches shared/core code, escalate to the broader package's tests. No test file for the change: note it explicitly, proceed, don't invent test infrastructure mid-task. **When a test fails, apply the `testfix` skill's classify-and-fix rules by name** — do not restate or re-derive them here; `testfix` is their one home.
7. **Read the loaded craft skill(s)' rules against the change.** Auto-fix violations of their objective/mechanical rules in code touched this session; report-only for subjective or broad ones. Never rewrite otherwise-correct working code for style alone.
8. **Final conformity — labeled as a self-check.** Re-read the acceptance checklist from Step 1. Per criterion: done, partial (explain), or not done (explain); fix what's fixable within budget. This is your own read-through, not the formal gate — it never substitutes for `agent-crew-critic`'s review (or a human doing that review directly), which is a separate, fresh pass. Say so in the summary.
9. **Report with evidence.** Include the actual command output (compile, test run) for every claim of success — no "should pass now," no summary without the output attached.

**Repair budget: 3 total fix-and-recheck cycles**, shared across Steps 5–8. After 3 cycles without a clean result, stop and report — don't keep iterating silently.

### What you NEVER do

- Never start developing before Step 1's scope and acceptance checklist exist
- Never restate or duplicate `testfix`'s classify-and-fix rules here — reference the skill by name, every time
- Never exceed the 3-cycle repair budget without stopping to report the blocker, what was tried, and what remains broken
- Never claim a task is done, or that tests/compile pass, without the actual executed output attached
- Never treat the final-conformity self-check (Step 8) as a substitute for the formal review — it's a self-check, label it as one
- Never work in a technology with no matching installed craft skill without flagging it first
- Never modify an API contract unilaterally — flag the implication and stop rather than guessing
- Do NOT apply this skill to fixing an already-failing test in isolation with no feature work involved — use `testfix` directly for that

## FOCUS

- Scope and acceptance criteria, established before any code is written
- Project-command detection (package manager, typecheck, tests, lint), including monorepo scoping
- The develop → compile → test → craft-conformance → final-conformity loop, bounded by a 3-cycle repair budget
- Evidence over claims at every step

## OUTPUT

Modified or new files (code and tests). A structured report — scope and acceptance checklist, commands detected, what was developed, compile/typecheck result, test result (with `testfix` invoked by name if any test failed), craft-skill conformance findings, final self-check against the acceptance checklist, and the actual command output backing every claim. This report is conversational — it is not written to a file in the client project; only code and tests are. If the repair budget is exhausted, the report states what remains broken and what was tried instead of a completion claim.
