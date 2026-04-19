# Resilience and Networking Rules

- Put an explicit timeout on every external dependency call: HTTP, database, cache, queue, filesystem, RPC, TCP socket, websocket handshake, or third-party SDK.
- For multi-step or chained external calls, define an end-to-end deadline budget. Per-call timeouts alone do not prevent total latency overruns when calls are composed.
- Classify failure mode before adding retry logic.
- Retry only transient failures such as timeout, connection reset, temporary unavailability, or rate limiting.
- Use exponential backoff with a bounded retry count. Add jitter for distributed callers when appropriate.
- Define retry ownership explicitly at each layer. When a dependency is called through multiple layers — SDK, transport, business logic — ensure only one layer retries. Stacked retries at every layer multiply load on a struggling dependency and make total retry count and latency non-deterministic.
- Do not retry validation failures, auth failures, programmer errors, or business-rule failures.
- When multiple distributed clients may retry the same dependency simultaneously, cap the total retry pressure to prevent retry storms under sustained failure.
- Implement a circuit breaker for dependencies that experience sustained failures. When a dependency is unresponsive or error-rate exceeds a defined threshold, stop sending requests rather than continuing to retry. Allow periodic probe requests to detect recovery. A circuit breaker protects both the caller and the struggling dependency.
- Isolate thread pools or execution slots per downstream dependency. Without bulkhead isolation, a single slow or failing dependency can exhaust all available threads in a high-concurrency process — cascading the failure to every other dependency that shares the same pool, even healthy ones. Assign each critical external dependency its own bounded thread pool or semaphore so that one dependency's failure cannot propagate to the others.
- When a downstream dependency signals overload across a network boundary, propagate that signal upstream — do not absorb it silently into an unbounded buffer and continue. An HTTP 429 response must cause the caller to slow intake or apply backpressure to its own callers, not just retry after a delay. A Kafka consumer receiving sustained lag pressure should pause partition consumption rather than accumulate a growing backlog. A gRPC client receiving flow-control signals must respect them rather than queue requests against a stalled stream. Absorbing overload signals silently converts a recoverable downstream overload into an upstream OOM or thread-exhaustion cascade. (For backpressure between in-process pipeline stages, see `07-performance-resources`.)
- Prefer idempotent operations for retried flows. If the operation is not idempotent, design a guard.
- Reuse connections and clients through pooling or persistent sessions when supported by the platform.
- Think about bandwidth and payload size. Prefer batching, compression, pagination, delta updates, and streaming when appropriate.
- Record retry attempts, timeout events, fallback activation, and circuit-breaker-style decisions in logs and telemetry.
- Timeouts must be visible in metrics, not only in logs. A timeout that only appears in a log entry is invisible to dashboards, burn-rate alerts, and trend analysis. Emit a counter or histogram for timeout events on each dependency so that timeout rate trends are detectable before they escalate to incidents.
- Define the fallback behavior for each dependency before it is needed, not during an outage. When a circuit opens or a timeout fires, the system must have a pre-defined response: fail fast with a structured error, return a stale cached value, return a degraded response with reduced functionality, or reject intake at the boundary. An undefined fallback means every partial failure triggers an improvised response under pressure — which is when improvisation is most dangerous.
- Distinguish readiness from liveness in health check endpoints. A liveness probe confirms the process is alive and should not be restarted. A readiness probe confirms the service can accept traffic — required dependencies are reachable and initialization is complete. A service that reports ready before its dependencies are available causes cascading failures during deployment and restart. These are different signals; conflating them hides the actual failure mode from the orchestrator.

## Token-budget-aware AI dependency resilience

- For AI model providers and token-metered inference services, distinguish
  request-rate limits from token-budget limits. A dependency may accept only a
  small number of requests per second, a bounded number of tokens per minute,
  or both. A single oversized prompt can exhaust the token budget while
  consuming only one request slot.
- Track token consumption as a first-class resilience signal alongside request
  counts, latency, and error rate. If the provider exposes token-usage headers,
  quotas, or remaining-budget metadata, record and alert on them. If it does
  not, estimate token usage at the caller and expose the estimate as telemetry.
- When an AI dependency returns overload or quota errors, identify whether the
  saturation is driven by request count, token volume, or concurrency. The
  mitigation differs: a request-count cap may call for slower intake; a token
  budget cap may require prompt-size reduction, admission control, batching, or
  deferral of large requests.
- Define the fallback behavior for token-budget exhaustion before production
  use: fail fast with a structured quota error, downgrade to a smaller or less
  capable model where correctness requirements permit, reject large prompts
  first, defer non-critical traffic, or other explicit behavior that matches
  the system's correctness requirements. Do not improvise quota handling during
  an incident.

## Retry budgets and retry amplification

The existing rule to cap total retry pressure requires a mechanism to make it operational. A retry budget is that mechanism: a token-bucket or rate-limit on outgoing retries expressed as a fraction of normal request volume.

- Size the retry budget at 10–20% of normal outbound request rate for the dependency as a starting point. A higher budget masks a dependency that is genuinely failing rather than transiently slow. A lower budget may leave legitimate transient failures unretried. Calibrate against your dependency's error-rate baseline and adjust from there.
- Understand retry amplification before layering retries. If a request passes through N layers each retrying M times, the dependency receives up to M^N requests per original call. Three layers each retrying three times produces 27 requests per original. This is not a theoretical concern — it is the mechanism behind every retry storm. The non-negotiable rule is: only one layer in a call chain retries a given failure. The others propagate the error.
- Document the retry policy for every dependency in the calling service's configuration or design note: which errors are retried, how many times, with what backoff, and which layer owns the retry. An undocumented retry policy is a time bomb during incidents when engineers need to understand total load on a struggling dependency.
- Emit retry-rate metrics per dependency alongside error-rate metrics. A rising retry rate is an early warning signal; it precedes the circuit-breaker threshold and provides earlier intervention opportunity than error rate alone.

## Load shedding

Circuit breakers protect callers from failing dependencies. Backpressure propagates overload signals upstream. Load shedding is the complementary server-side control: the server protects itself from its own callers when it is overloaded.

- Define a load-shedding threshold for each service: the point at which the service begins rejecting requests rather than queuing them. This threshold must be set before deployment, not discovered during an incident. Express it in terms of observable signals: request queue depth, active goroutine/thread count, CPU saturation, or memory pressure.
- Shed load as early and cheaply as possible — before parsing the request body, before acquiring locks, before touching the database. A 503 response sent at the connection-accept or router layer costs a fraction of a request that is accepted and then fails mid-processing. The goal is to protect the healthy capacity, not to process more requests than the service can handle.
- When shedding, prefer priority-aware rejection: reject low-priority or background traffic first, preserve capacity for critical paths. A service that sheds uniformly treats a health check the same as a user-facing transaction. Classify traffic and shed the cheapest-to-drop requests first.
- Emit shed-rate as a first-class metric. A non-zero shed rate is an operational signal that the service is at or near capacity. Alert on sustained shedding; it indicates either a traffic surge, a performance regression, or an infrastructure problem that precedes a more severe failure.
- Load shedding and backpressure are complementary, not alternatives. A server that sheds load must also signal upstream callers to slow down — otherwise the rejected requests are immediately retried, the shed rate stays high, and no capacity is actually recovered.

## Hedged requests for tail latency

**This section applies to high-scale, latency-sensitive, read-dominant systems. It is an advanced technique with specific prerequisites. Do not apply it generally.**

Standard retries address requests that fail. Hedged requests address requests that are slow-but-not-yet-failed — the tail of the latency distribution that retries never touch. The technique: after waiting for the P95 response time, send a second parallel request to a different replica or instance; use whichever responds first and cancel the other.

- Use hedged requests only for idempotent read operations. A hedged write produces two concurrent writes to the same or different replicas — this is a correctness violation, not a performance optimization. Reads with side effects (audit logging, read-increment counters) also do not qualify without explicit idempotency design.
- Set the hedge delay at the P95 latency of the dependency under normal load, not at the timeout. A hedge delay at P95 activates for the top 5% of slow requests and adds at most one extra request per 20. A hedge delay at the timeout adds no value — the slow request has already become an incident.
- Monitor hedge rate continuously. A hedge rate above 5–10% of requests indicates the underlying dependency has a structural latency problem that hedging is masking rather than solving. Investigate the root cause; do not normalize a high hedge rate as acceptable overhead.
- Always cancel the losing request. A hedged request that does not cancel the slower of the two leaves both requests running to completion, doubling load on the dependency for every hedged call. Cancel as soon as the first response is received.

## Graceful degradation planning

The existing rule to pre-define fallback behavior is the entry point. This section makes it a structured discipline rather than a per-incident decision.

- For each external dependency, define its criticality tier before the first deployment: critical (service cannot fulfill its primary function without it), degraded (service can fulfill its primary function with reduced functionality), or cosmetic (service is fully functional without it, output is less rich). The tier determines the fallback contract.
- Critical dependencies: the fallback is fail-fast with a structured error — do not attempt to substitute or approximate. A substituted critical dependency produces incorrect behavior that is harder to diagnose than an explicit failure.
- Degraded dependencies: define the specific reduced functionality that applies when the dependency is unavailable. "Return stale cache" or "omit recommendations section" is a degradation plan. "Handle gracefully" is not.
- Test degradation paths explicitly before they are needed. Inject dependency failures in a staging environment and verify the system behaves according to the degradation plan — not according to what the code was intended to do. Untested degradation paths almost always contain surprises.
- Document the degradation plan in the service's operational runbook. During an incident, engineers should be reading a pre-written plan, not making real-time decisions about what to omit.
