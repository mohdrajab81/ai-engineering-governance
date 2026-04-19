# Landscape Review: Coding-Agent Governance Ecosystem

Reviewed: April 19, 2026

Review cadence: revisit at least quarterly or when a major upstream release
changes scope materially.

## Purpose

This document compares the most relevant adjacent repositories and frameworks to
this governance pack.

The goal is not to choose a winner or replace this repository. The goal is to
keep this pack sharply scoped, identify what should be borrowed, and document
where stronger adjacent systems can compose with it.

## Scope of This Repository

This repository is an implementation-layer governance pack. It is designed to
make coding agents disciplined by default during software implementation and
review:

- working pattern and validation discipline
- architecture, concurrency, resilience, observability, security, and testing
  rules
- slice-completeness, exit-evidence, and session-handoff expectations
- portable adapter files for multiple AI coding tools

It is not:

- a runtime enforcement engine
- a delivery daemon or multi-process orchestration runtime
- an enterprise governance dashboard or registry

## Decision Summary

| Repository | Primary role | Relationship to this pack | Current recommendation |
| --- | --- | --- | --- |
| `Fr-e-d/GAAI-framework` | Delivery governance and cross-session agent operating model | Nearest peer and strongest composition target | Study actively; borrow positioning and lifecycle-separation ideas; do not import runtime orchestration wholesale |
| `microsoft/agent-governance-toolkit` | Runtime enforcement and agent action control | Strong adjacent enforcement layer | Reference as complementary; do not expand this repo into runtime enforcement |
| `sebuzdugan/frai` | Governance automation CLI and SDK | Useful automation direction | Borrow optional artifact-generation ideas only |
| `alan-turing-institute/AssurancePlatform` | Assurance-case structure and evidence framing | Strong structural influence | Borrow assurance and evidence patterns adapted to this repo's own rule categories |
| `verifywise-ai/verifywise` | Enterprise AI governance platform | Different product category | Borrow evidence-center and traceability language only; do not follow product direction |

## Comparative Assessment

### 1. `Fr-e-d/GAAI-framework`

Repository: <https://github.com/Fr-e-d/GAAI-framework>

What it is:

- a `.gaai/` folder dropped into a project
- separate Discovery and Delivery roles
- backlog-driven execution contract
- persistent project memory
- optional autonomous delivery daemon and tool adapters

What it adds beyond this repository:

- governance of what gets built before implementation starts
- explicit separation between scope definition and execution
- cross-session delivery discipline and execution queues

Overlap with this repository:

- agent governance
- tool adapters
- workflow and rule surfaces
- documentation-first operational model

Why it matters:

- this is the closest open-source peer in coding-agent governance
- it solves an adjacent lifecycle problem, not the same one
- this pack can sit inside a GAAI-driven delivery flow as the
  implementation-governance layer

What to borrow:

- clearer explanation of lifecycle separation:
  - what gets built
  - how implementation is governed
  - what proves the work is done
- more explicit composition language in README and upstream docs
- backlog/contract framing as an external integration example, not as a core
  requirement of this pack

What not to adopt:

- delivery daemon
- tmux-driven orchestration
- framework-specific autonomous runtime assumptions
- large skill/runtime surface

Recommendation:

- treat GAAI as the nearest peer and the most natural integration target
- keep this repository smaller and more portable than GAAI

### 2. `microsoft/agent-governance-toolkit`

Repository: <https://github.com/microsoft/agent-governance-toolkit>

What it is:

- deterministic runtime governance for autonomous agents
- policy engine, zero-trust identity, sandboxing, and agent SRE
- OWASP Agentic Top 10 runtime controls and verification tooling

What it adds beyond this repository:

- hard enforcement at action time
- runtime policy checks and audit logs
- identity, trust, kill-switch, and sandboxing surfaces

Overlap with this repository:

- both care about agent safety and governance
- both describe trust boundaries and failure control

Critical distinction:

- this repository governs how a coding agent should behave while planning,
  changing, validating, and reporting software work
- AGT governs whether an agent action is allowed to execute at runtime

What to borrow:

- wording that explains soft guidance versus hard enforcement cleanly
- references showing where stronger enforcement belongs

What not to adopt:

- policy engine implementation
- identity runtime
- sandboxing runtime
- agent fleet dashboard

Recommendation:

- position AGT as a stack-on enforcement layer, not as a competitor
- do not widen this repository into an enforcement platform

### 3. `sebuzdugan/frai`

Repository: <https://github.com/sebuzdugan/frai>

What it is:

- CLI plus SDK for scanning repositories, generating model cards, risk files,
  evaluation reports, and RAG indexes

What it adds beyond this repository:

- optional automation for evidence collection and standardized artifact output
- CI-friendly generation workflows

Overlap with this repository:

- governance artifacts
- evidence and evaluation language
- AI-risk documentation

What to borrow:

- optional automation direction for generated evidence artifacts
- examples of scan-to-report workflows

What not to adopt:

- turning the core pack into an SDK or CLI product
- requiring generated artifacts for basic pack adoption

Recommendation:

- keep automation optional and downstream of the core pack

### 4. `alan-turing-institute/AssurancePlatform`

Repository: <https://github.com/alan-turing-institute/AssurancePlatform>

What it is:

- a collaborative system for building assurance cases with explicit claims,
  evidence, and reasoning

What it adds beyond this repository:

- a stronger structure than generic best-practice checklists
- explicit evidence framing for high-risk changes

Overlap with this repository:

- evidence-backed validation
- phase and slice completion claims
- governance by explicit criteria rather than intuition

What to borrow:

- assurance-case structure adapted to this repo's own rule categories
- explicit claim/evidence/risk/residual-gap pattern for high-risk changes

What not to adopt:

- full platform workflow
- product-style collaboration surface

Recommendation:

- this is the strongest structural idea to borrow into the pack itself

### 5. `verifywise-ai/verifywise`

Repository: <https://github.com/verifywise-ai/verifywise>

What it is:

- an enterprise AI governance platform with inventories, risks, evidence,
  incidents, reporting, and framework mappings

What it adds beyond this repository:

- evidence center concept
- traceability and inventory thinking
- governance reporting vocabulary

Overlap with this repository:

- governance evidence
- framework alignment language

Why it is not a direct peer:

- it is a product platform, not a portable coding-agent governance pack

What to borrow:

- evidence-center and traceability phrasing where it helps explain downstream
  usage

What not to adopt:

- dashboards
- inventories
- incident-management product scope
- enterprise workflow product direction

Recommendation:

- treat it as inspiration for evidence language only

## What This Repository Should Add

The next additions with the best signal-to-scope ratio are:

1. Positioning updates that explain composition with delivery-governance and
   runtime-enforcement systems
2. A native assurance/evidence template for high-risk changes
3. Optional future examples showing how this pack can be used inside a broader
   workflow such as GAAI

## What This Repository Should Not Become

Do not expand this repository into:

- a delivery daemon
- a multi-agent runtime platform
- a policy-enforcement engine
- an enterprise audit dashboard
- a mandatory CLI or SDK product

Those are valid products and frameworks. They are not this repository's job.

## Current Positioning Statement

This repository should be positioned as the implementation-layer governance pack
that makes coding agents disciplined by default and composable with stronger
enforcement systems by design.

## Freshness Warning

This document reflects upstream repositories reviewed on or before April 19,
2026. Repositories in this area evolve quickly. Re-check current repository
state, releases, and scope before making a substantive adoption decision based
on this document.
