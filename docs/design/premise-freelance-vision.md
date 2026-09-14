# Premise — Freelance Dev Crew Vision

**Status:** raw premise, parsed from a voice dictation (2026-07-17). Input for an upcoming challenge/brainstorm pass — **not** authoritative. [`SPEC.md`](../SPEC.md) remains the source of truth; anything ratified out of this premise must land there and in `docs/adr/` before implementation.

## Who this is for

A freelance developer who lands on client projects of any kind — innovation topics included (AI/LLM integration, blockchain) — and wants to arrive on any codebase with her own toolkit, the way one would open Codex or GitHub Copilot:

- The crew is **project-agnostic**: it knows nothing about the project in advance, and that must never be a problem.
- The crew is **trivially installable** on a new project.
- The freelance value proposition: deliver quality code easily, be ready to work on anything.

## Core goal

LLMs are already smart enough to work. The crew's job is not to make them smarter — it is to **optimize how they work** through agents and skills that specifically know how to produce quality code.

## Design drivers

### 1. Token economy is the primary constraint

The operator runs on a ~€20/month subscription. Every design decision must respect that budget:

- Never force the full structure (dev + test + review + …) to launch for a small task.
- The developer often has the code in front of her and few tokens available: her dev agent must dev without costing three times the task's worth.

### 2. Unit-first operation

Every capability must be invocable **alone**:

- understand a need,
- develop it,
- fix a bug,
- verify the result.

Composition into a crew is optional; unitary use is the default working mode.

### 3. Verification is part of the work, and it is plural

Fixing a bug includes proving the fix works. Distinct verification types:

- **functional tests** — does it behave as intended;
- **technical tests** — does it respect current best practices;
- **spec compliance** — does it match what was asked.

### 4. Local best-practices reference (no permanent web searching)

Searching the web for best practices on every task is too costly. Instead:

- best practices live in a **reference folder** as a versioned `best-practices.md` (or equivalent) inside a skill;
- that file is **updated regularly** through a maintenance pass, rather than re-fetched at usage time.

### 5. Crew mode: parallel specialists (optional)

When the budget and the task justify it, dispatch several agents working the project together:

- one **back**, one **front**, one **tester**, possibly one **reviewer**;
- outcome expected: a result that is tested and works.

### 6. A critic against hallucination and verbosity

One agent must hold the critical role:

- catch hallucinations;
- enforce spec compliance;
- enforce code quality **including concision** — never 15,000 lines where 2 would do.

### 7. Self-improvement deployment: possible, never required

Deploying the agents to work autonomously on the crew's own product (Morpho-style, per GDIY #553) must be **possible** — but manual, hands-on use must always remain sufficient. The subscription budget rules out mandatory background consumption.

### 8. A tech-watch agent

The operator needs to keep learning. One agent dedicated to **veille** (tech watch): tracking practices, models, tools — feeding both the operator's learning and the best-practices reference (§4).

## Requested next steps (from the dictation)

1. **Challenge this premise against the existing** — what big tech companies actually do (the AI-mature ones, not those just starting), including the Morpho setup as inspiration.
2. **Brainstorm/critique pass** with Fable; evaluate whether to run BMAD on this reflection.
