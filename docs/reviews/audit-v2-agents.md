# Audit — ai-dev-crew v2 agents & skills (adversarial pass, pre-arena)

**Auditor:** agent-ai-expert (crew-auditor) · **Date:** 2026-07-17
**Scope:** `docs/SPEC.md`, ADR 0001–0006, 3 agents, 7 skills. Context: `README.md`, `scripts/crew.sh`.
**Method:** conformance to SPEC/ADRs, internal and cross-artifact contradiction hunting, prompt-effectiveness review against current skill-authoring best practice (superpowers:writing-skills). No artifact was modified.

Severity: **BLOCKING** (contract broken or guarantee false) · **SHOULD-FIX** (predictable failure under real use) · **NITPICK**.

---

## 1. SPEC.md

### B1 — BLOCKING — The file contract's central write path is mechanically impossible

`docs/SPEC.md:62-63`:

> | `docs/adr/` | Written by `agent-crew-butler` (via the `crew-architecture` skill) | ...
> | `docs/design/` | Written by `agent-crew-butler` (via the `crew-architecture` skill) | ...

But `agent-crew-butler.md:4` declares `tools: Read, Grep, Glob, Bash, Agent` — no `Write`, no `Edit`. ADR 0004 (`0004-role-tool-allowlists.md:11`) states this is deliberate: "no `Write`/`Edit`, so it can't implement code even if instructed to." The same restriction makes the butler unable to record the ADRs and design notes it is contractually the sole writer of. The only escape is `Bash` heredocs — which defeats the entire point of ADR 0004 (see B2).

**Fix (pick one, record as ADR):**
1. Give the butler `Write`, behaviorally scoped to `docs/adr/` and `docs/design/` — the exact pattern already used for the critic's `Write` scoped to `docs/reviews/` (ADR 0004:12). Symmetric, honest, one-line change.
2. Keep the butler write-less and change the §4 table: the butler *drafts* ADR content as conversational text; the main session (or user) saves it. Then the table's "Written by" column must say so.

Option 1 is the correct fix — option 2 breaks "coordination is files" for the flow's most important artifact.

### S1 — SHOULD-FIX — §4 mislabels the butler's read of `docs/reviews/` as "sanity check"

`docs/SPEC.md:64`: `docs/reviews/` read by "user, `agent-crew-butler` (sanity check)". But per §1 (line 16) and ADR 0003:9, the sanity check happens on **dev's returned work, before the critic runs** — at that moment no `docs/reviews/` file exists. Two distinct activities are conflated. Related gap: dev's evidence report is conversational only — no file in the §4 table carries it — so a butler invoked later for the sanity check has nothing durable to read and must re-run tests itself (possible via Bash, but nowhere stated).

**Fix:** relabel the `docs/reviews/` read as "relaying the verdict", and either add a dev handoff artifact to the table or state explicitly that the sanity check = butler re-running tests via Bash.

### S2 — SHOULD-FIX — "The butler routes" vs "the main session is the orchestrator"

SPEC §1 line 14: "Routes to `agent-crew-dev` and/or `agent-crew-critic`." README line 128: "The **main session is the orchestrator**: it dispatches one crew agent at a time." These are two different topologies. If the butler is invoked as a classic subagent (every `crew.sh` kickoff does exactly this), two of its core functions are in doubt:
- a subagent has no direct conversational channel to the user (ADR 0004:15 already concedes `AskUserQuestion` is unavailable) — so "qualify the need by asking" and "hold the architecture dialogue" are at best a relay through the main session, at worst a single-shot monologue;
- `Agent` in a subagent's allowlist: classic subagents cannot dispatch subagents; teammate agents can. Whether the butler can *actually* route depends on invocation mode, and no artifact says which mode is assumed.

**Fix:** decide the topology once and write it into §2: either (a) the butler is a *main-session persona* (kickoff starts the session as the butler, giving it real dialogue + dispatch), or (b) the butler is an advisory subagent that returns a routing recommendation the main session executes — in which case remove `Agent` from its tools and reword "routes" to "recommends routing". Validate in a real session before formalizing (this matches the repo's own driver-agent practice).

### N1 — NITPICK — Craft skills advertise a review mode no crew member may use

§3 gives the critic exactly two lenses (`code-quality`, `security-review`); the dev must never self-grade. Yet all three craft skills say "reviewing … code for adherence to modern idioms" (description trigger 2) and "or a short list of adherence findings when used in review mode" (OUTPUT). Inside the crew, that mode has no authorized consumer. **Fix:** either extend the critic ("may additionally load the matching craft skill as a conventions reference") — genuinely useful for its "harmony with existing project practice" duty — or strip review mode from the craft skills.

---

## 2. ADRs

### B2 — BLOCKING (overclaim) — ADR 0004's "mechanically impossible" is false while Bash is allowlisted

`0004-role-tool-allowlists.md:24`: "A butler invocation literally cannot call `Edit` or `Write` — the tool isn't in its resolved tool set. The critic literally cannot silently rewrite a file via `Edit`."

Both allowlists include `Bash`. `echo '...' > src/app.ts` and `sed -i` are one tool call away for either agent. The guarantee ADR 0004 sells as mechanical is in fact behavioral-with-extra-steps until the v2.1 hooks land. ADR 0005 handles its equivalent gap honestly ("nothing mechanically forces the agent to actually run the command instead of fabricating output. That's a known limitation"); ADR 0004 claims the opposite of its own gap.

**Fix:** add the Bash bypass to ADR 0004's Consequences as an explicit known gap, and add a behavioral NEVER to butler and critic: "Never use Bash to create or modify files — Bash is for running/reading, not writing." Cheap, testable, and makes the ADR's claim honest.

### S3 — SHOULD-FIX — ADR 0003's second checkpoint exists nowhere in practice

ADR 0003:18 promises "Two distinct checkpoints sit between implementation and 'done'." No `crew.sh` kickoff prompt ever routes returned dev work through the butler's Check option (choices 1 and 5 hand dev output straight to the critic), and no file carries dev's evidence to a later butler invocation (see S1). The sanity check is currently aspirational. **Fix:** wire it into the choice-5 prompt ("after Phase 2, use agent-crew-butler to sanity-check the returned work before Phase 3") or downgrade the ADR's consequence.

ADRs 0001, 0002, 0005, 0006: sound, internally consistent, honestly argued. No findings. ADR 0005's explicit acknowledgment of the fabrication limitation is the standard 0004 should be held to.

---

## 3. `agent-crew-butler` (plugins/crew-core/agents/agent-crew-butler.md)

### B3 — BLOCKING — OUTPUT promises what the tools forbid

Line 50: "an architecture dialogue conducted directly with the user (never delegated), **with the decision recorded via the `crew-architecture` skill**". No `Write` tool (line 4). The agent's own OUTPUT contract is unfulfillable without the Bash bypass. Same root cause as B1; fixed by the same decision.

### S4 — SHOULD-FIX — Core behaviors assume an interaction channel the agent may not have

Lines 34, 36: "Ask what's needed before dispatching anything", "a dialogue you conduct yourself". As a subagent, its questions land in the dispatching session's transcript, not in front of the user; it cannot iterate a dialogue within one invocation. Same root cause as S2 — resolved by the topology decision. Until then, an LLM running this definition as a subagent will predictably simulate the dialogue (ask-and-answer itself) to complete its turn.

### N2 — NITPICK — Sanity-check note has no destination

Line 50: "a short sanity-check note before handoff" — written where? Conversational only. If the sanity check is meant to be auditable (it gates the critic dispatch), name a destination or explicitly accept it as ephemeral.

**Otherwise:** the definition is well-shaped. Description matches body; NEVER list is concrete and testable ("Never dispatch every crew agent by default", "one routing layer only"); thin-agent principle respected (zero domain content).

---

## 4. `agent-crew-dev` (plugins/crew-dev/agents/agent-crew-dev.md)

### S5 — SHOULD-FIX — Undeclared cross-plugin dependency on `dev-conventions`

Lines 27, 36: "Follow `dev-conventions` for commit style, versioning, and changelog entries." `dev-conventions` ships in `crew-core`; a client installing only `crew-dev` (+ a craft plugin) gets a MUST pointing at a skill that isn't there, which silently no-ops. The agent already has the right pattern for craft skills (line 41: "Never work in a technology with no matching installed craft skill without flagging it first"). **Fix:** extend the same rule: "If `dev-conventions` is not available, flag it and fall back to the host project's documented conventions."

### S6 — SHOULD-FIX — No failure path in the verification loop

The MUST list (line 37) and NEVER list (line 44) fully specify the *success* case (evidence before "done") but say nothing about what to do when the run **fails**. Under pressure, the predictable LLM behaviors are silent retry loops or "mostly passing" euphemisms. **Fix:** add one MUST: "If tests or the build fail, report the failing output verbatim and state the task is not done; after two failed fix attempts, stop and escalate instead of iterating further."

### N3 — NITPICK — Full toolset includes `Agent`

No `tools:` field (deliberate, ADR 0004:13) means dev can dispatch subagents — including, in principle, spawning its own "critic" and claiming a review happened. Line 43's NEVER ("self-checking is not the formal gate") mostly covers this; a half-sentence ("never dispatch other crew agents — the orchestrator does") would close it.

**Otherwise:** the strongest of the three definitions. Evidence wording is tight ("no success claims without evidence", mirrored in NEVER — exactly ADR 0005), the API-contract stop rule is testable, description and body agree.

---

## 5. `agent-crew-critic` (plugins/crew-critic/agents/agent-crew-critic.md)

### S7 — SHOULD-FIX — ROLE contradicts OPTIONS on lens separability

Line 13: "the two lenses don't go one without the other." Lines 20–21 then define **Quality-only** and **Security-only** modes, and `crew.sh` choice 3 runs security-only routinely. An LLM told the lenses are inseparable may "helpfully" add the second lens in single-lens parallel mode — precisely what the parallel design must prevent (it would duplicate the other teammate's work). **Fix:** reword ROLE: "Both lenses by default; a single lens only when explicitly instructed (parallel-review or targeted audit)."

### S8 — SHOULD-FIX — OUTPUT mandates a two-section merged report even in single-lens mode

Line 53: "A single merged findings report … with a Quality section and a Security section." In Security-only mode (choice 3) there is no quality content; the OUTPUT contract still demands the section. **Fix:** "In single-lens mode, the report contains only that lens's section, and says so."

### S9 — SHOULD-FIX — Parallel mode: two instances, one report, no designated writer

Lines 40 and 53 tell *each* instance to reconcile "into one merged report" — both hold `Write`, so the race ends in two competing reports or a clobbered file. The `crew.sh` choice-4 prompt (line 137) has the same gap. **Fix:** designate: "In parallel mode, the quality-lens instance writes the merged report after reconciliation; the security-lens instance contributes findings but does not Write."

### N4 — NITPICK — "Escalate … immediately" has no mechanism

Line 39: escalate to whom, through what? A subagent's only channels are its report and its return message. **Fix:** "…by placing them first in the report AND in the first line of the return message."

### N5 — NITPICK — "no `Edit` tool at all: mechanically impossible" (line 44)

Same Bash caveat as B2 — `sed -i` is in reach. Inherits ADR 0004's fix (behavioral "never modify files via Bash" NEVER).

**Otherwise:** good. Secret-redaction rule includes a concrete format example (line 36), the no-exploit and no-active-scan rules are unambiguous, "propose a fix but leave applying it" matches `code-quality` word-for-word.

---

## 6. Skills

House template (OPTIONS/BEHAVIOR/OUTPUT), "Use when:" trigger-only descriptions, name-only cross-references, English, small word counts: all seven comply with SPEC §3 and current skill-writing practice. Real "Do NOT apply" clauses everywhere — none decorative. Findings below are the exceptions.

### 6.1 `crew-architecture` (crew-core)

**B4 — BLOCKING (contract)** — The skill that anchors the file contract never names the destination path. SPEC §4 routes `docs/adr/` and `docs/design/` through this skill, but its MUST (line 17: "Record significant decisions as a short ADR") and OUTPUT (line 35) never say *where*. Combined with B1/B3, the dialogue → `docs/adr/` → dev loop is open at both ends: no tool to write, no path to write to. **Fix:** add to MUST: "Record ADRs under the host project's `docs/adr/` (create the directory if missing), one file per decision, kebab-case slug."

**N6 — NITPICK** — "significant decisions" (line 17) is the vague predicate; the description already owns the right observable triggers (expensive to reverse, boundary-affecting) — reuse them in the MUST.

### 6.2 `dev-conventions` (crew-core)

**S10 — SHOULD-FIX** — Double nuance clause guts the TDD baseline. Line 18: "write the failing test first **when practical**, or add coverage immediately after **if writing the test first isn't practical**." "Practical" is self-certified; under deadline pressure the model will always find test-first impractical, making the clause read as "tests whenever". The NEVER at line 24 already carries the real, enforceable rule (no completion without a test, observable user-override predicate). **Fix:** drop "when practical" hedging: "Default to writing the failing test first; if you implement first, add the test in the same change — the completion rule in NEVER applies either way."

**N7 — NITPICK** — Description trigger 3 ("deciding whether new code needs tests before it's considered done") overlaps `code-quality` trigger 3 (hygiene at merge gate). Producer-side vs reviewer-side is distinguishable, but a loader matching on "tests before done" can grab either. Acceptable; sharpen if misloads are observed.

### 6.3 `code-quality` (crew-critic)

**N8 — NITPICK** — OUTPUT (line 36) hard-codes crew internals into a "portable" skill: "Used as the quality lens inside `agent-crew-critic`'s review: findings feed … `docs/reviews/<slug>.md`." SPEC §3 claims skills "stay usable outside Claude Code". The sentence belongs in the critic agent, which already owns the report path. Same in `security-review:35`. Cosmetic, but it's the only place the fat-skills/thin-agents boundary leaks in the wrong direction.

Otherwise clean: severity taxonomy (blocking/suggestion) composes correctly with the critic's three-value verdict; "Never treat a passing test suite alone as sufficient evidence" is a genuinely good reviewer rule.

### 6.4 `security-review` (crew-critic)

**S11 — SHOULD-FIX** — Says "OWASP Top 10", enumerates nine. Line 14 lists: injection, broken access control, auth failures, insecure design, misconfiguration, vulnerable components, data integrity, logging failures, SSRF — **Cryptographic Failures (A02:2021) is missing**. A security lens that structurally never looks at weak hashing, plaintext-at-rest, or homegrown crypto, in the one category historically ranked #2. **Fix:** add "cryptographic failures (weak/homegrown crypto, plaintext sensitive data at rest or in transit)" to the enumeration.

Otherwise the strongest skill: redaction, no-exploit, and no-active-scan rules are precise and match the critic agent verbatim (no drift).

### 6.5 `angular-craft`, `java-craft`, `python-craft`

**S12 — SHOULD-FIX (all three)** — Orphaned review mode: see N1. Description trigger 2 and OUTPUT ("or a short list of adherence findings when used in review mode") name a mode no crew agent is authorized to run. Recommended resolution: authorize the critic to load the matching craft skill as a conventions reference (serves its `docs/adr/`-harmony duty) — record as a one-line SPEC §3 note.

**N9 — NITPICK (all three)** — Shipped placeholder comments: `angular-craft:28`, `java-craft:26`, `python-craft:26` — `<!-- TODO: user references — team-specific style guide… -->`. Fine as a deliberate customization hook, but then say so ("populate per client") instead of `TODO`, which reads as unfinished work in a shipped v2.

Content quality is high across all three: version-matching rule first, observable stop conditions (API/schema contract changes), conditional signals-vs-RxJS guidance keyed to an observable predicate ("when the project has already adopted signals"), consistent structure across the trio.

---

## 7. `crew.sh` kickoff prompts vs the contract (context — mismatches only)

**B5 — BLOCKING mismatch** — Choice 1 auto-chains implementation → review, violating SPEC §2. Line 123: "Once implemented, use agent-crew-critic to run the quality and security gate **before finishing**." Line 121 (arch path) likewise chains dev → critic after the single design approval. SPEC §2 line 40: "Every arrow is a user-triggered step; phases never auto-chain. The butler enforces an explicit user gate between … implementation, and the critic's formal gate." The launcher's second-most-prominent path institutionalizes the exact behavior the SPEC forbids. **Fix:** insert "then STOP and wait for my explicit approval before invoking agent-crew-critic" into both choice-1 prompts.

**S13 — SHOULD-FIX** — Choice 5's numbered phases contradict their own trailing rule. Line 141 places STOP after Phase 1 and after Phase 3, but the Phase 2 → Phase 3 boundary has no STOP; the closing sentence ("each phase ends with a pause") contradicts the enumeration it follows. An LLM follows the numbered structure. **Fix:** end Phase 2 with an explicit "then STOP for my approval" — ideally routed through the butler's sanity check (closes S3 at the same time).

**S14 — SHOULD-FIX** — Choice 0 requires `crew-core crew-dev` (line 113) but its prompt authorizes routing "to agent-crew-dev and/or **agent-crew-critic**" (line 114). If the qualified need is a review, the flow hits a missing plugin mid-session. **Fix:** require `crew-critic` too, or append "if crew-critic isn't installed, say so instead of proceeding."

---

## 8. Arena worthiness

| Agent | Arena-worthy | Why |
| --- | --- | --- |
| `agent-crew-butler` | **Not yet** | Its real defects (B1/B3: no `Write` vs ADR-writing contract; S2/S4: subagent-vs-orchestrator topology) are *contract decisions*, not prompt-craft. An arena run today would produce two polished variants of the same unfulfillable contract. Decide topology + Write scope first (two ADR-level choices, ~1 hour), then the butler becomes the **most** arena-worthy artifact — its qualification/routing/gating persona has the widest behavioral variance to optimize. |
| `agent-crew-dev` | **No** | Already the best-aligned artifact: evidence loop matches ADR 0005 verbatim, stop conditions are observable, description/body coherent. The three findings (S5, S6, N3) are additive one-liners — apply them directly; an arena would burn budget polishing an artifact with no structural tension. |
| `agent-crew-critic` | **Yes** | All findings (S7–S9, N4–N5) are self-contained wording problems inside one file — lens separability, single-lens output shape, parallel-writer designation. Exactly the class of tension competitive rewriting resolves well, with a clear equivalence test (do both critics in choice-4 parallel mode produce one report, and does choice-3 single-lens produce a sane one?). Highest payoff-per-token of the three. |

**Recommended sequence:** (1) settle B1/B2 with one ADR (butler Write scope + Bash-bypass honesty) and S2's topology decision; (2) apply the mechanical one-line fixes (S5–S6, S10–S14, B4–B5); (3) arena the critic; (4) arena the butler only after step 1 lands.

---

## 9. Finding index

| ID | Severity | Artifact | Line | Summary |
| --- | --- | --- | --- | --- |
| B1 | Blocking | SPEC.md | 62–63 | Butler is sole writer of `docs/adr|design/` but has no Write tool |
| B2 | Blocking | ADR 0004 | 24 | "Mechanically impossible" false — Bash bypass unacknowledged |
| B3 | Blocking | agent-crew-butler | 50 | OUTPUT promises recorded decision; tools forbid it |
| B4 | Blocking | architecture skill | 17, 35 | ADR destination path never named — contract loop open |
| B5 | Blocking | crew.sh | 121, 123 | Choice 1 auto-chains dev → critic, violating SPEC §2 |
| S1 | Should-fix | SPEC.md | 64 | `docs/reviews/` read mislabeled "sanity check"; dev evidence has no file |
| S2 | Should-fix | SPEC.md / README | 14 / 128 | Butler-routes vs main-session-orchestrates topology conflict |
| S3 | Should-fix | ADR 0003 | 18 | Second checkpoint exercised by no flow |
| S4 | Should-fix | agent-crew-butler | 34, 36 | Dialogue behaviors assume a user channel a subagent lacks |
| S5 | Should-fix | agent-crew-dev | 36 | Undeclared dependency on crew-core's `dev-conventions` |
| S6 | Should-fix | agent-crew-dev | 37, 44 | No failure path in verification loop |
| S7 | Should-fix | agent-crew-critic | 13 vs 20–21 | Lenses "inseparable" vs single-lens OPTIONS |
| S8 | Should-fix | agent-crew-critic | 53 | Two-section OUTPUT mandated even single-lens |
| S9 | Should-fix | agent-crew-critic | 40, 53 | Parallel mode: no designated report writer |
| S10 | Should-fix | dev-conventions | 18 | "When practical" double hedge guts TDD-first |
| S11 | Should-fix | security-review | 14 | "Top 10" enumerates 9 — Cryptographic Failures missing |
| S12 | Should-fix | craft skills ×3 | OUTPUT | Review mode has no authorized consumer |
| S13 | Should-fix | crew.sh | 141 | Choice 5: no STOP between Phase 2 and 3 |
| S14 | Should-fix | crew.sh | 113–114 | Choice 0 may route to uninstalled crew-critic |
| N1–N9 | Nitpick | various | — | See sections above |
