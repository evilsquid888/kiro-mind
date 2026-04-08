#!/usr/bin/env python3
"""Post-write validation for vault notes. Kiro postToolUse hook (matcher: write).

Stdin: {"hook_event_name":"postToolUse","cwd":"...","tool_name":"fs_write",
        "tool_input":{...},"tool_response":{...}}
Stdout: validation warnings added to agent context.
"""
import json
import sys
import os
from pathlib import Path


def main():
    try:
        data = json.load(sys.stdin)
    except Exception:
        sys.exit(0)

    tool_input = data.get("tool_input", {})
    if not isinstance(tool_input, dict):
        sys.exit(0)

    # Kiro fs_write uses "path" field
    file_path = tool_input.get("path", "") or tool_input.get("file_path", "")
    if not file_path or not file_path.endswith(".md"):
        sys.exit(0)

    normalized = file_path.replace("\\", "/")
    basename = os.path.basename(normalized)

    # Skip non-vault files
    skip_names = {"README.md", "CHANGELOG.md", "CONTRIBUTING.md", "CLAUDE.md", "AGENTS.md"}
    if basename in skip_names or basename.startswith("README."):
        sys.exit(0)
    skip_paths = [".claude/", ".kiro/", ".obsidian/", "templates/", "thinking/"]
    if any(s in normalized for s in skip_paths):
        sys.exit(0)

    warnings = []
    try:
        content = Path(file_path).read_text(encoding="utf-8")

        if not content.startswith("---"):
            warnings.append("Missing YAML frontmatter")
        else:
            parts = content.split("---", 2)
            if len(parts) >= 3:
                fm = parts[1]
                if "tags:" not in fm and "tags :" not in fm:
                    warnings.append("Missing `tags` in frontmatter")
                if "description:" not in fm and "description :" not in fm:
                    warnings.append("Missing `description` (~150 chars required)")
                if "date:" not in fm and "date :" not in fm:
                    warnings.append("Missing `date` in frontmatter")

        if len(content) > 300 and "[[" not in content:
            warnings.append("No [[wikilinks]] found — every note must link to at least one other note")
    except Exception:
        sys.exit(0)

    if warnings:
        hint_list = "\n".join(f"  - {w}" for w in warnings)
        print(f"Vault hygiene warnings for `{basename}`:\n{hint_list}\nFix these before moving on.")

    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception:
        sys.exit(0)
