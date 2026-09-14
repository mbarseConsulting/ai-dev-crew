---
name: java-craft
description: "Use when: (1) writing or modifying Java/Spring Boot code, (2) reviewing Java code for adherence to modern idioms, (3) deciding on dependency injection, transaction boundaries, or API layering for a Java service."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Match the Java and Spring Boot version and conventions already in use in the project before introducing new ones
- Prefer constructor injection over field injection; keep classes and fields as restrictive as reasonable
- Write or update a test (JUnit) alongside any behavior change
- Flag when a requested change implies an API contract or database schema change, and stop rather than guessing

### What you NEVER do

- Never introduce a new framework, ORM, or major dependency without flagging it as a decision for the user first
- Never bypass Spring's transaction boundaries or exception handling to "make it work" without flagging the workaround
- Never drop existing input validation or error handling while touching a method
- Do NOT apply this skill to non-Java backend code or to front-end code

<!-- Customization hook — populate per client: team-specific Java/Spring Boot style guide, preferred build tool (Maven/Gradle) conventions, module/package layering rules -->

## FOCUS

- Modern Spring Boot idioms (constructor injection, records for DTOs where they fit)
- Layering: controller / service / repository boundaries
- Transaction and exception-handling conventions
- Test coverage with JUnit, matching the project's existing test style

## OUTPUT

Component/service/test code that follows the rules above, produced by `agent-crew-dev` when implementing. Review mode (a short list of adherence findings instead of code) has two authorized consumers only: `agent-crew-dev`, self-checking its own work-in-progress (not a substitute for the formal gate), and `agent-crew-critic`, loading this skill as a conventions-reference lens alongside `code-quality`/`security-review` when checking harmony with existing project practice.
