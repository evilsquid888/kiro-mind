# 🧠 Obsidian Mind

[![Obsidian](https://img.shields.io/badge/obsidian-1.12%2B-7C3AED)](https://obsidian.md)
[![Claude Code](https://img.shields.io/badge/claude%20code-compatible-D97706)](https://docs.anthropic.com/en/docs/claude-code)
[![Python](https://img.shields.io/badge/python-3.8%2B-3776AB)](https://python.org)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> **An Obsidian vault that makes Claude Code remember everything.** Start a session, talk about your day, and Claude handles the rest — notes, links, indexes, performance tracking. Every conversation builds on the last.

---

## 🔴 The Problem

Claude Code is powerful, but it forgets. Every session starts from zero — no context on your goals, your team, your patterns, your wins. You re-explain the same things. You lose decisions made three conversations ago. The knowledge never compounds.

## 🟢 The Solution

Give Claude a brain.

```
You: "start session"
Claude: *reads North Star, checks active projects, scans recent memories*
Claude: "You're working on Project Alpha, blocked on the BE contract.
         Last session you decided to split the coordinator. Your 1:1
         with your manager is tomorrow — review brief is ready."
```

---

## ⚡ See It In Action

**Morning kickoff:**

```bash
/standup
# → loads North Star, active projects, open tasks, recent git changes
# → "You have 2 active projects. The auth refactor is blocked on API contract.
#    Your 1:1 with Sarah is at 2pm — last time she flagged observability."
```

**Brain dump after a meeting:**

```bash
/dump Just had a 1:1 with Sarah. She's happy with the auth work but wants
us to add error monitoring before release. Also, Tom mentioned the cache
migration is deferred to Q2 — we decided to focus on the API contract first.
Decision: defer Redis migration. Win: Sarah praised the auth architecture.
```

```
→ Updated org/people/Sarah Chen.md with meeting context
→ Created work/1-1/Sarah 2026-03-26.md with key takeaways
→ Created Decision Record: "Defer Redis migration to Q2"
→ Added to perf/Brag Doc.md: "Auth architecture praised by manager"
→ Updated work/active/Auth Refactor.md with error monitoring task
```

**Incident response:**

```bash
/incident-capture https://slack.com/archives/C0INCIDENT/p123456
# → slack-archaeologist reads every message, thread, and profile
# → people-profiler creates notes for new people involved
# → Full timeline, root cause analysis, brag doc entry
```

**End of day:**

```
You: "wrap up"
# → verifies all notes have links
# → updates indexes
# → brag-spotter finds uncaptured wins
# → suggests improvements
```

---

## ⚙️ How It Works

The vault is organized around a **graph, not folders**. Folders group by purpose (where to browse), links group by meaning (how to discover). Every note links to related notes — people, decisions, competencies, projects — building a knowledge graph that compounds over time.

Claude maintains this graph. When you create a work note, it links to the people involved, the decisions it produced, and the competencies it demonstrates. When review season arrives, you read the backlinks on each competency note and the evidence is already there.

### The Operating Manual

`CLAUDE.md` defines how Claude navigates the vault: where to put things, how to link, what to do at the start and end of every session. It includes an atomicity rule ("does this cover multiple distinct concepts that could be separate nodes?"), a linking contract ("a note without links is a bug"), and a dual memory system separating Claude Code's session memory from the vault's linked knowledge.

### Hooks

Five lifecycle hooks handle routing automatically:

| Hook | When | What |
|------|------|------|
| 🚀 SessionStart | On startup/resume | QMD re-index, inject North Star, active work, recent changes, tasks, file listing |
| 💬 UserPromptSubmit | Every message | Classifies content (decision, incident, win, 1:1, architecture, person) and injects routing hints |
| ✍️ PostToolUse | After writing `.md` | Validates frontmatter, checks for wikilinks, verifies folder placement |
| 💾 PreCompact | Before context compaction | Backs up session transcript to `thinking/session-logs/` |
| 🏁 Stop | End of session | Checklist: archive completed projects, update indexes, check orphans |

> [!TIP]
> You just talk. The hooks handle the routing.

---

## 📅 Daily Workflow

**Morning**: Run `/standup`. Claude loads your North Star, active projects, open tasks, and recent changes. You get a structured summary and suggested priorities.

**Throughout the day**: Talk naturally. Mention a decision you made, an incident that happened, a 1:1 you just had, a win you want to remember. The classification hook nudges Claude to file each piece correctly. For bigger brain dumps, use `/dump` and narrate everything at once.

**End of day**: Say "wrap up" and Claude invokes `/wrap-up` — verifies notes, updates indexes, checks links, spots uncaptured wins.

**Weekly**: Run `/vault-audit` to catch orphan notes, broken links, and stale content.

**Review season**: Run `/review-brief H1 2026` and get a structured review prep document with all the evidence already linked.

---

## 🛠️ Commands

Defined in `.claude/commands/`. Run them in any Claude Code session.

| Command | What It Does |
|---------|-------------|
| `/standup` | Morning kickoff — loads context, reviews yesterday, surfaces tasks, suggests priorities |
| `/dump` | Freeform capture — talk naturally about anything, Claude routes it all to the right notes |
| `/wrap-up` | Full session review — verify notes, indexes, links, suggest improvements |
| `/capture-1on1` | Capture a 1:1 meeting transcript into a structured vault note |
| `/incident-capture` | Capture an incident from Slack/channels into structured notes |
| `/slack-scan` | Deep scan Slack channels/DMs for evidence |
| `/peer-scan` | Deep scan a peer's GitHub PRs for review prep |
| `/review-brief` | Generate a review brief (manager or peer version) |
| `/vault-audit` | Audit indexes, links, orphans, stale context |
| `/project-archive` | Move a completed project from active/ to archive/, update indexes |

---

## 🤖 Subagents

Specialized agents that run in isolated context windows. They handle heavy operations without polluting your main conversation.

| Agent | Purpose | Invoked by |
|-------|---------|------------|
| `brag-spotter` | Finds uncaptured wins and competency gaps | `/wrap-up` |
| `context-loader` | Loads all vault context about a person, project, or concept | Direct |
| `cross-linker` | Finds missing wikilinks, orphans, broken backlinks | `/vault-audit` |
| `people-profiler` | Bulk creates/updates person notes from Slack profiles | `/incident-capture` |
| `review-prep` | Aggregates all performance evidence for a review period | `/review-brief` |
| `slack-archaeologist` | Full Slack reconstruction — every message, thread, profile | `/incident-capture` |
| `vault-librarian` | Deep vault maintenance — orphans, broken links, stale notes | `/vault-audit` |

> [!NOTE]
> Subagents are defined in `.claude/agents/`. You can add your own for domain-specific workflows.

---

## 📊 Performance Graph

The vault doubles as a performance tracking system:

1. **Competency notes** in `perf/competencies/` define your org's competency framework — one note per competency
2. **Work notes** link to competencies in their `## Related` section, annotated with what was demonstrated
3. **Backlinks accumulate automatically** — review prep becomes reading the backlinks panel on each competency note
4. **Brag Doc** aggregates wins per quarter with links to evidence notes
5. **`/peer-scan`** deep-scans a colleague's GitHub PRs and writes structured evidence to `perf/evidence/`
6. **`/review-brief`** generates a full review brief by aggregating everything: brag entries, decisions, incidents, competency evidence, and 1:1 feedback

> [!TIP]
> To get started: create competency notes from the template, then link your work notes to them as you go. The graph does the rest.

---

## 📋 Bases

The `bases/` folder contains database views that query your notes' frontmatter properties. They update automatically as notes change.

| Base | Shows |
|------|-------|
| Work Dashboard | Active projects filtered by quarter, grouped by status |
| Incidents | All incidents sorted by severity and date |
| People Directory | Everyone in `org/people/` with role, team |
| 1:1 History | All 1:1 notes sortable by person and date |
| Review Evidence | PR scans and evidence grouped by person and cycle |
| Competency Map | Competencies with evidence counts from backlinks |
| Templates | Quick access to all templates |

`Home.md` embeds these views, making it the vault's dashboard.

---

## 🚀 Quick Start

1. Clone this repo (or use it as a **GitHub template**)
2. Open the folder as an **Obsidian vault**
3. Enable the **Obsidian CLI** in Settings → General (requires Obsidian 1.12+)
4. Run **`claude`** in the vault directory
5. Fill in **`brain/North Star.md`** with your goals — this grounds every session
6. Start talking about work

### Optional: QMD Semantic Search

For semantic search across the vault (find "what did we decide about caching" even if the note is titled "Redis Migration ADR"):

```bash
npm install -g @tobilu/qmd
qmd collection add . --name vault --mask "**/*.md"
qmd context add qmd://vault "Engineer's work vault: projects, decisions, incidents, people, reviews, architecture"
qmd update && qmd embed
```

> [!NOTE]
> If QMD isn't installed, everything still works — Claude falls back to the Obsidian CLI and grep.

---

## 📁 Vault Structure

```
Home.md                 Vault entry point — embedded Base views, quick links
bases/                  Dynamic database views (Work Dashboard, Incidents, People, etc.)

work/
  active/               Current projects (1–3 files at a time)
  archive/YYYY/         Completed work, organized by year
  incidents/            Incident docs (main note + RCA + deep dive)
  1-1/                  1:1 meeting notes — named <Person> YYYY-MM-DD.md
  Index.md              Map of Content for all work

org/
  people/               One note per person — role, team, relationship, key moments
  teams/                One note per team — members, scope, interactions
  People & Context.md   MOC for organizational knowledge

perf/
  Brag Doc.md           Running log of wins, linked to evidence
  brag/                 Quarterly brag notes (one per quarter)
  competencies/         One note per competency (link targets)
  evidence/             PR deep scans, data extracts for reviews
  <cycle>/              Review cycle briefs and artifacts

brain/
  North Star.md         Goals and focus areas — read every session
  Memories.md           Index of memory topics
  Key Decisions.md      Significant decisions and their reasoning
  Patterns.md           Recurring patterns observed across work
  Gotchas.md            Things that have gone wrong and why
  Skills.md             Custom workflows and slash commands

reference/              Codebase knowledge, architecture maps, flow docs
thinking/               Scratchpad for drafts — promote findings, then delete
templates/              Obsidian templates with YAML frontmatter

.claude/
  commands/             10 slash commands
  agents/               7 subagents
  scripts/              Hook scripts (session-start, classify, validate, backup)
  skills/               Obsidian + QMD skills
  settings.json         5 hooks configuration
```

---

## 📝 Templates

Templates with YAML frontmatter, each including a `description` field for progressive disclosure:

- **Work Note** — date, description, project, status, quarter, tags
- **Decision Record** — date, description, status (proposed/accepted/deprecated), owner, context
- **Thinking Note** — date, description, context, tags (scratchpad — delete after promoting)
- **Competency Note** — date, description, current-level, target-level, proficiency table
- **1:1 Note** — date, person, key takeaways, action items, quotes
- **Incident Note** — date, ticket, severity, role, timeline, root cause, impact

---

## 🔧 What's Included

### Obsidian Skills

[kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) pre-installed in `.claude/skills/`:

- **obsidian-markdown** — Obsidian-flavored markdown (wikilinks, embeds, callouts, properties)
- **obsidian-cli** — CLI commands for vault operations
- **obsidian-bases** — Database-style `.base` files
- **json-canvas** — Visual `.canvas` file creation
- **defuddle** — Web page to markdown extraction

### QMD Skill

A custom skill in `.claude/skills/qmd/` that teaches Claude to use [QMD](https://github.com/tobi/qmd) semantic search proactively — before reading files, before creating notes (to check for duplicates), and after creating notes (to find related content that should link to it).

---

## 🎨 Customize It

This is a starting point. Adapt it to how you work:

| What | Where |
|------|-------|
| Your goals | `brain/North Star.md` — grounds every session |
| Your org | `org/` — add your manager, team, key collaborators |
| Your competencies | `perf/competencies/` — match your org's framework |
| Your tools | `.claude/commands/` — edit for your GitHub org, Slack workspace |
| Your conventions | `CLAUDE.md` — the operating manual, evolve it as you go |
| Your domain | Add folders, subagents in `.claude/agents/`, or classification rules in `.claude/scripts/` |

> [!IMPORTANT]
> `CLAUDE.md` is the operating manual. When you change conventions, update it — Claude reads it every session.

---

## 📋 Requirements

- [Obsidian](https://obsidian.md) 1.12+ (for CLI support)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Python 3 (for hook scripts)
- Git (for version history)
- [QMD](https://github.com/tobi/qmd) (optional, for semantic search)

---

## 🙏 Design Influences

- [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) — Official Obsidian agent skills
- [James Bedford](https://x.com/jameesy) — Vault structure philosophy, separation of AI-generated content
- [arscontexta](https://github.com/agenticnotetaking/arscontexta) — Progressive disclosure via description fields, session hooks

---

## 📄 License

MIT
