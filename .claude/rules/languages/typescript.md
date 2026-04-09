# TypeScript Language Rules

This file covers TypeScript projects primarily. Several sections also apply to plain
JavaScript projects (`.js`, `.jsx`); those are marked **[TS + JS]**. Sections that
reference TypeScript-specific constructs — `interface`, `type`, `unknown`, `@ts-expect-error`,
`z.infer`, type assertions — are **[TS only]** and do not apply to plain JavaScript.

Activate according to `PHASED_ADOPTION.md`:

- TypeScript project (`.ts`, `.tsx`): apply all sections.
- Plain JavaScript project (`.js`, `.jsx`): apply only sections marked **[TS + JS]**.

These rules do not replace the base rules. They add language-specific depth to
01-architecture, 05-security, 06-testing-validation, 09-readability, and
11-ai-agent-verification.

## Type safety [TS only]

- Never use `any` unless it is genuinely unavoidable and accompanied by a comment
  explaining why. An unexplained `any` disables type checking at that point and
  silently propagates through callers.
- For external input — HTTP request bodies, API responses, environment variables,
  user-supplied data — use `unknown` instead of `any`. `unknown` forces explicit
  narrowing before the value can be used; `any` does not.
- Use `interface` for extensible object shapes (types that may be implemented or
  extended elsewhere). Use `type` for unions, intersections, mapped types, and
  utility compositions.
- Avoid non-null assertion (`!`) on values that could legitimately be null or
  undefined. A `!` that turns out to be wrong throws at runtime with no warning
  at compile time. Use optional chaining (`?.`) and explicit null checks instead.
- Use `as T` type assertions only when you have verified the shape from an external
  source and cannot express the proof to the type system. Add a comment explaining
  the verification. An unverified cast is a runtime error waiting to happen.

## Boundary validation [TS + JS]

- Validate all external input at system boundaries using a schema library.
  `zod` is the recommended default: it validates at runtime and produces clear
  error messages. It works in both TypeScript and JavaScript.
- **[TS only]** Infer TypeScript types from the schema definition:
  `type MyType = z.infer<typeof MySchema>`. Do not maintain a parallel manual
  type and a schema that can drift apart.
- Never trust data from HTTP request bodies, query strings, file contents, or
  external API responses without schema validation. Parse, do not cast.

## Immutability [TS + JS]

- Use `const` by default. Use `let` only when reassignment is required.
  Never use `var`.
- For objects and arrays that should not be mutated after creation, use
  `Object.freeze()` (TS + JS) or — in TypeScript — `Readonly<T>` /
  `ReadonlyArray<T>` at the type level to enforce immutability statically.
- When updating state, use spread syntax to produce new values:
  `{ ...existing, field: newValue }`. Do not mutate objects in place unless
  there is a documented performance reason and the mutation is locally contained.

## Async and error handling [TS + JS]

- Use `async/await` over raw `.then()/.catch()` chains. Async/await produces
  linear, readable error flow that is easier to reason about and easier to annotate
  with types.
- In `catch` blocks, treat the caught value as `unknown`. Narrow it explicitly
  before accessing properties:

  ```typescript
  catch (err) {
    const message = err instanceof Error ? err.message : String(err);
  }
  ```

  In TypeScript, never write `catch (err: any)` — it defeats the type system
  at the point where type information is most needed. In plain JavaScript,
  the variable is untyped by definition; apply the same narrowing logic
  without the type annotation.

## Logging [TS + JS]

- Do not use `console.log`, `console.warn`, or `console.error` in production code.
  Use a structured logging library (e.g., `pino`, `winston`) that respects log
  levels, formats output consistently, and supports correlation keys.
- `console.*` is acceptable in scripts, CLI tools, and test output where no
  log infrastructure is available. It is not acceptable in application code
  that runs in production.

## Security [TS + JS]

- Store all secrets in environment variables. Never hardcode API keys, tokens,
  or passwords in source files or configuration files committed to the repository.
- Validate that required environment variables are present at startup. Use a
  validation schema (e.g., `zod` against `process.env`) so missing or malformed
  config fails fast with a clear error.
- Sanitize HTML output. If the application renders user-supplied content into the
  DOM, use a library like `DOMPurify` or framework-provided escaping. Never
  inject raw user strings into `innerHTML` or equivalent.
- For HTTP APIs, enforce input length limits and reject oversized payloads before
  they reach business logic.
- Run a dependency audit in CI: `npm audit` or `yarn audit`. Treat HIGH and CRITICAL
  findings as build failures. See Rule 05 (security) for supply chain requirements.

## Testing [TS + JS]

- For unit and integration testing, use `vitest` (preferred for modern projects)
  or `jest`.
- For end-to-end testing of browser-based applications, use `Playwright`.
  Playwright covers multiple browsers, has a stable async API, and integrates
  with CI without a display server.
- Structure tests with Arrange-Act-Assert. Descriptive test names should read as
  specifications: `"returns 401 when token is expired"` rather than `"test auth"`.
- Do not test implementation details. Test observable behavior: inputs, outputs,
  and side effects visible to callers. Tests coupled to internal structure break
  on refactoring without catching real regressions.
- Mock at system boundaries (HTTP, database, filesystem), not at arbitrary internal
  points. An integration test that mocks the database client is testing nothing
  real.
- **[TS only]** Use `@ts-expect-error` (not `@ts-ignore`) when a test intentionally
  passes a wrong type. `@ts-expect-error` fails the build if the error disappears,
  which is the signal you want.

## Dependency management

- Pin exact versions in `package.json` for production dependencies, or use a
  lockfile (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`) and commit it.
- Do not accept automatic major-version upgrades. Review the changelog before
  upgrading any production dependency.
- Before adding a new package, verify it is actively maintained and its transitive
  dependency tree does not introduce vulnerabilities. Run `npm audit` after
  adding any new dependency.
