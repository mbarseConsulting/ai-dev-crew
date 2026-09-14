---
name: crew-test
description: "Use when: (1) one or more tests are failing and need fixing, (2) deciding whether a piece of behavior belongs in a fast isolated test or an end-to-end test, (3) designing end-to-end scenarios for a feature, (4) independently verifying a change by running the full suite rather than just the tests its author ran."
---

## OPTIONS

- **Verify** — run the full suite independently and report the actual result. Default.
- **Design** — design missing end-to-end scenarios, using the tier criterion below.
- **Fix** — one or more tests are red: load `references/testfix.md` and apply its classify-and-fix rules.

## OPTIONS

**NONE** — This skill has no configurable options.

## BEHAVIOR

### What you MUST do

- Route behavior to the **fast, isolated tier** when it is deterministic logic whose collaborators can be mocked — it must be provable with no real browser, no real DOM, and no real network
- Route behavior to the **end-to-end / component tier** when it only exists once the thing is really rendered and really wired: visual result, DOM interaction, CSS, keyboard handling, a journey across screens
- Take the concrete artifact names for a technology from its persona in `agents/`, never from here — this skill owns the criterion, each persona owns its expression (`agent-angular` maps it to guards/pipes/interceptors/effects vs. page and UI components, and names the file suffixes and tooling)
- Design end-to-end scenarios around actual user journeys (what a person does, in order), not around implementation internals
- Independently run the **full** test suite — not just the subset the change's author ran — as the verification step, and report the actual command output
- Flag disabled or skipped suites (e.g. `describe.skip`, `xdescribe`) rather than passing over them silently

### What you NEVER do

- Never put deterministic logic in a heavy DOM/browser-driven test — too slow, wrong tier
- Never rely on a fast/mocked test to validate real rendering, CSS, or DOM interaction — wrong tier, use the end-to-end tier instead
- Never restate a technology's artifact list or file-naming convention here — that belongs to its persona, and two copies would drift
- Never treat "the author's own targeted run passed" as sufficient verification — this skill's value is in running the full suite independently of the author
- Never let a disabled test suite go unflagged
- Do NOT apply this skill to implementing a feature and writing its accompanying tests (the development loop) or to reviewing a change (the formal review gate) — this skill is strategy, repair and independent verification

## FOCUS

- Unit/logic tier vs. end-to-end/DOM tier: which behavior belongs where, and why
- End-to-end scenario design around user journeys
- Independent full-suite execution as the actual verification step
- Flagging disabled or skipped suites

## OUTPUT

Either: a tier recommendation (which kind of test a piece of behavior belongs in, and why) with a short rationale; or an end-to-end scenario list; or a full-suite run with the actual command output and a pass/fail verdict, including any disabled suites found. Conversational, not written to a file — this is the independent-verification evidence reported back by whoever invoked the skill (an `agent-crew-tester` dispatch, or a solo session). It does not substitute for `agent-crew-critic`'s formal review; independent test execution and a quality/security review are separate concerns.

<!-- Customization hook — populate per client: specific test framework if not Vitest/Cypress-shaped, CI test-tier gating rules -->

## SUPPORTING FILES

### References

| Context | Load |
| --- | --- |
| A test is failing and must be fixed | `references/testfix.md` |
| The concrete artifacts and file naming of a stack | that stack's persona in `agents/` |

## ACTIVATION - DEACTIVATION - HANDOFF

**`[CREW-TEST]`** — Display this immediately.

**Applies to this response only. Auto-resets after.**
