#!/bin/bash
# run.sh — Integration test suite for kiro-mind.
#
# Usage:
#   bash test/integration/run.sh              # run all tests
#   bash test/integration/run.sh --quick      # skip headless kiro-cli tests (fast)
#   bash test/integration/run.sh --full       # include headless kiro-cli agent tests (slow)
#
# Requirements:
#   --quick: python3, bash (no kiro-cli needed)
#   --full:  python3, bash, kiro-cli (authenticated)
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MODE="${1:---quick}"
TOTAL_PASS=0; TOTAL_FAIL=0

run_suite() {
  local name="$1" script="$2"
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║  $name"
  echo "╚══════════════════════════════════════╝"
  if bash "$script"; then
    echo "  → SUITE PASSED"
  else
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
    echo "  → SUITE FAILED"
  fi
}

echo "kiro-mind integration tests (mode: $MODE)"
echo "=========================================="

# --- Always run: no kiro-cli needed ---
run_suite "JSON Config Validation" "$SCRIPT_DIR/test-json.sh"
run_suite "Hook Script Unit Tests" "$SCRIPT_DIR/test-hooks.sh"

# --- Headless kiro-cli tests (slow, optional) ---
if [ "$MODE" = "--full" ]; then
  echo ""
  echo "╔══════════════════════════════════════╗"
  echo "║  Headless Agent Tests (kiro-cli)     "
  echo "╚══════════════════════════════════════╝"

  if ! command -v kiro-cli &>/dev/null; then
    echo "  ✗ kiro-cli not found — skipping headless tests"
    TOTAL_FAIL=$((TOTAL_FAIL + 1))
  else
    HPASS=0; HFAIL=0

    hpass() { HPASS=$((HPASS + 1)); echo "  ✓ $1"; }
    hfail() { HFAIL=$((HFAIL + 1)); echo "  ✗ $1"; }

    # Test: vault agent loads and responds
    echo "  Testing vault agent..."
    OUTPUT=$(timeout 90 kiro-cli chat --agent vault --no-interactive --trust-all-tools \
      "Read brain/North Star.md and respond with just the word CONFIRMED" 2>&1 || true)
    echo "$OUTPUT" | grep -qi "north star\|confirmed\|goals\|focus" && hpass "vault agent responds" || hfail "vault agent no response"

    # Test: morning agent loads
    echo "  Testing morning agent..."
    OUTPUT=$(timeout 90 kiro-cli chat --agent morning --no-interactive --trust-all-tools \
      "List active projects in under 20 words" 2>&1 || true)
    echo "$OUTPUT" | grep -qi "active\|project\|none\|empty\|work" && hpass "morning agent responds" || hfail "morning agent no response"

    # Test: reviewer agent loads
    echo "  Testing reviewer agent..."
    OUTPUT=$(timeout 90 kiro-cli chat --agent reviewer --no-interactive --trust-all-tools \
      "What workflows do you support? One word each." 2>&1 || true)
    echo "$OUTPUT" | grep -qi "review\|brief\|peer\|self" && hpass "reviewer agent responds" || hfail "reviewer agent no response"

    # Test: wrapup agent loads
    echo "  Testing wrapup agent..."
    OUTPUT=$(timeout 90 kiro-cli chat --agent wrapup --no-interactive --trust-all-tools \
      "Summarize vault status in under 20 words" 2>&1 || true)
    echo "$OUTPUT" | grep -qi "vault\|note\|empty\|template\|stub\|markdown\|indexed\|session\|review" && hpass "wrapup agent responds" || hfail "wrapup agent no response"

    # Test: context-loader subagent invocation
    echo "  Testing context-loader subagent..."
    OUTPUT=$(timeout 120 kiro-cli chat --agent vault --no-interactive --trust-all-tools \
      "Invoke the context-loader subagent to load context about North Star. Summarize in 10 words." 2>&1 || true)
    echo "$OUTPUT" | grep -qi "north star\|goals\|empty\|template\|focus\|subagent\|context" && hpass "context-loader subagent works" || hfail "context-loader subagent failed"

    echo ""
    echo "  Headless: $HPASS passed, $HFAIL failed"
    [ $HFAIL -gt 0 ] && TOTAL_FAIL=$((TOTAL_FAIL + 1))
  fi
fi

# --- Summary ---
echo ""
echo "=========================================="
if [ $TOTAL_FAIL -gt 0 ]; then
  echo "RESULT: $TOTAL_FAIL suite(s) had failures"
  exit 1
else
  echo "RESULT: All suites passed ✓"
fi
