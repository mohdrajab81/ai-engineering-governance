# Slice Exit Evidence

When a repository uses named phases, slices, milestones, or tracks, do not mark
one of those units complete based only on compilation, local tests, or an
implementation summary. A slice is complete only when every declared deliverable
for that slice exists in the tree, is wired into the relevant runtime path, and
has explicit validation evidence.

This rule is local to repositories that use planned implementation slices. It
operationalizes the general vertical-slice completeness rule for phase-driven
work.

## When this rule applies

Use this rule whenever work is described in terms such as:

- "Slice 3 is complete"
- "Phase 11 store work is done"
- "Track A can be closed"

## Required closure checks

Before declaring a slice complete, verify all of the following:

### 1. Deliverable existence

List each deliverable named in the plan or design doc and show the exact file,
directory, route, schema, fixture set, migration, or package that now exists.

If the slice promised a directory or corpus:

- verify the path exists
- verify it is not empty
- verify any required manifest or index file exists

An empty directory does not satisfy a promised deliverable.

Documentation artifacts are deliverables. If the slice promised or required an
API spec update, schema reference update, ADR entry, design note, or runbook
change, those are deliverables subject to the same existence check as code
artifacts. For cross-layer contract completeness checks within a slice, apply
Rule 12 (`12-vertical-slice-completeness`).

### 2. Contract-to-implementation alignment

If the slice changed a contract, verify the implementation boundary can express
the intended semantics completely.

Examples of incomplete closure:

- a field is overloaded to carry two different meanings
- a mode from the design doc has no field in the request type
- a response type advertises fields that the decoder or mapper never populates

Compiling code is not enough if the type boundary cannot represent the slice's
required behavior honestly.

### 3. Runtime wiring

If the slice promised behavior, verify the new code is reachable from the real
call path, not only from isolated unit tests.

Examples:

- route is registered, not only implemented
- event is emitted, not only defined
- worker/store/transport method is called from the owning path
- fixtures are actually consumed by tests, not only checked in

### 4. Evidence-backed validation

For each deliverable, record the validation that proves it works:

- exact command
- exact scope
- result
- remaining gaps (what could not be validated and why)

If validation was partial, say so explicitly. If the remaining gap is material —
behavior not verified, deliverable not confirmed, runtime path not checked — the
slice is not complete. Do not call it complete and note the gap as a follow-up;
an unverified deliverable is an open deliverable.

Good examples:

- package tests passed
- contract validator passed
- fixture-driven test suite passed
- repository-wide test timed out after N seconds

Bad examples:

- "build clean"
- "tests pass"
- "slice complete"

without any supporting evidence.

### 5. Claimed vs actual tree check

Before any completion statement, compare the summary against the actual tree.

If the summary says a deliverable exists, verify it directly from the working
tree. Do not infer existence from intent, partial implementation, or a passing
unit-test package.

## Required completion note format

When reporting slice completion, include a short evidence block:

```text
Slice closure check:
- Deliverables claimed:
- Paths verified:
- Validation run:
- Remaining gaps:
```

If any remaining gap is non-empty, do not call the slice complete.
