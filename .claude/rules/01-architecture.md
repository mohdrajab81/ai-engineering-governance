# Architecture and Design Rules

- Start from the requested outcome, acceptance criteria, and current architecture.
- Perform cross-impact analysis before editing: callers, downstream consumers, config, docs, tests, dashboards, alerts, and rollout implications.
- Preserve backward compatibility by default for APIs, method signatures, data contracts, events, and persisted formats.
- If backward compatibility must be broken, document the migration path, rollout sequence, deprecation window, and rollback plan before making any change.
- Keep business logic out of controllers, transport adapters, and views.
- Prefer the repository's established patterns over new frameworks or abstractions.
- Prefer the simplest design that solves today's problem. Avoid solving for anticipated future requirements that have not been confirmed.
- Extract shared logic only when there is clear reuse or a clear boundary benefit. Do not extract an abstraction until the shared concept is stable and has at least two proven, concrete uses.
- Keep functions focused. If a function becomes hard to explain quickly, split it.
- Keep classes cohesive. If a class owns unrelated responsibilities, separate them.
- Treat design docs and feature specs as part of the implementation surface. Update them when behavior changes.
- Dependencies must flow inward toward domain logic, not outward. Transport adapters, HTTP handlers, database clients, and queue consumers must depend on domain interfaces — not vice versa. When business logic imports from infrastructure layers, the coupling is expensive to remove: tests require real infrastructure, migrations require rewriting logic, and the domain model becomes entangled with delivery mechanism details.
- Architectural constraints that matter to correctness — dependency direction,
  layer boundaries, forbidden imports, and module ownership rules — must be
  enforced by automated checks when the repository defines them, not only stated
  in documentation. A documented boundary with no automated enforcement will
  drift under routine change, and AI-assisted refactors accelerate that drift.
- When a significant architectural decision is made — wire format, database choice, service boundary, key algorithm, auth model — record it immediately as a brief decision note: what was decided, what alternatives were considered, and why this option was chosen. Capture this before or immediately after the decision, not after the system is built. Future AI sessions reading only the code cannot recover the reasoning behind a decision, and will re-derive the same options from scratch without the context that ruled them out.
- Define explicit error propagation contracts at every module and service boundary. A caller must know: which error conditions are transient and retryable, which are permanent and should not be retried, and which indicate caller error (bad input, auth failure) versus system error (dependency unavailable). Without an explicit error boundary contract, every caller implements its own interpretation, producing inconsistent retry behavior, silent swallowing of failures, and error types that leak internal implementation details to external consumers.

## Distributed systems and service decomposition

- Do not introduce microservices or distributed processing unless there is a clear, specific value case that justifies the cost. Every service boundary adds network latency, serialization overhead, an additional failure point, and operational complexity. A well-structured modular monolith is often faster, cheaper to operate, and easier to reason about than a distributed equivalent.
- Before drawing a service boundary, estimate the data volume, call frequency, and latency budget for the communication that will cross that boundary. Data that moved in-process now consumes real network bandwidth and adds measurable round-trip time. Model these costs against your SLA before committing.
- Use observable signals — not instinct or fashion — as the trigger for decomposition. Growing state machine complexity that spans unrelated concerns, persistent ownership confusion between teams, independent scaling requirements that cannot be met in a single process, and accumulating compensating logic are legitimate decomposition signals. Fashionable architecture patterns are not.
- Keep the number of states in a service's state machine at a level where every state can be named and every transition explained without hesitation. When that becomes difficult, the state machine is signalling that the service boundary may be wrong. Treat this as a prompt to re-examine ownership, not as a mandate to immediately split.
- When crossing process or network boundaries, choose the wire format deliberately based on the specific tradeoffs for your context: latency and parse cost, bandwidth, human readability and debuggability, schema evolution needs, and available tooling. Text formats such as JSON are self-describing and easy to inspect but verbose and slow to parse at high throughput. Binary formats such as Protocol Buffers or Avro are compact and fast but require schema management discipline and tooling to inspect.
- Treat wire format and schema evolution strategy as first-class design decisions at the interface level, not incidental implementation details. Once chosen, changing the wire format is a migration, not a refactor. If a binary format is chosen, establish explicit schema versioning discipline before the first message is sent — a schema registry is one valid implementation of this, but the non-negotiable is the versioning discipline itself, not the tooling. Never mix wire formats on the same interface without explicit versioning — a consumer expecting one format receiving another fails in confusing, hard-to-diagnose ways.

## Data ownership and service boundaries

- Each service must own its data exclusively. No two services should read from or write to the same database, schema, or table. A shared database between services is a distributed monolith — it couples deployment, schema evolution, and failure modes across service boundaries without any of the isolation benefits.
- When a data ownership boundary is drawn, define which service is the authoritative source for each entity and record it in the relevant design note. Ambiguous ownership produces conflicting writes, stale reads, and reconciliation logic that grows without bound.
- Local read replicas and caches of another service's data are acceptable for performance, but they must never be treated as authoritative. The owning service's API or event stream is the source of truth; a local copy is a convenience with an explicit staleness budget.

## API contract permanence

- Treat a published API field name, route path, error code, or enum value as permanent once it has external consumers. Renaming is a breaking change even if the semantics are identical. To evolve a field, add the new name alongside the old one, populate both during a migration window, then deprecate the old form — do not rename in place. See `10-config-migrations.md` for the mechanical execution of this pattern.
- Choose the API versioning strategy — URL path segment, request header, content-type negotiation, or query parameter — as a first-class design decision before the first consumer exists. Record it as a decision note. Changing the versioning strategy after consumers depend on it is a migration that affects every client simultaneously.

## AI retrieval and embedding contracts

- Treat embedding model choice, vector dimensionality, chunking strategy, and
  vector index configuration as contract-bearing design decisions when a system
  stores or compares embeddings. These choices define the meaning of persisted
  vectors. Changing them is a migration, not a refactor.
- Do not mix embeddings produced by different models, dimensions, or incompatible
  preprocessing strategies in the same logical index unless the separation is
  explicit in the schema and query path. Similarity scores across incompatible
  vector spaces are semantically invalid even when the storage layer accepts
  them without error.
- When evolving an embedding model or retrieval representation, define the
  migration plan before changing production traffic: how new embeddings will be
  generated, whether old and new indexes will coexist temporarily, how query
  routing will work during transition, and how rollback will be achieved if the
  new representation performs worse.
- Record the retrieval contract in a decision note when the system first ships:
  embedding model, chunking policy, index type, distance metric, and any other
  setting that affects retrieval semantics. A future session reading only code
  and infrastructure cannot infer which of these choices are deliberate and
  compatibility-sensitive.

## Foundation models as volatile external contracts

- Treat foundation models and hosted inference deployments as volatile external
  contracts, not stable internal implementation details. Providers deprecate
  model versions, change behavior behind a family name, alter structured-output
  fidelity, and retire features on timelines outside your control.
- Keep prompt construction, model selection, and response parsing behind an
  explicit application boundary rather than scattering vendor-specific calls
  through business logic. If a model must be replaced, routed differently, or
  temporarily downgraded, the change should occur in one boundary layer — not
  through a repository-wide rewrite of core domain code.
- When a user-facing or correctness-sensitive workflow depends on a specific
  model behavior, record the dependency explicitly: which model or deployment is
  required, what assumptions the prompt/parser makes about its behavior, and
  what fallback or migration path exists if that model is deprecated or its
  output shape drifts.
