# Python Language Rules

This file extends the base governance rules with Python-specific guidance. It applies
whenever the repository contains `.py` or `.pyi` files. Activate it according to
`PHASED_ADOPTION.md` — day one for new Python projects, immediately for existing ones.

These rules do not replace the base rules. They add language-specific depth to
01-architecture, 05-security, 06-testing-validation, 09-readability, and
11-ai-agent-verification.

## Type annotations

- Every function signature must have type annotations: parameters and return type.
  Unannotated public functions are a maintenance liability — callers cannot see
  the contract without reading the body.
- Use `Optional[T]` (or `T | None` in Python ≥ 3.10) rather than leaving a
  parameter implicitly nullable.
- Use `Any` only when genuinely necessary and always with a comment explaining
  why the type cannot be narrowed. An unexplained `Any` is a type-safety hole.
- For external input (HTTP bodies, file contents, environment variables, CLI args),
  parse into typed structures at the boundary. Do not pass raw `dict` or `str`
  deep into business logic.

## Boundary validation

- For external input boundaries — HTTP request bodies, file contents,
  environment variables, CLI arguments, and LLM structured outputs — use
  runtime schema validation before the data enters business logic. Static type
  hints alone are not a runtime safety mechanism.
- `pydantic` is the recommended default for Python boundary validation. Use a
  `BaseModel` or equivalent validated settings model for external payloads,
  configuration parsing, and AI-generated structured data so malformed or
  hallucinated fields are rejected or normalized at the boundary.
- `@dataclass`, `TypedDict`, and plain annotated `dict` objects do not perform
  runtime validation by themselves. They are appropriate for trusted internal
  data structures after validation, not as the primary guard at an untrusted
  boundary.

## Immutability and data structures

- Prefer immutable data transfer objects. Use `@dataclass(frozen=True)` or
  `NamedTuple` for objects that represent values passed between layers.
- Do not use a plain mutable `dict` as a domain object. A dict has no schema,
  no type contract, and no invariants. Define a dataclass or TypedDict instead.
- For configuration objects that must be initialized once and read many times,
  frozen dataclasses prevent accidental mutation across the call stack.

## Formatting and linting

The following tools are mandatory on every Python project. Configure them in
`pyproject.toml` or equivalent and run them in CI:

| Tool | Purpose | Command |
| --- | --- | --- |
| `black` | Code formatting | `black --check .` |
| `isort` | Import ordering | `isort --check .` |
| `ruff` | Linting (fast, replaces flake8/pylint for most checks) | `ruff check .` |
| `mypy` or `pyright` | Static type checking | `mypy src/` |

- Do not disable a linter rule globally unless there is a documented reason and
  a team decision behind it. A blanket `# noqa` or `# type: ignore` with no
  comment is not acceptable.
- Formatter output is authoritative. Do not argue with `black` formatting — configure
  `black` instead if the defaults are wrong for the project.

## Logging

- Use the `logging` module. Never use `print()` for diagnostic output in production
  code. `print()` bypasses log levels, formatters, and handlers.
- Configure a logger per module: `logger = logging.getLogger(__name__)`. Do not
  use the root logger directly in library code — it pollutes every consumer's
  log output.
- Follow Rule 04 (observability): structured logs, correlation keys, no raw secrets
  or sensitive payload content.

## Security

- Use `python-dotenv` or an equivalent mechanism to load secrets from environment
  variables. Never hardcode API keys, passwords, or tokens in source files.
- Validate that required secrets are present at startup. Fail fast with a clear
  message rather than failing silently on first use.
- Run `bandit -r src/` as part of CI to catch common Python security issues:
  shell injection, insecure random, weak crypto, hardcoded passwords.
- For dependency auditing, run `pip-audit` or `safety check` in CI to surface
  known vulnerabilities in installed packages.
- Never use `eval()`, `exec()`, or `pickle.loads()` on untrusted input.
  These are remote code execution vectors.
- Use parameterized queries for all database access. Never build SQL by
  string concatenation.

## Testing

- Use `pytest` as the testing framework. Do not mix `unittest` and `pytest`
  in the same project without a documented reason.
- Mark tests by layer using pytest markers:

  ```python
  @pytest.mark.unit          # fast, no I/O, no external services
  @pytest.mark.integration   # real dependencies (DB, broker, filesystem)
  @pytest.mark.e2e           # full stack, requires running services
  ```

- Run unit tests in isolation: `pytest -m unit`. Never let a unit test make
  a real network call or touch a real database.
- Use `pytest-cov` to measure coverage: `pytest --cov=src --cov-report=term-missing`.
  A coverage report is not a goal in itself — treat uncovered critical paths as
  a risk signal, not a metric to optimize.
- Use `pytest-asyncio` for async code. Mark async tests with `@pytest.mark.asyncio`
  and configure the event loop scope explicitly to avoid fixture ordering surprises.
- Fixtures that set up expensive resources (database connections, test servers)
  belong at `session` or `module` scope. Per-test setup for expensive resources
  is a performance anti-pattern.

## AI-generated Python code: known failure modes

These patterns are disproportionately common in AI-generated Python code. Reviewers should check for them explicitly — they produce code that passes basic tests but fails silently under real conditions.

- **`except Exception: pass` error suppression.** When an AI agent encounters an error path that complicates the surrounding generation goal, it commonly wraps the block in a bare `except Exception: pass` or `except Exception: return None`. The happy path works; every failure mode is silently discarded. Any bare except with no logging, no re-raise, and no explicit handling is a review flag.

- **Fire-and-forget `asyncio.create_task()`.** AI agents commonly generate `asyncio.create_task(some_coroutine())` without storing the returned `Task` reference or awaiting it. Python's garbage collector can collect an unreferenced task before it completes, silently dropping the work. Always store task references and either await them or add them to a set with a `task.add_done_callback(tasks.discard)` pattern.

- **`requests.get()` without `timeout=`.** The `requests` library has no default timeout. An AI agent generates a call without `timeout=` because the function signature does not require it and the test suite never exercises a slow network. In production, a hung upstream service hangs the thread indefinitely. Every `requests` call must have an explicit `timeout=` argument — see Rule 03.

- **Mutable default arguments.** `def fn(items=[])` shares the same list across all calls. AI agents generate this pattern because it looks like a default value. Any mutable object (list, dict, set) as a default argument is a bug — use `None` and initialize inside the function body.

- **Unprotected async generators.** When an async generator streams data over a
  network connection or holds a resource such as a client session, file handle,
  or cursor, client disconnects and task cancellation can raise
  `asyncio.CancelledError` or terminate iteration before cleanup code at the end
  of the function is reached. Wrap resource acquisition in `try/finally` inside
  the generator and release resources in the `finally` block. Do not swallow
  cancellation — clean up and let the cancellation propagate.

## Dependency management

- Pin dependency versions in `pyproject.toml` or `requirements.txt`. Unpinned
  dependencies produce non-reproducible builds.
- Use a lockfile (`poetry.lock`, `pdm.lock`, or `pip-tools`-generated
  `requirements.txt`) and commit it to the repository.
- Before adding a new dependency, verify it is actively maintained, has a
  permissive license compatible with the project, and is available from the
  official package index. See Rule 05 (security) for supply chain requirements.
