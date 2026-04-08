# Vault Migrator Agent

Classify, transform, and migrate content from a source vault into this vault.

## Modes

This agent operates in two modes. User specifies which mode to run.

---

### Mode 1: Classification

**Input**: path to a source vault directory.

**Process**:

1. Read all markdown files in the source vault
2. Analyze folder structure, frontmatter fields, filename patterns, and content heuristics
3. Classify the vault's organizational system:
   - **PARA** (Projects / Areas / Resources / Archives)
   - **Zettelkasten** (atomic notes with IDs, index notes, structure notes)
   - **Flat** (no meaningful folder hierarchy, tags-only)
   - **Folder-heavy** (deep nesting, folders as categories)
   - **Hybrid** (mix of the above)
4. For each file, determine:
   - Source category (what it is in the old system)
   - Target location (where it should go in this vault per structure.md)
   - Transform needed (frontmatter changes, link format changes)
   - Confidence (high / medium / low)

**Output**: return a classification map as a markdown table. Do not write files yet.

```markdown
| Source Path | Type | Target Path | Transforms | Confidence |
|-------------|------|-------------|------------|------------|
```

---

### Mode 2: Execution

**Input**: an approved classification plan (user confirms or edits the map from Mode 1).

**Process**:

1. For each file in the approved plan:
   - Read from source path
   - **Transform frontmatter**:
     - Add missing required fields per structure.md (type, date, tags)
     - Normalize existing fields (date formats → YYYY-MM-DD, tags → array)
     - Preserve all original fields — never delete source metadata
   - **Fix links**:
     - Convert `[text](path.md)` markdown links → `[[wikilinks]]`
     - Strip path prefixes from links (e.g. `../notes/foo` → `foo`)
     - Resolve relative paths to note names
   - **Write** to the target path in this vault
2. After all files are written:
   - Rebuild any affected `_index.md` files
   - Update relevant MOCs (Maps of Content) if they exist
3. Write migration log to `brain/Migration Log.md`:
   - Source vault path, date, file count
   - Table of every file migrated with source → target
   - Any files skipped and why
   - Any links that could not be resolved

## Constraints

- **Never modify the source vault** — read-only access to source
- Never overwrite existing files in this vault without user confirmation
- If a target path already exists, ask user: skip, rename, or merge
- Preserve original creation dates in frontmatter where available
- If a file has no frontmatter at all, create minimal frontmatter from filename and content
- Run in dry-run mode first (report what would happen) unless user says to execute
- Log every action for auditability
