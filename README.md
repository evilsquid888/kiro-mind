# 🧠 Kiro Mind

[![Kiro CLI](https://img.shields.io/badge/kiro%20cli-required-10B981)](https://kiro.dev)
[![Obsidian](https://img.shields.io/badge/obsidian-1.12%2B-7C3AED)](https://obsidian.md)
[![Python](https://img.shields.io/badge/python-3.8%2B-3776AB)](https://python.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> **An Obsidian vault that makes Kiro CLI remember everything.** Start a session, talk about your day, and Kiro handles the rest — notes, links, indexes, performance tracking. Every conversation builds on the last.

Based on [obsidian-mind](https://github.com/breferrari/obsidian-mind) by [@breferrari](https://github.com/breferrari). Redesigned from scratch around Kiro CLI's primitives — mode agents, subagents, skills, steering, and `AGENTS.md`.

---

## 🔴 The Problem

AI coding assistants are powerful, but they forget. Every session starts from zero — no context on your goals, your team, your patterns, your wins. You re-explain the same things. You lose decisions made three conversations ago. The knowledge never compounds.

## 🟢 The Solution

Give Kiro a brain.

```
You: "start session"
Kiro: *reads North Star, checks active projects, scans recent memories*
Kiro: "You're working on Project Alpha, blocked on the BE contract.
       Last session you decided to split the coordinator. Your 1:1
       with your manager is tomorrow — review brief is ready."
```

---

## ⚡ How It Works

You live in **modes**. Each mode is an agent you swap into. Conversation context carries across swaps, so chaining is natural.

```bash
kiro-cli                              # starts in vault mode (default)
/agent swap morning                   # standup: load context, set priorities
/agent swap vault                     # back to day-to-day capture
/agent swap wrapup                    # end of session: verify, archive, brag-spot
```

**Morning kickoff:**

```bash
/agent swap morning
# → loads North Star, active projects, open tasks, recent git changes
# → "You have 2 active projects. The auth refactor is blocked on API contract.
#    Your 1:1 with Sarah is at 2pm — last time she flagged observability."
```

**Brain dump after a meeting:**

```bash
/prompts get dump Just had a 1:1 with Sarah. She's happy with the auth work
but wants us to add error monitoring before release. Decision: defer Redis
migration. Win: Sarah praised the auth architecture.
```

```
→ Updated org/people/Sarah Chen.md with meeting context
→ Created work/1-1/Sarah 2026-03-26.md with key takeaways
→ Created Decision Record: "Defer Redis migration to Q2"
→ Added to perf/Brag Doc.md: "Auth architecture praised by manager"
```

**End of day:**

```
You: "wrap up"
→ /agent swap wrapup
→ verifies all notes have links, updates indexes
→ brag-spotter finds uncaptured wins
→ suggests improvements
```

---

## 🚀 Quick Start

1. Clone this repo (or use it as a **GitHub template**)
2. Open the folder as an **Obsidian vault**
3. Install **Kiro CLI**: `curl -fsSL https://cli.kiro.dev/install | bash`
4. Run **`kiro-cli chat --agent vault`** in the vault directory
5. Fill in **`brain/North Star.md`** with your goals — this grounds every session
6. Start talking about work

### Optional: QMD Semantic Search

```bash
npm install -g @tobilu/qmd
qmd collection add . --name vault --mask "**/*.md"
qmd context add qmd://vault "Engineer's work vault"
qmd update && qmd embed
```

> [!NOTE]
> If QMD isn't installed, everything still works — Kiro falls back to grep and filesystem.

---

## 📋 Requirements

- [Kiro CLI](https://kiro.dev) (install: `curl -fsSL https://cli.kiro.dev/install | bash`)
- [Obsidian](https://obsidian.md) 1.12+ (for CLI support)
- Python 3.8+ (for hook scripts)
- Git (for version history)
- [QMD](https://github.com/tobi/qmd) (optional, for semantic search)
- [GitHub CLI](https://cli.github.com/) (optional, for `peer-scan` PR scanning in reviewer mode)
- Slack MCP server (optional, user-configured — required for `incident` mode and `slack-archaeologist`/`people-profiler` subagents)

---

## 🎯 Modes

| Mode | Shortcut | Purpose | Subagents |
|------|----------|---------|-----------|
| `vault` | `Ctrl+Shift+V` | Default — capture, link, browse | All 9 available |
| `morning` | `Ctrl+Shift+M` | Standup — read-only context load, priorities | context-loader |
| `wrapup` | `Ctrl+Shift+W` | Session review or weekly synthesis | brag-spotter, cross-linker, vault-librarian |
| `reviewer` | `Ctrl+Shift+R` | Self-review, peer review, review briefs, PR scanning | review-prep, review-fact-checker, brag-spotter |
| `incident` | `Ctrl+Shift+I` | Incident capture from Slack | slack-archaeologist, people-profiler |
| `librarian` | `Ctrl+Shift+L` | Vault audit and content migration | vault-librarian, cross-linker, vault-migrator |
| `thinker` | `Ctrl+Shift+T` | Drafting in thinking/ scratchpad | None (solo) |

Swap via `/agent swap <mode>` or keyboard shortcut. Context is preserved across swaps.

---

## 🛠️ Prompts

For quick actions that don't need a mode switch:

| Prompt | Usage | What it does |
|--------|-------|-------------|
| `dump` | `/prompts get dump <text>` | Classify and route freeform content to correct notes |
| `humanize` | `/prompts get humanize <file>` | Voice-calibrate a draft to sound like you |
| `capture-1on1` | `/prompts get capture-1on1 <person>` | Structured 1:1 meeting capture |
| `project-archive` | `/prompts get project-archive <name>` | Archive project from active/ to archive/ |

---

## 🤖 Subagents

Specialized agents that run in isolated context (up to 4 in parallel). Each mode declares which subagents it can access.

| Subagent | Purpose | Primary mode |
|----------|---------|-------------|
| `brag-spotter` | Uncaptured wins and competency gaps | wrapup |
| `context-loader` | Load all vault context about a topic | morning, vault |
| `cross-linker` | Missing wikilinks, orphans, broken backlinks | wrapup, librarian |
| `people-profiler` | Bulk create/update person notes from Slack | incident |
| `review-prep` | Aggregate performance evidence for a period | reviewer |
| `review-fact-checker` | Verify claims in review drafts against vault | reviewer |
| `slack-archaeologist` | Full Slack reconstruction — messages, threads, profiles | incident |
| `vault-librarian` | Deep maintenance — orphans, links, frontmatter, stale notes | librarian |
| `vault-migrator` | Classify, transform, migrate content from another vault | librarian |

---

## ⚙️ Hooks

Per-agent hooks fire automatically. Shared scripts in `.kiro/scripts/`, assembled into each agent via `build-agents.sh`.

| Hook | Trigger | Script | What |
|------|---------|--------|------|
| `agentSpawn` | Mode activates (including swap) | `session-start.sh` | Inject North Star, git log, tasks, file listing |
| `userPromptSubmit` | User sends message | `classify-message.py` | Classify content → routing hints |
| `postToolUse` | After writing `.md` | `validate-write.py` | Validate frontmatter, wikilinks, folder |
| `stop` | Assistant finishes | inline | Session checklist reminder |

> [!TIP]
> You just talk. The hooks handle the routing.

---

## 📅 Daily Workflow

**Morning**: `/agent swap morning`. Kiro loads your North Star, active projects, open tasks, and recent changes. You get a structured summary and suggested priorities.

**Throughout the day**: Stay in `vault` mode. Talk naturally. The classification hook nudges Kiro to file each piece correctly. Use `/prompts get dump` for bigger brain dumps.

**End of day**: Say "wrap up" — Kiro suggests swapping to `wrapup` mode, which verifies notes, updates indexes, checks links, and spots uncaptured wins.

**Weekly**: `/agent swap wrapup` + say "weekly" for cross-session synthesis — North Star alignment, patterns, uncaptured wins, and next-week priorities.

**Review season**: `/agent swap reviewer` + "review brief manager" — gets a structured review prep document with all evidence linked.

---

## 📊 Performance Graph

The vault doubles as a performance tracking system:

1. **Competency notes** in `perf/competencies/` define your org's framework
2. **Work notes** link to competencies in `## Related` — evidence accumulates via backlinks
3. **Brag Doc** aggregates wins per quarter with links to evidence
4. **Reviewer mode** deep-scans PRs, aggregates evidence, and generates review briefs
5. **Review fact-checker** verifies every claim against vault sources

---

## 📁 Vault Structure

```
Home.md                 Vault entry point — embedded Base views, quick links
AGENTS.md               Tool-neutral rulebook — any agentic tool can follow this
vault-manifest.json     Template metadata — version, structure, schemas
CHANGELOG.md            Version history
README.md               This file

brain/                  Operational knowledge (North Star, Memories, Patterns, Gotchas, Skills)
work/
  active/               Current projects (1–3 files at a time)
  archive/YYYY/         Completed work, organized by year
  incidents/            Incident docs (main note + RCA + deep dive)
  1-1/                  1:1 meeting notes
  Index.md              Map of Content for all work
org/
  people/               One note per person
  teams/                One note per team
  People & Context.md   MOC for organizational knowledge
perf/
  Brag Doc.md           Running log of wins
  brag/                 Quarterly brag notes
  competencies/         One note per competency
  evidence/             PR deep scans, data extracts
  <cycle>/              Review cycle briefs
reference/              Codebase knowledge, architecture maps
thinking/               Scratchpad for drafts — promote, then delete
templates/              Obsidian templates with YAML frontmatter
bases/                  Dynamic database views

.kiro/
  agents/               7 mode agents + 9 subagents (JSON configs)
    prompts/            16 prompt bodies (referenced via file://)
  prompts/              4 lightweight prompts
  scripts/              Hook scripts + assembly tooling
  skills/               5 auto-loaded skills
  steering/             4 scoped context files
```

---

## 🎨 Customize It

| What | Where |
|------|-------|
| Your goals | `brain/North Star.md` — grounds every session |
| Your org | `org/` — add your manager, team, key collaborators |
| Your competencies | `perf/competencies/` — match your org's framework |
| Your conventions | `AGENTS.md` — the tool-neutral rulebook, evolve it |
| Your domain | Add agents in `.kiro/agents/`, prompts in `.kiro/prompts/` |

> [!IMPORTANT]
> `AGENTS.md` is the canonical rulebook. When you change conventions, update it — Kiro reads it every session.

---

## 🚦 Status & Maturity

This is **v0.1.0 — early and experimental**. The vault content is template stubs (no real user data). Fill in `brain/North Star.md` and start using it to populate the vault.

### What's tested

| Feature | Status |
|---------|--------|
| Vault agent — hooks fire, reads/writes notes | ✅ Tested headless |
| Context-loader subagent — invoked from vault | ✅ Tested headless |
| Reviewer agent — loads, lists workflows | ✅ Tested headless |
| All 16 agent JSON configs — valid, load cleanly | ✅ `kiro-cli agent list` |
| Hook scripts — session-start, classify, validate | ✅ Fire correctly |
| Keyboard shortcuts — no conflicts | ✅ Verified |

### What's not tested end-to-end

| Feature | Blocker |
|---------|---------|
| `incident` mode, `slack-archaeologist`, `people-profiler` | Requires Slack MCP server (user-configured) |
| `vault-migrator` (upgrade workflow) | Needs a source vault to migrate from |
| `peer-scan` in reviewer mode | Requires `gh` CLI authenticated to a GitHub org |
| `wrapup`, `librarian`, `thinker` modes | Created and load, but workflows not exercised |
| `brag-spotter`, `cross-linker`, `vault-librarian` subagents | Created, not invoked in testing |
| 4 prompts (`dump`, `humanize`, `capture-1on1`, `project-archive`) | Created, not invoked in testing |
| Weekly synthesis (`wrapup` + "weekly") | Not exercised |

### Optional dependencies — graceful degradation

| Dependency | If missing |
|------------|-----------|
| **QMD** | Semantic search unavailable. Agents fall back to `grep`/`glob`. `session-start.sh` skips `qmd update` silently. |
| **Obsidian CLI** | Vault-aware commands unavailable. Agents fall back to filesystem reads. `session-start.sh` skips `obsidian tasks` silently. |
| **Slack MCP** | `incident` mode, `slack-archaeologist`, and `people-profiler` won't work. Other modes unaffected. |
| **GitHub CLI** | `peer-scan` workflow in reviewer mode won't work. Other review workflows unaffected. |

---

## 🙏 Credits

This project is a **Kiro CLI-native sibling** of [obsidian-mind](https://github.com/breferrari/obsidian-mind) by [@breferrari](https://github.com/breferrari). The vault structure, note conventions, performance graph, subagent designs, and hook scripts all originate from that project. kiro-mind redesigns the agent layer from scratch around Kiro's primitives while keeping the vault content and philosophy intact.

If you use Claude Code instead of Kiro CLI, use [obsidian-mind](https://github.com/breferrari/obsidian-mind) directly.

### Design Influences

- [obsidian-mind](https://github.com/breferrari/obsidian-mind) — The original project this is based on
- [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) — Official Obsidian agent skills
- [James Bedford](https://x.com/jameesy) — Vault structure philosophy
- [arscontexta](https://github.com/agenticnotetaking/arscontexta) — Progressive disclosure, session hooks

---

## 📄 License

MIT — same as [obsidian-mind](https://github.com/breferrari/obsidian-mind).
