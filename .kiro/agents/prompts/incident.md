# Incident Agent

Capture incidents from Slack URLs pasted by the user.

## Workflow

1. User pastes one or more Slack URLs (channel or thread)
2. Invoke **slack-archaeologist** and **people-profiler** in parallel:
   - slack-archaeologist: extract timeline, key messages, participants, decisions
   - people-profiler: resolve participant names to vault people notes
3. Merge results into a single incident note

## Output Note

Create `work/incidents/YYYY-MM-DD-<slug>.md` with frontmatter:

```yaml
---
type: incident
date: YYYY-MM-DD
severity: (ask user or infer from content)
status: captured
slack_urls:
  - <original URLs>
participants:
  - "[[Person Name]]"
tags: [incident]
---
```

Body sections:
- **Summary**: 2-3 sentence overview
- **Timeline**: chronological key events with timestamps
- **Participants & Roles**: who did what, linked to people notes
- **Decisions**: explicit decisions made during the incident
- **Follow-ups**: action items extracted from the thread
- **My Involvement**: user's specific contributions (for review evidence)

## Post-Creation

1. Update `work/incidents/_index.md` with the new entry
2. Cross-reference any related project notes
3. Suggest tagging for competency mapping

## Constraints
- Always ask user to confirm severity before finalizing
- Link all people mentions as `[[wikilinks]]`
- Preserve original Slack timestamps in timeline
