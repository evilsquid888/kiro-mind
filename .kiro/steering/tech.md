# Tech Stack — kiro-mind

## Required
| Tool | Version | Role |
|------|---------|------|
| Obsidian | 1.12+ | Vault UI, graph, search |
| Kiro CLI | 0.x (pin to minor) | AI-assisted note creation and refactoring |
| Python | 3.8+ | Scripts in `scripts/` for batch ops |
| Git | 2.x | Version control for vault |

## Optional
| Tool | Role |
|------|------|
| QMD | Semantic search over vault markdown |

## Model Configuration
- Default model: `claude-sonnet-4.6`
- All Kiro CLI operations use this unless overridden per-command

## Compatibility Notes
- Pin Kiro CLI to current minor version; test before bumping
- Vault uses wikilink syntax (`[[note]]`), not markdown links
- All files are plain `.md` — no proprietary formats
- Python scripts must run without Obsidian open
- Git ignores `.obsidian/workspace.json` and `.obsidian/workspace-mobile.json`

## File Encoding
- UTF-8, LF line endings, no BOM
- YAML frontmatter on every note
