#!/bin/bash
# Check for existing official documentation in openshift/enhancements
# Exit 0 if no conflicts, 1 if RECONCILIATION_NEEDED.md should be created

set -e

REPO_PATH="${1:-.}"
EXIT_CODE=0

echo "🔍 Checking for existing official documentation..."
echo "Repository: $REPO_PATH"
echo ""

# Check for dev-guide/
if [ -d "$REPO_PATH/../dev-guide" ]; then
    DEV_GUIDE_COUNT=$(find "$REPO_PATH/../dev-guide" -name "*.md" 2>/dev/null | wc -l)
    echo "✅ Found dev-guide/ with $DEV_GUIDE_COUNT files"

    if [ "$DEV_GUIDE_COUNT" -gt 3 ]; then
        echo "   ⚠️  Significant official documentation exists"
        EXIT_CODE=1
    fi

    # List key files
    echo ""
    echo "   Key files found:"
    [ -f "$REPO_PATH/../dev-guide/api-conventions.md" ] && echo "   - api-conventions.md (API design guidelines)"
    [ -f "$REPO_PATH/../dev-guide/operators.md" ] && echo "   - operators.md (Operator development guide)"
    [ -f "$REPO_PATH/../dev-guide/test-conventions.md" ] && echo "   - test-conventions.md (Test naming/organization)"
    [ -f "$REPO_PATH/../dev-guide/feature-zero-to-hero.md" ] && echo "   - feature-zero-to-hero.md (Feature lifecycle)"
    [ -f "$REPO_PATH/../dev-guide/breaking-changes.md" ] && echo "   - breaking-changes.md (Breaking change handling)"
    [ -f "$REPO_PATH/../dev-guide/featuresets.md" ] && echo "   - featuresets.md (Feature gates)"
    echo ""
else
    echo "ℹ️  No dev-guide/ found"
fi

# Check for guidelines/
if [ -d "$REPO_PATH/../guidelines" ]; then
    GUIDELINES_COUNT=$(find "$REPO_PATH/../guidelines" -name "*.md" 2>/dev/null | wc -l)
    echo "✅ Found guidelines/ with $GUIDELINES_COUNT files"

    if [ "$GUIDELINES_COUNT" -gt 0 ]; then
        echo "   ⚠️  Official enhancement/PR guidelines exist"
        EXIT_CODE=1
    fi

    # List key files
    echo ""
    echo "   Key files found:"
    [ -f "$REPO_PATH/../guidelines/enhancement_template.md" ] && echo "   - enhancement_template.md (Official enhancement template)"
    [ -f "$REPO_PATH/../guidelines/commit_and_pr_text.md" ] && echo "   - commit_and_pr_text.md (PR guidelines)"
    [ -f "$REPO_PATH/../guidelines/supportability.md" ] && echo "   - supportability.md (Supportability requirements)"
    echo ""
else
    echo "ℹ️  No guidelines/ found"
fi

# Summary
echo "===================================="
if [ "$EXIT_CODE" -eq 1 ]; then
    echo "⚠️  RECONCILIATION NEEDED"
    echo ""
    echo "Existing official documentation found that may overlap with agentic docs."
    echo ""
    echo "Recommended actions:"
    echo "1. Create RECONCILIATION_NEEDED.md in repo root"
    echo "2. Add references to official docs in agentic files"
    echo "3. Position agentic docs as supplement, not replacement"
    echo ""
    echo "Files that should reference official docs:"

    if [ -f "$REPO_PATH/../dev-guide/api-conventions.md" ]; then
        echo "   - agentic/practices/development/api-evolution.md → dev-guide/api-conventions.md"
    fi

    if [ -f "$REPO_PATH/../dev-guide/test-conventions.md" ]; then
        echo "   - agentic/practices/testing/index.md → dev-guide/test-conventions.md"
    fi

    if [ -f "$REPO_PATH/../guidelines/enhancement_template.md" ]; then
        echo "   - agentic/workflows/enhancement-process.md → guidelines/enhancement_template.md"
    fi

    if [ -f "$REPO_PATH/../dev-guide/operators.md" ]; then
        echo "   - agentic/platform/operator-patterns/index.md → dev-guide/operators.md"
    fi

    echo "   - agentic/references/index.md → Add 'Official Development Guides' section"
    echo ""
else
    echo "✅ NO RECONCILIATION NEEDED"
    echo ""
    echo "No significant existing official documentation found."
    echo "Agentic docs can be created without conflicts."
fi
echo "===================================="

exit $EXIT_CODE
