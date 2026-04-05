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

# Create exec-plan template
cat > "$AGENTIC_DIR/exec-plans/template.md" <<'EOF'
---
status: active
enhancement: <link to enhancements repo>
owner: @username
target_version: vX.Y
started: YYYY-MM-DD
---

# Plan: [Feature Name]

## Goal
[What we're building - component-specific scope]

## Context
See [enhancement](link) for overall design.
This plan covers ONLY [COMPONENT]-specific implementation.

## Related Components
[Other repos involved, if cross-repo feature]

## Implementation Status
- [ ] Design review
- [ ] API changes
- [ ] Controller implementation
- [ ] Unit tests
- [ ] Integration tests
- [ ] E2E tests
- [ ] Documentation
- [ ] Performance validation

## Blockers
[Any blockers or dependencies]

## Component-Specific Considerations
[What's unique about implementing this in THIS component]

## Testing Strategy
[Component-specific testing approach]

## Rollout Plan
[How this will be deployed/enabled]

## Links
- Enhancement: [link]
- Jira: [link]
- Related ADRs: [link]
EOF

# Create README for exec-plans
cat > "$AGENTIC_DIR/exec-plans/README.md" <<'EOF'
# Execution Plans

Track active feature implementations and completed work.

## Usage

**Starting a new feature:**
```bash
cp template.md active/feature-name.md
# Fill in the template with your feature details
```

**When implementation completes:**
```bash
mv active/feature-name.md completed/
```

## Structure

- `active/` - Features currently being implemented
- `completed/` - Archived completed features
- `template.md` - Template for new exec-plans

## What to Track

Create an exec-plan when:
- Implementing a new feature from an enhancement
- Major refactoring or architectural change
- Cross-repo feature (your component's portion)
- Any multi-week engineering effort

## What NOT to Track

Don't create exec-plans for:
- Bug fixes (unless major architectural fix)
- Minor refactoring
- Documentation-only changes
- Routine maintenance

Link exec-plans from AGENTS.md so they're discoverable.
EOF

echo "✅ Lean Tier 2 structure created"
echo "✅ Created exec-plans/template.md"
echo "✅ Created exec-plans/README.md"
echo ""
echo "Structure:"
tree -L 2 "$AGENTIC_DIR" 2>/dev/null || find "$AGENTIC_DIR" -type d | sed 's|^|  |'
echo ""

# Initialize progress tracking
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/check-phase-progress.sh" ]; then
    bash "$SCRIPT_DIR/check-phase-progress.sh" "$REPO_PATH" "" init
    bash "$SCRIPT_DIR/check-phase-progress.sh" "$REPO_PATH" "phase_2_structure" mark-complete
    echo ""
fi

echo "Next steps:"
echo "  1. Create component-specific content (via AI or manual):"
echo "     - AGENTS.md (≤100 lines, link to Tier 1, show exec-plans/ structure)"
echo "     - references/ecosystem.md (link to Tier 1 patterns)"
echo "     - domain/ (component-specific CRDs/concepts) - Phase 2.5 ⭐"
echo "     - architecture/ (component internals)"
echo "     - decisions/ (component-specific ADRs) - Phase 5.2 ⭐"
echo "     - exec-plans/active/ (for planning new features)"
echo "  2. Run validate-categories.sh --strict for enforcement"
echo "  3. Run validate.sh for full compliance check"
echo ""
echo "CRITICAL: Don't skip Phase 2.5 (domain discovery) and Phase 5.2 (ADR extraction)"
echo "  - Phase 2.5: ≥4 domain concepts required (SKILL.md lines 455-672)"
echo "  - Phase 5.2: ≥3 ADRs required (SKILL.md lines 955-1236)"
echo ""
echo "Track progress: bash scripts/check-phase-progress.sh $REPO_PATH list"
