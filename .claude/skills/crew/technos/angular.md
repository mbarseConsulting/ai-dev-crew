# angular — Angular

> Load when: the change touches `*.ts`, `*.html`, `*.scss` or `*.css` under an `angular.json` project. Last watch: 2026-09-14 · Target: Angular 17+

## MUST

- Type everything: `unknown`, `Record<string, unknown>` or a domain interface, never `any` — `any` turns a compile error into a runtime one
- Use `ChangeDetectionStrategy.OnPush` on every production component — default change detection re-renders the tree on every event
- Declare components, directives and pipes `standalone: true` — NgModules add a second graph to maintain for nothing
- Use the built-in control flow (`@if`, `@for` with `track`, `@switch`) — the structural directives are deprecated, and an untracked `@for` re-creates every DOM node on each change
- Handle RxJS errors with `catchError()` in the pipe; clean up manual subscriptions with `takeUntilDestroyed()`; use `take(1)` for one-shot calls; prefer the `async` pipe or a signal over `.subscribe()` — a subscription with no teardown is a memory leak
- Use `afterNextRender` for DOM timing and RxJS `timer` for delays — `setTimeout` runs outside Angular's lifecycle and change detection
- Use `afterRenderEffect` for DOM work that must re-run when a signal it reads changes, `afterNextRender` for one-shot work — the first is reactive, the second fires once
- Pair every `(click)` with a keyboard equivalent (`(keydown.enter)`, `(keydown.space)`) — mouse-only interactivity is not accessible
- Use signals for local state and RxJS for streams when the project has adopted signals; otherwise follow its existing state approach. With NgRx, NgRx is the single source of truth, read through scoped selectors, not selectors coupled to the route tree
- Put a test in its tier: a `.spec.ts` with mocked dependencies (`TestBed`, `HttpTestingController`, `provideMockStore`) for guards, services, pipes, interceptors, reducers, effects; a `.cy.ts` with real rendering (`cy.mount()`, `cy.intercept()`) for components and directives whose behavior is visual, CSS, hover or keyboard

## NEVER

- Never use `*ngIf`, `*ngFor`, `*ngSwitch` in new or touched code — deprecated in favor of the built-in control flow
- Never `.subscribe()` without a cleanup mechanism
- Never bypass the type system or change detection to force something to work without flagging the workaround
- Never migrate an app to standalone or signals mid-task unless asked — that is an architectural decision, not a drive-by change

## Flag, don't fix

- Lazy-loaded routes (`loadComponent`, `loadChildren`) for feature areas, where the routing structure allows it
- Signals over `BehaviorSubject`-based custom stores for new reactive state — existing stores are not a rewrite target
- A missing i18n key, when the project has i18n set up

## Not here

- The BFF the front end calls → `references/bp-bff.md`; the shape of its contract → `references/bp-api-rest.md`
- Practices every stack shares → `references/bp-code.md`

## Sources

- [Angular — Built-in control flow](https://angular.dev/guide/templates/control-flow)
- [Angular — Signals](https://angular.dev/guide/signals)
- [Angular — takeUntilDestroyed](https://angular.dev/api/core/rxjs-interop/takeUntilDestroyed)
