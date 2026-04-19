# Testing and Validation Rules

- Define the validation plan before coding.
- Translate acceptance criteria into explicit test cases.
- Cover happy path, boundary conditions, error handling, malformed input, and critical regressions.
- Add a regression test for every bug fix when practical. The test should fail before the fix is applied and pass after.
- Add integration tests when behavior crosses module or service boundaries.
- Add contract tests when the change touches a published API, event schema, or shared data contract. Verify that producers and consumers remain compatible.
- For systems with multiple validation layers, define the ladder explicitly: unit, integration with real dependencies, fake transport or test doubles, live simulator, multi-instance, failover, or other higher-confidence layers as applicable.
- Validate at the lowest cost layer first, but do not stop there when the changed risk exists at a higher layer.
- For event-driven or stateful session systems, add replay-and-recovery tests covering: duplicate event delivery, out-of-order event arrival, late events arriving after session termination, and restart-after-partial-commit sequences. These scenarios do not occur in happy-path tests but are exactly the conditions that cause ghost sessions, corrupted state, and data loss in production.
- When using a new function, method, SDK call, or API, review relevant overloads, optional parameters, and defaults. Record why the chosen option set was used and why other relevant options were not.
- Tests must be deterministic and hermetic. Unit tests must not depend on timing, network access, external services, or shared mutable state between runs. Mock external dependencies, fix random seeds, and use controlled clocks where the code under test depends on time.
- Do not modify or delete tests to make them pass unless the tested behavior intentionally changed. If tests are removed, document why in the commit message.
- Prefer file-scoped or targeted checks first for fast feedback, then run broader checks before finishing.
- Never claim success from compilation alone. Run the relevant tests and inspect the results.
- When reporting validation results, state: the exact command run, the scope covered (package, module, or full suite), the outcome (pass count, fail count, skip count), and any gap (what could not be validated and why). "Tests pass" with no supporting detail is not an acceptable validation report.
- If the only way to verify behavior is in a live or integration environment that is unavailable during the session, state explicitly that the implementation is ready but the task is not fully verified, and describe what environment and conditions are required to complete verification. Do not close the task.
- Review AI-generated tests for assertion quality, not only for compilation,
  pass rate, or line coverage. A generated test that asserts nothing
  meaningful, only mirrors the implementation, or encodes an invented
  expectation creates false confidence instead of validation.
- When a production incident, customer escalation, or post-deployment bug
  reveals a test gap, add a regression test that captures the failure mode
  before closing the issue when practical. Production failures are evidence
  that the pre-deployment suite missed a real condition; the suite must be
  strengthened, not only the code patched.

## Validating AI-integrated components

- Distinguish deterministic artifacts from nondeterministic generation when
  designing tests for AI-integrated systems. Schema-conformant JSON outputs,
  tool-call envelopes, routing decisions, and other structured control signals
  should use exact assertions. Free-form natural-language generation usually
  should not.
- Do not force exact-string assertions onto nondeterministic model output unless
  the system is explicitly configured to make that output deterministic. Brittle
  exact-match tests on free-form generation create flaky suites that fail
  without a meaningful regression.
- When validating free-form generation, define an evaluation method that matches
  the risk being tested: rubric-based checks, semantic-similarity thresholds,
  human-reviewed golden answers, or model-assisted evaluation where
  appropriate. Record why that method is sufficient for the specific behavior
  under test.
- Model-assisted evaluation introduces its own bias risk — particularly when the
  evaluator model shares training data, provider lineage, or architectural
  assumptions with the model under test. Validate model-assisted scores against
  human judgment periodically and do not treat them as ground truth.
- For retrieval-augmented generation or ranking systems, maintain a golden
  dataset for retrieval and relevance regression. The goal is to catch
  degradation in retrieval accuracy, ranking quality, grounding, or citation
  coverage even when the final wording varies.
- Keep AI evaluations reproducible enough to compare runs over time. Fix the
  test dataset, prompt template, model version where possible, and scoring
  rubric for a given regression suite. If those inputs change, record the
  change explicitly so a score shift is not misread as a product regression.

## Property-based and fuzz testing

- For parsers, state machines, data validation layers, and other edge-heavy
  components that AI agents commonly get almost right, add property-based or
  fuzz-style tests when the risk justifies them. Fixed examples rarely cover
  the combinatorial boundary conditions where these components actually fail.
- Use property-based testing to express invariants rather than examples: valid
  inputs round-trip without corruption, invalid inputs fail safely, state
  transitions remain legal, and normalization rules are idempotent. A thousand
  randomized cases exercising one invariant often finds defects that dozens of
  hand-written examples miss.
- This is especially important for protocol parsing, schema validation,
  user-controlled text parsing, and session/state transition logic. AI agents
  often generate plausible happy-path handling while hallucinating rare
  edge-case behavior; property-based tests are one of the few practical ways to
  expose those gaps before production.

## Code review severity tiers

When reviewing code or reporting review findings — whether as a human reviewer, an AI agent, or an automated check — classify every finding by severity before reporting it. A review without severity tiers produces a flat list that treats a security hole and a naming preference as equivalent. That makes it harder to decide what blocks a merge.

**CRITICAL — blocks merge.**
The change must not be merged until this is resolved. Examples: security vulnerability (injection, credential exposure, broken auth), broken contract (API, event schema, shared data structure), missing test for a behavior that cannot be verified any other way, data loss or corruption risk, illegal state transition left unhandled.

**HIGH — must fix before merge.**
The change must not be merged until this is resolved. It does not rise to the immediate safety or security level of CRITICAL, but it is a real correctness, reliability, or coverage defect that must be fixed in this change, not deferred. Examples: missing error handling on an external call, a retry path that is not idempotent, a public function with no test coverage, a race condition on shared state, a deprecated dependency with a known vulnerability.

**MEDIUM — fix if feasible in this change.**
Real issue worth resolving, but it does not block the merge if the author acknowledges it and files a follow-up. Examples: duplicated logic that should be extracted, a function that is becoming too long to follow, a log statement missing a correlation key, a test that passes but relies on a flaky timing assumption.

**LOW — optional, style, or preference.**
No functional impact. The reviewer notes it but the author decides whether to act. Examples: naming clarity, comment style, minor structural tidying, a simpler alternative that is equally correct.

**Reporting format:** State the severity tier explicitly for each finding. Do not mix severities in a single bullet. A useful finding looks like: `[HIGH] The retry loop in process_payment() is not idempotent — a double-charge is possible if the network times out after the charge succeeds.`

**Merge gate:** A change with any open CRITICAL or HIGH finding must not be merged. MEDIUM findings do not block merge but must be acknowledged with a tracked follow-up. LOW findings do not block merge.
