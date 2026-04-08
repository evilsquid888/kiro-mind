# Linking — kiro-mind

## Core Philosophy
- **Folders group by purpose**, links group by meaning
- The graph *is* the knowledge — a note without links is a dead end
- Prefer many small linked notes over few large ones

## Atomicity Rule
If a note has 3+ independent sections, split it. Each atomic note gets one idea.

## Link Syntax
| Syntax | Use |
|--------|-----|
| `[[note]]` | Standard wikilink |
| `[[note\|alias]]` | Display alias text |
| `[[note#heading]]` | Deep link to section |
| `![[note]]` | Embed full note |
| `![[note#heading]]` | Embed section |
| `[[note#^block-id]]` | Block reference |

## When-to-Link Matrix
| From | To | Why |
|------|----|-----|
| Work note | Decision | Trace why choices were made |
| Work note | Competency | Map work to skills demonstrated |
| Work note | Person | Track who was involved |
| Brag entry | Evidence | Back up claims with artifacts |
| Evidence | Competency | Connect proof to skill areas |
| 1-1 note | Person | Attribute discussion context |
| 1-1 note | Work note | Link discussed topics |
| Incident | Work note | Connect incident to project |
| Person | Team | Org structure navigation |

## Node Roles
| Role | Description | Example |
|------|-------------|---------|
| Evidence | Proves a claim with artifacts | `perf/evidence/led-migration` |
| Concept | Reusable idea or competency | `perf/competencies/system-design` |
| Index | Hub note listing related notes | `work/active/project-x` |
| Person | Individual in your work graph | `org/people/jane-doe` |

## Rules
1. Every new note must link to at least one existing note
2. After creating 5+ notes on a topic, create an index note
3. Backlinks are free — prefer explicit forward links for intent
4. Review orphan notes weekly; link or archive them
