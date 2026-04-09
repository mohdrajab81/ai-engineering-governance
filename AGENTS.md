# AGENTS.md — AI Engineering Governance

This repository uses a structured governance pack for AI coding agents. The authoritative rules are in `CLAUDE.md` (root policy) and `.claude/rules/` (domain rules). These apply to all AI agents, not only Claude.

## Non-negotiable rules

The authoritative non-negotiable rules are defined in `CLAUDE.md` at the repository root. Read `CLAUDE.md` for the full rule set and working pattern. If `CLAUDE.md` and this file ever conflict, `CLAUDE.md` is the authority.

## Required working pattern

1. Restate the task in implementation terms.
2. List affected files, callers, downstream impact, and risks.
3. For any non-trivial change, propose a short plan before editing.
4. Define validation before coding.
5. Implement in small, reviewable steps.
6. Report exactly what changed, what was tested, and what remains unverified.

## Recommended source order

On the first non-trivial task in a repository, prefer this reading order:

1. repository `README`
2. current implementation or execution plan
3. current technical baseline, if the repo keeps one
4. current consolidated decision layer, if the repo keeps one
5. live contract files such as `openapi`, shared interfaces, schemas, migrations, or equivalent

The goal is to understand:

- what the system currently is
- what is planned next
- which engineering choices are intentionally fixed
- which contracts are authoritative

For resumed or multi-session tasks, also read `tasks/handoff-<topic>.md` if one exists before making any changes.

## Conflict order

If repository documents conflict, resolve them in this order:

1. live contracts and code-enforced boundaries
2. current decision and baseline documents
3. implementation plans and workflow docs
4. historical notes, tutorials, archived docs, or old phase documents

Do not treat historical material as if it were current source of truth.

## Current-vs-historical docs rule

If a repository contains both active docs and historical material:

- use current-facing docs for decisions and implementation work
- keep historical docs for context only
- when current docs are restructured, remove stale references from active navigation
- if older ADRs or phase notes become noisy, prefer one maintained current decision surface over many half-current files

## Domain rules

Detailed rules for each domain are in `.claude/rules/`:

| File | Domain |
| --- | --- |
| 01-architecture.md | Design, separation of concerns, distributed systems |
| 02-concurrency.md | Thread safety, state machines, atomic transitions |
| 03-resilience-networking.md | Timeouts, retries, circuit breakers |
| 04-observability.md | Logs, metrics, traces, SLOs |
| 05-security.md | Input validation, authorization, supply chain |
| 06-testing-validation.md | Test discipline, replay/recovery tests |
| 07-performance-resources.md | Resource management, DB patterns, load testing |
| 08-change-management.md | PR discipline, runbooks, migrations |
| 09-readability-maintainability.md | Naming, comments, cognitive load |
| 10-config-migrations.md | Config, feature flags, schema migrations |
| 11-ai-agent-verification.md | Anti-hallucination, scope, trust boundaries |
| 12-vertical-slice-completeness.md | Cross-layer contract closure, compatibility paths, deprecated alias verification, documentation surface updates |
| 13-slice-exit-evidence.md | Phase and milestone closure — deliverable existence, wiring, evidence, completion note |
| 14-ai-session-memory.md | Session boundary management, checkpointing, handoff, resume discipline |

Consult Rule 13 before declaring any phase, slice, or milestone complete. Consult Rule 14 before ending any session with incomplete high-risk work or before resuming a task that ran in a prior session.

## Human review

AI-generated code must be reviewed by a human before merge. This applies regardless of test coverage or apparent correctness.
