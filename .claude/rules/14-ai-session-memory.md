# AI Session and Memory Management

AI coding sessions have a bounded context window. When a session runs long, earlier
decisions, earlier rule content, and earlier task state get pushed out of the
available context. This is not a recoverable failure if the session continues
as if nothing changed — it is an active hazard. A session that loses context
mid-change and restarts from a wrong assumption can silently undo hours of work,
invent state that does not exist, or violate constraints it no longer remembers.

These rules govern how to manage session boundaries, preserve continuity across
sessions, and hand off safely when a session ends.

## Context pressure recognition

- Monitor context growth during long sessions. When working on a multi-step task
  that spans many file reads, large diffs, or long tool outputs, the risk of
  critical earlier content being truncated increases.
- When context pressure is high and the current task involves a high-risk
  operation — schema migration, destructive action, public API change, security
  boundary — stop and state explicitly that earlier rule content may no longer
  be fully available. Do not proceed on the assumption that all constraints are
  still in context.
- Do not silently continue a high-risk operation in a compressed context. The
  compressed state is not equivalent to the full state. Reconfirm scope and
  constraints before acting.

## Progress checkpointing

- Significant decisions and completed steps must be recorded in committed files,
  not held only in chat history. Chat history is ephemeral and session-scoped.
  Committed files survive session boundaries.
- For tasks that span more than one session, write a progress summary to a
  tracked file before ending the session. The summary should capture: what was
  done, what changed, what the next step is, and any open decisions that must
  be resolved before continuing. This is a handoff document, not a log entry.
  Store it in `tasks/` — for example `tasks/handoff-<topic>.md` — so it is
  visible in the repository and readable by the next session without searching.
- Checkpoint before ending any session that contains incomplete high-risk work:
  schema migrations, public API changes, large refactors, destructive operations,
  or any change that cannot safely be left in a partial state. Do not rely on
  resuming the session from memory alone.
- Do not rely on memory systems (project memory files, CLAUDE.md notes) to
  carry implementation state. Memory is for durable preferences, patterns, and
  decisions — not for tracking mid-task progress. Mid-task progress belongs in
  a plan or working file that is visible in the repository.

## What belongs in persistent memory

Persistent memory (project-level configuration files, CLAUDE.md, memory files)
is for:

- Durable decisions about how the project works: conventions, architectural
  constraints, what not to do
- Preferences and working-style rules that should apply across all sessions
- Pointers to authoritative sources (which file is the contract, which doc is
  the canonical decision surface)

Persistent memory is not for:

- Current task progress or in-flight work
- Lists of recent changes (git log is authoritative)
- Debugging notes or temporary state
- Context that is only valid for the current session

Putting ephemeral state into persistent memory pollutes the context of future
sessions with stale information that no longer applies.

## Session handoff

When ending a session that has incomplete work:

- Preserve stable, reviewable work in version control before ending the session.
  If the project allows intermediate commits, commit changes that are in a
  complete, self-consistent state. If commit policy requires only shippable
  commits, preserve the work on a branch or in a tracked handoff artifact so
  a future session does not have to reconstruct what was done from scratch.
- If work is intentionally incomplete, leave a clear marker in the code or a
  tracked note explaining what is missing and why, so a future session does not
  treat the partial state as complete.
- Do not end a session mid-migration, mid-refactor, or mid-schema-change without
  either completing the operation or explicitly documenting the safe stopping
  point and what must happen next.

## Multi-agent session handoff

When a session used sub-agents or parallel agents, the orchestrating session
must record the handoff state before ending:

- List which files each sub-agent read or proposed changes to. A future session
  must know which areas were already addressed and which were not.
- Record the accepted source of truth for any conflict between sub-agent outputs.
  If two sub-agents produced conflicting results, document which was accepted and
  why, so the next session does not re-derive the conflict.
- Do not assume a future session can reconstruct multi-agent work from chat
  history. Multi-agent sessions produce more state faster than single-agent ones;
  checkpointing discipline matters more, not less.

## Resuming from a previous session

- Read the committed state of the repository before acting. Do not rely on chat
  history alone to reconstruct what happened in a prior session. Chat history
  may be summarized, compressed, or unavailable.
- If a progress summary or handoff document exists, read it. If it does not
  exist and the task is complex, spend the first part of the session
  reconstructing the current state from the repository before making changes.
- Verify that assumptions from the previous session still hold: files mentioned
  may have changed, decisions may have been revisited, dependencies may have
  been updated. Do not carry over state from memory without checking.

## Why this rule exists

Long multi-session AI-assisted projects fail in a specific way: the agent loses
track of what was decided, re-derives conclusions that conflict with earlier
ones, or misses a constraint that was established in a session it can no longer
read. The failure is not dramatic — it produces plausible-looking output that
violates an earlier decision. The fix is to treat session boundaries as real
engineering boundaries: checkpoint explicitly, commit before handing off, and
verify state at the start of each new session rather than assuming continuity.
