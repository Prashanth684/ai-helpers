---
name: plan
description: OpenShift implementation planning - breaks down approved spec into ordered, implementable tasks following OpenShift development practices. Use after /spec is approved.
trigger: explicit
model: sonnet
---

# Plan - OpenShift Implementation Planning

## Overview

Break down an approved feature specification into ordered, implementable tasks following OpenShift development practices. Creates a dependency graph and vertical slices with checkpoints for incremental delivery.

**Key Innovation**: Uses `/fetch` to retrieve component architecture and similar implementations before creating the task breakdown.

## What This Skill Operates On

**Input**: SPEC-*.md file + fetched workflow patterns
- SPEC-{feature-name}.md (the specification document)
- Fetched implementation workflow patterns
- Fetched component architecture (code structure)
- Similar feature implementations

**Output**: Implementation plan with tasks + timeline
- PLAN-{feature-name}.md file
- 9 ordered tasks (API → MVP → Status → Validation → Integration → E2E → Observability → Docs)
- 4 checkpoints for validation gates
- Timeline estimate (typically 5 weeks)
- Risk assessment

**Artifacts Created**:
- `PLAN-{feature-name}.md`
- Optional: `{component}/agentic/exec-plans/active/{feature-name}.md`

## When to Use

- After `/spec` is approved and ready for implementation
- Breaking down a large feature into manageable tasks
- Planning implementation timeline and dependencies
- Need structured approach for multi-week projects

**When NOT to use**:
- Spec not yet approved
- Simple one-file changes (just implement directly)
- Bug fixes that don't need planning

**Natural Language**:
- "Create an implementation plan"
- "Break down the spec into tasks"
- "Plan the implementation for this feature"

## Arguments

```bash
/plan [spec-file] [--component <name>] [--feedback "text"] [--auto-approve] [--max-retries N]
```

**Arguments:**
- `[spec-file]`: Path to spec document (optional, will search for SPEC-*.md files)
- `--component <name>`: Component repository name (e.g., machine-config-operator)
- `--feedback "text"`: Revision feedback from previous attempt (optional, used for iterative refinement)
- `--auto-approve`: Skip approval gate and proceed directly (optional, default: false)
- `--max-retries N`: Maximum revision attempts before giving up (optional, default: 3)

**Examples:**
```bash
# Use spec from current directory
/plan

# Specify spec file
/plan SPEC-webhook-validation.md

# Component-specific planning
/plan --component machine-config-operator
```

## Execution Protocol

### Phase 0: Fetch Implementation Patterns

**CRITICAL**: Retrieve implementation guidance BEFORE creating plan.

**Actions:**
```bash
# Step 1: Fetch implementation workflow
echo "📚 Fetching OpenShift implementation patterns..."
/fetch "feature implementation workflow and practices" --tier1-only

# Step 2: Fetch component architecture (if --component specified)
if [ -n "$COMPONENT" ]; then
    echo "📡 Fetching component architecture..."
    /fetch "component architecture and code structure" --tier2 openshift/$COMPONENT
fi

# Step 3: Fetch similar implementations for reference
echo "🔍 Finding similar implementations..."
/fetch "similar feature implementations and patterns" --tier2 openshift/$COMPONENT
```

**Output from Phase 0:**
```markdown
📚 Fetched Patterns:
  ✅ practices/development/implementing-features.md (workflow)
  ✅ practices/development/git-workflow.md (commit strategy)
  ✅ platform/operator-patterns/controller-runtime.md (implementation pattern)
  ✅ $COMPONENT/agentic/architecture/ (component structure)
  
📝 Similar Implementations Found:
  - machine-api-operator: Similar webhook implementation
  - cluster-network-operator: Similar validation pattern
  
🎯 Ready to create implementation plan!
```

### Phase 1: Analyze Dependencies

Read spec and identify dependency order:

**Actions:**
```markdown
## Dependency Analysis

Based on fetched architecture and spec:

### API Changes Required
- [ ] openshift/api PR (CRD definitions)
  - Blocks: All implementation work
  - Estimated: 1 week (API review required)

### Component Changes
Repository: openshift/$COMPONENT

```
pkg/apis/           # API types (depends on openshift/api PR merged)
    ↓
pkg/controller/     # Reconciliation logic
    ↓
pkg/operator/       # Status reporting, operator integration
    ↓
test/unit/          # Unit tests (parallel with implementation)
    ↓
test/integration/   # Integration tests (after controller complete)
    ↓
test/e2e-agnostic/  # E2E tests (after integration tests)
```

### External Dependencies
- controller-runtime: v0.XX.X (check go.mod)
- library-go: vX.XX.X (for helpers)
- openshift/api: Feature branch until PR merges

### Critical Path
```
API PR → Vendor → Basic Controller → Status → Validation → Testing → Observability
```
```

### Phase 2: Create Vertical Slices

Following OpenShift practices (from fetched workflow):

**Actions:**
```markdown
## Implementation Tasks

### Task 1: API Foundation ⏱️ 1 week
**Goal**: Define CRD and get API approval

**Work Items**:
- [ ] 1.1: Define CRD types in openshift/api
  - File: `config/v1/types_myresource.go`
  - Pattern: API evolution (alpha → beta → GA)
  - Validation: kubebuilder markers
- [ ] 1.2: Generate CRD manifests
  - Command: `make update-codegen-crds`
  - Verify: CRD YAML generated
- [ ] 1.3: API review
  - Reviewer: @api-approvers
  - Doc: API changes justification
- [ ] 1.4: Merge openshift/api PR
  - CI: All checks pass
  - Approval: API approvers +1

**Acceptance Criteria**:
- ✅ CRD types merged to openshift/api
- ✅ API review complete
- ✅ No breaking changes to existing APIs

**Depends On**: None (first task)
**Blocks**: Task 2, Task 3 (all implementation)

**Pattern Source**: `practices/development/api-evolution.md`

---

### Task 2: Vendor Dependencies ⏱️ 1 day
**Goal**: Update component to use new API types

**Work Items**:
- [ ] 2.1: Vendor openshift/api
  - Command: `go get github.com/openshift/api@<commit>`
  - Command: `go mod vendor`
- [ ] 2.2: Import new types
  - File: `pkg/apis/imports.go`
  - Add: `_ "github.com/openshift/api/config/v1"`
- [ ] 2.3: Verify build
  - Command: `make build`
  - Verify: No compile errors

**Acceptance Criteria**:
- ✅ Component builds successfully
- ✅ New API types importable

**Depends On**: Task 1 (API PR merged)
**Blocks**: Task 3 (controller implementation)

---

### Task 3: Basic Reconciliation (MVP) ⏱️ 3 days
**Goal**: Minimal viable feature that reports Available=True

**Work Items**:
- [ ] 3.1: Create controller skeleton
  - File: `pkg/controller/myresource/controller.go`
  - Pattern: controller-runtime reconciliation
  - Structure: Fetch → Validate → Reconcile → Update Status
- [ ] 3.2: Implement Reconcile() method
  - Read desired state from CR
  - Apply minimal reconciliation logic
  - Handle errors gracefully
- [ ] 3.3: Set Available=True status
  - Condition type: "Available"
  - Reason: "AsExpected"
  - Message: Descriptive success message
- [ ] 3.4: Unit tests for reconciliation
  - Test: Happy path (reconcile succeeds)
  - Test: Resource not found (no error)
  - Test: Reconcile error (proper handling)
- [ ] 3.5: Wire controller into operator
  - File: `pkg/operator/operator.go`
  - Register: Add controller to manager
  - Watches: Set up watches on relevant resources

**Acceptance Criteria**:
- ✅ Feature reports Available=True when reconciled
- ✅ Unit tests pass (`make test-unit`)
- ✅ Code compiles and runs locally

**Depends On**: Task 2 (vendored dependencies)
**Blocks**: Task 4 (full status reporting)

**Pattern Source**: `platform/operator-patterns/controller-runtime.md`

---

### Task 4: Full Status Reporting ⏱️ 2 days
**Goal**: Implement all required status conditions

**Work Items**:
- [ ] 4.1: Add Progressing condition
  - Set True during reconciliation
  - Set False when reconciliation complete
  - Message: Current operation
- [ ] 4.2: Add Degraded condition
  - Set True on reconcile errors
  - Set False on success
  - Message: Error details
- [ ] 4.3: Add Upgradeable condition
  - Set True when safe to upgrade
  - Set False if blocking operation in progress
  - Message: Upgrade safety status
- [ ] 4.4: Unit tests for all conditions
  - Test: All conditions in success scenario
  - Test: Degraded scenario (error handling)
  - Test: Progressing scenario (in-flight operation)
- [ ] 4.5: Verify ClusterOperator integration
  - Ensure status propagates to ClusterOperator CR
  - Test: Conditions visible via `oc get co`

**Acceptance Criteria**:
- ✅ All 4 conditions (Available/Progressing/Degraded/Upgradeable) implemented
- ✅ Status transitions tested
- ✅ ClusterOperator reflects correct status

**Depends On**: Task 3 (basic reconciliation)
**Blocks**: Task 5 (validation), Task 6 (integration tests)

**Pattern Source**: `platform/operator-patterns/status-conditions.md`

---

### Task 5: Validation & Safety ⏱️ 3 days
**Goal**: Reject invalid configurations, handle errors gracefully

**Work Items**:
- [ ] 5.1: Implement validation logic
  - Validate CR spec fields
  - Return clear error messages
  - Pattern: Early validation, fail fast
- [ ] 5.2: Add validating webhook (if needed)
  - File: `pkg/webhook/validation.go`
  - Implement: ValidateCreate, ValidateUpdate
  - Register: Wire into webhook server
- [ ] 5.3: Error handling
  - Wrap errors with context
  - Set Degraded condition on errors
  - Retry with exponential backoff
- [ ] 5.4: Unit tests for validation
  - Test: Valid config accepted
  - Test: Invalid config rejected
  - Test: Error scenarios handled
- [ ] 5.5: Integration test for webhook
  - Test: Webhook rejects invalid CR
  - Test: Webhook allows valid CR

**Acceptance Criteria**:
- ✅ Invalid configurations rejected
- ✅ Clear error messages provided
- ✅ Webhook tests pass (if applicable)

**Depends On**: Task 4 (status reporting)
**Blocks**: Task 6 (integration tests)

**Pattern Source**: `platform/operator-patterns/webhooks.md`

---

### Task 6: Integration Testing ⏱️ 2 days
**Goal**: Test controller with real/fake Kubernetes API

**Work Items**:
- [ ] 6.1: Integration test - happy path
  - Create CR
  - Verify reconciliation
  - Check status conditions
  - Delete CR
- [ ] 6.2: Integration test - error cases
  - Invalid configuration
  - Reconcile failures
  - Recovery scenarios
- [ ] 6.3: Integration test - upgrades
  - Simulate upgrade scenario
  - Verify Upgradeable condition
  - Test migration (if applicable)
- [ ] 6.4: Run integration tests in CI
  - Command: `make test-integration`
  - Verify: All tests pass

**Acceptance Criteria**:
- ✅ Integration tests cover happy path + error cases
- ✅ Tests pass locally and in CI
- ✅ 30% test coverage from integration tests

**Depends On**: Task 5 (validation complete)
**Blocks**: Task 7 (E2E tests)

**Pattern Source**: `practices/testing/pyramid.md`

---

### Task 7: E2E Testing ⏱️ 3 days
**Goal**: Test full user workflow on real cluster

**Work Items**:
- [ ] 7.1: E2E test - feature installation
  - Deploy operator
  - Create CR
  - Verify feature works
- [ ] 7.2: E2E test - feature usage
  - Exercise key user workflows
  - Verify expected behavior
  - Check observability (logs, metrics)
- [ ] 7.3: E2E test - upgrade N → N+1
  - Install cluster with version N
  - Upgrade to version N+1 (with feature)
  - Verify feature still works
  - Check Upgradeable condition
- [ ] 7.4: Add to openshift-tests
  - File: `test/extended/myfeature.go`
  - Framework: Ginkgo v2
  - Tags: [sig-mycomponent], [Slow]
- [ ] 7.5: Run E2E tests in CI
  - CI job: e2e-agnostic
  - Verify: Tests pass

**Acceptance Criteria**:
- ✅ E2E tests cover critical user workflows
- ✅ Upgrade test passes
- ✅ Tests run in OpenShift CI
- ✅ 10% test coverage from E2E tests

**Depends On**: Task 6 (integration tests)
**Blocks**: Task 8 (observability)

**Pattern Source**: `practices/testing/e2e-framework.md`

---

### Task 8: Observability ⏱️ 2 days
**Goal**: Add metrics, must-gather support

**Work Items**:
- [ ] 8.1: Define Prometheus metrics
  - Metric: `myfeature_reconcile_total` (counter)
  - Metric: `myfeature_reconcile_duration_seconds` (histogram)
  - Metric: `myfeature_reconcile_errors_total` (counter)
- [ ] 8.2: Instrument code
  - Increment counters in reconcile loop
  - Record duration histograms
  - Label errors by type
- [ ] 8.3: Create ServiceMonitor
  - File: `manifests/servicemonitor.yaml`
  - Scrape: Operator metrics endpoint
- [ ] 8.4: Add must-gather support
  - Script: `must-gather/gather_myfeature`
  - Collect: CRs, operator logs, metrics
- [ ] 8.5: Add alerts (if needed)
  - Alert: FeatureDegraded (Degraded=True for >10min)
  - Alert: FeatureReconcileErrors (high error rate)
- [ ] 8.6: Verify metrics scraped
  - Query Prometheus: Metrics visible
  - Test must-gather: Data collected

**Acceptance Criteria**:
- ✅ Metrics defined and scraped
- ✅ Must-gather collects feature data
- ✅ Alerts fire correctly (if defined)

**Depends On**: Task 7 (E2E tests)
**Blocks**: Task 9 (documentation)

**Pattern Source**: `practices/reliability/observability.md`

---

### Task 9: Documentation ⏱️ 2 days
**Goal**: Document feature in Tier 2 agentic docs

**Work Items**:
- [ ] 9.1: Update AGENTS.md
  - Section: Feature overview
  - Describe: What, why, how to use
- [ ] 9.2: Create exec-plan
  - File: `agentic/exec-plans/active/myfeature.md`
  - Include: Implementation plan, status, decisions
- [ ] 9.3: Update architecture docs
  - File: `agentic/architecture/components.md`
  - Diagram: Component interaction
  - Explain: How feature integrates
- [ ] 9.4: Enhancement merged
  - PR: openshift/enhancements
  - Status: Merged and approved
- [ ] 9.5: User-facing docs (if needed)
  - docs.openshift.com PR
  - Procedures, examples, troubleshooting

**Acceptance Criteria**:
- ✅ AGENTS.md updated
- ✅ Exec-plan created
- ✅ Architecture docs accurate
- ✅ Enhancement merged

**Depends On**: Task 8 (observability)
**Blocks**: Ready to ship!

**Pattern Source**: `agentic-docs-maintainer:tier2-component`

---

## Checkpoints

### 🚧 Checkpoint 1: After Task 3 (MVP)
**Validation**:
- [ ] Feature compiles
- [ ] Unit tests pass
- [ ] Feature reports Available=True
- [ ] Human reviews: Basic reconciliation works

**Gate**: Proceed to status reporting only if MVP works

---

### 🚧 Checkpoint 2: After Task 5 (Validation)
**Validation**:
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Feature handles errors gracefully
- [ ] Human reviews: Core functionality complete

**Gate**: Proceed to E2E and observability only if validation works

---

### 🚧 Checkpoint 3: After Task 7 (E2E)
**Validation**:
- [ ] All E2E tests pass in CI
- [ ] Upgrade tests pass
- [ ] Human reviews: Ready for observability

**Gate**: Proceed to final polish only if E2E tests pass

---

### 🚧 Checkpoint 4: After Task 9 (Documentation)
**Validation**:
- [ ] All tests pass (unit, integration, E2E)
- [ ] Metrics working
- [ ] Documentation complete
- [ ] Human reviews: Ready to ship

**Gate**: Proceed to `/ship` skill

---

## Timeline Estimate

Based on fetched patterns and task breakdown:

| Week | Tasks | Deliverable |
|------|-------|-------------|
| **Week 1** | Task 1 | API PR merged |
| **Week 2** | Task 2-3 | MVP (basic reconciliation) |
| **Week 3** | Task 4-5 | Full status + validation |
| **Week 4** | Task 6-7 | Integration + E2E tests |
| **Week 5** | Task 8-9 | Observability + docs |

**Total**: 5 weeks (assumes no blockers)

**Risk Buffer**: +1 week for API review delays, testing issues

---

## Risk Assessment

### High Risk
- **API review delays** → Blocks all implementation
  - Mitigation: Start API PR early, engage reviewers proactively
  
### Medium Risk
- **E2E test flakes** → Blocks shipping
  - Mitigation: Follow test-flake-policy.md, isolate tests properly

### Low Risk
- **Must-gather integration** → Nice-to-have, not blocking
  - Mitigation: Can ship without if timeline tight

---

## Next Steps

1. ✅ Human reviews and approves plan
2. ✅ Create GitHub issues/Jira tickets for each task
3. ✅ Start Task 1 (API foundation)
4. ✅ Proceed to `/build` skill for implementation

---

### Phase 2.5: Approval Gate

**CRITICAL**: After creating the plan, pause for human review unless `--auto-approve` is set.

**Actions:**

```bash
# Check if auto-approve is enabled
if [[ "$AUTO_APPROVE" == "true" ]]; then
    echo "✓ Auto-approve enabled. Skipping review gate."
    # Proceed to final output
else
    # Find the generated plan file
    PLAN_FILE=$(find . -maxdepth 1 -name "PLAN-*.md" -type f | head -1)
    
    # Show approval gate message
    cat <<EOF

════════════════════════════════════════════════════════════════
  REVIEW GATE: Implementation Plan Generated
════════════════════════════════════════════════════════════════

📄 $PLAN_FILE created

Please review the implementation plan and respond:

  • "approve" or "looks good" 
    → I'll finalize and you can proceed to /build
  
  • "revise: <your feedback>"
    → I'll adjust the plan incorporating your feedback
    → Example: "revise: task 3 should be split into two tasks"
  
  • "abort" or "cancel"
    → I'll stop here without proceeding

Key plan elements:
$(grep "^### Task" "$PLAN_FILE" | head -9)

Timeline: $(grep "Total:" "$PLAN_FILE")

════════════════════════════════════════════════════════════════

I'm waiting for your review decision...

EOF
    
    # Exit here - return control to user
    # User will respond in natural language, and Claude will detect their intent
    exit 0
fi
```

**Natural Language Detection:**

When the user responds, Claude Code's conversational layer detects intent:

**Approval phrases** (proceed to finalize):
- "approve", "approved", "LGTM", "looks good", "proceed", "continue", "yes"

**Revision phrases** (re-invoke /plan with feedback):
- "revise: <feedback>"
- "change <feedback>"  
- "update <feedback>"
- "adjust <feedback>"
- "split task X into Y and Z"

**Abort phrases** (stop workflow):
- "abort", "cancel", "stop", "nevermind", "no"

**Revision Flow:**

When revision is detected:
1. Extract feedback from user message
2. Check attempt count (tracked in `.work/plan-state.json`)
3. If attempts < max_retries:
   - Re-invoke: `/plan SPEC-*.md --feedback "user feedback"`
   - Increment attempt count
4. If attempts >= max_retries:
   - Report: "Maximum retries reached. Plan may need manual adjustment."
   - Save final plan and exit

**State Tracking:**

```json
// .work/plan-state.json
{
  "spec_file": "SPEC-dynamic-imagestream-importmode.md",
  "component": "cluster-version-operator",
  "attempt": 2,
  "max_retries": 3,
  "plan_file": "PLAN-dynamic-imagestream-importmode.md",
  "last_feedback": "split task 3 into two tasks"
}
```

---

## Output Format

**Output varies based on approval gate:**

**On First Generation (Paused for Review):**
```
✅ OpenShift Implementation Plan Generated

📄 Plan Created: PLAN-feature.md (Attempt 1/3)

📚 Patterns Fetched:
  ✅ implementing-features.md
  ✅ git-workflow.md
  ✅ component architecture

📊 Plan Summary:
  • 9 tasks defined
  • 4 checkpoints
  • Timeline: 5 weeks
  • Risks identified: 3

════════════════════════════════════════════════════════════════
  REVIEW GATE: Implementation Plan Generated
════════════════════════════════════════════════════════════════

📄 PLAN-feature.md created

Please review and respond:
  • "approve" → I'll finalize
  • "revise: <feedback>" → I'll adjust plan
  • "abort" → I'll stop

════════════════════════════════════════════════════════════════
```

**On Revision (After Feedback Applied):**
```
✅ Implementation Plan Revised (Attempt 2/3)

Feedback applied:
"split task 3 into two tasks: watcher setup and reconciliation"

Changes made:
  ✓ Task 3 split into Task 3a (watcher) and Task 3b (reconcile)
  ✓ Updated dependencies (Task 3b depends on Task 3a)
  ✓ Adjusted timeline (+1 day for parallel work)
  ✓ Updated checkpoint 1 to validate both subtasks

📄 Updated: PLAN-feature.md

════════════════════════════════════════════════════════════════
  REVIEW GATE: Implementation Plan Revised
════════════════════════════════════════════════════════════════

Changes applied. Please review and respond:
  • "approve" → I'll finalize
  • "revise: <feedback>" → I'll adjust again (1 attempt left)
  • "abort" → I'll stop

════════════════════════════════════════════════════════════════
```

**On Approval (Complete):**
```
✅ Implementation Plan Approved

📄 Plan: PLAN-feature.md
📋 Exec-Plan: component/agentic/exec-plans/active/feature.md

🎯 Next Step: Run `/build` to start implementation
```

**On Max Retries:**
```
⚠️  Maximum Retries Reached (3/3)

📄 Final plan saved: PLAN-feature.md

The plan has been revised 3 times but may need manual adjustment.
You can:
  1. Manually edit PLAN-feature.md
  2. Start fresh with new approach
  3. Use current plan as-is (review carefully first)
```

**Created Files**:
- `PLAN-[feature-name].md` - Implementation plan with tasks and timeline
- Optional: `agentic/exec-plans/active/[feature-name].md` - Copy for Tier 2 tracking

**Next Command**:
```bash
/build  # Start implementing tasks
```

---

## Revision Best Practices

**Good Feedback** (Specific, Actionable):
- ✅ "revise: task 3 should be split - watcher setup is independent of reconciliation"
- ✅ "revise: add task for migration strategy before integration tests"
- ✅ "revise: checkpoint 2 is too late - add checkpoint after MVP"

**Poor Feedback** (Vague, Hard to Apply):
- ❌ "revise: make it better"
- ❌ "revise: too complex" (which tasks?)
- ❌ "revise: I don't understand" (what specifically?)

**Common Revision Scenarios:**
- **Split tasks**: "revise: task 5 should be two tasks: validation logic + webhook"
- **Adjust timeline**: "revise: reduce week 3 tasks - too ambitious for parallel work"
- **Add missing task**: "revise: add task for database migration between tasks 4 and 5"
- **Reorder tasks**: "revise: task 7 doesn't depend on task 6 - can run in parallel"
- **Adjust checkpoint**: "revise: move checkpoint 2 to after task 4 instead of task 5"

---

**Pattern Source**: 
- `practices/development/implementing-features.md`
- `practices/development/git-workflow.md`
- Component architecture from Tier 2

**Validation Gate**: Human approval before `/build`
