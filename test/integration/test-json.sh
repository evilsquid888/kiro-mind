#!/bin/bash
# test-json.sh — Validate all agent JSON configs and project structure.
# No kiro-cli needed. Runs with just python3 + bash.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PASS=0; FAIL=0; ERRORS=""

pass() { PASS=$((PASS + 1)); echo "  ✓ $1"; }
fail() { FAIL=$((FAIL + 1)); ERRORS="${ERRORS}\n  ✗ $1"; echo "  ✗ $1"; }

echo "=== JSON Config Validation ==="

# 1. All agent JSONs are valid JSON
for f in "$REPO_ROOT"/.kiro/agents/*.json; do
  name=$(basename "$f")
  python3 -m json.tool "$f" > /dev/null 2>&1 && pass "$name valid JSON" || fail "$name INVALID JSON"
done

# 2. All agent JSONs have required fields
for f in "$REPO_ROOT"/.kiro/agents/*.json; do
  name=$(basename "$f")
  python3 -c "
import json, sys
with open('$f') as fh:
    d = json.load(fh)
missing = [k for k in ['description', 'tools'] if k not in d]
if missing:
    print(f'Missing: {missing}', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null && pass "$name has required fields" || fail "$name missing required fields"
done

# 3. Mode agents (7) have hooks assembled (no _hooks_preset remaining)
MODE_AGENTS="vault morning wrapup reviewer incident librarian thinker"
for agent in $MODE_AGENTS; do
  f="$REPO_ROOT/.kiro/agents/$agent.json"
  [ -f "$f" ] || { fail "$agent.json missing"; continue; }
  python3 -c "
import json, sys
with open('$f') as fh:
    d = json.load(fh)
if '_hooks_preset' in d:
    print('_hooks_preset not assembled', file=sys.stderr)
    sys.exit(1)
if 'hooks' not in d:
    print('no hooks field', file=sys.stderr)
    sys.exit(1)
" 2>/dev/null && pass "$agent.json hooks assembled" || fail "$agent.json hooks NOT assembled"
done

# 4. Subagents (9) do NOT have hooks
SUBAGENTS="brag-spotter context-loader cross-linker people-profiler review-prep review-fact-checker slack-archaeologist vault-librarian vault-migrator"
for agent in $SUBAGENTS; do
  f="$REPO_ROOT/.kiro/agents/$agent.json"
  [ -f "$f" ] || { fail "$agent.json missing"; continue; }
  python3 -c "
import json, sys
with open('$f') as fh:
    d = json.load(fh)
if 'hooks' in d:
    sys.exit(1)
" 2>/dev/null && pass "$agent.json no hooks (correct for subagent)" || fail "$agent.json has hooks (unexpected for subagent)"
done

# 5. All prompt file:// references resolve
for f in "$REPO_ROOT"/.kiro/agents/*.json; do
  name=$(basename "$f")
  python3 -c "
import json, sys, os
with open('$f') as fh:
    d = json.load(fh)
prompt = d.get('prompt', '')
if prompt.startswith('file://'):
    rel = prompt.replace('file://', '')
    agent_dir = os.path.dirname('$f')
    full = os.path.normpath(os.path.join(agent_dir, rel))
    if not os.path.isfile(full):
        print(f'Prompt not found: {full}', file=sys.stderr)
        sys.exit(1)
" 2>/dev/null && pass "$name prompt file resolves" || fail "$name prompt file MISSING"
done

# 6. No keyboard shortcut conflicts
echo ""
echo "=== Keyboard Shortcut Check ==="
python3 -c "
import json, glob, sys
shortcuts = {}
for f in glob.glob('$REPO_ROOT/.kiro/agents/*.json'):
    with open(f) as fh:
        d = json.load(fh)
    ks = d.get('keyboardShortcut')
    if ks:
        name = f.split('/')[-1]
        if ks in shortcuts:
            print(f'CONFLICT: {ks} used by {shortcuts[ks]} and {name}', file=sys.stderr)
            sys.exit(1)
        shortcuts[ks] = name
print(f'  ✓ {len(shortcuts)} shortcuts, no conflicts')
" 2>/dev/null && PASS=$((PASS + 1)) || { fail "keyboard shortcut conflict"; }

# 7. File structure checks
echo ""
echo "=== File Structure ==="
[ -f "$REPO_ROOT/AGENTS.md" ] && pass "AGENTS.md exists" || fail "AGENTS.md missing"
[ -d "$REPO_ROOT/.kiro/steering" ] && pass ".kiro/steering/ exists" || fail ".kiro/steering/ missing"
[ -d "$REPO_ROOT/.kiro/skills" ] && pass ".kiro/skills/ exists" || fail ".kiro/skills/ missing"
[ -d "$REPO_ROOT/.kiro/prompts" ] && pass ".kiro/prompts/ exists" || fail ".kiro/prompts/ missing"
[ -d "$REPO_ROOT/.kiro/scripts" ] && pass ".kiro/scripts/ exists" || fail ".kiro/scripts/ missing"

for f in product.md tech.md structure.md linking.md; do
  [ -f "$REPO_ROOT/.kiro/steering/$f" ] && pass "steering/$f" || fail "steering/$f missing"
done

for s in obsidian-markdown obsidian-cli qmd-search frontmatter-validate wikilink-check; do
  [ -f "$REPO_ROOT/.kiro/skills/$s/SKILL.md" ] && pass "skill $s" || fail "skill $s missing"
done

for p in dump.md humanize.md capture-1on1.md project-archive.md; do
  [ -f "$REPO_ROOT/.kiro/prompts/$p" ] && pass "prompt $p" || fail "prompt $p missing"
done

for s in session-start.sh classify-message.py validate-write.py charcount.sh; do
  [ -f "$REPO_ROOT/.kiro/scripts/$s" ] && pass "script $s" || fail "script $s missing"
done

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
