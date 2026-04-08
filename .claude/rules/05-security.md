# Security Rules

- Treat all external input as untrusted. Validate format, type, range, and length at boundaries.
- Use parameterized queries and safe encoders; never build SQL, shell commands, or markup unsafely from raw input.
- Encode output for the target context before writing: HTML encoding for HTML output, JSON encoding for JSON, shell escaping for shell, URL encoding for URLs. Input validation and output encoding are complementary controls, not interchangeable.
- Enforce authorization at every protected operation. Do not assume a caller is authorized because they are authenticated or because an earlier check passed elsewhere in the call chain.
- Follow least privilege for runtime identities, service accounts, file permissions, and data access.
- Use secure defaults: TLS where applicable, modern algorithms, and no insecure fallback modes in production.
- Never commit secrets. Use environment variables, secret managers, or approved configuration stores.
- Prefer trusted, actively maintained libraries and official package managers.
- Avoid obscure or hallucinated dependencies. If adding a dependency, justify why the standard library or existing repo dependencies are insufficient.
- Pin dependency versions. Review changelogs before upgrading. Do not accept automatic major-version upgrades without explicit review.
- Run the repository's security checks when available and call out unresolved findings.

## Server-side request forgery (SSRF)

- When accepting URLs, hostnames, or IP addresses as input and making server-side requests, validate and restrict the target. Block requests to loopback addresses, private network ranges (RFC 1918), link-local addresses, and cloud instance metadata endpoints (169.254.169.254 and platform equivalents). An unguarded SSRF allows an attacker to pivot from a public-facing endpoint into internal infrastructure.
- Do not rely on DNS resolution at validation time to check whether a hostname resolves to a private address — a DNS rebinding attack can change the resolution between validation and use. Validate the resolved IP address at request time, not only at input time.

## File and path handling

- Validate file paths before any filesystem operation. Reject paths containing `..` sequences, null bytes, or absolute path prefixes. Normalize the path and confirm it falls within the intended directory boundary before opening, reading, or writing.
- For file upload endpoints: validate content type from file content inspection, not from the `Content-Type` request header; enforce a maximum file size before reading the body; store uploaded files outside the web root and never execute them directly.

## CSRF defense

- For any server-rendered or cookie-authenticated endpoint, require CSRF token validation on all state-changing operations (POST, PUT, PATCH, DELETE). Do not rely on SameSite cookies alone as the only control — browser support and deployment context vary. AI-generated web endpoint code must include a CSRF defense by default, not as an optional hardening step.
- Validate CSRF tokens server-side on every state-changing request. Token presence in the request does not imply validity; check origin and token value together.

## Rate limiting and abuse control

- Every public or partner-facing endpoint must have a rate limit. Define the limit before the endpoint is deployed, not after abuse is observed. Absence of a rate limit is a design defect, not a performance concern.
- Apply rate limits at the authenticated identity layer when available, not only at IP address. IP-based limits alone are trivially bypassed and penalize legitimate users behind shared NAT.

## Secrets and regulated data in AI tool inputs

- Never log secrets, tokens, or credentials at any severity level — not at DEBUG, not in structured payloads, not in exception stack traces. Secrets that appear in logs propagate silently to log aggregators, audit trails, and monitoring systems.
- When using AI coding tools, code review tools, or external analysis services that process source code or runtime output, ensure secrets are not present in the content being submitted. Redact sensitive values before submitting code, logs, configuration, or test output to any external service. The "never log secrets" rule applies to AI tool inputs as much as to production log pipelines.
- Do not include personally identifiable information, protected health information, financial account data, or other regulated data in prompts or context sent to external AI services without explicit organizational authorization. Apply the same need-to-know principle to AI service inputs as to human access: send only what the tool needs to complete the task. When AI tools process code that references regulated data structures — schemas, models, migrations, fixtures — verify that no sample or real regulated values are present in the submission.

## Authorization at runtime

- Do not cache authorization decisions indefinitely when roles, permissions, or scopes can change at runtime. A stale cache entry can allow access that has been revoked or deny access that has been granted. Define an explicit TTL or invalidation trigger for any cached authorization state.

## Supply chain integrity

- For any build artifact published to a package registry or deployed to production, generate and retain a build provenance record capturing: source commit, build environment, build inputs, and the identity of the build system. This is the minimum SLSA Level 1 requirement and establishes a baseline for supply-chain incident investigation.
- SLSA Level 1 (provenance record exists) is the appropriate baseline for internal services and private registries. Teams publishing artifacts to public registries, operating in regulated industries, or integrating with third-party supply chain verification should target Level 2 (build service generates and signs the attestation) and evaluate Level 3 (hermetic, verifiable build environment) against their specific threat model. Moving between levels is a deliberate security investment decision, not an automatic upgrade.
- Do not consume a third-party dependency that has no verifiable release provenance — signed release, reproducible build, or known-good hash in lockfile. If provenance cannot be verified, treat the dependency as untrusted and escalate before adopting it.
