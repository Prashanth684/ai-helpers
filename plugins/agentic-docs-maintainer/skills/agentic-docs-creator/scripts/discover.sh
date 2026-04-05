#!/bin/bash
# Discovery script - learns from existing agentic/ structure
# Non-prescriptive: adapts to what exists, suggests improvements

set -euo pipefail

REPO_PATH="${1:-.}"
AGENTIC_PATH="$REPO_PATH/agentic"

echo "🔍 Discovery Phase"
echo "=================="
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

# 2. Count files by category
for category in platform/operator-patterns platform/openshift-specifics \
                practices/testing practices/security practices/reliability practices/development \
                domain/kubernetes domain/openshift \
                decisions workflows references; do

    if [ -d "$AGENTIC_PATH/$category" ]; then
        count=$(find "$AGENTIC_PATH/$category" -name "*.md" -type f | wc -l)
        echo "  📁 $category: $count files"
    else
        echo "  ❌ $category: missing"
    fi
done

echo ""
echo "📝 Learning naming conventions..."
echo ""

# 3. Detect naming patterns (not prescriptive, just informative)
if [ -f "$AGENTIC_PATH/practices/testing/pyramid.md" ]; then
    echo "  ✓ Uses 'pyramid.md' (not testing-pyramid.md)"
elif [ -f "$AGENTIC_PATH/practices/testing/testing-pyramid.md" ]; then
    echo "  ℹ️  Uses 'testing-pyramid.md'"
fi

if [ -f "$AGENTIC_PATH/domain/kubernetes/crds.md" ]; then
    echo "  ✓ Uses 'crds.md' (not crd.md)"
elif [ -f "$AGENTIC_PATH/domain/kubernetes/crd.md" ]; then
    echo "  ℹ️  Uses 'crd.md'"
fi

if [ -f "$AGENTIC_PATH/platform/operator-patterns/rbac-patterns.md" ]; then
    echo "  ✓ Uses 'rbac-patterns.md'"
elif [ -f "$AGENTIC_PATH/platform/operator-patterns/rbac.md" ]; then
    echo "  ℹ️  Uses 'rbac.md'"
fi

echo ""
echo "🔗 Checking cross-references..."
echo ""

# 4. Check for official docs (suggest cross-refs)
if [ -d "$REPO_PATH/dev-guide" ]; then
    echo "  ✅ dev-guide/ exists - recommend cross-referencing"

    # Check if cross-refs exist
    if grep -rq "dev-guide/" "$AGENTIC_PATH" 2>/dev/null; then
        echo "  ✓ Found references to dev-guide/"
    else
        echo "  ⚠️  No references to dev-guide/ found - consider adding"
    fi
fi

if [ -d "$REPO_PATH/guidelines" ]; then
    echo "  ✅ guidelines/ exists"
fi

echo ""
echo "💡 Suggestions (not requirements):"
echo ""

# 5. Suggest commonly useful files (non-prescriptive)
suggestions=()

[ ! -f "$AGENTIC_PATH/platform/operator-patterns/must-gather.md" ] && suggestions+=("must-gather.md - diagnostics collection")
[ ! -f "$AGENTIC_PATH/platform/operator-patterns/owner-references.md" ] && suggestions+=("owner-references.md - garbage collection")
[ ! -f "$AGENTIC_PATH/practices/security/secrets-management.md" ] && suggestions+=("secrets-management.md - security best practices")
[ ! -f "$AGENTIC_PATH/practices/reliability/alerting.md" ] && suggestions+=("alerting.md - observability")
[ ! -f "$AGENTIC_PATH/practices/testing/test-flake-policy.md" ] && suggestions+=("test-flake-policy.md - operational policy")
[ ! -f "$AGENTIC_PATH/ENHANCEMENT_ROADMAP.md" ] && suggestions+=("ENHANCEMENT_ROADMAP.md - status tracking")

if [ ${#suggestions[@]} -gt 0 ]; then
    echo "  Common files that could be added:"
    for suggestion in "${suggestions[@]}"; do
        echo "    - $suggestion"
    done
else
    echo "  ✓ All commonly recommended files present"
fi

echo ""
echo "=================================================="
echo "Discovery complete. Mode: $MODE"
echo ""
