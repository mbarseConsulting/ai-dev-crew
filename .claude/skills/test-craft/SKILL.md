---
name: test-craft
description: "Use when: (1) deciding whether a piece of behavior belongs in a fast unit/logic test or a DOM/end-to-end test, (2) designing end-to-end test scenarios for a feature, (3) independently verifying a change by running the full test suite rather than just the tests its author ran."
---

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Route logic/state/pure-function behavior to fast, isolated tests: guards (route logic, dispatch), services (business logic, API calls, mocked dependencies), pipes (pure transformations), interceptors (HTTP headers, auth), reducers (state mutations), effects (side effects, dispatching) — no real DOM, no real browser
- Route visual, DOM-interaction, and user-journey behavior to end-to-end/component tests: page components (forms, routing, complex state), UI components (modals, cards, selects), directives with CSS/hover/keyboard behavior — real rendering
- Design end-to-end scenarios around actual user journeys (what a person does, in order), not around implementation internals
- Independently run the **full** test suite — not just the subset the change's author ran — as the verification step, and report the actual command output
- Flag disabled or skipped suites (e.g. `describe.skip`, `xdescribe`) rather than passing over them silently

### What you NEVER do

- Never put pure logic (reducers, pipes, services) in a heavy DOM/browser-driven test — too slow, wrong tier
- Never rely on a fast/mocked test to validate real rendering, CSS, or DOM interaction — wrong tier, use the end-to-end tier instead
- Never treat "the author's own targeted run passed" as sufficient verification — this skill's value is in running the full suite independently of the author
- Never let a disabled test suite go unflagged
- Do NOT apply this skill to fixing an already-failing test (use `testfix`) or to implementing the feature itself and writing its accompanying tests (use `dev-loop`) — this skill is strategy and independent verification, not authoring or repair

## FOCUS

- Unit/logic tier vs. end-to-end/DOM tier: which behavior belongs where, and why
- End-to-end scenario design around user journeys
- Independent full-suite execution as the actual verification step
- Flagging disabled or skipped suites

## OUTPUT

Either: a tier recommendation (which kind of test a piece of behavior belongs in, and why) with a short rationale; or an end-to-end scenario list; or a full-suite run with the actual command output and a pass/fail verdict, including any disabled suites found. Conversational, not written to a file — this is the independent-verification evidence reported back by whoever invoked the skill (an `agent-crew-tester` dispatch, or a solo session). It does not substitute for `agent-crew-critic`'s formal review; independent test execution and a quality/security review are separate concerns.

<!-- Customization hook — populate per client: specific test framework if not Vitest/Cypress-shaped, CI test-tier gating rules -->
