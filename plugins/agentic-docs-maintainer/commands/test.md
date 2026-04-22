---
description: Verify comprehensive testing following OpenShift testing pyramid (60/30/10)
---

## Name
agentic-docs-maintainer:test

## Synopsis
```
/agentic-docs-maintainer:test
```

## Description
Verifies comprehensive test coverage and compliance with OpenShift testing standards (60% unit, 30% integration, 10% E2E).

**Approach**: Run all test suites, calculate pyramid ratio, identify gaps.

## When to Use

✅ **Use for:**
- After `/build` completes all tasks
- Before `/review` to verify comprehensive testing
- Checking testing pyramid compliance

❌ **Don't use for:**
- Running single test (use `make test-unit` directly)
- During individual task implementation

## How It Works

### Phase 0: Read Testing Standards

Reads testing pyramid guidance:
- `../enhancements/agentic/practices/testing/pyramid.md`
- `../enhancements/agentic/practices/testing/e2e-framework.md`

### Phase 1: Analyze Coverage

Runs all test suites:
```bash
make test-unit
make test-integration  # if exists
make test-e2e          # if exists
```

Calculates:
- Unit test count and coverage
- Integration test count
- E2E test count
- Pyramid ratio (unit/integration/E2E)

### Phase 2: Report

Compares to targets:
- Unit: 60% of tests
- Integration: 30% of tests
- E2E: 10% of tests

Identifies gaps if non-compliant.

### Phase 3: Approval Gate

Shows report, waits for user decision.

## Testing Pyramid Targets

| Type | Target | What to Test |
|------|--------|-------------|
| Unit | 60% | Business logic, validation, edge cases |
| Integration | 30% | Component interactions, API contracts |
| E2E | 10% | Critical user workflows, upgrades |

**These are guidelines, not rigid rules.** Adapt to your feature.

## Example

```bash
/agentic-docs-maintainer:test
```

**Output:**
```
📚 Reading testing standards...
  ✅ pyramid.md
  ✅ e2e-framework.md

📊 Analyzing coverage...
  ✅ make test-unit (45 tests, 65% coverage)
  ✅ make test-integration (15 tests)
  ✅ make test-e2e (5 tests)

📈 Test Coverage Analysis:

Unit Tests:
  Count: 45
  Coverage: 65%
  Ratio: 69% of total tests
  Status: ✅ PASS (target: 60%)

Integration Tests:
  Count: 15
  Ratio: 23% of total tests
  Status: ⚠️  BELOW TARGET (target: 30%)

E2E Tests:
  Count: 5
  Ratio: 8% of total tests
  Status: ✅ PASS (target: 10%)

Pyramid Ratio: 69/23/8
Target: 60/30/10
Overall: ⚠️  NEEDS WORK (integration tests low)

────────────────────────────────────────────────────────────────

Recommendations:
  - Add 5 integration tests to reach 30% target
  - Tests cover critical paths

════════════════════════════════════════════════════════════════
  REVIEW GATE
════════════════════════════════════════════════════════════════

Respond:
  ✅ "proceed" → Continue to /review (accept current coverage)
  ✏️  "fix-gaps" → Add missing tests
  ❌ "abort" → Stop
```

## Good Testing Practices

**Good pyramid**:
- ✅ Fast unit tests (60%+)
- ✅ Moderate integration tests (20-30%)
- ✅ Few E2E tests (10-15%)
- ✅ All critical paths covered

**Bad pyramid**:
- ❌ Mostly E2E tests (slow, brittle)
- ❌ No unit tests (slow feedback)
- ❌ 100% coverage obsession (diminishing returns)

## Integration with Other Skills

**Full workflow:**
```bash
# After all /build tasks complete

/test           # Verify comprehensive testing
→ Review coverage report
→ Approve or fix gaps

/review         # Check code compliance
/ship           # Create PR
```

## Implementation

Execution handled by skill at: `skills/test/SKILL.md`

**Key phases:**
1. Read testing standards
2. Run all test suites
3. Calculate pyramid ratio
4. Report and identify gaps

## See Also

- `/agentic-docs-maintainer:build` - Implement tasks (previous step)
- `/agentic-docs-maintainer:review` - Check compliance (next step)

---

**Pattern**: OpenShift comprehensive testing verification  
**Version**: 2.0
