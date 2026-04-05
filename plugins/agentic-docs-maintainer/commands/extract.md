---
description: Extract knowledge from enhancements and create documentation automatically
---

## Name
agentic-docs-maintainer:extract

## Synopsis
```
/agentic-docs-maintainer:extract [--path <repo-path>]
/agentic-docs-maintainer --extract [--path <repo-path>]
```

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

Executes: `./agentic/agentic-docs-maintainer/loop.sh --extract`

Spawns autonomous agent that:
1. Runs compliance checks (fixes if needed)
2. Scans for new enhancements (last 30 days)
3. Extracts knowledge and creates docs
4. Creates git commits
5. Marks enhancements as processed

## See Also

- `/agentic-docs-maintainer` - Compliance mode (fixes only)
- `/agentic-docs-maintainer:verify` - Check only (no changes)
