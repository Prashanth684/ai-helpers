#!/bin/bash
# Fill gaps for Tier 2 (component repos) - generate only missing files incrementally

set -euo pipefail

REPO_PATH="${1:-.}"
AGENTIC_DIR="$REPO_PATH/agentic"
COMPONENT_NAME=$(basename "$(realpath "$REPO_PATH")")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 Tier 2 Fill Gaps Mode"
echo "========================"
echo "Component: $COMPONENT_NAME"
echo ""

# Check if agentic/ exists
if [ ! -d "$AGENTIC_DIR" ]; then
    echo "❌ agentic/ directory not found"
    echo "   Use create mode instead"
    exit 1
fi

# Run discovery first
echo "Running discovery..."
"$SCRIPT_DIR/discover.sh" "$REPO_PATH" > /tmp/tier2-discovery.log 2>&1

echo ""
echo "🔍 Identifying gaps..."
echo ""

# Check for commonly useful files for components
SUGGESTIONS=(
    "AGENTS.md"
    "references/ecosystem.md"
    "exec-plans/template.md"
    "decisions/adr-template.md"
    "architecture/index.md"
    "domain/index.md"
    "${COMPONENT_NAME}_DEVELOPMENT.md"
    "${COMPONENT_NAME}_TESTING.md"
)

missing_files=()
for file in "${SUGGESTIONS[@]}"; do
    if [ ! -f "$AGENTIC_DIR/$file" ]; then
        missing_files+=("$file")
        echo "  ❌ Missing: $file"
    fi
done

if [ ${#missing_files[@]} -eq 0 ]; then
    echo "  ✅ No common gaps found"
    exit 0
fi

echo ""
echo "📝 Found ${#missing_files[@]} commonly recommended files missing"
echo ""

# Special check for recommended files (development mode: warnings only)
if [[ " ${missing_files[@]} " =~ " references/ecosystem.md " ]]; then
    echo "⚠️  RECOMMENDED: references/ecosystem.md is missing"
    echo "   This file is recommended for linking to Tier 1 documentation (development mode)"
    echo ""
fi

if [[ " ${missing_files[@]} " =~ " AGENTS.md " ]]; then
    echo "⚠️  RECOMMENDED: AGENTS.md is missing"
    echo "   This is the main entry point for agents"
    echo ""
fi

echo "To create these files, you can:"
echo "  1. Use LLM to generate from templates"
echo "  2. Create from component-specific content"
echo "  3. Adapt from similar components"
echo ""
echo "Missing files:"
for file in "${missing_files[@]}"; do
    # Mark recommended files (development mode)
    if [[ "$file" == "AGENTS.md" || "$file" == "references/ecosystem.md" ]]; then
        echo "  - $file ⚠️  RECOMMENDED"
    else
        echo "  - $file"
    fi
done
echo ""
