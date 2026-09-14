# testfix — classify and fix red tests

> Chargé par `agents/agent-tester.md` en entier, et par `agents/agent-dev.md` pour la seule classification du Step 5 quand un test passe au rouge. **Règles** fait autorité.
>
> Dernière passe de veille : —

## Règles

Execute the steps in order. Do not touch any file before Step 3's output is in hand.

### What you MUST do

1. **Detect the runner.** Build file or `package.json` scripts first, then config files, then dependencies as a last resort. If it can't be determined, stop and report the runner as unknown — never guess a command; whoever briefed the run supplies it.

   | Found | Runner | One file / test | Full suite |
   | --- | --- | --- | --- |
   | `pom.xml` (prefer `./mvnw`) | Maven + JUnit | `mvn test -Dtest=OrderServiceTest` (`#method` for one test) | `mvn verify` if `pom.xml` declares `maven-failsafe-plugin`, else `mvn test` |
   | `build.gradle(.kts)` (prefer `./gradlew`) | Gradle + JUnit | `./gradlew test --tests 'com.acme.OrderServiceTest'` | `./gradlew test` |
   | `vitest.config.*` or `vitest` in scripts | Vitest | `npx vitest run <file> --reporter=verbose` | `npx vitest run` |
   | `jest.config.*` or `jest` in scripts | Jest | `npx jest <file> --verbose` | `npx jest` |
   | `cypress.config.*` | Cypress | `npx cypress run --spec <file>` | `npx cypress run` |
   | `playwright.config.*` | Playwright | `npx playwright test <file>` | `npx playwright test` |
   | `pyproject.toml` / `pytest.ini` / `conftest.py` | pytest | `pytest <file>::<test> -v` (prefix `uv run` / `poetry run` per lockfile) | `pytest` |

   An Angular project runs its fast tier through `package.json`'s `test` script (`ng test`); use that script rather than guessing the underlying runner.

2. **Identify scope.** The most specific target wins: a named test method → that method; a test file → that file only. Only a source file was mentioned: find its tests by the stack's naming — `*.spec.ts` / `*.test.ts(x)`, `*Test.java` / `*IT.java` under `src/test/`, `test_*.py` / `*_test.py` — and run those. Nothing specific: run the full suite.
3. **Run and capture.** Execute the command, capturing the **entire** output — no truncation. Compilation or type errors in the output are source errors (Step 5).
4. **Parse the failures.** For each failing test, extract: test name; test file and line; exact error message; the stack-trace lines pointing to a non-test source file. Zero failures: output "All tests pass. Nothing to fix." and stop.
5. **Classify and fix each failure:**
   - **Fix the source if:** the stack trace points to a non-test source file; the error is a runtime exception (`TypeError`, `NullPointerException`, `AttributeError`…); the returned value doesn't match the logic the test validates; it is a compilation or type error in source code.
   - **Fix the test if:** it is a snapshot mismatch and the content change was clearly intentional; a mock no longer matches an API contract that was intentionally updated; the test asserts a hardcoded value that was deliberately changed elsewhere.
   - **When genuinely ambiguous**, fix the source and explain why. Edits are surgical — fix only what the captured output shows is broken.
6. **Verify, looping.** Re-run the same command. All pass: report done. Still failing, under 3 total iterations: return to Step 4 with the new output. Still failing after 3: stop and report.

### What you NEVER do

- Never touch a file before Step 3's captured output exists
- Never widen or weaken an assertion to make a failing test pass (`assertEquals(5, x)` → `assertNotNull(x)`, `toBe(5)` → `toBeDefined()`)
- Never modify a test to hide a genuine bug in the source
- Never disable a failing test (`@Disabled`, `.skip`, `@pytest.mark.skip`) to turn the run green
- Never exceed 3 verify-loop iterations without stopping to report
- Do NOT use these rules to write new tests for untested behavior — they fix already-written, already-failing tests; that is `--dev`, which writes tests alongside new code and designs missing scenarios

## Output

Conversational, not written to a file: runner and scope detected; the first run's captured output; per test, `name → file:line — what failed, source bug or stale test`; per file, what changed and why; the re-run output that verifies the fix. Still failing after 3 iterations: the remaining failing tests, what was tried, and the likely root cause, instead of a completion claim.
