# conventions — commits, versions, changelog, TDD baseline

> Chargé quand le contexte le demande : un commit, une version, un changelog, « est-ce fini ? ».
> **Règles** fait autorité, **Pourquoi** explique. En cas de désaccord, Règles a raison.
>
> Dernière passe de veille : —

## Règles

### What you MUST do

- Use Conventional Commits prefixes (`feat`, `fix`, `docs`, `refactor`, `test`, `chore`) for commit subjects; mark a breaking change with `!` or a `BREAKING CHANGE:` footer
- Follow the host project's own branch-naming convention when one is documented (e.g. a `CONTRIBUTING.md`); if none exists, default to `<type>/<kebab-case-description>`
- Apply Semantic Versioning (`MAJOR.MINOR.PATCH`) to any versioned artifact: breaking change → major, new backward-compatible capability → minor, fix or internal change → patch
- Add a changelog entry in Keep a Changelog format (`Added` / `Changed` / `Deprecated` / `Removed` / `Fixed` / `Security`) for any user-visible change to a versioned artifact
- Treat new behavior as requiring a test before it is considered done (TDD baseline): default to writing the failing test first; if you implement first, add the test in the same change

### What you NEVER do

- Never invent a branch-naming or commit convention when the project already documents one
- Never bump a version without a corresponding changelog entry
- Never mark a feature or fix as complete without at least one test exercising the new behavior, unless the user explicitly says tests are out of scope for this change
- Do NOT use these rules for prose, documentation-only repos with no versioning, or throwaway prototyping explicitly flagged as such by the user

## Pourquoi

**Un préfixe de commit est une donnée, pas un style.** Il permet de dériver mécaniquement le prochain numéro de version et le changelog. Un historique sans préfixe ne peut être résumé qu'en le relisant.

**SemVer est une promesse faite à celui qui dépend de l'artefact.** Un correctif publié en version majeure ne casse rien, mais apprend aux consommateurs à ignorer les versions majeures. C'est l'inverse qui casse : un changement cassant publié en mineure.

**Le changelog s'écrit pour un humain.** `git log` dit ce qui a changé dans le code, le changelog dit ce qui a changé pour celui qui l'utilise. Les deux ne se remplacent pas.

**La base TDD ne porte pas sur l'ordre d'écriture, elle porte sur la preuve.** Un comportement sans test n'est pas démontré, il est affirmé. Écrire le test d'abord est la façon la plus sûre de voir qu'il peut échouer.

## Sources

- [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Versioning 2.0.0](https://semver.org/)
- [Keep a Changelog 1.1.0](https://keepachangelog.com/en/1.1.0/)
