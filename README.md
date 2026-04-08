# AI Engineering Governance Pack

> *"Rules written by someone who has seen the failure, not someone who has read about it."*

---

## The Problem This Solves

Most teams using AI coding agents follow the same implicit workflow: write a prompt, review the output, merge if it looks right. This is prompt-and-hope development. It produces plausible-looking code that invents library calls that do not exist, claims tests pass without running them, silently expands scope, and misses structural gaps that compile cleanly and only surface at runtime or in production.

The statistics are not ambiguous. AI-generated code introduces 1.7× more total issues and 1.75× more logic errors than human-written code across production systems. Approximately 25–30% of AI-generated code contains Common Weakness Enumerations. Only 3% of developers highly trust AI-generated code; 71% never merge without manual review.

The problem is not the AI. The problem is the absence of governance. An AI agent operating without rules will follow the path of least resistance — generating output that satisfies the prompt without satisfying the engineering requirements that the prompt did not mention.

This pack is the governance layer. It tells the agent what the rules are, where the boundaries are, and what counts as done — so that AI-assisted development produces the same quality standards as human-reviewed engineering.

---

## Proven in Production

This pack was used as the primary governance framework for building a production-grade dual-RAT Cell Broadcast Centre — two protocol stacks (SBc-AP/SCTP and CBSP/TCP), a transactional dispatch engine, 14 database migrations, a full REST and WebSocket API, and 670 automated tests. The build was completed by a team of one engineer in approximately one week, working in a language used for the first time on this project.

The outcome — zero data races, fail-closed dispatch with AMBIGUOUS outcome detection, a consolidated architecture decision record, and complete documentation at every layer — was not accidental. It was the direct result of applying the rules in this pack consistently across every AI session.

Every rule that was applied produced the outcome the rule was designed to produce. Every gap that caused friction was a gap in the framework, not in the project.

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
- AI session boundary management — why context loss mid-task is an active hazard, not a minor inconvenience

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
| `12-vertical-slice-completeness.md` | Contract-layer completeness — code layers, documentation surfaces, deprecated aliases |
| `13-slice-exit-evidence.md` | Phase and milestone closure evidence — deliverable existence, wiring, validation, completion note format |
| `14-ai-session-memory.md` | Session boundary management, context pressure, progress checkpointing, session handoff |

---

## How to Deploy

### For Claude Code

1. Place `CLAUDE.md` at the repository root
2. Create `.claude/rules/` and add the 14 domain files
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

      - name: Check all rule files exist
        run: |
          EXPECTED=14
          ACTUAL=$(ls .claude/rules/*.md 2>/dev/null | wc -l)
          if [ "$ACTUAL" -ne "$EXPECTED" ]; then
            echo "ERROR: Expected $EXPECTED rule files in .claude/rules/, found $ACTUAL."
            exit 1
          fi
          echo "Rule file count check passed: $ACTUAL files."

      - name: Validate settings.example.json
        run: |
          python3 -m json.tool .claude/settings.example.json > /dev/null
          echo "settings.example.json is valid JSON."

      - name: Lint markdown governance files
        run: |
          npm install -g markdownlint-cli --silent
          markdownlint "**/*.md" --ignore node_modules
          echo "Markdown lint passed."

      - name: Check no secrets in governance files
        run: |
          if grep -rE "(password|secret|token|api_key)\s*=\s*\S+" \
            README.md REFERENCES.md RULE_PLACEMENT.md AI_AGENT_WORKFLOW.md \
            CLAUDE.md AGENTS.md copilot-instructions.md \
            .github/copilot-instructions.md .github/workflows/governance-check.yml \
            .github/PULL_REQUEST_TEMPLATE.md \
            .claude/settings.example.json \
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

### Domain adapters

The 14 domain rule files cover general software engineering. Every domain has additional critical rules that do not belong in a generic pack.

The extension pattern:

1. Create a `domain/` directory alongside `.claude/rules/`
2. Add domain-specific rule files: `domain/telecom.md`, `domain/fintech.md`, `domain/healthcare.md`, or equivalent
3. Reference domain files from `CLAUDE.md` with a note that they extend, not replace, the base rules
4. Domain files follow the same placement principles as base rules: judgment calls and constraints the agent cannot infer from code; nothing that a linter or CI tool can enforce mechanically

Domain-critical rules that belong in a domain file, not in the base pack: platform-specific API verification requirements, regulatory constraints, safety-critical failure modes specific to the industry, domain-specific encoding or protocol rules.

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
