---
description: Extract knowledge from enhancements and create documentation automatically
---

## Name
agentic-docs-maintainer:extract

## Synopsis
```
/agentic-docs-maintainer:extract [--path <repo-path>]
```

**Important Distinctions:**
- **:extract** (this command) → Extract knowledge from **Tier 1 enhancements** (creates/enriches docs)
- **--extract** (flag to main command) → Compliance + extraction from enhancements, iterative loop
- **:tier2-lean --extract** → Extract from **single-tier docs** to create lean Tier 2 (removes generic duplication)

## Description
Knowledge extraction mode - scans `/enhancements/` directory for new proposals and automatically:

**Parameters:**
- `--path <repo-path>`: Path to the repository (defaults to current working directory)
- `--extract`: Enable extraction mode

**What it does:**

1. Creates domain docs for new API types
2. Creates pattern docs when reusable patterns emerge (3+ enhancements)
3. Proposes ADRs for architectural decisions (DRAFT - human review required)
4. Updates glossary with new terminology
5. Enriches existing docs with new examples

This is the **proactive** mode that creates new documentation.

## What Gets Created

| Enhancement Contains | Creates |
|---------------------|---------|
| New API type | `domain/openshift/[type].md` |
| Reusable pattern (3+) | `platform/operator-patterns/[pattern].md` |
| Architectural decision | `decisions/adr-NNNN-[decision].md` (DRAFT) |
| New terminology | Entries in `references/glossary.md` |
| New example | Enriches existing pattern docs |

## Example

```
Enhancement merged: enhancements/workload/kueue-integration.md

Running: /agentic-docs-maintainer:extract

🧠 Found 1 new enhancement
🔍 Detected:
  - New API type: ClusterQueue
  - Architectural decision: Workload management
  - New terminology: Kueue, Cohort

✅ Created:
  - domain/openshift/clusterqueue.md (NEW)
  - decisions/adr-0004-kueue-workload.md (DRAFT)
  - Updated glossary (+3 terms)

⚠️  Action required: Review proposed ADR-0004
```

## Safety Features

- ✅ Human review required for ADRs (proposed as DRAFT)
- ✅ Source-based only (extracts from enhancements, doesn't invent)
- ✅ Only creates docs when justified (new API types, patterns in 3+ enhancements)
- ✅ Git commits for each extraction (traceable/reversible)
- ✅ Max 10 iterations (bounded execution)

## Implementation

### Execution Steps

**Step 1: SCRIPT - Run extract.sh**
```bash
PLUGIN_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-maintainer/*/scripts" -type d | head -1)
REPO_ROOT="${provided_path:-$PWD}" bash "$PLUGIN_DIR/extract.sh"
```

What the script does:
- Creates `.ralph-processed-enhancements.txt` (if doesn't exist)
- Scans `enhancements/` for recent files (last 30 days)
- Filters out already-processed enhancements
- Creates `.ralph-extract-task.md` with detailed extraction instructions
- Waits for LLM

**Step 2: LLM - Read task and extract knowledge**

LLM reads `.ralph-extract-task.md` and executes:
- Create critical files (DESIGN_PHILOSOPHY.md, KNOWLEDGE_GRAPH.md)
- Deepen template docs (add examples, edge cases, anti-patterns)
- Extract from enhancements:
  - New API types → Create domain docs
  - Patterns (3+ enhancements) → Create pattern docs
  - Architectural decisions → Propose ADRs (DRAFT)
  - New terminology → Add to glossary
- Append processed enhancements to `.ralph-processed-enhancements.txt`

## See Also

- `/agentic-docs-maintainer` - Compliance mode (fixes only)
- `/agentic-docs-maintainer:verify` - Check only (no changes)
