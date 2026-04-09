# Lessons Log Template

This file is a reusable pattern for capturing what the team learned from AI-assisted development.

Use it when:

- an agent repeats the same mistake more than once
- a review catches a failure mode that the current rules did not prevent
- a process gap is discovered between the rules and the real workflow
- the team wants to justify a rule change with concrete evidence

This file is not a runtime instruction file. It is a maintainer artifact for improving the governance pack or a consuming repository's local rules.

A lessons entry is evidence for a governance change, not a substitute for it. If the lesson warrants a rule update, make the update. The entry records the failure mode behind it.

## Entry template

Copy this block for each new lesson:

```md
## YYYY-MM-DD — Short lesson title

### What happened

- Describe the failure or recurring mistake in one or two specific sentences.

### Why it happened

- Explain the underlying cause.
- Note whether the problem came from missing guidance, unclear wording, bad workflow, or missing tooling.

### What changed

- Record the rule, workflow, CI, or review change made in response.

### Prevention rule

- State the principle the team should follow in future.

### Decision

- Upstream pack change / repository-local only / no rule change needed

### Scope

- Say whether this is repository-specific or suitable for the upstream governance pack.

### Evidence

- Link the relevant file, commit, PR, or review note if available.
```

## 2026-03-23 — Separate governance changes from product-contract changes

### What happened

- Governance-file adoption and API contract changes were prepared in the same working session.
- That made it harder to review and reason about rollback scope.

### Why it happened

- The repository was adopting new AI-governance files while also refining product behavior.
- There was no explicit reminder to keep process changes separate from architecture or contract changes.

### What changed

- The repository split the work into separate commits: one for governance files and one for API/interface changes.

### Prevention rule

- Keep governance/process changes separate from product-contract changes whenever practical.

### Decision

- Suitable for upstream governance guidance.

### Scope

- Suitable for upstream governance guidance because the review and rollback benefit is generic.

### Evidence

- Example pattern only. Replace with repository-specific links when copied into a real project.

## 2026-04-01 — Contract-complete work needs cross-layer closure checks

### What happened

- A change added new contract surfaces and compatibility paths, but only some
  layers were updated.
- The code compiled and targeted tests passed, yet the runtime surface was
  still incomplete because routes, serializers, deprecated aliases, or sibling
  implementations were missing or only partially updated.

### Why it happened

- The governance pack already required validation and anti-hallucination
  discipline, but it did not explicitly require a cross-layer closure check
  for new contract definitions.
- Agents and reviewers relied too much on local compile/test success as a proxy
  for completeness.
- Deprecated coexistence paths were especially easy to miss because the new
  canonical surface looked correct while the old surface silently drifted.

### What changed

- Added a new general rule file:
  `.claude/rules/12-vertical-slice-completeness.md`.
- The rule requires explicit checks for:
  - new shared fields across all constructors, copies, and defaults
  - new routes across router, handler, serializer, and instrumentation
  - new event types at the emitter and payload level
  - new schemas across serialization structs and mappers
  - new interface methods across all implementations
  - deprecated aliases and coexistence paths during migration windows

### Prevention rule

- A contract addition is not done until every layer that must implement or
  consume it is updated and verified.
- Passing tests is evidence, not proof of cross-layer completeness.
- During a migration window, deprecated aliases are still part of the contract
  and must be verified like the new canonical surface.

### Decision

- Upstream pack change.

### Scope

- Suitable for the upstream governance pack because this failure mode is common
  across layered repositories and is not specific to one stack or product.

### Evidence

- Rule file added: `.claude/rules/12-vertical-slice-completeness.md`
- Inventory/docs updated to include the new rule.

## 2026-04-08 — Session boundaries are engineering boundaries

### What happened

- A long multi-session task produced conflicting outputs because earlier decisions
  had been made in sessions whose context was no longer available.
- The agent re-derived conclusions that contradicted established choices and
  violated constraints it could no longer see.

### Why it happened

- Mid-task progress was held in chat history and project memory files, not in
  committed repository artifacts.
- When the session compressed, the earlier decisions became invisible.
- There was no established pattern for writing a handoff artifact before ending
  a session with incomplete work.

### What changed

- Added Rule 14: `.claude/rules/14-ai-session-memory.md`.
- The rule establishes: checkpoint progress in `tasks/handoff-<topic>.md` before
  ending any session with incomplete high-risk work; verify repository state at
  the start of each new session; persistent memory is for durable preferences,
  not mid-task progress.

### Prevention rule

- Treat session boundaries as real engineering boundaries. Commit stable
  intermediate state before ending a session. Write a handoff file when work
  will resume in a later session. Do not rely on memory files or chat history
  to carry implementation state across sessions.

### Decision

- Upstream pack change.

### Scope

- Suitable for the upstream governance pack because session-boundary failures
  occur in any long AI-assisted project regardless of stack or domain.

### Evidence

- Rule file added: `.claude/rules/14-ai-session-memory.md`
- Inventory and adapter files updated to reference Rule 14.

## 2026-04-09 — Hardcoded rule count in CI became a latent sync gap

### What happened

- `governance-check.yml` and `check-governance.sh` both contained `EXPECTED=14`.
- The value was correct but independent of any authoritative source.
- Every time the base rule set changes, both files must be updated manually, and
  the failure mode is silent — CI passes with the wrong count if both files are
  updated consistently but the actual file count diverges.

### Why it happened

- The count was written as a literal at the time the check was introduced.
  There was no mechanism forcing it to stay in sync with the rule manifest.
- A reviewer flagged it as a LOW finding after two consecutive version bumps.

### What changed

- Both files now derive `EXPECTED` from the AGENTS.md row count instead of
  hardcoding a literal. AGENTS.md is the single source of truth for the rule
  manifest. The file-count check validates actuals against the manifest.

### Prevention rule

- When a CI check compares two independently-maintained values, one should derive
  from the other rather than being hardcoded in parallel. Two parallel hardcoded
  values create a latent sync gap that will not be caught until they diverge.

### Decision

- Upstream pack change.

### Scope

- Generic pattern applicable to any repo with count-based CI checks.

### Evidence

- Commit: `governance-check.yml` and `check-governance.sh` updated to derive
  `EXPECTED=$(grep -c "\.md |" AGENTS.md)`.

## 2026-04-09 — Coverage maps need explicit labels, not implicit completeness

### What happened

- The initial OWASP Agentic Top 10 coverage table in README.md listed a rule
  reference for every ASI category without distinguishing full from partial
  coverage.
- ASI10 (Rogue Agents) was listed with Rule 11 scope discipline and Rule 14
  session handoff — real coverage, but only on the prevention side.
  Runtime behavioral monitoring, anomaly detection, and kill-switch controls
  were not covered, and the table did not say so.
- A reviewer flagged this as a MEDIUM finding: the table overstated coverage and
  reintroduced the credibility problem that had been reduced elsewhere.

### Why it happened

- The table was written to map rules to categories, not to assess completeness.
  The implicit assumption was that a partial mapping was better than no mapping.
  It was — but without labels, readers could not distinguish partial from full.

### What changed

- Added a Coverage column to the table with Full / Partial labels.
- Each Partial row now includes a sentence explaining what the pack does not cover
  and why (usually: runtime/operational concerns outside coding governance scope).

### Prevention rule

- Any coverage or compliance mapping table must use explicit coverage labels.
  A table row that names a rule without qualifying coverage implies full coverage
  to a reader who does not inspect every rule in detail. Make the qualifier
  visible in the table itself, not in accompanying prose.

### Decision

- Upstream pack change.

### Scope

- Applicable to any governance pack producing coverage tables against external
  frameworks (OWASP, NIST, ISO, regulatory).

### Evidence

- README.md Standards Coverage section updated with Full/Partial labels and
  inline gap notes per ASI category.
