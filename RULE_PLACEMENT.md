# Rule Enforcement Placement Guide

Where each type of rule should live and who enforces it.

## Principles

- **CLAUDE.md** (project root): static, project-wide rules the agent cannot infer from code. Keep under 650 words. The higher limit vs. the original 500 reflects two mandatory AI-verification non-negotiables that belong at root level.
- **.claude/rules/*.md**: detailed domain rules loaded on demand when relevant.
- **Supporting governance artifacts**: rollout, lessons, and local settings examples belong in separate docs, not in rule files.
- **Linters, formatters, CI tools**: anything checkable deterministically. Never duplicate in instruction files.
- If a tool can enforce it, let the tool enforce it. Reserve instruction files for judgment calls.

## Placement Table

| Rule Category | CLAUDE.md | .claude/rules/ | Linter / CI / Tools |
| --- | --- | --- | --- |
| Project overview and commands | Yes — repo purpose, stack, canonical commands | | |
| Working pattern (plan - implement - validate) | Yes — required task flow | | |
| Backward compatibility default | Yes — non-negotiable rule | 01-architecture — expanded guidance, breaking-change procedure | |
| No hardcoded secrets | Yes — non-negotiable rule | 05-security — expanded guidance | Secret scanners (gitleaks, trufflehog) |
| Explicit timeouts on external calls | Yes — non-negotiable rule | 03-resilience-networking — protocol details | |
| Retry with bounded backoff | Yes — non-negotiable rule | 03-resilience-networking — failure classification | |
| Separation of concerns | Yes — brief mention | 01-architecture — layer definitions | |
| Concurrency and thread safety | Yes — summary principles | 02-concurrency — specific primitives, lock ordering, cancellation | Thread-safety analyzers where available |
| Resource management and cleanup | | 07-performance-resources — pooling, lifecycle, leak monitoring | |
| Code readability and structure | Brief mention (clean, no over-engineering) | 09-readability-maintainability — naming clarity, cognitive load, comments | Linters and formatters for syntax only |
| Naming conventions — syntax | | | Linters — language-specific casing rules |
| Naming conventions — semantic clarity | | 09-readability-maintainability — intention-revealing names | Human / AI review |
| Indentation and formatting | | | Formatters — deterministic, no AI needed |
| Comments and documentation — quality | | 09-readability-maintainability — explain why, not what | Human / AI review |
| Comments and documentation — sync with behavior | Brief mention (update docs when behavior changes) | 08-change-management — docs in sync with code | |
| Logging and observability — logs | Yes — structured logs, correlation keys, no sensitive data | 04-observability — severity levels, session correlation, privacy | |
| Logging and observability — metrics and traces | Yes — one-line anchor (emit metrics, propagate trace context) | 04-observability — metrics, traces, SLO intent, sampling | APM tools, OpenTelemetry collectors |
| Error handling | Yes — classify failures, surface safe errors | 03-resilience-networking — retry, idempotency, deadline budgets | |
| Testing expectations | Yes — define tests before coding, validate before done | 06-testing-validation — coverage, API review, determinism | CI test runners, coverage tools |
| Security constraints — secrets and defaults | Yes — no secrets in code/logs, secure defaults | 05-security — input validation, dependency hygiene | SAST, DAST, dependency scanners |
| Security constraints — authorization | | 05-security — enforce at every protected operation | SAST, runtime policy checks |
| Security constraints — output encoding | | 05-security — encode by target context | SAST |
| Performance and networking | | 07-performance-resources — batching, streaming, perf baselines | Profilers, load testing tools |
| API and library usage | Yes — review overloads, explain choices, no unverified deps | 06-testing-validation — expanded guidance | |
| Change management and git | Brief mention (small commits, validate before merge) | 08-change-management — PR discipline, refactor vs. behavior | CI pipelines, branch protection |
| Build and format enforcement | | | CI — fail on lint / format / build errors |
| Dependency and supply chain | | 05-security — trusted libs, version pinning, provenance | Dependency scanners, lockfile audit |
| Configuration and environment | Yes — no hardcoded values | 10-config-migrations — externalized config, startup validation | Secret scanners, env validators |
| Schema / API / event migrations | Brief mention in 01-architecture | 10-config-migrations — expand-migrate-contract pattern | Migration runners, contract test CI |
| Feature flags and staged rollout | | 10-config-migrations — flag ownership, defaults, removal plan | Feature flag platforms |
| AI-agent verification / anti-hallucination | Yes — two explicit non-negotiables | 11-ai-agent-verification — full guidance | None — pure judgment |
| Readability and maintainability | Brief mention (clean, no over-engineering) | 09-readability-maintainability — full guidance | Linters for syntax; human review for judgment |
| Vertical slice completeness — contract layers | | 12-vertical-slice-completeness — field, route, event, schema, interface, deprecated alias checks, documentation surfaces | Human / AI review |
| Phase and milestone closure evidence | | 13-slice-exit-evidence — deliverable existence, wiring, validation, completion note | Human / AI review |
| AI session boundary and memory management | | 14-ai-session-memory — context pressure, checkpointing, handoff, resume discipline | Human / AI review |
| Domain-specific rules (telecom, fintech, etc.) | | domain/*.md — extend base rules; never modify base files for domain concerns | Human review |

## How to Read This

- **CLAUDE.md**: loaded into every AI coding session automatically. It holds principles and hard constraints only.
- **.claude/rules/**: loaded when the agent works on a relevant topic. They hold the detail, examples, and edge cases.
- **PHASED_ADOPTION.md**: maintainer guidance for sequencing governance rollout. Not a runtime instruction file.
- **tasks/lessons.md**: maintainer log for lessons learned and future rule updates. Not a runtime instruction file.
- **.claude/settings.example.json**: optional local Claude Code configuration example. Operational helper, not a policy source.
- **Linter / CI / Tools**: enforced mechanically. Do not repeat in instruction files — it wastes context tokens and creates drift when tools and instructions diverge.
- Some rules appear in multiple columns. CLAUDE.md holds the principle, the rule file holds the detail, CI enforces the check. They complement, not duplicate.
- This file is a governance-maintainer document. It is not loaded by agents at runtime. Store it in `docs/ai-governance/` or the repository root alongside CLAUDE.md.
