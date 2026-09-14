# angular — Angular

Loaded by the role agent once `SKILL.md`'s detection table has identified this stack.

> Dernière passe de veille : —

## REFERENCES

Load one when the task's context calls for it, never by default:

- `technos/angular-patterns.md`

## BEHAVIOR

### What you MUST do

- Keep components and services strictly typed — use specific types (`unknown`, `Record<string, unknown>`, domain interfaces) instead of `any`
- Use `ChangeDetectionStrategy.OnPush` on all production components (test mocks excepted)
- Use `standalone: true` for all components, directives, and pipes
- Use Angular's built-in control flow (`@if`, `@for`, `@switch`), with a `track` expression on every `@for`
- Use `catchError()` in the pipe chain for RxJS error handling; use `takeUntilDestroyed()` for manual subscriptions in components; use `take(1)` for one-shot subscriptions; prefer the `async` pipe or Signals over manual `.subscribe()` when either is viable
- Use `afterNextRender` instead of `setTimeout` for DOM-related timing, and RxJS `timer` instead of `setTimeout` for stream-based delays (utility code outside components may use `setInterval` with proper teardown)
- Always pair a `(click)` handler with a keyboard equivalent (`(keydown.enter)`, `(keydown.space)`) — visual-only interactivity is not accessible
- Prefer signals for local component state and RxJS for async streams/event composition, when the project has already adopted signals; otherwise follow the project's existing state approach. When the project uses NgRx: keep NgRx as the single source of truth for application state, and use scoped, context-specific selectors rather than ones coupled to route-tree structure
- Place a test in the tier its behavior belongs to: the fast tier is a `.spec.ts` with mocked dependencies (`MockStore`, `TestBed` DI, `HttpTestingController`, `provideMockActions`/`provideMockStore`) and covers guards, services, pipes, interceptors, reducers and effects; the end-to-end tier is a `.cy.ts` with real rendering (`cy.mount()`, `cy.intercept()` for HTTP) and covers page components, UI components, and directives with CSS/hover/keyboard behavior

### What you NEVER do

- Never migrate an app to standalone components/signals mid-task unless explicitly asked — that is an architectural decision, not a drive-by change
- Never bypass Angular's type system or change detection to force something to work without flagging the workaround
- Never use `*ngIf`/`*ngFor`/`*ngSwitch` in new or touched code — deprecated in favor of the built-in control flow
- Never use `.subscribe()` without a cleanup mechanism — a manual subscription with no `takeUntilDestroyed()` (or equivalent) is a memory leak
- Do NOT use these rules for non-Angular front-end code (plain HTML/JS, other frameworks) or to backend/API code — the BFF belongs to `references/bp-bff.md`, the shape of the contract it consumes to `references/bp-api-rest.md`, and security review to `--review`

### What you report but don't auto-fix

Same objective/subjective split as `agents/agent-dev.md` Step 7: the rules above are mechanical enough to auto-fix in code touched this session. The following are broader guidelines — worth flagging, never worth silently rewriting working code over:

- Lazy-loaded routes (`loadComponent`/`loadChildren`) for feature modules, where the project's routing structure supports it
- Prefer Signals over `BehaviorSubject`-based custom stores for *new* reactive state (existing patterns aren't a rewrite target on their own)
- Early detection of a missing i18n translation key, if the project has i18n set up

<!-- Customization hook — a project's own names, versions and choices belong in its project file, never here. -->

## FOCUS

- Standalone components, `OnPush`, and modern control flow as the default shape of new/touched code
- Signals vs. RxJS: right tool for local state vs. async streams; NgRx as source of truth when the project already uses it
- Typed reactive forms, no `any`
- Component boundaries: presentation vs. container, explicit `@Input`/`@Output` contracts
- Accessibility: keyboard parity with every `(click)` handler
- `.spec.ts` vs `.cy.ts`: which behavior belongs in which tier, and the tooling each uses

