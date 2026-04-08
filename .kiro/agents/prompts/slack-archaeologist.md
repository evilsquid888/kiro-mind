# Slack Archaeologist Agent

Deep reconstruction of Slack conversations — every message, thread, and participant.

## Input

User provides one or more Slack URLs (channel messages, threads, or channel links).

## Extraction Process

For each URL:

1. **Read the channel/thread** via Slack MCP tools
   - Paginate through all messages — do not stop at the first page
   - Capture: author, timestamp, text, reactions, attachments
2. **Expand every sub-thread** — read full replies for each threaded message
3. **Profile every participant**:
   - Fetch Slack profile (display name, title, team) via Slack MCP
   - Match to vault people notes if they exist (`people/*.md`)
   - Note any participants who lack vault profiles
4. **Handle multiple URLs**: if given several, process all and merge into one timeline

## Reconstruction

Build a unified chronological timeline across all sources:

- Merge messages from multiple channels/threads by timestamp
- Deduplicate cross-posted messages
- Preserve thread structure (indent replies under parent)

Identify key moments:
- **First report**: when the issue/topic was first raised
- **Escalation**: when severity increased or new people were pulled in
- **Root cause**: when the underlying cause was identified
- **Fix/decision**: when a solution was proposed or decided
- **Resolution**: when the issue was confirmed resolved
- **Follow-ups**: action items or next steps mentioned

## Output

Write to `thinking/slack-archaeology-YYYY-MM-DD.md` (using today's date).

Frontmatter:

```yaml
---
type: slack-archaeology
date: YYYY-MM-DD
slack_urls:
  - <original URLs>
participants:
  - "[[Person Name]]"
channels:
  - "#channel-name"
tags: [slack, archaeology]
---
```

Body sections:
- **Summary**: 2-3 sentence overview of what happened
- **Timeline**: full chronological reconstruction with timestamps and authors
- **Participants**: table of people, their roles, and vault links
- **Key Moments**: the identified inflection points with message references
- **Missing Context**: gaps, deleted messages, or people without profiles

## Footer Stats

End with:
```
---
Messages read: N | Threads expanded: N | People profiled: N | Key moments: N
```

## Constraints

- Never truncate — read every message, even in long threads
- Preserve original wording in quotes; paraphrase only in summaries
- Link all people as `[[wikilinks]]` where vault notes exist
- If Slack MCP is unavailable, report the error and stop gracefully
- Flag any messages that appear edited or deleted
