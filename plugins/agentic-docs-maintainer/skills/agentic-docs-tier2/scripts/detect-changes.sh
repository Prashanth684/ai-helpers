#!/bin/bash
# Detect changes in component repository that require documentation updates
# Usage: ./detect-changes.sh [path-to-component-repo]

set -e

REPO_PATH="${1:-.}"
COMPONENT_NAME="$(basename $(realpath $REPO_PATH))"
AGENTIC_DIR="$REPO_PATH/agentic"

echo "🔍 Detecting changes requiring documentation updates..."
echo "Repository: $REPO_PATH"
echo "Component: $COMPONENT_NAME"
echo ""

# Track if any changes detected
CHANGES_DETECTED=0

# 1. Check for new CRDs/API types
echo "📋 [1/5] Checking for new CRDs/API types..."
if [ -d "$AGENTIC_DIR/domain" ]; then
    NEW_CRDS=$(find "$REPO_PATH/vendor/github.com/openshift/api" -name "types.go" \
        -newer "$AGENTIC_DIR/domain/index.md" 2>/dev/null | head -10 || true)

    if [ -n "$NEW_CRDS" ]; then
        echo "  📝 New CRDs detected:"
        echo "$NEW_CRDS" | while read crd; do
            dir=$(dirname "$crd")
            api_group=$(basename "$dir")
            echo "    - $api_group"
        done
        echo ""
        echo "  → Action needed: Create domain docs for new types"
        CHANGES_DETECTED=1
    else
        echo "  ✅ No new CRDs detected"
    fi
else
    echo "  ℹ️  No domain/ directory - skipping CRD check"
fi
echo ""

# 2. Check for code structure changes
echo "📋 [2/5] Checking for code structure changes..."
cd "$REPO_PATH"

# Check for significant pkg/ or cmd/ changes in last 10 commits
RECENT_CODE_CHANGES=$(git diff HEAD~10..HEAD --stat pkg/ cmd/ 2>/dev/null || true)

if [ -n "$RECENT_CODE_CHANGES" ]; then
    # Count changed files
    CHANGED_FILES=$(echo "$RECENT_CODE_CHANGES" | grep -c "\.go" || echo 0)

    if [ "$CHANGED_FILES" -gt 10 ]; then
        echo "  📝 Significant code structure changes detected ($CHANGED_FILES files changed)"
        echo "  Top changed areas:"
        echo "$RECENT_CODE_CHANGES" | head -8 | sed 's/^/    /'
        echo ""
        echo "  → Action needed: Review architecture docs for updates"
        CHANGES_DETECTED=1
    else
        echo "  ✅ Minor code changes ($CHANGED_FILES files)"
    fi
else
    echo "  ✅ No recent code structure changes"
fi
echo ""

# 3. Check for new controllers/packages
echo "📋 [3/5] Checking for new controllers/packages..."
if [ -d "$AGENTIC_DIR/architecture" ]; then
    # Find new controller directories
    NEW_CONTROLLERS=$(find "$REPO_PATH/pkg/controller" -type d -maxdepth 1 \
        -newer "$AGENTIC_DIR/architecture/index.md" 2>/dev/null | grep -v "^$REPO_PATH/pkg/controller$" || true)

    if [ -n "$NEW_CONTROLLERS" ]; then
        echo "  📝 New controllers detected:"
        echo "$NEW_CONTROLLERS" | while read ctrl; do
            echo "    - $(basename $ctrl)"
        done
        echo ""
        echo "  → Action needed: Document new controllers in architecture/"
        CHANGES_DETECTED=1
    else
        echo "  ✅ No new controllers detected"
    fi
else
    echo "  ℹ️  No architecture/ directory - skipping controller check"
fi
echo ""

# 4. Check for new enhancements
echo "📋 [4/5] Checking for new enhancements..."
if [ -d "$AGENTIC_DIR/references" ]; then
    # Look for enhancements directory (common locations)
    ENHANCEMENT_DIRS=(
        "../enhancements/enhancements"
        "../../enhancements/enhancements"
        "../../../enhancements/enhancements"
    )

    for enh_dir in "${ENHANCEMENT_DIRS[@]}"; do
        if [ -d "$enh_dir" ]; then
            RECENT_ENHANCEMENTS=$(find "$enh_dir" -name "*${COMPONENT_NAME}*" -type f \
                -newer "$AGENTIC_DIR/references/ecosystem.md" 2>/dev/null | head -5 || true)

            if [ -n "$RECENT_ENHANCEMENTS" ]; then
                echo "  📝 New enhancements detected affecting this component:"
                echo "$RECENT_ENHANCEMENTS" | while read enh; do
                    echo "    - $(basename $enh)"
                done
                echo ""
                echo "  → Action needed: Create exec-plans for new enhancements"
                CHANGES_DETECTED=1
                break
            fi
        fi
    done

    if [ "$CHANGES_DETECTED" -eq 0 ]; then
        echo "  ✅ No new enhancements detected"
    fi
else
    echo "  ℹ️  No references/ directory - skipping enhancement check"
fi
echo ""

# 5. Check for architectural decisions in git log
echo "📋 [5/5] Checking for architectural decisions..."
RECENT_DECISIONS=$(git log --since="30 days ago" \
    --grep="design\|decision\|alternative\|architecture" --oneline 2>/dev/null | head -10 || true)

if [ -n "$RECENT_DECISIONS" ]; then
    DECISION_COUNT=$(echo "$RECENT_DECISIONS" | wc -l)
    echo "  📝 Recent architectural commits detected ($DECISION_COUNT commits):"
    echo "$RECENT_DECISIONS" | head -5 | sed 's/^/    /'

    if [ "$DECISION_COUNT" -gt 5 ]; then
        echo "    ..."
    fi
    echo ""
    echo "  → Action needed: Review for potential ADRs in decisions/"
    CHANGES_DETECTED=1
else
    echo "  ✅ No recent architectural decisions"
fi
echo ""

# Bonus: Check if Tier 1 has been updated
echo "📋 [Bonus] Checking Tier 1 updates..."
TIER1_URL="https://api.github.com/repos/openshift/enhancements/commits?path=agentic&since=$(date -d '30 days ago' --iso-8601 2>/dev/null || date -v-30d +%Y-%m-%d)"

if command -v curl >/dev/null 2>&1; then
    TIER1_COMMITS=$(curl -s "$TIER1_URL" 2>/dev/null | grep -c '"sha"' || echo 0)

    if [ "$TIER1_COMMITS" -gt 0 ]; then
        echo "  📝 Tier 1 has been updated ($TIER1_COMMITS commits in last 30 days)"
        echo "  → Action needed: Verify ecosystem.md links are current"
        CHANGES_DETECTED=1
    else
        echo "  ✅ No recent Tier 1 updates"
    fi
else
    echo "  ℹ️  curl not available - skipping Tier 1 check"
fi
echo ""

# Summary
echo "=================================================="
if [ "$CHANGES_DETECTED" -eq 1 ]; then
    echo "📝 Changes detected requiring documentation updates"
    echo ""
    echo "Recommended actions:"
    echo "  1. Review detected changes above"
    echo "  2. Update relevant documentation:"
    echo "     - New CRDs → agentic/domain/"
    echo "     - Code changes → agentic/architecture/"
    echo "     - New controllers → agentic/architecture/components.md"
    echo "     - Enhancements → agentic/exec-plans/active/"
    echo "     - Decisions → agentic/decisions/"
    echo "  3. Run validate.sh to verify Tier 2 compliance"
    echo ""
    echo "For autonomous updates, use maintenance-loop.sh"
    exit 1
else
    echo "✅ No changes detected"
    echo ""
    echo "Documentation appears current with repository state."
    exit 0
fi
