#!/bin/bash
set -euo pipefail
# Merge hook stanzas from _hooks-common.json into agent configs.
# Usage: bash .kiro/scripts/build-agents.sh
#
# Each agent config can have a "_hooks_preset" field ("full", "spawn-and-validate",
# "spawn-only", or absent). This script reads the preset, merges the hooks from
# _hooks-common.json, removes the _hooks_preset field, and writes back.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HOOKS_FILE="$SCRIPT_DIR/_hooks-common.json"
AGENTS_DIR="$SCRIPT_DIR/../agents"

if [ ! -f "$HOOKS_FILE" ]; then
  echo "ERROR: $HOOKS_FILE not found" >&2
  exit 1
fi

count=0
for agent_file in "$AGENTS_DIR"/*.json; do
  [ -f "$agent_file" ] || continue

  preset=$(python3 -c "
import json, sys
with open('$agent_file') as f:
    d = json.load(f)
print(d.get('_hooks_preset', ''))
" 2>/dev/null || echo "")

  if [ -z "$preset" ]; then
    continue
  fi

  python3 -c "
import json, sys

with open('$HOOKS_FILE') as f:
    presets = json.load(f)
with open('$agent_file') as f:
    agent = json.load(f)

preset = agent.pop('_hooks_preset', None)
if preset and preset in presets:
    agent['hooks'] = presets[preset]

with open('$agent_file', 'w') as f:
    json.dump(agent, f, indent=2)
    f.write('\n')
"
  count=$((count + 1))
  echo "  ✓ $(basename "$agent_file") ← $preset"
done

echo "Assembled hooks for $count agent(s)."
