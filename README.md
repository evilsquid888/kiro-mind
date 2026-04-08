🌐 **English** | [日本語](README.ja.md) | [中文](README.zh-CN.md) | [한국어](README.ko.md)

# 🧠 Obsidian Mind

[![Claude Code](https://img.shields.io/badge/claude%20code-required-D97706)](https://docs.anthropic.com/en/docs/claude-code)
[![Obsidian](https://img.shields.io/badge/obsidian-1.12%2B-7C3AED)](https://obsidian.md)
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

<p align="center">
  <img src="obsidian-mind-demo.gif" alt="Obsidian Mind demo — standup and dump commands" width="800">
</p>

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

## 📋 Requirements

- [Obsidian](https://obsidian.md) 1.12+ (for CLI support)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
- Python 3 (for hook scripts)
- Git (for version history)
- [QMD](https://github.com/tobi/qmd) (optional, for semantic search)

---

## ⚙️ How It Works

**Folders group by purpose. Links group by meaning.** A note lives in one folder (its home) but links to many notes (its context). Claude maintains this graph — linking work notes to people, decisions, and competencies automatically. When review season arrives, the backlinks on each competency note are already the evidence trail. A note without links is a bug.

**Vault-first memory** keeps context across sessions and machines. All durable knowledge lives in `brain/` topic notes (git-tracked, Obsidian-browsable, linked). Claude Code's `MEMORY.md` (`~/.claude/`) is an auto-loaded index that points to vault locations — never the storage itself. This means memories survive machine changes and are part of the graph.

**Sessions have a designed lifecycle.** The `SessionStart` hook auto-injects your North Star goals, active projects, recent changes, open tasks, and the full vault file listing — Claude starts every session with context, not a blank slate. At the end, say "wrap up" and Claude runs `/wrap-up` — verifying notes, updating indexes, and spotting uncaptured wins. The 285-line `CLAUDE.md` governs everything in between: where to file things, how to link, when to split a note, what to do with decisions and incidents.

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

**Weekly**: Run `/weekly` for cross-session synthesis — North Star alignment, patterns, uncaptured wins, and next-week priorities. Run `/vault-audit` to catch orphan notes, broken links, and stale content.

**Review season**: Run `/review-brief manager` and get a structured review prep document with all the evidence already linked.

---

## 🛠️ Commands

Defined in `.claude/commands/`. Run them in any Claude Code session.

| Command | What It Does |
|---------|-------------|
| `/standup` | Morning kickoff — loads context, reviews yesterday, surfaces tasks, suggests priorities |
| `/dump` | Freeform capture — talk naturally about anything, Claude routes it all to the right notes |
| `/wrap-up` | Full session review — verify notes, indexes, links, suggest improvements |
| `/humanize` | Voice-calibrated editing — makes Claude-drafted text sound like you wrote it |
| `/weekly` | Weekly synthesis — cross-session patterns, North Star alignment, uncaptured wins |
| `/capture-1on1` | Capture a 1:1 meeting transcript into a structured vault note |
| `/incident-capture` | Capture an incident from Slack/channels into structured notes |
| `/slack-scan` | Deep scan Slack channels/DMs for evidence |
| `/peer-scan` | Deep scan a peer's GitHub PRs for review prep |
| `/review-brief` | Generate a review brief (manager or peer version) |
| `/self-review` | Write your self-assessment for review season — projects, competencies, principles |
| `/review-peer` | Write a peer review — projects, principles, performance summary |
| `/vault-audit` | Audit indexes, links, orphans, stale context |
| `/vault-upgrade` | Import content from an existing vault — version detection, classification, migration |
| `/project-archive` | Move a completed project from active/ to archive/, update indexes |

---

## 🤖 Subagents

Specialized agents that run in isolated context windows. They handle heavy operations without polluting your main conversation.

| Agent | Purpose | Invoked by |
|-------|---------|------------|
| `brag-spotter` | Finds uncaptured wins and competency gaps | `/wrap-up`, `/weekly` |
| `context-loader` | Loads all vault context about a person, project, or concept | Direct |
| `cross-linker` | Finds missing wikilinks, orphans, broken backlinks | `/vault-audit` |
| `people-profiler` | Bulk creates/updates person notes from Slack profiles | `/incident-capture` |
| `review-prep` | Aggregates all performance evidence for a review period | `/review-brief` |
| `slack-archaeologist` | Full Slack reconstruction — every message, thread, profile | `/incident-capture` |
| `vault-librarian` | Deep vault maintenance — orphans, broken links, stale notes | `/vault-audit` |
| `review-fact-checker` | Verify every claim in a review draft against vault sources | `/self-review`, `/review-peer` |
| `vault-migrator` | Classify, transform, and migrate content from a source vault | `/vault-upgrade` |

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

## 📁 Vault Structure

```
Home.md                 Vault entry point — embedded Base views, quick links
CLAUDE.md               Operating manual — Claude reads this every session
vault-manifest.json     Template metadata — version, structure, schemas
CHANGELOG.md            Version history
CONTRIBUTING.md         Template development checklist
README.md               Product documentation
LICENSE                 MIT license

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
  commands/             15 slash commands
  agents/               9 subagents
  scripts/              Hook scripts + charcount.sh utility
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

## 🔄 Upgrading

Already using an older version of obsidian-mind (or any Obsidian vault)? The `/vault-upgrade` command migrates your content into the latest template:

```bash
# 1. Clone the latest obsidian-mind
git clone https://github.com/breferrari/obsidian-mind.git ~/new-vault

# 2. Open it in Claude Code
cd ~/new-vault && claude

# 3. Run the upgrade pointing to your old vault
/vault-upgrade ~/my-old-vault
```

Claude will:
1. **Detect** your vault version (v1–v3.2, or identify it as a non-obsidian-mind vault)
2. **Inventory** every file — classify as user content, scaffold, infrastructure, or uncategorized
3. **Present a migration plan** — you see exactly what will be copied, transformed, and skipped
4. **Execute** after your approval — transforms frontmatter, fixes wikilinks, rebuilds indexes
5. **Validate** — checks for orphans, broken links, missing frontmatter

Your old vault is **never modified**. Use `--dry-run` to preview the plan without executing.

> [!NOTE]
> Works with any Obsidian vault, not just obsidian-mind. For non-obsidian-mind vaults, Claude reads each note and classifies it semantically — routing work notes, people, incidents, 1:1s, and decisions to the right folders.

---

## 🧪 Using with Kiro CLI (experimental)

A from-scratch **Kiro CLI**-native port lives on the [`kiro-mind-draft`](https://github.com/evilsquid888/obsidian-mind/tree/kiro-mind-draft) branch. Same vault content and philosophy, redesigned around Kiro's primitives. The `.kiro/` tree coexists alongside `.claude/` — both work in the same repo.

**Status**: Phase 1 complete (58 files, 3,730 lines). Headless-tested. Dogfooding in progress.

### Quick Start (Kiro)

```bash
git clone https://github.com/evilsquid888/obsidian-mind.git ~/vault
cd ~/vault && git checkout kiro-mind-draft
kiro-cli chat --agent vault          # starts in vault mode
```

### Architecture: Modes, Not Commands

Where Claude Code uses 15 slash commands, Kiro uses **7 mode agents** you swap between. Conversation context carries across swaps, so chaining is natural.

```bash
kiro-cli                              # starts in vault mode (default)
/agent swap morning                   # standup: load context, set priorities
/agent swap vault                     # back to day-to-day capture
/agent swap wrapup                    # end of session: verify, archive, brag-spot
```

| Mode | Shortcut | Purpose | Subagents |
|------|----------|---------|-----------|
| `vault` | `Ctrl+Shift+V` | Default — capture, link, browse | All 9 available |
| `morning` | `Ctrl+Shift+M` | Standup — read-only context load, priorities | context-loader |
| `wrapup` | `Ctrl+Shift+W` | Session review or weekly synthesis | brag-spotter, cross-linker, vault-librarian |
| `reviewer` | `Ctrl+Shift+R` | Self-review, peer review, review briefs, PR scanning | review-prep, review-fact-checker, brag-spotter |
| `incident` | `Ctrl+Shift+I` | Incident capture from Slack | slack-archaeologist, people-profiler |
| `librarian` | `Ctrl+Shift+L` | Vault audit and content migration | vault-librarian, cross-linker, vault-migrator |
| `thinker` | `Ctrl+Shift+T` | Drafting in thinking/ scratchpad | None (solo) |

### Lightweight Prompts

For quick actions that don't need a mode switch:

```bash
/prompts get dump Just had a 1:1 with Sarah...     # auto-routes to correct notes
/prompts get humanize work/active/Auth-Refactor.md  # voice-calibrate a draft
/prompts get capture-1on1 Sarah                     # structured 1:1 capture
/prompts get project-archive Auth-Refactor           # git mv + index updates
```

### 9 Subagents

Same subagents as Claude Code, invoked via Kiro's native `subagent` tool (isolated context, up to 4 in parallel). Each mode agent declares which subagents it can access via `availableAgents`/`trustedAgents` scoping.

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

### Hooks (per-agent)

Kiro hooks are per-agent (no global hooks). A shared `_hooks-common.json` template + `build-agents.sh` assembly script keeps 7 mode agents in sync without duplication drift.

| Hook | Trigger | Script | What |
|------|---------|--------|------|
| `agentSpawn` | Mode activates (including swap) | `session-start.sh` | Inject North Star, git log, tasks, file listing |
| `userPromptSubmit` | User sends message | `classify-message.py` | Classify content → routing hints (decision, incident, win, 1:1, person) |
| `postToolUse` | After writing `.md` | `validate-write.py` | Validate frontmatter, check wikilinks, verify folder |
| `stop` | Assistant finishes | inline | Session checklist reminder |

### AGENTS.md + Steering

`AGENTS.md` at the repo root is the **tool-neutral rulebook** — vault conventions that work with any agentic tool. Kiro-specific wiring lives in `.kiro/`:

| File | Purpose |
|------|---------|
| `AGENTS.md` | Canonical rules: folder structure, note types, frontmatter, linking, indexes, session workflow |
| `.kiro/steering/product.md` | What this vault is for, audience, non-goals |
| `.kiro/steering/tech.md` | Stack versions, model pinning, compatibility |
| `.kiro/steering/structure.md` | Folder layout, note types, naming conventions |
| `.kiro/steering/linking.md` | Graph-first rules, atomicity, when-to-link matrix |

### 5 Skills

Auto-loaded by description matching — you don't invoke them explicitly:

- `obsidian-markdown` — wikilinks, embeds, callouts, properties
- `obsidian-cli` — vault-aware CLI commands when Obsidian is running
- `qmd-search` — semantic search across the vault via QMD
- `frontmatter-validate` — YAML frontmatter schema checks
- `wikilink-check` — broken/missing link detection

### Claude Code ↔ Kiro Mapping

Every Claude Code command has a Kiro equivalent:

| Claude Code | Kiro CLI |
|-------------|----------|
| `/standup` | `/agent swap morning` |
| `/dump <text>` | `/prompts get dump <text>` |
| `/wrap-up` | `/agent swap wrapup` |
| `/weekly` | `/agent swap wrapup` + say "weekly" |
| `/humanize <file>` | `/prompts get humanize <file>` |
| `/capture-1on1 <person>` | `/prompts get capture-1on1 <person>` |
| `/incident-capture <urls>` | `/agent swap incident` + paste URLs |
| `/review-brief <audience>` | `/agent swap reviewer` + "review brief" |
| `/self-review` | `/agent swap reviewer` + "self-review" |
| `/review-peer <name>` | `/agent swap reviewer` + "peer review" |
| `/peer-scan <name> <user> <repo>` | `/agent swap reviewer` + "peer-scan" |
| `/vault-audit` | `/agent swap librarian` + "audit" |
| `/vault-upgrade <path>` | `/agent swap librarian` + "upgrade" |
| `/project-archive <name>` | `/prompts get project-archive <name>` |
| `/slack-scan <target>` | "Use slack-archaeologist to scan..." (any mode) |

### `.kiro/` File Tree

```
.kiro/
├── agents/                 7 mode agents + 9 subagents (JSON configs)
│   └── prompts/            16 prompt bodies (referenced via file://)
├── prompts/                4 lightweight prompts (dump, humanize, capture-1on1, project-archive)
├── scripts/                Hook scripts + assembly tooling
│   ├── session-start.sh    agentSpawn — inject vault context
│   ├── classify-message.py userPromptSubmit — content classification
│   ├── validate-write.py   postToolUse — frontmatter/link validation
│   ├── charcount.sh        Character count utility for review limits
│   ├── _hooks-common.json  Shared hook stanzas template
│   └── build-agents.sh     Assembles hooks into agent configs
├── skills/                 5 auto-loaded skills
│   ├── obsidian-markdown/  Obsidian-flavored markdown
│   ├── obsidian-cli/       Obsidian CLI commands
│   ├── qmd-search/         QMD semantic search
│   ├── frontmatter-validate/ Frontmatter schema checks
│   └── wikilink-check/     Broken link detection
└── steering/               4 scoped context files
    ├── product.md          Purpose, audience, non-goals
    ├── tech.md             Stack, model pinning, compatibility
    ├── structure.md        Folder layout, note types
    └── linking.md          Graph-first rules, link conventions
```

### Verified Behaviors

These were empirically tested against Kiro CLI (see [`thinking/kiro-verification-2026-04-08.md`](thinking/kiro-verification-2026-04-08.md)):

- Prompts are plain `.md` files — no frontmatter needed, support `${1}`–`${10}` positional args
- Hooks are per-agent only — no inheritance across `/agent swap`
- Subagents honor their own `allowedTools`, not the caller's — tool isolation works
- Nested subagents are not supported — orchestration must happen in the mode agent
- `agentSpawn` fires on every agent activation, including `/agent swap`

### Differences from Claude Code

| | Claude Code (`main`) | Kiro CLI (`kiro-mind-draft`) |
|---|---|---|
| Commands | 15 slash commands | 7 mode agents + 4 prompts |
| Subagents | 9 via Task tool | 9 via `subagent` tool (same shape) |
| Config | `.claude/commands/`, `.claude/agents/` | `.kiro/agents/`, `.kiro/prompts/` |
| Rulebook | `CLAUDE.md` (monolith) | `AGENTS.md` (tool-neutral) + 4 steering files |
| Hooks | Global in `settings.json` | Per-agent, shared scripts + assembly |
| Context backup | `PreCompact` transcript backup | Dropped (no Kiro equivalent) |

**Expect**: best-effort, no promises on parity. Claude Code remains the primary target on `main`.

---

## 🙏 Design Influences

- [kepano/obsidian-skills](https://github.com/kepano/obsidian-skills) — Official Obsidian agent skills
- [James Bedford](https://x.com/jameesy) — Vault structure philosophy, separation of AI-generated content
- [arscontexta](https://github.com/agenticnotetaking/arscontexta) — Progressive disclosure via description fields, session hooks

---

## 📄 License

MIT
