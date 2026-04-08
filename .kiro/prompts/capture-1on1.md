Capture a 1:1 meeting. The user will paste transcript or raw notes.

Create work/1-1/${1} YYYY-MM-DD.md with this frontmatter:

```yaml
date: YYYY-MM-DD
description: "1:1 with ${1}"
tags: [work-note]
status: completed
```

Sections to include:
- **Key Takeaways** — top 3-5 bullets
- **Decisions Made** — anything agreed on
- **Action Items** — who owes what, with owners
- **Quotes Worth Noting** — verbatim if available
- **What to Watch** — risks, tensions, open threads
- **Related** — wikilinks to relevant notes

After creating the note:
1. Update or create the person note in org/people/${1}.md
2. Add an entry to work/Index.md under 1:1s
3. Update brain/Memories.md if anything personally significant came up

Participant: ${1}
