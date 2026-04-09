# Changelog

All notable changes to the AI Engineering Governance Pack are documented here.

This project follows [Semantic Versioning](https://semver.org/):

- **Patch (x.x.N):** Typos, wording clarifications, and other
  non-substantive documentation fixes. Safe to adopt without a team review
  session.
- **Minor (x.N.0):** Additive rule expansions, new rule files, new
  supporting artifacts, or stronger enforcement that does not remove or
  weaken existing rules. Review the change set before adopting.
- **Major (N.0.0):** Breaking changes to rule structure, non-negotiable changes, or rule removal. Requires an explicit team decision before upgrading.

---

## [v10.11.1] — 2026-04-09

### Changed

- **Adapter compaction** — Removed duplicated non-negotiable summaries from
  `AGENTS.md` and `.github/copilot-instructions.md` while keeping
  `CLAUDE.md` as the canonical rule source and retaining adapter-specific
  guidance.

Safe to adopt without a team review session.

---

## [v10.11.0] — 2026-04-09

### Changed

- **Safe compaction pass** — Removed a small amount of tutorial and
  restated text from Rules 06, 08, 10, 12, and 13 without changing rule
  substance or file structure.

All changes are additive. Consuming repositories can adopt on a normal
minor-upgrade schedule.

---

## [v10.10.0] — 2026-04-09

### Added

- **README enforcement-boundary note** — Added an explicit
  "What This Pack Does Not Enforce" section clarifying that the pack's own
  CI is structural and that consuming repositories still need stack-specific
  code-level enforcement.

All changes are additive. Consuming repositories can adopt on a normal
minor-upgrade schedule.

---

## [v10.9.0] — 2026-04-09

### Added

- **Collateral alignment and local-check reliability** — Added
  `scripts/run-markdownlint.sh` to make markdown linting work reliably in
  Bash/WSL environments that expose `node.exe` but not `node`.

### Changed

- **README.md** — Replaced the stale inline CI sample with guidance to copy
  the canonical workflow file, documented the local lint/runtime
  requirement more accurately, and revised semantic-versioning wording to
  match additive rule expansions.
- **AI_AGENT_WORKFLOW.md** — Corrected the docs-only command table for
  linting, smoke testing, security scanning, and local YAML/JSON
  validation.
- **`scripts/check-governance.sh`** — Aligned the local secret scan with
  CI, used the new markdownlint helper, and made shell/runtime
  requirements explicit.
- **`.claude/settings.example.json`** — Updated the markdownlint hook to
  use the helper script and documented the Bash/WSL fallback behavior.
- **Tracked markdown files** — Fixed markdownlint issues in Rule 13 and the
  Python and TypeScript language-rule files so the full local governance
  check now passes.

All changes are additive. Consuming repositories can adopt on a normal
minor-upgrade schedule.

---

## [v10.8.0] — 2026-04-09

### Added

- **Rules 10, 11, 12, and 14 refinements** — Added IaC drift detection,
  version-controlled feature flag definitions, migration deployment
  ordering, AI defect-profile review guidance, fixture and seed-data
  alignment for shared-structure changes, early contract-file drift
  checks, large tool-output summarization, and deliberate session restart
  under context pressure.

All changes are additive. Consuming repositories can adopt on a normal
minor-upgrade schedule.

---

## [v10.7.0] — 2026-04-09

### Added

- **Rule 09 readability discipline** — Added guidance for
  domain-significant constants, AI-generated readability review, and a
  three-instance duplication extraction heuristic.

All changes are additive. Consuming repositories can adopt on a normal
minor-upgrade schedule.

---

## [v10.6.0] — 2026-04-09

### Added

- **Rule 08 change-management discipline** — Added deliberate deployment
  strategy selection, predeclared canary success criteria, rollback-path
  requirements, AI-generated diff size discipline, and incident-driven
  change-process learning.

All changes are additive. Consuming repositories can adopt on a normal
minor-upgrade schedule.

---

## [v10.5.0] — 2026-04-09

### Added

- **Rule 07 performance and resource discipline** — Added explicit
  guidance for container resource budgeting, right-sizing from measured
  usage, allocation-aware hot-path design, connection pool sizing from
  real concurrency, and connection acquisition timeout discipline.

All changes are additive. Consuming repositories can adopt on a normal
minor-upgrade schedule.

---

## [v10.4.0] — 2026-04-09

### Added

- **Rule 05 security hardening** — Added security misconfiguration and
  fail-closed guidance covering default credentials, exposed debug
  surfaces, safe external error responses, CORS allow-list discipline, and
  SBOM retention for deployable artifacts.
- **Rule 06 validation hardening** — Added explicit review guidance for
  AI-generated tests and a requirement to turn production-discovered test
  gaps into regression tests when practical.

All changes are additive. Consuming repositories can adopt on a normal
minor-upgrade schedule.

---

## [v10.3.0] — 2026-04-09

### Added

- **Rule 04 observability expansion** — Added guidance for wide events
  and context-rich telemetry, continuous profiling as the fourth
  observability signal, AI and GenAI operational observability (model
  spans, token accounting, retrieval instrumentation, redaction), and
  backend-specific cardinality management.

### Changed

- **Rule 04 metrics section** — Clarified that high-cardinality
  restrictions apply specifically to time-series metric backends, with
  guidance to route investigative context to event or trace backends
  instead of dropping it.

All changes are additive. Consuming repositories can adopt on a normal minor-upgrade schedule.

---

## [v10.2.0] — 2026-04-09

### Added

- **Standards Coverage section in README.md** — OWASP Top 10 for Agentic Applications (2026) full coverage map (ASI01–ASI10) with explicit rule-to-category mappings. Summary table for NIST AI RMF, ISO/IEC 42001, IMDA Agentic AI Framework, and EU AI Act.
- **AI Governance Frameworks section in REFERENCES.md** — Source citations for OWASP Agentic Top 10, NIST AI RMF 1.0, NIST AI RMF Playbook, ISO/IEC 42001:2023, IMDA Agentic AI Framework (January 2026), and EU AI Act with Digital Omnibus caveat.
- **Rule 11: Agent identity and credential lifecycle** — Scoped least-privilege identities per agent, no credential passing between agents, time-bound tokens, credential exposure as a security incident, auditability requirement for agent identities and actions. Closes ASI03 (Identity & Privilege Abuse).
- **`scripts/governance-lint.sh`** — Heuristic code quality checks for consuming repositories: bare TODO/FIXME without issue reference, hardcoded localhost literals in production code, secret literal patterns, HTTP calls without explicit timeout (Python), and print()/console.log() in non-test source. Explicitly framed as heuristics with documented false-positive rates per check.

### Changed

- **REFERENCES.md** — AI review score tables moved into a `<details>` collapse block. Caveat ("not independent peer review") now precedes the tables rather than following them. Production-experience origin paragraph promoted above the score detail.
- **`.markdownlint.json`** — Added `"MD033": false` to permit `<details>` HTML in REFERENCES.md.

All changes are additive. Consuming repositories can adopt without a team review session (patch/minor rules apply).

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
