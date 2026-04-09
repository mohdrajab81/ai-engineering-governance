# Configuration, Feature Flags, and Migration Rules

## Configuration and environment

- Keep all configuration outside of code. Use environment variables, secret managers, or approved configuration stores. Never hardcode environment-specific values, endpoints, credentials, or tuning parameters in business logic.
- Validate all required configuration at startup. Fail fast with a clear error message if a required value is missing, malformed, or out of acceptable range. Do not allow the service to start in a silently degraded configuration.
- Separate configuration concerns by audience: infrastructure config (ports, replicas, resource limits) belongs in deployment manifests; application config (timeouts, feature flags, behaviour toggles) belongs in the application's own config layer.
- Do not read configuration values repeatedly inside hot loops. Load and validate at startup or at a well-defined refresh boundary.
- When configuration changes at runtime (hot reload), treat the reload path with the same validation rigor as startup. A bad reload must not silently corrupt in-memory state.
- When a service starts or completes a configuration reload, emit a structured log entry recording the effective configuration profile — excluding any secret values. This confirms the running process is using the intended configuration and provides a reference point for incident diagnosis when behavior differs from expectation.
- Configuration keys are part of the external contract. Do not rename, remove, or restructure config keys without a migration plan that supports both the old and new key names simultaneously during the transition window.
- Treat infrastructure configuration defined through Terraform, Pulumi,
  CloudFormation, or equivalent IaC tools with the same discipline as
  application configuration: version-control it, validate it before apply,
  and run periodic drift detection. A manual console change that diverges
  from IaC is a configuration failure until it is reconciled back into the
  declared source of truth.

## Feature flags

- Every feature flag must have a documented owner, a default value, a purpose, and a planned removal milestone before it is merged.
- Store feature flag definitions in version-controlled configuration
  alongside the code whenever the platform allows it. A flag that exists
  only in a runtime dashboard is harder to review, audit, and retire.
- Treat a feature flag's default value as a contract. Changing the default is a potentially breaking change and must be reviewed as one.
- Set a maximum lifetime for each flag.
- Remove flags and their dead branches promptly after a rollout is confirmed stable. Do not accumulate flag debt.
- Test both flag states (enabled and disabled) before merging. A flag that has never been tested in its off state is a latent defect.

## Schema, API, and event migrations

- Treat schema changes (database columns, event formats, API request/response shapes) as public contracts. Consumers may depend on the current form even if they are internal services.
- Use the expand-migrate-contract pattern for breaking changes:
  1. **Expand**: add the new field, column, or endpoint alongside the old one. Both forms are live simultaneously.
  2. **Migrate**: update all producers and consumers to use the new form. Verify completeness.
  3. **Contract**: remove the old form in a separate, subsequent change after migration is confirmed.
- Never remove a field, rename a column, or change an event's required shape in a single step that is not coordinated with all consumers.
- For database migrations: write migrations as forward-only scripts in version-controlled files. Every migration must be tested against a representative dataset. Include a rollback note or compensating migration where reversal is feasible.
- During the expand phase of a schema or API migration, add contract tests that verify both the old and new forms are simultaneously valid. These tests must pass before beginning the migrate phase.
- When a migration requires coordinated schema and application changes,
  deploy the additive schema expansion first, then deploy the application
  code that uses the new shape, then remove the old shape in a later
  contract phase.
- For event-driven systems: version event schemas explicitly. Consumers must tolerate unknown fields in newer events (forward compatibility) and producers must tolerate missing optional fields in older consumers (backward compatibility).
- For public or partner-facing APIs: maintain a documented deprecation window before removing any field or endpoint. Communicate the timeline to consumers before beginning the contract phase.

## Rollout and staged deployment

- For high-risk changes, prefer canary or staged rollout over a full immediate release. Define the traffic percentage, success criteria, and automatic rollback trigger before starting the rollout.
- Define what "healthy" looks like before the rollout begins. Use error rate, latency, and business-level metrics as rollout health signals, not just process uptime.
- Ensure a rollback path exists and has been tested before releasing a change that modifies persistent state, schema, or external contracts.
