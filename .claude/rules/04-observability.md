# Observability and Logging Rules

## Structured logging

- Prefer structured logs over free-text logs when the stack supports it.
- Use consistent severity levels: DEBUG for diagnostics, INFO for
  significant normal events, WARN for degraded but recoverable behavior,
  ERROR for failures that need attention.
- Include correlation metadata on all important logs. For session-based or
  dialogue-based flows, include the same session correlation key in every
  related log entry across threads, async tasks, and service boundaries.
- At minimum, log request/session start, request/session end, external call start, external call end, retry, fallback, timeout, and failure.
- Never log raw secrets, tokens, credentials, connection strings, or sensitive personal data.
- Prefer identifiers and safe summaries over raw payload dumps.
- When logging user or session identifiers, use the repository's approved privacy-safe representation.
- Do not remove, downgrade, or suppress log entries without explicit
  justification. Logs are part of the operational contract; silently
  removing them degrades observability for everyone monitoring the system.

## Wide events and context-rich telemetry

- For operation boundaries where engineers need to answer unknown questions
  after the fact, prefer one context-rich structured event over many
  narrow, fragmented log lines. A single event for "request completed",
  "dispatch decision made", or equivalent boundary outcomes is often more
  investigable than five small logs spread across the code path.
- Build wide events by accumulating fields as the operation progresses,
  then emit once at the boundary where the outcome is known. This preserves
  context without requiring a human to reconstruct the story from
  scattered logs after the incident.
- Wide events complement traces and metrics; they do not replace them.
  Metrics answer "how much" and "how often." Traces answer "where in the
  path." Wide events answer "what exactly was true when this operation
  happened."
- Route high-cardinality investigative fields to wide events or traces
  instead of dropping them entirely. User IDs, request IDs, session keys,
  prompt hashes, and similar fields are often essential for investigation,
  but they belong in event-capable backends - not in low-cardinality
  metric labels.
- Do not emit wide events in hot loops or per-item at very high frequency.
  The value of wide events is rich context at meaningful boundaries, not
  unbounded event volume. Coordinate this with the hot-loop telemetry
  rules below.

## Containerized and cloud-native deployment

- In containerized or cloud-native environments (Docker, Kubernetes, or
  any platform that manages process lifecycle externally), write logs to
  stdout and stderr - not to files. The container runtime or log
  aggregation layer is responsible for collection, rotation, and
  retention. File-based logging in a container bypasses the platform's log
  pipeline, creates disk-space risk in ephemeral filesystems, and loses
  logs when a container is replaced.
- The log-file rotation and buffer-flush rules elsewhere in this file
  apply to deployments where the process owns its log files directly
  (bare-metal, VM, on-premises). In containerized deployments, those
  concerns move to the platform layer. Know which model your deployment
  uses and apply the correct rules - do not mix them.
- Structured log format (JSON or equivalent) remains mandatory regardless of deployment model. Writing to stdout is not a license for free-text output.

## Metrics

- Emit metrics for latency, error rate, throughput, and queue or resource saturation on critical code paths.
- Prefer counters, gauges, and histograms over derived log-scraping where the platform supports it.
- Name metrics consistently. Follow the repository's or platform's metric naming convention so dashboards and alerts remain coherent.
- In time-series metric backends, do not emit high-cardinality label
  values (such as raw user IDs or request IDs) as metric dimensions. High
  cardinality destroys query performance and storage efficiency in systems
  such as Prometheus. See the cardinality-management section below for how
  to route high-cardinality context to the right telemetry signal instead
  of dropping it entirely.

## Distributed traces

- Instrument major request flows and external dependency calls with spans. Include timing, status, and error information per span.
- Propagate trace context (trace ID, span ID) across service boundaries,
  thread handoffs, and async task submissions so logs, metrics, and traces
  can be correlated for the same request.
- For high-volume workloads, define a sampling rate before enabling tracing in production. Head-based sampling is simpler; tail-based sampling gives better coverage of errors and slow requests.
- Apply data redaction rules to span attributes and log fields that could carry sensitive data before spans are exported.

## Continuous profiling

- Treat continuous profiling as the fourth observability signal alongside
  logs, metrics, and traces when the platform supports it. Metrics tell
  you what changed, traces tell you where latency accumulated, and
  profiles tell you which functions consumed CPU, memory, or lock time.
- Continuous profiling in production must have an explicit overhead
  budget. A 1-5% CPU overhead is a reasonable starting range; if the
  profiler exceeds the agreed budget, reconfigure or disable it rather
  than treating the overhead as invisible.
- Correlate profiles with traces when the tooling supports shared
  `trace_id` or `span_id`. A slow trace without profile correlation tells
  you the path but not the code-level cause.
- Use profile comparisons as a deployment-regression tool. Compare flame
  graphs or equivalent profile views before and after significant releases
  to detect unexpected CPU growth, lock contention, allocator pressure, or
  blocking introduced by the change.
- Treat profile data as sensitive operational data. Function names, file
  paths, and symbols can reveal internal architecture or business logic.
  Apply the same export and retention controls you would apply to other
  internal telemetry.

## AI and GenAI operation observability

- For every LLM invocation, emit at minimum: model name, request outcome,
  latency, input token count, output token count, and total token count or
  cost-equivalent usage when available. An LLM call without token
  accounting is an unmonitored cost center and a capacity blind spot.
- In agentic pipelines, represent the agent execution tree in traces:
  parent span for the user-visible task, child spans for tool calls,
  retrieval steps, sub-agents, and model invocations. A multi-agent
  workflow without per-agent spans is a black box during incident
  investigation.
- Instrument retrieval-augmented generation steps explicitly: retrieval
  latency, number of retrieved items, retrieval source, and whether the
  retrieval result was empty, partial, or filtered. A bad answer may be a
  retrieval failure rather than a model failure.
- Apply redaction rules to prompts, completions, retrieved content, and
  tool arguments before they enter logs, spans, or event stores. Prompt
  and completion text frequently contain secrets, customer data, or
  regulated information. Rule 11's untrusted-input guidance and Rule 05's
  data-handling guidance still apply here.
- Treat token usage as both a cost metric and an operational metric. Alert
  on abnormal token growth, request fan-out in agent chains, and sudden
  changes in model mix. A token spike is often the first signal of prompt
  drift, retrieval failure, or runaway agent behavior.

## Cardinality management

- Cardinality rules are backend-specific. Time-series metric backends
  require strict low-cardinality labels. Event-capable backends can derive
  value from high-cardinality fields. Trace systems tolerate moderate
  cardinality but still require discipline. Do not apply one backend's
  limits blindly to every telemetry signal.
- Route low-cardinality aggregates to metrics: request rate, status class,
  dependency name, queue depth, saturation level. Route high-cardinality
  investigative context to wide events or traces: request ID, tenant ID,
  user ID, session key, prompt hash, document ID, or correlation token.
- Make the routing decision explicit when adding a new field: is this
  dimension primarily for alerting, trend analysis, trace correlation, or
  post-incident investigation? Put it in the signal that matches that use
  case instead of copying it everywhere.
- If a field is too expensive for the metric backend but too important to
  drop, preserve it in wide events or trace attributes and keep a
  lower-cardinality aggregate in metrics. "Do not emit as a metric label"
  is not the same as "do not capture at all."

## Alerting and SLO intent

- For each user-facing operation, define at minimum an intent-level SLO: acceptable p99 latency, acceptable error rate, and the alert condition that triggers investigation.
- Implement burn-rate alerts tied to your error budget. A fast burn rate — consuming the error budget significantly faster than the SLO window allows — should trigger an immediate page. A slow burn rate should create a ticket for investigation before the budget is exhausted. Alerting only on raw error rate without burn-rate context produces either too many alerts or alerts that arrive too late.
- If a service's error budget is exhausted — meaning the cumulative error rate has exceeded the SLO threshold for the measurement window — halt non-essential feature releases for that service until reliability is restored. Shipping new features into a degraded service compounds risk and delays recovery.
- Alerts should fire on symptoms (elevated error rate, latency breach, queue growth) rather than on causes alone (CPU spike, disk usage). Cause-level alerts are supplementary.
- Keep alert thresholds and SLO targets in version-controlled configuration alongside the code they monitor.

## Telemetry volume, buffering, and rotation

### Hot loops and high-frequency paths

- Do not emit INFO or higher severity log entries inside tight or high-frequency loops. Each log write is an I/O operation; at high iteration rates it saturates the logging pipeline, adds measurable latency to the hot path, and can block processing threads.
- In high-frequency loops, prefer one of: DEBUG level only, a sampled log every N iterations with a counter included in the message, or a periodic summary log that aggregates what happened over a time window.
- Apply the same discipline to distributed traces. Do not create a span per iteration in a hot loop unless there is an explicit diagnostic reason. A span-per-iteration at high throughput overwhelms the tracing backend and destroys the signal-to-noise ratio.
- The acceptable telemetry volume at a given code path is a conscious design decision, not a default. Make it explicit.

### Log file rotation and buffered flushing

- Log files must rotate on explicit, configured size or time policies. Never allow log files to grow without bound; unbounded log files exhaust disk space silently and make post-mortem analysis harder.
- Flush policy must be explicit and configurable per environment. Buffered or chunked flushing is acceptable and often correct for high-volume or debug-mode scenarios — the I/O reduction is worth the tradeoff in most cases.
- The accepted risk of buffered flushing is that data in an unflushed buffer is lost at crash time. This tradeoff must be a documented, conscious decision — not an accidental default. In crash-investigation or audit scenarios, reduce the flush interval rather than disabling buffering entirely.
- During log file rotation, the transition from old file handle to new file handle must be atomic with respect to buffered data. Define and implement explicitly what happens to data buffered against the old handle at the moment of rotation: flush-then-rotate, or accept bounded loss. Never silently drop or duplicate log entries at the rotation boundary.
- Correlation fields — session ID, trace ID, request ID — must survive buffering and rotation intact. A log entry written before rotation and flushed after must carry the same correlation metadata it would have carried if flushed immediately. Loss of correlation at rotation boundaries breaks post-mortem session reconstruction.
- At shutdown, always flush and close log buffers explicitly before process exit, regardless of the configured flush interval. An abrupt exit with an unflushed buffer loses the last events before shutdown, which are often the most diagnostically valuable.

### Resource handle transitions

- The rotation discipline above applies to any stateful I/O resource, not just log files. Before closing or replacing a file handle, socket, queue consumer, database connection, or any resource that may hold buffered or in-flight data, make an explicit decision about that data. The four valid options are: drain and flush before closing, transfer buffered data to the new resource, discard deliberately with a log entry recording what was lost, or stop accepting new intake first and drain before switching. Silent discard — closing the resource without considering the buffer — is not an option.
- When a service or component transitions a resource mid-operation (reconnect, failover, rotation), its health probe or readiness signal must not report healthy until the new resource is confirmed ready and the transition is complete.

## Streaming and message-broker operational health

These rules apply to any system using Kafka, Pulsar, RabbitMQ, or equivalent message brokers as part of the operational pipeline.

- Treat consumer lag as the primary operational health signal for any consumer group, not just process uptime or CPU. A process that is running but not consuming — or consuming slower than the producer produces — is silently falling behind. Alert on consumer lag growth, not only on consumer absence.
- Choose partition keys deliberately for stateful workloads. A partition key that groups all events for the same session or entity onto the same partition guarantees ordering within that session and enables session affinity in consumer assignment. An arbitrary or hash-random partition key spreads session events across partitions, making ordered processing impossible without external coordination. Changing a partition key strategy after deployment is a breaking change — treat it as one from the start.
- Account for consumer group rebalancing in stateful session handling. During a rebalance, in-flight session state may be mid-processing on a partition that is being reassigned. Design consumer shutdown and partition revocation handlers to flush, checkpoint, or cleanly hand off any in-progress session state before the partition is released. A rebalance that interrupts a mid-session write without a checkpoint creates the same ghost-state failure mode as a mid-commit crash.
- Do not commit offsets before processing is confirmed complete for a message batch. Committing offsets eagerly — before downstream writes, state updates, or outbound messages are durable — means a consumer restart will skip those messages silently. Late offset commit after confirmed processing is the correct default; early commit optimizes throughput at the cost of correctness.
