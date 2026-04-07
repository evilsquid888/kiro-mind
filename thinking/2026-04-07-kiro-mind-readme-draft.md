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

## Status

Early. Designed from research, not yet dogfooded. See `CHANGELOG.md` for release history.

## License

MIT
