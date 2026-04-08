# Phased Adoption Guide

This document explains how to adopt the governance pack without turning it into shelfware.

The pack is intentionally comprehensive. Not every rule belongs in day-one enforcement, and not every file is a runtime instruction file. Teams get better results when they adopt the pack in layers.

## Core idea

Use three categories:

- **Apply from day one** for non-negotiable safety and anti-hallucination rules.
- **Apply when the layer exists** for domain guidance that only becomes meaningful once a database, network client, migration path, or state machine exists.
- **Apply as hardening** for rollout, observability depth, and production-operations controls that are real requirements, but only once the system itself exists.

This is not a weakening of the pack. It is a sequencing model that keeps the rules credible and enforceable.

## Minimal Context Principle

Repository context files help only when they stay small, specific, and relevant to the task. Two 2026 arXiv studies point in the same direction from different angles: `AGENTS.md` can reduce runtime and token usage when present and focused, but broader context files can reduce task success and raise inference cost when they add unnecessary requirements. The practical rule is simple: keep root context minimal and move detail into files that are loaded only when relevant.

Use this checklist before adding new always-read context:

- Does this requirement need to be read on nearly every task?
- Is this a hard constraint, not a preference or repository history lesson?
- Can this live in a domain file, workflow doc, or supporting artifact instead?
- Will adding this text improve execution more than it increases context load?

If the answer is unclear, do not add it to root context yet.

## Day-one adoption

Apply these immediately:

- `CLAUDE.md` non-negotiables
- `AI_AGENT_WORKFLOW.md`
- `11-ai-agent-verification.md`
- `14-ai-session-memory.md`
- relevant parts of `01-architecture.md`
- relevant parts of `06-testing-validation.md`
- relevant parts of `09-readability-maintainability.md`

Why:

- These rules prevent the most damaging AI-agent failures even in the first repository session.
- They do not depend on a specific runtime architecture or deployment model.
- Rule 14 applies from the very first multi-session task: session boundary failures can occur on day one and are invisible until they produce conflicting or incomplete output.

## Apply when the layer exists

Bring these files into active use as the corresponding layer appears:

| File | Activate when | Why |
| --- | --- | --- |
| `02-concurrency.md` | Shared mutable state, background workers, or lifecycle state machines exist | Concurrency rules are meaningless until real state transitions exist |
| `03-resilience-networking.md` | The repo makes external network calls or depends on remote services | Retry, deadline, and circuit-breaker guidance only matters at boundaries |
| `05-security.md` | Secrets, authz, input handling, or data persistence enter the system | Security is always relevant, but several controls become concrete only when the boundary exists |
| `07-performance-resources.md` | DB access, connection pools, batching, or throughput concerns appear | Resource rules should follow actual bottlenecks, not imagined ones |
| `10-config-migrations.md` | Config files, flags, migrations, or staged schema changes exist | Migration discipline starts when something can actually be migrated |
| `12-vertical-slice-completeness.md` | The first contract surface appears — an API route, event type, interface method, or shared data structure | Cross-layer closure checks are meaningless before contracts exist; once the first contract exists, every subsequent one needs this checklist |
| `13-slice-exit-evidence.md` | The project adopts phased or milestone-driven work | Evidence requirements for phase closure are irrelevant before phases are defined; once phases exist, exit criteria must be explicit |

## Apply as hardening

These rules matter most once the system is already functional:

| File | Typical adoption point | Why |
| --- | --- | --- |
| `04-observability.md` | Service is running in shared or production-like environments | Rich metrics, tracing, and SLOs are most valuable once behavior exists to observe |
| `08-change-management.md` | The team is rolling out changes across environments or operators | Runbooks, staged rollout, and change windows matter when real change management begins |

This does not mean "ignore them until late." It means adopt the parts that are real now, then deepen them as the system matures.

## Supporting artifacts

These files support governance adoption but are not runtime rule files:

| File | Purpose |
| --- | --- |
| `RULE_PLACEMENT.md` | Explains what belongs in root policy, domain rules, and deterministic tooling |
| `tasks/lessons.md` | Captures recurring mistakes, root causes, and rule/process updates |
| `.claude/settings.example.json` | Example local permissions and hook configuration for Claude Code |

## Practical rollout sequence

1. Install `CLAUDE.md`, `.claude/rules/`, `AGENTS.md`, and the Copilot adapter.
2. Fill in `AI_AGENT_WORKFLOW.md` with real commands before code work starts.
3. Use `tasks/lessons.md` to capture recurring agent mistakes and process failures.
4. Activate domain files as the matching layer becomes real.
5. Add stronger observability, security enforcement, and change-management controls as the system approaches shared or production use.

## What this prevents

Without phased adoption:

- teams ignore the pack because it feels too heavy for bootstrap work
- agents are told to obey rules that are not yet grounded in real code
- governance becomes aspirational instead of operational

With phased adoption:

- safety rules still apply immediately
- domain rules are introduced when they become concrete
- later-phase controls stay visible, but they are treated as deferred requirements with a real deadline
