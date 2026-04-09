# Change Management Rules

- Keep changes small, coherent, and reviewable.
- Maintain runbooks or operational playbooks for critical system operations: deployments, rollbacks, failovers, data migrations, and incident response. Update them as part of every major release. A runbook that does not reflect the current system is worse than no runbook — it creates false confidence during incidents.
- Write a short plan for multi-file or high-risk work before editing.
- Commit only logically complete, validated changes.
- Do not mix refactoring with behavior changes in the same commit unless they are trivially inseparable. Separating them makes review faster and rollback cleaner.
- Keep docs, config examples, diagrams, and migration notes in sync with code.
- Keep the active documentation surface small and current. When documents become historical, archive them, delete them, or clearly remove them from active navigation rather than leaving them mixed with current source-of-truth docs.
- When a project accumulates many old ADRs or phase notes, prefer one maintained current decision surface over many half-current files.
- Use branch and PR discipline appropriate to the repository.
- In the PR description or summary, explain the problem, the approach, risks, rollback considerations, and validation performed.
- For breaking schema, API, or event changes, use the expand-migrate-contract pattern — full procedure including contract tests and event versioning is in `10-config-migrations`.
- For high-risk production changes, prefer a feature flag or staged
  rollout. Define the flag's owner, default value, purpose, and planned
  removal timeline before merging.
- Choose the deployment strategy deliberately for production changes.
  Routine low-risk changes may suit a normal rolling deployment. Changes
  with meaningful correctness, latency, or user-impact risk should use a
  staged rollout, canary, feature flag, or other mechanism that limits
  blast radius. Do not treat "deploy everywhere at once" as the default
  for risky changes.
- For any canary or staged rollout, define success criteria before the
  rollout begins: which signals will be checked, what threshold
  constitutes failure, and who decides whether to proceed or roll back. A
  canary without predeclared success criteria is only a partial deploy,
  not a controlled one.
- Every production change needs a practical rollback path. For pure code
  changes this may be redeploying the previous version or reverting the
  change. For schema, event, or configuration changes, rollback may
  require an explicit compatibility or compensating-change plan. An
  untested rollback path is an assumption, not a capability.
- Human review is mandatory for AI-generated code before merge.
- AI-generated or AI-assisted changes must remain small enough to review
  with the same or greater scrutiny as human-written changes. If the
  generated diff is too large to review confidently, split it into smaller
  sequential changes before merge.
- When a production incident or failed rollout exposes a gap in change
  process, rollback readiness, or release safety, record the lesson and
  track the follow-up action. A repeated rollout failure with no captured
  lesson is a change-management defect, not bad luck.

## Rule exceptions and waivers

- When a specific situation requires deliberately breaking one of these governance rules, document the exception explicitly: which rule is being broken, the scope of the exception (file, module, release), the owner responsible for it, the risk accepted, and the condition under which it expires or must be revisited.
- Scope exceptions as narrowly as possible. An exception that applies to a single function or migration is better than one that applies to a whole module. An exception that expires after one release is better than one with no end date.
