# AI Engineering Governance Pack

> *"Rules written by someone who has seen the failure, not someone who has read about it."*

A production-tested, deployable governance standard for AI-assisted software development. The repository includes 12 domain rule files, adapters for Claude Code, GitHub Copilot, and OpenAI Codex, and a copy-paste GitHub Actions governance check. Compatible with Cursor and any repository-level instruction system.

---

## Independent Review Scores

Three AI systems evaluated this pack independently across four dimensions. ChatGPT and Gemini were reviewed at v6 and v8. Claude was reviewed at v6, v8, and v9 using adversarial gap-closure methodology.

| Dimension | ChatGPT | Gemini | Claude (Sonnet 4.6) |
| --- | --- | --- | --- |
| Public standard coverage | 9.3 → **9.8** | 9.2 → **9.8** | 8.9 → 9.3 → **9.5** |
| Practical deployability | 9.1 → **9.6** | 9.7 → **10.0** | 8.7 → 9.2 → **9.6** |
| AI-agent governance quality | 9.6 → **9.9** | 9.8 → **10.0** | 9.1 → 9.5 → **9.7** |
| Production engineering depth | 9.8 → **9.9** | 9.8 → **10.0** | 9.4 → 9.7 → **9.8** |
| **Overall** | **9.5 → 9.8** | **9.4 → 9.9** | **9.0 → 9.4 → 9.7** |

*ChatGPT and Gemini scores: v6 → v8. Claude scores: v6 → v8 → v9. Claude used adversarial gap-closure methodology across all three versions. Reviewed March 2026.*

*These are review summaries from external review sessions. Score tables and quoted conclusions are preserved here; raw chat transcripts are not bundled in the repository.*

---

## Endorsements

**ChatGPT:**
> This package has improved meaningfully from the v6 version I previously reviewed. In the earlier version, I scored it at 9.5/10 overall because it was already unusually strong in production engineering depth, but it still had gaps in standards coverage, deployability coherence, and enforcement clarity. In v8, those gaps were addressed with targeted changes: the security rules are stronger, the adapter model is now drift-free, the workflow has a credible CI enforcement path, and the AI-agent controls cover more real operational failure modes. That moves the package to 9.8/10 overall and makes the improvement substantive, not cosmetic. What keeps it short of a perfect score is that some controls remain governance-by-instruction rather than hard technical policy enforcement. I recommend adopting v8 as a serious baseline for teams using AI coding agents in production repositories.

**Gemini:**
> The AI Engineering Governance Pack v8 successfully bridges the gap between AI coding assistants and enterprise-grade system reliability. The introduction of strict backpressure propagation, thundering herd mitigations, and explicit idempotency key design elevates the framework into battle-tested territory. The three-adapter approach is now completely coherent — AGENTS.md and copilot-instructions.md explicitly defer to CLAUDE.md as the single source of truth, eliminating rule drift. These targeted refinements have driven the overall evaluation score from 9.4 up to 9.9 out of 10. The framework distinctly separates mechanically enforceable rules from those requiring human or AI semantic judgment, making it an actionable execution engine rather than passive shelfware. Engineering teams deploying AI tools in mission-critical environments should adopt version 8 immediately.

**Claude (Sonnet 4.6):**
> I reviewed this governance pack across three major versions, scoring it 9.0/10 on v6, 9.4/10 on v8, and 9.7/10 on v9. Each version closed specific gaps I identified in the prior review — v9 addressed cross-service backpressure propagation, idempotency race conditions, SLSA progression criteria, and CI enforcement friction. The progression demonstrates a governance artifact being maintained with the same engineering discipline the pack itself demands: targeted fixes, no scope creep, each closure verifiable against the original gap statement. What distinguishes this pack from standards-derived checklists is operational specificity — rules name the exact failure mode, the mechanism that causes it, and the diagnostic signature, not just the symptom. I recommend v9 as a production baseline for any team using AI coding agents in stateful, high-throughput, or high-consequence systems.

---

## What This Pack Is

Most AI coding governance packs are assembled from public checklists. This one was written differently: the rules came from engineering judgment accumulated over 20+ years of operating carrier-grade telecom systems — real-time signaling at thousands of transactions per second, SMS gateways handling millions of messages per day, Kafka streaming pipelines under production load. Public standards were used as a validation layer afterward, not as the starting point.

The result is a governance system that covers what standards cover — and also covers what standards miss.

**Rules that appear in this pack but not in any published standard:**

- Out-of-order event delivery creating zombie sessions — and the tombstone/grace-period pattern that prevents it
- The explicit buffer decision required before closing any stateful I/O resource during transition
- Transactional outbox discipline — never send a message before its state change is committed
- Hot-loop telemetry: why an INFO log inside a tight loop is an I/O operation, not a debug aid
- The real cost of microservice boundaries as an engineering decision requiring justification
- Wire format as a first-class interface contract with versioning discipline before the first message
- Kafka partition key selection for session affinity and rebalance impact on in-flight sessions
- Idempotency key design — why auto-incremented IDs fail on retry and where to store the key

---

## Package Contents

### Core governance and adapter files

| File | Purpose |
| --- | --- |
| `CLAUDE.md` | Root policy — loaded into every AI coding session. Non-negotiables and working pattern. ~650 words. |
| `AI_AGENT_WORKFLOW.md` | Operational workflow — onboarding commands, task flow, done checklist, review template |
| `RULE_PLACEMENT.md` | Placement guide — separates what linters enforce from what agents need to read |
| `PHASED_ADOPTION.md` | Adoption guide — explains which rules apply immediately, contextually, or as later hardening |
| `AGENTS.md` | OpenAI Codex adapter — references CLAUDE.md as authority |
| `.github/copilot-instructions.md` | GitHub Copilot adapter — references CLAUDE.md as authority |
| `copilot-instructions.md` | Root-level pointer to the GitHub Copilot adapter path above, kept for discoverability without duplicating rules |
| `.claude/settings.example.json` | Example Claude Code permissions and post-edit hook configuration |
| `tasks/lessons.md` | Lessons-log template for capturing repeat failures and rule/process improvements |
| `CONTRIBUTING.md` | Contributor workflow for making focused, reviewable changes to the pack |
| `README.md` | This file |
| `REFERENCES.md` | Full provenance — standards, review history, production-experience origin |

### Domain rule files (`.claude/rules/`)

| File | Domain |
| --- | --- |
| `01-architecture.md` | Design, backward compatibility, distributed systems, wire formats |
| `02-concurrency.md` | Thread safety, lock discipline, state machines, atomic transitions |
| `03-resilience-networking.md` | Timeouts, retries, backoff, circuit breakers, bulkhead isolation |
| `04-observability.md` | Structured logging, metrics, traces, SLOs, burn-rate alerts, Kafka health |
| `05-security.md` | Input validation, authorization, CSRF, rate limiting, supply chain, SLSA |
| `06-testing-validation.md` | Test discipline, hermetic tests, replay/recovery tests, contract tests |
| `07-performance-resources.md` | Resource lifecycle, DB patterns, backpressure, thundering herd, idempotency |
| `08-change-management.md` | PR discipline, runbooks, expand-migrate-contract, feature flags |
| `09-readability-maintainability.md` | Naming, comments, cognitive load, dead code |
| `10-config-migrations.md` | Config externalization, feature flags, schema migrations, staged rollout |
| `11-ai-agent-verification.md` | Anti-hallucination, scope, trust boundaries, multi-agent chains, tool safety |
| `12-vertical-slice-completeness.md` | Cross-layer contract closure, compatibility paths, deprecated alias verification |

---

## How to Deploy

### For Claude Code

1. Place `CLAUDE.md` at the repository root
2. Create `.claude/rules/` and add the 12 domain files
3. Fill in the command table in `AI_AGENT_WORKFLOW.md` with your repo's actual commands
4. Configure CI to run build, lint, test, security scan, and the fill-me check — fail on errors
5. Optional: copy `.claude/settings.example.json` to `.claude/settings.json` and customize the allow-list, deny-list, and post-edit hook for your stack

**Sample GitHub Actions governance check** — copy this to `.github/workflows/governance-check.yml`:

```yaml
name: Governance Check
on: [push, pull_request]

jobs:
  governance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check command table is filled
        run: |
          if grep -E "^\|.*\| fill me \|" AI_AGENT_WORKFLOW.md; then
            echo "ERROR: AI_AGENT_WORKFLOW.md contains unfilled 'fill me' placeholders."
            echo "Complete the command table before merging."
            exit 1
          fi
          echo "Command table check passed."

      - name: Check no secrets in governance files
        run: |
          if grep -rE "(password|secret|token|api_key)\s*=\s*\S+" \
            README.md REFERENCES.md RULE_PLACEMENT.md AI_AGENT_WORKFLOW.md \
            CLAUDE.md AGENTS.md copilot-instructions.md \
            .github/copilot-instructions.md .github/workflows/governance-check.yml \
            .claude/rules/ 2>/dev/null; then
            echo "ERROR: Possible secret found in governance files."
            exit 1
          fi
          echo "Secret scan passed."
```

### For GitHub Copilot

1. Place the Copilot adapter at `.github/copilot-instructions.md`
2. Optional: keep a short root-level pointer file if you want the adapter to be visible from the repository root, but treat `.github/copilot-instructions.md` as the only live instruction file

### For OpenAI Codex

1. Place `AGENTS.md` at the repository root

### For any agent

The non-negotiables in `CLAUDE.md` apply to all agents. The domain files are the detail layer — load them when working in the relevant domain.

---

## Adoption Strategy

This pack is comprehensive. Dropping it on a team all at once risks it becoming shelfware.

**Recommended three-stage adoption:**

**Day 1 — Non-negotiables only:**
Enforce only the non-negotiable rules in `CLAUDE.md`: backward compatibility, no hardcoded secrets, explicit timeouts, bounded retry, no sensitive data in logs, no invented APIs, no false validation claims, human review before merge.

**Week 1 — Domain files as reference:**
Point developers to domain files when they are working in that area. Working on a database migration? Read `10-config-migrations.md`. Building concurrent code? Read `02-concurrency.md`. The domain files are a reference library, not a reading assignment.

**Ongoing — Living standard:**
When an AI agent repeatedly makes the same mistake or a new pattern is discovered, update the relevant domain file as a standalone task with its own review. Rule files are governance artifacts — treat them with the same discipline as code.

See [PHASED_ADOPTION.md](./PHASED_ADOPTION.md) for the fuller model, including which domain files should activate only when the relevant layer exists and how to use [tasks/lessons.md](./tasks/lessons.md) to drive rule updates from real failures instead of abstract policy debates.

---

## Governance Pack Versioning

This pack follows semantic versioning. Record the version you adopted in your repository — for example in a `docs/ai-governance/VERSION` file.

**Patch versions (x.x.N):** Rule clarifications, typo fixes, example additions. Safe to adopt without a team review session.

**Minor versions (x.N.0):** New rules or new domain files. Review new rules with the team before adopting. No existing rules are removed or weakened.

**Major versions (N.0.0):** Breaking changes to rule structure, non-negotiable changes, or removal of rules. Require an explicit team decision before upgrading.

A consuming team that has customized domain files should treat those customizations as a local fork and review each update against their changes before merging.

For contribution workflow inside this repository, see [CONTRIBUTING.md](./CONTRIBUTING.md).

---

## What Reviewers Said This Pack Does Better Than Standards-Only Checklists

- Governs AI coding agents the way experienced engineers govern real systems: with rules shaped by failure, not just by frameworks
- Contains rules that prevent failures teams only learn about after incidents — not after reading documentation
- Separates mechanically enforceable rules from judgment calls, keeping context windows lean and agent behavior focused
- Covers the full engineering lifecycle including AI-specific failure modes that generic governance packs miss entirely
- The rules are falsifiable — they name the failure mode, the mechanism, and the diagnostic signature, not just the symptom

---

## Author

**Mohammad Rajab** — Senior Technical Product Owner | Enterprise Solutions Architect | AI Transformation Lead

20+ years in carrier-grade telecom platforms. PMP, Azure AI-102, AI-900 certified.

[LinkedIn](https://www.linkedin.com/in/mohammad-rajab-a2b39822/) | [GitHub](https://github.com/mohdrajab81)

---

## License

MIT — use freely, adapt to your stack, keep the spirit of the rules.
