#!/bin/bash
# Agentic Docs Maintainer - Fully Autonomous Implementation
# Uses Claude Code Agent system for autonomous iteration

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

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🤖 Agentic Docs Maintainer - Fully Autonomous Mode${NC}"
echo "=========================================================="
echo ""

# Check prerequisites
if [[ ! -f "$RALPH_DIR/verify.sh" ]]; then
    echo -e "${RED}❌ Error: verify-agentic.sh not found${NC}"
    exit 1
fi

chmod +x "$RALPH_DIR/verify.sh"

# Function to extract issues from verification output
extract_issues() {
    local output="$1"
    echo "$output" | grep "^  - " || echo ""
}

# Track previous errors for stuck detection
LAST_ISSUES=""
STUCK_COUNT=0

while [[ $ITERATION -lt $MAX_ITERATIONS ]]; do
    ((ITERATION++))

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}🔄 Iteration $ITERATION/$MAX_ITERATIONS${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Run verification
    echo -e "${YELLOW}🔍 Running verification...${NC}"
    VERIFY_OUTPUT=$("$RALPH_DIR/verify.sh" 2>&1 || true)

    # Check if passed
    if echo "$VERIFY_OUTPUT" | grep -q "✅ All checks passed!"; then
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}✅ SUCCESS! All checks passed!${NC}"
        echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo "Iterations completed: $ITERATION"
        exit 0
    fi

    # Extract issues
    ISSUES=$(extract_issues "$VERIFY_OUTPUT")

    if [[ -z "$ISSUES" ]]; then
        echo -e "${YELLOW}⚠️  No specific issues found, but verification failed${NC}"
        echo "$VERIFY_OUTPUT"
        echo ""
        echo "Manual review required."
        exit 1
    fi

    # Check for stuck condition
    if [[ "$ISSUES" == "$LAST_ISSUES" ]]; then
        ((STUCK_COUNT++))
        if [[ $STUCK_COUNT -ge 3 ]]; then
            echo -e "${RED}❌ STUCK: Same issues repeated 3 times${NC}"
            echo ""
            echo "Issues:"
            echo "$ISSUES"
            exit 1
        fi
    else
        STUCK_COUNT=0
    fi
    LAST_ISSUES="$ISSUES"

    echo -e "${YELLOW}📋 Issues found:${NC}"
    echo "$ISSUES"
    echo ""

    # Create autonomous task prompt
    TASK_PROMPT="# Autonomous Fix - Agentic Docs Maintainer Iteration $ITERATION

You are an autonomous agent tasked with fixing agentic/ directory issues.

## Current Issues

$ISSUES

## Your Task

Fix the issues above to bring agentic/ directory into compliance with SPECIFICATION.md.

**Rules**:
1. Fix broken links by updating file paths
2. Update index files to reference all relevant documents
3. Add missing references to /dev-guide/ and /guidelines/
4. Update file counts in KNOWLEDGE_GRAPH.md to match reality
5. Fix markdown formatting issues
6. DO NOT create new content files
7. DO NOT modify files outside agentic/
8. CREATE a git commit when done with message: \"Ralph iteration $ITERATION: <brief fix summary>\"

**Verification**: After your changes, the verification script should pass.

**Working Directory**: $REPO_ROOT

## Available Files

Specification: $RALPH_DIR/SPECIFICATION.md
Verification: $RALPH_DIR/verify.sh

## Example Fixes

**Broken link**: Update reference in source file to correct path
**Incomplete index**: Add missing file reference to index.md
**Missing reference**: Add link to official doc with note \"See [official doc](../../dev-guide/...)\"
**File count mismatch**: Count actual files and update KNOWLEDGE_GRAPH.md

## Success Criteria

Run ./agentic/agentic-docs-maintainer/verify.sh and it should exit 0 (all checks pass).
"

    # Save task prompt for reference
    echo "$TASK_PROMPT" > "$AGENTIC_DIR/.ralph-iteration-$ITERATION.txt"

    # *** AUTONOMOUS AGENT INVOCATION ***
    # This is where we would invoke Claude Code agent
    # For now, we'll simulate or document the integration point

    echo -e "${YELLOW}🤖 Autonomous agent task created${NC}"
    echo ""
    echo "Task file: $AGENTIC_DIR/.ralph-iteration-$ITERATION.txt"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "INTEGRATION POINT: Spawn autonomous agent"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "To complete iteration $ITERATION:"
    echo ""
    echo "Option 1 - Manual (for testing):"
    echo "  1. Review task in: .ralph-iteration-$ITERATION.txt"
    echo "  2. Make fixes manually"
    echo "  3. Press Enter to continue"
    echo ""
    echo "Option 2 - Via Claude Code skill (recommended):"
    echo "  /ralph-fix $ITERATION"
    echo ""
    echo "Option 3 - Via Agent API:"
    echo "  [Invoke agent with task prompt programmatically]"
    echo ""

    # For demo purposes, we can either:
    # A) Pause for manual intervention
    # B) Actually spawn an agent if this is being run within Claude Code
    # C) Use Claude API if available

    if [[ "${RALPH_INTERACTIVE:-true}" == "true" ]]; then
        read -p "Press Enter when fixes complete (or Ctrl+C to abort)..."
    else
        # In fully autonomous mode, this would invoke the agent
        echo "⚠️  Autonomous mode requires agent integration"
        echo "Set RALPH_INTERACTIVE=false only when agent system is configured"
        exit 1
    fi

    echo ""
done

# Max iterations reached
echo -e "${RED}❌ Max iterations ($MAX_ITERATIONS) reached${NC}"
echo ""
echo "Remaining issues:"
echo "$ISSUES"
exit 1
