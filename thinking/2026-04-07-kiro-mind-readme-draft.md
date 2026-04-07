# kiro-mind

> An Obsidian vault that doubles as an external brain for work notes, decisions, performance tracking, and Kiro context. Kiro-native sibling of [obsidian-mind](https://github.com/evilsquid888/obsidian-mind).

Designed around Kiro CLI's primitives: **mode agents**, **subagents**, **skills**, **steering**, and **AGENTS.md**. If you use Claude Code, see [obsidian-mind](https://github.com/evilsquid888/obsidian-mind) instead.

## What this gives you

- An Obsidian vault pre-wired for capture, linking, performance tracking, and review prep
- **7 mode agents** for different kinds of work (daily, wrap-up, reviews, incidents, audits, thinking)
- **9 subagents** for heavy lifting (Slack archaeology, PR scanning, cross-linking, review aggregation)
- **Lightweight prompts** for quick capture and editing flows
- **Hooks** that inject daily context, classify messages, and validate writes
- **AGENTS.md** as the canonical rulebook — any agentic tool that respects the standard gets baseline conventions for free

## Install

```bash
# 1. Clone
git clone https://github.com/<you>/kiro-mind ~/vault
cd ~/vault

# 2. Install Kiro CLI (if you haven't)
curl -fsSL https://cli.kiro.dev/install | bash

# 3. Open in Obsidian
# File -> Open Vault -> select ~/vault

# 4. First run — this loads AGENTS.md + steering, runs AgentSpawn hook
kiro-cli
```

On first launch, the `vault` mode's `AgentSpawn` hook injects:
- North Star goals
- Active work (`work/active/`)
- Recent git changes
- Open tasks
- File listing

## Daily flow

You live in **modes**. Each mode is an agent you swap into. Conversation context carries across swaps, so chaining is natural.

```bash
kiro-cli                      # starts in `vault` mode (default)

/agent swap morning           # standup: load context, review yesterday, set priorities
# ... work in morning for a bit, then:
/agent swap vault             # back to day-to-day capture and linking
# ... do work, capture notes, link things ...
/agent swap wrapup            # end-of-session: archive, update indexes, check orphans
```

## Modes

| Mode | When to use | Key behaviors |
|---|---|---|
| `vault` **(default)** | Normal capture, linking, browsing | Hooks active: session-start, classify, validate-write |
| `morning` | Start of day | Reads North Star, git log, tasks; proposes priorities |
| `wrapup` | End of session | Archives completed projects, updates indexes, runs cross-link check via subagent |
| `reviewer` | Performance review writing | Orchestrates `review-prep`, `review-fact-checker` subagents |
| `incident` | Capturing an incident | Invokes `slack-archaeologist`, `people-profiler` subagents |
| `librarian` | Vault maintenance | Runs `vault-librarian`, `cross-linker`, optionally `vault-migrator` |
| `thinker` | Drafting and analysis | Writes to `thinking/` scratchpad, then promotes to atomic notes |

Swap via `/agent swap <mode>`. List with `/agent list`.

## Prompts (lightweight templates)

For things that aren't mode switches — quick capture or text transforms — use `/prompts`:

```bash
/prompts get dump              # dump anything, auto-route to the right note
/prompts get humanize          # voice-calibrate a draft so it sounds like you
/prompts get capture-1on1      # structured 1:1 meeting capture
```

These run inside your current mode without swapping.

## Subagents

Subagents run in isolated context (up to 4 in parallel) and are invoked by mode agents via the `subagent` tool. You rarely call them directly, but you can:

```bash
/agent swap vault
> Use the slack-archaeologist subagent to reconstruct the #incident-123 thread
```

| Subagent | Purpose |
|---|---|
| `brag-spotter` | Finds uncaptured wins and competency gaps |
| `context-loader` | Loads all vault context about a person, project, or concept |
| `cross-linker` | Finds missing wikilinks, orphans, broken backlinks |
| `people-profiler` | Bulk creates/updates person notes from Slack profiles |
| `review-prep` | Aggregates performance evidence for a review period |
| `slack-archaeologist` | Full Slack reconstruction — every message, thread, profile |
| `vault-librarian` | Deep vault maintenance — orphans, broken links, stale notes |
| `review-fact-checker` | Verifies claims in a review draft against vault sources |
| `vault-migrator` | Classifies, transforms, and migrates content from a source vault |

## Skills

Skills auto-load by description matching. You don't invoke them explicitly.

- `obsidian-markdown` — wikilinks, embeds, callouts, properties
- `obsidian-cli` — vault-aware CLI commands when Obsidian is running
- `qmd-search` — semantic search across the vault via QMD
- `frontmatter-validate` — YAML frontmatter schema checks
- `wikilink-check` — broken/missing link detection

## Hooks

Defined per-agent in `.kiro/agents/*.json`, scripts live in `.kiro/scripts/`:

| Hook | Trigger | Script | What it does |
|---|---|---|---|
| `AgentSpawn` | Mode activates | `session-start.sh` | Injects North Star, git log, tasks, file listing |
| `UserPromptSubmit` | User sends message | `classify-message.py` | Classifies content (decision/incident/win/1:1) and injects routing hints |
| `PostToolUse` (matcher: `write`) | After a file is written | `validate-write.py` | Validates frontmatter, checks wikilinks, verifies folder placement |
| `Stop` | Assistant finishes | inline | End-of-session checklist reminder |

## Vault structure

```
kiro-mind/
├── AGENTS.md                # canonical vault rules (tool-neutral)
├── Home.md                  # vault entry point with embedded Base views
├── brain/                   # operational knowledge (Memories, Patterns, Gotchas, Skills, North Star)
├── work/
│   ├── active/              # current projects
│   ├── archive/YYYY/        # completed work
│   ├── incidents/           # incident docs
│   └── 1-1/                 # 1:1 meeting notes
├── perf/                    # performance framework, brag doc, review cycles
├── org/people/              # person notes
├── org/teams/               # team notes
├── reference/               # codebase knowledge, architecture maps
├── thinking/                # scratchpad for drafts
├── templates/               # Obsidian note templates
├── bases/                   # .base files for dynamic views
└── .kiro/
    ├── steering/            # product.md, tech.md, structure.md, linking.md
    ├── agents/              # 7 mode agents + prompt bodies
    ├── subagents/           # 9 specialized subagents
    ├── prompts/             # lightweight /prompts templates
    ├── skills/              # auto-loaded skills
    ├── scripts/             # hook scripts
    └── settings/cli.json
```

## Common commands cheat sheet

```bash
# --- Starting the day ---
kiro-cli                         # enters vault mode, AgentSpawn runs
/agent swap morning              # standup

# --- During work ---
/prompts get dump                # capture anything unstructured
/agent swap thinker              # drafting mode with thinking/ scratchpad
/agent swap vault                # back to default

# --- Reviews ---
/agent swap reviewer             # perf review writing
# (reviewer will invoke review-prep subagent automatically)

# --- Incidents ---
/agent swap incident             # incident capture
# (will invoke slack-archaeologist and people-profiler subagents)

# --- Maintenance ---
/agent swap librarian            # audit, cross-link, clean up
/agent list                      # see all modes
/prompts list                    # see all lightweight templates

# --- Session management ---
/context show                    # what's currently loaded
/compact                         # compact conversation
/chat new                        # start fresh session (saves current)
/agent swap wrapup               # end of day — archive, update indexes
```

## Obsidian CLI integration

When Obsidian is running, the `obsidian-cli` skill activates and the `vault` agent prefers vault-aware commands over raw filesystem:

```bash
obsidian read file="Note Name"
obsidian create name="Name" content="..." silent
obsidian search query="text" limit=10
obsidian backlinks file="Name"
obsidian tasks daily todo
```

Falls back to filesystem when Obsidian isn't running.

## Philosophy

- **Graph-first, not folder-first.** Folders are for browsing; links are for discovery. A note without links is a bug.
- **Atomic notes.** One concept per note. Split anything with 3+ independent sections.
- **Modes, not commands.** Kiro's `/agent swap` preserves context — embrace it. A mode is a lens you work through, not a one-shot.
- **Subagents for heavy lifting.** Keep main-conversation context clean; offload research, aggregation, and reconstruction to isolated subagent contexts.
- **AGENTS.md is canonical.** Kiro-specific wiring lives in `.kiro/`, but the vault rules themselves are tool-neutral.

## Differences from obsidian-mind (Claude Code)

| obsidian-mind | kiro-mind |
|---|---|
| 15 slash commands | 7 mode agents + 3 prompts |
| 9 subagents via Task tool | 9 subagents via `subagent` tool (same shape) |
| `.claude/commands/` | `.kiro/agents/` (modes) + `.kiro/prompts/` (templates) |
| `.claude/agents/` (md + YAML) | `.kiro/subagents/` (JSON) |
| `.claude/skills/` | `.kiro/skills/` (nearly identical `SKILL.md` format) |
| `CLAUDE.md` monolith | `AGENTS.md` + 4 steering files |
| Global hooks in `settings.json` | Per-agent hooks, shared scripts in `.kiro/scripts/` |
| `PreCompact` transcript backup | Dropped (no equivalent) |

---

# Implementation Plan

Everything above describes the **target state**. This section is the build plan to get there.

## Verified facts (from Kiro docs research, 2026-04-07)

| Fact | Source |
|---|---|
| `/agent swap` preserves conversation context | `docs/cli/chat/context/` + changelog |
| `subagent` tool: up to 4 parallel, isolated context, inherits invoked agent's tools | `docs/cli/reference/built-in-tools/` |
| `delegate` tool: async background agents, polled via `/delegate status` | `docs/cli/reference/built-in-tools/` |
| `.kiro/prompts/` is workspace-scoped and repo-trackable | `docs/cli/chat/manage-prompts/` |
| Hook triggers: `AgentSpawn`, `UserPromptSubmit`, `PreToolUse`, `PostToolUse`, `Stop` | `docs/cli/hooks/` |
| Hooks are **per-agent only** (no global hooks) | `docs/cli/hooks/` |
| Built-in tool names: `read`, `write`, `glob`, `grep`, `shell`, `web_search`, `web_fetch`, `subagent`, `delegate`, `thinking`, `todo`, etc. (no separate `Edit`) | `docs/cli/reference/built-in-tools/` |
| Skills: `.kiro/skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`) | `docs/cli/skills/` |
| Steering: `.kiro/steering/*.md`; `AGENTS.md` always auto-included | `docs/cli/steering/` |
| Agent config format: JSON at `.kiro/agents/<name>.json`; prompt supports `file://` URIs | `docs/cli/custom-agents/configuration-reference/` |
| Settings: `~/.kiro/settings/cli.json` | `docs/cli/reference/settings/` |
| No `PreCompact` equivalent | `docs/cli/hooks/` |

## Open questions (verify in Phase 2 scratch test)

1. **Prompt file format.** `.kiro/prompts/*.md`? JSON? Frontmatter required? → create one via `/prompts create` and inspect.
2. **Hook inheritance across agents.** Does `kiro_default`'s hook config apply when a custom mode agent is active, or must each agent declare its own? → define a loud hook in `vault` only, swap to `thinker`, observe.
3. **`subagent` tool scoping.** Does it honor `allowedTools` declared in the invoked subagent's config, or inherit from the caller? → give a subagent narrow tools, invoke it from an agent with broad tools, test.
4. **Agent chain depth.** Can a subagent itself invoke another subagent? (Probably no — 4-parallel cap implies flat.) → try nested; fall back to orchestration in the mode agent if blocked.
5. **`AgentSpawn` fires on swap?** Does it fire once per mode swap or only on `kiro-cli` startup? → put `date >> /tmp/spawn.log` in the hook, swap 3 times, count lines.

## Phases

### Phase 1 — Baseline content and docs (est. 1 day)

**Deliverables**
- New repo `kiro-mind` (fresh git init; copy vault content, not history)
- Copied folders: `brain/`, `work/`, `perf/`, `org/`, `reference/`, `thinking/`, `templates/`, `bases/`, `.obsidian/`
- Copied root files: `Home.md`, `vault-manifest.json`, `CHANGELOG.md` (reset to v0.1), `LICENSE`, `.gitignore`
- `AGENTS.md` — tool-neutral rewrite of `CLAUDE.md` (strip slash command table, strip Skill-tool references, strip `.claude/` paths)
- `.kiro/steering/product.md` — what this vault is for (purpose, audience, non-goals)
- `.kiro/steering/tech.md` — Obsidian + QMD + Bases + Kiro stack versions
- `.kiro/steering/structure.md` — folder layout and note type table
- `.kiro/steering/linking.md` — graph-first rules, atomicity rule, link conventions
- `README.md` — the content above this plan section
- 5 skills ported from `.claude/skills/` to `.kiro/skills/<name>/SKILL.md` (format is nearly identical)

**Exit gate**: `kiro-cli` starts in the repo, loads AGENTS.md + steering without errors, can read/write notes using default agent.

### Phase 2 — Default `vault` agent + hooks + open-question verification (est. 1 day)

**Deliverables**
- `.kiro/agents/vault.json` — default mode agent config
- `.kiro/agents/prompts/vault.md` — prompt body loaded via `file://`
- `.kiro/scripts/session-start.sh` — port from `.claude/scripts/`, adapt to Kiro's AgentSpawn stdin JSON
- `.kiro/scripts/classify-message.py` — port; adapt stdin format
- `.kiro/scripts/validate-write.py` — port; matcher becomes `write` (single tool, no `Edit` branch)
- Hooks wired in `vault.json`: AgentSpawn, UserPromptSubmit, PostToolUse(write), Stop
- **Scratch tests answering all 5 open questions** — results committed to `thinking/kiro-verification-<date>.md`

**Exit gate**: Session start injects context, capture a test note, validate-write fires, classify-message fires. All 5 open questions have documented answers.

### Phase 3 — Subagents (est. 2 days)

Port 9 subagents from `.claude/agents/*.md` to `.kiro/subagents/*.json`.

**Per subagent:**
1. Create `.kiro/subagents/<name>.json` with JSON config
2. Move prompt body to `.kiro/subagents/prompts/<name>.md`, reference via `file://`
3. Declare narrow `allowedTools` (e.g. `slack-archaeologist` needs `read`, `grep`, MCP Slack tools; not `write`)
4. Test in isolation from `vault` mode: `Use the <name> subagent to <task>`

**Port order** (easiest → hardest, to build confidence):
1. `context-loader` (read-only, simple)
2. `cross-linker` (read + grep)
3. `brag-spotter` (read + grep)
4. `vault-librarian` (read + glob + grep)
5. `people-profiler` (read + write, Slack MCP)
6. `review-fact-checker` (read + grep)
7. `review-prep` (read + write, aggregation heavy)
8. `slack-archaeologist` (complex MCP flow)
9. `vault-migrator` (read + write, most risk)

**Exit gate**: each subagent invokable from `vault`, returns structured output, doesn't bleed context to main conversation.

### Phase 4 — Mode agents (est. 2 days)

Build 6 additional modes. For each: JSON config + prompt body + hook copies + subagent wiring.

| Mode | Subagents invoked | Notes |
|---|---|---|
| `morning` | `context-loader` (optional) | Reads North Star, proposes priorities |
| `wrapup` | `cross-linker`, `brag-spotter`, `vault-librarian` | Heaviest orchestrator |
| `reviewer` | `review-prep`, `review-fact-checker` | Handles self + peer + manager reviews |
| `incident` | `slack-archaeologist`, `people-profiler` | Structured capture flow |
| `librarian` | `vault-librarian`, `cross-linker`, `vault-migrator` | Maintenance |
| `thinker` | none | Drafting, writes to `thinking/` |

**Decision per mode**: copy hooks from `vault.json` or omit? Depends on Phase 2 answer to open question #2. If hooks inherit from default, omit. If not, copy the critical ones (`UserPromptSubmit`, `PostToolUse`).

**Exit gate**: every Claude Code slash command has a mode or prompt equivalent; cheat sheet in README is accurate.

### Phase 5 — Lightweight prompts (est. 0.5 day)

Create via `/prompts create`:
- `dump` — freeform capture, auto-route
- `humanize` — voice calibration
- `capture-1on1` — structured 1:1 meeting capture

**Verify**: commit `.kiro/prompts/*`, clone fresh, confirm they're available via `/prompts list`.

### Phase 6 — Dogfood + migration guide + release (est. 1 week calendar, part-time)

- Use kiro-mind exclusively for 5 working days
- Log friction points in `thinking/kiro-dogfood-<date>.md`
- Fix top 5 issues
- Write `docs/migration-from-obsidian-mind.md`: how to move a vault from the Claude Code version, mapping table, gotchas
- Tag `v0.1.0`, write release notes

## Risks and mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| Hooks don't inherit → 7x duplication in agent configs | Medium | Low | Scripts are shared; only JSON stanzas duplicate. Keep a single `hooks.json` fragment and script the assembly if it gets painful. |
| `subagent` tool doesn't match Claude Task semantics cleanly | Medium | Medium | Verify in Phase 2. If broken, collapse some subagents into mode-agent prompts. |
| `.kiro/prompts/` format is JSON-only or not markdown-friendly | Low | Low | Fall back to all-agents, no prompts. Lose 3 commands' ergonomics. |
| Kiro tool name changes in a future release | Low | Medium | Pin CLI version in `tech.md` steering. |
| `AgentSpawn` fires only on CLI start, not swap | Medium | Medium | Move session-start injection to `UserPromptSubmit` with a "first message of session" guard. |
| Context carry-across-swap has hidden gotchas (e.g. tool permissions reset) | Low | High | Phase 2 scratch test question #2. |
| Scope creep — tempting to "improve" the vault content while porting | High | Medium | Hard rule: Phase 1 is **copy**, not refactor. Vault content changes go in a separate PR post-v0.1. |

## Non-goals for v0.1

- Back-porting improvements to `obsidian-mind` (Claude Code version stays as-is)
- `PreCompact` equivalent / transcript backup
- Cross-tool config sync (a change in kiro-mind does **not** automatically propagate to obsidian-mind)
- Automated test suite for agent configs (manual verification is fine at this stage)
- Windows support (Linux/macOS only, matches obsidian-mind)

## Sample artifacts

### `.kiro/agents/vault.json` skeleton

```json
{
  "description": "Default mode — day-to-day capture, linking, and vault browsing",
  "prompt": "file://.kiro/agents/prompts/vault.md",
  "model": "claude-sonnet-4-6",
  "tools": ["read", "write", "glob", "grep", "shell", "subagent", "thinking", "todo"],
  "allowedTools": ["read", "glob", "grep", "thinking", "todo"],
  "resources": [
    "file://.kiro/steering/**/*.md",
    "skill://obsidian-markdown",
    "skill://obsidian-cli",
    "skill://qmd-search",
    "skill://frontmatter-validate",
    "skill://wikilink-check"
  ],
  "hooks": {
    "AgentSpawn": [
      { "command": "bash .kiro/scripts/session-start.sh", "timeout": 30 }
    ],
    "UserPromptSubmit": [
      { "command": "python3 .kiro/scripts/classify-message.py", "timeout": 15 }
    ],
    "PostToolUse": [
      { "matcher": "write", "command": "python3 .kiro/scripts/validate-write.py", "timeout": 15 }
    ],
    "Stop": [
      { "command": "echo 'Session end checklist: archive? indexes? links?'", "timeout": 5 }
    ]
  }
}
```

*Field names to verify against the agent config reference during Phase 2 — this is illustrative.*

### `.kiro/subagents/slack-archaeologist.json` skeleton

```json
{
  "description": "Deep Slack reconstruction — every message, thread, profile. Invoke for incident timelines and evidence gathering.",
  "prompt": "file://.kiro/subagents/prompts/slack-archaeologist.md",
  "model": "claude-sonnet-4-6",
  "tools": ["read", "grep", "@slack/*"],
  "allowedTools": ["read", "grep", "@slack/conversations_history", "@slack/users_info"],
  "resources": [
    "file://.kiro/steering/structure.md"
  ]
}
```

## Effort summary

| Phase | Est. effort | Calendar |
|---|---|---|
| 1. Baseline | 1 day | Day 1 |
| 2. vault agent + verification | 1 day | Day 2 |
| 3. Subagents × 9 | 2 days | Days 3–4 |
| 4. Mode agents × 6 | 2 days | Days 5–6 |
| 5. Prompts | 0.5 day | Day 7 |
| 6. Dogfood + release | ~5 working days part-time | Week 2 |

**Minimum viable release**: Phases 1 + 2 + `vault` + 1 subagent + 1 mode. Proves the concept end-to-end. ~2.5 days.

## Decision log

- **2026-04-07**: Chose sibling repo over port, branch, or subfolder. Rationale: ergonomics mismatch is too large for a port; branch/subfolder mixes tool configs and invites drift.
- **2026-04-07**: Chose mode agents over trying to emulate slash commands. Rationale: `/agent swap` context preservation (verified) makes modes a natural replacement.
- **2026-04-07**: Kept subagents as real subagents (not skills). Rationale: Kiro has a native `subagent` tool with Claude Task-tool parity.
- **2026-04-07**: Hand-authored AGENTS.md, not generated. Rationale: low change rate, generation adds a build step and drift risk.
- **2026-04-07**: Dropped `PreCompact` transcript backup. Rationale: no Kiro trigger; non-critical.
- **2026-04-07**: Lives as unmerged branch `kiro-mind-draft` in obsidian-mind repo, not a sibling repo. `.kiro/` is additive and does not touch `.claude/`. Vault content (`brain/`, `work/`, etc.) is shared — no copy.
- **2026-04-07**: License MIT (matches obsidian-mind). Starting version v0.1.0.
- **2026-04-07**: Models — use the same Claude models as obsidian-mind (`claude-sonnet-4-6`, `claude-opus-4-6`). Pending verification that Kiro CLI routes to Anthropic directly and not Bedrock-only.
- **2026-04-07**: Hook script languages unchanged — bash + python3, same as obsidian-mind.
- **2026-04-07**: MCP server configuration is user's responsibility — no shipped `.kiro/mcp.json` template.
- **2026-04-07**: Vault content treated as template stubs shared with `main` (option 7c). Branch references the existing stubs, no fork of personal data.
- **2026-04-07**: Maintenance posture: best-effort, no promises. README notes "experimental, may lag Kiro CLI releases".
- **2026-04-07**: Risky subagents (`slack-archaeologist`, `vault-migrator`) ship in v0.1 with `experimental: true` marker and README warning "use at your own risk, not fully tested against Kiro MCP semantics". Do not block v0.1 on them working perfectly.

---

## Status

Early. Designed from research, not yet dogfooded. See `CHANGELOG.md` for release history.

## License

MIT
