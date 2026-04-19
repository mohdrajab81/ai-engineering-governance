# Assurance and Evidence: API Field Migration (Example)

This is a filled example of `tasks/assurance-evidence-template.md`.
Scenario: rename the `request_id` field on an API response to `correlation_id`
while keeping `request_id` as a deprecated alias for one release window.

Use this to understand what a filled template looks like before writing your own.

---

## Change Summary

- **Title:** Migrate response field `request_id` → `correlation_id`
- **Owner:** Mohammad Rajab
- **Date:** 2026-04-19
- **Status:** In progress — expand phase complete, migrate phase pending
- **Related issue / PR / task:** issue #47 — align response shape with trace context standard

## Risk Trigger

- [x] Breaking or compatibility-sensitive change
- [ ] Schema migration
- [x] API contract change
- [ ] Event schema or message-shape change
- [ ] Configuration key or feature-flag change
- [ ] Destructive action
- [x] Production rollout risk
- [ ] Multi-session continuity risk

## Claim

The expand phase of this migration adds `correlation_id` alongside the existing
`request_id` field. Both fields carry the same value and are populated from the
same source. No consumer receives a response with a missing field. No field is
removed in this change.

## Rule Categories In Scope

- **`CLAUDE.md` non-negotiables:** backward compatibility is the default; breaking
  change is not permitted without a documented migration path, rollout sequence,
  deprecation window, and rollback plan
- **`.claude/rules/08-change-management.md`:** migration plan and rollback path
  required; expand-migrate-contract pattern applies
- **`.claude/rules/10-config-migrations.md`:** treat field names as permanent once
  external consumers exist; expand first, migrate consumers, contract in a later
  separate change
- **`.claude/rules/12-vertical-slice-completeness.md`:** new field on shared
  response struct — every constructor, mapper, test fixture, and serializer must
  be verified
- **`.claude/rules/13-slice-exit-evidence.md`:** expand phase cannot be declared
  complete without deliverable existence check, wiring verification, and
  validation evidence
- **`.claude/rules/14-ai-session-memory.md`:** not applicable — single-session
  change

## Deliverables and Paths

| Deliverable | Path | Exists | Notes |
| --- | --- | --- | --- |
| Updated response struct | `internal/api/response.go` | yes | both fields present |
| Updated response mapper | `internal/api/mapper.go` | yes | populates both fields from trace context |
| Updated OpenAPI spec | `docs/api/openapi.yaml` | yes | `correlation_id` added; `request_id` marked deprecated |
| Updated test fixtures | `testdata/fixtures/response_*.json` | yes | all fixtures include both fields |
| Updated unit tests | `internal/api/mapper_test.go` | yes | asserts both fields are non-empty |
| Contract test | `internal/api/contract_test.go` | yes | verifies both old and new field names simultaneously |
| Deprecation notice in CHANGELOG | `CHANGELOG.md` | yes | documents removal target version |

## Contract and Compatibility Analysis

- **Current contract:** response body includes `request_id` (string, always present)
- **Intended contract after this change:** response body includes both `correlation_id`
  (canonical) and `request_id` (deprecated alias, same value, present until v11.0.0)
- **Compatibility mode during transition:** both fields populated, same value,
  no consumer change required in this phase
- **Expand-migrate-contract phase:** expand (this change); migrate consumers in
  next sprint; contract (remove `request_id`) no earlier than v11.0.0
- **Consumers affected:** two internal services confirmed reading `request_id`;
  one external partner API client identified in partner docs
- **Producers affected:** one — this service's response mapper
- **Deprecated alias or old shape still supported:** yes — `request_id` remains
  in all responses through the migration window
- **Planned removal point:** v11.0.0 (no earlier than 90 days from expand
  phase deployment)

## Rollout and Rollback

- **Deployment strategy:** normal rolling deployment; additive-only change
  makes immediate rollout safe
- **Success criteria:** zero 5xx errors in the 30 minutes following deployment;
  `correlation_id` present in 100% of sampled responses; `request_id` present
  and matching `correlation_id` in 100% of sampled responses
- **Failure threshold:** any 5xx error rate above baseline, or any sampled
  response missing either field
- **Rollback path:** redeploy previous artifact; both fields simply disappear;
  consumers still reading `request_id` are unaffected because the rollback
  restores the original single-field response
- **Rollback tested:** yes — tested against a prior build in staging; `request_id`
  consumers received valid responses after rollback
- **Feature flag:** not applicable; additive field addition does not require a flag

## Destructive Action Review

Not applicable — no destructive action involved in the expand phase.

## Validation Evidence

| Command | Scope | Result | Evidence / notes |
| --- | --- | --- | --- |
| `go test ./internal/api/...` | api package | pass — 34 tests, 0 failures | mapper, serializer, and contract tests all pass |
| `go test -race ./internal/api/...` | api package | pass — no race conditions detected | |
| `python3 -m json.tool docs/api/openapi.yaml` | OpenAPI spec | not applicable — YAML not JSON | |
| `python3 -c "import yaml; yaml.safe_load(open('docs/api/openapi.yaml'))"` | OpenAPI spec | pass — valid YAML | |
| `grep -r "request_id" testdata/fixtures/` | test fixtures | 12 occurrences — all fixtures verified | all also contain `correlation_id` |
| `grep -r "correlation_id" testdata/fixtures/` | test fixtures | 12 occurrences — matches `request_id` count | |

## Runtime Wiring Check

- **Entry point or caller:** `POST /v1/operations` handler in `internal/api/handler.go:87`
- **Wiring path confirmed:** handler calls `mapper.BuildResponse()` → struct
  populated with both fields → JSON serializer includes both in output
- **Boundary reached in validation:** integration test sends real HTTP request
  and asserts both fields present in response body
- **Any path not verified:** partner client consuming `request_id` — cannot
  test external partner in this environment; verified by reading their documented
  integration behavior

## Residual Risks and Gaps

- **Residual risks:** partner client has not been notified yet that `request_id`
  is deprecated; notification is required before the contract phase begins
- **What remains unverified:** partner client behavior after the contract phase
  removes `request_id`
- **Why it remains unverified:** partner environment is not accessible during
  development; notification and confirmation are tracked in issue #48
- **Follow-up owner:** Mohammad Rajab — notify partner before opening any PR
  that removes `request_id`

## Session Continuity

Not applicable — this change completes in one session.

## Closure Statement

```text
Closure check:
- Claim: expand phase adds correlation_id alongside request_id with no consumer breakage
- Deliverables claimed: response struct, mapper, OpenAPI spec, fixtures, unit tests, contract test, CHANGELOG entry
- Paths verified: all 7 deliverable paths confirmed present and non-empty
- Validation run: go test ./internal/api/... — 34 pass, 0 fail; race detector clean; fixtures grep confirms both fields in all 12 files
- Residual risks: partner notification pending before contract phase; partner behavior in contract phase unverified
- Remaining gaps: partner client unverified — contract phase (field removal) must not proceed until issue #48 is resolved
```

Expand phase is complete. Migrate phase and contract phase are open.
