#!/bin/bash
# Category-based validation for Tier 1 agentic documentation
# FLEXIBLE: Checks categories have content, not exact file lists
#
# Used by: Skills during generation (SKILL.md Phase 8)
# Purpose: Flexible validation that adapts to different file naming
# Approach: Checks categories have min files, suggests (not mandates) common files
# Compare to: validate.sh (comprehensive strict validation for commands)

set -euo pipefail

REPO_PATH="${1:-.}"
AGENTIC_DIR="$REPO_PATH/agentic"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CATEGORIES_FILE="$SCRIPT_DIR/categories.yaml"

EXIT_CODE=0
declare -a ISSUES=()
declare -a WARNINGS=()

record_issue() {
    ISSUES+=("$1")
    EXIT_CODE=1
}

record_warning() {
    WARNINGS+=("$1")
}

echo "🔍 Category-Based Validation (Flexible)"
echo "========================================"
echo "Repository: $REPO_PATH"
echo ""

# Check if agentic/ exists
if [ ! -d "$AGENTIC_DIR" ]; then
    echo "❌ agentic/ directory not found"
    exit 1
fi

# 1. Check required categories have minimum content
echo "📋 [1/5] Checking category content..."
echo ""

CATEGORIES=(
    "platform/operator-patterns:5:Operator patterns"
    "platform/openshift-specifics:2:OpenShift specifics"
    "practices/testing:3:Testing practices"
    "practices/security:2:Security practices"
    "practices/reliability:2:Reliability practices"
    "practices/development:2:Development practices"
    "domain/kubernetes:1:Kubernetes concepts"
    "domain/openshift:3:OpenShift concepts"
    "decisions:3:ADRs"
    "workflows:1:Workflows"
    "references:2:References"
)

for category_spec in "${CATEGORIES[@]}"; do
    IFS=':' read -r path min_files description <<< "$category_spec"

    if [ -d "$AGENTIC_DIR/$path" ]; then
        count=$(find "$AGENTIC_DIR/$path" -name "*.md" -type f 2>/dev/null | wc -l)

        if [ "$count" -ge "$min_files" ]; then
            echo "  ✅ $description: $count files (min: $min_files)"
        else
            record_issue "$description has only $count files (min: $min_files)"
            echo "  ❌ $description: $count files (min: $min_files)"
        fi
    else
        record_issue "Missing category: $path"
        echo "  ❌ Missing: $description ($path)"
    fi
done

echo ""

# 2. Check entry points exist
echo "📋 [2/5] Checking entry points..."
echo ""

ENTRY_POINTS=(
    "OPENSHIFT_AGENTS.md"
    "DESIGN_PHILOSOPHY.md"
    "KNOWLEDGE_GRAPH.md"
)

for entry in "${ENTRY_POINTS[@]}"; do
    if [ -f "$AGENTIC_DIR/$entry" ]; then
        lines=$(wc -l < "$AGENTIC_DIR/$entry")
        echo "  ✅ $entry exists ($lines lines)"
    else
        record_issue "Missing entry point: $entry"
        echo "  ❌ Missing: $entry"
    fi
done

echo ""

# 3. Suggest commonly useful files (non-prescriptive)
echo "📋 [3/5] Checking commonly recommended files..."
echo ""

SUGGESTED_CRITICAL=(
    "platform/operator-patterns/must-gather.md:Diagnostics collection"
    "platform/operator-patterns/owner-references.md:Garbage collection"
    "platform/operator-patterns/status-conditions.md:Health reporting"
    "practices/security/secrets-management.md:Secrets handling"
    "practices/reliability/alerting.md:Alert best practices"
    "practices/testing/test-flake-policy.md:Flake handling"
    "decisions/adr-template.md:ADR template"
)

missing_suggestions=()
for suggestion in "${SUGGESTED_CRITICAL[@]}"; do
    IFS=':' read -r file description <<< "$suggestion"

    if [ -f "$AGENTIC_DIR/$file" ]; then
        echo "  ✅ $description ($file)"
    else
        missing_suggestions+=("$description ($file)")
        echo "  ℹ️  Consider adding: $description ($file)"
    fi
done

if [ ${#missing_suggestions[@]} -eq 0 ]; then
    echo ""
    echo "  ✓ All commonly recommended files present"
fi

echo ""

# 4. Check for cross-references (suggestions)
echo "📋 [4/5] Checking cross-references..."
echo ""

if [ -d "$REPO_PATH/dev-guide" ]; then
    echo "  ✅ dev-guide/ exists"

    # Check if any cross-references exist (suggestion, not requirement)
    if grep -rq "dev-guide/" "$AGENTIC_DIR" 2>/dev/null; then
        echo "  ✅ Found references to dev-guide/"
    else
        record_warning "No references to dev-guide/ - consider cross-referencing official docs"
        echo "  ⚠️  No references to dev-guide/ found (consider adding)"
    fi

    # Check for enhancement roadmap
    if [ -f "$AGENTIC_DIR/ENHANCEMENT_ROADMAP.md" ]; then
        echo "  ✅ ENHANCEMENT_ROADMAP.md exists"
    else
        record_warning "ENHANCEMENT_ROADMAP.md missing - consider documenting status/gaps"
        echo "  ℹ️  Consider adding ENHANCEMENT_ROADMAP.md"
    fi
fi

echo ""

# 5. Check OPENSHIFT_AGENTS.md size (recommendation, not requirement)
echo "📋 [5/5] Checking OPENSHIFT_AGENTS.md size..."
echo ""

if [ -f "$AGENTIC_DIR/OPENSHIFT_AGENTS.md" ]; then
    LINES=$(wc -l < "$AGENTIC_DIR/OPENSHIFT_AGENTS.md")

    if [ "$LINES" -ge 150 ] && [ "$LINES" -le 200 ]; then
        echo "  ✅ OPENSHIFT_AGENTS.md: $LINES lines (target: 150-170)"
    elif [ "$LINES" -lt 150 ]; then
        echo "  ⚠️  OPENSHIFT_AGENTS.md: $LINES lines (recommended: 150-170)"
    else
        echo "  ⚠️  OPENSHIFT_AGENTS.md: $LINES lines (recommended: 150-170, keep concise)"
    fi
fi

echo ""

# Summary
echo "=================================================="
echo ""

if [ ${#ISSUES[@]} -eq 0 ] && [ ${#WARNINGS[@]} -eq 0 ]; then
    echo "✅ Validation PASSED (no issues)"
    echo ""
    exit 0
fi

if [ ${#ISSUES[@]} -gt 0 ]; then
    echo "❌ Validation FAILED with ${#ISSUES[@]} issue(s):"
    echo ""
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue"
    done
    echo ""
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "⚠️  ${#WARNINGS[@]} warning(s) (suggestions, not failures):"
    echo ""
    for warning in "${WARNINGS[@]}"; do
        echo "  - $warning"
    done
    echo ""
fi

exit $EXIT_CODE
