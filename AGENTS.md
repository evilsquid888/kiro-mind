# AGENTS.md — Vault Rulebook

Canonical rules for any agentic tool operating on this Obsidian vault.

## Vault Purpose

Personal Obsidian vault — an external brain for work notes, decisions, performance tracking, and persistent agent context. Everything is git-tracked and Obsidian-browsable.

## Folder Structure

| Folder | Purpose |
|--------|---------|
| `Home.md` | Vault entry point — embedded views, quick links. Open first. |
| `work/` | Work notes index. `Index.md` is the master MOC. |
| `work/active/` | Current projects (1–3 files). Move here when starting. |
| `work/archive/YYYY/` | Completed work organized by year. |
| `work/incidents/` | Incident docs (main note + RCA + deep dive). |
| `work/1-1/` | 1:1 meeting notes. Named `<Person> YYYY-MM-DD.md`. |
| `perf/` | Performance framework. `Brag Doc.md` is the index. |
| `perf/brag/` | Quarterly brag notes (e.g. `Q1 2025.md`). |
| `perf/competencies/` | One note per competency (atomic). |
| `perf/evidence/` | PR deep scans, data extracts for reviews. |
| `perf/<cycle>/` | Review cycle briefs and artifacts. |
| `brain/` | Agent operational knowledge — topic notes. |
| `org/` | Org knowledge. `People & Context.md` is the MOC. |
| `org/people/` | One note per person. |
| `org/teams/` | One note per team. |
| `reference/` | Codebase knowledge, architecture maps. |
| `thinking/` | Scratchpad for drafts and reasoning. Temporary. |
| `templates/` | Obsidian templates for note creation. |
| `bases/` | Obsidian Bases — dynamic views for navigation. |

Root-level files (`Home.md`, `AGENTS.md`, `vault-manifest.json`, `CHANGELOG.md`, `README.md`, `LICENSE`, `.gitignore`) are infrastructure. No user notes at root.

## Note Types

| Type | Location | Naming | Key Sections |
|------|----------|--------|--------------|
| Work note | `work/active/` → `archive/YYYY/` | Descriptive title | Context, What/Why, Links, Related |
| Incident | `work/incidents/` | Ticket or title | Context, Root Cause, Timeline, Impact, Related |
| 1:1 note | `work/1-1/` | `<Person> YYYY-MM-DD.md` | Takeaways, Action Items, Quotes, Related |
| PR analysis | `perf/evidence/` | `<Person> PRs - <Period>.md` | PR Count, Projects, Quality, Growth |
| Review brief | `perf/<cycle>/` | `<Cycle> Review Brief.md` | Arc, Impact, Competencies, Trail |
| Person | `org/people/` | Full name | Role & Team, Relationship, Key Moments |
| Team | `org/teams/` | Team name | Members, Scope, Interactions |
| Competency | `perf/competencies/` | Competency name | Definition, levels, Evidence (backlinks) |
| Brain note | `brain/` | Topic name | Topic-specific content |
| Decision | `work/` | Descriptive title | Context, Options, Decision, Consequences |
| Thinking | `thinking/` | `YYYY-MM-DD-topic.md` | Scratchpad — promote, then delete |

## Frontmatter Requirements

Every note MUST have YAML frontmatter with at minimum:

```yaml
date: YYYY-MM-DD
description: "~150 char summary"  # Agent fills this automatically
tags: [<type-tag>]
```

Additional required fields by type:
- Work notes, incidents: `quarter: Q1-2026`
- Incidents: `ticket`, `severity` (high/medium/low), `role`
- Review-related: `cycle: h2-2024`
- Evidence notes: `person: "Full Name"`
- People/work notes: `team: Backend`
- Work notes: `status: active|completed|archived`
- Decisions: `status: proposed|accepted|deprecated`

Preserve existing frontmatter when editing. Never silently drop fields.

## Tags Convention

Tags go in frontmatter only (not inline):
- Type: `work-note`, `decision`, `perf`, `thinking`, `north-star`, `competency`, `person`, `team`, `brain`
- Index: `index`, `moc`
- Project: as needed, e.g. `project/auth-refactor`

Status, team, cycle, person, quarter — use frontmatter properties, not tags.

## Properties for Querying

| Property | Example | Purpose |
|----------|---------|---------|
| `cycle` | `h2-2024` | Review material for a cycle |
| `person` | `"Jane Smith"` | Evidence related to a person |
| `team` | `Backend` | Filter by team |
| `status` | `active` | Active projects |
| `quarter` | `Q1-2026` | Work Dashboard grouping |
| `ticket` | `TICKET-123` | Incident lookup |
| `severity` | `high` | Incident severity |
| `role` | `incident-lead` | Your role in an incident |

## Linking Rules

### Graph-First Principle

**Folders group by purpose, links group by meaning.** A note lives in ONE folder but links to MANY notes. Links are the primary organizational tool.

**A note without links is a bug.** After writing content, add wikilinks immediately. Every new note must link to at least one existing note.

### Atomicity Rule

Before writing or appending, ask: "Does this cover multiple distinct concepts?" If a note has 3+ independent sections that don't need each other, split into atomic notes that link to each other.

### Graph Roles

| Role | Examples | Behavior |
|------|----------|----------|
| Evidence nodes | Work notes, 1:1s, PR analyses | Add outbound links to concepts demonstrated |
| Concept nodes | Competencies, patterns | Stay definitional — evidence arrives via backlinks |
| Index nodes | Index, Brag Doc, Memories | Actively curate links — navigational |
| Person nodes | `org/people/` | Link to projects, teams, evidence. Receive backlinks. |

### When-to-Link Matrix

| From → To | Link Style |
|-----------|-----------|
| Work note ↔ Decision | Bidirectional |
| Work note → Competency | `## Related` section |
| Work note → Team / Person | `## Related` or body |
| Person → PR analysis | Link to evidence file |
| Brag Doc → Work note | Every entry links to evidence |
| Memories → Source note | Every memory links to origin |
| Index → Work notes | `work/Index.md` links to all |
| North Star → Projects | Focus areas link to project notes |

### Link Syntax

```
[[Note Title]]                  — standard wikilink (preferred over markdown links)
[[Note Title|display text]]     — aliased
[[Note Title#Heading]]          — deep link
![[Note Title]]                 — embed
[[Note Title#^block-id]]        — block reference
```

## Index Maintenance

Update when creating or archiving notes:

| Index | When to Update |
|-------|---------------|
| `work/Index.md` | New work note, decision, or project archived |
| `brain/Memories.md` | New brain topic note created |
| `brain/Skills.md` | New vault workflow registered |
| `org/People & Context.md` | People, teams, or org structure changes |
| `perf/Brag Doc.md` | Win achieved — log with evidence links |

## Decision Records

1. Create in `work/` using the Decision Record template
2. Link from the work note(s) that led to the decision
3. Add to the Decisions Log in `work/Index.md`
4. If significant, note in `brain/Key Decisions.md`

## Wins Tracking

When significant work is completed, add to `perf/Brag Doc.md` with links to work note(s). Categorize: Impact, Technical Growth, Collaboration, Feedback.

## Memory System (brain/)

All durable knowledge lives in `brain/` topic notes — git-tracked, Obsidian-browsable, linked.

| Note | Purpose |
|------|---------|
| `Memories.md` | Index of memory topics — pointers, not content |
| `Key Decisions.md` | Significant decisions and rationale |
| `Patterns.md` | Recurring patterns worth remembering |
| `Gotchas.md` | Traps, pitfalls, things that bite |
| `Skills.md` | Vault workflows and capabilities |
| `North Star.md` | Living goals and focus areas |

When asked to "remember" something:
1. Find or create the appropriate `brain/` topic note
2. Add the knowledge with a wikilink to context
3. Update `brain/Memories.md` if a new topic was created

`brain/North Star.md` — read at session start, reference for priorities, update when goals shift.

## Session Workflow

### Starting a Session

1. Read `Home.md` — vault entry point
2. Read `brain/North Star.md` — ground in current goals
3. Check `work/Index.md` — active projects and recent notes
4. Scan `brain/Memories.md` — read relevant topic notes
5. Check for open tasks across the vault

### Ending a Session

1. Archive completed projects: move `work/active/` → `work/archive/YYYY/`, set `status: completed`
2. Update `work/Index.md` if new notes or decisions were created
3. Update relevant brain topic notes with key learnings
4. Update `org/People & Context.md` if org knowledge changed
5. Update `perf/Brag Doc.md` if wins were achieved
6. Offer to update `brain/North Star.md` if goals shifted
7. Verify all new notes have links (orphans are bugs)
8. Add competency links to work notes that demonstrate them

Skip steps that don't apply. Goal: transfer durable knowledge from conversation to vault.

### Thinking Workflow

`thinking/` is a scratchpad, not storage. Create `thinking/YYYY-MM-DD-topic.md`, reason through the problem, promote findings to atomic notes in the correct folder, then delete the scratchpad.

## Agent Guidelines

### Graph-First Thinking

- Add wikilinks FIRST when creating a note. A note without links is a bug.
- Prefer bidirectional links: if A → B, then B → A (unless B is a concept node).
- Before creating a subfolder: "Can I solve this with a tag, property, or link?"
- After every substantial session, verify new notes have inbound links.

### Where to Put Things

| Writing about... | Put it in... |
|-----------------|-------------|
| A person | `org/people/` |
| A team | `org/teams/` |
| How the codebase works | `brain/` (Patterns, Gotchas, Key Decisions) |
| What to remember | `brain/` topic notes |
| A 1:1 meeting | `work/1-1/` |
| PR deep scans | `perf/evidence/` |
| Review briefs | `perf/<cycle>/` |
| Active project work | `work/active/` |
| An incident | `work/incidents/` |
| Unstructured info | Classify, then route to correct folder |

### Don't Mix Contexts

When capturing from Slack, DMs, or meetings:
- Project evidence (PRs, decisions, delivery) → relevant `work/` note
- Review prep (strategy, brag framing) → `perf/` or `work/`
- People dynamics (feedback, relationships) → `org/people/`
- Personal conversations → only if review-relevant; otherwise skip

## Rules

- Never modify `.obsidian/` config unless explicitly asked
- Preserve existing frontmatter when editing
- Git sync is the user's responsibility — don't configure hooks or auto-commit
- When reorganizing, use `git mv`. Never delete without explicit confirmation
- Always check for and suggest connections between notes
- Every note gets a `description` (~150 chars), filled automatically
- Use templates from `templates/`. Fill `{{placeholders}}` with real values
- Name files descriptively — note title as filename
- Zero data loss: move, don't delete. Confirm before destructive operations
