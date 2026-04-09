# Go Language Rules

This file extends the base governance rules with Go-specific guidance. It applies
whenever the repository contains `.go`, `go.mod`, or `go.sum` files. Activate it
according to `PHASED_ADOPTION.md` — day one for new Go projects, immediately for
existing ones.

These rules do not replace the base rules. They add language-specific depth to
01-architecture, 02-concurrency, 03-resilience-networking, 05-security,
06-testing-validation, 09-readability, and 11-ai-agent-verification.

## Formatting and static analysis

- `gofmt` and `goimports` are mandatory and non-negotiable. There are no style
  debates in Go — the formatter is the standard. CI must fail on unformatted code.
- Run `go vet ./...` in CI. `go vet` catches a class of real bugs (unreachable
  code, incorrect format strings, suspicious composite literals) that the compiler
  does not reject.
- Run `staticcheck ./...` for extended static analysis beyond `go vet`. It
  catches deprecated API usage, unnecessary type conversions, and common
  correctness issues.
- Run `gosec ./...` for security-focused static analysis. It identifies injection
  risks, weak crypto, file permission issues, and other security-relevant patterns.

## Interface design

- Accept interfaces, return concrete types. Functions should take the narrowest
  interface that satisfies their needs; they should return concrete structs so
  callers have access to the full type.
- Define interfaces at the point of use, not at the point of implementation.
  The consumer owns the interface; the producer owns the struct. This produces
  smaller, more focused interfaces and avoids the Java-style "define an interface
  for every type" pattern.
- Keep interfaces small — typically one to three methods. A large interface is
  a coupling point. If a function needs a large interface, it likely needs to
  be decomposed.

## Error handling

- Always check errors. Never assign to `_` on an error return unless the error
  is genuinely safe to ignore, with a comment explaining why.
- Wrap errors with context using `fmt.Errorf("operation description: %w", err)`.
  Wrapped errors preserve the original error for `errors.Is` and `errors.As`
  inspection further up the call stack.
- Use sentinel errors (`var ErrNotFound = errors.New("not found")`) for
  conditions callers need to inspect and branch on. Do not expose raw string
  errors as part of a public API contract.
- Distinguish between errors that are the caller's fault (invalid input —
  return immediately, no retry) and errors that are environmental (network
  timeout, temporary unavailability — eligible for retry with backoff).
  See Rule 03 (resilience) for retry classification.

## Context and timeouts

- Every function that performs I/O — network, database, filesystem, RPC — must
  accept a `context.Context` as its first parameter.
- Never use `context.Background()` in business logic or request handlers. Derive
  a context with a timeout from the incoming request context:

  ```go
  ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
  defer cancel()
  ```

- Always `defer cancel()` immediately after creating a context with timeout or
  cancellation. Failing to cancel leaks the context goroutine.
- Respect context cancellation in loops and blocking operations. Check
  `ctx.Err()` or select on `ctx.Done()` in long-running loops.

## Concurrency

- Do not share memory between goroutines without explicit synchronization.
  Use channels for communication, `sync.Mutex` or `sync.RWMutex` for protecting
  shared state. Document which lock guards which data.
- Run the race detector in CI: `go test -race ./...`. The race detector has
  negligible false-positive rate for real race conditions. A race-detector
  failure is a real bug.
- Use `sync.WaitGroup` to wait for a known set of goroutines to complete.
  Use `errgroup` when you need to collect errors from concurrent goroutines.
- Goroutines must have a defined lifetime and cancellation path. A goroutine
  that leaks — that is, runs past the point where its work is needed and cannot
  be stopped — is a resource leak. See Rule 02 (concurrency) for the full
  concurrency model requirements.

## Testing

- Use table-driven tests as the default pattern for functions with multiple
  input/output cases:

  ```go
  tests := []struct {
      name  string
      input string
      want  string
  }{
      {"empty input", "", ""},
      {"normal case", "hello", "HELLO"},
  }
  for _, tt := range tests {
      t.Run(tt.name, func(t *testing.T) { ... })
  }
  ```

- Always run tests with the race detector: `go test -race ./...`. Make this
  the default in CI, not an optional step.
- Measure coverage: `go test -cover ./...`. Use `-coverprofile` and `go tool cover`
  to inspect uncovered paths. Coverage is a risk signal, not a target.
- Use `t.Helper()` in test helper functions so that failure messages point to
  the test call site, not the helper internals.
- Avoid `time.Sleep` in tests. It creates flaky tests. Use channels, `sync.WaitGroup`,
  or a test clock abstraction to synchronize test assertions with async behavior.

## Security

- Load secrets from environment variables. Use `os.Getenv()` or an equivalent
  config loader. Never hardcode credentials, tokens, or keys.
- Validate that required configuration is present at startup. Fail fast with a
  descriptive error rather than panicking on first use.
- Use `crypto/rand` for all cryptographic randomness. Never use `math/rand`
  for security-sensitive operations — it is not cryptographically secure.
- Use parameterized queries for all database access. Never build SQL by string
  concatenation.
- When handling HTTP input, validate content-type, enforce body size limits
  using `http.MaxBytesReader`, and reject oversized or malformed payloads
  before they reach business logic.

## AI-generated Go code: known failure modes

These patterns are disproportionately common in AI-generated Go code. Reviewers should check for them explicitly — they produce code that compiles cleanly and passes basic tests but fails at runtime or under load.

- **Swallowed errors.** AI agents commonly assign error returns to `_` when they cannot immediately determine the right error-handling strategy. The result compiles and the happy path works; errors from I/O, type assertions, or channel operations are silently discarded. Treat any `_ =` or `_, _ =` that discards an error return as a review flag unless there is an explicit comment explaining why the error is safe to ignore.

- **Missing `defer cancel()`.** After `context.WithTimeout` or `context.WithCancel`, the `cancel` function must be deferred immediately on the next line. AI agents frequently generate the context creation but omit the defer, leaking the context goroutine for the duration of the parent context. In request handlers this means one leaked goroutine per request.

- **Goroutines without a defined exit path.** AI agents frequently generate `go func() { ... }()` inside loops or handlers without a mechanism to stop the goroutine or wait for it to complete. This produces goroutine leaks that only become visible under sustained load. Every goroutine must have a documented lifetime and a cancellation path — see Rule 02.

- **`interface{}` / `any` as a shortcut.** When an AI agent is uncertain about a type, it defaults to `interface{}` or `any`. This removes type safety and forces callers to use type assertions that can panic. If a type cannot be determined from context, ask — do not paper over it with an empty interface.

## Dependency management

- Use Go modules. Commit `go.sum` to the repository. `go.sum` is the integrity
  record for the module graph and must not be omitted.
- Run `go mod tidy` before committing module changes to keep `go.mod` and
  `go.sum` consistent.
- Audit dependencies using `govulncheck ./...` in CI to surface known
  vulnerabilities in the module graph. See Rule 05 (security) for supply chain
  requirements.
