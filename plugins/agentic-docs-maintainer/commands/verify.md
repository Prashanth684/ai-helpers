---
description: Verify agentic documentation compliance against SPECIFICATION.md
---

## Name
agentic-docs-maintainer:verify

## Synopsis
```
/agentic-docs-maintainer:verify [--path <repo-path>]
```

## Description
Runs 11 automated compliance checks on the agentic/ directory to verify it meets SPECIFICATION.md requirements.

This command is **read-only** - it only checks and reports issues, does not fix them.

**Parameters:**
- `--path <repo-path>`: Path to the repository (defaults to current working directory)

## Checks Performed

1. **Internal links** - All relative links work
2. **Index completeness** - Index files reference all relevant docs
3. **Official doc references** - Links to /dev-guide/ and /guidelines/ exist
4. **Consistency** - No contradictions between docs
5. **File counts** - KNOWLEDGE_GRAPH.md matches reality
6. **Markdown formatting** - Code blocks properly closed
7. **Entry points** - All index.md files exist
8. **Required patterns** - Core operator patterns present
9. **New enhancements** - Unprocessed enhancements reported
10. **Glossary completeness** - Glossary exists and has content
11. **Enhancement index freshness** - Index is current

## Output

**On success (exit 0):**
```
✅ All checks passed!
The agentic/ directory meets the SPECIFICATION.md requirements.
```

**On failure (exit 1):**
```
❌ Found 3 issue(s):
  - decisions/index.md has 2 refs but 3 ADR files exist
  - Broken link: platform/foo.md
  - KNOWLEDGE_GRAPH.md file count mismatch

Run /agentic-docs-maintainer to fix automatically
```

## Implementation

When you invoke this command, Claude Code runs the verification script to check documentation compliance.

### Execution Flow

1. **Locate Scripts**:
   ```bash
   # Find the verify.sh script in the plugin cache
   PLUGIN_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-maintainer/*/scripts" -type d | head -1)
   ```

2. **Run Verification**:
   ```bash
   # Run verification with repository root
   REPO_ROOT="${provided_path:-$PWD}" bash "$PLUGIN_DIR/verify.sh"
   ```

3. **Report Results**:
   - Exit 0: All checks passed ✅
   - Exit 1: Issues found (with detailed list) ❌

### What the Script Checks

The `verify.sh` bash script performs 11 automated compliance checks:
- Internal links validity
- Index completeness
- Official documentation references
- Content consistency
- File count accuracy
- Markdown formatting
- Entry points existence
- Required patterns presence
- New enhancements detection
- Glossary completeness
- Enhancement index freshness

This command is **read-only** - no changes are made to the repository.

## See Also

- `/agentic-docs-maintainer` - Fix issues automatically
- `/agentic-docs-maintainer:extract` - Extract knowledge from enhancements
