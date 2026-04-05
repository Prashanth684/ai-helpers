#!/bin/bash
# Create Tier 1 directory structure in openshift/enhancements
# Usage: ./create-structure.sh [path-to-enhancements-repo]

set -e

REPO_PATH="${1:-.}"
AGENTIC_DIR="$REPO_PATH/agentic"

echo "🏗️  Creating Tier 1 directory structure..."
echo "Repository: $REPO_PATH"
echo ""

# Verify this looks like openshift/enhancements
if [ ! -d "$REPO_PATH/enhancements" ] && [ ! -d "$REPO_PATH/dev-guide" ]; then
    echo "❌ ERROR: This doesn't appear to be openshift/enhancements repository"
    echo "Expected directories: enhancements/, dev-guide/"
    exit 1
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

# Create main structure
mkdir -p "$AGENTIC_DIR"/{platform,practices,domain,decisions,workflows,references}

# Create platform subdirectories
mkdir -p "$AGENTIC_DIR/platform"/{operator-patterns,openshift-specifics}

# Create practices subdirectories
mkdir -p "$AGENTIC_DIR/practices"/{testing,security,reliability,development}

# Create domain subdirectories
mkdir -p "$AGENTIC_DIR/domain"/{kubernetes,openshift}

# Create scripts directory
mkdir -p "$AGENTIC_DIR/scripts"

echo "✅ Directory structure created"
echo ""
echo "Structure:"
tree -L 2 "$AGENTIC_DIR" 2>/dev/null || find "$AGENTIC_DIR" -type d | sed 's|^|  |'
echo ""
echo "Next steps:"
echo "  1. Run populate-templates.sh to create template files"
echo "  2. Run validate.sh to verify compliance"
