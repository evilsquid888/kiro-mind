#!/bin/bash
set -eo pipefail

# Kiro agentSpawn hook — inject vault context at session/mode start.
# Stdin: {"hook_event_name":"agentSpawn","cwd":"/path/to/vault"}
# Stdout: context text added to agent's context window.

CWD=$(cat | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "")
cd "${CWD:-.}"

# Incremental QMD re-index (fast, non-blocking if qmd not installed)
qmd update 2>/dev/null || true

echo "## Session Context"
echo ""
echo "### Date"
echo "$(date +%Y-%m-%d) ($(date +%A))"
echo ""

echo "### North Star (current goals)"
if [ -f "brain/North Star.md" ]; then
  head -30 "brain/North Star.md"
else
  echo "(not found)"
fi
echo ""

echo "### Recent Changes (last 48h)"
git log --oneline --since="48 hours ago" --no-merges 2>/dev/null | head -15 || echo "(no git history)"
echo ""

echo "### Open Tasks"
if command -v obsidian &>/dev/null; then
  timeout 5 obsidian tasks daily todo 2>/dev/null | head -10 || echo "(CLI timed out)"
else
  echo "(Obsidian CLI not available)"
fi
echo ""

echo "### Active Work"
ls work/active/*.md 2>/dev/null | sed 's|work/active/||;s|\.md$||' | head -10 || echo "(none)"
echo ""

echo "### Vault File Listing"
find . -name "*.md" -not -path "./.git/*" -not -path "./.obsidian/*" -not -path "./thinking/*" -not -path "./.claude/*" -not -path "./.kiro/*" | sort
