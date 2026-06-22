#!/usr/bin/env bash
# check-governance.sh — run all governance CI checks locally.
# Usage: bash scripts/check-governance.sh
# Canonical source of truth for the repository's structural governance checks.
# The GitHub Actions workflow should invoke this script so local and CI behavior
# stay aligned.
# Requirements: bash, git, grep, python3, markdownlint-cli, and a Node runtime
# available in the same shell as `markdownlint` (either `node` or `node.exe`)

set -euo pipefail
PASS=0
FAIL=0
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

ok()   { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

compare_expected_to_actual() {
  local label="$1"
  local expected_file="$2"
  local actual_file="$3"

  if diff -u "$expected_file" "$actual_file" > "$TMP_DIR/diff" 2>&1; then
    ok "$label matches repository files."
  else
    echo "    Differences for $label:"
    sed 's/^/    /' "$TMP_DIR/diff"
    fail "$label is out of sync with repository files."
  fi
}

list_base_rule_files() {
  if [ -d ".claude/rules" ]; then
    find .claude/rules -maxdepth 1 -type f -name '[0-9][0-9]-*.md' \
      | sed 's#^\./##; s#^\.claude/rules/##' \
      | sort
  fi
}

list_language_rule_files() {
  if [ -d ".claude/rules/languages" ]; then
    find .claude/rules/languages -maxdepth 1 -type f -name '*.md' \
      | sed 's#^\./##; s#^\.claude/rules/##' \
      | sort
  fi
}

list_hook_scripts() {
  if [ -d ".claude/hooks/scripts" ]; then
    find .claude/hooks/scripts -maxdepth 1 -type f -name '*.sh' \
      | sed 's#^\./##' \
      | sort
  fi
}

echo "=== Governance check: $ROOT ==="
echo ""

ACTUAL_RULES="$TMP_DIR/actual-rules"
EXPECTED_RULES="$TMP_DIR/expected-rules"
ACTUAL_LANGUAGE_RULES="$TMP_DIR/actual-language-rules"
EXPECTED_LANGUAGE_RULES="$TMP_DIR/expected-language-rules"
ACTUAL_HOOK_SCRIPTS="$TMP_DIR/actual-hook-scripts"
EXPECTED_HOOK_SCRIPTS="$TMP_DIR/expected-hook-scripts"

list_base_rule_files > "$ACTUAL_RULES"
list_language_rule_files > "$ACTUAL_LANGUAGE_RULES"
list_hook_scripts > "$ACTUAL_HOOK_SCRIPTS"

# 1. Fill-me placeholder
echo "-- Command table fill-me check"
if grep -qE "^\|.*\| fill me \|" AI_AGENT_WORKFLOW.md 2>/dev/null; then
  fail "AI_AGENT_WORKFLOW.md contains unfilled 'fill me' placeholders."
else
  ok "Command table has no unfilled placeholders."
fi

# 2. Exact rule inventory sync across docs that enumerate rule filenames.
echo "-- Domain-rule inventory sync"
(grep -oE '[0-9]{2}-[a-z-]+\.md' AGENTS.md 2>/dev/null || true) | sort -u > "$EXPECTED_RULES"
compare_expected_to_actual "AGENTS.md domain-rule inventory" "$EXPECTED_RULES" "$ACTUAL_RULES"

(grep -oE '`[0-9]{2}-[a-z-]+\.md`' README.md 2>/dev/null || true) \
  | tr -d '`' \
  | sort -u > "$EXPECTED_RULES"
compare_expected_to_actual "README.md domain-rule inventory" "$EXPECTED_RULES" "$ACTUAL_RULES"

# 3. Rule N cross-references
echo "-- Rule N cross-reference validation"
REF_FAILED=0
while IFS= read -r ref; do
  num=$(echo "$ref" | grep -oE "[0-9]+")
  padded=$(printf "%02d" "$((10#$num))")
  if ! ls .claude/rules/${padded}-*.md > /dev/null 2>&1; then
    echo "    '$ref' referenced in prose but .claude/rules/${padded}-*.md does not exist."
    REF_FAILED=$((REF_FAILED + 1))
  fi
done < <(grep -rh --include="*.md" -oE "Rule [0-9]+" . | sort -u)
if [ "$REF_FAILED" -gt 0 ]; then
  fail "$REF_FAILED broken rule reference(s) in prose."
else
  ok "All Rule N prose references point to existing files."
fi

# 4. PHASED_ADOPTION language-rule inventory
echo "-- PHASED_ADOPTION language-rule inventory sync"
(grep -oE '`languages/[a-z]+\.md`' PHASED_ADOPTION.md 2>/dev/null || true) \
  | tr -d '`' \
  | sort -u > "$EXPECTED_LANGUAGE_RULES"
compare_expected_to_actual "PHASED_ADOPTION.md language-rule inventory" "$EXPECTED_LANGUAGE_RULES" "$ACTUAL_LANGUAGE_RULES"

# 5. Claude settings and hook manifest validity
echo "-- Claude settings and hook JSON validity"
if python3 -m json.tool .claude/settings.example.json > /dev/null 2>&1; then
  ok "settings.example.json is valid JSON (python3)."
elif node -e "JSON.parse(require('fs').readFileSync('.claude/settings.example.json','utf8'))" > /dev/null 2>&1; then
  ok "settings.example.json is valid JSON (node)."
else
  fail "settings.example.json is not valid JSON (neither python3 nor node could parse it)."
fi

if python3 -m json.tool .claude/hooks/hooks.json > /dev/null 2>&1; then
  ok "hooks.json is valid JSON (python3)."
elif node -e "JSON.parse(require('fs').readFileSync('.claude/hooks/hooks.json','utf8'))" > /dev/null 2>&1; then
  ok "hooks.json is valid JSON (node)."
else
  fail "hooks.json is not valid JSON (neither python3 nor node could parse it)."
fi

# 6. Claude hook script manifest sync, syntax, and tracking
echo "-- Claude hook script sync, syntax, and tracking"
python3 - > "$EXPECTED_HOOK_SCRIPTS" <<'PY'
import json
from pathlib import Path

data = json.loads(Path(".claude/hooks/hooks.json").read_text())
paths = set()

for event_hooks in data.get("hooks", {}).values():
    for item in event_hooks:
        for hook in item.get("hooks", []):
            command = hook.get("command", "")
            prefix = "bash "
            script_prefix = ".claude/hooks/scripts/"
            if command.startswith(prefix + script_prefix) and command.endswith(".sh"):
                paths.add(command[len(prefix):])

for path in sorted(paths):
    print(path)
PY
compare_expected_to_actual "Hook manifest script inventory" "$EXPECTED_HOOK_SCRIPTS" "$ACTUAL_HOOK_SCRIPTS"

HOOK_SCRIPT_FAILED=0
while IFS= read -r script; do
  [ -z "$script" ] && continue

  if [ ! -f "$script" ]; then
    echo "    $script is referenced by hooks.json but does not exist."
    HOOK_SCRIPT_FAILED=$((HOOK_SCRIPT_FAILED + 1))
    continue
  fi

  if ! bash -n "$script"; then
    echo "    $script has a shell syntax error."
    HOOK_SCRIPT_FAILED=$((HOOK_SCRIPT_FAILED + 1))
  fi

  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    if git ls-files --error-unmatch "$script" > /dev/null 2>&1; then
      :
    else
      echo "    $script exists locally but is not tracked by git."
      HOOK_SCRIPT_FAILED=$((HOOK_SCRIPT_FAILED + 1))
    fi
  fi
done < "$EXPECTED_HOOK_SCRIPTS"

if [ "$HOOK_SCRIPT_FAILED" -gt 0 ]; then
  fail "$HOOK_SCRIPT_FAILED hook script tracking, presence, or syntax issue(s) found."
else
  if [ -s "$EXPECTED_HOOK_SCRIPTS" ]; then
    ok "Hook scripts are referenced, present, tracked, and pass bash syntax checks."
  else
    ok "No hook scripts are referenced by hooks.json."
  fi
fi

# 7. Markdown lint (requires markdownlint-cli + node or node.exe)
echo "-- Markdown lint"
if command -v markdownlint > /dev/null 2>&1; then
  if bash scripts/run-markdownlint.sh 2>/dev/null; then
    ok "Markdown lint passed."
  else
    fail "Markdown lint failed. Run: bash scripts/run-markdownlint.sh"
  fi
else
  echo "    [SKIP] markdownlint not installed. Run: npm install -g markdownlint-cli"
fi

# 8. Secret grep
echo "-- Secret scan"
if grep -rqE "(password|secret|token|api_key)\s*=\s*\S+" \
  README.md REFERENCES.md RULE_PLACEMENT.md AI_AGENT_WORKFLOW.md \
  CLAUDE.md AGENTS.md CONTRIBUTING.md CHANGELOG.md SECURITY.md \
  copilot-instructions.md \
  .github/copilot-instructions.md .github/workflows/governance-check.yml \
  .github/PULL_REQUEST_TEMPLATE.md \
  .claude/settings.example.json \
  .claude/hooks/hooks.json \
  .claude/hooks/scripts/ \
  .claude/rules/ 2>/dev/null; then
  fail "Possible secret found in governance files."
else
  ok "Secret scan passed."
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then exit 1; fi
