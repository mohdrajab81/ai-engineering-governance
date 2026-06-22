#!/usr/bin/env bash
# Block git commands that bypass repository hooks.

set -eu

INPUT="$(cat)"
COMMAND="$(printf '%s' "$INPUT" | python3 -c 'import json, sys; data = json.load(sys.stdin); print(data.get("tool_input", {}).get("command", ""))' 2>/dev/null || true)"

if printf '%s\n' "$COMMAND" | grep -qE 'git (commit|merge|rebase).*--no-verify'; then
  echo '[BLOCKED by Rule 08] --no-verify bypasses commit hooks and is not permitted. Fix the failing hook instead of skipping it.' >&2
  exit 2
fi

exit 0
