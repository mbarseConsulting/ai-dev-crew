# conventions — git, semver, changelog, TDD

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Use Conventional Commits style prefixes (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`) for commit subjects
- Follow the host project's own branch-naming convention when one is documented (e.g. a `CONTRIBUTING.md`); if none exists, default to `<type>/<kebab-case-description>`
- Apply Semantic Versioning (`MAJOR.MINOR.PATCH`) to any versioned artifact: breaking change → major, new backward-compatible capability → minor, fix or internal change → patch
- Add a changelog entry in Keep a Changelog format (`Added` / `Changed` / `Fixed` / `Removed`) for any user-visible change to a versioned artifact
- Treat new behavior as requiring a test before it's considered done (TDD baseline): default to writing the failing test first; if you implement first, add the test in the same change — the completion rule in NEVER below applies either way, with no "practical" escape hatch

### What you NEVER do

- Never invent a branch-naming or commit convention when the project already documents one — follow the existing one
- Never bump a version without a corresponding changelog entry
- Never mark a feature or fix as complete without at least one test exercising the new behavior, unless the user explicitly says tests are out of scope for this change
- Do NOT use these rules for prose, documentation-only repos with no versioning, or throwaway prototyping explicitly flagged as such by the user

## OUTPUT

Commit messages, branch names, version bumps, and changelog entries that follow the rules above, silently — no need to announce that this skill is active.
