#!/bin/bash
# Agentic Docs Maintainer - Knowledge Extraction Mode
# Proactively extracts knowledge from enhancements and updates agentic/

set -e

# Accept REPO_ROOT as environment variable, or calculate from script location
if [[ -z "$REPO_ROOT" ]]; then
    RALPH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    AGENTIC_DIR="$(cd "$RALPH_DIR/.." && pwd)"
    REPO_ROOT="$(cd "$AGENTIC_DIR/.." && pwd)"
fi

AGENTIC_DIR="$REPO_ROOT/agentic"
ENHANCEMENTS_DIR="$REPO_ROOT/enhancements"
PROCESSED_FILE="$AGENTIC_DIR/.ralph-processed-enhancements.txt"
MAX_ITERATIONS=10

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}🧠 Agentic Docs Maintainer - Knowledge Extraction Mode${NC}"
echo "=========================================================="
echo ""
echo "This mode proactively:"
echo "  • Scans enhancements/ for new or updated proposals"
echo "  • Extracts architectural decisions, patterns, concepts"
echo "  • Creates new docs in agentic/ when justified"
echo "  • Enriches existing docs with new examples"
echo "  • Updates glossary with new terminology"
echo ""

# Create processed file if it doesn't exist
touch "$PROCESSED_FILE"

# Find recent enhancements (last 30 days or never processed)
echo -e "${BLUE}🔍 Discovering enhancements to process...${NC}"
echo ""

# Get list of recent enhancements
RECENT_ENHANCEMENTS=()
while IFS= read -r file; do
    # Check if already processed
    if ! grep -q "^$file$" "$PROCESSED_FILE" 2>/dev/null; then
        RECENT_ENHANCEMENTS+=("$file")
    fi
done < <(find "$ENHANCEMENTS_DIR" -name "*.md" -type f -mtime -30 2>/dev/null)

# Also get very recent ones even if processed (to catch updates)
while IFS= read -r file; do
    if ! printf '%s\n' "${RECENT_ENHANCEMENTS[@]}" | grep -q "^$file$"; then
        RECENT_ENHANCEMENTS+=("$file")
    fi
done < <(find "$ENHANCEMENTS_DIR" -name "*.md" -type f -mtime -7 2>/dev/null)

if [[ ${#RECENT_ENHANCEMENTS[@]} -eq 0 ]]; then
    echo -e "${GREEN}✅ No new enhancements to process${NC}"
    echo ""
    echo "All enhancements processed. The agentic/ directory is current."
    exit 0
fi

echo -e "${YELLOW}📋 Found ${#RECENT_ENHANCEMENTS[@]} enhancement(s) to process:${NC}"
for enh in "${RECENT_ENHANCEMENTS[@]}"; do
    echo "  - $(basename $enh)"
done
echo ""

# Create extraction task for autonomous agent
EXTRACTION_TASK="# Knowledge Extraction Task

## Enhancements to Process

Process the following ${#RECENT_ENHANCEMENTS[@]} enhancement(s):

$(printf '%s\n' "${RECENT_ENHANCEMENTS[@]}" | sed 's|^|  - |')

## Your Mission

Extract knowledge from these enhancements and update the agentic/ directory.

**HYBRID WORKFLOW (Option C):** This extraction fills the 40% gap left by agentic-docs-creator's 60% foundation. Your goal is to transform template docs into comprehensive documentation by extracting deep content from real enhancements.

## PRIORITY: Fill 40% Gap Targets

### 1. Critical Files (MUST CREATE if missing)

**DESIGN_PHILOSOPHY.md**
- Extract from: All enhancement \"Motivation\", \"Goals\", \"Non-Goals\", \"Alternatives Considered\" sections
- Structure: Core principles (Declarative Config, Self-Healing, etc.), each with Why/Examples
- Target: 13KB (~400 lines)
- Cross-reference: 10+ enhancements
- Quality: Extract real rationales, don't invent principles

**KNOWLEDGE_GRAPH.md**
- Extract from: Directory structure analysis + enhancement categories
- Structure: Navigation strategies + topic maps for different personas
- Target: 24KB (~700 lines)
- Include: Entry points for platform devs, component owners, new contributors
- Quality: Curated paths through content, not just file listing

**OPENSHIFT_AGENTS.md expansion**
- Current limit: 150 lines (if exists)
- Reality needs: 167 lines minimum
- Add: Real-world context, component examples, Tier 2 repo links
- Extract from: Component repos that use agentic/ docs

### 2. Deepen Template Docs (MUST EXPAND if < 200 lines)

For EACH doc in platform/operator-patterns/ that is < 200 lines:
- Current: ~100 lines (template with basic explanation)
- Target: 119-589 lines depending on topic complexity
  - Simple patterns (rbac, upgrades): 119-154 lines
  - Standard patterns (status, runtime): 139-276 lines
  - Complex patterns (webhooks, finalizers, owner-refs): 443-589 lines
- Add these sections:
  - **Why?** - Rationale from enhancements that chose this pattern
  - **Real Examples** - 3+ examples from merged enhancements (code snippets)
  - **Edge Cases** - Extracted from implementation details in enhancements
  - **Anti-patterns** - From \"Alternatives Considered\" sections
  - **Cross-references** - Link to 6+ related enhancements
  - **Performance** - Considerations from large-scale implementations
  - **Debugging** - Common issues from enhancement discussions

### 3. Missing Files (CREATE if justified)

Scan for these commonly missing docs and create if you find source material:
- domain/kubernetes/configmap.md (if 3+ enhancements use ConfigMaps)
- domain/kubernetes/secret.md (if 3+ enhancements use Secrets)
- platform/operator-patterns/degraded-state.md (extract degraded handling patterns)
- practices/reliability/observability.md (from monitoring enhancements)
- practices/development/code-organization.md (from repo structure patterns)
- workflows/testing-enhancements.md (from test plan sections)
- references/crd-index.md (generate from api/ type analysis)
- references/controller-index.md (generate from controller/ directory analysis)

**Criteria to create:**
- Found in 3+ enhancements (reusable pattern)
- OR new OpenShift API type (domain doc)
- OR cross-cutting practice (affects all components)
- Must have real source material (extract, don't invent)

## Extraction Guidelines

### 1. Identify New Concepts
- **New API types**: Create domain/openshift/[resource].md or domain/kubernetes/[resource].md
- **New terminology**: Add to references/glossary.md
- **New repositories**: Add to references/repo-index.md

### 2. Extract Architectural Decisions
- Look for \"Alternatives Considered\" sections
- If decision affects multiple components → Propose ADR in decisions/
- Document: Context, Decision, Rationale, Consequences

### 3. Identify Patterns
- Operator patterns that appear in multiple enhancements
- If reusable pattern → Create platform/operator-patterns/[pattern].md
- Include: When to use, example, anti-patterns

### 4. Extract Best Practices
- Security practices → practices/security/
- Testing approaches → practices/testing/
- Reliability patterns → practices/reliability/

### 5. Update Existing Docs
- Add examples to existing pattern docs
- Update DESIGN_PHILOSOPHY.md if new principles emerge
- Cross-reference in domain docs

### 6. Update Indexes
- Add to references/enhancement-index.md
- Update relevant category indexes

## What to Create

**Create new file when**:
- New OpenShift API type introduced (domain doc)
- Reusable pattern appears in 3+ enhancements (pattern doc)
- Cross-cutting architectural decision (ADR - flag for review)
- New major concept not documented (justified)

**Update existing file when**:
- Enhancement modifies existing resource (update domain doc)
- New example of existing pattern (add to pattern doc)
- New terminology (add to glossary)
- Enhancement fits existing category (update index)

**DON'T create**:
- Docs for one-off features (link in enhancement index instead)
- Duplicate content (reference enhancement, don't copy)
- Docs for rejected proposals
- Content without source material

## Example Outputs

### Example 1: New API Type
Enhancement introduces \`ManagedUpgrade\` resource →
**Create**: domain/openshift/managedupgrade.md
**Content**: Purpose, spec/status fields, use cases, example
**Update**: references/glossary.md (add ManagedUpgrade term)
**Update**: references/enhancement-index.md (link to enhancement)

### Example 2: New Pattern
Multiple enhancements use \"validation webhooks\" pattern →
**Create**: platform/operator-patterns/validation-webhooks.md
**Content**: When to use, implementation, examples from enhancements
**Update**: platform/operator-patterns/index.md

### Example 3: Architectural Decision
Enhancement chooses OVN over OpenShiftSDN for all new features →
**Create**: decisions/adr-0004-ovn-default-cni.md (DRAFT - flag for review)
**Content**: Context, decision, rationale from enhancement
**Update**: DESIGN_PHILOSOPHY.md (add network architecture principle)

### Example 4: Enrich Existing Doc
Enhancement shows new example of leader election →
**Update**: platform/operator-patterns/leader-election.md
**Add**: New example from enhancement
**Add**: Reference to enhancement

## Commit Strategy

Create git commits as you go:
- \"Extract: Add ManagedUpgrade domain doc from enhancement\"
- \"Extract: Update glossary with 5 new terms\"
- \"Extract: Propose ADR-0004 for OVN decision (review needed)\"

## Success Criteria

After processing (fills 40% gap):
1. **Critical files created:**
   - DESIGN_PHILOSOPHY.md exists (13KB, ~400 lines) ✅
   - KNOWLEDGE_GRAPH.md exists (24KB, ~700 lines) ✅
   - OPENSHIFT_AGENTS.md expanded to 167+ lines ✅

2. **Template docs deepened:**
   - All platform/operator-patterns/*.md are comprehensive (119-589 lines based on complexity) ✅
   - Each has Why/Examples/Edge Cases/Anti-patterns sections ✅
   - Each cross-references 6+ enhancements ✅

3. **Missing files created (if justified):**
   - All 8 target files evaluated ✅
   - Created if found in 3+ enhancements ✅

4. **Standard extraction:**
   - All new API types documented in domain/
   - Reusable patterns extracted to platform/
   - Glossary updated with new terminology
   - Enhancement index references all processed enhancements
   - ADRs proposed for cross-cutting decisions (flagged for human review)

5. **Quality bar:**
   - No content invented (all extracted from enhancements) ✅
   - Every claim references source enhancement ✅
   - Examples from merged enhancements only ✅

## Mark as Processed

When done, append processed enhancements to:
  $PROCESSED_FILE

## Working Directory

$REPO_ROOT

## Reference

- Specification: agentic/SPECIFICATION.md
- Enhancement directory: enhancements/
"

# Save task
TASK_FILE="$AGENTIC_DIR/.ralph-extract-task.md"
echo "$EXTRACTION_TASK" > "$TASK_FILE"

echo -e "${CYAN}📝 Extraction task created${NC}"
echo ""
echo "Task file: $TASK_FILE"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "AUTONOMOUS AGENT INVOCATION POINT"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This is where an autonomous agent would:"
echo "  1. Read the ${#RECENT_ENHANCEMENTS[@]} enhancement(s)"
echo "  2. Extract key knowledge"
echo "  3. Create/update docs in agentic/"
echo "  4. Create git commits"
echo "  5. Mark enhancements as processed"
echo ""
echo "Options to proceed:"
echo ""
echo "  1. Manual review and implementation"
echo "     - Review: $TASK_FILE"
echo "     - Implement changes"
echo "     - Press Enter when complete"
echo ""
echo "  2. Via Claude Code skill"
echo "     /ralph-extract"
echo ""
echo "  3. Via Agent API (fully autonomous)"
echo "     [Configure agent integration]"
echo ""

if [[ "${RALPH_INTERACTIVE:-true}" == "true" ]]; then
    read -p "Press Enter when extraction complete (or Ctrl+C to abort)..."
    echo ""
    echo -e "${GREEN}✅ Extraction complete!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review commits created during extraction"
    echo "  2. Review any proposed ADRs (human decision required)"
    echo "  3. Run verification: ./agentic/agentic-docs-maintainer/verify.sh"
else
    echo -e "${YELLOW}⚠️  Autonomous mode requires agent integration${NC}"
    exit 1
fi
