#!/usr/bin/env bash
# run-markdownlint.sh — run markdownlint with a Node fallback that works in
# Bash/WSL environments where the npm shim cannot find `node` but `node.exe`
# is available on the Windows path.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [ "$#" -gt 0 ]; then
  ARGS=("$@")
else
  mapfile -t ARGS < <(git ls-files "*.md")
  if [ "${#ARGS[@]}" -eq 0 ]; then
    echo "No tracked markdown files found." >&2
    exit 0
  fi
fi

if ! command -v markdownlint > /dev/null 2>&1; then
  echo "markdownlint CLI not found. Install: npm install -g markdownlint-cli" >&2
  exit 127
fi

if command -v node > /dev/null 2>&1; then
  exec markdownlint "${ARGS[@]}"
fi

if command -v node.exe > /dev/null 2>&1; then
  ML="$(command -v markdownlint)"
  BASE="$(dirname "$ML")"
  JS="$BASE/node_modules/markdownlint-cli/markdownlint.js"
  if [ -f "$JS" ]; then
    if command -v wslpath > /dev/null 2>&1; then
      JS_WIN="$(wslpath -w "$JS")"
    else
      JS_WIN="$JS"
    fi
    exec node.exe "$JS_WIN" "${ARGS[@]}"
  fi
fi

echo "markdownlint CLI is installed, but no Node runtime is available in this shell." >&2
echo "Install Node in this shell environment, or run the lint command from a shell where node is available." >&2
exit 127
