#!/bin/bash
# Phase progress tracking for Tier 2 skill execution
# Ensures critical phases (2.5 and 5.2) are completed

set -euo pipefail

REPO_PATH="${1:-.}"
PROGRESS_FILE="$REPO_PATH/agentic/.skill-progress.json"
PHASE="${2:-}"
ACTION="${3:-check}"  # check, mark-complete, list

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Initialize progress file if it doesn't exist
init_progress() {
    if [ ! -f "$PROGRESS_FILE" ]; then
        cat > "$PROGRESS_FILE" <<'EOF'
{
  "skill_version": "1.0",
  "started_at": "",
  "phases": {
    "phase_1_discovery": {"status": "not_started", "completed_at": null},
    "phase_2_structure": {"status": "not_started", "completed_at": null},
    "phase_2.5_domain_discovery": {"status": "not_started", "completed_at": null, "critical": true},
    "phase_3_agents_md": {"status": "not_started", "completed_at": null},
    "phase_4_ecosystem_md": {"status": "not_started", "completed_at": null},
    "phase_5_component_guides": {"status": "not_started", "completed_at": null},
    "phase_5.2_adr_extraction": {"status": "not_started", "completed_at": null, "critical": true},
    "phase_6_architecture": {"status": "not_started", "completed_at": null},
    "phase_7_validation": {"status": "not_started", "completed_at": null}
  }
}
EOF
        # Set started_at timestamp
        TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
        sed -i "s/\"started_at\": \"\"/\"started_at\": \"$TIMESTAMP\"/" "$PROGRESS_FILE"
    fi
}

# Mark phase as complete
mark_complete() {
    local phase="$1"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Update status to complete and set timestamp
    sed -i "s/\"$phase\": {\"status\": \"[^\"]*\"/\"$phase\": {\"status\": \"complete\"/" "$PROGRESS_FILE"
    sed -i "s/\"$phase\": {\"status\": \"complete\", \"completed_at\": [^,}]*/\"$phase\": {\"status\": \"complete\", \"completed_at\": \"$timestamp\"/" "$PROGRESS_FILE"
}

# Check if critical phases are complete
check_critical() {
    if [ ! -f "$PROGRESS_FILE" ]; then
        echo -e "${RED}❌ No progress file found - run create-structure.sh first${NC}"
        return 1
    fi

    # Check Phase 2.5 (Domain Discovery)
    phase_2_5_status=$(grep "phase_2.5_domain_discovery" "$PROGRESS_FILE" | sed 's/.*"status": "\([^"]*\)".*/\1/')

    # Check Phase 5.2 (ADR Extraction)
    phase_5_2_status=$(grep "phase_5.2_adr_extraction" "$PROGRESS_FILE" | sed 's/.*"status": "\([^"]*\)".*/\1/')

    echo "🔍 Critical Phase Status Check"
    echo "==============================="
    echo ""

    CRITICAL_INCOMPLETE=0

    if [ "$phase_2_5_status" != "complete" ]; then
        echo -e "${RED}❌ Phase 2.5: Domain Discovery - NOT COMPLETE${NC}"
        echo "   This phase is CRITICAL (≥4 domain concepts required)"
        echo "   See SKILL.md lines 455-672 for checklist"
        echo ""
        CRITICAL_INCOMPLETE=1
    else
        echo -e "${GREEN}✅ Phase 2.5: Domain Discovery - COMPLETE${NC}"
        completed_at=$(grep "phase_2.5_domain_discovery" "$PROGRESS_FILE" | sed 's/.*"completed_at": "\([^"]*\)".*/\1/')
        echo "   Completed at: $completed_at"
        echo ""
    fi

    if [ "$phase_5_2_status" != "complete" ]; then
        echo -e "${RED}❌ Phase 5.2: ADR Extraction - NOT COMPLETE${NC}"
        echo "   This phase is CRITICAL (≥3 ADRs required)"
        echo "   See SKILL.md lines 955-1236 for checklist"
        echo ""
        CRITICAL_INCOMPLETE=1
    else
        echo -e "${GREEN}✅ Phase 5.2: ADR Extraction - COMPLETE${NC}"
        completed_at=$(grep "phase_5.2_adr_extraction" "$PROGRESS_FILE" | sed 's/.*"completed_at": "\([^"]*\)".*/\1/')
        echo "   Completed at: $completed_at"
        echo ""
    fi

    if [ $CRITICAL_INCOMPLETE -eq 1 ]; then
        echo -e "${RED}⚠️  CRITICAL PHASES INCOMPLETE${NC}"
        echo ""
        echo "Cannot proceed to validation without completing critical phases."
        echo "These phases ensure minimum content requirements (≥4 domain concepts, ≥3 ADRs)"
        return 1
    else
        echo -e "${GREEN}✅ All critical phases complete${NC}"
        return 0
    fi
}

# List all phases and their status
list_progress() {
    if [ ! -f "$PROGRESS_FILE" ]; then
        echo "No progress file found"
        return 1
    fi

    echo "📋 Tier 2 Skill Execution Progress"
    echo "==================================="
    echo ""

    started_at=$(grep "started_at" "$PROGRESS_FILE" | cut -d'"' -f4)
    echo "Started: $started_at"
    echo ""

    echo "Phases:"
    echo "-------"

    # Parse and display each phase
    grep -E "phase_[0-9]|phase_[0-9]\.[0-9]" "$PROGRESS_FILE" | while read -r line; do
        phase_name=$(echo "$line" | cut -d'"' -f2)
        status=$(echo "$line" | grep -o '"status": "[^"]*"' | cut -d'"' -f4 || echo "unknown")
        is_critical=$(echo "$line" | grep -q '"critical": true' && echo " ⭐ CRITICAL" || echo "")

        # Format phase name
        phase_display=$(echo "$phase_name" | sed 's/_/ /g' | sed 's/phase/Phase/')

        # Color based on status
        if [ "$status" = "complete" ]; then
            echo -e "  ${GREEN}✅${NC} $phase_display$is_critical"
        elif [ "$status" = "in_progress" ]; then
            echo -e "  ${YELLOW}⏳${NC} $phase_display$is_critical"
        else
            echo -e "  ⬜ $phase_display$is_critical"
        fi
    done

    echo ""
}

# Main execution
case "$ACTION" in
    init)
        init_progress
        echo "✅ Progress tracking initialized at $PROGRESS_FILE"
        ;;

    mark-complete)
        if [ -z "$PHASE" ]; then
            echo "Error: Phase name required"
            echo "Usage: $0 <repo-path> <phase-name> mark-complete"
            exit 1
        fi
        init_progress
        mark_complete "$PHASE"
        echo "✅ Phase $PHASE marked complete"
        ;;

    check)
        check_critical
        ;;

    list)
        list_progress
        ;;

    *)
        echo "Usage: $0 <repo-path> [phase-name] [action]"
        echo ""
        echo "Actions:"
        echo "  init           - Initialize progress tracking"
        echo "  mark-complete  - Mark phase as complete (requires phase-name)"
        echo "  check          - Check critical phase completion (default)"
        echo "  list           - List all phases and their status"
        echo ""
        echo "Phase names:"
        echo "  phase_1_discovery"
        echo "  phase_2_structure"
        echo "  phase_2.5_domain_discovery  (CRITICAL)"
        echo "  phase_3_agents_md"
        echo "  phase_4_ecosystem_md"
        echo "  phase_5_component_guides"
        echo "  phase_5.2_adr_extraction    (CRITICAL)"
        echo "  phase_6_architecture"
        echo "  phase_7_validation"
        exit 1
        ;;
esac
