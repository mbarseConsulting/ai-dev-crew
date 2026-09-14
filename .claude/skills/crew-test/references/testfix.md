## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

Execute the following steps in order. Do not skip steps. Do not touch any file before Step 3's output is in hand.

### What you MUST do

1. **Detect the runner.** `package.json` scripts (`test`, `test:unit`, `test:e2e`, `test:run`, `test:watch`) first; then config files (`vitest.config.*`, `cypress.config.*`, `jest.config.*`, `playwright.config.*`); `devDependencies` as a last resort. If it can't be determined, ask which command to run before proceeding.
2. **Identify scope.** A specific test file was mentioned: run that file only. A source file/component was mentioned: find its associated test files (`*.test.ts`, `*.spec.ts`, `*.test.tsx`) and run those. Nothing specific: run the full suite.
3. **Run and capture.** Execute the test command via `Bash`, capturing the **entire** output — no truncation. Command by runner: vitest — `npx vitest run <file> --reporter=verbose` (omit `<file>` for the full suite); jest — `npx jest <file> --verbose`; cypress — `npx cypress run --spec <file>`; playwright — `npx playwright test <file>`. TypeScript/compilation errors in the output are treated as source errors (Step 5).
4. **Parse the failures.** For each failing test, extract: test name; test file path and line number; exact error message; stack trace, specifically any lines pointing to a non-test source file. Zero failures: output "All tests pass. Nothing to fix." and stop.
5. **Classify and fix each failure:**
   - **Fix the source file if:** the stack trace points to a non-test source file; the error is a runtime exception (`TypeError`, undefined/null reference, etc.); the returned value doesn't match the logic the test is validating; it's a TypeScript/compilation error in source code.
   - **Fix the test file if:** it's a snapshot mismatch and the content change was clearly intentional; a mock value no longer matches an API contract that was intentionally updated; the test asserts a hardcoded value that was deliberately changed elsewhere.
   - **Absolute rules, never violated:** never widen an assertion to make a test pass (`expect(x).toBe(5)` → `expect(x).toBeDefined()` is forbidden); never modify a test to hide a bug in the source; when genuinely ambiguous, fix the source and explain why; edits are surgical — fix only what the captured output shows is actually broken.
6. **Verify, looping.** Re-run the same command. All pass: report done with a summary of changes. Still failing, under 3 total iterations: return to Step 4 with the new output. Still failing after 3 total iterations: stop, report the full diagnosis, what was attempted, and what remains broken.

### What you NEVER do

- Never touch a file before Step 3's captured output exists
- Never widen or weaken an assertion to make a failing test pass
- Never modify a test to hide a genuine bug in the source
- Never exceed 3 verify-loop iterations without stopping to report
- Do NOT use these rules for writing new tests for previously-untested behavior — they fix already-written, already-failing tests; use `crew-dev` (which writes tests alongside new code) or `crew-test`'s Design option (which designs missing scenarios) instead

## FOCUS

- Runner and scope detection before touching anything
- Source-vs-test classification per failure, governed by the absolute rules above
- Surgical fixes only — no scope creep beyond what the captured output shows
- A bounded, honest verify loop (3 iterations, then stop and report)

## OUTPUT

A structured report: runner and scope detected; the first run's captured output; per-test diagnosis (test name → file:line — what failed, source bug or stale test); per-file fix description (what changed and why); the re-run output that verifies the fix. Conversational — not written to a file. If still failing after 3 iterations: the remaining failing tests, what was tried, and the likely root cause, instead of a completion claim.

## ACTIVATION - DEACTIVATION - HANDOFF

**`[TESTFIX]`** — Display this immediately.

**Applies to this response only. Auto-resets after.** Completes after one full cycle or 3 loop iterations, whichever comes first — no persistent mode.
