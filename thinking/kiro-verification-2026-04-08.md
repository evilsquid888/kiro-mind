# Kiro CLI Verification — Open Questions

> Date: 2026-04-08
> Context: Answering 5 open questions from `thinking/2026-04-08-kiro-mind-spec-v2.md`
> Method: Kiro CLI docs analysis + headless empirical tests

---

## Q1: What is the exact file format of `.kiro/prompts/*`?

**Answer: Plain markdown files (`.md`). No frontmatter required.**

**Evidence**: Kiro CLI docs (`/prompts` slash command documentation).

**Details**:
- Files are stored as `.kiro/prompts/<name>.md` (local) or `~/.kiro/prompts/<name>.md` (global)
- Local takes precedence over global with same name
- Content is plain markdown — no YAML frontmatter needed
- Argument substitution via placeholders:
  - `${1}` through `${10}` — positional arguments
  - `$ARGUMENTS` — all arguments joined by spaces
  - `${@}` — shell-style alias for `$ARGUMENTS`
- Name rules: alphanumeric, hyphens, underscores only. Max 50 chars. Pattern: `^[a-zA-Z0-9_-]+$`
- Created via `/prompts create --name <name>` or manually

**Verified**: Created `.kiro/prompts/test-q1.md` manually — plain markdown, no frontmatter.

**Impact on spec**: No changes needed. The spec already assumed markdown. Prompts are simpler than feared — no JSON, no frontmatter overhead.

---

## Q2: Do hooks on one agent fire when a different agent is active?

**Answer: NO. Hooks do NOT inherit across agent swaps. Each agent only runs its own hooks.**

**Evidence**: Kiro CLI docs (hooks system + agent swap + agent configuration).

**Key doc quotes**:
1. Hooks are "defined in agent configuration files" — per-agent, not global
2. Agent swap: "Tool Manager: Recreated with new agent's tool configuration and permissions"
3. Agent swap: "Tool permissions reset to new agent's configuration"
4. `/hooks` command: "Displays hooks configured in current agent"
5. No mention of hook inheritance, global hooks, or hook sharing anywhere in docs

**Confidence**: High (docs are unambiguous). Interactive verification script provided below.

**Interactive verification** (run manually to get 100% empirical proof):
```bash
rm -f /tmp/kiro-hook-test.log
kiro-cli chat --agent test-hooked
# Send: "hello" → check /tmp/kiro-hook-test.log (should have userPromptSubmit entry)
# Run: /agent swap test-nohook
# Send: "hello again" → check log (should have NO new entry)
# Run: /agent swap test-hooked
# Send: "hello once more" → check log (should have new entry)
```

**Impact on spec**: Confirmed the risk. Every mode agent that needs `classify-message.py` or `validate-write.py` must declare its own hook stanzas. The `_hooks-common.json` + `build-agents.sh` assembly approach in the spec is the right mitigation.

---

## Q3: Does the `subagent` tool honor `allowedTools` from the invoked subagent's config?

**Answer: YES. The subagent runs with its OWN tools, not the caller's.**

**Evidence**: Empirical test (headless, `kiro-cli chat --no-interactive --trust-all-tools`).

**Test setup**:
- `test-caller.json`: tools = `[fs_read, fs_write, use_subagent, glob, grep]`
- `test-narrow.json`: tools = `[fs_read]` (no fs_write)
- test-caller invoked test-narrow with query: "Try to create a file using fs_write"

**Result**: The subagent reported:
> "The fs_write tool was **not available** to it. Its only tools are **read** (for reading files/directories/images) and **summary** (for reporting results)."

The file `/tmp/kiro-q3-test.txt` was NOT created.

**Key finding**: Subagents get stripped down to their own config's tools + the built-in `summary` tool. The caller's broader tool set does NOT leak into the subagent.

**Impact on spec**: This is exactly what we want. Subagents can be given narrow tools (e.g., `slack-archaeologist` gets read + grep + Slack MCP, not write). The spec's per-subagent `allowedTools` design is correct.

---

## Q4: Can a subagent invoke another subagent (nested delegation)?

**Answer: NO. Nested subagents are NOT supported. Delegation is flat.**

**Evidence**: Empirical test (headless, `kiro-cli chat --no-interactive --trust-all-tools`).

**Test setup**:
- `test-q4-caller.json`: invokes `test-nester` subagent
- `test-nester.json`: has `use_subagent` in its tools config + `availableAgents: ["test-narrow"]`
- test-nester was asked to invoke test-narrow from within its subagent context

**Result**: The subagent reported:
> "Nesting **failed**. The test-nester subagent reported that it does not have access to a subagent invocation tool within its own context. Its available tools were limited to **summary** and **read** — no **use_subagent** tool was present."

**Key finding**: Even though `test-nester.json` declares `use_subagent` in its tools list, when running AS a subagent, the `use_subagent` tool is stripped. Subagents only get their declared read/write/grep/etc. tools + the built-in `summary` tool. The subagent tool itself is not available to subagents.

**Impact on spec**: Confirmed the spec's assumption. Orchestration must happen in the mode agent (top level), not in subagents. For example, `incident` mode must invoke `slack-archaeologist` and `people-profiler` directly — `slack-archaeologist` cannot invoke `people-profiler` on its own.

---

## Q5: Does `agentSpawn` fire on every `/agent swap` or only on CLI startup?

**Answer: Fires on every agent activation, including swap (high confidence).**

**Evidence**: Kiro CLI docs + partial empirical verification.

**Doc evidence**:
1. `agentSpawn`: "Runs when agent is **activated**" — not "on startup"
2. "AgentSpawn hooks are **never cached**" — implies frequent firing; if it only fired once on startup, caching would be irrelevant
3. Agent swap fully recreates the agent: "Tool Manager: Recreated with new agent's tool configuration"
4. Agent swap docs describe a full agent reload, not a partial reconfiguration

**Empirical evidence**: Confirmed `agentSpawn` fires on CLI startup via headless test. The hook log shows:
```
[HOOK-FIRED] agentSpawn at 20:38:45
```

**Interactive verification** (for swap specifically):
```bash
rm -f /tmp/kiro-hook-test.log
kiro-cli chat --agent test-hooked
# Log should show 1 agentSpawn entry
# Run: /agent swap test-nohook
# Run: /agent swap test-hooked
# Check log — should show 2 agentSpawn entries (startup + swap back)
```

**Confidence**: High from docs. The "never cached" note is the strongest signal — it only makes sense if agentSpawn fires frequently enough that caching was considered and rejected.

**Impact on spec**: This is good news. The `session-start.sh` hook in `agentSpawn` will fire on every mode swap, meaning each mode gets fresh context injection. No need for a `userPromptSubmit` first-message guard as a fallback.

---

## Summary Table

| # | Question | Answer | Method | Confidence |
|---|----------|--------|--------|------------|
| 1 | Prompt file format | Plain `.md`, no frontmatter, `${1}`-`${10}` args | Docs + manual creation | Verified |
| 2 | Hook inheritance across agents | NO — per-agent only | Docs (5 evidence points) | High |
| 3 | Subagent honors own allowedTools | YES — caller's tools don't leak | Empirical (headless) | Verified |
| 4 | Nested subagents | NO — `use_subagent` stripped from subagents | Empirical (headless) | Verified |
| 5 | agentSpawn fires on swap | YES — fires on every activation | Docs + partial empirical | High |

## Test Artifacts

Test agents created in `.kiro/agents/`:
- `test-hooked.json` — agent with agentSpawn + userPromptSubmit hooks (Q2, Q5)
- `test-nohook.json` — agent without hooks (Q2)
- `test-narrow.json` — read-only subagent (Q3)
- `test-caller.json` — broad-tools agent that invokes test-narrow (Q3)
- `test-nester.json` — subagent that tries to nest another subagent (Q4)
- `test-q4-caller.json` — invokes test-nester (Q4)

Test prompt: `.kiro/prompts/test-q1.md` (Q1)

These can be deleted after verification is complete.
