# conventions — commits, versions, changelog, test baseline

> Load when: a commit, a version bump, a changelog, "is it done?". Last watch: 2026-09-14

## MUST

- Prefix commit subjects per Conventional Commits (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`), `!` or a `BREAKING CHANGE:` footer for a breaking change — the prefix is data: it derives the next version and the changelog mechanically
- Follow the project's documented branch naming; none documented → `<type>/<kebab-case-description>`
- Apply Semantic Versioning to any versioned artifact: breaking → major, compatible capability → minor, fix → patch — a breaking change shipped as minor is what actually breaks consumers
- Treat a 0.y.z artifact as exempt from breaking → major — under major version zero anything may change and the API is not yet stable
- Add a Keep a Changelog entry (`Added` / `Changed` / `Deprecated` / `Removed` / `Fixed` / `Security`) for any user-visible change — `git log` says what changed in the code, the changelog says what changed for the person using it
- Keep an `Unreleased` section at the top of the changelog — cutting a release is then retitling it
- Treat new behavior as done only once a test exercises it — a behavior without a test is asserted, not demonstrated

## NEVER

- Never invent a branch or commit convention when the project documents one
- Never bump a version without its changelog entry
- Never mark a feature or fix complete with no test on the new behavior, unless the user says tests are out of scope

## Not here

- Prose, documentation-only repositories, prototypes the user flagged as throwaway — none of this applies

## Sources

- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/)
