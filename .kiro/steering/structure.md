# Structure — kiro-mind

## Folder Layout
| Folder | Purpose |
|--------|---------|
| `brain/` | Fleeting notes, inbox, daily scratch |
| `work/active/` | Current projects and workstreams |
| `work/archive/YYYY/` | Completed work, archived by year |
| `work/incidents/` | Incident notes and postmortems |
| `work/1-1/` | 1-1 meeting notes by person |
| `perf/` | Performance review home |
| `perf/brag/` | Brag log entries |
| `perf/competencies/` | Competency/skill definitions |
| `perf/evidence/` | Concrete evidence linked to competencies |
| `org/people/` | Person notes (manager, peers, stakeholders) |
| `org/teams/` | Team structure and context |
| `reference/` | Long-lived reference material |
| `thinking/` | Drafts, explorations, half-baked ideas |
| `templates/` | Obsidian templates |
| `bases/` | Dataview-queryable structured notes |

## Note Types
| Type | Location | Naming | Key Sections |
|------|----------|--------|--------------|
| Work note | `work/active/` | `YYYY-MM-DD-slug` | Context, Decisions, Outcome, Links |
| Incident | `work/incidents/` | `YYYY-MM-DD-incident-slug` | Timeline, Impact, Root Cause, Action Items |
| 1-1 note | `work/1-1/` | `YYYY-MM-DD-person` | Agenda, Notes, Action Items |
| Brag entry | `perf/brag/` | `YYYY-MM-DD-slug` | What, Impact, Evidence links |
| Evidence | `perf/evidence/` | `evidence-slug` | Claim, Artifacts, Competency links |
| Competency | `perf/competencies/` | `competency-name` | Definition, Level, Evidence links |
| Person | `org/people/` | `firstname-lastname` | Role, Team, Context, Interaction log |
| Reference | `reference/` | `slug` | Summary, Source, Related |

## File Naming Conventions
- Lowercase, hyphen-separated: `my-note-title.md`
- Date-prefixed where chronological order matters: `YYYY-MM-DD-slug.md`
- No spaces, no special characters beyond hyphens
- Templates prefixed with `tpl-`: `tpl-work-note.md`
