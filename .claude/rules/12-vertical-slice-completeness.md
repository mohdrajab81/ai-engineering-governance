# Vertical Slice Completeness

When a task adds a contract definition — an API route, an event type, a schema,
a field on a shared data structure, or an interface method — that definition is
not done until every layer that must implement or consume it is also updated and
verified. Contract additions that compile cleanly and pass all tests are still
incomplete if any downstream layer is missing.

Run this checklist before marking any task done if the work touched a public
contract (API spec, interface definition, event schema, shared domain type):

**1. New field on a shared data structure**
Find every place that constructs or copies that structure. Verify the new field
is explicitly set, defaulted, or intentionally omitted with a reason. A field
at its zero value in a constructor is a bug until proven intentional.
In-memory or stub implementations are the most common place this is missed.

**2. New API route or endpoint**
Verify the route is registered in the router. Verify the handler exists.
Verify the response serializer includes all required fields from the schema.
Verify any routing instrumentation (metrics labels, middleware) covers the new
path. A route in the spec with no registration returns a silent 404.

**3. New event type**
Find the emitter — the code that owns the domain transition that triggers this
event. Verify it publishes the new event type with a payload that satisfies all
required fields. If a deprecated event must coexist, see check 6.

**4. New response or message schema**
Find or create the corresponding serialization struct. Verify all required
fields are present with correct names (JSON tags, protobuf field numbers, etc.).
Verify the mapper function populates every required field. For fields that are
conditional on a variant, verify the mapper handles each variant correctly.

**5. New interface method**
Find every implementation of the interface. Verify each implementation has the
method and that its behavior correctly mirrors the contract (filters, defaults,
conflict rules). The compiler catches missing methods; it does not catch methods
that compile but produce wrong results.

**6. Deprecated aliases and coexistence paths**
When a new canonical surface replaces an old one but the old one must survive
for a migration window, both surfaces are part of the contract and both must be
verified. Specifically:

- If a new route replaces a deprecated route, verify the deprecated route still
  exists, still responds correctly per its own spec (including any filtering or
  narrowing the deprecation introduced), and that its response shape has not
  been silently broken by changes made for the new route.
- If a new event type replaces a deprecated event type, verify both are emitted
  from the same call site with correct payloads. Verify the deprecated event
  is only emitted for the subset of cases the contract says it covers.
- If new enum values replace deprecated ones, verify the read path normalises
  old values to new ones, the write path accepts both, and any validation
  error messages reference the canonical new values.

A deprecated surface that silently stops working or changes behaviour during
the migration window is a breaking change, even if it is labelled deprecated.

## How to apply this

For each applicable check, state which check you are running and show the
evidence (grep result, file section, or compiler output) that confirms the
connection exists. Do not rely on "the tests pass" as a substitute — test suites
catch logic errors, not structural gaps between contract layers. Structural gaps
compile cleanly and pass all tests until a runtime caller discovers the missing
piece.

## Why this rule exists

In layered architectures (spec → handler → serializer, or interface →
in-memory impl → SQL impl), it is easy to update one layer and forget the
others. The layers are in different files and sometimes different packages.
Tests mock the boundaries, so the gap is invisible until integration or
production. The cost of a 2-minute checklist is lower than the cost of a review
finding or a runtime 404.
