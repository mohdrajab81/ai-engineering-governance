# Changelog

All notable changes to the AI Engineering Governance Pack are documented here.

This project follows [Semantic Versioning](https://semver.org/):

- **Patch (x.x.N):** Clarifications, typo fixes, example additions. Safe to adopt without a team review session.
- **Minor (x.N.0):** New rules or new domain files. Review new rules before adopting. No existing rules removed or weakened.
- **Major (N.0.0):** Breaking changes to rule structure, non-negotiable changes, or rule removal. Requires an explicit team decision before upgrading.

---

## [v10.1.0] — 2026-04-09

### Added

- **Language rule files** (`.claude/rules/languages/`) — optional extensions for Python, TypeScript, and Go. Activated per `PHASED_ADOPTION.md` when the language is in active use. Python: type annotations, frozen dataclasses, black/ruff/isort/mypy, bandit, pytest markers. TypeScript: `unknown` over `any`, Zod boundary validation, no `console.log`, Playwright E2E. Sections annotated `[TS only]` vs `[TS + JS]`. Go: gofmt/goimports/vet/staticcheck/gosec, interface design, context timeouts, `-race` flag, table-driven tests.
- **Rule 11: Research and Reuse Before Coding** — new section defining hallucination-by-omission narrowly: failing to check repo patterns or vendor docs is a verification failure; not finding an external package when custom code is justified is not.
- **Rule 06: Code review severity tiers** — CRITICAL / HIGH / MEDIUM / LOW with explicit merge gate semantics. CRITICAL and HIGH are hard blockers; MEDIUM requires acknowledged follow-up; LOW does not block merge.
- **AI_AGENT_WORKFLOW.md step 0** — research and reuse before coding added to the standard task flow.
- **`.claude/hooks/hooks.json`** — optional governance-enforcing hooks: `--no-verify` block (Rule 08), staged-diff secret scan on `git commit` (Rule 05), config-protection for lint/format files with warn-only for `pyproject.toml` (Rule 06). All hooks use `exit 2` + stderr for hard blocking. Session-stop handoff hook documented as opt-in example with explanation. Windows/PowerShell portability caveat documented.
- **`scripts/check-governance.sh`** — local validation script mirroring all CI checks. Structured pass/fail output. Falls back to `node` for JSON validation when `python3` is unavailable.
- **Semantic CI checks** (`governance-check.yml`) — three new steps: Rule N cross-reference validation (prose references must resolve to existing files), README domain-rule inventory sync, PHASED_ADOPTION language-rule sync.
- Rule 01: dependency direction rule and ADR capture discipline.
- Rule 03: graceful degradation pre-definition and readiness vs liveness health check semantics.
- Rule 03: error boundary design — callers must define explicit error propagation contracts at module and service boundaries.

### Changed

- README.md: "Proven in Production" renamed to "Battle-Tested on a Production Build" with explicit scope sentence (one project, one engineer, one language).
- REFERENCES.md: "independent review" replaced with "multi-round AI alignment reviews" in all three occurrences. Caveat paragraph added before score table: scores reflect AI alignment assessment, not independent peer review.
- PHASED_ADOPTION.md: language rule files added to middle-tier activation table.
- RULE_PLACEMENT.md: language-specific rules row added.
- `settings.example.json`: note updated to reference `hooks.json` and distinguish default hooks from optional examples.

---

## [v10.0.0] — 2026-04-08

### Added

- **Rule 14: AI Session Memory and Boundary Management** (`.claude/rules/14-ai-session-memory.md`) — context pressure recognition, progress checkpointing via `tasks/handoff-<topic>.md`, session handoff discipline, multi-agent handoff protocol
- **CHANGELOG.md** — this file; implements the semantic versioning the README prescribes
- **Scope Boundaries section in README** — explicitly documents what the pack does not cover (GDPR, accessibility, cost governance, industry compliance frameworks)
- Rules 12, 13, and 14 added to PHASED_ADOPTION.md activation tables
- Rule 14 session handoff step added to AI_AGENT_WORKFLOW.md task flow
- Rules 12, 13, 14 items added to AI_AGENT_WORKFLOW.md done checklist
- Rule 14 session handoff bullet added to .github/copilot-instructions.md
- Exceptions/Waivers and Lessons Entry sections added to .github/PULL_REQUEST_TEMPLATE.md
- JSON validation, markdown lint, and rule-file count check added to governance-check.yml
- `tasks/lessons.md` with structured template and two real lesson entries

### Changed

- CLAUDE.md: added destructive-action approval to non-negotiables; prompt-injection explicitly named
- AI_AGENT_WORKFLOW.md: review template aligned to Rule 06 evidence format (scope / remaining gaps)
- AGENTS.md: Rule 12 description updated with documentation surfaces; Rule 13/14 callout added
- `.claude/settings.example.json`: removed `git push` from allow list (too permissive for generic example); added `git branch -D` and `git checkout --` to deny list; added `_note` for repo-specific tuning
- `.markdownlint.json`: added MD024 siblings_only, disabled MD041
- README.md: "any published standard" corrected to "any published AI governance standard"
- RULE_PLACEMENT.md: removed duplicate vertical-slice-completeness row
- governance-check.yml: expanded secret scan to include settings.example.json and PR template

---

## [v9.0.0] — 2026-04-01

### Added

- **Rule 12: Vertical Slice Completeness** (`.claude/rules/12-vertical-slice-completeness.md`) — 7-point cross-layer contract closure checklist covering fields, routes, events, schemas, interface methods, deprecated aliases, and documentation surfaces
- **Rule 13: Slice Exit Evidence** (`.claude/rules/13-slice-exit-evidence.md`) — phase and milestone closure evidence requirements: deliverable existence, wiring verification, validation evidence, completion note format

### Changed

- All 11 original rule files: targeted improvements based on multi-round review. Key changes: Rule 02 timer/scheduler ownership; Rule 03 retry ownership and backpressure scope; Rule 05 SSRF section, file/path handling, secrets in AI outputs, authz cache invalidation; Rule 06 evidence format rule; Rule 07 in-process backpressure and stateless clarification; Rule 08 exception/waiver section; Rule 09 codebase consistency section; Rule 10 log effective config at startup; Rule 11 three multi-agent operational rules
- README.md: fully restructured — leads with "The Problem This Solves", production proof second, domain adapter pattern under deployment
- AGENTS.md: updated to list all 14 rule files
- PHASED_ADOPTION.md: Minimal Context Principle section with arXiv citations added

---

## [v6.0.0] — 2026-03-23

### Added

- Initial public release of the AI Engineering Governance Pack
- 11 domain rule files (01–11)
- CLAUDE.md root authority file
- AI_AGENT_WORKFLOW.md operational workflow
- AGENTS.md (OpenAI Codex adapter)
- .github/copilot-instructions.md (GitHub Copilot adapter)
- RULE_PLACEMENT.md, PHASED_ADOPTION.md, CONTRIBUTING.md, REFERENCES.md
- .claude/settings.example.json
- .github/workflows/governance-check.yml (2-step: fill-me check, secret scan)
- .github/PULL_REQUEST_TEMPLATE.md

---

## Version Recording

Consuming repositories should record the version they adopted. One simple approach:

```yaml
# In docs/ai-governance/VERSION or similar
ai-engineering-governance: v10.0.0
adopted: 2026-04-08
customizations: domain/telecom.md added
```

When upgrading, review the changelog entries between your current version and the target version before merging.
