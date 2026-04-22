---
name: ship
description: OpenShift safe deployment - validates upgrade strategy, creates PR, verifies CI, and ships with rollback plan. Use after /review passes. Final step in workflow.
trigger: explicit
model: sonnet
---

# Ship - OpenShift Safe Deployment

## Overview

Deploy feature safely with upgrade strategy validation, PR creation, CI verification, and rollback plan. Final step in the OpenShift development workflow.

**Key Innovation**: Uses `/fetch` to retrieve upgrade strategies and shipping checklists, ensuring safe deployment.

## What This Skill Operates On

**Input**: Actual codebase + git state + CI status
- All code files (for pre-ship validation)
- Git state: Current branch, commits, uncommitted changes
- Test results: CI status from Prow
- Fetched patterns: Upgrade strategies, shipping checklist, rollback procedures

**Output**: PR created + rollback plan
- GitHub Pull Request with comprehensive description
- CI monitoring status
- Rollback plan document
- Deployment verification steps

**Artifacts Created**:
- GitHub PR (via `gh pr create`)
- Rollback plan document
- Pre-ship validation report

## When to Use

- After `/review` passes with no blocking issues
- Ready to create PR and ship feature
- Need upgrade validation and rollback plan
- Final step before deployment

**Natural Language**:
- "Ship this feature"
- "Create a PR for this implementation"
- "I'm ready to deploy"
- "Ship my changes with upgrade validation"

## Arguments

```bash
/ship [--dry-run] [--skip-upgrade-test] [--feedback "text"] [--auto-approve] [--max-retries N]
```

**Arguments:**
- `--dry-run`: Validate readiness without creating PR
- `--skip-upgrade-test`: Skip upgrade test (not recommended)
- `--feedback "text"`: Revision feedback from previous attempt (optional, used to address shipping issues)
- `--auto-approve`: Skip approval gates (optional, default: false - NOT RECOMMENDED for production)
- `--max-retries N`: Maximum fix attempts before giving up (optional, default: 3)

## Execution Protocol

### Phase 0: Fetch Shipping Patterns

```bash
# Fetch upgrade strategies
/fetch "upgrade strategies and version compatibility" --tier1-only

# Fetch shipping checklist
/fetch "feature shipping and deployment checklist" --tier1-only

# Fetch rollback procedures
/fetch "rollback and recovery procedures" --tier1-only
```

**Output:**
```markdown
📚 Fetched Shipping Guidance:
  ✅ platform/operator-patterns/upgrade-strategies.md
  ✅ practices/development/shipping-checklist.md
  ✅ practices/reliability/rollback-procedures.md
  
🎯 Ready to ship!
```

---

## Phase 1: Pre-Ship Checklist

Based on `practices/development/shipping-checklist.md`:

```markdown
# Pre-Ship Validation

## API Changes
- [x] openshift/api PR merged
- [x] Vendored into component (go.mod, go.sum updated)
- [x] API review complete (@api-approvers approved)
- [x] CRD manifests generated correctly
- [x] No breaking changes (or properly versioned)

## Implementation
- [x] All tasks from plan complete
- [x] Code follows operator patterns
- [x] RBAC minimal and correct
- [x] Status conditions implemented (Available/Progressing/Degraded/Upgradeable)
- [x] Validation present (webhook or in-controller)

## Testing
- [x] All unit tests pass (≥60% of suite)
- [x] All integration tests pass (~30% of suite)
- [x] All E2E tests pass (~10% of suite)
- [x] Upgrade test N → N+1 passes
- [x] Tests pass in Prow CI
- [x] No flaky tests

## Security
- [x] STRIDE threat model applied
- [x] Input validation present
- [x] No secrets in logs
- [x] RBAC follows least privilege
- [x] No known CVEs in dependencies

## Observability
- [x] Prometheus metrics implemented
- [x] ServiceMonitor created
- [x] Must-gather support added
- [x] Alerts defined (if feature is critical)
- [x] Logs structured and meaningful

## Documentation
- [x] Enhancement merged to openshift/enhancements
- [x] AGENTS.md updated (Tier 2)
- [x] Exec-plan created (agentic/exec-plans/active/)
- [x] Architecture docs updated
- [x] User-facing docs (if needed)

## Upgrade Strategy
- [x] Upgradeable condition implemented
- [x] Migration code (if CRD changes)
- [x] Handles version N → N+1
- [x] Handles version skew (operator ahead of API server, etc.)
- [x] Rollback tested
- [x] No data loss scenarios

**Status**: ✅ 32/32 criteria met - READY TO SHIP
```

---

## Phase 2: Upgrade Validation

Test upgrade path following `platform/operator-patterns/upgrade-strategies.md`:

```bash
#!/bin/bash
# Upgrade validation script

echo "🧪 Testing upgrade path..."

# Step 1: Install cluster with version N
echo "📦 Installing cluster version N..."
openshift-install create cluster --release-image=quay.io/openshift-release-dev/ocp-release:4.15.0

# Step 2: Verify feature NOT present (baseline)
oc get crd myresources.mygroup.openshift.io
# Should not exist

# Step 3: Upgrade to version N+1 (with feature)
echo "⬆️  Upgrading to version N+1..."
oc adm upgrade --to-image=quay.io/openshift-release-dev/ocp-release:4.16.0-rc

# Wait for upgrade to complete
oc wait clusterversion/version --for=condition=Available=True --timeout=30m

# Step 4: Verify feature deployed
echo "✅ Verifying feature deployed..."
oc get crd myresources.mygroup.openshift.io
# Should exist now

oc get clusteroperator myoperator
# Should be Available=True

# Step 5: Create CR and verify it works
oc create -f test/fixtures/myresource.yaml
oc wait myresource/test --for=condition=Available=True --timeout=5m

# Step 6: Verify Upgradeable condition
UPGRADEABLE=$(oc get clusteroperator myoperator -o jsonpath='{.status.conditions[?(@.type=="Upgradeable")].status}')
if [ "$UPGRADEABLE" != "True" ]; then
    echo "❌ Operator not reporting Upgradeable=True"
    exit 1
fi

# Step 7: Test upgrade N+1 → N+2 (skip level)
echo "⬆️  Testing skip-level upgrade..."
oc adm upgrade --to-image=quay.io/openshift-release-dev/ocp-release:4.17.0-rc
oc wait clusterversion/version --for=condition=Available=True --timeout=30m

# Verify feature still works
oc get myresource/test -o yaml | grep "Available.*True"

echo "✅ Upgrade validation PASS"
```

**Expected Output:**
```
🧪 Testing upgrade path...
📦 Installing cluster version N...
  ✅ Cluster ready (4.15.0)
⬆️  Upgrading to version N+1...
  ✅ Upgrade complete (4.16.0-rc)
✅ Verifying feature deployed...
  ✅ CRD exists
  ✅ Operator Available=True
  ✅ CR reconciles successfully
  ✅ Upgradeable=True
⬆️  Testing skip-level upgrade...
  ✅ Skip-level upgrade complete (4.17.0-rc)
  ✅ Feature still works

✅ Upgrade validation PASS
```

---

## Phase 3: Create PR

```bash
# Ensure all changes committed
if ! git diff --quiet; then
    echo "❌ Uncommitted changes detected"
    exit 1
fi

# Create feature branch (if not already on one)
BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
    echo "❌ Cannot ship from main/master branch"
    echo "   Create feature branch first: git checkout -b feature/my-feature"
    exit 1
fi

# Push branch to origin
git push origin $BRANCH -u

# Create PR using gh CLI
gh pr create \
    --title "feature: Add MyResource controller" \
    --body "$(cat <<'EOF'
## Summary
Implements MyResource controller following OpenShift operator patterns.

Completes: Enhancement openshift/enhancements#XXXX

## Changes
- **API**: Added MyResource CRD to openshift/api
- **Controller**: Reconciliation loop with status reporting
- **Validation**: Webhook validation for MyResource
- **Testing**: 75 tests (60/30/10 pyramid)
- **Observability**: Prometheus metrics + must-gather

## Testing
- ✅ Unit tests: 45 tests, 65% coverage
- ✅ Integration tests: 22 tests
- ✅ E2E tests: 8 tests
- ✅ Upgrade test: N → N+1 verified

## Compliance
- ✅ Operator patterns: 8/8
- ✅ Engineering practices: 7/7
- ✅ Security: STRIDE model applied
- ✅ Observability: Metrics + must-gather

## Upgrade Strategy
- Supports N → N+1 minor version upgrades
- Upgradeable condition implemented
- No breaking API changes
- Rollback tested

## Documentation
- Enhancement: openshift/enhancements#XXXX
- Tier 2 docs: Updated AGENTS.md, created exec-plan
- User docs: (link to docs.openshift.com PR if applicable)

---

🤖 Generated with [Claude Code](https://claude.com/claude-code) using agentic-docs-maintainer skills
EOF
)" \
    --reviewer @team-leads \
    --label enhancement \
    --label component/mycomponent

# Get PR URL
PR_URL=$(gh pr view --json url -q '.url')
echo "✅ PR created: $PR_URL"
```

---

## Phase 4: Verify CI

```bash
# Wait for CI checks to start
sleep 30

# Monitor CI status
echo "🔍 Monitoring CI checks..."
gh pr checks --watch

# Expected checks:
# - verify: Code formatting, linting
# - unit tests: All unit tests pass
# - integration tests: All integration tests pass
# - e2e tests: E2E tests pass on representative cluster
# - upgrade tests: N → N+1 upgrade works
# - build: Operator image builds
```

**CI Check Results:**
```
✅ verify: All checks passed (2m 15s)
✅ unit-tests: 45/45 tests passed (3m 42s)
✅ integration-tests: 22/22 tests passed (8m 18s)
✅ e2e-tests: 8/8 tests passed (45m 22s)
✅ upgrade-test: N → N+1 verified (52m 10s)
✅ build: Image built successfully (5m 33s)

All checks passed! ✅
```

---

## Phase 5: Rollback Plan

Document rollback procedure:

```markdown
# Rollback Plan: MyFeature

## Scenarios Requiring Rollback

### 1. Critical Bug in Production
**Trigger**: Bug causes cluster instability or data loss  
**Action**: Revert to previous version

### 2. Upgrade Failure
**Trigger**: Upgrade to N+1 fails or causes degradation  
**Action**: Rollback cluster to version N

### 3. Performance Regression
**Trigger**: Feature causes unacceptable performance degradation  
**Action**: Disable feature or revert

---

## Rollback Procedure

### Option 1: Revert PR (Pre-Merge)
```bash
# If PR not yet merged, close it
gh pr close $PR_NUMBER
gh pr comment $PR_NUMBER --body "Reverting due to: [reason]"
```

### Option 2: Revert Commit (Post-Merge)
```bash
# If PR merged, revert the merge commit
git revert -m 1 $MERGE_COMMIT_SHA
git push origin main

# Create PR for revert
gh pr create --title "Revert: MyFeature" --body "Reverts #$PR_NUMBER due to [reason]"
```

### Option 3: Feature Flag Disable
```bash
# If feature flag exists, disable it
oc patch deployment myoperator -n openshift-myoperator \
  --type=json \
  -p='[{"op": "add", "path": "/spec/template/spec/containers/0/env/-", "value": {"name": "FEATURE_MYFEATURE_ENABLED", "value": "false"}}]'
```

### Option 4: Cluster Rollback
```bash
# Rollback entire cluster to previous version
oc adm upgrade --to=4.15.0  # Previous known-good version
```

---

## Rollback Validation

After rollback:
1. ✅ Cluster reports Available=True
2. ✅ No Degraded conditions
3. ✅ Existing workloads unaffected
4. ✅ CRs still reconcile (if CR exists in version N)
5. ✅ No data loss

---

## Post-Rollback Actions
1. Investigate root cause
2. Create bug report with reproduction steps
3. Fix issue in feature branch
4. Re-test comprehensively
5. Re-ship when fix verified
```

---

## Phase 6: Ship!

```bash
# Final validation
if [ "$DRY_RUN" = "true" ]; then
    echo "🔍 Dry run complete - ready to ship"
    echo "   Run without --dry-run to create PR"
    exit 0
fi

# All checks passed, ready to merge
echo "✅ All pre-ship checks passed"
echo "✅ PR created and CI passing"
echo "✅ Rollback plan documented"
echo ""
echo "🎯 Ready to ship!"
echo ""
echo "Next steps:"
echo "1. Wait for reviewers to approve PR: $PR_URL"
echo "2. Merge PR when approved"
echo "3. Monitor deployment in CI"
echo "4. Verify in staging/production"
echo "5. Close enhancement issue"
```

---

## Deployment Verification

After PR merges and deploys:

```bash
# Monitor cluster operators
oc get clusteroperators

# Verify operator deployed
oc get deployment myoperator -n openshift-myoperator

# Check operator status
oc get clusteroperator myoperator -o yaml

# Expected:
#   conditions:
#   - type: Available
#     status: "True"
#   - type: Progressing
#     status: "False"
#   - type: Degraded
#     status: "False"
#   - type: Upgradeable
#     status: "True"

# Verify metrics scraped
oc exec -n openshift-monitoring prometheus-k8s-0 -- \
    promtool query instant \
    'http://localhost:9090' \
    'myfeature_reconcile_total'

# Check must-gather
oc adm must-gather -- /usr/bin/gather_myfeature
```

---

## Success Criteria

Ship is successful when:
1. ✅ All pre-ship checklist items complete
2. ✅ Upgrade validation passes
3. ✅ PR created and approved
4. ✅ All CI checks pass
5. ✅ Rollback plan documented
6. ✅ PR merged
7. ✅ Feature deployed to cluster
8. ✅ Operator reports Available=True
9. ✅ No regressions detected

---

## Approval Gate 1: Pre-PR Validation

**CRITICAL**: After pre-ship validation, pause before creating PR unless `--auto-approve` is set.

**Actions:**

```bash
# Check if auto-approve is enabled
if [[ "$AUTO_APPROVE" == "true" ]]; then
    echo "⚠️  Auto-approve enabled. Proceeding to create PR (NOT RECOMMENDED for production)."
else
    # Show approval gate message
    cat <<EOF

════════════════════════════════════════════════════════════════
  REVIEW GATE: Pre-Ship Validation
════════════════════════════════════════════════════════════════

📋 Pre-Ship Checklist: $PASSING/$TOTAL criteria met

Critical Items:
  ✅ All tests passing: $(if all_tests_pass; then echo "YES"; else echo "NO"; fi)
  ✅ Review score >= 80: $(if [ $REVIEW_SCORE -ge 80 ]; then echo "YES ($REVIEW_SCORE)"; else echo "NO ($REVIEW_SCORE)"; fi)
  ✅ Upgrade test passes: $(if upgrade_test_passes; then echo "YES"; else echo "NO"; fi)
  ✅ No uncommitted changes: $(if no_uncommitted; then echo "YES"; else echo "NO"; fi)
  ✅ Branch up to date: $(if branch_up_to_date; then echo "YES"; else echo "NO"; fi)

Rollback Plan: $(if [ -f "ROLLBACK-*.md" ]; then echo "✅ Ready"; else echo "❌ Missing"; fi)

Please review and respond:

  • "approve" or "create PR" 
    → I'll create the GitHub PR
  
  • "revise: <your feedback>"
    → I'll address the issues before creating PR
    → Example: "revise: upgrade test is failing, fix the migration logic"
  
  • "abort" or "cancel"
    → I'll stop here without creating PR

Issues to address:
$(list_shipping_issues)

════════════════════════════════════════════════════════════════

Waiting for your decision to create PR...

EOF
    
    # Exit here - return control to user
    exit 0
fi
```

## Approval Gate 2: Pre-Merge Validation

**CRITICAL**: After CI passes, pause before merging PR unless `--auto-approve` is set.

**Actions:**

```bash
# Check if auto-approve is enabled
if [[ "$AUTO_APPROVE" == "true" ]]; then
    echo "⚠️  Auto-approve enabled. Proceeding to merge PR (NOT RECOMMENDED)."
    gh pr merge --auto --merge
else
    # Show approval gate message
    cat <<EOF

════════════════════════════════════════════════════════════════
  REVIEW GATE: Pre-Merge Validation
════════════════════════════════════════════════════════════════

📄 PR: $PR_URL
✅ CI Status: $(gh pr checks | grep -c "pass")/$CI_TOTAL checks passing

Critical Checks:
  ✅ Unit tests: $(check_status "unit")
  ✅ Integration tests: $(check_status "integration")
  ✅ E2E tests: $(check_status "e2e")
  ✅ Upgrade test: $(check_status "upgrade")
  ✅ Linters: $(check_status "lint")

PR Approval:
  • Reviewers: $(gh pr view --json reviews -q '.reviews | length') reviews
  • Status: $(gh pr view --json reviewDecision -q '.reviewDecision')

Please review and respond:

  • "approve" or "merge" 
    → I'll merge the PR and deploy
  
  • "wait" or "hold"
    → I'll wait for additional review/testing
  
  • "revise: <your feedback>"
    → I'll address issues and update PR
    → Example: "revise: E2E test flake detected, investigate and fix"
  
  • "abort" or "cancel"
    → I'll close the PR without merging

════════════════════════════════════════════════════════════════

⚠️  FINAL GATE: This will merge and deploy to production

Waiting for your decision to merge PR...

EOF
    
    # Exit here - return control to user
    exit 0
fi
```

**Natural Language Detection:**

When the user responds, Claude Code's conversational layer detects intent:

**Approval phrases** (proceed):
- Gate 1: "approve", "create PR", "looks good", "proceed"
- Gate 2: "approve", "merge", "ship it", "LGTM", "deploy"

**Wait phrases** (pause without abort):
- "wait", "hold", "not yet", "give me time to review"

**Revision phrases** (fix issues):
- "revise: <feedback>"
- "fix <feedback>"  
- "update <feedback>"

**Abort phrases** (stop):
- "abort", "cancel", "stop", "don't ship"

**Revision Flow:**

When revision is detected:
1. Extract feedback from user message
2. Check attempt count (tracked in `.work/ship-state.json`)
3. If attempts < max_retries:
   - Re-invoke: `/ship --feedback "user feedback"`
   - Address identified issues
   - Update PR if already created
   - Re-run validation
4. If attempts >= max_retries:
   - Report: "Maximum retries reached. Feature may need manual intervention."
   - Save current state and exit

**State Tracking:**

```json
// .work/ship-state.json
{
  "attempt": 2,
  "max_retries": 3,
  "last_feedback": "upgrade test failing, fix migration logic",
  "pr_url": "https://github.com/openshift/component/pull/123",
  "pr_created": true,
  "ci_passing": false,
  "pre_ship_score": 30,
  "pre_ship_total": 32
}
```

---

## Validation

Before shipping:
- ✅ 32/32 pre-ship criteria met
- ✅ Upgrade test passes
- ✅ PR CI green
- ✅ Rollback plan ready
- ✅ Human approves PR creation (Gate 1)
- ✅ Human approves PR merge (Gate 2)

---

**Pattern Source**:
- `platform/operator-patterns/upgrade-strategies.md`
- `practices/development/shipping-checklist.md`
- `practices/reliability/rollback-procedures.md`

**Final Gates**: 
1. Human approves PR creation → PR created
2. Human approves PR merge → Ship complete! 🎉
