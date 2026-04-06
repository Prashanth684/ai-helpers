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
/agentic-docs-maintainer --extract [--path <repo-path>]
```

**Modes:**
- **No flags** (or `:fix`) → Compliance only (fix broken links, indexes, etc.)
- **--extract flag** → Compliance + extraction in each iteration (see below)

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

### Execution Steps (Iterative Loop)

**Iteration 1-10:**

**Step 1: SCRIPT - Run verify.sh**
```bash
PLUGIN_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-maintainer/*/scripts" -type d | head -1)
REPO_ROOT="${provided_path:-$PWD}" bash "$PLUGIN_DIR/verify.sh"
```

What the script does:
- Checks 11 compliance areas
- Reports issues found
- Exits with status 0 (pass) or 1 (fail)

**Step 2: SCRIPT - Run loop.sh (if issues found)**
```bash
REPO_ROOT="${provided_path:-$PWD}" bash "$PLUGIN_DIR/loop.sh"
```

What the script does:
- Creates `.ralph-task-N.md` with current issues
- Waits for LLM intervention

**Step 3: LLM - Read task and fix issues**

LLM reads `.ralph-task-N.md` and executes:
- Fix broken links → Update file paths
- Fix incomplete indexes → Add missing references
- Fix missing /dev-guide/ refs → Add links to official docs
- Fix file count mismatches → Update KNOWLEDGE_GRAPH.md
- Fix markdown formatting → Fix unclosed code blocks

**Step 4: SCRIPT - Re-run verify.sh**

Check if issues resolved:
- ✅ All checks pass → SUCCESS (exit loop)
- ↻ Issues remain → Next iteration
- ❌ Same error 3x → STUCK (exit loop)
- ⚠️ Max 10 iterations → TIMEOUT (exit loop)

---

## With --extract Flag

When using `--extract` flag, the loop does BOTH compliance AND extraction:

**Step 2: SCRIPT - Run loop.sh --extract**
```bash
REPO_ROOT="${provided_path:-$PWD}" bash "$PLUGIN_DIR/loop.sh" --extract
```

**Step 3: LLM - Read task and execute Part 1 + Part 2**

Task file contains TWO parts:

**Part 1: Fix Compliance Issues** (same as above)
- Fix broken links, indexes, etc.

**Part 2: Extract Knowledge from Enhancements**
- Find recent enhancements (last 30 days)
- Extract APIs, patterns, decisions, terminology
- Create/update documentation
- Update indexes

Each iteration does compliance fixes FIRST, then extraction.

## See Also

- `/agentic-docs-maintainer:verify` - Check only (no changes)
- `/agentic-docs-maintainer:extract` - Also extract knowledge from enhancements
