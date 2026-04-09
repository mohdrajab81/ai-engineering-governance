# Reference Notes

This package was shaped around current public guidance from the following sources, validated through multi-round AI alignment reviews by Claude, ChatGPT, and Gemini across nine iterations (v1–v9).

## AI Agent Instruction Standards

- **Anthropic** — Claude Code Best Practices, CLAUDE.md documentation, and project memory guidance (docs.anthropic.com)
- **OpenAI** — Codex Best Practices and AGENTS.md persistent repository context guidance
- **OpenSSF** — Security-Focused Guide for AI Code Assistant Instructions (best.openssf.org)
- **GitHub** — Repository-wide and path-specific Copilot custom instructions; responsible use guidance stating AI review must supplement, not replace, human review
- **arXiv:2601.20404** — *On the Impact of AGENTS.md Files on the Efficiency of AI Coding Agents* — empirical study across 10 repositories and 124 pull requests; reports lower median runtime and lower token use when `AGENTS.md` is present and focused
- **arXiv:2602.11988** — *Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?* — finds broader context files can reduce task success and raise inference cost; concludes that human-written context files should describe only minimal requirements

## Code Quality and Engineering Practices

- **Google** — Engineering Practices: Code Review Developer Guide — design, complexity, naming, comments, tests, documentation
- **Google SRE** — Site Reliability Engineering: SLO/error-budget discipline, burn-rate alerting, release freeze on budget exhaustion
- **Atlassian** — User Stories and Acceptance Criteria guidance
- **Martin Fowler** — Parallel Change / Expand-Migrate-Contract pattern for safe backward-incompatible changes; Monolith First guidance on cautious service decomposition; Transactional Outbox pattern for atomic state and messaging

## Resilience and Reliability

- **AWS** — Guidance on timeouts, retries, exponential backoff with jitter, capped retry counts, and overload control
- **AWS SDK** — Explicit guidance on jittered exponential backoff and circuit-breaking behavior for distributed retry patterns
- **AWS Operational Excellence** — Runbook and playbook discipline for critical operations and major releases

## Observability

- **OpenTelemetry** — Observability specification covering logs, metrics, traces, and context propagation as a correlated signal system; guidance on sampling and performance overhead of instrumentation; semantic conventions for resource attributes

## Security

- **OWASP** — Input validation, authorization as a distinct control from authentication, contextual output encoding, secure logging, session correlation, and safe error handling cheat sheets
- **SLSA** — Software supply-chain integrity controls (referenced for dependency provenance context)

## AI Governance Frameworks

- **OWASP Top 10 for Agentic Applications (2026)** — The agentic security risk framework, covering ASI01 Agent Goal Hijack through ASI10 Rogue Agents. The full coverage map is in [README.md](./README.md). Source: [genai.owasp.org](https://genai.owasp.org/resource/owasp-top-10-for-agentic-applications-for-2026/)

- **NIST AI Risk Management Framework (AI RMF 1.0)** — Four core functions: GOVERN, MAP, MEASURE, MANAGE. The governance pack operates at the GOVERN and MEASURE level for engineering teams — establishing rules, reviewing AI outputs, and measuring adherence. Source: [NIST AI RMF 1.0](https://airc.nist.gov/RMF/1)

- **NIST AI RMF Playbook** — Supplementary subcategory guidance for implementing trustworthy AI properties (accurate, explainable, privacy-enhanced, reliable, safe, secure, resilient, transparent). Source: [NIST AI RMF Playbook](https://airc.nist.gov/Docs/2)

- **ISO/IEC 42001:2023** — International standard for AI management systems. Defines requirements for establishing, implementing, maintaining, and continually improving an AI management system. The governance pack provides the engineering-layer controls that an ISO 42001 implementation requires at the team and codebase level.

- **IMDA Agentic AI Framework (January 2026)** — Singapore's national framework for responsible deployment of agentic AI systems, covering trust architecture, human oversight requirements, and accountability for autonomous agent actions. Directly relevant to the multi-agent pipeline rules in Rule 11. Source: [IMDA Agentic AI Framework](https://www.imda.gov.sg/resources/press-releases-factsheets-and-speeches/press-releases/2026/imda-launches-agentic-ai-framework)

- **EU AI Act (Regulation EU 2024/1689)** — The baseline application date under the current regulation is 2 August 2026. A Digital Omnibus proposal is under active consideration that may adjust the high-risk system obligations timeline; the precise enforcement date is subject to legislative finalization. Source: [European Commission AI Act FAQ](https://digital-strategy.ec.europa.eu/en/faqs/eu-ai-act-questions-and-answers). The governance pack provides the engineering-layer controls — human review gates, audit trails, scope discipline, and verification requirements — that high-risk AI system obligations assume exist at the development layer but do not specify how to implement.

## Configuration and Deployment

- **Twelve-Factor App** — Config principle: store environment-varying configuration in environment variables, separate from code (12factor.net)

## Database

- **PostgreSQL documentation** — Prepared statements: parse-once-execute-many optimization, generic vs custom plan tradeoffs, and performance implications at high call rates

## Industry Data on AI Code Quality

- **Second Talent / Panto.ai (2026)**: AI-generated code introduces 1.7× more total issues, 1.75× more logic errors, and 1.57× more security findings than human-written code across production systems
- **Kiuwan / OpenSSF (2025–2026)**: approximately 25–30% of AI-generated code contains Common Weakness Enumerations (CWEs)
- **Stack Overflow Developer Survey (2025)**: only 3% of developers highly trust AI-generated code
- **Industry surveys and practitioner reports (2025, secondary compilation)**: approximately 71% of developers do not merge AI-generated code without manual review; approximately 66% report spending more time fixing near-correct AI output than writing code manually — these figures appear across multiple practitioner surveys and roundups; primary source per-stat is not individually verified in this document
- **Arxiv / SonarQube study (2025)**: concurrency and threading bugs are disproportionately common in LLM-generated code due to underrepresentation of atomicity concepts in training corpora

## AI Review Process and Scores

This package underwent multi-round AI alignment reviews by three AI systems across nine iterations (v1–v9). The repository preserves the score tables, methodology summaries, and selected conclusion excerpts from those review sessions. Raw chat transcripts are not bundled here because the reviews were conducted in external chat environments.

**Important:** These are alignment assessments by AI systems against published engineering standards, conducted at the author's request. They are not independent peer review. The scores reflect how well the pack aligns with known standards and practices as evaluated by the reviewing model — not a third-party audit or external validation.

Rules added from real-world production experience — session state machine ordering, tombstone/grace-period handling, transactional outbox atomicity, hot-loop telemetry discipline, resource-transition buffer decisions, database access patterns, microservice cost evaluation, wire format as interface contract, Kafka partition affinity, idempotency key design, cross-service backpressure propagation — were not suggested by any AI reviewer. They came from 20+ years of carrier-grade telecom system engineering. This distinction is intentional and documented: AI systems can validate alignment with published standards; they cannot originate rules that only exist because a production system failed.

<details>
<summary>Score detail (AI alignment assessments, not peer review)</summary>

| Reviewer | Method | Versions reviewed | Score progression |
| --- | --- | --- | --- |
| Claude (Sonnet 4.6) | Line-by-line adversarial review, gap-closure audit | v6, v8, v9 | 9.0 → 9.4 → **9.7** / 10 |
| ChatGPT | Standard alignment + deep-research adversarial | v6, v8 | 9.5 → **9.8** / 10 |
| Gemini | Holistic four-dimension evaluation | v6, v8 | 9.4 → **9.9** / 10 |

**Final v9 scores:**

| Dimension | ChatGPT (v8) | Gemini (v8) | Claude (v9) |
| --- | --- | --- | --- |
| Public standard coverage | 9.8 | 9.8 | 9.5 |
| Practical deployability | 9.6 | 10.0 | 9.6 |
| AI-agent governance quality | 9.9 | 10.0 | 9.7 |
| Production engineering depth | 9.9 | 10.0 | 9.8 |
| **Overall** | **9.8** | **9.9** | **9.7** |

Claude's review across v6, v8, and v9 used an adversarial methodology with explicit gap identification and closure audit at each version. Each score increment corresponds to named gaps identified and closed, not estimated.

</details>

## Principles

- Keep source citations out of agent instruction files. Citations belong in governance docs, design notes, and supporting material — not in CLAUDE.md or domain rule files, where they waste context tokens without adding enforcement value.
- Rules derived from public standards should be generalized, not copied verbatim. The governance pack reflects the principles behind the guidance, not excerpts from it.
- Prefer primary sources for evidentiary claims. Social posts, summaries, and commentary can be useful for discovery, but they should not be treated as proof when the primary paper, specification, or official documentation is available.
