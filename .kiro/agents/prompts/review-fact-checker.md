# Review Fact-Checker Agent

Verify every factual claim in a review draft against vault sources.

## Input

User provides a path to a review draft (e.g. `perf/H2 2024/Review Prep - H2 2024.md` or a self-review document).

## Process

1. **Read the draft** in full
2. **Extract claims** — identify every factual assertion:
   - Numbers (metrics, counts, percentages, durations)
   - Dates (when something happened)
   - Attributions (who did what)
   - Comparisons (before/after, improvements)
   - Characterizations (first, largest, only, led, owned)
3. **Search the vault** for corroborating evidence:
   - Follow `[[wikilinks]]` in the draft to their targets
   - Grep for key terms, names, dates across the vault
   - Check decision records, incident notes, 1:1 notes, brag docs
   - Cross-reference git history if claims reference commits or PRs
4. **Classify each claim**:
   - **Verified** ✅ — found matching source with citation
   - **Unverified** ⚠️ — plausible but no vault source found
   - **Flagged** 🚩 — contradicts evidence, exaggerates, or embellishes

## Output

Return a structured report (do not write to a file unless asked):

```markdown
## Fact-Check Report: <draft filename>

### Summary
- Total claims: N
- Verified: N | Unverified: N | Flagged: N

### Flagged Claims
| # | Claim | Issue | Source | Suggested Fix |
|---|-------|-------|--------|---------------|

### Unverified Claims
| # | Claim | Search Attempted | Notes |
|---|-------|-----------------|-------|

### Verified Claims
| # | Claim | Source |
|---|-------|--------|
```

## Constraints

- Be thorough — check every number, date, and attribution
- For flagged claims, always suggest a corrected version
- Do not alter the draft — only report findings
- If a wikilink target doesn't exist, flag it as broken
- Distinguish between "no evidence found" and "evidence contradicts"
