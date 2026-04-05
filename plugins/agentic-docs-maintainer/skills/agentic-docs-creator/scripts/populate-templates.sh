#!/bin/bash
# Populate agentic/ directory with template files (60% foundation phase)
# Usage: ./populate-templates.sh [path-to-repo]

set -e

REPO_PATH="${1:-.}"
AGENTIC_DIR="$REPO_PATH/agentic"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(cd "$SCRIPT_DIR/../templates" && pwd)"

echo "📝 Populating agentic/ directory with template files..."
echo "Repository: $REPO_PATH"
echo "Template source: $TEMPLATE_DIR"
echo ""

# Verify agentic directory exists
if [ ! -d "$AGENTIC_DIR" ]; then
    echo "❌ ERROR: $AGENTIC_DIR does not exist"
    echo "Run create-structure.sh first to create directory tree"
    exit 1
fi

# Check if templates directory exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "❌ ERROR: Template directory not found: $TEMPLATE_DIR"
    exit 1
fi

echo "📋 Copying critical files..."

# 1. Copy DESIGN_PHILOSOPHY.md
if [ -f "$TEMPLATE_DIR/DESIGN_PHILOSOPHY.md" ]; then
    cp "$TEMPLATE_DIR/DESIGN_PHILOSOPHY.md" "$AGENTIC_DIR/"
    # Update timestamp
    sed -i "s/YYYY-MM-DD/$(date +%Y-%m-%d)/g" "$AGENTIC_DIR/DESIGN_PHILOSOPHY.md"
    echo "  ✅ DESIGN_PHILOSOPHY.md (~500 lines)"
else
    echo "  ⚠️  Warning: DESIGN_PHILOSOPHY.md template not found"
fi

# 2. Copy KNOWLEDGE_GRAPH.md
if [ -f "$TEMPLATE_DIR/KNOWLEDGE_GRAPH.md" ]; then
    cp "$TEMPLATE_DIR/KNOWLEDGE_GRAPH.md" "$AGENTIC_DIR/"
    # Update timestamp
    sed -i "s/YYYY-MM-DD/$(date +%Y-%m-%d)/g" "$AGENTIC_DIR/KNOWLEDGE_GRAPH.md"
    echo "  ✅ KNOWLEDGE_GRAPH.md (~450 lines)"
else
    echo "  ⚠️  Warning: KNOWLEDGE_GRAPH.md template not found"
fi

# 3. Copy OPENSHIFT_AGENTS.md (if exists)
if [ -f "$TEMPLATE_DIR/OPENSHIFT_AGENTS.md" ]; then
    cp "$TEMPLATE_DIR/OPENSHIFT_AGENTS.md" "$AGENTIC_DIR/"
    sed -i "s/YYYY-MM-DD/$(date +%Y-%m-%d)/g" "$AGENTIC_DIR/OPENSHIFT_AGENTS.md"
    echo "  ✅ OPENSHIFT_AGENTS.md (~150-170 lines)"
fi

echo ""
echo "📋 Copying operator pattern templates..."

# Copy operator pattern templates (if they exist)
if [ -d "$TEMPLATE_DIR/platform/operator-patterns" ]; then
    cp -r "$TEMPLATE_DIR/platform/operator-patterns"/*.md "$AGENTIC_DIR/platform/operator-patterns/" 2>/dev/null || true
    PATTERN_COUNT=$(ls "$AGENTIC_DIR/platform/operator-patterns"/*.md 2>/dev/null | wc -l)
    echo "  ✅ $PATTERN_COUNT operator pattern templates"
fi

echo ""
echo "📋 Copying practice templates..."

# Copy practice templates (if they exist)
for practice in testing security reliability development; do
    if [ -d "$TEMPLATE_DIR/practices/$practice" ]; then
        cp -r "$TEMPLATE_DIR/practices/$practice"/*.md "$AGENTIC_DIR/practices/$practice/" 2>/dev/null || true
    fi
done
PRACTICE_COUNT=$(find "$AGENTIC_DIR/practices" -name "*.md" 2>/dev/null | wc -l)
echo "  ✅ $PRACTICE_COUNT practice templates"

echo ""
echo "📋 Copying domain templates..."

# Copy domain templates (if they exist)
for domain in kubernetes openshift; do
    if [ -d "$TEMPLATE_DIR/domain/$domain" ]; then
        cp -r "$TEMPLATE_DIR/domain/$domain"/*.md "$AGENTIC_DIR/domain/$domain/" 2>/dev/null || true
    fi
done
DOMAIN_COUNT=$(find "$AGENTIC_DIR/domain" -name "*.md" 2>/dev/null | wc -l)
echo "  ✅ $DOMAIN_COUNT domain templates"

echo ""
echo "📋 Copying decision templates..."

# Copy ADR templates (if they exist)
if [ -d "$TEMPLATE_DIR/decisions" ]; then
    cp -r "$TEMPLATE_DIR/decisions"/*.md "$AGENTIC_DIR/decisions/" 2>/dev/null || true
fi
ADR_COUNT=$(find "$AGENTIC_DIR/decisions" -name "*.md" 2>/dev/null | wc -l)
echo "  ✅ $ADR_COUNT decision templates"

echo ""
echo "📋 Copying workflow templates..."

# Copy workflow templates (if they exist)
if [ -d "$TEMPLATE_DIR/workflows" ]; then
    cp -r "$TEMPLATE_DIR/workflows"/*.md "$AGENTIC_DIR/workflows/" 2>/dev/null || true
fi
WORKFLOW_COUNT=$(find "$AGENTIC_DIR/workflows" -name "*.md" 2>/dev/null | wc -l)
echo "  ✅ $WORKFLOW_COUNT workflow templates"

echo ""
echo "📋 Copying reference templates..."

# Copy reference templates (if they exist)
if [ -d "$TEMPLATE_DIR/references" ]; then
    cp -r "$TEMPLATE_DIR/references"/*.md "$AGENTIC_DIR/references/" 2>/dev/null || true
fi
REF_COUNT=$(find "$AGENTIC_DIR/references" -name "*.md" 2>/dev/null | wc -l)
echo "  ✅ $REF_COUNT reference templates"

echo ""
echo "✅ Template population complete!"
echo ""
echo "Summary:"
echo "  - Critical files: DESIGN_PHILOSOPHY.md, KNOWLEDGE_GRAPH.md, OPENSHIFT_AGENTS.md"
echo "  - Operator patterns: $PATTERN_COUNT files"
echo "  - Practices: $PRACTICE_COUNT files"
echo "  - Domain concepts: $DOMAIN_COUNT files"
echo "  - Decisions (ADRs): $ADR_COUNT files"
echo "  - Workflows: $WORKFLOW_COUNT files"
echo "  - References: $REF_COUNT files"
echo ""

# Calculate total
TOTAL_FILES=$(find "$AGENTIC_DIR" -name "*.md" 2>/dev/null | wc -l)
TOTAL_LINES=$(find "$AGENTIC_DIR" -name "*.md" -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')

echo "Total: $TOTAL_FILES markdown files, ~$TOTAL_LINES lines"
echo ""
echo "📊 Foundation Status: ~60% complete"
echo ""
echo "Next steps:"
echo "  1. Customize templates with project-specific content"
echo "  2. Run extraction to fill 40% gap:"
echo "     ./scripts/extract.sh"
echo "  3. Validate compliance:"
echo "     ./scripts/validate.sh"
echo ""
echo "NOTE: Templates contain placeholder content and extraction notes."
echo "Use extraction mode to populate with real content from enhancements."
