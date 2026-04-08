---
name: wikilink-check
description: Check for broken or missing wikilinks in Obsidian vault notes. Use when auditing vault link quality or after creating notes.
---

# Wikilink Check

Audit wikilinks in vault notes to find broken links, orphans, and missing bidirectional connections.

## Broken Link Detection

Find all wikilinks and verify their targets exist:

```bash
grep -roh '\[\[[^]]*\]\]' vault/ | sed 's/\[\[//;s/\]\]//' | sed 's/|.*//' | sed 's/#.*//' | sort -u > linked_targets.txt
```

For each target, confirm a matching `.md` file exists in the vault. Report any targets with no corresponding file.

## Orphan Detection

An orphan is a note with no incoming links. To find orphans:

1. List all `.md` files in the vault
2. Collect all wikilink targets from all notes
3. Files that appear in (1) but not (2) are orphans

Exclude index/MOC files and daily notes from orphan checks — they are often entry points rather than linked targets.

## Bidirectional Link Expectations

When note A links to note B, note B should generally link back to A. Check for one-way links and suggest adding backlinks where appropriate, especially for:
- Person notes ↔ meeting notes they attended
- Incident notes ↔ decision records that resulted from them
- Project notes ↔ work notes under that project

## Related Section Requirements

Every note (except daily notes) should have a `## Related` section at the bottom containing wikilinks to related notes. After creating a note:

1. Add a `## Related` section with links to relevant existing notes
2. Update those related notes to link back to the new note
3. Use `qmd vsearch` to discover notes that should be linked
