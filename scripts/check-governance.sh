#!/usr/bin/env bash
# check-governance.sh — run all governance CI checks locally.
# Usage: bash scripts/check-governance.sh
# Mirrors .github/workflows/governance-check.yml so you can validate before pushing.
# Requirements: bash, python3, markdownlint-cli (npm install -g markdownlint-cli)

set -euo pipefail
PASS=0
FAIL=0
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ok()   { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

echo "=== Governance check: $ROOT ==="
echo ""

# 1. Fill-me placeholder
echo "-- Command table fill-me check"
if grep -qE "^\|.*\| fill me \|" AI_AGENT_WORKFLOW.md 2>/dev/null; then
  fail "AI_AGENT_WORKFLOW.md contains unfilled 'fill me' placeholders."
else
  ok "Command table has no unfilled placeholders."
fi

# 2. Rule file count + AGENTS.md row count
echo "-- Rule file count and AGENTS.md inventory sync"
EXPECTED=14
ACTUAL=$(ls .claude/rules/*.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$ACTUAL" -ne "$EXPECTED" ]; then
  fail "Expected $EXPECTED rule files in .claude/rules/, found $ACTUAL."
else
  ok "Rule file count: $ACTUAL."
fi
AGENTS_ROWS=$(grep -c "\.md |" AGENTS.md 2>/dev/null || echo 0)
if [ "$AGENTS_ROWS" -ne "$EXPECTED" ]; then
  fail "AGENTS.md has $AGENTS_ROWS domain rule rows, expected $EXPECTED."
else
  ok "AGENTS.md inventory: $AGENTS_ROWS rows."
fi

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

# 4. README domain-rule inventory
echo "-- README domain-rule inventory sync"
README_FAILED=0
while IFS= read -r filename; do
  if [ ! -f ".claude/rules/$filename" ]; then
    echo "    README.md lists '.claude/rules/$filename' but file does not exist."
    README_FAILED=$((README_FAILED + 1))
  fi
done < <(grep -oE '`[0-9]{2}-[a-z-]+\.md`' README.md | tr -d '`')
if [ "$README_FAILED" -gt 0 ]; then
  fail "README domain-rule table out of sync with .claude/rules/."
else
  ok "README domain-rule inventory matches .claude/rules/."
fi

# 5. RULE_PLACEMENT.md inventory
echo "-- RULE_PLACEMENT.md inventory sync"
RP_FAILED=0
while IFS= read -r filename; do
  if [ ! -f ".claude/rules/$filename" ]; then
    echo "    RULE_PLACEMENT.md references '.claude/rules/$filename' but file does not exist."
    RP_FAILED=$((RP_FAILED + 1))
  fi
done < <(grep -oE '`[0-9]{2}-[a-z-]+\.md`' RULE_PLACEMENT.md | tr -d '`')
if [ "$RP_FAILED" -gt 0 ]; then
  fail "RULE_PLACEMENT.md table out of sync with .claude/rules/."
else
  ok "RULE_PLACEMENT.md inventory matches .claude/rules/."
fi

# 6. PHASED_ADOPTION language-rule inventory
echo "-- PHASED_ADOPTION language-rule inventory sync"
LANG_FAILED=0
while IFS= read -r entry; do
  if [ ! -f ".claude/rules/$entry" ]; then
    echo "    PHASED_ADOPTION.md references '$entry' but .claude/rules/$entry does not exist."
    LANG_FAILED=$((LANG_FAILED + 1))
  fi
done < <(grep -oE '`languages/[a-z]+\.md`' PHASED_ADOPTION.md | tr -d '`')
if [ "$LANG_FAILED" -gt 0 ]; then
  fail "PHASED_ADOPTION language-rule table out of sync with .claude/rules/languages/."
else
  ok "PHASED_ADOPTION language-rule inventory matches .claude/rules/languages/."
fi

# 7. settings.example.json validity
echo "-- settings.example.json JSON validity"
if python3 -m json.tool .claude/settings.example.json > /dev/null 2>&1; then
  ok "settings.example.json is valid JSON (python3)."
elif node -e "JSON.parse(require('fs').readFileSync('.claude/settings.example.json','utf8'))" > /dev/null 2>&1; then
  ok "settings.example.json is valid JSON (node)."
else
  fail "settings.example.json is not valid JSON (neither python3 nor node could parse it)."
fi

# 8. Markdown lint (requires markdownlint-cli)
echo "-- Markdown lint"
if command -v markdownlint > /dev/null 2>&1; then
  if markdownlint "**/*.md" --ignore node_modules 2>/dev/null; then
    ok "Markdown lint passed."
  else
    fail "Markdown lint failed. Run: markdownlint '**/*.md' --ignore node_modules"
  fi
else
  echo "    [SKIP] markdownlint not installed. Run: npm install -g markdownlint-cli"
fi

# 9. Secret grep
echo "-- Secret scan"
if grep -rqE "(password|secret|token|api_key)\s*=\s*\S+" \
  README.md REFERENCES.md RULE_PLACEMENT.md AI_AGENT_WORKFLOW.md \
  CLAUDE.md AGENTS.md .claude/rules/ 2>/dev/null; then
  fail "Possible secret found in governance files."
else
  ok "Secret scan passed."
fi

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then exit 1; fi
