---
name: review
description: OpenShift code review - checks implementation against operator patterns, practices, and component standards. Five-axis review (correctness, maintainability, testing, security, operability). Use before /ship.
trigger: explicit
model: sonnet
---

# Review - OpenShift Code Review

## Overview

Review implementation for OpenShift compliance across five axes: correctness, maintainability, testing, security, and operability. Checks against operator patterns, engineering practices, and component-specific standards.

**Key Innovation**: Uses `/fetch` to retrieve review criteria from agentic documentation and verify compliance automatically.

## What This Skill Operates On

**Input**: Actual codebase (static analysis of existing code)
- All Go files: `pkg/`, `cmd/`, `test/`
- Configuration: Makefiles, YAML manifests
- Git history: Commit messages, branch state
- Fetched patterns: Operator patterns, practices, component standards

**Output**: Review report with score /100
- Five-axis scores (correctness, maintainability, testing, security, operability)
- Compliance checklists (operator patterns, engineering practices)
- Action items (Must Fix, Should Fix, Nice to Have)
- Approval status

**Artifacts Created**:
- Review report (Markdown)
- Action item list

## When to Use

- After `/test` passes and before `/ship`
- Before creating PR for review
- Self-review against OpenShift standards
- Automated compliance checking

**Natural Language**:
- "Review my code for OpenShift compliance"
- "Check if my implementation follows operator patterns"
- "Is this ready for PR?"
- "Run a code review"

## Arguments

```bash
/review [--component <name>] [--fix-auto] [--feedback "text"] [--auto-approve] [--max-retries N]
```

**Arguments:**
- `--component <name>`: Component name for component-specific checks
- `--fix-auto`: Automatically fix linter issues where possible
- `--feedback "text"`: Revision feedback from previous attempt (optional, used to address review findings)
- `--auto-approve`: Skip approval gate and proceed to /ship (optional, default: false)
- `--max-retries N`: Maximum fix attempts before giving up (optional, default: 3)

## Execution Protocol

### Phase 0: Fetch Review Criteria

```bash
# Fetch operator pattern compliance
/fetch "operator patterns and compliance checklist" --tier1-only

# Fetch engineering practices
/fetch "code review best practices and standards" --tier1-only

# Fetch component-specific patterns (if applicable)
if [ -n "$COMPONENT" ]; then
    /fetch "component code patterns and standards" --tier2 openshift/$COMPONENT
fi
```

**Output:**
```markdown
📚 Fetched Review Criteria:
  ✅ platform/operator-patterns/ (8 patterns)
  ✅ practices/development/code-review.md
  ✅ practices/security/threat-modeling.md
  ✅ $COMPONENT/agentic/patterns/ (component standards)
  
🎯 Ready to review!
```

---

## Five-Axis Review

### Axis 1: Correctness - Does It Work?

**Criteria from Operator Patterns**:

```markdown
## Controller Runtime Pattern
- [x] Implements Reconcile(ctx, req) signature
- [x] Uses client.IgnoreNotFound() for deleted resources
- [x] Returns (ctrl.Result{}, error) correctly
- [x] Requeue on transient errors
- [x] Idempotent reconciliation logic

**Pattern**: `platform/operator-patterns/controller-runtime.md`

## Status Conditions Pattern
- [x] Implements Available condition
- [x] Implements Progressing condition
- [x] Implements Degraded condition
- [x] Implements Upgradeable condition
- [x] Uses metav1.Condition type
- [x] Sets LastTransitionTime correctly
- [x] Meaningful Reason and Message fields

**Pattern**: `platform/operator-patterns/status-conditions.md`

## Webhooks Pattern (if applicable)
- [x] Implements ValidateCreate()
- [x] Implements ValidateUpdate()
- [x] Returns admission.Allowed() or admission.Denied()
- [x] Clear error messages for validation failures
- [x] Webhook registered in ValidatingWebhookConfiguration

**Pattern**: `platform/operator-patterns/webhooks.md`

## RBAC Pattern
- [x] ServiceAccount defined
- [x] ClusterRole with minimal permissions
- [x] ClusterRoleBinding links SA to Role
- [x] No wildcard permissions (*/*)
- [x] Follows least privilege principle

**Pattern**: `platform/operator-patterns/rbac-patterns.md`
```

---

### Axis 2: Maintainability - Can It Be Understood?

**Criteria from Development Practices**:

```markdown
## Code Style
- [x] gofmt formatted
- [x] golint passes (no warnings)
- [x] go vet passes
- [x] Follows component naming conventions
- [x] Consistent with existing codebase

## Comments
- [x] Comments explain "why", not "what"
- [x] Public functions have godoc comments
- [x] Complex logic has explanatory comments
- [x] No commented-out code
- [x] TODO comments have owner/ticket

## Naming
- [x] Variable names descriptive
- [x] Function names match Go conventions
- [x] Struct names match domain concepts
- [x] Constants use correct casing

## Structure
- [x] Functions are small (<50 lines)
- [x] Files are focused (<500 lines)
- [x] Packages are cohesive
- [x] Dependencies are minimal

**Pattern**: `practices/development/code-review.md`
```

---

### Axis 3: Testing - Is It Proven?

**Criteria from Testing Pyramid**:

```markdown
## Test Coverage
- [x] Unit tests: ≥60% of test suite
- [x] Integration tests: ~30% of test suite
- [x] E2E tests: ~10% of test suite
- [x] Total coverage: ≥70% code coverage

## Test Quality
- [x] Tests follow arrange-act-assert pattern
- [x] Test names descriptive (TestFunction_Scenario)
- [x] Table-driven tests where appropriate
- [x] Tests are isolated (no shared state)
- [x] Tests clean up resources

## Critical Paths Tested
- [x] Happy path (successful reconciliation)
- [x] Resource not found (deletion)
- [x] Reconcile errors (degraded state)
- [x] Validation failures
- [x] Upgrade scenarios

## CI Integration
- [x] Tests pass in Prow
- [x] No flaky tests
- [x] Tests run on all supported platforms

**Pattern**: `practices/testing/pyramid.md`
```

---

### Axis 4: Security - Is It Safe?

**Criteria from Security Practices**:

```markdown
## STRIDE Threat Model
- [x] Spoofing addressed (authentication)
- [x] Tampering addressed (validation, RBAC)
- [x] Repudiation addressed (audit logs)
- [x] Information disclosure addressed (no secrets in logs)
- [x] Denial of service addressed (rate limiting, resource limits)
- [x] Elevation of privilege addressed (least privilege RBAC)

## Input Validation
- [x] All user inputs validated
- [x] Validation errors clear and actionable
- [x] No injection vulnerabilities (SQL, command, etc.)
- [x] Safe defaults used

## Secrets Management
- [x] No secrets in code
- [x] No secrets in logs
- [x] Secrets loaded from Secrets API
- [x] Secrets not exposed in status

## RBAC
- [x] Minimal permissions granted
- [x] No cluster-admin unless absolutely required
- [x] Service account dedicated to feature
- [x] Permissions scoped to namespaces where possible

**Pattern**: `practices/security/threat-modeling.md`
```

---

### Axis 5: Operability - Will It Run Well?

**Criteria from Reliability Practices**:

```markdown
## Observability
- [x] Prometheus metrics defined
- [x] Metrics cover reconcile rate, duration, errors
- [x] ServiceMonitor created
- [x] Metrics scraped and visible
- [x] Logs structured and meaningful
- [x] Log levels appropriate (Debug/Info/Warning/Error)

## Must-Gather
- [x] Must-gather script created
- [x] Collects feature CRs
- [x] Collects operator logs
- [x] Collects relevant metrics
- [x] Script tested and works

## Alerts (if applicable)
- [x] Critical alerts defined
- [x] Alerts actionable
- [x] Runbooks provided
- [x] Alerts tested

## Upgrades
- [x] Upgradeable condition implemented
- [x] Handles version N → N+1
- [x] Migration code (if CRD changes)
- [x] Rollback tested
- [x] No breaking API changes (or properly versioned)

## Resource Management
- [x] CPU/Memory limits set
- [x] No resource leaks
- [x] Graceful handling of resource exhaustion

**Pattern**: `practices/reliability/observability.md`
```

---

## Review Output

```markdown
# Code Review: MyFeature

## Summary
- **Overall**: 🟢 PASS (94/100 criteria met)
- **Blocking Issues**: 0
- **Warnings**: 6

---

## Axis 1: Correctness ✅
Score: 20/20

- ✅ Controller runtime pattern followed
- ✅ Status conditions implemented correctly
- ✅ RBAC minimal and correct

---

## Axis 2: Maintainability ✅
Score: 18/20

- ✅ Code style consistent
- ✅ Comments appropriate
- ✅ Naming follows conventions
- ⚠️  Function `reconcileComplex()` is 75 lines (recommend <50)
- ⚠️  File `controller.go` is 620 lines (recommend <500)

**Recommendations**:
1. Split `reconcileComplex()` into smaller functions
2. Consider splitting `controller.go` into `controller.go` and `status.go`

---

## Axis 3: Testing ✅
Score: 19/20

- ✅ Testing pyramid compliance (60/29/11)
- ✅ Critical paths tested
- ✅ Tests pass in CI
- ⚠️  Integration tests 1% below target (29% vs 30%)

**Recommendation**:
- Add 1 integration test for upgrade scenario

---

## Axis 4: Security ✅
Score: 20/20

- ✅ STRIDE analysis complete
- ✅ Input validation present
- ✅ No secrets in logs
- ✅ RBAC follows least privilege

---

## Axis 5: Operability 🟡
Score: 17/20

- ✅ Prometheus metrics defined
- ✅ Must-gather support added
- ✅ Upgradeable condition works
- ⚠️  ServiceMonitor not tested (recommend verify scraping)
- ⚠️  No alerts defined (consider if feature is critical)
- ⚠️  Resource limits not set in deployment

**Recommendations**:
1. Verify ServiceMonitor in test cluster
2. Consider alert for FeatureDegraded
3. Set reasonable CPU/memory limits

---

## Compliance Checklist

### Operator Patterns (8/8) ✅
- [x] Controller-runtime reconciliation
- [x] Status conditions
- [x] Leader election
- [x] Finalizers (N/A for this feature)
- [x] Webhooks (if needed)
- [x] RBAC patterns
- [x] Upgrade safety
- [x] Must-gather

### Engineering Practices (6/7) 🟡
- [x] Testing pyramid (60/30/10)
- [x] STRIDE threat model
- [x] SLO defined
- [x] CI integration (Prow)
- [x] ADRs documented
- [x] Git workflow (atomic commits)
- [ ] Resource limits set ⚠️

### Component Patterns (if applicable)
[Checklist from component agentic/ docs]

---

## Action Items

### Must Fix (Blocking)
*None* ✅

### Should Fix (Before Merge)
1. Set CPU/memory limits in deployment
2. Verify ServiceMonitor scraping works
3. Add 1 integration test for 30% target

### Nice to Have (Future PR)
1. Refactor `reconcileComplex()` to smaller functions
2. Split `controller.go` into multiple files
3. Consider adding FeatureDegraded alert

---

## Approval Status

- ✅ **APPROVED** for merge
- Conditions: Fix "Should Fix" items before merge
- Next: `/ship` after fixes applied

---

**Reviewed against**:
- platform/operator-patterns/ (all patterns)
- practices/ (all practices)
- $COMPONENT/agentic/patterns/
```

---

## Auto-Fixable Issues

If `--fix-auto` flag used:

```bash
# Auto-fix code formatting
gofmt -w pkg/
go mod tidy

# Auto-fix imports
goimports -w pkg/

# Auto-fix simple linter issues
golangci-lint run --fix

echo "✅ Auto-fixed 12 issues"
echo "⚠️  6 issues require manual fix"
```

---

## Approval Gate

**CRITICAL**: After completing review, pause for human decision unless `--auto-approve` is set.

**Actions:**

```bash
# Check if auto-approve is enabled
if [[ "$AUTO_APPROVE" == "true" ]]; then
    echo "✓ Auto-approve enabled. Proceeding to /ship."
else
    # Calculate overall score
    OVERALL_SCORE=$(( (CORRECTNESS + MAINTAINABILITY + TESTING + SECURITY + OPERABILITY) ))
    
    # Show approval gate message
    cat <<EOF

════════════════════════════════════════════════════════════════
  REVIEW GATE: Code Review Complete
════════════════════════════════════════════════════════════════

📊 Review Scores:
  • Correctness: $CORRECTNESS/20 $(if [ $CORRECTNESS -ge 16 ]; then echo "✅"; else echo "⚠️"; fi)
  • Maintainability: $MAINTAINABILITY/20 $(if [ $MAINTAINABILITY -ge 16 ]; then echo "✅"; else echo "⚠️"; fi)
  • Testing: $TESTING/20 $(if [ $TESTING -ge 16 ]; then echo "✅"; else echo "⚠️"; fi)
  • Security: $SECURITY/20 $(if [ $SECURITY -ge 16 ]; then echo "✅"; else echo "⚠️"; fi)
  • Operability: $OPERABILITY/20 $(if [ $OPERABILITY -ge 16 ]; then echo "✅"; else echo "⚠️"; fi)

Overall Score: $OVERALL_SCORE/100 $(if [ $OVERALL_SCORE -ge 80 ]; then echo "✅ PASS"; else echo "❌ FAIL"; fi)

Action Items:
  • Must Fix: $MUST_FIX_COUNT issues
  • Should Fix: $SHOULD_FIX_COUNT issues
  • Nice to Have: $NICE_TO_HAVE_COUNT suggestions

Please review the findings and respond:

  • "approve" or "looks good" 
    → I'll proceed to /ship (if score >= 80)
  
  • "revise: <your feedback>"
    → I'll address the review findings
    → Example: "revise: fix the 3 security issues in pkg/controller"
  
  • "abort" or "cancel"
    → I'll stop here without proceeding

Top Issues:
$(list_top_issues | head -5)

════════════════════════════════════════════════════════════════

$(if [ $OVERALL_SCORE -lt 80 ]; then
    echo "⚠️  WARNING: Score below 80 - recommend fixing issues before shipping"
fi)

Waiting for your review decision...

EOF
    
    # Exit here - return control to user
    exit 0
fi
```

**Natural Language Detection:**

When the user responds, Claude Code's conversational layer detects intent:

**Approval phrases** (proceed to /ship):
- "approve", "approved", "LGTM", "looks good", "proceed", "continue", "ship it"

**Revision phrases** (fix review findings):
- "revise: <feedback>"
- "fix <feedback>"  
- "address <feedback>"
- "improve <feedback>"

**Abort phrases** (stop workflow):
- "abort", "cancel", "stop", "nevermind", "not ready"

**Revision Flow:**

When revision is detected:
1. Extract feedback from user message
2. Check attempt count (tracked in `.work/review-state.json`)
3. If attempts < max_retries:
   - Re-invoke: `/review --feedback "user feedback"`
   - Address identified issues
   - Re-run review
   - Generate updated report
4. If attempts >= max_retries:
   - Report: "Maximum retries reached. Issues may need manual review."
   - Save current state and exit

**State Tracking:**

```json
// .work/review-state.json
{
  "attempt": 2,
  "max_retries": 3,
  "last_feedback": "fix the 3 security issues in pkg/controller",
  "overall_score": 75,
  "scores": {
    "correctness": 18,
    "maintainability": 16,
    "testing": 19,
    "security": 12,
    "operability": 10
  },
  "must_fix_count": 3,
  "should_fix_count": 5
}
```

---

## Validation

Before advancing to `/ship`:
1. ✅ All 5 axes reviewed
2. ✅ No blocking issues (Must Fix: 0)
3. ✅ Overall score >= 80/100
4. ✅ Compliance checklist complete
5. ✅ Action items tracked
6. ✅ Human approves

---

**Pattern Source**:
- `platform/operator-patterns/` (all)
- `practices/development/code-review.md`
- `practices/security/threat-modeling.md`
- `practices/reliability/observability.md`
- Component-specific patterns

**Validation Gate**: Pass review before `/ship`
