#!/bin/bash
# Pre-flight check before running Tier 2 skill
# Validates environment and provides guidance on what to expect

set -euo pipefail

REPO_PATH="${1:-.}"
COMPONENT_NAME=$(basename "$(realpath "$REPO_PATH")")

echo "🚀 Tier 2 Skill Pre-Flight Check"
echo "================================="
echo "Component: $COMPONENT_NAME"
echo "Repository: $REPO_PATH"
echo ""

EXIT_CODE=0

# Check 1: Is this an OpenShift component?
echo "[1/6] Checking if OpenShift component..."
if [ -f "$REPO_PATH/go.mod" ] && grep -q "github.com/openshift" "$REPO_PATH/go.mod" 2>/dev/null; then
    echo "  ✅ OpenShift component detected"
else
    echo "  ❌ Not an OpenShift component (no openshift dependencies in go.mod)"
    echo "     → Use full agentic-docs-maintainer instead of Tier 2"
    echo "     → Tier 2 is for OpenShift ecosystem repos only"
    EXIT_CODE=1
fi
echo ""

# Check 2: Find design docs for ADR extraction
echo "[2/6] Finding design docs for ADR extraction..."
if [ -d "$REPO_PATH/docs" ]; then
    DESIGN_DOCS=$(find "$REPO_PATH/docs" -name "*.md" -type f 2>/dev/null | wc -l)
    echo "  Found $DESIGN_DOCS markdown files in /docs/"

    if [ "$DESIGN_DOCS" -ge 5 ]; then
        echo "  ✅ Good amount of design docs - should yield ≥3 ADRs"
    elif [ "$DESIGN_DOCS" -ge 2 ]; then
        echo "  ⚠️  Few design docs - may need to mine git history for ADRs"
        echo "     Try: git log --all --grep=\"design\\|architecture\\|decision\""
    else
        echo "  ⚠️  Very few design docs - ADR extraction may be challenging"
        echo "     Check git history and code comments for architectural decisions"
    fi
else
    echo "  ⚠️  No /docs directory found"
    echo "     ADRs will need to be extracted from git history and code"
fi
echo ""

# Check 3: Find CRDs for domain concepts
echo "[3/6] Finding CRDs for domain concepts..."
if [ -d "$REPO_PATH/vendor/github.com/openshift/api" ]; then
    CRD_COUNT=$(find "$REPO_PATH/vendor/github.com/openshift/api" -name "*_types.go" 2>/dev/null | wc -l)
    echo "  Found $CRD_COUNT potential CRD type files"

    if [ "$CRD_COUNT" -ge 3 ]; then
        echo "  ✅ Multiple CRDs found - good start for domain concepts"
    elif [ "$CRD_COUNT" -gt 0 ]; then
        echo "  ⚠️  Few CRDs found - also check for:"
        echo "     - Technologies component uses (rpm-ostree, OVN, etc.)"
        echo "     - Data formats (Ignition, YAML schemas, etc.)"
        echo "     - Abstractions (rendered config, etc.)"
    else
        echo "  ⚠️  No CRDs found - this component may not manage custom resources"
        echo "     Focus on: technologies, formats, and abstractions"
    fi
else
    echo "  ℹ️  No vendor/github.com/openshift/api - may not have CRDs"
fi
echo ""

# Check 4: Estimate component complexity
echo "[4/6] Estimating component complexity..."
if [ -d "$REPO_PATH/pkg" ]; then
    PKG_COUNT=$(find "$REPO_PATH/pkg" -type d -maxdepth 1 2>/dev/null | wc -l)
    CMD_COUNT=$(find "$REPO_PATH/cmd" -type d -maxdepth 1 2>/dev/null | wc -l)

    echo "  Top-level packages: $PKG_COUNT"
    echo "  Commands: $CMD_COUNT"

    TOTAL_COMPLEXITY=$((PKG_COUNT + CMD_COUNT))

    if [ "$TOTAL_COMPLEXITY" -lt 5 ]; then
        echo "  → Simple component"
        echo "     Expected minimums: 2-3 domain concepts, 1-2 ADRs"
        echo "     Strict mode may not be required"
    elif [ "$TOTAL_COMPLEXITY" -lt 10 ]; then
        echo "  → Moderate complexity component"
        echo "     Target: ≥3 domain concepts, ≥2 ADRs"
    else
        echo "  → Complex component"
        echo "     Target: ≥4 domain concepts, ≥3 ADRs (strict mode recommended)"
    fi
else
    echo "  ⚠️  No pkg/ directory - unusual structure"
fi
echo ""

# Check 5: Check for existing agentic docs
echo "[5/6] Checking for existing documentation..."
if [ -d "$REPO_PATH/agentic" ]; then
    echo "  ⚠️  agentic/ directory already exists"

    if [ -f "$REPO_PATH/agentic/.comparison-with-previous.md" ]; then
        echo "     Looks like Tier 2 docs already created"
        echo "     → Use --update or --maintain to refresh"
    else
        echo "     May be old single-tier docs"
        echo "     → Use --migrate to convert to Tier 2 lean"
    fi

    EXISTING_FILES=$(find "$REPO_PATH/agentic" -name "*.md" -type f 2>/dev/null | wc -l)
    echo "     Existing files: $EXISTING_FILES"
else
    echo "  ✅ No existing agentic/ directory - ready for fresh creation"
fi
echo ""

# Check 6: Time estimate
echo "[6/6] Time estimate for comprehensive Tier 2 docs..."
echo ""
echo "  Estimated time (including checklists):"
echo "    Phase 1: Discovery                    5-10 minutes"
echo "    Phase 2: Structure creation           2-3 minutes (script)"
echo "    Phase 2.5: Domain discovery          20-30 minutes ⭐ CRITICAL"
echo "    Phase 3: AGENTS.md                   10-15 minutes"
echo "    Phase 4: ecosystem.md                 5-10 minutes"
echo "    Phase 5: Component guides            15-20 minutes"
echo "    Phase 5.2: ADR extraction            30-45 minutes ⭐ CRITICAL"
echo "    Phase 7: Validation                   5 minutes"
echo "    ─────────────────────────────────────────────────"
echo "    TOTAL:                              ~90-140 minutes (1.5-2.5 hours)"
echo ""
echo "  ⚡ Critical phases (don't skip):"
echo "     - Phase 2.5: Domain discovery (use checklist!)"
echo "     - Phase 5.2: ADR extraction from /docs/"
echo ""

# Final summary
echo "=================================================="
echo ""

if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Pre-flight check complete - ready to proceed"
    echo ""
    echo "Next steps:"
    echo "  1. Review SKILL.md execution checklist (top of file)"
    echo "  2. Run: create-structure.sh \"$REPO_PATH\""
    echo "  3. Follow Phase 2.5 domain discovery checklist"
    echo "  4. Follow Phase 5.2 ADR extraction checklist"
    echo "  5. Validate with: validate-categories.sh \"$REPO_PATH\" --strict"
    echo ""
    echo "📚 Key sections in SKILL.md:"
    echo "   - Lines 455-672: Phase 2.5 (Domain Discovery)"
    echo "   - Lines 955-1236: Phase 5.2 (ADR Extraction)"
    echo "   - Lines 2173-2407: Troubleshooting"
else
    echo "❌ Pre-flight check failed"
    echo ""
    echo "This repository is not suitable for Tier 2 lean docs."
    echo "Use full agentic-docs-maintainer instead."
fi

exit $EXIT_CODE
