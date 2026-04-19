# Contributing

Thanks for contributing to the AI Engineering Governance Pack.

This repository is documentation-first. Changes should be small, exact, and internally consistent. Treat governance files with the same discipline you would apply to production code.

## Before you change anything

Read these files first:

1. `README.md`
2. `CLAUDE.md`
3. `AI_AGENT_WORKFLOW.md`
4. `RULE_PLACEMENT.md`
5. `PHASED_ADOPTION.md`
6. `.github/PULL_REQUEST_TEMPLATE.md`

If you are updating or adding a rule because of a real failure pattern, also review `tasks/lessons.md`.

## Contribution principles

- Keep changes focused. One logical change per branch and PR.
- Do not mix governance/process changes with unrelated product or repository changes.
- Prefer clarifications and exact examples over broad rewrites.
- If you change one file that describes package contents, rollout, or file placement, update every other file that references it.
- Do not duplicate the same rule in multiple files unless each file serves a different purpose.

## What belongs where

- `CLAUDE.md`: root non-negotiables and working pattern
- `.claude/rules/`: domain-specific detailed guidance
- `AI_AGENT_WORKFLOW.md`: operational workflow, command table, review checklist
- `RULE_PLACEMENT.md`: maintainer guidance on where rules belong
- `PHASED_ADOPTION.md`: maintainer guidance on when to apply parts of the pack
- `tasks/lessons.md`: evidence log for recurring failures and improvements
- `tasks/assurance-evidence-template.md`: evidence and assurance template for high-risk changes; copy and fill when the risk-trigger checklist in that file applies
- `.claude/settings.example.json`: optional local setup example, not a policy source

If you are unsure where something belongs, update `RULE_PLACEMENT.md` and the relevant file together.

## Recommended workflow

1. Create a branch from `main`.
2. Make one focused change.
3. Update all affected docs and cross-references.
4. Run the relevant checks.
5. Open a PR using `.github/PULL_REQUEST_TEMPLATE.md`.
6. Merge only after review.

Suggested branch naming:

- `docs/<short-topic>`
- `fix/<short-topic>`

Suggested commit naming:

- `docs: ...`
- `fix(docs): ...`
- `chore: ...`

## Validation expectations

For documentation changes:

- verify all referenced files and paths exist
- verify any JSON examples parse
- run markdown linting if available in your environment

For workflow or governance-check changes:

- review `.github/workflows/governance-check.yml`
- ensure new instructions do not conflict with existing adapters or root policy

If you could not run a check, say so explicitly in the PR.

## Rule changes

Do not edit a rule file casually.

A good rule change should be backed by one of:

- a repeated agent mistake
- a review finding
- a real operational failure mode
- a deliberate policy decision by maintainers

Capture the motivation in `tasks/lessons.md` when appropriate, then update the rule as a standalone change.

## Pull requests

Every PR should explain:

- the problem being solved
- the exact files changed
- why the chosen design is correct
- what validation was run
- what remains unverified

For high-risk changes — backward-compatibility risk, schema or API migration, destructive operation, public contract change, or staged rollout — include the closure statement from a filled `tasks/assurance-evidence-template.md` in the PR description or as an attached file.

Use the repository PR template.

## Do not do this

- Do not push unrelated batches of changes directly to `main`.
- Do not add tool-specific files without updating the README or placement guidance.
- Do not add examples that conflict with the repo's own stated workflow.
- Do not treat support artifacts like `tasks/lessons.md` or `.claude/settings.example.json` as runtime policy files.
