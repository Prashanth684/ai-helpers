#!/bin/bash
# Validate Tier 1 (openshift/enhancements/agentic/) compliance
# Exit 0 if compliant, 1 if issues found

set -e

REPO_PATH="${1:-.}"
AGENTIC_DIR="$REPO_PATH/agentic"
EXIT_CODE=0

echo "🔍 Validating Tier 1 compliance..."
echo "Repository: $REPO_PATH"
echo ""

# Track issues
declare -a ISSUES=()

record_issue() {
    ISSUES+=("$1")
    EXIT_CODE=1
}

# 1. Check OPENSHIFT_AGENTS.md exists and is ~150-170 lines
echo "📋 [1/9] Checking OPENSHIFT_AGENTS.md..."
if [ ! -f "$AGENTIC_DIR/OPENSHIFT_AGENTS.md" ]; then
    record_issue "Missing OPENSHIFT_AGENTS.md"
    echo "  ❌ Missing OPENSHIFT_AGENTS.md"
else
    LINES=$(wc -l < "$AGENTIC_DIR/OPENSHIFT_AGENTS.md")
    if [ "$LINES" -gt 200 ]; then
        echo "  ⚠️  OPENSHIFT_AGENTS.md is $LINES lines (recommended: 150-170)"
    else
        echo "  ✅ OPENSHIFT_AGENTS.md exists ($LINES lines)"
    fi
fi
echo ""

# 2. Check all required directories exist
echo "📋 [2/9] Checking required directories..."
REQUIRED_DIRS=(
    "platform/operator-patterns"
    "platform/openshift-specifics"
    "practices/testing"
    "practices/security"
    "practices/reliability"
    "practices/development"
    "domain/kubernetes"
    "domain/openshift"
    "decisions"
    "workflows"
    "references"
)

for dir in "${REQUIRED_DIRS[@]}"; do
    if [ ! -d "$AGENTIC_DIR/$dir" ]; then
        record_issue "Missing required directory: $dir"
        echo "  ❌ Missing: $dir"
    fi
done

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ All required directories present"
fi
echo ""

# 3. Check no component-specific content (forbidden patterns)
echo "📋 [3/9] Checking for component-specific content..."
FORBIDDEN_PATTERNS=(
    "machine-config-operator"
    "MCO-specific"
    "installer-specific"
    "CNO-specific"
    "cluster-network-operator-specific"
)

# Exception: repo-index.md and "Examples in Components" sections are OK
for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    if grep -r "$pattern" "$AGENTIC_DIR" 2>/dev/null | grep -v "repo-index.md" | grep -v "Examples" | grep -v ".git"; then
        record_issue "Found component-specific content: $pattern (should be in Tier 2)"
        echo "  ❌ Found component-specific content: $pattern"
    fi
done

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ No component-specific content detected"
fi
echo ""

# 4. Check internal links
echo "📋 [4/9] Checking internal links..."
cd "$AGENTIC_DIR"

while IFS= read -r file; do
    if [ -f "$file" ]; then
        grep -oh '\[.*\](\.\/[^)]*\.md)' "$file" 2>/dev/null | sed 's/.*(\.\///' | sed 's/).*//' | while read -r link; do
            file_dir=$(dirname "$file")
            if [ ! -f "$file_dir/$link" ] && [ ! -f "$AGENTIC_DIR/$link" ]; then
                record_issue "Broken link in $file: $link"
                echo "  ❌ Broken in $(basename $file): $link"
            fi
        done
    fi
done < <(find "$AGENTIC_DIR" -name "*.md" -type f 2>/dev/null)

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ All internal links valid"
fi
echo ""

# 5. Check references to dev-guide exist
echo "📋 [5/9] Checking dev-guide references..."
grep -roh '\[.*\](.*dev-guide/[^)]*\.md)' "$AGENTIC_DIR" 2>/dev/null | \
    sed 's/.*dev-guide\///' | sed 's/).*//' | \
    sort -u | while read -r file; do
    if [ ! -f "$REPO_PATH/dev-guide/$file" ]; then
        record_issue "Broken dev-guide reference: $file"
        echo "  ❌ Broken dev-guide ref: $file"
    fi
done

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ All dev-guide references valid"
fi
echo ""

# 6. Check index files list all content
echo "📋 [6/9] Checking index completeness..."

# Check decisions/index.md lists all ADRs
if [ -d "$AGENTIC_DIR/decisions" ]; then
    ADR_FILES=$(ls "$AGENTIC_DIR/decisions/adr-"*.md 2>/dev/null | wc -l)
    if [ -f "$AGENTIC_DIR/decisions/index.md" ]; then
        ADR_REFS=$(grep -c "adr-" "$AGENTIC_DIR/decisions/index.md" 2>/dev/null || echo 0)
        if [ "$ADR_FILES" -ne "$ADR_REFS" ]; then
            record_issue "decisions/index.md has $ADR_REFS refs but $ADR_FILES ADR files exist"
            echo "  ⚠️  decisions/index.md incomplete ($ADR_REFS refs, $ADR_FILES files)"
        fi
    fi
fi

echo "  ✅ Index checks complete"
echo ""

# 7. Check required pattern files exist
echo "📋 [7/9] Checking required pattern files..."
REQUIRED_PATTERNS=(
    "platform/operator-patterns/status-conditions.md"
    "platform/operator-patterns/controller-runtime.md"
    "platform/operator-patterns/leader-election.md"
    "platform/operator-patterns/index.md"
)

for pattern in "${REQUIRED_PATTERNS[@]}"; do
    if [ ! -f "$AGENTIC_DIR/$pattern" ]; then
        record_issue "Missing required pattern: $pattern"
        echo "  ❌ Missing: $pattern"
    fi
done

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ Core pattern files exist"
fi
echo ""

# 8. Check required practice files exist
echo "📋 [8/9] Checking required practice files..."
REQUIRED_PRACTICES=(
    "practices/testing/pyramid.md"
    "practices/testing/e2e-framework.md"
    "practices/testing/index.md"
)

for practice in "${REQUIRED_PRACTICES[@]}"; do
    if [ ! -f "$AGENTIC_DIR/$practice" ]; then
        record_issue "Missing required practice: $practice"
        echo "  ❌ Missing: $practice"
    fi
done

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ Core practice files exist"
fi
echo ""

# 9. Check required domain files exist
echo "📋 [9/9] Checking required domain files..."
REQUIRED_DOMAIN=(
    "domain/kubernetes/pods.md"
    "domain/openshift/clusteroperator.md"
    "references/repo-index.md"
)

for domain in "${REQUIRED_DOMAIN[@]}"; do
    if [ ! -f "$AGENTIC_DIR/$domain" ]; then
        record_issue "Missing required domain file: $domain"
        echo "  ❌ Missing: $domain"
    fi
done

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ Core domain files exist"
fi
echo ""

# Summary
echo "=================================================="
if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "✅ Tier 1 validation PASSED!"
    echo ""
    echo "The agentic/ directory meets Tier 1 requirements."
    exit 0
else
    echo "❌ Tier 1 validation FAILED with ${#ISSUES[@]} issue(s):"
    echo ""
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue"
    done
    echo ""
    echo "Fix these issues and re-run validation."
    exit 1
fi
