# Concurrency and Thread Safety Rules

- Assume shared mutable state is dangerous until proven otherwise.
- Use explicit concurrency-safe primitives and collections, such as `ConcurrentHashMap`, `CopyOnWriteArrayList`, `BlockingQueue`, `threading.Lock`, `asyncio.Lock`, channels, or language-equivalent constructs.
- Document the synchronization model when state is shared across threads, tasks, workers, or callbacks. Make ownership and lifetime of shared state explicit.
- Acquire multiple locks only in a documented global order.
- Prefer bounded acquisition (`tryLock`, timeout-based acquire, or equivalent) where blocking indefinitely could stall the system.
- Never perform network I/O, disk I/O, waits, or CPU-heavy work while holding a lock.
- Prefer immutable handoff, message passing, or snapshot copies over long-lived shared mutation.
- Background tasks and async operations must define explicit cancellation behavior. Respect cancellation signals promptly; do not silently discard them.
- Do not mix concurrency models (for example, raw threads with asyncio, or executor futures with coroutines) without explicit justification and clearly documented ownership boundaries.
- When a background task owns a timer, retry scheduler, or delayed callback, document who is responsible for cancelling it, what happens if the owning component shuts down before the timer fires, and whether the scheduled action survives a restart. A timer that outlives its owner is a common source of ghost actions — side effects that fire after the state that justified them has already been torn down.
- Add concurrency-focused tests when the change introduces shared state, async flows, retries, timers, or callbacks.

## Structured concurrency

Structured concurrency is the principle that subtasks must not outlive their parent scope. When a function spawns concurrent work, that work must complete — or be cancelled — before the function returns. Unstructured concurrency — fire-and-forget goroutines, detached tasks, background threads with no join — is the primary source of goroutine and thread leaks, silent background work after request completion, and error loss from orphaned workers.

- Every unit of concurrent work must be owned by a parent scope that is responsible for waiting on it, collecting its errors, and cancelling it on failure or timeout. Child work must not outlive the parent scope that created it.
- When a subtask fails, the parent scope must propagate the error or make an explicit decision to ignore it. Swallowing subtask errors silently is not acceptable — it is the concurrency equivalent of `except: pass`.
- Prefer structured concurrency primitives where the language provides them: Go `errgroup`, Python `asyncio.TaskGroup` (3.11+), Java `StructuredTaskScope` (21+), Kotlin `coroutineScope`, Swift `TaskGroup`. These enforce the parent-child lifetime contract at the API level.
- When unstructured concurrency is genuinely necessary — long-running background workers, daemon tasks, process-wide services — document it explicitly: what is the task, who owns its lifecycle, how is it cancelled, and what prevents it from outliving its intended scope. Unstructured concurrency without this documentation is a maintenance hazard.
- AI agents commonly generate unstructured goroutines and fire-and-forget tasks because they satisfy the immediate functional requirement without exposing the leak. Treat any spawned concurrent work that has no explicit join, cancel, or ownership documentation as a review flag.

## Cancellation contracts

Cancellation is a design contract, not an afterthought. A task that cannot be cancelled safely is a resource that cannot be reclaimed, a test that cannot be timed out, and a shutdown that cannot complete in bounded time.

- Every long-running or blocking operation must define cancellation checkpoints: where in the execution flow will the task check for a cancellation signal and stop? At minimum: before each I/O call, before each significant computation, and at the top of each loop iteration.
- Define the cleanup contract before cancellation happens, not after. When cancellation arrives mid-operation, the task must know whether to: roll back partial state and exit cleanly, commit what was completed and stop before the next unit, or release held resources and propagate the cancellation upward. All three are valid; none of them is the default — the choice must be explicit.
- Use language-native cancellation mechanisms consistently: Go `ctx.Done()` and `ctx.Err()` in every blocking select; Python `asyncio.CancelledError` caught only to clean up, then re-raised; Java `Thread.interrupted()` flag checked in loops and before blocking calls. Do not implement a parallel cancellation mechanism when the language provides one.
- A cancelled operation must release all resources it holds — locks, file handles, network connections, database transactions — before exiting. A cancellation that leaks resources is worse than no cancellation handling at all.

## Lightweight threads and carrier-thread discipline

Lightweight concurrency primitives — Go goroutines, Java virtual threads (Project Loom), Python asyncio tasks — lower the cost of concurrency but do not eliminate blocking hazards. They change where blocking is dangerous, not whether it matters.

- Lightweight threads are still threads from the perspective of the work they perform. Code that blocks a lightweight thread blocks the underlying carrier or event loop for other lightweight threads. The rules on I/O discipline, lock holding, and CPU-heavy work apply equally to lightweight concurrency.
- In Java virtual thread environments: avoid `synchronized` blocks and methods in hot paths. A virtual thread that enters a `synchronized` block is pinned to its carrier thread — it cannot yield, and the carrier is unavailable to other virtual threads until the block exits. Use `ReentrantLock` instead of `synchronized` where virtual thread throughput matters.
- In Go: CGo calls and system calls that do not release the OS thread grow the thread pool and can cause unexpected thread exhaustion under load. In async Python: any blocking call inside a coroutine stalls the event loop for all other coroutines sharing that thread. Identify and isolate blocking calls explicitly using thread pools or async equivalents.
- On cold start or rapid scale-out, lightweight thread runtimes must reach a safe concurrent state before serving traffic. A runtime that is still initializing shared thread-local or carrier-level state when the first requests arrive produces subtle correctness failures that do not reproduce under load. Define and verify the readiness condition before accepting traffic.

## Session state machines and event sequencing

These rules apply to any system where related events for the same logical session, entity, or workflow can arrive across multiple threads, streams, connections, or brokers. Out-of-order delivery is normal, not exceptional, in these environments.

- Never assume that related events arrive in the order they were generated. Multiple network streams, worker threads, or broker partitions can deliver events for the same session in any order. Design for this explicitly.
- For stateful sessions, either serialize all events for a given session key through a single thread or processing slot, or make the state machine explicitly tolerant of reordering with documented handling for each out-of-order case.
- A session may only be created by a valid, recognized initiation event for that protocol or workflow. If a non-initiation message arrives and no session exists, reject or hold it — do not silently create a session in an undefined state using a mid-flow or termination message as the trigger.
- Termination of a session does not always mean immediate hard deletion of session state. When late-arriving messages are expected (due to network reordering or multi-stream delivery), retain a bounded tombstone or grace-period state after termination to absorb them safely. Define the grace period explicitly; do not leave it open-ended.
- Duplicate or replayed events must be handled idempotently at the state machine level. Receiving the same event twice must not create a duplicate session, corrupt state, or trigger duplicate side effects.
- Illegal state transitions must be rejected explicitly with a logged error. Do not silently coerce the state machine into an adjacent valid state. A suppressed illegal transition hides protocol violations and makes post-mortem diagnosis impossible.
- Log each state transition at an operationally retained severity level — or emit it as a structured event to an equivalent stream — including session key, previous state, triggering event, and new state. This produces a complete, reconstructible audit trail without requiring a debugger or replay. In high-volume systems where INFO-level logging per transition would saturate the pipeline, use a dedicated structured event sink or reduce to sampled or DEBUG logging with a periodic summary.

## Atomic state and messaging

- Never send a message, emit an event, or trigger a downstream action before the state change that caused it is durably committed. If the commit fails, the message must not have been sent. The reverse — committing first and then failing to send — is recoverable; the forward case (message sent, commit fails) creates ghost state that is extremely difficult to diagnose and clean up.
- For operations that must update a database and publish an event atomically, use a transactional outbox pattern or equivalent: write the event to a durable outbox table within the same transaction as the state change, then deliver it asynchronously after commit. Do not rely on best-effort dual writes.
- When designing multi-step operations that span a database and a message broker, explicitly define what happens on partial failure at each step. Document the failure modes and recovery path before implementation, not after.
