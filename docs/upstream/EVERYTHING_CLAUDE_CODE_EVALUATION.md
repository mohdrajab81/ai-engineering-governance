# Evaluation: `everything-claude-code`

## Purpose

This document evaluates the external repository
`affaan-m/everything-claude-code` as a possible source of ideas, files, or
patterns for future use in this governance pack.

The goal is selective adoption, not repo import.

## External Source

- Repository: `https://github.com/affaan-m/everything-claude-code`
- Relevant area reviewed:
  - root `README.md`
  - `agents/architect.md`
  - `agents/planner.md`
  - `agents/code-reviewer.md`
- License: MIT

## Current Recommendation

Do not adopt the external repository wholesale.

Do evaluate it as a source for:

- role-oriented agent prompts
- cross-harness adapter ideas
- packaging patterns for optional agent catalogs

Keep this repository's current governance core as the authoritative base.

## Why This Repository Is Interesting

The external repository is broader than a normal rules pack. It combines:

- role prompts and agent files
- skill catalogs
- harness adapters
- installation flows
- hook and runtime examples
- multi-tool support across Claude Code, Codex, Cursor, and others

That makes it useful as a reference for operational packaging and role surface
design, especially where this repository is currently strongest on governance
rules but lighter on reusable agent-role catalogs.

## Comparison With This Governance Pack

### What this repository already does well

The current `ai-engineering-governance` repository already has a strong core:

- root policy in `CLAUDE.md`
- cross-agent adapter in `AGENTS.md`
- deep domain rule files in `.claude/rules/`
- workflow and phased adoption documentation
- a clear governance-first philosophy

This is the current strength of the repository:

- engineering standards
- review discipline
- validation expectations
- session and slice completeness rules

### What the external repository adds

The external repository is stronger in:

- prebuilt role catalogs such as architect, planner, and code-reviewer
- cross-harness operational examples
- packaging surface for optional installation and adapters
- broader tool-facing structure for multiple agent harnesses

This is useful because it adds a reusable operator layer on top of the
governance core.

## What We Can Benefit From

## 1. Curated role prompts

The most immediately useful material is the small agent-role surface:

- `architect`
- `planner`
- `code-reviewer`
- language-specific reviewers later

These can help teams use the governance pack more consistently by giving them
reusable role-specific entry points rather than only a root rule pack.

## 2. Separation between core rules and optional catalogs

The external repository reinforces an important packaging lesson:

- keep the core rules small and authoritative
- keep optional agent catalogs separate and additive

This matches the direction this repository should take if it later grows beyond
the current rule pack.

## 3. Cross-harness adapter patterns

The external repository is useful as a reference for how one governance system
can present different adapter surfaces for:

- Claude Code
- Codex
- Cursor
- OpenCode

This is relevant for future expansion of this repository, but only after the
core governance model remains stable.

## 4. Install and packaging ideas

The repository contains useful ideas for:

- optional component installation
- namespaced adapter surfaces
- harness-specific configuration examples

These are useful as examples, not as a drop-in system.

## What We Should Not Adopt Directly

Do not adopt these parts wholesale:

- the full install/runtime system
- the large command catalog
- the large skill catalog
- the memory and learning subsystems
- the hook chain complexity
- the multi-agent orchestration runtime

Why:

- they add significant maintenance cost
- they assume a much larger operational surface than this repository needs
- they would blur the boundary between governance pack and harness platform
- they would make this repository harder to reason about and harder to audit

## Adoption Principle

Use the external repository as:

- a source of ideas
- a source of selectively copied or adapted files
- a benchmark for packaging and role organization

Do not use it as:

- a replacement for this repository
- an upstream to vendor wholesale
- the authority over this repository's governance philosophy

## Recommended Adoption Model

Use a three-layer model for future growth of this repository.

### Layer 1. Core governance

Keep the existing core as the authoritative base:

- `CLAUDE.md`
- `AGENTS.md`
- `.claude/rules/`
- workflow and adoption docs

This layer stays small, opinionated, and stable.

### Layer 2. Optional role catalog

Add a small curated role layer later, likely under a future path such as:

- `catalog/agents/`

or:

- `agents/`

This layer should contain only role files that were reviewed and adapted to
this repository's governance model.

### Layer 3. Optional harness adapters

Later, if needed, add adapter examples for:

- Claude Code
- Codex
- Cursor

These should live in an adapter-oriented surface such as:

- `adapters/claude/`
- `adapters/codex/`
- `adapters/cursor/`

The adapter layer must remain downstream of the governance core.

## Recommended First Curated Agents

The first five worth curating are:

### 1. `architect`

Why:

- useful for system design reviews
- useful when evaluating major feature placement
- aligns with existing ADR-driven decision discipline

Adaptation required:

- replace generic SaaS examples with governance-pack examples
- explicitly defer to `CLAUDE.md` and `.claude/rules/`
- remove any assumption that architecture advice outranks repository policy

### 2. `planner`

Why:

- good fit for converting broad work into stepwise plans
- compatible with existing validation-first workflow

Adaptation required:

- align plan structure with this repository's slice and validation rules
- point to `AI_AGENT_WORKFLOW.md` and `PHASED_ADOPTION.md`

### 3. `code-reviewer`

Why:

- useful as a reusable review lens
- complements the current governance rules well

Adaptation required:

- align output to this repository's review philosophy
- remove generic framework assumptions where unnecessary
- explicitly defer to project-specific policy when used downstream

### 4. `go-reviewer`

Why:

- useful because many consuming projects will be Go backends
- complements the current production proof point behind this governance pack

Adaptation required:

- align to this repository's language-specific rule layout
- ensure it remains additive to general review, not a parallel rule system

### 5. `typescript-reviewer`

Why:

- useful for frontend and web projects
- especially relevant if the governance pack is used in React/TypeScript codebases

Adaptation required:

- align with existing immutability, validation, and verification principles
- keep framework guidance subordinate to repository policy

## How To Merge Ideas Into This Repository

Use this merge strategy:

### Step 1. Evaluate first

Create an evaluation note before copying any external content.

This document is that first step.

### Step 2. Copy only small units

If material is adopted, copy one role file or one adapter idea at a time.

Do not import whole directories just because they are available.

### Step 3. Adapt immediately

Any adopted file must be rewritten to:

- defer to `CLAUDE.md`
- align to this repository's workflow and rule structure
- remove assumptions that belong only to the external repository

### Step 4. Attribute correctly

If a file is copied or substantially derived from the external repository:

- preserve the required MIT license notice
- record provenance in an attribution note, changelog entry, or file header as appropriate

### Step 5. Keep adoption additive

New role catalogs or adapters must not:

- duplicate the core rules
- contradict the core rules
- create a second competing authority layer

## Recommended Future Structure

If this repository expands to include curated agent roles and adapters, the
target shape should look more like this:

```text
ai-engineering-governance/
├── CLAUDE.md
├── AGENTS.md
├── .claude/
│   └── rules/
├── docs/
│   └── upstream/
├── catalog/
│   └── agents/
├── adapters/
│   ├── claude/
│   ├── codex/
│   └── cursor/
└── tasks/
```

This keeps the repository understandable:

- governance core first
- evaluation docs second
- optional role catalog third
- adapters fourth

## Phased Adoption Plan

### Phase 1. Evaluation only

Deliverable:

- this evaluation document

Commit scope:

- `docs/upstream/README.md`
- `docs/upstream/EVERYTHING_CLAUDE_CODE_EVALUATION.md`

Purpose:

- record the decision before any adoption

### Phase 2. Curated agent pilot

Deliverable:

- first curated role files only

Suggested scope:

- `architect`
- `planner`
- `code-reviewer`

Purpose:

- prove that a small role catalog adds value without destabilizing the core

### Phase 3. Language-specific reviewers

Deliverable:

- `go-reviewer`
- `typescript-reviewer`

Purpose:

- add practical value for common consuming repositories

### Phase 4. Adapter examples

Deliverable:

- optional harness examples for Codex, Cursor, or other environments

Purpose:

- widen adoption surface only after the role catalog proves stable

## Commit Strategy

Do not combine evaluation, role catalog creation, and adapter work in one commit.

Recommended commit order:

1. `docs: evaluate everything-claude-code for selective adoption`
2. `feat: add curated planning and review agent roles`
3. `feat: add initial language-specific review roles`
4. `docs: add adapter guidance for additional agent harnesses`

## License And Attribution

The external repository is MIT-licensed.

That means selective reuse is permitted, but copied or substantially derived
files should retain appropriate attribution and license notice.

Reference:

- `https://github.com/affaan-m/everything-claude-code/blob/main/LICENSE`

## Final Decision

Use `everything-claude-code` as a selective upstream reference.

Do not vendor it wholesale.

The first safe adoption path for this repository is:

- evaluation documents first
- curated role files second
- adapters later

That approach preserves the strongest quality of this repository today: a clear,
opinionated governance core.
