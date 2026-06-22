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

## 2026-06-22 — Gates must enforce what documentation claims

### What happened

- A project methodology review found a generated coverage check described with
  gate language even though one important gap class was report-only.
- The output was still useful, but the documentation made the check sound more
  blocking than its exit behavior actually was.

### Why it happened

- The workflow treated "strict report is clean today" and "strict report would
  fail if this condition appeared tomorrow" as equivalent.
- The existing validation rules required exact commands and results, but did
  not explicitly require claimed gates to match command exit semantics.

### What changed

- Added gate-honesty guidance to Rule 06, Rule 13, and
  `AI_AGENT_WORKFLOW.md`.
- Added the pattern to the README methodology lessons so consuming teams know
  to distinguish blocking gates from report-only evidence.

### Prevention rule

- A check is a gate only when it exits non-zero for the condition it claims to
  block. If a tool only reports a gap, call it report-only evidence and list
  the remaining gap explicitly.

### Decision

- Upstream pack change.

### Scope

- Suitable for the upstream governance pack because false gate language is a
  generic validation and completion-risk pattern.

### Evidence

- Contract-first rebuild methodology review, 2026-06-22. The source methodology
  file is external evidence and is not bundled into this repository.

## 2026-06-22 — Contract surfaces need a named consumer need

### What happened

- A contract-first project found that API endpoints designed directly from
  schema tables can return the wrong shape for real clients.
- The project avoided orphan endpoints by tracing each endpoint to an actor,
  trigger, workflow or screen, and concrete data need before implementation.

### Why it happened

- Rule 12 already required cross-layer closure once a contract exists, but it
  did not explicitly require a new contract surface to prove why it should
  exist.
- Without that trace, an endpoint, event, or schema field can be technically
  implemented while still leaving consumers to invent missing business logic.

### What changed

- Rule 12 now includes a no-orphan contract check before the existing
  cross-layer checklist.
- README methodology lessons now call out consumer-traced contracts as a
  portable pattern.

### Prevention rule

- A new contract surface should have a named caller or consumer, trigger, and
  data need before it is promoted into the public or shared contract.

### Decision

- Upstream pack change.

### Scope

- Suitable for the upstream governance pack because orphan contract surfaces
  appear across UI, API, event-driven, and service-to-service systems.

### Evidence

- Contract-first rebuild methodology review, 2026-06-22. The source methodology
  file is external evidence and is not bundled into this repository.

## 2026-06-22 — Authority layers and derived documents need conflict order

### What happened

- A documentation-heavy project relied on live contracts, current decisions,
  governance files, generated reports, state summaries, and methodology notes.
- The method worked because authority layers had an explicit conflict order and
  derived documents stayed subordinate to the sources they summarized.
- Without explicit subordination, derived documents can silently become a second
  decision layer when they drift.

### Why it happened

- The pack already encouraged small current docs and archived history, but did
  not explicitly require repositories to define conflict order when multiple
  active authority layers existed.
- It also did not explicitly require derived documents to name the source they
  summarize.
- Agents tend to trust the most readable or recent document unless the conflict
  order is stated directly in the artifact.

### What changed

- Rule 08 now requires repositories with multiple active authority layers to
  define conflict order in the agent entrypoint, workflow doc, or equivalent.
- Rule 08 also requires derived documents to name their authoritative source and
  state which source wins on conflict.

### Prevention rule

- When several active authority layers exist, define their conflict order where
  agents will read it before work begins.
- A derived document should identify the source of truth it summarizes and
  declare itself the artifact to fix if the two disagree.

### Decision

- Upstream pack change.

### Scope

- Suitable for the upstream governance pack because generated reports, indexes,
  coverage maps, and summary docs are common across AI-assisted projects.

### Evidence

- Contract-first rebuild methodology review, 2026-06-22. The source methodology
  file is external evidence and is not bundled into this repository.

## 2026-06-22 — Review feedback should become precise operational guidance

### What happened

- External review feedback praised the pack's structure but identified several
  places where the operational guidance could be easier to apply: complex hook
  shell logic embedded directly in JSON, no explicit place to record active
  governance layers, and a few domain-rule points that needed implementation
  boundaries.

### Why it happened

- The hook manifest optimized for copy/paste portability, but non-trivial shell
  bodies inside JSON are hard to review, edit, and syntax-check.
- The phased-adoption guide explained when layers activate, but not where a
  consuming repository should record that a layer is now active.
- Several domain rules stated the principle but left room for agents to overdo
  implementation detail, such as heavyweight token counting or application-level
  tail-sampling logic.

### What changed

- Moved default hook logic into companion scripts under `.claude/hooks/scripts/`
  and updated local/CI validation to parse `hooks.json` and syntax-check the
  scripts.
- Added active-layer recording guidance to `PHASED_ADOPTION.md` and task-flow
  guidance to name relevant rule files during planning.
- Clarified token-estimation tradeoffs, trace sampling ownership, golden
  dataset storage, and explicit database pool sizing.

### Prevention rule

- When review feedback identifies a governance gap, translate it into a small
  operational rule, artifact, or validation check rather than adding broad
  explanatory prose.

### Decision

- Upstream pack change.

### Scope

- Suitable for the upstream governance pack because hook maintainability,
  adoption-state tracking, and over/under-specific agent guidance are generic
  AI-assisted engineering workflow issues.

### Evidence

- External review feedback attached to the 2026-06-22 governance review session.
