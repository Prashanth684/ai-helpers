#!/bin/bash
# Agentic Docs Maintainer - Autonomous iteration for agentic/ directory
# Two modes:
#   1. Compliance mode (default): Fix broken links, indexes, references
#   2. Extract mode (--extract): Also extract knowledge from new enhancements

set -e

# Accept REPO_ROOT as environment variable, or calculate from script location
if [[ -z "$REPO_ROOT" ]]; then
    RALPH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    AGENTIC_DIR="$(cd "$RALPH_DIR/.." && pwd)"
    REPO_ROOT="$(cd "$AGENTIC_DIR/.." && pwd)"
fi

AGENTIC_DIR="$REPO_ROOT/agentic"
MAX_ITERATIONS=10
ITERATION=0
EXTRACT_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --extract)
            EXTRACT_MODE=true
            shift
            ;;
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--extract] [--max-iterations N]"
            exit 1
            ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Agentic Docs Maintainer - Autonomous Agentic Directory Maintenance${NC}"
echo "=========================================================="
echo ""
if [[ "$EXTRACT_MODE" == "true" ]]; then
    echo "Mode: KNOWLEDGE EXTRACTION + Compliance"
    echo "  • Fix compliance issues (broken links, indexes, etc.)"
    echo "  • Extract knowledge from new enhancements"
    echo "  • Create new docs when justified"
    echo "  • Enrich existing docs with new examples"
else
    echo "Mode: COMPLIANCE (fix issues only)"
    echo "  • Fix broken links, indexes, references"
    echo "  • Update file counts"
    echo "  • Add missing official doc references"
    echo ""
    echo "  💡 Use --extract to also process new enhancements"
fi
echo ""
echo "Max iterations: $MAX_ITERATIONS"
echo ""

# Check if we're in the right place
if [[ ! -f "$RALPH_DIR/SPECIFICATION.md" ]]; then
    echo -e "${RED}❌ Error: SPECIFICATION.md not found${NC}"
    exit 1
fi

if [[ ! -f "$RALPH_DIR/verify.sh" ]]; then
    echo -e "${RED}❌ Error: verify-agentic.sh not found${NC}"
    exit 1
fi

# Make verify script executable
chmod +x "$RALPH_DIR/verify.sh"

# Track if we're making progress
LAST_ERROR=""
STUCK_COUNT=0

# Function to run verification
run_verification() {
    local output
    output=$("$RALPH_DIR/verify.sh" 2>&1 || true)
    echo "$output"
}

# Function to detect if we're stuck
check_if_stuck() {
    local current_error="$1"

    if [[ "$current_error" == "$LAST_ERROR" ]]; then
        ((STUCK_COUNT++))
    else
        STUCK_COUNT=0
    fi

    LAST_ERROR="$current_error"

    if [[ $STUCK_COUNT -ge 3 ]]; then
        return 0  # Stuck
    else
        return 1  # Not stuck
    fi
}

# Initial verification
echo -e "${BLUE}🔍 Initial verification...${NC}"
VERIFY_OUTPUT=$(run_verification)
echo "$VERIFY_OUTPUT"
echo ""

if echo "$VERIFY_OUTPUT" | grep -q "✅ All checks passed!"; then
    echo -e "${GREEN}✅ Already compliant! No work needed.${NC}"
    exit 0
fi

# Extract issues
ISSUES=$(echo "$VERIFY_OUTPUT" | grep "^  - " || true)

echo -e "${YELLOW}📋 Issues found. Starting Agentic Docs Maintainer...${NC}"
echo ""

# Main Agentic Docs Maintainer
while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
    ((ITERATION++))

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🔄 Iteration $ITERATION/$MAX_ITERATIONS${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Create task file for this iteration
    TASK_FILE="$AGENTIC_DIR/.ralph-task-$ITERATION.md"

    # Create task based on mode
    if [[ "$EXTRACT_MODE" == "true" ]]; then
        cat > "$TASK_FILE" <<EOF
# Agentic Docs Maintainer Iteration $ITERATION - KNOWLEDGE EXTRACTION MODE

## Part 1: Fix Compliance Issues

$ISSUES

## Part 2: Extract Knowledge from Enhancements

After fixing compliance issues, process new enhancements:

1. **Find recent enhancements** (last 30 days):
   find $REPO_ROOT/enhancements -name "*.md" -type f -mtime -30

2. **Extract knowledge** for each enhancement:
   - New API types → Create domain/ docs
   - Architectural decisions → Propose ADRs (flag for review)
   - Reusable patterns → Create platform/operator-patterns/ docs
   - New terminology → Add to references/glossary.md
   - New examples → Enrich existing docs

3. **Update indexes**:
   - references/enhancement-index.md
   - Category-specific indexes

4. **Mark as processed**:
   - Append to .ralph-processed-enhancements.txt

## Guidelines

**Compliance fixes**:
- Fix broken links, update indexes, add references
- Standard compliance work

**Knowledge extraction**:
- Only create docs when justified (see SPECIFICATION.md section 1.4)
- Extract from source material, don't invent content
- Propose ADRs but flag for human review
- Enrich existing docs with new examples
- Update glossary with new terms

**Commits**:
- "Ralph iteration $ITERATION (compliance): <fix summary>"
- "Ralph iteration $ITERATION (extract): <what was extracted>"

## Verification

Run ./agentic/agentic-docs-maintainer/verify.sh after changes.

## Working Directory

$REPO_ROOT
EOF
    else
        cat > "$TASK_FILE" <<EOF
# Agentic Docs Maintainer Iteration $ITERATION - COMPLIANCE MODE

## Current Issues

$ISSUES

## Your Task

Fix the issues listed above to bring the agentic/ directory into compliance with SPECIFICATION.md.

**Guidelines**:
1. Fix broken links by updating paths
2. Update index files to reference all relevant docs
3. Add missing references to /dev-guide/ and /guidelines/
4. Update file counts in KNOWLEDGE_GRAPH.md
5. Do NOT create new content (use --extract mode for that)
6. Do NOT change official docs outside agentic/
7. Create a git commit when done: "Ralph iteration $ITERATION: <brief summary>"

**Verification**: After changes, run ./agentic/agentic-docs-maintainer/verify.sh to check compliance.

## Stopping Conditions

- ✅ All verification checks pass
- ❌ Same errors repeat 3 times (stuck)
- ⚠️  Max iterations reached ($MAX_ITERATIONS)

## Working Directory

$REPO_ROOT
EOF
    fi

    echo -e "${YELLOW}📝 Task file created: $TASK_FILE${NC}"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$TASK_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # *** INTEGRATION POINT ***
    # This is where Claude Code would be invoked
    # Options:
    #   1. Manual: User runs claude with task file
    #   2. API: Call Claude API with task file content
    #   3. Skill: Invoke via skill system

    echo -e "${YELLOW}⏸️  Agentic Docs Maintainer requires AI intervention${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review the task file above"
    echo "  2. Invoke Claude Code to fix the issues:"
    echo "     ${GREEN}claude --file $TASK_FILE${NC}"
    echo "     OR use the skill: ${GREEN}/ralph-fix${NC}"
    echo "  3. Press Enter when fixes are complete to verify"
    echo ""
    read -p "Press Enter when iteration $ITERATION is complete (or Ctrl+C to stop)..."

    # Re-run verification
    echo ""
    echo -e "${BLUE}🔍 Verifying changes...${NC}"
    VERIFY_OUTPUT=$(run_verification)
    echo "$VERIFY_OUTPUT"
    echo ""

    # Check if passed
    if echo "$VERIFY_OUTPUT" | grep -q "✅ All checks passed!"; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ SUCCESS! All checks passed!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "Iterations completed: $ITERATION"

        # Clean up task files
        rm -f "$AGENTIC_DIR/.ralph-task-"*.md

        exit 0
    fi

    # Extract new issues
    NEW_ISSUES=$(echo "$VERIFY_OUTPUT" | grep "^  - " || true)

    # Check if stuck
    if check_if_stuck "$NEW_ISSUES"; then
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${RED}❌ STUCK: Same errors repeated 3 times${NC}"
        echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "Last error:"
        echo "$LAST_ERROR"
        echo ""
        echo "Manual intervention required."
        exit 1
    fi

    # Check if no progress
    if [[ "$ISSUES" == "$NEW_ISSUES" ]]; then
        echo -e "${YELLOW}⚠️  No progress detected - same issues remain${NC}"
    else
        echo -e "${GREEN}✅ Progress detected - issues changed${NC}"
    fi

    ISSUES="$NEW_ISSUES"
    echo ""
done

# Max iterations reached
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${RED}❌ Max iterations ($MAX_ITERATIONS) reached${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Remaining issues:"
echo "$ISSUES"
echo ""
echo "Manual intervention required."
exit 1
