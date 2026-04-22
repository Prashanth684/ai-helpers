---
name: test
description: OpenShift comprehensive testing - implements and verifies testing pyramid (60% unit, 30% integration, 10% E2E) following openshift-tests framework. Use after /build tasks complete.
trigger: explicit
model: sonnet
---

# Test - OpenShift Comprehensive Testing

## Overview

Implement and verify comprehensive testing following OpenShift testing pyramid (60% unit, 30% integration, 10% E2E). Ensures all tests pass and coverage targets met before shipping.

**Key Innovation**: Uses `/fetch` to retrieve testing framework patterns and verify compliance with OpenShift testing standards.

## What This Skill Operates On

**Input**: Actual codebase (reads existing code and test files)
- All test files: `*_test.go`
- Source code being tested: `pkg/`, `cmd/`
- Test configuration: Makefile, test scripts

**Output**: Test coverage report + recommendations
- Coverage percentages (unit, integration, E2E)
- Pyramid ratio (60/30/10 compliance)
- Missing coverage analysis

**Artifacts Created**: 
- Coverage reports (`coverage-*.out`)
- Test gap analysis

## When to Use

- After `/build` completes all implementation tasks
- Before `/review` to ensure tests comprehensive
- Verifying testing pyramid compliance (60/30/10)
- Adding missing test coverage

**When NOT to use**:
- During individual task implementation (tests written per-task in `/build`)
- Just running existing tests (use `make test-unit` directly)

**Natural Language**: 
- "Test my implementation"
- "Verify the testing pyramid"
- "Check if my tests meet the 60/30/10 ratio"

## Arguments

```bash
/test [--coverage-report] [--fix-missing] [--feedback "text"] [--auto-approve] [--max-retries N]
```

**Arguments:**
- `--coverage-report`: Generate detailed coverage report
- `--fix-missing`: Identify and create missing tests
- `--feedback "text"`: Revision feedback from previous attempt (optional, used to address test issues)
- `--auto-approve`: Skip approval gate and proceed to /review (optional, default: false)
- `--max-retries N`: Maximum fix attempts before giving up (optional, default: 3)

## Execution Protocol

### Phase 0: Fetch Testing Patterns

```bash
# Fetch testing framework guidance
/fetch "testing pyramid and coverage standards" --tier1-only
/fetch "E2E testing framework and best practices" --tier1-only
/fetch "openshift-tests integration patterns" --tier1-only
```

### Phase 1: Analyze Test Coverage

```bash
# Run all test suites with coverage
make test-unit COVERAGE=true
make test-integration COVERAGE=true
make test-e2e COVERAGE=true

# Analyze coverage breakdown
UNIT_COVERAGE=$(go tool cover -func=coverage-unit.out | grep total | awk '{print $3}')
INTEGRATION_COVERAGE=$(go tool cover -func=coverage-integration.out | grep total | awk '{print $3}')
E2E_COVERAGE=$(estimate_e2e_coverage)  # Based on critical path coverage

# Calculate pyramid ratio
TOTAL_TESTS=$(count_all_tests)
UNIT_PERCENT=$(calculate_percentage $UNIT_TESTS $TOTAL_TESTS)
INTEGRATION_PERCENT=$(calculate_percentage $INTEGRATION_TESTS $TOTAL_TESTS)
E2E_PERCENT=$(calculate_percentage $E2E_TESTS $TOTAL_TESTS)
```

**Output:**
```markdown
## Test Coverage Analysis

### Unit Tests (Target: 60%)
- Tests: 45
- Coverage: 65%
- Status: ✅ PASS (meets 60% target)

### Integration Tests (Target: 30%)
- Tests: 22
- Coverage: 28%
- Status: ⚠️  CLOSE (2% below target)

### E2E Tests (Target: 10%)
- Tests: 8
- Coverage: 12%
- Status: ✅ PASS (exceeds 10% target)

### Pyramid Ratio
- Unit: 60% (target: 60%) ✅
- Integration: 29% (target: 30%) ⚠️
- E2E: 11% (target: 10%) ✅

Overall: 🟡 Mostly compliant (integration 1% short)
```

### Phase 2: Identify Missing Tests

```markdown
## Missing Test Coverage

### Critical Paths Without Tests
1. **Error handling in reconcile loop**
   - File: `pkg/controller/myresource/controller.go:45-60`
   - Severity: HIGH
   - Recommendation: Add TestReconcile_ReconcileError

2. **Webhook validation for edge case**
   - File: `pkg/webhook/validation.go:78-92`
   - Severity: MEDIUM
   - Recommendation: Add TestValidation_EdgeCase

### Integration Test Gaps
1. **Upgrade scenario not tested**
   - Recommendation: Add TestUpgrade_N_to_NPlus1 to test/integration/

### E2E Test Gaps
1. **Multi-node scenario not tested**
   - Recommendation: Add E2E test for multi-node cluster (if applicable)
```

### Phase 3: Run Full Test Suite

```bash
# Run all tests
echo "🧪 Running full test suite..."

# Unit tests
make test-unit
if [ $? -ne 0 ]; then
    echo "❌ Unit tests failed"
    exit 1
fi

# Integration tests
make test-integration
if [ $? -ne 0 ]; then
    echo "❌ Integration tests failed"
    exit 1
fi

# E2E tests (in CI or local cluster)
make test-e2e
if [ $? -ne 0 ]; then
    echo "❌ E2E tests failed"
    exit 1
fi

echo "✅ All tests pass!"
```

### Phase 4: Verify Test Quality

Based on fetched testing practices:

```markdown
## Test Quality Checklist

### Unit Tests Quality
- [x] Tests are isolated (no external dependencies)
- [x] Tests use table-driven approach where appropriate
- [x] Tests have clear arrange-act-assert structure
- [x] Test names follow convention: TestFunction_Scenario
- [x] Tests cover happy path + error cases
- [x] Mock/fake objects used correctly

### Integration Tests Quality
- [x] Tests use real Kubernetes API (envtest or kind)
- [x] Tests clean up resources after completion
- [x] Tests are not flaky (run 10x, all pass)
- [x] Tests cover controller reconciliation end-to-end
- [x] Tests verify status conditions set correctly

### E2E Tests Quality
- [x] Tests use openshift-tests framework (Ginkgo v2)
- [x] Tests have proper tags ([sig-component], [Slow])
- [x] Tests exercise real user workflows
- [x] Tests wait for conditions (not sleep)
- [x] Tests are hermetic (can run in parallel)
- [x] Tests run in CI successfully
```

### Phase 5: Generate Report

```markdown
# Test Report: MyFeature

## Summary
- **Total Tests**: 75
- **Passing**: 75 ✅
- **Failing**: 0
- **Pyramid Compliance**: ✅ PASS

## Coverage
| Type | Tests | Percentage | Target | Status |
|------|-------|------------|--------|--------|
| Unit | 45 | 60% | 60% | ✅ |
| Integration | 22 | 29% | 30% | 🟡 |
| E2E | 8 | 11% | 10% | ✅ |

## Test Execution Time
- Unit: 2.3s
- Integration: 45s
- E2E: 8m 32s
- **Total**: 9m 19s

## Recommendations
1. Add 1 integration test to reach 30% target
2. Consider reducing E2E test time (currently 8m, target <5m)

## CI Status
- ✅ All tests pass in Prow
- ✅ No flaky tests detected
- ✅ Coverage meets standards

**Ready for `/review`**
```

---

## Test Type Guidelines

### Unit Tests (60% Target)

**What to Test**:
- Business logic
- Validation functions
- Status condition transitions
- Error handling
- Edge cases

**Example**:
```go
func TestValidation_ValidConfig(t *testing.T) {
    config := &Config{Field: "valid-value"}
    err := validate(config)
    assert.NoError(t, err)
}
```

**Pattern Source**: `practices/testing/pyramid.md`

### Integration Tests (30% Target)

**What to Test**:
- Controller reconciliation loop
- Kubernetes API interactions
- Watch mechanisms
- Status propagation

**Example**:
```go
func TestController_Integration(t *testing.T) {
    env := envtest.Environment{}
    // Test with real K8s API
}
```

**Pattern Source**: `practices/testing/pyramid.md`

### E2E Tests (10% Target)

**What to Test**:
- Full user workflows
- Feature installation
- Upgrade scenarios
- Cross-component interactions

**Example**:
```go
var _ = ginkgo.Describe("[sig-mycomponent] MyFeature", func() {
    ginkgo.It("should work end-to-end", func() {
        // Real cluster test
    })
})
```

**Pattern Source**: `practices/testing/e2e-framework.md`

---

## Test Commands

```bash
# Run unit tests
make test-unit

# Run unit tests with coverage
make test-unit COVERAGE=true

# Run integration tests
make test-integration

# Run E2E tests (requires cluster)
make test-e2e

# Run specific test
go test -run TestMyFunction ./pkg/controller/...

# Run all tests
make test-all
```

---

## Approval Gate

**CRITICAL**: After running tests, pause for human review unless `--auto-approve` is set.

**Actions:**

```bash
# Check if auto-approve is enabled
if [[ "$AUTO_APPROVE" == "true" ]]; then
    echo "✓ Auto-approve enabled. Proceeding to /review."
else
    # Show approval gate message
    cat <<EOF

════════════════════════════════════════════════════════════════
  REVIEW GATE: Test Results
════════════════════════════════════════════════════════════════

📊 Test Coverage Summary:
  • Unit: $UNIT_PERCENT% (target: 60%) $(if [ $UNIT_PERCENT -ge 60 ]; then echo "✅"; else echo "❌"; fi)
  • Integration: $INTEGRATION_PERCENT% (target: 30%) $(if [ $INTEGRATION_PERCENT -ge 30 ]; then echo "✅"; else echo "❌"; fi)
  • E2E: $E2E_PERCENT% (target: 10%) $(if [ $E2E_PERCENT -ge 10 ]; then echo "✅"; else echo "❌"; fi)

✅ All tests passing: $(if all_tests_pass; then echo "YES"; else echo "NO"; fi)
✅ Pyramid compliance: $(if pyramid_compliant; then echo "YES"; else echo "NO"; fi)

Please review the test results and respond:

  • "approve" or "looks good" 
    → I'll proceed to /review
  
  • "revise: <your feedback>"
    → I'll address the test issues
    → Example: "revise: add missing integration test for upgrade scenario"
  
  • "abort" or "cancel"
    → I'll stop here without proceeding

Missing tests identified:
$(list_missing_tests)

════════════════════════════════════════════════════════════════

Waiting for your review decision...

EOF
    
    # Exit here - return control to user
    exit 0
fi
```

**Natural Language Detection:**

When the user responds, Claude Code's conversational layer detects intent:

**Approval phrases** (proceed to /review):
- "approve", "approved", "LGTM", "looks good", "proceed", "continue", "yes"

**Revision phrases** (fix test issues):
- "revise: <feedback>"
- "fix <feedback>"  
- "add <feedback>"
- "improve <feedback>"

**Abort phrases** (stop workflow):
- "abort", "cancel", "stop", "nevermind", "no"

**Revision Flow:**

When revision is detected:
1. Extract feedback from user message
2. Check attempt count (tracked in `.work/test-state.json`)
3. If attempts < max_retries:
   - Re-invoke: `/test --feedback "user feedback"`
   - Address identified issues (add missing tests, fix failing tests, improve coverage)
   - Re-run test suite
   - Commit test improvements
4. If attempts >= max_retries:
   - Report: "Maximum retries reached. Tests may need manual review."
   - Save current state and exit

**State Tracking:**

```json
// .work/test-state.json
{
  "attempt": 2,
  "max_retries": 3,
  "last_feedback": "add integration test for upgrade scenario",
  "unit_coverage": 65,
  "integration_coverage": 28,
  "e2e_coverage": 12,
  "pyramid_compliant": false,
  "all_passing": true
}
```

---

## Validation

Before advancing to `/review`:
1. ✅ All tests pass (unit, integration, E2E)
2. ✅ Testing pyramid compliance (60/30/10)
3. ✅ Coverage meets targets
4. ✅ No flaky tests
5. ✅ Tests run successfully in CI

---

**Pattern Source**:
- `practices/testing/pyramid.md`
- `practices/testing/e2e-framework.md`
- `practices/testing/test-flake-policy.md`

**Validation Gate**: All tests pass before `/review`
