#!/bin/bash
# Discovery script for Tier 2 (component repos) - learns from existing agentic/ structure
# Non-prescriptive: adapts to what exists, suggests improvements

set -euo pipefail

REPO_PATH="${1:-.}"
AGENTIC_PATH="$REPO_PATH/agentic"
COMPONENT_NAME=$(basename "$(realpath "$REPO_PATH")")

echo "🔍 Tier 2 Discovery Phase"
echo "========================="
echo "Component: $COMPONENT_NAME"
echo ""

# 1. Check if agentic/ exists
if [ -d "$AGENTIC_PATH" ]; then
    echo "✅ agentic/ directory exists at: $AGENTIC_PATH"
    MODE="update"
else
    echo "➕ agentic/ directory not found - will create from scratch"
    MODE="create"
    exit 0
fi

echo ""
echo "📊 Analyzing existing structure..."
echo ""

# 2. Count files by category (component-specific)
for category in domain architecture decisions exec-plans/active exec-plans/completed references; do
    if [ -d "$AGENTIC_PATH/$category" ]; then
        count=$(find "$AGENTIC_PATH/$category" -name "*.md" -type f 2>/dev/null | wc -l)
        echo "  📁 $category: $count files"
    else
        echo "  ❌ $category: missing"
    fi
done

echo ""
echo "📝 Checking entry points..."
echo ""

# 3. Check for entry point
if [ -f "$AGENTIC_PATH/AGENTS.md" ]; then
    lines=$(wc -l < "$AGENTIC_PATH/AGENTS.md")
    echo "  ✅ AGENTS.md exists ($lines lines)"

    if [ "$lines" -lt 40 ]; then
        echo "  ⚠️  AGENTS.md is quite short ($lines lines, recommended: 80-150)"
    elif [ "$lines" -gt 120 ]; then
        echo "  ⚠️  AGENTS.md is long ($lines lines, recommended: 80-150, keep lean)"
    fi
elif [ -f "$AGENTIC_PATH/${COMPONENT_NAME}_AGENTS.md" ]; then
    echo "  ✅ ${COMPONENT_NAME}_AGENTS.md exists"
else
    echo "  ❌ Missing AGENTS.md or ${COMPONENT_NAME}_AGENTS.md"
fi

echo ""
echo "🔗 Checking Tier 1 cross-references..."
echo ""

# 4. Check for Tier 1 integration (development mode: warnings only)
if [ -f "$AGENTIC_PATH/references/ecosystem.md" ]; then
    echo "  ✅ references/ecosystem.md exists"

    # Check if it references Tier 1
    if grep -q "enhancements/agentic\|OPENSHIFT_AGENTS\|Tier 1" "$AGENTIC_PATH/references/ecosystem.md" 2>/dev/null; then
        echo "  ✅ Found references to Tier 1"
    else
        echo "  ⚠️  No references to Tier 1 found - should link to ecosystem hub"
    fi
else
    echo "  ⚠️  Missing references/ecosystem.md - recommended for Tier 1 integration (development mode)"
fi

echo ""
echo "💡 Suggestions (not requirements):"
echo ""

# 5. Suggest commonly useful files for components
suggestions=()

[ ! -f "$AGENTIC_PATH/AGENTS.md" ] && suggestions+=("AGENTS.md - main entry point")
[ ! -f "$AGENTIC_PATH/references/ecosystem.md" ] && suggestions+=("references/ecosystem.md - Tier 1 links (CRITICAL)")
[ ! -f "$AGENTIC_PATH/exec-plans/template.md" ] && suggestions+=("exec-plans/template.md - exec plan template")
[ ! -f "$AGENTIC_PATH/decisions/adr-template.md" ] && suggestions+=("decisions/adr-template.md - ADR template")
[ ! -f "$AGENTIC_PATH/architecture/index.md" ] && suggestions+=("architecture/index.md - architecture overview")
[ ! -f "$AGENTIC_PATH/${COMPONENT_NAME}_DEVELOPMENT.md" ] && suggestions+=("${COMPONENT_NAME}_DEVELOPMENT.md - development guide")
[ ! -f "$AGENTIC_PATH/${COMPONENT_NAME}_TESTING.md" ] && suggestions+=("${COMPONENT_NAME}_TESTING.md - testing guide")

if [ ${#suggestions[@]} -gt 0 ]; then
    echo "  Common files that could be added:"
    for suggestion in "${suggestions[@]}"; do
        echo "    - $suggestion"
    done
else
    echo "  ✓ All commonly recommended files present"
fi

echo ""
echo "⚠️  Checking for Tier 1 content (should not be in Tier 2)..."
echo ""

# 6. Warn about generic content that should be in Tier 1
GENERIC_PATTERNS=(
    "operator patterns"
    "testing pyramid"
    "Kubernetes fundamentals"
    "status conditions"
    "controller-runtime"
)

found_generic=()
for pattern in "${GENERIC_PATTERNS[@]}"; do
    if grep -riq "$pattern" "$AGENTIC_PATH" --exclude-dir=references 2>/dev/null; then
        found_generic+=("$pattern")
    fi
done

if [ ${#found_generic[@]} -gt 0 ]; then
    echo "  ⚠️  Found generic content that might belong in Tier 1:"
    for pattern in "${found_generic[@]}"; do
        echo "    - $pattern (consider linking to Tier 1 instead)"
    done
else
    echo "  ✓ No obvious generic content detected"
fi

echo ""
echo "=================================================="
echo "Discovery complete. Mode: $MODE"
echo ""
