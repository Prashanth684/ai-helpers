#!/bin/bash
# Validate Tier 2 lean documentation compliance - COMPREHENSIVE
# Exit 0 if compliant, 1 if issues, 2 if contains Tier 1 content
#
# NOTE: Two validation approaches available:
# - validate.sh (this script): Comprehensive strict validation
#   Used by: Commands (/agentic-docs-maintainer:tier2-component --verify)
#   Purpose: Full compliance check with all rules
#
# - validate-categories.sh: Flexible category-based validation
#   Used by: Skills during generation (SKILL.md Phase 7)
#   Purpose: Check categories have content, warn on suggestions
#   Advantage: Adapts to different file naming conventions

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

# 1. Check AGENTS.md exists and ≤100 lines (Tier 2 lean, not 150 like Tier 1)
echo "📋 [1/11] Checking AGENTS.md size..."
if [ ! -f "$AGENTS_FILE" ]; then
    record_issue "Missing AGENTS.md at repository root"
    echo "  ❌ Missing AGENTS.md"
else
    LINES=$(wc -l < "$AGENTS_FILE")
    if [ "$LINES" -gt 100 ]; then
        record_issue "AGENTS.md is $LINES lines (must be ≤100 for Tier 2 lean)"
        echo "  ❌ AGENTS.md is $LINES lines (must be ≤100 for Tier 2, not 150 like Tier 1)"
    else
        echo "  ✅ AGENTS.md exists ($LINES lines ≤100)"
    fi
fi
echo ""

# 1.5. Check AGENTS.md contains knowledge graph (REQUIRED for Tier 2)
echo "📋 [2/11] Checking AGENTS.md knowledge graph..."
if [ -f "$AGENTS_FILE" ]; then
    # Check for knowledge graph section
    if ! grep -qi "knowledge graph" "$AGENTS_FILE"; then
        record_issue "AGENTS.md missing knowledge graph section (REQUIRED for Tier 2)"
        echo "  ❌ No knowledge graph section found"
        echo "     Required: ASCII diagram showing documentation relationships"
        echo "     Template: SKILL.md lines 962-1040"
    else
        # Check for ASCII diagram (box drawing characters or simple ASCII art)
        if grep -qE "┌|┐|└|┘|│|─|▼|→|\+---|\|" "$AGENTS_FILE"; then
            echo "  ✅ Knowledge graph with ASCII diagram found"
        else
            record_issue "AGENTS.md has 'Knowledge Graph' heading but missing ASCII diagram"
            echo "  ❌ Knowledge graph section exists but missing ASCII diagram"
            echo "     Required: Visual diagram showing doc structure and relationships"
            echo "     Template: SKILL.md lines 962-1040"
        fi
    fi
else
    echo "  ⏭️  Skipped (AGENTS.md doesn't exist)"
fi
echo ""

# 1.6. Check AGENTS.md mentions exec-plans/ (REQUIRED for Tier 2)
echo "📋 [2.5/11] Checking AGENTS.md mentions exec-plans..."
if [ -f "$AGENTS_FILE" ]; then
    if ! grep -qi "exec-plan" "$AGENTS_FILE"; then
        record_issue "AGENTS.md doesn't mention exec-plans/ (required for feature planning guidance)"
        echo "  ❌ No exec-plans/ mentioned in AGENTS.md"
        echo "     Required: Show exec-plans/ in directory structure or workflow"
        echo "     Template: SKILL.md lines 1018-1033"
    else
        echo "  ✅ AGENTS.md mentions exec-plans/"
    fi
else
    echo "  ⏭️  Skipped (AGENTS.md doesn't exist)"
fi
echo ""

# 3. Check ecosystem.md exists (critical link to Tier 1)
echo "📋 [3/11] Checking ecosystem.md..."
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
echo "📋 [4/11] Checking for generic content duplication..."
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
    # Search for pattern, but exclude legitimate references to Tier 1
    matches=$(grep -rin "$pattern" "$AGENTIC_DIR" 2>/dev/null | \
        grep -v "\.git" | \
        grep -v "Example:" | \
        grep -v "github.com/openshift/enhancements" | \
        grep -v "^[^:]*ecosystem.md:" | \
        grep -v "^[^:]*> \*\*" | \
        grep -v "See.*Tier 1" | \
        grep -v "link to Tier 1" || true)

    if [ -n "$matches" ]; then
        # Check if it's actual content duplication (multi-line explanation)
        # vs just a brief mention/reference
        match_count=$(echo "$matches" | wc -l)

        # If pattern appears multiple times or with substantial text, likely duplication
        if [ "$match_count" -gt 2 ]; then
            record_issue "Found generic content that belongs in Tier 1: '$pattern' ($match_count occurrences)"
            echo "  ❌ Generic content detected: '$pattern' ($match_count times)"
            echo "     Should link to Tier 1 instead of duplicating"
            SERIOUS_VIOLATIONS=$((SERIOUS_VIOLATIONS + 1))
        fi
    fi
done

if [ "$SERIOUS_VIOLATIONS" -gt 0 ]; then
    echo "  ❌ Found $SERIOUS_VIOLATIONS generic content violation(s)"
    EXIT_CODE=2  # Serious violation
else
    echo "  ✅ No generic content duplication detected"
fi
echo ""

# 4. Check domain concepts are component-specific
echo "📋 [5/11] Checking domain concepts are component-specific..."
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
echo "📋 [6/11] Checking ADRs are component-specific..."
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

    # Check if decisions/ has content
    ADR_COUNT=$(find "$AGENTIC_DIR/decisions" -name "adr-*.md" 2>/dev/null | wc -l)
    if [ "$ADR_COUNT" -eq 0 ]; then
        record_warning "decisions/ directory is empty - extract component-specific ADRs from design docs (see Phase 5.2)"
        echo "  ⚠️  No ADRs found - consider extracting from /docs/ design documents"
    else
        echo "  ✅ Found $ADR_COUNT component ADR(s)"
    fi

    if [ ${#ISSUES[@]} -eq 0 ]; then
        echo "  ✅ ADRs appear component-specific"
    fi
else
    echo "  ℹ️  No decisions/ directory"
fi
echo ""

# 6. Check AGENTS.md links to Tier 1
echo "📋 [7/11] Checking AGENTS.md links to Tier 1..."
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
echo "📋 [8/11] Checking internal links..."
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
echo "📋 [9/11] Checking required Tier 2 directories..."
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

# Check for exec-plans template
if [ ! -f "$AGENTIC_DIR/exec-plans/template.md" ]; then
    record_warning "Missing exec-plans/template.md (recommended for feature planning)"
    echo "  ⚠️  No exec-plans/template.md - should exist for teams to copy"
else
    echo "  ✅ exec-plans/template.md exists"
fi

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ All required directories present"
fi
echo ""

# 9. Check component-specific guide files
echo "📋 [10/11] Checking component-specific guides..."
COMPONENT_UPPER=$(echo "$COMPONENT_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' '_')

# Look for component-specific DEVELOPMENT.md and TESTING.md
# Accept various naming patterns:
# - machine-config-operator_DEVELOPMENT.md
# - MACHINE_CONFIG_OPERATOR_DEVELOPMENT.md
# - MCO_DEVELOPMENT.md (common abbreviation)
DEV_GUIDE="${COMPONENT_UPPER}_DEVELOPMENT.md"
TEST_GUIDE="${COMPONENT_UPPER}_TESTING.md"

# Extract common abbreviation (e.g., MCO from machine-config-operator)
ABBREV=$(echo "$COMPONENT_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) printf toupper(substr($i,1,1))}')

if [ -f "$AGENTIC_DIR/${COMPONENT_NAME}_DEVELOPMENT.md" ] || \
   [ -f "$AGENTIC_DIR/$DEV_GUIDE" ] || \
   [ -f "$AGENTIC_DIR/${ABBREV}_DEVELOPMENT.md" ]; then
    echo "  ✅ Component development guide exists"
else
    record_warning "No ${COMPONENT_NAME}_DEVELOPMENT.md or ${ABBREV}_DEVELOPMENT.md (recommended for Tier 2)"
    echo "  ⚠️  No component development guide"
fi

if [ -f "$AGENTIC_DIR/${COMPONENT_NAME}_TESTING.md" ] || \
   [ -f "$AGENTIC_DIR/$TEST_GUIDE" ] || \
   [ -f "$AGENTIC_DIR/${ABBREV}_TESTING.md" ]; then
    echo "  ✅ Component testing guide exists"
else
    record_warning "No ${COMPONENT_NAME}_TESTING.md or ${ABBREV}_TESTING.md (recommended for Tier 2)"
    echo "  ⚠️  No component testing guide"
fi
echo ""

# 10. Quality assessment (documentation size, navigation, exec-plans)
echo "📋 [11/11] Quality assessment..."
if [ -d "$AGENTIC_DIR" ]; then
    # Calculate documentation size (should be ~60% smaller than single-tier)
    TOTAL_LINES=$(find "$AGENTIC_DIR" -name "*.md" -type f -exec wc -l {} + | tail -1 | awk '{print $1}')
    TOTAL_FILES=$(find "$AGENTIC_DIR" -name "*.md" -type f | wc -l)

    echo "  ℹ️  Documentation size: $TOTAL_FILES files, $TOTAL_LINES lines"

    # Warn if suspiciously large (single-tier MCO was 6000 lines, Tier 2 should be ~2500)
    if [ "$TOTAL_LINES" -gt 4000 ]; then
        record_warning "Documentation is $TOTAL_LINES lines (seems large for Tier 2 lean)"
        echo "  ⚠️  Documentation seems large - may contain generic content"
    fi

    # Check AGENTS.md navigation quality
    if [ -f "$AGENTS_FILE" ]; then
        # Count internal links (both ./path and relative path formats)
        INTERNAL_LINKS=$(grep -o '\[.*\](\./' "$AGENTS_FILE" 2>/dev/null | wc -l || echo 0)
        RELATIVE_LINKS=$(grep -o '\[.*\](agentic/' "$AGENTS_FILE" 2>/dev/null | wc -l || echo 0)
        TOTAL_INTERNAL=$((INTERNAL_LINKS + RELATIVE_LINKS))

        TIER1_LINKS=$(grep -o 'github.com/openshift/enhancements.*agentic' "$AGENTS_FILE" 2>/dev/null | wc -l || echo 0)

        if [ "$TOTAL_INTERNAL" -lt 3 ]; then
            echo "  ⚠️  AGENTS.md has few internal links ($TOTAL_INTERNAL) - consider adding more navigation"
        else
            echo "  ℹ️  Navigation: $TOTAL_INTERNAL internal links, $TIER1_LINKS Tier 1 references"
        fi
    fi

    # Check for exec-plans (optional but recommended for active repos)
    ACTIVE_PLANS=$(find "$AGENTIC_DIR/exec-plans/active" -name "*.md" -type f 2>/dev/null | wc -l)
    COMPLETED_PLANS=$(find "$AGENTIC_DIR/exec-plans/completed" -name "*.md" -type f 2>/dev/null | wc -l)

    if [ "$ACTIVE_PLANS" -gt 0 ] || [ "$COMPLETED_PLANS" -gt 0 ]; then
        echo "  ℹ️  exec-plans: $ACTIVE_PLANS active, $COMPLETED_PLANS completed"
    else
        echo "  ℹ️  No exec-plans found (optional - add if tracking active features)"
    fi

    echo "  ✅ Quality assessment complete"
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
