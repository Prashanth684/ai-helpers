#!/bin/bash
# Validate Tier 2 lean documentation compliance
# Exit 0 if compliant, 1 if issues, 2 if contains Tier 1 content

set -e

REPO_PATH="${1:-.}"
COMPONENT_NAME="$(basename $(realpath $REPO_PATH))"
AGENTIC_DIR="$REPO_PATH/agentic"
AGENTS_FILE="$REPO_PATH/AGENTS.md"
EXIT_CODE=0

echo "🔍 Validating Tier 2 lean documentation compliance..."
echo "Repository: $REPO_PATH"
echo "Component: $COMPONENT_NAME"
echo ""

# Track issues
declare -a ISSUES=()
declare -a WARNINGS=()

record_issue() {
    ISSUES+=("$1")
    EXIT_CODE=1
}

record_warning() {
    WARNINGS+=("$1")
}

# 1. Check AGENTS.md exists and ≤80 lines (NOT 150 like Tier 1)
echo "📋 [1/10] Checking AGENTS.md size..."
if [ ! -f "$AGENTS_FILE" ]; then
    record_issue "Missing AGENTS.md at repository root"
    echo "  ❌ Missing AGENTS.md"
else
    LINES=$(wc -l < "$AGENTS_FILE")
    if [ "$LINES" -gt 80 ]; then
        record_issue "AGENTS.md is $LINES lines (must be ≤80 for Tier 2 lean)"
        echo "  ❌ AGENTS.md is $LINES lines (must be ≤80 for Tier 2, not 150 like Tier 1)"
    else
        echo "  ✅ AGENTS.md exists ($LINES lines ≤80)"
    fi
fi
echo ""

# 2. Check ecosystem.md exists (critical link to Tier 1)
echo "📋 [2/10] Checking ecosystem.md..."
if [ ! -f "$AGENTIC_DIR/references/ecosystem.md" ]; then
    record_issue "Missing agentic/references/ecosystem.md (required link to Tier 1)"
    echo "  ❌ Missing ecosystem.md - critical for Tier 2"
else
    echo "  ✅ ecosystem.md exists"

    # Check it links to Tier 1
    if ! grep -q "github.com/openshift/enhancements/.*agentic" "$AGENTIC_DIR/references/ecosystem.md"; then
        record_issue "ecosystem.md doesn't link to Tier 1 (enhancements/agentic/)"
        echo "  ❌ ecosystem.md missing Tier 1 links"
    else
        TIER1_LINKS=$(grep -c "github.com/openshift/enhancements/.*agentic" "$AGENTIC_DIR/references/ecosystem.md" || echo 0)
        echo "  ✅ ecosystem.md has $TIER1_LINKS Tier 1 links"

        if [ "$TIER1_LINKS" -lt 5 ]; then
            record_warning "ecosystem.md only has $TIER1_LINKS Tier 1 links (recommend ≥10)"
        fi
    fi
fi
echo ""

# 3. Check for generic content duplication (CRITICAL for Tier 2)
echo "📋 [3/10] Checking for generic content duplication..."
FORBIDDEN_GENERIC=(
    "testing pyramid"
    "controller-runtime reconciliation loop"
    "Available/Progressing/Degraded conditions"
    "STRIDE threat model"
    "SLO error budget"
    "E2E framework philosophy"
    "operator pattern.*all operators"
)

SERIOUS_VIOLATIONS=0
for pattern in "${FORBIDDEN_GENERIC[@]}"; do
    # Exception: "Examples" sections are OK
    if grep -ri "$pattern" "$AGENTIC_DIR" 2>/dev/null | grep -v "Example" | grep -v "\.git"; then
        record_issue "Found generic content that belongs in Tier 1: '$pattern'"
        echo "  ❌ Generic content detected: '$pattern'"
        echo "     Should link to Tier 1 instead of duplicating"
        SERIOUS_VIOLATIONS=$((SERIOUS_VIOLATIONS + 1))
    fi
done

if [ "$SERIOUS_VIOLATIONS" -gt 0 ]; then
    echo "  ❌ Found $SERIOUS_VIOLATIONS generic content violation(s)"
    EXIT_CODE=2  # Serious violation
elif [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ No generic content duplication detected"
fi
echo ""

# 4. Check domain concepts are component-specific
echo "📋 [4/10] Checking domain concepts are component-specific..."
if [ -d "$AGENTIC_DIR/domain" ]; then
    # Tier 1 concepts that shouldn't be in Tier 2 (top-level)
    TIER1_CONCEPTS=(
        "Pod"
        "Node"
        "Service"
        "Deployment"
        "ClusterOperator"
    )

    # Check for files named after generic concepts
    for concept in "${TIER1_CONCEPTS[@]}"; do
        concept_lower=$(echo "$concept" | tr '[:upper:]' '[:lower:]')
        if [ -f "$AGENTIC_DIR/domain/${concept_lower}.md" ] || [ -f "$AGENTIC_DIR/domain/${concept_lower}s.md" ]; then
            record_issue "Domain has generic K8s/OpenShift concept: $concept (should be in Tier 1)"
            echo "  ❌ Found generic concept: $concept"
        fi
    done

    if [ ${#ISSUES[@]} -eq 0 ]; then
        echo "  ✅ Domain concepts appear component-specific"
    fi
else
    record_warning "No domain/ directory - component may not have documented concepts"
    echo "  ⚠️  No domain/ directory"
fi
echo ""

# 5. Check ADRs are component-specific
echo "📋 [5/10] Checking ADRs are component-specific..."
if [ -d "$AGENTIC_DIR/decisions" ]; then
    # Cross-repo decisions that belong in Tier 1
    TIER1_DECISIONS=(
        "etcd"
        "use.*all.*operator"
        "cvo.*coordinate"
        "operator-sdk"
    )

    for decision in "${TIER1_DECISIONS[@]}"; do
        if grep -ri "$decision" "$AGENTIC_DIR/decisions" 2>/dev/null | grep -v "\.git"; then
            record_issue "Found cross-repo decision: '$decision' (should be in Tier 1 decisions/)"
            echo "  ❌ Cross-repo decision detected: '$decision'"
        fi
    done

    if [ ${#ISSUES[@]} -eq 0 ]; then
        echo "  ✅ ADRs appear component-specific"
    fi
else
    echo "  ℹ️  No decisions/ directory"
fi
echo ""

# 6. Check AGENTS.md links to Tier 1
echo "📋 [6/10] Checking AGENTS.md links to Tier 1..."
if [ -f "$AGENTS_FILE" ]; then
    if ! grep -q "github.com/openshift/enhancements.*agentic" "$AGENTS_FILE"; then
        record_issue "AGENTS.md doesn't prominently link to Tier 1"
        echo "  ❌ Missing Tier 1 link in AGENTS.md"
    else
        echo "  ✅ AGENTS.md links to Tier 1"
    fi
fi
echo ""

# 7. Check internal links
echo "📋 [7/10] Checking internal links..."
if [ -d "$AGENTIC_DIR" ]; then
    cd "$AGENTIC_DIR"

    while IFS= read -r file; do
        if [ -f "$file" ]; then
            grep -oh '\[.*\](\.\/[^)]*\.md)' "$file" 2>/dev/null | sed 's/.*(\.\///' | sed 's/).*//' | while read -r link; do
                file_dir=$(dirname "$file")
                if [ ! -f "$file_dir/$link" ] && [ ! -f "$AGENTIC_DIR/$link" ]; then
                    record_issue "Broken link in $file: $link"
                    echo "  ❌ Broken in $(basename $file): $link"
                fi
            done
        fi
    done < <(find "$AGENTIC_DIR" -name "*.md" -type f 2>/dev/null)

    if [ ${#ISSUES[@]} -eq 0 ]; then
        echo "  ✅ All internal links valid"
    fi
fi
echo ""

# 8. Check required Tier 2 structure
echo "📋 [8/10] Checking required Tier 2 directories..."
REQUIRED_TIER2_DIRS=(
    "domain"
    "architecture"
    "decisions"
    "exec-plans/active"
    "exec-plans/completed"
    "references"
)

for dir in "${REQUIRED_TIER2_DIRS[@]}"; do
    if [ ! -d "$AGENTIC_DIR/$dir" ]; then
        record_issue "Missing required directory: $dir"
        echo "  ❌ Missing: $dir"
    fi
done

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ All required directories present"
fi
echo ""

# 9. Check component-specific guide files
echo "📋 [9/10] Checking component-specific guides..."
COMPONENT_UPPER=$(echo "$COMPONENT_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

# Look for component-specific DEVELOPMENT.md and TESTING.md
DEV_GUIDE="${COMPONENT_UPPER}_DEVELOPMENT.md"
TEST_GUIDE="${COMPONENT_UPPER}_TESTING.md"

if [ -f "$AGENTIC_DIR/${COMPONENT_NAME}_DEVELOPMENT.md" ] || [ -f "$AGENTIC_DIR/$DEV_GUIDE" ]; then
    echo "  ✅ Component development guide exists"
else
    record_warning "No ${COMPONENT_NAME}_DEVELOPMENT.md (recommended for Tier 2)"
    echo "  ⚠️  No component development guide"
fi

if [ -f "$AGENTIC_DIR/${COMPONENT_NAME}_TESTING.md" ] || [ -f "$AGENTIC_DIR/$TEST_GUIDE" ]; then
    echo "  ✅ Component testing guide exists"
else
    record_warning "No ${COMPONENT_NAME}_TESTING.md (recommended for Tier 2)"
    echo "  ⚠️  No component testing guide"
fi
echo ""

# 10. Calculate documentation size (should be ~60% smaller than single-tier)
echo "📋 [10/10] Checking documentation size..."
if [ -d "$AGENTIC_DIR" ]; then
    TOTAL_LINES=$(find "$AGENTIC_DIR" -name "*.md" -type f -exec wc -l {} + | tail -1 | awk '{print $1}')
    TOTAL_FILES=$(find "$AGENTIC_DIR" -name "*.md" -type f | wc -l)

    echo "  ℹ️  Total: $TOTAL_FILES files, $TOTAL_LINES lines"

    # Warn if suspiciously large (single-tier MCO was 6000 lines, Tier 2 should be ~2500)
    if [ "$TOTAL_LINES" -gt 4000 ]; then
        record_warning "Documentation is $TOTAL_LINES lines (seems large for Tier 2 lean)"
        echo "  ⚠️  Documentation seems large - may contain generic content"
    fi
fi
echo ""

# Summary
echo "=================================================="
if [ "$EXIT_CODE" -eq 2 ]; then
    echo "❌ CRITICAL: Tier 1 content detected in Tier 2!"
    echo ""
    echo "This is a serious violation. Tier 2 should:"
    echo "  - Link to Tier 1 for generic patterns"
    echo "  - Contain ONLY component-specific content"
    echo ""
    echo "Issues:"
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue"
    done
    exit 2
elif [ ${#ISSUES[@]} -eq 0 ]; then
    echo "✅ Tier 2 lean validation PASSED!"
    echo ""
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo "Warnings:"
        for warning in "${WARNINGS[@]}"; do
            echo "  ⚠️  $warning"
        done
        echo ""
    fi
    echo "The component repository meets Tier 2 lean requirements."
    exit 0
else
    echo "❌ Tier 2 validation FAILED with ${#ISSUES[@]} issue(s):"
    echo ""
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue"
    done
    echo ""
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        echo "Warnings:"
        for warning in "${WARNINGS[@]}"; do
            echo "  ⚠️  $warning"
        done
        echo ""
    fi
    echo "Fix these issues and re-run validation."
    exit 1
fi
