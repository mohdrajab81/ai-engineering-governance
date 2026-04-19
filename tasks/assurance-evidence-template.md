# Assurance and Evidence Template for High-Risk Changes

Use this template when a change crosses one or more of this pack's native
high-risk boundaries:

- backward compatibility risk
- schema, API, event, or config migration
- destructive operation
- public contract or interface change
- staged rollout or rollback-sensitive production change
- multi-session work where loss of context could create delivery risk

This template is intentionally anchored to the repository's own rules rather
than to a generic assurance framework.

## When to use it

Use this template when any of the following apply:

- `CLAUDE.md` non-negotiables require migration, rollback, or explicit approval
- `.claude/rules/08-change-management.md` requires a plan, rollback path, or
  staged rollout
- `.claude/rules/10-config-migrations.md` applies
- `.claude/rules/12-vertical-slice-completeness.md` applies across layers
- `.claude/rules/13-slice-exit-evidence.md` is needed before declaring a slice
  or milestone complete
- `.claude/rules/14-ai-session-memory.md` requires tracked handoff or session
  continuity

## Change Summary

- Title:
- Owner:
- Date:
- Status:
- Related issue / PR / task:

## Risk Trigger

Check every trigger that applies:

- [ ] Breaking or compatibility-sensitive change
- [ ] Schema migration
- [ ] API contract change
- [ ] Event schema or message-shape change
- [ ] Configuration key or feature-flag change
- [ ] Destructive action
- [ ] Production rollout risk
- [ ] Multi-session continuity risk

## Claim

State the claim being made about the change in one or two precise sentences.

Example:

`This change preserves backward compatibility during the expand phase and
introduces the new request shape without breaking current consumers.`

- Claim:

## Rule Categories In Scope

List the relevant native rule surfaces:

- `CLAUDE.md` non-negotiables:
- `.claude/rules/08-change-management.md`:
- `.claude/rules/10-config-migrations.md`:
- `.claude/rules/12-vertical-slice-completeness.md`:
- `.claude/rules/13-slice-exit-evidence.md`:
- `.claude/rules/14-ai-session-memory.md`:
- Other rule files in scope:

## Deliverables and Paths

List each promised artifact and the exact path that satisfies it.

| Deliverable | Path | Exists | Notes |
| --- | --- | --- | --- |
| Example: migration script | `db/migrations/20260419_add_field.sql` | yes/no | |

## Contract and Compatibility Analysis

- Current contract:
- Intended contract after this change:
- Compatibility mode during transition:
- Expand-migrate-contract phase:
- Consumers affected:
- Producers affected:
- Deprecated alias or old shape still supported:
- Planned removal point:

## Rollout and Rollback

- Deployment strategy:
- Success criteria:
- Failure threshold:
- Rollback path:
- Rollback tested:
- Feature flag owner/default/removal timeline, if applicable:

## Destructive Action Review

Complete this section only if destructive behavior is involved.

- Destructive action:
- Explicit human approval reference:
- Scope of destruction:
- Safeguards before execution:
- Recovery path:

## Validation Evidence

Record exact commands and actual results. Do not summarize vaguely.

| Command | Scope | Result | Evidence / notes |
| --- | --- | --- | --- |
| Example: `go test ./...` | repository | pass/fail | |

## Runtime Wiring Check

Show that the change is reachable from the real runtime path, not only from
isolated code or tests.

- Entry point or caller:
- Wiring path confirmed:
- Boundary reached in validation:
- Any path not verified:

## Residual Risks and Gaps

- Residual risks:
- What remains unverified:
- Why it remains unverified:
- Follow-up owner:

## Session Continuity

Complete this section for multi-session or high-context work.

- Handoff artifact path:
- Current state captured:
- Open decisions captured:
- Safe resume point:

## Closure Statement

Use this block before calling the work complete:

```text
Closure check:
- Claim:
- Deliverables claimed:
- Paths verified:
- Validation run:
- Residual risks:
- Remaining gaps:
```

If any material remaining gap exists, do not mark the slice, phase, or change
complete.
