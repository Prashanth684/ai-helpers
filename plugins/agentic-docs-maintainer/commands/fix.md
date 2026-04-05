---
description: Automatically fix compliance issues in agentic documentation
---

## Name
agentic-docs-maintainer:fix
agentic-docs-maintainer (default)

## Synopsis
```
/agentic-docs-maintainer [--path <repo-path>]
/agentic-docs-maintainer:fix [--path <repo-path>]
```

## Description
Compliance mode - runs verification and autonomously fixes all issues found.

This is the **reactive** mode that fixes broken things.

**Parameters:**
- `--path <repo-path>`: Path to the repository (defaults to current working directory)

## What Gets Fixed

✅ **Broken internal links** - Updates file paths  
✅ **Incomplete indexes** - Adds missing references  
✅ **Missing /dev-guide/ references** - Adds links to official docs  
✅ **File count mismatches** - Updates KNOWLEDGE_GRAPH.md  
✅ **Unclosed code blocks** - Fixes markdown formatting

## How It Works

The autonomous loop:
1. Runs verification (checks 11 compliance areas)
2. Identifies specific issues
3. Spawns autonomous agent to fix them
4. Agent makes changes and creates git commit
5. Re-runs verification
6. Repeats until all checks pass (max 10 iterations)

## Example

```
/agentic-docs-maintainer

🔄 Iteration 1/10
🔍 Running verification...
❌ Found 3 issues:
  - decisions/index.md incomplete
  - Broken link: platform/foo.md
  - File count mismatch

🤖 Spawning fixer agent...
  ✓ Fixed decisions/index.md
  ✓ Fixed broken link
  ✓ Updated KNOWLEDGE_GRAPH.md
  ✓ Commit: "Fix 3 compliance issues"

🔍 Verifying...
✅ All checks passed!

✅ SUCCESS - Converged in 1 iteration
```

## Stopping Conditions

- ✅ **Success**: All checks pass
- ✅ **Converged**: No changes made
- ❌ **Stuck**: Same error repeats 3x
- ⚠️  **Timeout**: Max 10 iterations reached

## Implementation

Executes: `./agentic/agentic-docs-maintainer/scripts/loop.sh`

Spawns autonomous agent that:
1. Reads current state
2. Identifies issues from verification
3. Makes fixes
4. Creates git commits
5. Iterates until done

## See Also

- `/agentic-docs-maintainer:verify` - Check only (no changes)
- `/agentic-docs-maintainer:extract` - Also extract knowledge from enhancements
