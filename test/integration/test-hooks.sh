#!/bin/bash
# test-hooks.sh — Unit test hook scripts with synthetic stdin.
# No kiro-cli needed. Tests the scripts directly.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PASS=0; FAIL=0; ERRORS=""

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); ERRORS="${ERRORS}\n  ✗ $1"; echo "  ✗ $1"; }

echo "=== Hook Script Unit Tests ==="

# --- session-start.sh ---
echo ""
echo "--- session-start.sh ---"

OUTPUT=$(echo '{"hook_event_name":"agentSpawn","cwd":"'"$REPO_ROOT"'"}' | bash "$REPO_ROOT/.kiro/scripts/session-start.sh" 2>/dev/null)

echo "$OUTPUT" | grep -q "## Session Context" && pass "outputs session context header" || fail "missing session context header"
echo "$OUTPUT" | grep -q "### North Star" && pass "includes North Star section" || fail "missing North Star section"
echo "$OUTPUT" | grep -q "### Recent Changes" && pass "includes recent changes" || fail "missing recent changes"
echo "$OUTPUT" | grep -q "### Active Work" && pass "includes active work" || fail "missing active work"
echo "$OUTPUT" | grep -q "### Vault File Listing" && pass "includes file listing" || fail "missing file listing"
echo "$OUTPUT" | grep -q "$(date +%Y-%m-%d)" && pass "includes today's date" || fail "missing today's date"

# --- classify-message.py ---
echo ""
echo "--- classify-message.py ---"

# Test: decision detection
OUT=$(echo '{"hook_event_name":"userPromptSubmit","cwd":".","prompt":"We decided to use GraphQL"}' | python3 "$REPO_ROOT/.kiro/scripts/classify-message.py" 2>/dev/null)
echo "$OUT" | grep -qi "decision" && pass "detects DECISION" || fail "missed DECISION in 'We decided to use GraphQL'"

# Test: incident detection
OUT=$(echo '{"hook_event_name":"userPromptSubmit","cwd":".","prompt":"There was a p1 incident last night"}' | python3 "$REPO_ROOT/.kiro/scripts/classify-message.py" 2>/dev/null)
echo "$OUT" | grep -qi "incident" && pass "detects INCIDENT" || fail "missed INCIDENT in 'p1 incident'"

# Test: win detection
OUT=$(echo '{"hook_event_name":"userPromptSubmit","cwd":".","prompt":"We shipped the new feature and got kudos from the team"}' | python3 "$REPO_ROOT/.kiro/scripts/classify-message.py" 2>/dev/null)
echo "$OUT" | grep -qi "win" && pass "detects WIN" || fail "missed WIN in 'shipped...kudos'"

# Test: 1:1 detection
OUT=$(echo '{"hook_event_name":"userPromptSubmit","cwd":".","prompt":"Just had a 1:1 with Sarah"}' | python3 "$REPO_ROOT/.kiro/scripts/classify-message.py" 2>/dev/null)
echo "$OUT" | grep -qi "1:1" && pass "detects 1:1" || fail "missed 1:1"

# Test: person context detection
OUT=$(echo '{"hook_event_name":"userPromptSubmit","cwd":".","prompt":"Bob told me the API is ready"}' | python3 "$REPO_ROOT/.kiro/scripts/classify-message.py" 2>/dev/null)
echo "$OUT" | grep -qi "person" && pass "detects PERSON CONTEXT" || fail "missed PERSON CONTEXT"

# Test: no signal on neutral message
OUT=$(echo '{"hook_event_name":"userPromptSubmit","cwd":".","prompt":"What time is it?"}' | python3 "$REPO_ROOT/.kiro/scripts/classify-message.py" 2>/dev/null)
[ -z "$OUT" ] && pass "no signal on neutral message" || fail "false positive on 'What time is it?'"

# Test: empty prompt
OUT=$(echo '{"hook_event_name":"userPromptSubmit","cwd":".","prompt":""}' | python3 "$REPO_ROOT/.kiro/scripts/classify-message.py" 2>/dev/null)
[ -z "$OUT" ] && pass "no signal on empty prompt" || fail "false positive on empty prompt"

# Test: CJK support
OUT=$(echo '{"hook_event_name":"userPromptSubmit","cwd":".","prompt":"チームで決定した"}' | python3 "$REPO_ROOT/.kiro/scripts/classify-message.py" 2>/dev/null)
echo "$OUT" | grep -qi "decision" && pass "detects Japanese DECISION" || fail "missed Japanese DECISION"

# --- validate-write.py ---
echo ""
echo "--- validate-write.py ---"

# Create temp test files
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

# Test: missing frontmatter
echo "# No frontmatter here" > "$TMPDIR/bad-note.md"
OUT=$(echo '{"hook_event_name":"postToolUse","cwd":".","tool_name":"fs_write","tool_input":{"path":"'"$TMPDIR/bad-note.md"'"},"tool_response":{}}' | python3 "$REPO_ROOT/.kiro/scripts/validate-write.py" 2>/dev/null)
echo "$OUT" | grep -qi "frontmatter" && pass "catches missing frontmatter" || fail "missed missing frontmatter"

# Test: missing tags
cat > "$TMPDIR/no-tags.md" << 'EOF'
---
date: 2026-04-08
description: "Test note"
---
# Test
EOF
OUT=$(echo '{"hook_event_name":"postToolUse","cwd":".","tool_name":"fs_write","tool_input":{"path":"'"$TMPDIR/no-tags.md"'"},"tool_response":{}}' | python3 "$REPO_ROOT/.kiro/scripts/validate-write.py" 2>/dev/null)
echo "$OUT" | grep -qi "tags" && pass "catches missing tags" || fail "missed missing tags"

# Test: valid note passes
cat > "$TMPDIR/good-note.md" << 'EOF'
---
date: 2026-04-08
description: "A properly formatted test note"
tags:
  - work-note
---
# Good Note

This note links to [[North Star]] and has proper frontmatter.
EOF
OUT=$(echo '{"hook_event_name":"postToolUse","cwd":".","tool_name":"fs_write","tool_input":{"path":"'"$TMPDIR/good-note.md"'"},"tool_response":{}}' | python3 "$REPO_ROOT/.kiro/scripts/validate-write.py" 2>/dev/null)
[ -z "$OUT" ] && pass "valid note produces no warnings" || fail "false warning on valid note: $OUT"

# Test: skips thinking/ files
OUT=$(echo '{"hook_event_name":"postToolUse","cwd":".","tool_name":"fs_write","tool_input":{"path":"thinking/scratch.md"},"tool_response":{}}' | python3 "$REPO_ROOT/.kiro/scripts/validate-write.py" 2>/dev/null)
[ -z "$OUT" ] && pass "skips thinking/ files" || fail "did not skip thinking/"

# Test: skips README.md
OUT=$(echo '{"hook_event_name":"postToolUse","cwd":".","tool_name":"fs_write","tool_input":{"path":"README.md"},"tool_response":{}}' | python3 "$REPO_ROOT/.kiro/scripts/validate-write.py" 2>/dev/null)
[ -z "$OUT" ] && pass "skips README.md" || fail "did not skip README.md"

# Test: no wikilinks warning on long note
cat > "$TMPDIR/no-links.md" << 'EOF'
---
date: 2026-04-08
description: "A note without any wikilinks at all"
tags:
  - work-note
---
# No Links

This is a long note with lots of content but no wikilinks anywhere.
It goes on and on about various topics without linking to anything.
The vault convention says every note must link to at least one other note.
This note violates that convention and should trigger a warning.
More content to push it over the 300 character threshold.
Even more content here to make absolutely sure.
EOF
OUT=$(echo '{"hook_event_name":"postToolUse","cwd":".","tool_name":"fs_write","tool_input":{"path":"'"$TMPDIR/no-links.md"'"},"tool_response":{}}' | python3 "$REPO_ROOT/.kiro/scripts/validate-write.py" 2>/dev/null)
echo "$OUT" | grep -qi "wikilink" && pass "catches missing wikilinks" || fail "missed missing wikilinks"

# Summary
echo ""
echo "=== Results ==="
echo "  Passed: $PASS"
echo "  Failed: $FAIL"
if [ $FAIL -gt 0 ]; then
  echo -e "\nFailures:$ERRORS"
  exit 1
fi
echo "  All checks passed."
