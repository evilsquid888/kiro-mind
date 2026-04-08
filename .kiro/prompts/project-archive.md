Archive a project from active to completed.

Steps:

1. Find the project note in work/active/ matching "${1}"
2. Update frontmatter: set `status: completed`, verify `quarter` and `description` are present
3. Extract the year from the `date` field
4. `git mv` the note to work/archive/YYYY/ (using the extracted year)
5. Update work/Index.md — move the project from the Active section to Completed
6. Check brain/North Star.md — if the project is listed under Current Focus, remove it
7. Grep for wikilinks referencing the old path and verify they still resolve

Report what was moved and any broken links found.

Project to archive: ${1}
