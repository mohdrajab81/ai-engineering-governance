#!/usr/bin/env bash
# Prevent quick edits to lint/format configuration as a way to silence checks.

set -eu

INPUT="$(cat)"
FILE="$(printf '%s' "$INPUT" | python3 -c 'import json, sys; data = json.load(sys.stdin); print(data.get("tool_input", {}).get("file_path", ""))' 2>/dev/null || true)"
BASENAME="$(basename "$FILE")"

case "$BASENAME" in
  .eslintrc|.eslintrc.js|.eslintrc.cjs|.eslintrc.json|.eslintrc.yaml|.eslintrc.yml|eslint.config.js|eslint.config.mjs|eslint.config.cjs|.prettierrc|.prettierrc.js|.prettierrc.cjs|.prettierrc.json|.prettierrc.yaml|.prettierrc.yml|prettier.config.js|prettier.config.mjs|ruff.toml|.ruff.toml|.markdownlint.json|.markdownlint.yaml|.markdownlint.yml|.markdownlintrc|.stylelintrc|.stylelintrc.json|.stylelintrc.yaml|stylelint.config.js|.flake8)
    echo '[BLOCKED by Rule 06] Editing lint/format config to make checks pass is not permitted. Fix the code that fails the check instead. If this is a deliberate team policy change, make it a standalone commit with an explicit reason in the commit message.' >&2
    exit 2
    ;;
  pyproject.toml)
    echo '[WARN] Editing pyproject.toml: if this touches [tool.ruff], [tool.black], [tool.isort], or [tool.flake8] sections, confirm it is a deliberate team policy decision and not a workaround to silence a failing check.' >&2
    exit 0
    ;;
  *)
    exit 0
    ;;
esac
