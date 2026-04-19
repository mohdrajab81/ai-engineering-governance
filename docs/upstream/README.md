# Upstream Evaluations

This folder records structured evaluations of external governance packs, agent
catalogs, rules repositories, and harness configurations that may influence this
repository in the future.

The purpose is to avoid two failure modes:

- adopting a large external system wholesale without understanding the overlap
  or maintenance cost
- discussing outside material informally without writing down what was accepted,
  rejected, or deferred

Each evaluation should answer:

- what the external source is
- what it adds beyond this repository
- what overlaps with the current governance pack
- what is worth borrowing
- what should not be adopted
- what phased adoption path, if any, is recommended
- what attribution or license obligations apply if material is copied

These evaluations are not binding governance by themselves. They are decision
support material for future changes to:

- `CLAUDE.md`
- `AGENTS.md`
- `.claude/rules/`
- future agent catalogs
- future harness adapters

Current evaluations:

- `EVERYTHING_CLAUDE_CODE_EVALUATION.md`
- `landscape-review.md`
