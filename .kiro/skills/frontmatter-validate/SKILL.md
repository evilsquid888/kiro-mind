---
name: frontmatter-validate
description: Validate YAML frontmatter on Obsidian vault notes. Use when creating or editing notes to ensure required fields (date, description, tags) and type-specific fields are present.
---

# Frontmatter Validation

Validate that every note has correct YAML frontmatter before saving.

## Universal Required Fields

All notes must have:
- `date` — ISO date (`YYYY-MM-DD`)
- `description` — ~150 character summary of the note's content
- `tags` — at least one tag as a YAML list

## Type-Specific Required Fields

### Work Notes
- `date`, `quarter` (e.g. `2026-Q2`), `description`, `status` (draft/active/done), `tags`

### Incident Notes
- All work note fields, plus: `ticket` (e.g. `INC-1234`), `severity` (sev1–sev4), `role` (responder/lead/observer)

### Person Notes
- `date`, `title`, `description`, `tags` — must include `person` tag

### Meeting Notes
- `date`, `description`, `tags`, `attendees` (list of `[[wikilinks]]`)

### Decision Records
- `date`, `description`, `status` (proposed/accepted/superseded), `tags`

## Description Convention

The `description` field should be approximately 150 characters — enough to be useful in search results and Bases views without reading the full note. Write it as a plain sentence, not a title.

## Tags Convention

- Use lowercase, hyphen-separated tags: `incident-review`, `team-sync`
- Use nested tags for hierarchy: `project/alpha`, `area/backend`
- Every note should have at least one category tag
- Person notes must include the `person` tag
