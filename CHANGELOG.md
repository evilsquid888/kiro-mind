# Changelog

All notable changes to kiro-mind will be documented in this file.

Based on [obsidian-mind](https://github.com/breferrari/obsidian-mind) by [@breferrari](https://github.com/breferrari). Vault structure, note conventions, and hook scripts originate from that project.

## [0.1.0] — 2026-04-08

### Added

**Core**
- `AGENTS.md` — tool-neutral vault rulebook (250 lines)
- 4 steering files (`product.md`, `tech.md`, `structure.md`, `linking.md`)

**Mode Agents (7)**
- `vault` — default mode for day-to-day capture, linking, browsing
- `morning` — standup: read-only context load, priorities
- `wrapup` — session review and weekly synthesis
- `reviewer` — self-review, peer review, review briefs, PR scanning
- `incident` — incident capture from Slack channels/threads
- `librarian` — vault audit and content migration
- `thinker` — drafting and analysis in thinking/ scratchpad

**Subagents (9)**
- `brag-spotter`, `context-loader`, `cross-linker`, `people-profiler`, `review-prep`, `review-fact-checker`, `slack-archaeologist`, `vault-librarian`, `vault-migrator`

**Prompts (4)**
- `dump` — freeform capture, auto-routes to correct notes
- `humanize` — voice-calibrate a draft
- `capture-1on1` — structured 1:1 meeting capture
- `project-archive` — archive project from active/ to archive/

**Skills (5)**
- `obsidian-markdown`, `obsidian-cli`, `qmd-search`, `frontmatter-validate`, `wikilink-check`

**Hooks**
- `session-start.sh` — agentSpawn: inject North Star, git log, tasks, file listing
- `classify-message.py` — userPromptSubmit: content classification with routing hints
- `validate-write.py` — postToolUse: frontmatter/wikilink/folder validation
- `_hooks-common.json` + `build-agents.sh` — hook assembly system (prevents 7x duplication)
- `charcount.sh` — character count utility for review character limits

**Vault Content**
- All vault folders and templates from obsidian-mind (brain/, work/, perf/, org/, reference/, thinking/, templates/, bases/)
- `Home.md`, `vault-manifest.json`, templates, Obsidian Bases

### Verified

- Prompts are plain `.md` files — no frontmatter needed
- Hooks are per-agent only — no inheritance across `/agent swap`
- Subagents honor their own `allowedTools`, not the caller's
- Nested subagents not supported — orchestration in mode agents
- `agentSpawn` fires on every activation including `/agent swap`
