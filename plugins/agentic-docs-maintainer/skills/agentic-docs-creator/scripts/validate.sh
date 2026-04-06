#!/bin/bash
# Validate Tier 1 (openshift/enhancements/agentic/) compliance
# Exit 0 if compliant, 1 if issues found

set -e

REPO_PATH="${1:-.}"
AGENTIC_DIR="$REPO_PATH/agentic"
EXIT_CODE=0

echo "🔍 Validating Tier 1 compliance (10 checks)..."
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

# 7. Check core pattern files exist (must have at least these)
echo "📋 [7/9] Checking core pattern files..."
REQUIRED_PATTERNS=(
    "platform/operator-patterns/status-conditions.md"
    "platform/operator-patterns/controller-runtime.md"
    "platform/operator-patterns/index.md"
)

# These are good to have but not required (LLM uses judgment)
RECOMMENDED_PATTERNS=(
    "platform/operator-patterns/webhooks.md"
    "platform/operator-patterns/leader-election.md"
    "platform/operator-patterns/finalizers.md"
    "platform/operator-patterns/rbac-patterns.md"
)

for pattern in "${REQUIRED_PATTERNS[@]}"; do
    if [ ! -f "$AGENTIC_DIR/$pattern" ]; then
        record_issue "Missing required pattern: $pattern"
        echo "  ❌ Missing: $pattern"
    fi
done

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ Core pattern files exist"

    # Show what additional patterns were created
    TOTAL_PATTERNS=$(find "$AGENTIC_DIR/platform/operator-patterns" -name "*.md" -not -name "index.md" 2>/dev/null | wc -l)
    if [ "$TOTAL_PATTERNS" -gt 2 ]; then
        echo "  ℹ️  Total operator patterns documented: $TOTAL_PATTERNS"
    fi
fi
echo ""

# 8. Check core practice files exist (must have at least these)
echo "📋 [8/9] Checking core practice files..."
REQUIRED_PRACTICES=(
    "practices/testing/pyramid.md"
    "practices/testing/e2e-framework.md"
)

# Recommended but not required (LLM uses judgment for others)

for practice in "${REQUIRED_PRACTICES[@]}"; do
    if [ ! -f "$AGENTIC_DIR/$practice" ]; then
        record_issue "Missing required practice: $practice"
        echo "  ❌ Missing: $practice"
    fi
done

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ Core practice files exist"

    # Show what practices were documented
    TOTAL_PRACTICES=$(find "$AGENTIC_DIR/practices" -name "*.md" -not -name "index.md" 2>/dev/null | wc -l)
    if [ "$TOTAL_PRACTICES" -gt 2 ]; then
        echo "  ℹ️  Total practices documented: $TOTAL_PRACTICES"
        echo "     Testing: $(find "$AGENTIC_DIR/practices/testing" -name "*.md" -not -name "index.md" 2>/dev/null | wc -l)"
        echo "     Security: $(find "$AGENTIC_DIR/practices/security" -name "*.md" 2>/dev/null | wc -l)"
        echo "     Reliability: $(find "$AGENTIC_DIR/practices/reliability" -name "*.md" 2>/dev/null | wc -l)"
        echo "     Development: $(find "$AGENTIC_DIR/practices/development" -name "*.md" 2>/dev/null | wc -l)"
    fi
fi
echo ""

# 9. Check core domain and reference files exist
echo "📋 [9/9] Checking core domain and reference files..."
REQUIRED_DOMAIN=(
    "domain/openshift/clusteroperator.md"
    "references/repo-index.md"
)

# Recommended but not required (LLM uses judgment)

for domain in "${REQUIRED_DOMAIN[@]}"; do
    if [ ! -f "$AGENTIC_DIR/$domain" ]; then
        record_issue "Missing required domain file: $domain"
        echo "  ❌ Missing: $domain"
    fi
done

if [ ${#ISSUES[@]} -eq 0 ]; then
    echo "  ✅ Core domain and reference files exist"

    # Show what domain concepts were documented
    K8S_DOMAIN=$(find "$AGENTIC_DIR/domain/kubernetes" -name "*.md" 2>/dev/null | wc -l)
    OCP_DOMAIN=$(find "$AGENTIC_DIR/domain/openshift" -name "*.md" 2>/dev/null | wc -l)
    REFERENCES=$(find "$AGENTIC_DIR/references" -name "*.md" 2>/dev/null | wc -l)

    echo "  ℹ️  Domain concepts documented:"
    [ "$K8S_DOMAIN" -gt 0 ] && echo "     Kubernetes: $K8S_DOMAIN"
    [ "$OCP_DOMAIN" -gt 0 ] && echo "     OpenShift: $OCP_DOMAIN"
    [ "$REFERENCES" -gt 0 ] && echo "     References: $REFERENCES"
fi
echo ""

# 10. Quality assessment (informational only)
echo "📋 [10/10] Quality assessment..."

# Check OPENSHIFT_AGENTS.md navigation quality
if [ -f "$AGENTIC_DIR/OPENSHIFT_AGENTS.md" ]; then
    INTERNAL_LINKS=$(grep -c '\[.*\](./' "$AGENTIC_DIR/OPENSHIFT_AGENTS.md" 2>/dev/null || echo 0)
    EXTERNAL_LINKS=$(grep -c '\[.*\](http' "$AGENTIC_DIR/OPENSHIFT_AGENTS.md" 2>/dev/null || echo 0)

    if [ "$INTERNAL_LINKS" -lt 5 ]; then
        echo "  ⚠️  OPENSHIFT_AGENTS.md has few internal links ($INTERNAL_LINKS) - consider adding more navigation"
    else
        echo "  ℹ️  Navigation links: $INTERNAL_LINKS internal, $EXTERNAL_LINKS external"
    fi
fi

# Check context budget (total documentation size)
TOTAL_LINES=$(find "$AGENTIC_DIR" -name "*.md" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
echo "  ℹ️  Total documentation size: $TOTAL_LINES lines"

if [ "$TOTAL_LINES" -gt 10000 ]; then
    echo "  ⚠️  Documentation is large ($TOTAL_LINES lines) - consider if all content is essential"
elif [ "$TOTAL_LINES" -lt 2000 ]; then
    echo "  ⚠️  Documentation is minimal ($TOTAL_LINES lines) - ensure critical patterns are covered"
fi

echo "  ✅ Quality assessment complete"
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
