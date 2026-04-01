# Lessons Log Template

This file is a reusable pattern for capturing what the team learned from AI-assisted development.

Use it when:

- an agent repeats the same mistake more than once
- a review catches a failure mode that the current rules did not prevent
- a process gap is discovered between the rules and the real workflow
- the team wants to justify a rule change with concrete evidence

This file is not a runtime instruction file. It is a maintainer artifact for improving the governance pack or a consuming repository's local rules.

## Entry template

Copy this block for each new lesson:

```md
## YYYY-MM-DD — Short lesson title

**What happened**

- Describe the failure or recurring mistake in one or two specific sentences.

**Why it happened**

- Explain the underlying cause.
- Note whether the problem came from missing guidance, unclear wording, bad workflow, or missing tooling.

**What changed**

- Record the rule, workflow, CI, or review change made in response.

**Prevention rule**

- State the principle the team should follow in future.

**Scope**

- Say whether this is repository-specific or suitable for the upstream governance pack.

**Evidence**

- Link the relevant file, commit, PR, or review note if available.
```

## Example entry

### 2026-03-23 — Separate governance changes from product-contract changes

**What happened**

- Governance-file adoption and API contract changes were prepared in the same working session.
- That made it harder to review and reason about rollback scope.

**Why it happened**

- The repository was adopting new AI-governance files while also refining product behavior.
- There was no explicit reminder to keep process changes separate from architecture or contract changes.

**What changed**

- The repository split the work into separate commits: one for governance files and one for API/interface changes.

**Prevention rule**

- Keep governance/process changes separate from product-contract changes whenever practical.

**Scope**

- Suitable for upstream governance guidance because the review and rollback benefit is generic.

**Evidence**

- Example pattern only. Replace with repository-specific links when copied into a real project.

## 2026-04-01 — Contract-complete work needs cross-layer closure checks

**What happened**

- A change added new contract surfaces and compatibility paths, but only some
  layers were updated.
- The code compiled and targeted tests passed, yet the runtime surface was
  still incomplete because routes, serializers, deprecated aliases, or sibling
  implementations were missing or only partially updated.

**Why it happened**

- The governance pack already required validation and anti-hallucination
  discipline, but it did not explicitly require a cross-layer closure check
  for new contract definitions.
- Agents and reviewers relied too much on local compile/test success as a proxy
  for completeness.
- Deprecated coexistence paths were especially easy to miss because the new
  canonical surface looked correct while the old surface silently drifted.

**What changed**

- Added a new general rule file:
  `.claude/rules/12-vertical-slice-completeness.md`.
- The rule requires explicit checks for:
  - new shared fields across all constructors, copies, and defaults
  - new routes across router, handler, serializer, and instrumentation
  - new event types at the emitter and payload level
  - new schemas across serialization structs and mappers
  - new interface methods across all implementations
  - deprecated aliases and coexistence paths during migration windows

**Prevention rule**

- A contract addition is not done until every layer that must implement or
  consume it is updated and verified.
- Passing tests is evidence, not proof of cross-layer completeness.
- During a migration window, deprecated aliases are still part of the contract
  and must be verified like the new canonical surface.

**Scope**

- Suitable for the upstream governance pack because this failure mode is common
  across layered repositories and is not specific to one stack or product.

**Evidence**

- Rule file added: `.claude/rules/12-vertical-slice-completeness.md`
- Inventory/docs updated to include the new rule.
