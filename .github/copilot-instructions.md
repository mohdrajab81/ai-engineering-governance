# GitHub Copilot Instructions

This repository uses a structured AI engineering governance pack. The authoritative rules are in `CLAUDE.md` at the repository root. They apply to all agents including Copilot. The rules are not duplicated here to prevent silent divergence — if CLAUDE.md and this file ever conflict, CLAUDE.md is the authority.

## Core rules

Read `CLAUDE.md` for the full non-negotiable rules and working pattern.

## AI-specific rules

- Keep suggested changes small and reviewable. If a task requires a large change, suggest decomposing it first.
- If a task spans multiple sessions or context is incomplete, read the tracked handoff artifact (`tasks/handoff-<topic>.md`) before continuing rather than guessing at prior state.

## Required before suggesting code

- Confirm the change is within the stated task scope.
- Identify affected callers, downstream consumers, and contracts.
- Ensure any new external call has a timeout and appropriate error handling.
- Ensure any new shared state has a documented synchronization strategy.

## Domain guidance

Full domain rules are in `.claude/rules/`. For security-sensitive, concurrency-sensitive, or migration-related changes, consult the relevant domain file before suggesting code. For any change touching a cross-layer contract (API, event, interface, schema), consult Rule 12. For phase or milestone closure, consult Rule 13. For multi-session or multi-agent work, consult Rule 14.

## Human review

All Copilot-suggested code must be reviewed by a human before merge. Copilot review supplements, not replaces, human judgment.
