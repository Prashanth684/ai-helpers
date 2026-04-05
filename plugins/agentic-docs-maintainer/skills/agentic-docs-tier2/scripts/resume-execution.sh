#!/bin/bash
# Resume Tier 2 skill execution from previous incomplete run
# Analyzes .skill-progress.json and determines next phase to execute

set -euo pipefail

REPO_PATH="${1:-.}"
PROGRESS_FILE="$REPO_PATH/agentic/.skill-progress.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🔄 Resuming Tier 2 Skill Execution"
echo "=================================="
echo ""

# Check if progress file exists
if [ ! -f "$PROGRESS_FILE" ]; then
    echo -e "${RED}❌ No progress file found${NC}"
    echo ""
    echo "This appears to be a fresh start. Run:"
    echo "  bash scripts/create-structure.sh $REPO_PATH"
    exit 1
fi

echo "📋 Analyzing previous execution progress..."
echo ""

# Read progress file and determine last completed phase
started_at=$(grep "started_at" "$PROGRESS_FILE" | cut -d'"' -f4)
echo "Original execution started: $started_at"
echo ""

# Parse phases and find last completed
declare -a phases=(
    "phase_1_discovery:Phase 1 - Discovery"
    "phase_2_structure:Phase 2 - Structure Creation"
    "phase_2.5_domain_discovery:Phase 2.5 - Domain Discovery ⭐"
    "phase_3_agents_md:Phase 3 - AGENTS.md"
    "phase_4_ecosystem_md:Phase 4 - ecosystem.md"
    "phase_5_component_guides:Phase 5 - Component Guides"
    "phase_5.2_adr_extraction:Phase 5.2 - ADR Extraction ⭐"
    "phase_6_architecture:Phase 6 - Architecture Docs"
    "phase_7_validation:Phase 7 - Validation"
)

last_completed=""
next_phase=""
next_phase_name=""

echo "Phase Status:"
echo "-------------"

for phase_spec in "${phases[@]}"; do
    IFS=':' read -r phase_key phase_name <<< "$phase_spec"

    status=$(grep -A1 "\"$phase_key\"" "$PROGRESS_FILE" | grep "status" | cut -d'"' -f4 || echo "not_found")

    if [ "$status" = "complete" ]; then
        completed_at=$(grep -A2 "\"$phase_key\"" "$PROGRESS_FILE" | grep "completed_at" | cut -d'"' -f4)
        echo -e "  ${GREEN}✅${NC} $phase_name (completed $completed_at)"
        last_completed="$phase_key"
    elif [ "$status" = "in_progress" ]; then
        echo -e "  ${YELLOW}⏳${NC} $phase_name (IN PROGRESS - resume here)"
        next_phase="$phase_key"
        next_phase_name="$phase_name"
        break
    else
        echo -e "  ⬜ $phase_name (NOT STARTED)"
        if [ -z "$next_phase" ]; then
            next_phase="$phase_key"
            next_phase_name="$phase_name"
        fi
        break
    fi
done

echo ""
echo "=================================================="
echo ""

if [ -z "$next_phase" ]; then
    echo -e "${GREEN}✅ All phases complete!${NC}"
    echo ""
    echo "Run validation to verify:"
    echo "  bash scripts/validate-categories.sh $REPO_PATH --strict"
    exit 0
fi

# Provide resumption guidance
echo -e "${BLUE}📍 Resume Point: $next_phase_name${NC}"
echo ""

# Determine line numbers in SKILL.md for the next phase
case "$next_phase" in
    phase_1_discovery)
        echo "Next steps:"
        echo "  1. Read SKILL.md Phase 1 for discovery guidance"
        echo "  2. Understand component structure, CRDs, design docs"
        echo "  3. Mark complete: bash scripts/check-phase-progress.sh $REPO_PATH phase_1_discovery mark-complete"
        ;;

    phase_2_structure)
        echo "Next steps:"
        echo "  1. Run: bash scripts/create-structure.sh $REPO_PATH"
        echo "  2. Script will auto-mark this phase complete"
        ;;

    phase_2.5_domain_discovery)
        echo -e "${RED}⭐ CRITICAL PHASE ⭐${NC}"
        echo ""
        echo "This phase requires ≥4 domain concepts. See SKILL.md lines 455-672."
        echo ""
        echo "Domain concept categories to check:"
        echo "  1. CRDs/API Resources (vendor/github.com/openshift/api, pkg/apis/)"
        echo "  2. Technologies (rpm-ostree, OVN, etc. in pkg/ imports)"
        echo "  3. Data Formats (Ignition, YAML schemas, config formats)"
        echo "  4. Abstractions (component-specific concepts like 'rendered config')"
        echo ""
        echo "Next steps:"
        echo "  1. Read SKILL.md lines 455-672 for comprehensive checklist"
        echo "  2. Create domain concept docs in agentic/domain/"
        echo "  3. Ensure ≥4 concepts documented"
        echo "  4. Mark complete: bash scripts/check-phase-progress.sh $REPO_PATH phase_2.5_domain_discovery mark-complete"
        ;;

    phase_3_agents_md)
        echo "Next steps:"
        echo "  1. Create AGENTS.md (≤100 lines)"
        echo "  2. Include exec-plans/ in directory structure"
        echo "  3. Link to Tier 1 ecosystem hub"
        echo "  4. Link to component-specific content"
        echo "  5. Mark complete: bash scripts/check-phase-progress.sh $REPO_PATH phase_3_agents_md mark-complete"
        ;;

    phase_4_ecosystem_md)
        echo "Next steps:"
        echo "  1. Create agentic/references/ecosystem.md"
        echo "  2. Add ≥10 links to Tier 1 patterns"
        echo "  3. Categories: operator patterns, testing, security, reliability"
        echo "  4. Mark complete: bash scripts/check-phase-progress.sh $REPO_PATH phase_4_ecosystem_md mark-complete"
        ;;

    phase_5_component_guides)
        echo "Next steps:"
        echo "  1. Create [COMPONENT]_DEVELOPMENT.md (lean, component-specific)"
        echo "  2. Create [COMPONENT]_TESTING.md (lean, component-specific)"
        echo "  3. Link to Tier 1 for generic practices"
        echo "  4. Mark complete: bash scripts/check-phase-progress.sh $REPO_PATH phase_5_component_guides mark-complete"
        ;;

    phase_5.2_adr_extraction)
        echo -e "${RED}⭐ CRITICAL PHASE ⭐${NC}"
        echo ""
        echo "This phase requires ≥3 ADRs. See SKILL.md lines 955-1236."
        echo ""
        echo "ADR extraction process:"
        echo "  1. Read ALL design docs in docs/ (ls docs/*Design.md docs/*.md)"
        echo "  2. Extract architectural decisions (component structure)"
        echo "  3. Extract technology choices (why this tool/format)"
        echo "  4. Extract implementation decisions (why this approach)"
        echo ""
        echo "Next steps:"
        echo "  1. Read SKILL.md lines 955-1236 for comprehensive checklist"
        echo "  2. Create ADR docs in agentic/decisions/ (adr-NNNN-*.md)"
        echo "  3. Ensure ≥3 ADRs documented"
        echo "  4. Mark complete: bash scripts/check-phase-progress.sh $REPO_PATH phase_5.2_adr_extraction mark-complete"
        ;;

    phase_6_architecture)
        echo "Next steps:"
        echo "  1. Create component architecture docs in agentic/architecture/"
        echo "  2. Document component internals, flows, interactions"
        echo "  3. Mark complete: bash scripts/check-phase-progress.sh $REPO_PATH phase_6_architecture mark-complete"
        ;;

    phase_7_validation)
        echo "Next steps:"
        echo "  1. Run pre-validation: bash scripts/check-phase-progress.sh $REPO_PATH check"
        echo "  2. Run strict validation: bash scripts/validate-categories.sh $REPO_PATH --strict"
        echo "  3. Fix any issues found"
        echo "  4. Mark complete: bash scripts/check-phase-progress.sh $REPO_PATH phase_7_validation mark-complete"
        ;;

    *)
        echo "Unknown phase: $next_phase"
        ;;
esac

echo ""
echo "Track all progress:"
echo "  bash scripts/check-phase-progress.sh $REPO_PATH list"
echo ""
