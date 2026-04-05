#!/bin/bash
# Autonomous Tier 2 documentation maintenance loop
# Detects changes → Creates task for AI → Validates → Repeats
# Usage: ./maintenance-loop.sh [path-to-component-repo] [--max-iterations N]

set -e

REPO_PATH="${1:-.}"
COMPONENT_NAME="$(basename $(realpath $REPO_PATH))"
AGENTIC_DIR="$REPO_PATH/agentic"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAX_ITERATIONS=10
ITERATION=0

# Parse arguments
shift || true
while [[ $# -gt 0 ]]; do
    case $1 in
        --max-iterations)
            MAX_ITERATIONS="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [repo-path] [--max-iterations N]"
            exit 1
            ;;
    esac
done

echo "🔄 Tier 2 Maintenance Loop - Autonomous Documentation Updates"
echo "=========================================================="
echo "Repository: $REPO_PATH"
echo "Component: $COMPONENT_NAME"
echo "Max iterations: $MAX_ITERATIONS"
echo ""

# Track progress
LAST_ISSUES=""
STUCK_COUNT=0

# Check prerequisites
if [ ! -f "$SCRIPT_DIR/detect-changes.sh" ]; then
    echo "❌ Error: detect-changes.sh not found"
    exit 1
fi

if [ ! -f "$SCRIPT_DIR/validate.sh" ]; then
    echo "❌ Error: validate.sh not found"
    exit 1
fi

# Make scripts executable
chmod +x "$SCRIPT_DIR/detect-changes.sh"
chmod +x "$SCRIPT_DIR/validate.sh"

# Initial checks
echo "🔍 Initial status check..."
DETECT_OUTPUT=$("$SCRIPT_DIR/detect-changes.sh" "$REPO_PATH" 2>&1 || true)
VALIDATE_OUTPUT=$("$SCRIPT_DIR/validate.sh" "$REPO_PATH" 2>&1 || true)

# Check if already compliant and current
if echo "$DETECT_OUTPUT" | grep -q "✅ No changes detected" && \
   echo "$VALIDATE_OUTPUT" | grep -q "✅ Tier 2 lean validation PASSED"; then
    echo "✅ Documentation is current and compliant!"
    echo ""
    echo "No maintenance needed."
    exit 0
fi

echo "📝 Changes or issues detected. Starting maintenance loop..."
echo ""

# Main loop
while [ $ITERATION -lt $MAX_ITERATIONS ]; do
    ((ITERATION++))

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔄 Iteration $ITERATION/$MAX_ITERATIONS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # Detect changes
    echo "🔍 Detecting changes..."
    CHANGES=$("$SCRIPT_DIR/detect-changes.sh" "$REPO_PATH" 2>&1 || true)
    echo ""

    # Validate compliance
    echo "🔍 Validating compliance..."
    ISSUES=$("$SCRIPT_DIR/validate.sh" "$REPO_PATH" 2>&1 || true)
    echo ""

    # Check if done
    if echo "$CHANGES" | grep -q "✅ No changes detected" && \
       echo "$ISSUES" | grep -q "✅ Tier 2 lean validation PASSED"; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "✅ SUCCESS! Maintenance complete"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Iterations: $ITERATION"
        exit 0
    fi

    # Extract issues for task creation
    CURRENT_ISSUES=$(echo "$ISSUES" | grep "^  - " || true)
    CURRENT_CHANGES=$(echo "$CHANGES" | grep "  📝" || true)

    # Check if stuck
    if [ "$CURRENT_ISSUES" = "$LAST_ISSUES" ] && [ -n "$CURRENT_ISSUES" ]; then
        ((STUCK_COUNT++))
        if [ $STUCK_COUNT -ge 3 ]; then
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "❌ STUCK: Same issues repeated 3 times"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Issues:"
            echo "$CURRENT_ISSUES"
            echo ""
            echo "Manual intervention required."
            exit 1
        fi
    else
        STUCK_COUNT=0
    fi
    LAST_ISSUES="$CURRENT_ISSUES"

    # Create task for AI agent
    TASK_FILE="$AGENTIC_DIR/.tier2-maintenance-iteration-$ITERATION.md"

    cat > "$TASK_FILE" <<EOF
# Tier 2 Maintenance - Iteration $ITERATION

## Component
**Repository**: $REPO_PATH
**Component**: $COMPONENT_NAME

## Detected Changes

$CURRENT_CHANGES

## Compliance Issues

$CURRENT_ISSUES

## Your Task

Update the Tier 2 lean documentation to address the changes and issues above.

### CRITICAL Tier 2 Lean Rules

1. ✅ **Component-specific content ONLY**
   - Document THIS component's concepts, architecture, decisions
   - Do NOT duplicate generic patterns

2. ❌ **NO generic content duplication**
   - Testing pyramid → Link to Tier 1 instead
   - controller-runtime → Link to Tier 1 instead
   - Operator patterns → Link to Tier 1 instead
   - STRIDE/SLO/etc → Link to Tier 1 instead

3. ✅ **Keep AGENTS.md ≤80 lines**
   - NOT 150 like Tier 1
   - Lean entry point with links

4. ✅ **Update ecosystem.md for new Tier 1 links**
   - If you reference new Tier 1 pattern, add to ecosystem.md

5. ✅ **Create component-specific docs only**
   - New CRD → domain/[crd-name].md (if component-specific)
   - New controller → architecture/components.md
   - New enhancement → exec-plans/active/[name].md
   - Architectural decision → decisions/adr-NNNN.md (if component-only)

### Example Actions

**For new CRD "MachineConfigNode":**
\`\`\`bash
# Create domain/machineconfignode.md
# Document: Purpose, API structure, lifecycle
# Link to Tier 1 CRD pattern
# Update domain/index.md
\`\`\`

**For code structure changes:**
\`\`\`bash
# Update architecture/components.md
# Reflect new package structure
# Update ARCHITECTURE.md if diagram changed
\`\`\`

**For generic content violation:**
\`\`\`bash
# Remove duplicated content
# Replace with link to Tier 1
# Example: "See [Testing Pyramid](https://github.com/openshift/enhancements/.../pyramid.md)"
\`\`\`

## Validation

After updates, verify:
1. Run: ./agentic/scripts/validate.sh
2. AGENTS.md still ≤80 lines
3. No generic content added
4. ecosystem.md updated if needed

## Commit

Create git commit:
\`\`\`
docs: tier2 maintenance iteration $ITERATION

- [Summary of changes]

Tier 2 compliance: [PASS/ISSUES]
AGENTS.md: [X] lines (≤80)
\`\`\`

## Working Directory

$REPO_PATH
EOF

    echo "📝 Task created: $TASK_FILE"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "$TASK_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "⏸️  AI agent intervention needed"
    echo ""
    echo "Options:"
    echo "  1. Invoke AI agent with task file"
    echo "  2. Make updates manually"
    echo "  3. Press Enter when complete"
    echo ""
    read -p "Press Enter when iteration $ITERATION complete (or Ctrl+C to stop)..."
    echo ""
done

# Max iterations reached
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "❌ Max iterations ($MAX_ITERATIONS) reached"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Remaining issues:"
echo "$CURRENT_ISSUES"
echo ""
echo "Remaining changes:"
echo "$CURRENT_CHANGES"
echo ""
echo "Manual intervention required."
exit 1
