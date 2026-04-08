# kiro-mind Refined Spec v2

> Refined 2026-04-08. Supersedes `2026-04-08-kiro-mind-spec.md`.
> Source material: all 15 Claude Code commands, 9 subagents, CLAUDE.md, Kiro CLI docs.

## Goal

Create `kiro-mind` as a branch (`kiro-mind-draft`) in the obsidian-mind repo, then promote to a standalone repo post-v0.1. Delivers the same outcomes (Obsidian vault pre-wired for capture, linking, performance tracking, and review prep) using Kiro CLI primitives — mode agents, subagents, prompts, skills, steering, AGENTS.md.

## Key Decisions (updated)

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **Branch first, repo later** | `.kiro/` is additive alongside `.claude/`. Vault content (`brain/`, `work/`, etc.) is shared — no copy. Promote to standalone repo after v0.1 dogfood. |
| 2 | **Mode agents over slash commands** | `/agent swap` preserves context (verified). Modes are lenses, not one-shots. |
| 3 | **Real subagents via `subagent` tool** | Kiro's `use_subagent` has Claude Task-tool parity: isolated context, up to 4 parallel, `availableAgents`/`trustedAgents` scoping. |
| 4 | **4 prompts, not 3** | `dump`, `humanize`, `capture-1on1`, `project-archive`. Archive is too lightweight for a mode. |
| 5 | **Hook names are camelCase** | Kiro uses `agentSpawn`, `userPromptSubmit`, `preToolUse`, `postToolUse`, `stop`. The spec had PascalCase — corrected. |
| 6 | **`weekly` is a wrapup variant, not a separate mode** | The wrapup prompt accepts a `--scope` argument (`session` or `week`). One mode, two behaviors. |
| 7 | **`PreCompact` dropped** | No Kiro equivalent. Non-critical. |
| 8 | **Hand-authored AGENTS.md** | Low change rate. Generation adds build step and drift risk. |
| 9 | **Hook duplication mitigated by shared JSON fragment** | A `_hooks-common.json` template + a tiny assembly script prevents 7x drift. |
| 10 | **Integration test kept** | Uses `kiro-cli chat --no-interactive --trust-all-tools` for headless validation. |

## Constraints

- **Kiro primitives only** — no emulating Claude Code patterns that don't fit
- **Hooks are per-agent** — no global hooks; shared scripts in `.kiro/scripts/`, JSON stanzas assembled from `_hooks-common.json`
- **Tool names** — Kiro uses `fs_read`/`read`, `fs_write`/`write`, `execute_bash`/`shell`, `glob`, `grep`, `use_subagent`/`subagent`, `use_aws`/`aws`, `thinking`, `todo_list`/`todo`. Hook matchers accept aliases.
- **Max 4 parallel subagents**
- **Context preserved on `/agent swap`** — modes can be chained freely
- **Vault content is tool-agnostic** — must not diverge between obsidian-mind and kiro-mind at v0.1

## Open Questions (5 — ALL ANSWERED)

> Full results: [`thinking/kiro-verification-2026-04-08.md`](thinking/kiro-verification-2026-04-08.md)

| # | Question | Answer | Method |
|---|----------|--------|--------|
| 1 | Prompt file format | Plain `.md`, no frontmatter, `${1}`–`${10}` args | Docs + manual test |
| 2 | Hook inheritance across agents | **NO** — per-agent only, no inheritance | Docs (5 evidence points) |
| 3 | Subagent honors own allowedTools | **YES** — caller's tools don't leak | Empirical (headless) |
| 4 | Nested subagents | **NO** — `use_subagent` stripped from subagents | Empirical (headless) |
| 5 | agentSpawn fires on swap | **YES** — fires on every activation | Docs + partial empirical |

**Design implications**:
- Q2: Every mode agent must declare its own hooks. Mitigated by `_hooks-common.json` assembly.
- Q3: Subagents can safely be given narrow tools — the caller's broader tools don't leak.
- Q4: Orchestration is top-level only. Mode agents must invoke subagents directly; subagents cannot chain to each other.
- Q5: `session-start.sh` fires on every mode swap — each mode gets fresh context. No first-message guard needed.

## Command-to-Kiro Mapping (all 15)

| Claude Code Command | Kiro Equivalent | Type | Notes |
|---|---|---|---|
| `/standup` | `/agent swap morning` | mode agent | Reads North Star, git log, tasks; proposes priorities |
| `/dump` | `/prompts get dump $ARGUMENTS` | prompt | Freeform capture, auto-routes. Runs inside current mode. |
| `/wrap-up` | `/agent swap wrapup` | mode agent | Session scope by default. Also triggered by "wrap up" in conversation. |
| `/weekly` | `/agent swap wrapup` + "weekly" | mode agent | Same mode, prompt detects weekly intent and widens scope to 7 days. |
| `/humanize` | `/prompts get humanize ${1}` | prompt | Voice calibration. Takes file path as `${1}`. |
| `/capture-1on1` | `/prompts get capture-1on1 ${1}` | prompt | Takes participant name as `${1}`. User pastes transcript. |
| `/incident-capture` | `/agent swap incident` | mode agent | Orchestrates `slack-archaeologist` + `people-profiler` in parallel. |
| `/slack-scan` | Natural language in any mode | subagent invocation | "Use the slack-archaeologist subagent to scan #channel". Works in `vault` mode (all subagents available) or `incident` mode. |
| `/peer-scan` | `/agent swap reviewer` + "peer-scan" | mode behavior | Reviewer mode handles PR scanning as part of review prep. |
| `/review-brief` | `/agent swap reviewer` + "review brief" | mode behavior | Reviewer invokes `review-prep` subagent, then writes brief. |
| `/self-review` | `/agent swap reviewer` + "self-review" | mode behavior | Reviewer drafts, then invokes `review-fact-checker` for verification. |
| `/review-peer` | `/agent swap reviewer` + "peer review" | mode behavior | Reviewer drafts peer review, invokes `review-fact-checker`. |
| `/vault-audit` | `/agent swap librarian` + "audit" | mode behavior | Librarian invokes `vault-librarian` then `cross-linker` subagents. |
| `/vault-upgrade` | `/agent swap librarian` + "upgrade" | mode behavior | Librarian invokes `vault-migrator` subagent. |
| `/project-archive` | `/prompts get project-archive ${1}` | prompt | Takes project name as `${1}`. Lightweight: git mv + index updates. |

## Mode Agent Deep Dives

### 1. `vault` (default mode)

**Purpose**: Day-to-day capture, linking, vault browsing. The home base.

**Prompt scope**: You are the vault agent for an obsidian-mind vault. Follow AGENTS.md for all conventions. Capture notes, maintain links, update indexes. When the user says "wrap up" or similar, suggest swapping to wrapup mode. When the user describes an incident, suggest swapping to incident mode. For review work, suggest reviewer mode.

**Hooks**:
| Hook | Script | What |
|---|---|---|
| `agentSpawn` | `session-start.sh` | Inject North Star, git log (24h), open tasks, file listing |
| `userPromptSubmit` | `classify-message.py` | Classify content → routing hints (decision/incident/win/1:1/person) |
| `postToolUse` (matcher: `write`) | `validate-write.py` | Validate frontmatter, check wikilinks, verify folder placement |
| `stop` | inline echo | "Session checklist: archive? indexes? links?" |

**Subagent wiring** (`toolsSettings.subagent`):
```json
{
  "availableAgents": ["brag-spotter", "context-loader", "cross-linker", "people-profiler",
                      "review-prep", "review-fact-checker", "slack-archaeologist",
                      "vault-librarian", "vault-migrator"],
  "trustedAgents": ["context-loader"]
}
```

**Tools**: `fs_read`, `fs_write`, `execute_bash`, `glob`, `grep`, `use_subagent`, `thinking`, `todo_list`, `web_search`, `web_fetch`
**allowedTools**: `fs_read`, `glob`, `grep`, `thinking`, `todo_list`

**Resources**:
- `file://AGENTS.md`
- `file://.kiro/steering/**/*.md`
- `skill://.kiro/skills/**/SKILL.md`

**keyboardShortcut**: `ctrl+shift+v`
**welcomeMessage**: "Vault mode — capture, link, browse. Say 'wrap up' when done."

**Entry**: Default on `kiro-cli` startup. Also via `/agent swap vault` from any mode.
**Exit**: User swaps to another mode or says "wrap up" (→ suggest wrapup).

---

### 2. `morning` (standup)

**Purpose**: Morning kickoff. Load context, review yesterday, surface tasks, propose priorities.

**Prompt scope**: You are the morning standup agent. Read North Star, active projects, yesterday's git log, open tasks, and recent 1:1 notes. Present a structured summary: Yesterday, Active Work, Open Tasks, North Star Alignment, Suggested Focus. Keep it concise — this is orientation, not a deep dive. After presenting, suggest swapping back to vault mode.

**Hooks**:
| Hook | Script | What |
|---|---|---|
| `agentSpawn` | `session-start.sh` | Same context injection as vault |
| `stop` | inline echo | "Standup complete. `/agent swap vault` to start working." |

No `userPromptSubmit` or `postToolUse` hooks — morning mode is read-only analysis.

**Subagent wiring**:
```json
{
  "availableAgents": ["context-loader"],
  "trustedAgents": ["context-loader"]
}
```

**Tools**: `fs_read`, `execute_bash`, `glob`, `grep`, `thinking`
**allowedTools**: `fs_read`, `glob`, `grep`, `thinking` (all read-only — no writes in standup)

**Resources**: Same as vault.

**keyboardShortcut**: `ctrl+shift+m`
**welcomeMessage**: "Morning standup — loading your context..."

**Entry**: `/agent swap morning` or keyboard shortcut.
**Exit**: After presenting summary, suggest vault swap. User can ask follow-up questions first.

---

### 3. `wrapup` (session end + weekly)

**Purpose**: End-of-session review OR weekly synthesis. Detects scope from conversation context or explicit "weekly" keyword.

**Prompt scope**: You are the wrapup agent. Two modes of operation:

**Session scope** (default): Scan conversation for notes created/modified. Verify note quality (frontmatter, wikilinks, folder placement). Check index consistency. Check for orphans. Archive completed projects. Review ways of working. Invoke `brag-spotter` to find uncaptured wins. Present: Done, Fixed, Flagged, Suggested.

**Weekly scope** (when user says "weekly" or "weekly synthesis"): Gather 7 days of git activity. Read North Star and compare against actual work. Find cross-day patterns. Invoke `brag-spotter` with weekly scope. Map competency signals. Suggest next-week priorities. Present: This Week, North Star Check, Patterns, Uncaptured Wins, Competency Coverage, Next Week. This is transient analysis — don't create a file unless asked.

Note: Scope detection is prompt-level (no `userPromptSubmit` hook on wrapup). The prompt body instructs the agent to check the user's first message for "weekly", "weekly synthesis", "week", or "cross-session" keywords. Default is session scope.

**Hooks**:
| Hook | Script | What |
|---|---|---|
| `agentSpawn` | `session-start.sh` | Context injection |
| `postToolUse` (matcher: `write`) | `validate-write.py` | Validate any fixes made during wrapup |
| `stop` | inline echo | "Wrapup complete. Good session." |

**Subagent wiring**:
```json
{
  "availableAgents": ["brag-spotter", "cross-linker", "vault-librarian"],
  "trustedAgents": ["brag-spotter"]
}
```

**Tools**: `fs_read`, `fs_write`, `execute_bash`, `glob`, `grep`, `use_subagent`, `thinking`, `todo_list`
**allowedTools**: `fs_read`, `glob`, `grep`, `thinking`, `todo_list`

**keyboardShortcut**: `ctrl+shift+w`
**welcomeMessage**: "Wrapup mode — reviewing session. Say 'weekly' for cross-session synthesis."

**Entry**: `/agent swap wrapup`, keyboard shortcut, or when user says "wrap up" (vault mode suggests the swap).
**Exit**: After presenting report. Suggest vault swap or quit.

---

### 4. `reviewer` (performance reviews)

**Purpose**: All review-related work: self-review, peer review, review briefs, PR scanning.

**Prompt scope**: You are the review agent for performance review season. You handle four workflows:

1. **Review brief** (`review brief <audience> [period]`): Invoke `review-prep` subagent to aggregate evidence. Write brief for manager (non-technical, outcome language) or peers (project-focused, casual). Create markdown + HTML + PDF versions.

2. **Self-review** (`self-review [cycle]`): Load review context. Draft project impacts, competency self-assessments, principles. Respect character limits (use charcount.sh). Invoke `review-fact-checker` for verification pass. Save to `thinking/review-drafts.md`.

3. **Peer review** (`peer review <Name>`): Load person note + PR evidence. Assess visibility level per project. Draft within character limits. Invoke `review-fact-checker`. Save to `thinking/<name>-peer-review.md`.

4. **Peer scan** (`peer-scan <name> <github-username> <repo> [period]`): Deep scan GitHub PRs via `gh` CLI. Produce structured analysis. Save to `perf/evidence/`.

Detect which workflow from the user's first message. Ask for clarification if ambiguous.

**Hooks**:
| Hook | Script | What |
|---|---|---|
| `agentSpawn` | `session-start.sh` | Context injection |
| `postToolUse` (matcher: `write`) | `validate-write.py` | Validate review artifacts |

No `userPromptSubmit` classifier — reviewer mode is already scoped.

**Subagent wiring**:
```json
{
  "availableAgents": ["review-prep", "review-fact-checker", "context-loader", "brag-spotter"],
  "trustedAgents": ["review-prep", "review-fact-checker"]
}
```

**Tools**: `fs_read`, `fs_write`, `execute_bash`, `glob`, `grep`, `use_subagent`, `thinking`, `todo_list`
**allowedTools**: `fs_read`, `glob`, `grep`, `thinking`, `todo_list`

**keyboardShortcut**: `ctrl+shift+r`
**welcomeMessage**: "Review mode — self-review, peer review, review brief, or peer-scan?"

**Entry**: `/agent swap reviewer`
**Exit**: After completing review workflow. Suggest vault swap.

---

### 5. `incident` (incident capture)

**Purpose**: Structured incident capture from Slack channels, DMs, and threads.

**Prompt scope**: You are the incident capture agent. Given Slack URLs, orchestrate a full incident reconstruction:

1. Launch `slack-archaeologist` and `people-profiler` subagents **in parallel**.
2. `slack-archaeologist` reads every message, thread, and profile → produces timeline in `thinking/`.
3. `people-profiler` creates/updates person notes for everyone involved.
4. Using their output, create the incident work note in `work/incidents/` with full frontmatter (date, quarter, description, ticket, severity, role, status, tags).
5. Sections: Context, Root Cause, Resolution, Timeline, Impact, Involved Personnel, Analysis, Related.
6. Update indexes: `work/Index.md`, `brain/Memories.md`, `brain/Patterns.md`, `brain/Gotchas.md`, `perf/Brag Doc.md`.
7. Offer next steps: post-mortem draft, incident ticket fields, channel message draft.

**Hooks**:
| Hook | Script | What |
|---|---|---|
| `agentSpawn` | `session-start.sh` | Context injection |
| `postToolUse` (matcher: `write`) | `validate-write.py` | Validate incident notes |

**Subagent wiring**:
```json
{
  "availableAgents": ["slack-archaeologist", "people-profiler", "context-loader"],
  "trustedAgents": ["slack-archaeologist", "people-profiler"]
}
```

**Tools**: `fs_read`, `fs_write`, `execute_bash`, `glob`, `grep`, `use_subagent`, `thinking`, `todo_list`
**allowedTools**: `fs_read`, `glob`, `grep`, `thinking`, `todo_list`

**MCP**: Requires Slack MCP server configured by user.

**keyboardShortcut**: `ctrl+shift+i`
**welcomeMessage**: "Incident mode — paste Slack URLs to begin capture."

**Entry**: `/agent swap incident`
**Exit**: After capture complete. Suggest vault-audit or vault swap.

---

### 6. `librarian` (vault maintenance + migration)

**Purpose**: Deep vault maintenance (audit) and content migration (upgrade). Two workflows in one mode.

**Prompt scope**: You are the vault librarian. Two workflows:

1. **Audit** (default): Invoke `vault-librarian` subagent for structural audit (orphans, broken links, frontmatter, stale notes, index consistency). Then invoke `cross-linker` for link quality. Present findings grouped by severity: fix now / fix later / informational. Fix small issues directly, flag larger changes for user approval.

2. **Upgrade** (`upgrade <path-to-source-vault>`): Detect source vault version. Inventory and classify files. Present migration plan. On approval, invoke `vault-migrator` subagent for execution. Validate results.

Detect workflow from user's first message.

**Hooks**:
| Hook | Script | What |
|---|---|---|
| `agentSpawn` | `session-start.sh` | Context injection |
| `postToolUse` (matcher: `write`) | `validate-write.py` | Validate any fixes |

**Subagent wiring**:
```json
{
  "availableAgents": ["vault-librarian", "cross-linker", "vault-migrator", "context-loader"],
  "trustedAgents": ["vault-librarian", "cross-linker"]
}
```

**Tools**: `fs_read`, `fs_write`, `execute_bash`, `glob`, `grep`, `use_subagent`, `thinking`, `todo_list`
**allowedTools**: `fs_read`, `glob`, `grep`, `thinking`, `todo_list`

**keyboardShortcut**: `ctrl+shift+l`
**welcomeMessage**: "Librarian mode — audit or upgrade?"

**Entry**: `/agent swap librarian`
**Exit**: After audit report or migration complete. Suggest vault swap.

---

### 7. `thinker` (drafting + analysis)

**Purpose**: Drafting, reasoning, and analysis in `thinking/` scratchpad. No subagents — this is focused solo work.

**Prompt scope**: You are the thinker agent. Help the user draft, analyze, and reason through problems. Write to `thinking/` as scratchpad. Key rules:
- Create thinking notes as `thinking/YYYY-MM-DD-descriptive-name.md` using the Thinking Note template.
- Thinking notes are temporary — once reasoning produces durable knowledge, promote findings to atomic notes in the correct folder.
- After promoting, delete the thinking note.
- If the thinking process itself is worth preserving (unusual), keep it but link to promoted notes.
- Apply the atomicity rule: one concept per note. Split anything with 3+ independent sections.

**Hooks**:
| Hook | Script | What |
|---|---|---|
| `agentSpawn` | `session-start.sh` | Context injection |
| `postToolUse` (matcher: `write`) | `validate-write.py` | Validate promoted notes (not thinking scratchpads) |

**Subagent wiring**: None. Thinker is solo.
```json
{
  "availableAgents": [],
  "trustedAgents": []
}
```

**Tools**: `fs_read`, `fs_write`, `execute_bash`, `glob`, `grep`, `thinking`, `todo_list`, `web_search`, `web_fetch`
**allowedTools**: `fs_read`, `fs_write`, `glob`, `grep`, `thinking`, `todo_list` (write is allowed — thinker creates drafts freely)

**keyboardShortcut**: `ctrl+shift+t`
**welcomeMessage**: "Thinker mode — drafting in thinking/. Promote findings when ready."

**Entry**: `/agent swap thinker`
**Exit**: After promoting findings. Suggest vault swap.

## Prompts (4 lightweight templates)

| Prompt | File | Arguments | What it does |
|---|---|---|---|
| `dump` | `.kiro/prompts/dump.md` | `$ARGUMENTS` (freeform text) | Classify and route freeform content to correct notes. Runs in current mode. |
| `humanize` | `.kiro/prompts/humanize.md` | `${1}` (file path or note name) | Voice-calibrate a draft. Loads voice samples, edits in-place, preserves frontmatter/wikilinks. |
| `capture-1on1` | `.kiro/prompts/capture-1on1.md` | `${1}` (participant name) | Create structured 1:1 note. User pastes transcript after invocation. |
| `project-archive` | `.kiro/prompts/project-archive.md` | `${1}` (project name) | `git mv` from active/ to archive/YYYY/, update frontmatter + indexes. |

Usage: `/prompts get <name> <args>` or `@<name><Tab>` for autocomplete.

**Note**: `dump`, `capture-1on1`, and `project-archive` require a mode with `fs_write` in its tools (vault, wrapup, reviewer, incident, librarian, thinker). They will fail in `morning` mode which is read-only.

## Subagents (9 — ported 1:1)

All live in `.kiro/agents/` (Kiro doesn't have a separate `subagents/` directory — they're just agents invoked via the `subagent` tool, scoped by `availableAgents` per mode).

| Subagent | Tools | Primary modes | Also available in |
|---|---|---|---|
| `brag-spotter` | `fs_read`, `grep`, `glob`, `execute_bash` | wrapup | vault, reviewer |
| `context-loader` | `fs_read`, `grep`, `glob`, `execute_bash` | morning, reviewer, incident, librarian | vault |
| `cross-linker` | `fs_read`, `fs_write`, `grep`, `glob`, `execute_bash` | wrapup, librarian | vault |
| `people-profiler` | `fs_read`, `fs_write`, `grep`, `glob`, `execute_bash` | incident | vault |
| `review-prep` | `fs_read`, `fs_write`, `grep`, `glob`, `execute_bash` | reviewer | vault |
| `review-fact-checker` | `fs_read`, `grep`, `glob`, `execute_bash` | reviewer | vault |
| `slack-archaeologist` | `fs_read`, `fs_write`, `grep`, `glob`, `execute_bash` | incident | vault |
| `vault-librarian` | `fs_read`, `grep`, `glob`, `execute_bash` | librarian | vault |
| `vault-migrator` | `fs_read`, `fs_write`, `grep`, `glob`, `execute_bash` | librarian | vault |

`vault` mode has all 9 subagents available as a catch-all. "Primary modes" are where the subagent is designed to be invoked.

**Port order** (easiest → hardest): context-loader, cross-linker, brag-spotter, vault-librarian, people-profiler, review-fact-checker, review-prep, slack-archaeologist, vault-migrator.

**Note**: Subagents that need Slack MCP tools (`slack-archaeologist`, `people-profiler`) will reference `@slack/*` in their tools list. MCP server config is the user's responsibility.

## Skills (5)

All in `.kiro/skills/<name>/SKILL.md` with YAML frontmatter (`name`, `description`).

| Skill | Description trigger |
|---|---|
| `obsidian-markdown` | "When creating or editing .md files in an Obsidian vault" |
| `obsidian-cli` | "When running Obsidian CLI commands for vault operations" |
| `qmd-search` | "When searching the vault semantically via QMD" |
| `frontmatter-validate` | "When validating YAML frontmatter on vault notes" |
| `wikilink-check` | "When checking for broken or missing wikilinks" |

## Hook Scripts (3 shared scripts)

All in `.kiro/scripts/`. Shared across mode agents — only the JSON stanzas in each agent config differ.

| Script | Language | Stdin | Stdout |
|---|---|---|---|
| `session-start.sh` | bash | `{"hook_event_name":"agentSpawn","cwd":"..."}` | North Star content, git log, open tasks, file listing |
| `classify-message.py` | python3 | `{"hook_event_name":"userPromptSubmit","cwd":"...","prompt":"..."}` | Routing hints: `[DECISION]`, `[INCIDENT]`, `[WIN]`, `[1ON1]`, `[PERSON]`, `[ARCHITECTURE]` |
| `validate-write.py` | python3 | `{"hook_event_name":"postToolUse","cwd":"...","tool_name":"fs_write","tool_input":{...},"tool_response":{...}}` | Validation warnings for missing frontmatter, no wikilinks, wrong folder. Skips files in `thinking/` (scratchpads don't need full validation). |

**Hook assembly**: A `_hooks-common.json` fragment defines the standard hook stanzas. A `build-agents.sh` script merges this into each agent's JSON config. This prevents 7x duplication drift while keeping each agent file self-contained for Kiro to read.

## Steering Files (4)

| File | Content |
|---|---|
| `.kiro/steering/product.md` | What this vault is for: purpose, audience, non-goals |
| `.kiro/steering/tech.md` | Stack: Obsidian 1.12+, Kiro CLI, Python 3, QMD, model pinning |
| `.kiro/steering/structure.md` | Folder layout, note type table, file naming conventions |
| `.kiro/steering/linking.md` | Graph-first rules, atomicity rule, link syntax, when-to-link matrix |

## File Tree (`.kiro/` only — vault content is shared with `main`)

```
.kiro/
├── agents/
│   ├── vault.json              # default mode
│   ├── morning.json
│   ├── wrapup.json
│   ├── reviewer.json
│   ├── incident.json
│   ├── librarian.json
│   ├── thinker.json
│   ├── brag-spotter.json       # subagent
│   ├── context-loader.json     # subagent
│   ├── cross-linker.json       # subagent
│   ├── people-profiler.json    # subagent
│   ├── review-prep.json        # subagent
│   ├── review-fact-checker.json # subagent
│   ├── slack-archaeologist.json # subagent
│   ├── vault-librarian.json    # subagent
│   ├── vault-migrator.json     # subagent
│   └── prompts/                # prompt bodies referenced via file://
│       ├── vault.md
│       ├── morning.md
│       ├── wrapup.md
│       ├── reviewer.md
│       ├── incident.md
│       ├── librarian.md
│       ├── thinker.md
│       ├── brag-spotter.md
│       ├── context-loader.md
│       ├── cross-linker.md
│       ├── people-profiler.md
│       ├── review-prep.md
│       ├── review-fact-checker.md
│       ├── slack-archaeologist.md
│       ├── vault-librarian.md
│       └── vault-migrator.md
├── prompts/
│   ├── dump.md
│   ├── humanize.md
│   ├── capture-1on1.md
│   └── project-archive.md
├── scripts/
│   ├── session-start.sh
│   ├── classify-message.py
│   ├── validate-write.py
│   ├── charcount.sh            # character count utility for review char limits
│   ├── _hooks-common.json      # shared hook stanzas template
│   └── build-agents.sh         # assembles hooks into agent JSONs
├── skills/
│   ├── obsidian-markdown/SKILL.md
│   ├── obsidian-cli/SKILL.md
│   ├── qmd-search/SKILL.md
│   ├── frontmatter-validate/SKILL.md
│   └── wikilink-check/SKILL.md
└── steering/
    ├── product.md
    ├── tech.md
    ├── structure.md
    └── linking.md
```

## Phases (refined)

### Phase 1 — Baseline (1 day)
- Create `.kiro/` tree on `kiro-mind-draft` branch
- Write `AGENTS.md` (tool-neutral rewrite of `CLAUDE.md`)
- Write 4 steering files
- Port 5 skills to `.kiro/skills/`
- Write README
- **Exit gate**: `kiro-cli` starts, loads AGENTS.md + steering, can read/write notes

### Phase 2 — vault agent + hooks (1 day)
- Build `vault.json` + prompt body
- Port 3 hook scripts, adapt to Kiro's stdin JSON format
- Wire hooks in vault.json
- Run interactive Q2/Q5 verification tests (scripts in `thinking/kiro-verification-2026-04-08.md`) for full empirical proof
- **Exit gate**: session-start injects context, classify fires, validate-write fires, Q2/Q5 interactively confirmed

### Phase 3 — Subagents (2 days)
- Port 9 subagents in order (context-loader → vault-migrator)
- Each gets JSON config + prompt body in `.kiro/agents/prompts/`
- Test each from vault mode
- **Exit gate**: each subagent invokable, returns structured output, doesn't bleed context

### Phase 4 — Mode agents (2 days)
- Build 6 remaining modes (morning, wrapup, reviewer, incident, librarian, thinker)
- Each gets JSON config + prompt body + hook stanzas (from `_hooks-common.json`)
- Wire subagent scoping per mode
- **Exit gate**: every Claude Code command has a mode or prompt equivalent

### Phase 5 — Prompts (0.5 day)
- Create 4 prompts via `/prompts create` or manual `.md` files
- Verify they're repo-trackable and work via `/prompts get`
- **Exit gate**: all 4 prompts work end-to-end

### Phase 5.5 — Integration test (0.5 day)
- `test/integration/test-vault/` — minimal `.kiro/` tree + stub vault content
- `test/integration/run.sh` — headless test via `kiro-cli chat --no-interactive --trust-all-tools`:
  1. Assert `agentSpawn` hook fired (check log marker)
  2. Submit test prompt; assert `userPromptSubmit` hook fired
  3. Write a test note; assert `postToolUse` hook fired
  4. Run a second headless session with `--agent wrapup`; assert its `agentSpawn` fires independently
  5. Invoke context-loader subagent; assert structured output
  6. Exit cleanly
- Note: `/agent swap` is not available in `--no-interactive` mode. Each agent is tested in a separate headless invocation.
- CI via GitHub Actions if Kiro CLI installable headless; otherwise manual pre-release checklist
- **Exit gate**: test passes on clean machine

### Phase 6 — Dogfood + release (~1 week part-time)
- Use kiro-mind exclusively for 5 working days
- Log friction in `thinking/kiro-dogfood-<date>.md`
- Fix top 5 issues
- Write `docs/migration-from-obsidian-mind.md`
- Tag `v0.1.0`
- **Exit gate**: 5 days dogfooded, migration guide written, tagged

**MVP cut**: Phases 1 + 2 + vault + context-loader subagent + morning mode. Proves concept end-to-end. ~2.5 days.

## Risks (updated)

| Risk | L | I | Mitigation |
|---|---|---|---|
| Hooks don't inherit across agent swaps → 7x duplication | M | L | `_hooks-common.json` + `build-agents.sh` assembly script. **Confirmed (Q2).** |
| `subagent` tool semantics differ from Claude Task tool | M | M | Verified Q3+Q4 — tools scoping works, nesting doesn't. Orchestrate in mode agents. |
| ~~`agentSpawn` fires only on CLI start, not swap~~ | ~~M~~ | ~~M~~ | **Retired (Q5)**: fires on every activation including swap. |
| `.kiro/prompts/` format surprises | L | L | **Retired (Q1)**: plain `.md`, no frontmatter. |
| Scope creep: tempted to refactor vault content | H | M | Hard rule: Phase 1 is copy-only. Content changes go post-v0.1. |
| `Stop` hook is passive echo, gets ignored | M | L | Phase 6 dogfood will reveal if it needs to do real work |
| Kiro tool names change in future release | L | M | Pin CLI version in `tech.md` steering |
| Nested subagent assumption violated silently | L | M | **Confirmed (Q4)**: document in AGENTS.md that subagents cannot chain. Mode agents orchestrate. |
| `dump` prompt fails in read-only modes | M | L | Document that `dump` requires a mode with `fs_write` (vault, thinker). Morning mode is read-only. |

## Acceptance Criteria

- [ ] `.kiro/` tree exists on `kiro-mind-draft` branch, `kiro-cli` starts cleanly
- [ ] `AGENTS.md` at root — tool-neutral, no `.claude/` references
- [ ] `.kiro/steering/` contains 4 files
- [ ] `vault.json` is default mode; all 4 hooks fire correctly
- [ ] All 9 subagents invokable from appropriate modes via `subagent` tool
- [ ] 6 additional mode agents exist with prompt bodies and subagent wiring
- [ ] 4 prompts in `.kiro/prompts/` work via `/prompts get`
- [ ] 5 skills activate by description matching
- [ ] 5 open questions documented with answers
- [ ] Integration test passes
- [ ] Dogfooded 5 working days; top 5 friction items fixed
- [ ] `v0.1.0` tag with release notes
- [ ] Migration guide written

## References

- Previous spec: `thinking/2026-04-08-kiro-mind-spec.md`
- Design doc: `thinking/2026-04-07-kiro-mind-readme-draft.md`
- Branch: `kiro-mind-draft`
- [Kiro CLI agent config reference](https://kiro.dev/docs/cli/custom-agents/configuration-reference/)
- [Kiro CLI hooks](https://kiro.dev/docs/cli/hooks/)
- [Kiro CLI prompts](https://kiro.dev/docs/cli/chat/manage-prompts/)
- [Kiro CLI subagent tool](https://kiro.dev/docs/cli/reference/built-in-tools/)
