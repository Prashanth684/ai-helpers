---
description: Create OpenShift feature specifications following enhancement template and agentic patterns
---

## Name
agentic-docs-maintainer:spec

## Synopsis
```
/agentic-docs-maintainer:spec [feature-description] [--component <name>[,<name>...]] [--feedback "text"] [--auto-approve] [--max-retries N]
```

## Description
Creates a comprehensive feature specification following the OpenShift enhancement template and agentic documentation patterns. Automatically fetches relevant patterns from Tier 1 (ecosystem hub) and Tier 2 (component docs) to ensure specs follow current OpenShift best practices.

**Key Innovations**: 
- **Pattern-driven**: Uses `/fetch` to retrieve OpenShift patterns before creating specs
- **Human-in-the-loop**: Pauses at approval gates for review and iterative refinement
- **Revision support**: Accepts feedback and regenerates until approved

**Multi-component support**: For features spanning multiple operators, specify comma-separated components or let the skill auto-detect from your description.

## Arguments

- `[feature-description]`: Brief description of what you're building (optional, will prompt if not provided)
- `--component <name>[,<name>...]`: Component repository name(s)
  - Single component: `machine-config-operator`
  - Multiple components: `machine-config-operator,cluster-network-operator`
  - Fetches architecture and patterns from all specified components
- `--feedback "text"`: Revision feedback from previous attempt (optional, used for iterative refinement)
- `--auto-approve`: Skip approval gate and proceed directly (optional, default: false)
- `--max-retries N`: Maximum revision attempts before giving up (optional, default: 3)

## When to Use

- Starting a new operator feature
- Adding a new CRD or API to openshift/api
- Making architectural changes to OpenShift components
- Proposing enhancements in openshift/enhancements
- Need to align with OpenShift design philosophy and patterns

**When NOT to use**: 
- Single-line fixes or typos
- Changes that don't need a spec (already spec'd in enhancement)
- Non-OpenShift projects

## How It Works

### Phase 0: Automatic Pattern Retrieval

```bash
# Automatically fetches relevant patterns
📚 Fetching OpenShift design philosophy...
📡 Fetching webhook validation patterns...
📡 Fetching component architecture...
🔍 Finding similar implementations...
```

### What Gets Fetched

**Always**:
- DESIGN_PHILOSOPHY.md (core principles)
- Relevant operator patterns (controller-runtime, status-conditions, etc.)
- Engineering practices (testing, security, reliability)
- ADRs (architectural constraints)

**If --component specified**:
- Component architecture from Tier 2
- Component-specific patterns
- Similar implementations in component

### Output

Creates a comprehensive spec with 12 sections:
1. **Objective** - What, why, success criteria
2. **Technical Design** - API, controller, validation
3. **Testing Strategy** - Unit/integration/E2E (60/30/10)
4. **Security** - STRIDE threat model, RBAC
5. **Reliability & Observability** - Metrics, SLO, must-gather
6. **Upgrade Strategy** - Version compat, migration
7. **Dependencies** - Tier 1/Tier 2 deps, ADRs
8. **Implementation Plan** - High-level timeline
9. **Compliance Checklist** - Operator patterns + practices
10. **Open Questions** - Need human input
11. **References** - All fetched docs + official docs
12. **Validation Gates** - Approval checklist

## Examples

### Example 1: Simple Feature
```bash
/agentic-docs-maintainer:spec "Add webhook validation for MachineConfigPool"
```

**What happens:**
```
📚 Fetching patterns...
  ✅ DESIGN_PHILOSOPHY.md
  ✅ platform/operator-patterns/webhooks.md
  ✅ practices/development/api-evolution.md
  ✅ practices/testing/pyramid.md
  ✅ practices/security/threat-modeling.md

📝 Creating spec...
  ✅ SPEC-machineconfig-webhook-validation.md

🎯 Ready for review!
```

### Example 2: Component-Specific Feature
```bash
/agentic-docs-maintainer:spec "Node drain timeout configuration" \
  --component machine-config-operator
```

**What happens:**
```
📚 Fetching Tier 1 patterns...
  ✅ DESIGN_PHILOSOPHY.md
  ✅ platform/operator-patterns/controller-runtime.md
  ✅ platform/operator-patterns/upgrade-strategies.md

📡 Fetching Tier 2 architecture...
  ✅ machine-config-operator/agentic/AGENTS.md
  ✅ machine-config-operator/agentic/architecture/components.md

📝 Creating spec...
  ✅ SPEC-node-drain-timeout.md
  ✅ machine-config-operator/agentic/exec-plans/active/node-drain-timeout.md

🎯 Ready for review!
```

### Example 3: Cross-Component Feature (Auto-Detected)
```bash
/agentic-docs-maintainer:spec "Coordinate node reboots across operators"
```

**What happens:**
```
🌐 Cross-component feature detected from description
📚 Fetching Tier 1 patterns...
  ✅ DESIGN_PHILOSOPHY.md (platform-wide coordination)
  ✅ platform/operator-patterns/upgrade-strategies.md
  ✅ decisions/adr-0003-cvo-upgrade-ordering.md

🔍 Finding similar implementations...
  - machine-config-operator: Node drain coordination
  - cluster-network-operator: SDN/OVN migration coordination

📝 Creating cross-component spec...
  ✅ SPEC-node-reboot-coordination.md
  ✅ Marked as: Tier 1 Platform (affects multiple components)

🎯 Ready for enhancement PR in openshift/enhancements!
```

### Example 4: Multi-Component Feature (Explicit)
```bash
/agentic-docs-maintainer:spec "Network isolation during node updates" \
  --component machine-config-operator,cluster-network-operator
```

**What happens:**
```
🌐 Multi-component feature: fetching from multiple repos
📚 Fetching Tier 1 patterns...
  ✅ DESIGN_PHILOSOPHY.md
  ✅ platform/operator-patterns/upgrade-strategies.md
  ✅ practices/security/network-isolation.md

📡 Fetching from: machine-config-operator
  ✅ machine-config-operator/agentic/AGENTS.md
  ✅ machine-config-operator/agentic/architecture/node-updates.md

📡 Fetching from: cluster-network-operator
  ✅ cluster-network-operator/agentic/AGENTS.md
  ✅ cluster-network-operator/agentic/architecture/network-policies.md

📝 Creating multi-component spec...
  ✅ SPEC-network-isolation-node-updates.md
  ✅ Implementation spans: MCO (node cordoning) + CNO (network policies)

🎯 Ready for review!
```

### Example 5: Approval Gate with Revision
```bash
/agentic-docs-maintainer:spec "dynamic ImageStream importMode" \
  --component cluster-version-operator
```

**What happens:**
```
📚 Fetching patterns...
  ✅ DESIGN_PHILOSOPHY.md
  ✅ controller-runtime.md
  ✅ cluster-version-operator/agentic/AGENTS.md

📝 Creating spec...
  ✅ SPEC-dynamic-imagestream-importmode.md (Attempt 1/3)

════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Generated
════════════════════════════════════════════════════════════════

📄 SPEC-dynamic-imagestream-importmode.md created

Please review and respond:
  • "approve" → I'll create exec-plan
  • "revise: <feedback>" → I'll regenerate
  • "abort" → I'll stop

════════════════════════════════════════════════════════════════
```

**User requests revision:**
```
User: revise: The technical design doesn't explain how registry-operator 
      reads the architecture field from ClusterVersion CR. Add code examples.
```

**Agent re-generates with feedback:**
```
=== Revision (Attempt 2/3) ===

Applying feedback:
"The technical design doesn't explain how registry-operator reads..."

Updated sections:
  ✓ Technical Design > Component Interaction (lines 245-350)
  ✓ Added code example: registry-operator ClusterVersion watcher
  ✓ Added data flow diagram

════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Revised
════════════════════════════════════════════════════════════════

📄 SPEC-dynamic-imagestream-importmode.md revised

Changes made:
  ✓ Component interaction subsection added (105 lines)
  ✓ Code example from registry-operator
  ✓ Data flow diagram

Please review and respond:
  • "approve" → I'll create exec-plan
  • "revise: <feedback>" → I'll regenerate (1 attempt left)
  • "abort" → I'll stop

════════════════════════════════════════════════════════════════
```

**User approves:**
```
User: looks good

Agent:
✓ Specification approved

📄 Spec Approved: SPEC-dynamic-imagestream-importmode.md
📋 Exec-Plan Created: cluster-version-operator/agentic/exec-plans/active/dynamic-imagestream-importmode.md

🎯 Next Step: Run `/plan SPEC-dynamic-imagestream-importmode.md`
```

## Spec Structure

The generated spec includes:

### 1. Objective (What & Why)
- Feature description
- OpenShift design principle alignment
- User stories
- Testable success criteria

### 2. Technical Design (How)
- API changes (CRD definition, openshift/api PR)
- Controller implementation (Reconcile() pattern)
- Validation (webhook or in-controller)

### 3. Testing (Proof)
- Testing pyramid: 60% unit, 30% integration, 10% E2E
- Critical test scenarios
- openshift-tests framework usage

### 4. Security (Safety)
- STRIDE threat model
- RBAC design (least privilege)
- Input validation strategy

### 5. Reliability (Operations)
- Prometheus metrics
- SLO definition
- Must-gather integration

### 6. Upgrade (Safety)
- Version compatibility (N → N+1)
- Migration strategy
- Rollback plan

### 7. Dependencies (Constraints)
- Tier 1 dependencies
- Component dependencies
- Relevant ADRs

### 8. Implementation Plan (Timeline)
- High-level phases
- Week-by-week breakdown
- Risk assessment

### 9. Compliance (Standards)
- ✅ Operator patterns: 8 required checks
- ✅ Engineering practices: 7 required checks
- ✅ Component patterns: Component-specific checks

### 10. Open Questions (Clarify)
- Things needing human input
- Assumptions to validate

### 11. References (Sources)
- All fetched documentation
- Official OpenShift docs
- Similar implementations

### 12. Validation Gates (Approval)
- Spec completeness checklist
- Human review checklist

## Benefits

### For Feature Developers
1. **Comprehensive**: Covers all aspects (API, testing, security, upgrades)
2. **Compliant**: Follows current OpenShift patterns automatically
3. **Guided**: Fetched patterns provide examples and best practices
4. **Fast**: Auto-generates structure, just fill in specifics

### For Reviewers
1. **Consistent**: All specs follow same structure
2. **Complete**: Compliance checklist ensures nothing missed
3. **Traceable**: References show which patterns were followed
4. **Actionable**: Clear validation gates for approval

### For Platform
1. **Quality**: Features follow documented patterns
2. **Maintainable**: Consistent structure across components
3. **Upgradeable**: Upgrade strategy baked in
4. **Observable**: Metrics and must-gather required

## Integration with Other Skills

**Full Workflow:**
```bash
# 1. CREATE SPEC (this command)
/agentic-docs-maintainer:spec "feature" --component myoperator
→ Spec created with fetched patterns

# 2. PLAN IMPLEMENTATION
/agentic-docs-maintainer:plan
→ Breaks spec into ordered tasks

# 3. BUILD INCREMENTALLY
/agentic-docs-maintainer:build
→ Implements tasks following patterns

# 4. TEST COMPREHENSIVELY
/agentic-docs-maintainer:test
→ Verifies compliance with testing pyramid

# 5. REVIEW FOR QUALITY
/agentic-docs-maintainer:review
→ Checks against operator patterns

# 6. SHIP SAFELY
/agentic-docs-maintainer:ship
→ Validates upgrade safety, deploys
```

## Validation

Before advancing to `/plan`:
- ✅ All 12 sections complete
- ✅ Fetched patterns applied
- ✅ Compliance checklist addressed
- ✅ Open questions answered
- ✅ **Human approves spec** ← GATE

## Implementation

Execution handled by skill at: `skills/spec/SKILL.md`

**Key phases:**
1. Phase 0: Fetch patterns (DESIGN_PHILOSOPHY + relevant patterns + component architecture)
2. Phase 1: Clarify requirements (ask questions, surface assumptions)
3. Phase 2: Write specification (12 sections following enhancement template)
4. **Phase 2.5: Approval gate** (pause for review, support revision with feedback)
5. Phase 3: Create exec-plan (if component-specific, after approval)
6. Phase 4: Report results (spec approved and ready for /plan)

**Approval Gate Behavior:**
- **Pause**: Skill exits and waits for user response
- **Detect intent**: Claude recognizes "approve", "revise: <feedback>", or "abort"
- **Iterate**: On "revise", re-invokes skill with feedback parameter
- **Max retries**: Enforces attempt limit (default: 3)

## See Also

- `/agentic-docs-maintainer:fetch` - Pattern retrieval (used internally)
- `/agentic-docs-maintainer:plan` - Task breakdown (next step)
- `/agentic-docs-maintainer:build` - Implementation (after plan)

---

**Pattern**: OpenShift feature specification with automatic pattern retrieval  
**Version**: 1.0
