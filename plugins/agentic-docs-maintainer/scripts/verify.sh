#!/bin/bash
# Verification script for agentic/ directory
# Exit 0 if all checks pass, 1 if needs work
# Used by Agentic Docs Maintainer to determine when to stop

set -e

# Accept REPO_ROOT as environment variable, or calculate from script location
if [[ -z "$REPO_ROOT" ]]; then
    RALPH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    AGENTIC_DIR="$(cd "$RALPH_DIR/.." && pwd)"
    REPO_ROOT="$(cd "$AGENTIC_DIR/.." && pwd)"
fi

AGENTIC_DIR="$REPO_ROOT/agentic"
EXIT_CODE=0

echo "🔍 Verifying agentic/ directory against SPECIFICATION.md"
echo "=================================================="
echo ""

# Track issues found
declare -a ISSUES=()

# Helper to record issues
record_issue() {
    ISSUES+=("$1")
    EXIT_CODE=1
}

# 1. Check all internal links work
echo "📋 [1/8] Checking internal links..."
cd "$AGENTIC_DIR"

# Find all markdown links to local files
# We'll check links that start with ./ or just filenames
while IFS= read -r file; do
    if [[ -f "$file" ]]; then
        # Extract links from this file
        grep -oh '\[.*\](\.\/[^)]*\.md)' "$file" 2>/dev/null | sed 's/.*(\.\///' | sed 's/).*//' | while read -r link; do
            # Get directory of source file
            file_dir=$(dirname "$file")
            # Check if link exists relative to source file
            if [[ ! -f "$file_dir/$link" ]] && [[ ! -f "$AGENTIC_DIR/$link" ]]; then
                record_issue "Broken link in $file: $link"
                echo "  ❌ Broken in $(basename $file): $link"
            fi
        done
    fi
done < <(find "$AGENTIC_DIR" -name "*.md" -type f)

if [[ ${#ISSUES[@]} -eq 0 ]]; then
    echo "  ✅ Internal links check complete"
fi

# Check references to /dev-guide/ exist
grep -roh '\[.*\](.*dev-guide/[^)]*\.md)' . 2>/dev/null | \
    sed 's/.*dev-guide\///' | sed 's/).*//' | \
    sort -u | while read -r file; do
    if [[ ! -f "$REPO_ROOT/dev-guide/$file" ]]; then
        record_issue "Broken dev-guide reference: $file"
        echo "  ❌ Broken dev-guide ref: $file"
    fi
done

if [[ ${#ISSUES[@]} -eq 0 ]]; then
    echo "  ✅ All links valid"
fi
echo ""

# 2. Check index files are complete
echo "📋 [2/8] Checking index completeness..."

# Check decisions/index.md lists all ADRs
ADR_FILES=$(ls "$AGENTIC_DIR/decisions/adr-"*.md 2>/dev/null | wc -l)
ADR_REFS=$(grep -c "adr-" "$AGENTIC_DIR/decisions/index.md" 2>/dev/null || echo 0)
if [[ $ADR_FILES -ne $ADR_REFS ]]; then
    record_issue "decisions/index.md has $ADR_REFS refs but $ADR_FILES ADR files exist"
    echo "  ❌ decisions/index.md incomplete ($ADR_REFS refs, $ADR_FILES files)"
else
    echo "  ✅ decisions/index.md complete"
fi

# Check platform/operator-patterns/index.md
PATTERN_FILES=$(ls "$AGENTIC_DIR/platform/operator-patterns/"*.md 2>/dev/null | grep -v index.md | wc -l)
PATTERN_REFS=$(grep -c "\.md" "$AGENTIC_DIR/platform/operator-patterns/index.md" 2>/dev/null || echo 0)
if [[ $PATTERN_FILES -gt $PATTERN_REFS ]]; then
    record_issue "platform/operator-patterns/index.md may be incomplete"
    echo "  ⚠️  operator-patterns/index.md may be incomplete ($PATTERN_REFS refs, $PATTERN_FILES files)"
fi

echo ""

# 3. Check required references to official docs exist
echo "📋 [3/8] Checking official doc references..."

# These files MUST reference /dev-guide/
declare -A REQUIRED_REFS=(
    ["practices/development/api-evolution.md"]="dev-guide/api-conventions.md"
    ["practices/testing/index.md"]="dev-guide/test-conventions.md"
    ["workflows/enhancement-process.md"]="guidelines/enhancement_template.md"
)

for file in "${!REQUIRED_REFS[@]}"; do
    ref="${REQUIRED_REFS[$file]}"
    if ! grep -q "$ref" "$AGENTIC_DIR/$file" 2>/dev/null; then
        record_issue "$file missing reference to $ref"
        echo "  ❌ $file should reference $ref"
    else
        echo "  ✅ $file references $ref"
    fi
done

echo ""

# 4. Check no contradictions (basic checks)
echo "📋 [4/8] Checking for contradictions..."

# Check API version progression is consistent
API_VERSION_DOCS=$(grep -l "v1alpha1.*v1beta1.*v1" "$AGENTIC_DIR"/**/*.md 2>/dev/null || true)
ALPHA_PATTERN=$(grep -h "v1alpha1" $API_VERSION_DOCS 2>/dev/null | head -1 || true)
BETA_PATTERN=$(grep -h "v1beta1" $API_VERSION_DOCS 2>/dev/null | head -1 || true)

# This is basic - full contradiction checking is hard to automate
echo "  ℹ️  Manual review recommended for contradictions"
echo ""

# 5. Check file counts match KNOWLEDGE_GRAPH.md
echo "📋 [5/8] Checking KNOWLEDGE_GRAPH.md accuracy..."

# Extract claimed counts
CLAIMED_PLATFORM=$(grep "Platform Patterns.*:" "$AGENTIC_DIR/KNOWLEDGE_GRAPH.md" | grep -o '[0-9]* files' | awk '{print $1}')
ACTUAL_PLATFORM=$(ls "$AGENTIC_DIR/platform/operator-patterns/"*.md 2>/dev/null | wc -l)

if [[ "$CLAIMED_PLATFORM" != "$ACTUAL_PLATFORM" ]]; then
    record_issue "KNOWLEDGE_GRAPH.md claims $CLAIMED_PLATFORM platform files, actually $ACTUAL_PLATFORM"
    echo "  ❌ Platform file count mismatch (claimed: $CLAIMED_PLATFORM, actual: $ACTUAL_PLATFORM)"
else
    echo "  ✅ Platform file count matches"
fi

echo ""

# 6. Check markdown validity (basic)
echo "📋 [6/8] Checking markdown formatting..."

# Check for unclosed code blocks
find "$AGENTIC_DIR" -name "*.md" -type f | while read -r file; do
    # Count ``` occurrences - should be even
    TICKS=$(grep -c '^```' "$file" 2>/dev/null || echo "0")
    # Ensure TICKS is a number
    if [[ "$TICKS" =~ ^[0-9]+$ ]]; then
        if [[ $((TICKS % 2)) -ne 0 ]]; then
            record_issue "$file has unclosed code block"
            echo "  ❌ $(basename $file): unclosed code block"
        fi
    fi
done

echo "  ✅ Basic markdown checks pass"
echo ""

# 7. Check entry points exist
echo "📋 [7/8] Checking entry points..."

ENTRY_POINTS=(
    "OPENSHIFT_AGENTS.md"
    "DESIGN_PHILOSOPHY.md"
    "KNOWLEDGE_GRAPH.md"
    "platform/operator-patterns/index.md"
    "decisions/index.md"
    "references/index.md"
)

for entry in "${ENTRY_POINTS[@]}"; do
    if [[ ! -f "$AGENTIC_DIR/$entry" ]]; then
        record_issue "Missing entry point: $entry"
        echo "  ❌ Missing: $entry"
    fi
done

echo "  ✅ All entry points exist"
echo ""

# 8. Check for required operator patterns
echo "📋 [8/8] Checking required patterns exist..."

REQUIRED_PATTERNS=(
    "controller-runtime.md"
    "status-conditions.md"
    "leader-election.md"
    "finalizers.md"
)

for pattern in "${REQUIRED_PATTERNS[@]}"; do
    if [[ ! -f "$AGENTIC_DIR/platform/operator-patterns/$pattern" ]]; then
        record_issue "Missing required pattern: $pattern"
        echo "  ❌ Missing: $pattern"
    fi
done

echo "  ✅ Core patterns exist"
echo ""

# 9. Check for unprocessed enhancements (knowledge extraction)
echo "📋 [9/11] Checking for new enhancements to process..."

# Track processed enhancements
PROCESSED_FILE="$AGENTIC_DIR/.ralph-processed-enhancements.txt"
touch "$PROCESSED_FILE"

# Find enhancements modified in last 30 days
RECENT_ENHANCEMENTS=$(find "$REPO_ROOT/enhancements" -name "*.md" -type f -mtime -30 2>/dev/null | wc -l)

if [[ $RECENT_ENHANCEMENTS -gt 0 ]]; then
    echo "  ℹ️  Found $RECENT_ENHANCEMENTS enhancement(s) modified in last 30 days"
    echo "  💡 Run Agentic Docs Maintainer with --extract to process new enhancements"
else
    echo "  ✅ No recent enhancements to process"
fi

echo ""

# 10. Check glossary completeness
echo "📋 [10/11] Checking glossary completeness..."

# Basic check - glossary should exist and have content
if [[ ! -f "$AGENTIC_DIR/references/glossary.md" ]]; then
    record_issue "references/glossary.md missing"
    echo "  ❌ Glossary missing"
elif [[ $(wc -l < "$AGENTIC_DIR/references/glossary.md") -lt 50 ]]; then
    record_issue "Glossary seems incomplete (< 50 lines)"
    echo "  ⚠️  Glossary may be incomplete"
else
    echo "  ✅ Glossary exists"
fi

echo ""

# 11. Check enhancement index freshness
echo "📋 [11/11] Checking enhancement index freshness..."

if [[ ! -f "$AGENTIC_DIR/references/enhancement-index.md" ]]; then
    record_issue "references/enhancement-index.md missing"
    echo "  ❌ Enhancement index missing"
else
    # Count enhancement categories in /enhancements/
    ENHANCEMENT_DIRS=$(find "$REPO_ROOT/enhancements" -maxdepth 1 -type d 2>/dev/null | wc -l)
    INDEX_REFS=$(grep -c "enhancements/" "$AGENTIC_DIR/references/enhancement-index.md" 2>/dev/null || echo 0)

    if [[ $INDEX_REFS -lt $((ENHANCEMENT_DIRS / 2)) ]]; then
        echo "  ℹ️  Enhancement index may need updating ($INDEX_REFS refs, ~$ENHANCEMENT_DIRS categories)"
        echo "  💡 Run Agentic Docs Maintainer with --extract to update"
    else
        echo "  ✅ Enhancement index seems current"
    fi
fi

echo ""

# Summary
echo "=================================================="
if [[ ${#ISSUES[@]} -eq 0 ]]; then
    echo "✅ All compliance checks passed!"
    echo ""
    if [[ $RECENT_ENHANCEMENTS -gt 0 ]]; then
        echo "💡 Tip: Run './agentic/agentic-docs-maintainer/loop.sh --extract' to process recent enhancements"
        echo ""
    fi
    echo "The agentic/ directory meets the SPECIFICATION.md requirements."
    exit 0
else
    echo "❌ Found ${#ISSUES[@]} issue(s):"
    echo ""
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue"
    done
    echo ""
    echo "Run Agentic Docs Maintainer to fix automatically:"
    echo "  ./agentic/agentic-docs-maintainer/loop.sh          # Fix compliance issues"
    echo "  ./agentic/agentic-docs-maintainer/loop.sh --extract # Also extract knowledge from enhancements"
    exit 1
fi
