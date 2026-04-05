#!/bin/bash
# Fill gaps - generate only missing files incrementally
# Uses discovery to learn what exists, generates only what's missing

set -euo pipefail

REPO_PATH="${1:-.}"
AGENTIC_DIR="$REPO_PATH/agentic"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 Fill Gaps Mode"
echo "================="
echo ""

# Check if agentic/ exists
if [ ! -d "$AGENTIC_DIR" ]; then
    echo "❌ agentic/ directory not found"
    echo "   Use create mode instead"
    exit 1
fi

# Run discovery first
echo "Running discovery..."
"$SCRIPT_DIR/discover.sh" "$REPO_PATH" > /tmp/discovery.log 2>&1

echo ""
echo "🔍 Identifying gaps..."
echo ""

# Check for commonly useful files and suggest creation
SUGGESTIONS=(
    "platform/operator-patterns/must-gather.md"
    "platform/operator-patterns/owner-references.md"
    "platform/operator-patterns/index.md"
    "practices/security/secrets-management.md"
    "practices/reliability/alerting.md"
    "practices/testing/test-flake-policy.md"
    "practices/testing/index.md"
    "decisions/adr-template.md"
    "decisions/index.md"
    "references/index.md"
    "ENHANCEMENT_ROADMAP.md"
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
echo "To create these files, you can:"
echo "  1. Use LLM to generate from production examples"
echo "  2. Copy from production and adapt"
echo "  3. Create from templates"
echo ""
echo "Missing files:"
for file in "${missing_files[@]}"; do
    echo "  - $file"
done
echo ""
