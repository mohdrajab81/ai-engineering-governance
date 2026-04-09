#!/usr/bin/env bash
# governance-lint.sh — heuristic code quality checks for consuming repositories.
#
# PURPOSE
#   This script runs pattern-based heuristic checks against your project's source
#   code to surface common governance violations. It is NOT a semantic enforcement
#   tool — it cannot verify logic, test coverage, or architectural compliance. Use
#   it as a fast first-pass signal, not as a substitute for code review.
#
# USAGE
#   bash scripts/governance-lint.sh [source-dir]
#   Default source-dir: src/ (or current directory if src/ does not exist)
#
# FALSE POSITIVES
#   Several checks below have known false positive rates. Each check documents its
#   limitations. Do not treat a flag as a confirmed violation without reading the
#   flagged line in context.
#
# REQUIREMENTS
#   bash, grep, find

set -euo pipefail

PASS=0
FAIL=0
WARN=0
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

# Source directory to scan: first argument, or src/, or current directory
if [ -n "${1:-}" ] && [ -d "$1" ]; then
  SRC_DIR="$1"
elif [ -d "src" ]; then
  SRC_DIR="src"
else
  SRC_DIR="."
fi

ok()   { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }
warn() { echo "[WARN] $1"; WARN=$((WARN + 1)); }

echo "=== Governance lint: $ROOT (scanning: $SRC_DIR) ==="
echo "    These are heuristic checks. Read flagged lines in context before acting."
echo ""

# ── 1. TODO comments without issue reference ──────────────────────────────────
# Rule 09: TODO comments must include a reason and a reference (ticket, issue, or owner).
# A bare TODO with no reference is not actionable.
# Heuristic: flag TODO/FIXME/HACK not followed by #, (, http, or a ticket pattern.
# False positives: low. Legitimate bare TODOs should have references added.
echo "-- TODO comments without issue reference (Rule 09)"
TODO_COUNT=0
while IFS= read -r line; do
  echo "    $line"
  TODO_COUNT=$((TODO_COUNT + 1))
done < <(grep -rn --include="*.py" --include="*.go" --include="*.ts" --include="*.js" \
  --include="*.java" --include="*.kt" --include="*.rs" --include="*.cs" \
  -E "(TODO|FIXME|HACK)[^:(#]" "$SRC_DIR" 2>/dev/null \
  | grep -vE "(TODO|FIXME|HACK)\s*(#[0-9]+|\(|http|https|[A-Z]+-[0-9]+)" \
  || true)
if [ "$TODO_COUNT" -gt 0 ]; then
  fail "$TODO_COUNT TODO/FIXME/HACK comment(s) without an issue reference."
else
  ok "All TODO/FIXME/HACK comments have references (or none found)."
fi

# ── 2. Hardcoded localhost / 0.0.0.0 in non-config source ─────────────────────
# Rule 10: Never hardcode endpoints in business logic.
# Heuristic: flag string literals containing localhost or 0.0.0.0 in source files.
# False positives: moderate. Test files and config loaders often legitimately use
# localhost. Review each result — test files are the common false positive.
echo "-- Hardcoded localhost / 0.0.0.0 in source files (Rule 10)"
LOCALHOST_COUNT=0
while IFS= read -r line; do
  echo "    $line"
  LOCALHOST_COUNT=$((LOCALHOST_COUNT + 1))
done < <(grep -rn --include="*.py" --include="*.go" --include="*.ts" --include="*.js" \
  --include="*.java" --include="*.kt" --include="*.rs" --include="*.cs" \
  -E "\"(localhost|127\.0\.0\.1|0\.0\.0\.0)(:[0-9]+)?\"" "$SRC_DIR" 2>/dev/null \
  | grep -v "_test\." | grep -v "\.test\." | grep -v "\.spec\." \
  || true)
if [ "$LOCALHOST_COUNT" -gt 0 ]; then
  warn "$LOCALHOST_COUNT hardcoded localhost/0.0.0.0 literal(s). Verify these are not in production code paths."
else
  ok "No hardcoded localhost/0.0.0.0 literals in non-test source files."
fi

# ── 3. Secret patterns in source code ─────────────────────────────────────────
# Rule 05: Never commit secrets. Use environment variables or approved config stores.
# Heuristic: flag assignment patterns that look like credential literals.
# False positives: low for real secrets; moderate for test fixtures with placeholder values.
echo "-- Secret patterns in source code (Rule 05)"
SECRET_COUNT=0
while IFS= read -r line; do
  echo "    $line"
  SECRET_COUNT=$((SECRET_COUNT + 1))
done < <(grep -rn --include="*.py" --include="*.go" --include="*.ts" --include="*.js" \
  --include="*.java" --include="*.kt" --include="*.rs" --include="*.cs" \
  --include="*.yaml" --include="*.yml" --include="*.json" \
  -E "(password|secret|api_key|apikey|token|private_key)\s*[=:]\s*['\"][^'\"]{6,}['\"]" \
  "$SRC_DIR" 2>/dev/null \
  | grep -vE "(os\.environ|getenv|process\.env|config\.|settings\.|placeholder|your[_-]|<|>|example|test|fake|mock|dummy)" \
  || true)
if [ "$SECRET_COUNT" -gt 0 ]; then
  fail "$SECRET_COUNT possible secret literal(s) in source. Review immediately."
else
  ok "No obvious secret literals found in source files."
fi

# ── 4. HTTP calls without a timeout argument (Python-focused heuristic) ────────
# Rule 03: Every external dependency call must have an explicit timeout.
# Heuristic: flag requests.get/post/put/patch/delete calls without 'timeout='.
# FALSE POSITIVE WARNING: This check is Python-specific and will miss timeouts set
# on a session object (requests.Session with timeout) or via a wrapper function.
# Do not treat a flag here as a confirmed violation — check whether the caller
# uses a session with a configured timeout or a wrapper that enforces it.
echo "-- HTTP calls without explicit timeout argument (Rule 03, Python heuristic)"
HTTP_COUNT=0
while IFS= read -r line; do
  echo "    $line"
  HTTP_COUNT=$((HTTP_COUNT + 1))
done < <(grep -rn --include="*.py" \
  -E "requests\.(get|post|put|patch|delete)\(" "$SRC_DIR" 2>/dev/null \
  | grep -v "timeout=" \
  || true)
if [ "$HTTP_COUNT" -gt 0 ]; then
  warn "$HTTP_COUNT requests.* call(s) without explicit timeout= argument. Verify session-level or wrapper timeout is set."
else
  ok "No requests.* calls missing explicit timeout= (Python check)."
fi

# ── 5. print() / console.log in non-test source (debug noise) ─────────────────
# Rule 04 / language rules: Use structured logging. print() and console.log in
# production code bypass the logging pipeline, lose severity and correlation context,
# and cannot be filtered by log level.
# False positives: low in production code; high in scripts and utilities.
echo "-- print() / console.log in non-test source (Rule 04 / language rules)"
PRINT_COUNT=0
while IFS= read -r line; do
  echo "    $line"
  PRINT_COUNT=$((PRINT_COUNT + 1))
done < <(grep -rn --include="*.py" --include="*.ts" --include="*.js" \
  -E "^\s*(print\(|console\.log\()" "$SRC_DIR" 2>/dev/null \
  | grep -v "_test\." | grep -v "\.test\." | grep -v "\.spec\." \
  || true)
if [ "$PRINT_COUNT" -gt 0 ]; then
  warn "$PRINT_COUNT print()/console.log() call(s) in non-test source. Replace with structured logger calls."
else
  ok "No print()/console.log() in non-test source files."
fi

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo "=== Results: $PASS passed, $WARN warnings, $FAIL failed ==="
echo "    PASS  = no pattern found"
echo "    WARN  = flagged; review in context before acting"
echo "    FAIL  = high-confidence violation; address before merge"
echo ""
echo "    This script provides heuristic signals, not semantic enforcement."
echo "    False positives are documented per check above."
if [ "$FAIL" -gt 0 ]; then exit 1; fi
