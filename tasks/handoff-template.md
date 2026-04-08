# Handoff: [topic]

Copy this file to `tasks/handoff-<topic>.md` when ending a session with incomplete high-risk work.
Delete the file when the task is complete and the work is committed.

---

## Session ended

- **Date:**
- **Reason:** context limit / end of working session / blocked on external input / other

## Task

One sentence: what was being worked on and why.

## State at handoff

### Done

- List what is fully implemented, committed, and verified.

### In progress

- List what was started but not finished, with the exact stopping point.

### Not started

- List planned steps not yet begun.

## Key decisions made this session

- [Decision and the reasoning behind it — critical for the next session to know]
- [If a design choice was made, state it explicitly so it is not re-derived differently]

## Constraints the next session must respect

- [Hard constraints: locked APIs, agreed interfaces, invariants already in code]
- [If any rule was intentionally bent, name it here with the reason]

## Files changed this session

| File | Status | Notes |
| --- | --- | --- |
| `path/to/file` | modified / created / deleted | What changed and why |

## Verification state

### Verified

- [Commands run and their results]

### Not verified

- [What could not be tested and why — environment gap, missing dependency, etc.]

## Next steps

Ordered list of actions for the next session, specific enough to start without re-reading history:

1.
2.
3.

## Open questions

- [Any unresolved question that blocks or shapes the next steps]
