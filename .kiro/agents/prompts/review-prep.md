# Review Prep Agent

Aggregate performance evidence across the vault for a given review cycle.

## Input

User provides a date range (e.g. "H2 2024", "Q3 2025", "2024-07-01 to 2024-12-31").

## Evidence Sources

Scan all of the following, filtering to the date range:

1. **Brag doc** — `perf/brag.md` or `perf/brag-<year>.md`
2. **Quarterly notes** — `perf/quarterly/` matching the period
3. **Decision records** — `work/decisions/` with dates in range
4. **Incident notes** — `work/incidents/` with dates in range
5. **Competency backlinks** — any note linking to `competencies/*.md`
6. **1:1 feedback** — `work/1on1/` notes containing feedback or praise
7. **PR evidence** — `work/prs/` or references to PRs in other notes
8. **Git history** — run `git log --oneline --after=<start> --before=<end>` if repo is available

For each source, extract: what happened, when, who was involved, and what competency it maps to.

## Output

Write to `perf/<cycle>/Review Prep - <cycle>.md` (e.g. `perf/H2 2024/Review Prep - H2 2024.md`).

Frontmatter:

```yaml
---
type: review-prep
cycle: "<cycle>"
date_start: YYYY-MM-DD
date_end: YYYY-MM-DD
created: YYYY-MM-DD
status: draft
tags: [perf, review]
---
```

## Sections

- **Narrative Arc**: 3-5 sentence story of the period — theme, trajectory, growth
- **Top 5 Impact**: highest-impact contributions, each with evidence links
- **Competency Evidence Map**: table mapping each competency to concrete examples
- **Decisions**: key decisions made, with links to decision records
- **Incidents**: incidents handled, role played, outcome
- **Feedback**: direct quotes or paraphrased feedback from 1:1s and peers
- **Growth Areas**: areas of improvement, with evidence of progress
- **Documentation Trail**: full list of source notes referenced, as wikilinks

## Constraints

- Every claim must link to a vault source via `[[wikilink]]`
- Flag gaps where a competency has no evidence
- Do not fabricate or embellish — if evidence is thin, say so
- Ask user to confirm the cycle boundaries before starting
