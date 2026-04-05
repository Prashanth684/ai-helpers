---
name: agentic-docs-maintainer
description: Autonomous maintenance - fixes issues AND extracts knowledge from enhancements
trigger: always
model: sonnet
---

# Agentic Docs Maintainer Skill - Execution Instructions

When the user invokes this skill, run the agentic docs maintainer to maintain and enrich the agentic/ directory.

## Arguments

- No args or empty: **Compliance mode** (fix broken links, indexes, references)
- `--extract`: **Knowledge extraction mode** (also extract from enhancements)
- `--path <repo-path>`: **Repository path** (defaults to current working directory)

## Examples

```bash
# Use current directory
/agentic-docs-maintainer

# Specify enhancements repo path
/agentic-docs-maintainer --path /path/to/enhancements

# Extract mode with path
/agentic-docs-maintainer --extract --path /path/to/enhancements
```

## Task

You are invoking the Agentic Docs Maintainer loop autonomous maintenance system.

### Step 0: Parse Arguments and Determine Repository Path

Extract arguments from user input:
- If `--path <path>` is provided: use that path as REPO_PATH
- Otherwise: use current working directory as REPO_PATH

Verify the repository structure:
```bash
# Check if agentic/ directory exists
test -d "$REPO_PATH/agentic" || echo "⚠️ agentic/ directory not found - will need to create structure"
```

### Step 1: Locate Plugin Scripts

The plugin scripts are in the ai-helpers repo. Determine the plugin directory:
- If running from ai-helpers repo: `plugins/agentic-docs-maintainer/scripts/`
- If skill is installed elsewhere: Check common locations or use absolute path

For now, assume the scripts are at: `plugins/agentic-docs-maintainer/scripts/` (relative to ai-helpers repo)

### Step 2: Run Verification

Run verification script with REPO_ROOT environment variable:

```bash
REPO_ROOT="$REPO_PATH" plugins/agentic-docs-maintainer/scripts/verify.sh
```

### Step 3: Determine Mode

**If user passed `--extract` argument:**
- Mode: KNOWLEDGE EXTRACTION + Compliance
- Goal: Extract knowledge from new enhancements AND fix compliance issues

**Otherwise:**
- Mode: COMPLIANCE only
- Goal: Fix broken links, indexes, references

### Step 4: Execute Agentic Docs Maintainer Loop

Based on mode, spawn an autonomous agent to execute the Agentic Docs Maintainer loop.

#### For Compliance Mode (default):

Spawn an agent with this task:

```
You are the Agentic Docs Maintainer loop autonomous maintenance agent.

GOAL: Fix compliance issues in the agentic/ directory.

REPOSITORY ROOT: $REPO_PATH

Where $REPO_PATH is the path parsed from the skill arguments (or current working directory if not specified).

TASK:
1. Run verification: REPO_ROOT="$REPO_PATH" plugins/agentic-docs-maintainer/scripts/verify.sh
2. If all checks pass → DONE ✅
3. If issues found, fix them:
   - Broken internal links → Update file paths
   - Incomplete indexes → Add missing references
   - Missing /dev-guide/ refs → Add links to official docs
   - File count mismatches → Update KNOWLEDGE_GRAPH.md
   - Markdown formatting → Fix unclosed code blocks
4. Create git commit: "Agentic Docs Maintainer: Fix <brief description>"
5. Re-run verification
6. Repeat until verification passes or max 10 iterations

RULES:
- Only modify files in agentic/ directory
- Each fix gets its own commit
- Do NOT create new content (just fix broken things)
- Stop if same error repeats 3 times (stuck)

SPECIFICATION: See agentic/agentic-docs-maintainer/SPECIFICATION.md for all requirements
```

#### For Knowledge Extraction Mode (--extract):

Spawn an agent with this task:

```
You are the Agentic Docs Maintainer loop autonomous knowledge extraction agent.

GOAL: Extract knowledge from new enhancements AND fix compliance issues.

REPOSITORY ROOT: $REPO_PATH

Where $REPO_PATH is the path parsed from the skill arguments (or current working directory if not specified).

TASK PART 1 - Compliance:
1. Run verification: REPO_ROOT="$REPO_PATH" plugins/agentic-docs-maintainer/scripts/verify.sh
2. Fix any compliance issues (same as compliance mode)
3. Create commits for fixes

TASK PART 2 - Knowledge Extraction (FILLS 40% GAP):

**Mission:** Transform 60% foundation (from agentic-docs-creator) into 100% comprehensive docs by extracting the missing 40% from enhancements.

**PRIORITY TARGETS:**

1. **Create critical files (if missing):**
   - DESIGN_PHILOSOPHY.md (13KB, ~400 lines)
     * Extract from: Enhancement "Motivation", "Goals", "Alternatives Considered" sections
     * Structure: Core principles with Why/Examples from real enhancements
     * Cross-reference: 10+ enhancements
   
   - KNOWLEDGE_GRAPH.md (24KB, ~700 lines)
     * Extract from: Directory structure + enhancement categories
     * Structure: Navigation strategies + topic maps for different personas
     * Include: Entry points for platform devs, component owners
   
   - Expand OPENSHIFT_AGENTS.md to 167+ lines
     * Add: Real-world context, component examples, Tier 2 links
     * Extract from: Component repos using agentic/ docs

2. **Deepen template docs (100 lines → 119-589 lines based on complexity):**
   For EACH doc in platform/operator-patterns/ that is < 200 lines:
   - Add "Why?" section (rationale from enhancements)
   - Add 3+ real examples (code snippets from merged enhancements)
   - Add "Edge Cases" section (from implementation details)
   - Add "Anti-patterns" section (from alternatives considered)
   - Add 6+ cross-references per doc
   - Add "Performance" and "Debugging" sections

3. **Create missing files (if justified):**
   Scan for and create these if found in 3+ enhancements:
   - domain/kubernetes/configmap.md
   - domain/kubernetes/secret.md
   - platform/operator-patterns/degraded-state.md
   - practices/reliability/observability.md
   - practices/development/code-organization.md
   - workflows/testing-enhancements.md
   - references/crd-index.md
   - references/controller-index.md

4. **Standard extraction:**
   - NEW API TYPES → Create domain/openshift/[type].md
   - REUSABLE PATTERNS (3+ enhancements) → Create platform/operator-patterns/[pattern].md
   - ARCHITECTURAL DECISIONS → Create decisions/adr-NNNN-[decision].md (DRAFT - flag for review)
   - NEW TERMINOLOGY → Add to references/glossary.md
   - NEW EXAMPLES → Enrich existing docs

5. **Quality bar:**
   - All content extracted from enhancements (no invention)
   - Every claim must reference source enhancement
   - Examples only from merged enhancements
   - ADRs flagged DRAFT for human review

6. Create separate commits:
   "Extract: <what> from <enhancement>"

7. Mark as processed in agentic/.ralph-processed-enhancements.txt

EXTRACTION RULES (see agentic/agentic-docs-maintainer/SPECIFICATION.md section 1.4):
- Only create docs when justified (new API type, pattern in 3+ enhancements, etc.)
- Extract from source material, don't invent
- Propose ADRs but flag for human review (status: DRAFT)
- Enrich existing docs with new examples
- Update glossary with new terms

SAFETY:
- Only modify files in agentic/ directory
- Each extraction gets own commit
- ADRs must be DRAFT status (human review required)
- Max 10 iterations total
- Stop if stuck (same error 3x)
```

### Step 5: Report Results

After the agent completes, report:

**For Compliance Mode:**
```
✅ Agentic Docs Maintainer Loop - Compliance Mode Complete

Iterations: <N>
Fixes applied:
  - <list of fixes>

Commits created:
  - <commit messages>

Status: <PASS/STUCK/TIMEOUT>
```

**For Knowledge Extraction Mode:**
```
✅ Agentic Docs Maintainer Loop - Knowledge Extraction Mode Complete

Iterations: <N>

Compliance fixes:
  - <list of fixes>

40% Gap Filled:
  - ✅ DESIGN_PHILOSOPHY.md created (13KB, 400 lines)
  - ✅ KNOWLEDGE_GRAPH.md created (24KB, 700 lines)
  - ✅ OPENSHIFT_AGENTS.md expanded to 167 lines
  - ✅ <N> pattern docs deepened (100 → 119-589 lines based on complexity)
  - ✅ <N> missing files created (from 8 targets)

Standard Knowledge Extraction:
  - <N> domain docs created
  - <N> pattern docs created
  - <N> ADRs proposed (NEEDS REVIEW)
  - <N> glossary entries added
  - <N> existing docs enriched with examples

Commits created:
  - <commit messages>

Before: 60% capability (37 files, 3,500 lines, templates)
After: 96%+ capability (45 files, 11,800 lines, comprehensive)

⚠️ Action required: Review proposed ADRs (if any)

Status: <PASS/STUCK/TIMEOUT>
```

## Example Usage

User types: `/agentic-docs-maintainer`
→ Run compliance mode (fix broken things)

User types: `/agentic-docs-maintainer --extract`  
→ Run extraction mode (create new things from enhancements)

## Safety Features

- Max 10 iterations (prevents infinite loops)
- Stuck detection (stops if same error 3x)
- Git commits (every change traceable)
- Human review for ADRs (no autonomous decisions)
- Source-based only (extracts from enhancements, doesn't invent)
- Read-only outside agentic/ (can't modify official docs)

## Files Located At

All Agentic Docs Maintainer files are in `agentic/agentic-docs-maintainer/`:
- verify.sh - Verification script
- loop.sh - Main loop (can also be used directly)
- SPECIFICATION.md - All requirements
- README.md - Quick start guide
- GUIDE.md - Complete reference
