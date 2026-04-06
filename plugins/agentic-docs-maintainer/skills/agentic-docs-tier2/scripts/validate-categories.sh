#!/bin/bash
# Category-based validation for Tier 2 agentic documentation (Component Repos)
# FLEXIBLE: Checks categories have content, not exact file lists
# STRICT (--strict): Enforces minimum content requirements (≥4 domain concepts, ≥3 ADRs)
#
# Used by: Skills during generation (SKILL.md Phase 7)
# Purpose: Flexible validation that adapts to different component needs
# Approach: Checks categories have min files, warns on Tier 1 integration (dev mode)
# Compare to: validate.sh (comprehensive strict validation for commands)
#
# Usage:
#   validate-categories.sh <repo-path>           # Flexible mode (warns)
#   validate-categories.sh <repo-path> --strict  # Strict mode (fails on minimums)

set -euo pipefail

# Parse arguments
REPO_PATH="${1:-.}"
STRICT_MODE=false

# Check for --strict flag in any position
for arg in "$@"; do
    if [[ "$arg" == "--strict" ]]; then
        STRICT_MODE=true
    fi
done

AGENTIC_DIR="$REPO_PATH/agentic"
COMPONENT_NAME=$(basename "$(realpath "$REPO_PATH")")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

if [ "$STRICT_MODE" = true ]; then
    echo "🔍 Tier 2 Category-Based Validation (STRICT MODE)"
    echo "=================================================="
else
    echo "🔍 Tier 2 Category-Based Validation (Flexible)"
    echo "=============================================="
    echo "ℹ️  Run with --strict to enforce minimums"
fi
echo "Component: $COMPONENT_NAME"
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
    "domain:1:Component domain concepts"
    "architecture:1:Component architecture"
    "decisions:1:Component ADRs"
    "references:1:References (including Tier 1 links)"
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

# 2. Check entry point exists
echo "📋 [2/5] Checking entry point..."
echo ""

if [ -f "$AGENTIC_DIR/AGENTS.md" ]; then
    lines=$(wc -l < "$AGENTIC_DIR/AGENTS.md")
    echo "  ✅ AGENTS.md exists ($lines lines)"

    if [ "$lines" -lt 40 ]; then
        record_warning "AGENTS.md is short ($lines lines, recommended: 80-150)"
        echo "  ⚠️  AGENTS.md: $lines lines (recommended: 80-150)"
    elif [ "$lines" -gt 120 ]; then
        record_warning "AGENTS.md is long ($lines lines, recommended: 80-150, keep lean)"
        echo "  ⚠️  AGENTS.md: $lines lines (recommended: 80-150, keep lean)"
    fi
elif [ -f "$AGENTIC_DIR/${COMPONENT_NAME}_AGENTS.md" ]; then
    echo "  ✅ ${COMPONENT_NAME}_AGENTS.md exists"
else
    record_issue "Missing entry point: AGENTS.md or ${COMPONENT_NAME}_AGENTS.md"
    echo "  ❌ Missing: AGENTS.md"
fi

echo ""

# 3. Check for Tier 1 integration (development mode: warning only)
echo "📋 [3/5] Checking Tier 1 integration..."
echo ""

if [ -f "$AGENTIC_DIR/references/ecosystem.md" ]; then
    echo "  ✅ references/ecosystem.md exists"

    # Check if it references Tier 1
    if grep -q "enhancements/agentic\|OPENSHIFT_AGENTS\|Tier 1" "$AGENTIC_DIR/references/ecosystem.md" 2>/dev/null; then
        echo "  ✅ Found references to Tier 1 ecosystem hub"
    else
        record_warning "references/ecosystem.md exists but doesn't reference Tier 1"
        echo "  ⚠️  No references to Tier 1 found - should link to ecosystem hub"
    fi
else
    record_warning "Missing references/ecosystem.md - recommended for Tier 1 integration (development mode)"
    echo "  ⚠️  Missing: references/ecosystem.md (recommended for Tier 1 integration)"
fi

echo ""

# 3.5. STRICT MODE: Enforce minimum content requirements
if [ "$STRICT_MODE" = true ]; then
    echo "📋 [3.5/6] STRICT: Checking minimum content requirements..."
    echo ""

    # Minimum requirements for non-trivial components
    DOMAIN_MIN=4
    ADR_MIN=3

    # Count domain concepts (exclude index.md)
    domain_count=$(find "$AGENTIC_DIR/domain" -name "*.md" -type f ! -name "index.md" ! -name "glossary.md" 2>/dev/null | wc -l || echo 0)

    # Count ADRs (only adr-*.md files)
    adr_count=$(find "$AGENTIC_DIR/decisions" -name "adr-*.md" -type f 2>/dev/null | wc -l || echo 0)

    echo "  Domain Concepts: $domain_count (minimum: $DOMAIN_MIN for non-trivial components)"
    if [ "$domain_count" -lt "$DOMAIN_MIN" ]; then
        record_issue "Only $domain_count domain concepts found (minimum: $DOMAIN_MIN)"
        echo "  ❌ Insufficient domain concepts"
        echo "     → See SKILL.md Phase 2.5 for discovery checklist"
        echo "     → Categories to check:"
        echo "       - API Resources (CRDs, types)"
        echo "       - Technologies (tools/platforms component uses)"
        echo "       - Data Formats (config formats, schemas)"
        echo "       - Abstractions (component-specific concepts)"
    else
        echo "  ✅ Domain concepts: $domain_count ≥ $DOMAIN_MIN"
    fi

    echo ""
    echo "  ADRs: $adr_count (minimum: $ADR_MIN for non-trivial components)"
    if [ "$adr_count" -lt "$ADR_MIN" ]; then
        record_issue "Only $adr_count ADRs found (minimum: $ADR_MIN)"
        echo "  ❌ Insufficient ADRs"
        echo "     → See SKILL.md Phase 5.2 for ADR extraction from /docs/"
        echo "     → Categories to check:"
        echo "       - Architecture decisions (why this component structure?)"
        echo "       - Technology choices (why this tool/format?)"
        echo "       - Pattern/implementation decisions (why this approach?)"
        echo "     → Mine existing design docs: ls docs/*Design.md docs/*.md"
    else
        echo "  ✅ ADRs: $adr_count ≥ $ADR_MIN"
    fi

    echo ""

    # Check that component-specific guides exist
    if [ ! -f "$AGENTIC_DIR"/*_DEVELOPMENT.md ] 2>/dev/null; then
        record_issue "Missing component development guide ([COMPONENT]_DEVELOPMENT.md)"
        echo "  ❌ Missing: Development guide"
        echo "     → See SKILL.md Phase 5 for template"
    fi

    if [ ! -f "$AGENTIC_DIR"/*_TESTING.md ] 2>/dev/null; then
        record_issue "Missing component testing guide ([COMPONENT]_TESTING.md)"
        echo "  ❌ Missing: Testing guide"
        echo "     → See SKILL.md Phase 5 for template"
    fi

    echo ""
fi

# 4. Suggest commonly useful files (non-prescriptive)
echo "📋 [4/6] Checking commonly recommended files..."
echo ""

SUGGESTED=(
    "exec-plans/template.md:Exec plan template"
    "decisions/adr-template.md:ADR template"
    "architecture/index.md:Architecture overview"
    "${COMPONENT_NAME}_DEVELOPMENT.md:Development guide"
    "${COMPONENT_NAME}_TESTING.md:Testing guide"
)

missing_suggestions=()
for suggestion in "${SUGGESTED[@]}"; do
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

# 5. Warn about generic content (should be in Tier 1)
echo "📋 [5/6] Checking for Tier 1 content in Tier 2..."
echo ""

GENERIC_PATTERNS=(
    "operator patterns"
    "testing pyramid"
    "Kubernetes fundamentals"
)

found_generic=()
for pattern in "${GENERIC_PATTERNS[@]}"; do
    if grep -riq "$pattern" "$AGENTIC_DIR" --exclude-dir=references 2>/dev/null; then
        found_generic+=("$pattern")
    fi
done

if [ ${#found_generic[@]} -gt 0 ]; then
    echo "  ⚠️  Found generic content (consider linking to Tier 1 instead):"
    for pattern in "${found_generic[@]}"; do
        record_warning "Found '$pattern' - consider linking to Tier 1"
        echo "    - $pattern"
    done
else
    echo "  ✅ No generic content detected"
fi

echo ""

# 6. Final Summary
echo "📋 [6/6] Final Summary"
echo ""
echo "=================================================="
echo ""

if [ ${#ISSUES[@]} -eq 0 ] && [ ${#WARNINGS[@]} -eq 0 ]; then
    echo "✅ Tier 2 Validation PASSED (no issues)"
    echo ""
    if [ "$STRICT_MODE" = true ]; then
        echo "🎉 All strict requirements met!"
        echo "   - Domain concepts ≥4 ✓"
        echo "   - ADRs ≥3 ✓"
        echo "   - Component guides present ✓"
        echo "   - Tier 1 integration ✓"
    fi
    echo ""
    exit 0
fi

if [ ${#ISSUES[@]} -gt 0 ]; then
    echo "❌ Tier 2 Validation FAILED with ${#ISSUES[@]} issue(s):"
    echo ""
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue"
    done
    echo ""

    if [ "$STRICT_MODE" = true ]; then
        echo "💡 To fix strict mode failures:"
        echo "   1. Review SKILL.md Phase 2.5 (Domain Discovery Checklist)"
        echo "   2. Review SKILL.md Phase 5.2 (ADR Extraction Checklist)"
        echo "   3. Use troubleshooting section (lines 2173-2407)"
        echo "   4. Check comparison doc: agentic/.comparison-with-previous.md"
        echo ""
    fi
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "⚠️  ${#WARNINGS[@]} warning(s) (suggestions, not failures):"
    echo ""
    for warning in "${WARNINGS[@]}"; do
        echo "  - $warning"
    done
    echo ""
fi

if [ "$STRICT_MODE" = false ] && [ ${#ISSUES[@]} -eq 0 ] && [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "ℹ️  To enforce minimum requirements, run:"
    echo "   bash validate-categories.sh \"$REPO_PATH\" --strict"
    echo ""
fi

exit $EXIT_CODE
