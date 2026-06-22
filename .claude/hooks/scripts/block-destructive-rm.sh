#!/usr/bin/env bash
# Block destructive rm -rf patterns with near-zero legitimate use in AI sessions.

set -eu

INPUT="$(cat)"
COMMAND="$(printf '%s' "$INPUT" | python3 -c 'import json, sys; data = json.load(sys.stdin); print(data.get("tool_input", {}).get("command", ""))' 2>/dev/null || true)"

if printf '%s\n' "$COMMAND" | grep -qE 'rm[[:space:]]+-[A-Za-z]*(r[A-Za-z]*f|f[A-Za-z]*r)[A-Za-z]*[[:space:]]+(/[[:space:]]|/$|~/|~[[:space:]]|~$|\.\./|\*|\./\*)'; then
  echo '[BLOCKED by Rule 08] rm -rf on root, home, wildcard, or parent-directory paths is not permitted in an AI coding session. If this deletion is intentional, run it manually in a terminal.' >&2
  exit 2
fi

exit 0
