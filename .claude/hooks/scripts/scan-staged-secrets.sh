#!/usr/bin/env bash
# Scan the staged diff for obvious secret literals before git commit.

set -eu

INPUT="$(cat)"
COMMAND="$(printf '%s' "$INPUT" | python3 -c 'import json, sys; data = json.load(sys.stdin); print(data.get("tool_input", {}).get("command", ""))' 2>/dev/null || true)"

if ! printf '%s\n' "$COMMAND" | grep -qE '^git commit'; then
  exit 0
fi

FINDINGS="$(
  git diff --cached \
    | grep '^+' \
    | grep -v '^+++' \
    | grep -E "(password|secret|token|api_key|apikey|private_key|access_key|client_secret)[[:space:]]*[=:\"']+[[:space:]]*[A-Za-z0-9+/_-]{8,}" 2>/dev/null \
    | grep -v '\.example' \
    | grep -v '\.sample' \
    | grep -v 'YOUR_' \
    | grep -v 'PLACEHOLDER' \
    | grep -v 'test_' \
    | head -5 \
    || true
)"

if [ -n "$FINDINGS" ]; then
  echo '[BLOCKED by Rule 05] Possible hardcoded secret detected in staged diff. Move secrets to environment variables before committing.' >&2
  echo "$FINDINGS" >&2
  exit 2
fi

exit 0
