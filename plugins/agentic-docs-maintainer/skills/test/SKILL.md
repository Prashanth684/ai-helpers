---
name: test
description: OpenShift comprehensive testing - implements and verifies testing pyramid (60% unit, 30% integration, 10% E2E) following openshift-tests framework. Use after /build tasks complete.
trigger: explicit
model: sonnet
---

# Test - OpenShift Comprehensive Testing

Verify comprehensive test coverage and compliance with OpenShift testing standards.

---

## 🚨 EXECUTE THESE PHASES IN ORDER 🚨

```
READ PATTERNS → ANALYZE COVERAGE → REPORT → APPROVE
      │                │             │         │
      ▼                ▼             ▼         ▼
    Show            Run           Show       STOP
  Standards        Tests         Results   & WAIT
```

**DO NOT skip phases. DO NOT proceed without completing current phase.**

---

## PHASE 0: Read Testing Standards (Inline)

**DO NOT use Skill("fetch"). Read files directly.**

### Check Local Patterns

```
📚 Phase 0: Reading Testing Standards
```

Check:
```bash
ls ../enhancements/agentic/practices/testing/
```

### Read Files Directly

**If found locally**, use Read tool:
- `../enhancements/agentic/practices/testing/pyramid.md`
- `../enhancements/agentic/practices/testing/e2e-framework.md`

**If NOT found**, fetch via gh CLI.

### Report

```
✅ Testing Standards Retrieved:
  ✅ pyramid.md (60/30/10 distribution)
  ✅ e2e-framework.md (openshift-tests)

🎯 Ready to analyze coverage
```

---

## PHASE 1: Analyze Test Coverage

```
📊 Phase 1: Analyzing Coverage
```

### Run All Test Suites

```bash
# Unit tests
make test-unit

# Integration tests (if exists)
make test-integration

# E2E tests (if exists)
make test-e2e
```

### Calculate Coverage

**Unit tests**:
- Count: How many unit tests?
- Coverage: What % code coverage?
- Target: Typically 60% of total tests

**Integration tests**:
- Count: How many integration tests?
- Target: Typically 30% of total tests

**E2E tests**:
- Count: How many E2E tests?
- Target: Typically 10% of total tests

**Pyramid ratio**:
- Calculate: unit% / integration% / E2E%
- Compare to 60/30/10 target

### Report

```
📊 Test Coverage Analysis:

Unit Tests:
  Count: [X]
  Coverage: [Y]%
  Target: 60% of tests
  Status: ✅ PASS / ❌ FAIL

Integration Tests:
  Count: [X]
  Target: 30% of tests
  Status: ✅ PASS / ❌ FAIL

E2E Tests:
  Count: [X]
  Target: 10% of tests
  Status: ✅ PASS / ❌ FAIL

Pyramid Ratio: [X]/[Y]/[Z]
Target: 60/30/10
Overall: ✅ COMPLIANT / ❌ NON-COMPLIANT
```

---

## PHASE 2: Identify Gaps (if non-compliant)

**If tests don't meet targets, identify gaps:**

```
📋 Test Gaps Identified:

Missing Unit Tests:
  - [Function/method without test]
  - [Edge case not covered]

Missing Integration Tests:
  - [Component interaction not tested]
  - [API contract not verified]

Missing E2E Tests:
  - [Critical user workflow not tested]
  - [Upgrade path not tested]

Recommendations:
  1. [Specific test to add]
  2. [Specific test to add]
```

---

## PHASE 3: APPROVAL GATE

**🛑 STOP HERE. WAIT FOR USER DECISION. 🛑**

```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Test Coverage Report
════════════════════════════════════════════════════════════════

Coverage Summary:
  Unit: [X]% (target: 60%)
  Integration: [Y]% (target: 30%)
  E2E: [Z]% (target: 10%)

Status: ✅ COMPLIANT / ⚠️  NEEDS WORK

────────────────────────────────────────────────────────────────

Respond:
  ✅ "approve" / "proceed" → Continue to /review
  ✏️  "fix-gaps" → I'll identify missing tests
  ❌ "abort" → I'll stop

════════════════════════════════════════════════════════════════

⏸️  Waiting for your decision...
```

**EXIT SKILL.**

---

## PHASE 4: Report (if approved)

```
✅ Test Coverage Verified

Tests Run:
  Unit: [X] tests
  Integration: [Y] tests
  E2E: [Z] tests

Coverage: [N]%
Pyramid: [X]/[Y]/[Z]

🎯 Next: /review
```

**DONE.**

---

## Red Flags - You're Doing It Wrong

| Red Flag | Fix |
|----------|-----|
| No E2E tests | Add at least 1 critical path E2E test. |
| <50% unit coverage | Add unit tests for business logic. |
| Only E2E tests | Add unit and integration tests (faster feedback). |
| Using Skill("fetch") | Read patterns inline. |
| Skipping approval | STOP. Show report. Wait. |

---

## Common Rationalizations - Don't Make These

| Excuse | Reality |
|--------|---------|
| "E2E tests cover everything" | E2E tests are slow. Need fast unit tests too. |
| "100% coverage needed" | 60-80% coverage is often sufficient. Focus on critical paths. |
| "Testing takes too long" | Good test pyramid = fast feedback. |

---

## Pre-Analysis Checklist

- [ ] All /build tasks complete
- [ ] Testing standards read
- [ ] Test suites exist (unit/integration/E2E)

**If unchecked, fix before analyzing.**

---

## Pre-Approval Checklist

- [ ] All test suites run
- [ ] Coverage calculated
- [ ] Pyramid ratio measured
- [ ] Gaps identified (if non-compliant)

**If unchecked, complete analysis first.**

---

**Pattern**: OpenShift comprehensive testing  
**Version**: 2.0
