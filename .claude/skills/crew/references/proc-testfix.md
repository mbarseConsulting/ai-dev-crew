# testfix — classify and fix red tests

> Run by: `agents/agent-tester.md`. Last watch: 2026-09-14

## Steps

1. **Detect the runner** from the build file or `package.json` scripts, then config files, then dependencies. Unknown → stop and report; whoever briefed the run supplies the command.

   | Found | Runner | One file / test | Full suite |
   | --- | --- | --- | --- |
   | `pom.xml` (prefer `./mvnw`) | Maven + JUnit | `mvn test -Dtest=OrderServiceTest` (`#method` for one test) | `mvn verify` if `maven-failsafe-plugin` is declared, else `mvn test` |
   | `build.gradle(.kts)` (prefer `./gradlew`) | Gradle + JUnit | `./gradlew test --tests 'com.acme.OrderServiceTest'` | `./gradlew test` |
   | `vitest.config.*` or `vitest` in scripts | Vitest | `npx vitest run <file> --reporter=verbose` | `npx vitest run` |
   | `jest.config.*` or `jest` in scripts | Jest | `npx jest <file> --verbose` | `npx jest` |
   | `cypress.config.*` | Cypress | `npx cypress run --spec <file>` | `npx cypress run` |
   | `playwright.config.*` | Playwright | `npx playwright test <file>` | `npx playwright test` |
   | `pyproject.toml` / `pytest.ini` / `pytest.toml` / `.pytest.toml` / `conftest.py` | pytest | `pytest <file>::<test> -v` (`uv run` / `poetry run` per lockfile) | `pytest` |

   An Angular project runs its fast tier through the `test` script (`ng test`), never a guessed runner.
2. **Scope.** The most specific target wins: a named test, a test file, the tests of a named source file (`*.spec.ts` / `*.test.ts`, `*Test.java` / `*IT.java`, `test_*.py`), else the full suite.
3. **Run and capture the entire output.** Nothing is touched before this exists. A compilation or type error is a source failure.
4. **Parse each failure:** test name, file and line, exact message, the stack-trace lines pointing at non-test source. Zero failures → "All tests pass. Nothing to fix." and stop.
5. **Classify and fix.** Source is wrong when the trace points at source, the error is a runtime exception, the value contradicts the logic the test states, or the code does not compile. The test is wrong when a snapshot changed intentionally, a mock lags an intentionally updated contract, or a hardcoded value was deliberately changed. Ambiguous → fix the source and say why. Surgical edits only.
6. **Re-run the same command.** Green → done. Red and under 3 iterations → back to step 4. Red after 3 → stop and report.

## NEVER

- Never widen or weaken an assertion to pass (`toBe(5)` → `toBeDefined()`)
- Never modify a test to hide a genuine source bug
- Never disable a failing test (`@Disabled`, `.skip`, `@pytest.mark.skip`) to turn the run green
- Never write tests for behavior that has none — that is development

## Output

Runner and scope; the first captured output; per test, `name → file:line — what failed, source bug or stale test`; per file, what changed and why; the re-run output. After 3 red iterations: what remains broken, what was tried, the likely root cause, never a completion claim.
