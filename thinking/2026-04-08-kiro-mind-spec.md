## Goal

Create `kiro-mind`, a from-scratch Kiro CLI-native sibling project to obsidian-mind. It delivers the same outcomes (Obsidian vault pre-wired for capture, linking, performance tracking, and review prep) using Kiro's primitives — mode agents, subagents, skills, steering, AGENTS.md — instead of a lossy port of the Claude Code `.claude/` tree.

Full design, verified facts, and phased build plan: [`thinking/2026-04-07-kiro-mind-readme-draft.md`](https://github.com/evilsquid888/obsidian-mind/blob/kiro-mind-draft/thinking/2026-04-07-kiro-mind-readme-draft.md) @ `32c64bf`.

## Scope

**In scope (v0.1):**
- New sibling repo `kiro-mind` (fresh git init, copy vault content — not history)
- Root `AGENTS.md` as canonical tool-neutral rulebook
- `.kiro/steering/` split into `product.md`, `tech.md`, `structure.md`, `linking.md`
- 7 mode agents in `.kiro/agents/`: `vault` (default), `morning`, `wrapup`, `reviewer`, `incident`, `librarian`, `thinker`
- 9 subagents in `.kiro/subagents/` ported 1:1 from `.claude/agents/` — invoked via Kiro's native `subagent` tool
- 3 lightweight templates in `.kiro/prompts/`: `dump`, `humanize`, `capture-1on1`
- 5 skills in `.kiro/skills/`: `obsidian-markdown`, `obsidian-cli`, `qmd-search`, `frontmatter-validate`, `wikilink-check`
- Hook scripts in `.kiro/scripts/`: `session-start.sh`, `classify-message.py`, `validate-write.py` (adapted to Kiro's stdin format and tool names)
- Hooks wired in `vault.json`: `AgentSpawn`, `UserPromptSubmit`, `PostToolUse` (matcher: `write`), `Stop`
- Vault content folders copied verbatim: `brain/`, `work/`, `perf/`, `org/`, `reference/`, `thinking/`, `templates/`, `bases/`, `.obsidian/`
- README with install, daily flow, mode table, command cheat sheet
- Migration guide for obsidian-mind users

**Out of scope (v0.1):**
- `PreCompact` equivalent or transcript backup (no Kiro trigger exists)
- Back-porting any improvements to obsidian-mind
- Automated test suite for agent configs (manual verification acceptable at v0.1)
- Cross-repo config sync between kiro-mind and obsidian-mind
- Windows support (Linux/macOS only)
- Refactoring vault content during port (Phase 1 is copy, not improve)

## Acceptance Criteria

- [ ] New repo `kiro-mind` exists with all content folders copied from obsidian-mind
- [ ] `AGENTS.md` at root, tool-neutral (no `.claude/`, no Skill-tool references, no slash command table)
- [ ] `.kiro/steering/` contains 4 files: `product.md`, `tech.md`, `structure.md`, `linking.md`
- [ ] `.kiro/agents/vault.json` is default mode; `kiro-cli` starts cleanly in it
- [ ] `AgentSpawn` hook runs `session-start.sh` and injects North Star, git log, open tasks, file listing
- [ ] `UserPromptSubmit` hook runs `classify-message.py` and emits routing hints
- [ ] `PostToolUse` hook with matcher `write` runs `validate-write.py` and validates frontmatter + wikilinks on new notes
- [ ] All 9 subagents in `.kiro/subagents/` invokable from `vault` mode via the `subagent` tool; each returns structured output in isolated context
- [ ] 6 additional mode agents (`morning`, `wrapup`, `reviewer`, `incident`, `librarian`, `thinker`) exist with prompt bodies and subagent wiring
- [ ] 3 lightweight prompts in `.kiro/prompts/` invokable via `/prompts get <name>`
- [ ] 5 skills in `.kiro/skills/` activate correctly by description matching
- [ ] README cheat sheet commands all work end-to-end
- [ ] 5 open questions (see below) documented with answers in `thinking/kiro-verification-<date>.md`
- [ ] Dogfooded for 5 working days; top 5 friction items fixed
- [ ] `v0.1.0` tag with release notes
- [ ] Migration guide `docs/migration-from-obsidian-mind.md` written

## Open Questions (resolve in Phase 2 scratch tests)

- [ ] Exact file format of `.kiro/prompts/*` (markdown? JSON? frontmatter required?)
- [ ] Do hooks on `kiro_default` fire when a custom mode agent is active, or must each agent declare its own?
- [ ] Does the `subagent` tool honor `allowedTools` from the invoked subagent's config, or inherit from the caller?
- [ ] Can a subagent itself invoke another subagent (nested), or is delegation flat?
- [ ] Does `AgentSpawn` fire on every `/agent swap` or only on `kiro-cli` startup?

## Constraints

- **Kiro primitives only**: design around what Kiro provides, do not emulate Claude Code patterns that don't fit (`PreCompact`, global hooks, `/commands`)
- **Hooks are per-agent**: no global hooks in Kiro; hook stanzas may need duplication across mode agents (scripts remain shared)
- **Tool names**: Kiro uses `read`, `write`, `glob`, `grep`, `shell`, `subagent`, etc. No separate `Edit` — the `PostToolUse` matcher is `write` only
- **Max 4 parallel subagents** via `subagent` tool
- **Context preservation confirmed**: `/agent swap` preserves conversation history — modes can be chained
- **Vault content is tool-agnostic**: must not diverge between obsidian-mind and kiro-mind at v0.1

## Risks

- Hooks don't inherit across agent swaps → 7x duplication (Medium likelihood, Low impact — scripts shared)
- `subagent` tool semantics differ from Claude Task tool in ways we haven't caught (Medium/Medium — verify Phase 2)
- `.kiro/prompts/` format not markdown-friendly → lose 3 commands' ergonomics (Low/Low)
- `AgentSpawn` fires only on CLI startup, not swap → move session-start to `UserPromptSubmit` with a first-message guard (Medium/Medium)
- Scope creep: tempted to refactor vault content during the port (High/Medium — hard rule: Phase 1 is copy-only)

## Dependencies

- Kiro CLI installed and working (`curl -fsSL https://cli.kiro.dev/install | bash`)
- `gh` CLI for repo creation
- QMD installed for semantic search skill
- Obsidian (optional, for `obsidian-cli` skill validation)

## Phases (summary)

1. **Baseline** (1d) — new repo, copy vault, write AGENTS.md + 4 steering files + README, port 5 skills
2. **vault agent + verification** (1d) — default mode agent, wire 4 hooks, answer all 5 open questions
3. **Subagents** (2d) — port 9 subagents in order from easiest (`context-loader`) to hardest (`vault-migrator`)
4. **Mode agents** (2d) — build 6 additional modes with subagent wiring
5. **Prompts** (0.5d) — create 3 lightweight prompts and verify they're repo-trackable
6. **Dogfood + release** (~1 week part-time) — use for 5 days, fix friction, write migration guide, tag v0.1.0

**MVP cut**: Phases 1 + 2 + `vault` + 1 subagent + 1 mode proves the concept end-to-end. ~2.5 days.

## Decision Log

- Sibling repo over port/branch/subfolder — ergonomics mismatch too large for a port
- Mode agents over slash command emulation — `/agent swap` context preservation (verified) makes modes natural
- Real subagents (not skills) — Kiro's `subagent` tool has Claude Task-tool parity
- Hand-authored AGENTS.md (not generated) — low change rate, generation adds build step and drift risk
- `PreCompact` dropped — no Kiro trigger, non-critical

## References

- Plan doc: [`thinking/2026-04-07-kiro-mind-readme-draft.md`](https://github.com/evilsquid888/obsidian-mind/blob/kiro-mind-draft/thinking/2026-04-07-kiro-mind-readme-draft.md) @ `32c64bf`
- Branch: [`kiro-mind-draft`](https://github.com/evilsquid888/obsidian-mind/tree/kiro-mind-draft)
- [Kiro CLI docs](https://kiro.dev/docs/cli/)
- [Agent configuration reference](https://kiro.dev/docs/cli/custom-agents/configuration-reference/)
- [Built-in tools](https://kiro.dev/docs/cli/reference/built-in-tools/)
- [Hooks](https://kiro.dev/docs/cli/hooks/)
- [Steering](https://kiro.dev/docs/cli/steering/)
- [Skills](https://kiro.dev/docs/cli/skills/)
- [Manage prompts](https://kiro.dev/docs/cli/chat/manage-prompts/)
