#!/bin/bash
# Create lean Tier 2 directory structure for component repository
# Usage: ./create-structure.sh [path-to-component-repo]

set -e

REPO_PATH="${1:-.}"
COMPONENT_NAME="$(basename $(realpath $REPO_PATH))"
AGENTIC_DIR="$REPO_PATH/agentic"

echo "🏗️  Creating lean Tier 2 directory structure..."
echo "Repository: $REPO_PATH"
echo "Component: $COMPONENT_NAME"
echo ""

# Verify this looks like an OpenShift component repo
if [ ! -f "$REPO_PATH/go.mod" ]; then
    echo "⚠️  WARNING: No go.mod found - this may not be a Go component repository"
fi

if [ -f "$REPO_PATH/go.mod" ]; then
    if ! grep -q "github.com/openshift" "$REPO_PATH/go.mod" 2>/dev/null; then
        echo "⚠️  WARNING: go.mod doesn't contain openshift dependencies"
        echo "This script is optimized for OpenShift component repositories."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

# Check if /agentic already exists
if [ -d "$AGENTIC_DIR" ]; then
    echo "⚠️  WARNING: $AGENTIC_DIR already exists"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Create lean Tier 2 structure (NOT full single-tier)
mkdir -p "$AGENTIC_DIR"/{domain,architecture,decisions,exec-plans,references,scripts}

# Create exec-plans subdirectories
mkdir -p "$AGENTIC_DIR/exec-plans"/{active,completed}

echo "✅ Lean Tier 2 structure created"
echo ""
echo "Structure:"
tree -L 2 "$AGENTIC_DIR" 2>/dev/null || find "$AGENTIC_DIR" -type d | sed 's|^|  |'
echo ""
echo "Next steps:"
echo "  1. Run populate-templates.sh to create template files"
echo "  2. Customize templates with component-specific content"
echo "  3. Run validate.sh to verify Tier 2 compliance"
echo ""
echo "IMPORTANT: This is LEAN Tier 2 structure"
echo "  - No generic patterns (link to Tier 1 instead)"
echo "  - AGENTS.md must be ≤80 lines (not 150)"
echo "  - ecosystem.md must link to Tier 1"
