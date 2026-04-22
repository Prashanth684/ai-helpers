---
description: Verify comprehensive testing following OpenShift testing pyramid (60/30/10)
---

## Name
agentic-docs-maintainer:test

## Synopsis
```
/agentic-docs-maintainer:test [--coverage-report] [--fix-missing]
```

## Description
Implements and verifies comprehensive testing following OpenShift testing pyramid (60% unit, 30% integration, 10% E2E). Ensures all tests pass and coverage targets met.

**Key Innovation**: Uses `/fetch` to retrieve testing framework patterns and verify pyramid compliance.

## Arguments

- `--coverage-report`: Generate detailed coverage report
- `--fix-missing`: Identify and suggest missing tests

## When to Use

- After `/build` completes all tasks
- Before `/review` to ensure comprehensive testing
- Verifying testing pyramid compliance
- Identifying gaps in test coverage

## How It Works

### Five-Phase Testing Workflow

```
1. Fetch Patterns    → Testing pyramid, E2E framework, standards
2. Analyze Coverage  → Calculate 60/30/10 ratio, identify gaps
3. Run Tests         → Execute unit, integration, E2E suites
4. Verify Quality    → Check test quality standards
5. Generate Report   → Coverage report with recommendations
```

## Testing Pyramid Target

| Type | Target | What to Test |
|------|--------|-------------|
| Unit | 60% | Business logic, validation, state transitions |
| Integration | 30% | Controller reconciliation, K8s API interactions |
| E2E | 10% | Full user workflows, upgrades, cross-component |

## Example

```bash
/agentic-docs-maintainer:test --coverage-report
```

**Output:**
```
🧪 Running comprehensive test suite...

📊 Test Coverage Analysis:
  Unit Tests: 45 tests, 65% coverage ✅ (target: 60%)
  Integration Tests: 22 tests, 29% coverage 🟡 (target: 30%)
  E2E Tests: 8 tests, 11% coverage ✅ (target: 10%)

📈 Pyramid Ratio:
  Unit: 60% ✅
  Integration: 29% 🟡 (1% below)
  E2E: 11% ✅

✅ All 75 tests PASS

⚠️  Recommendations:
  - Add 1 integration test to reach 30% target
  - Consider reducing E2E time (8m → target <5m)

🎯 Overall: PASS (ready for /review)
```

## See Also

- `/agentic-docs-maintainer:build` - Implement tasks (previous step)
- `/agentic-docs-maintainer:review` - Code review (next step)

---

**Pattern**: OpenShift testing pyramid verification  
**Version**: 1.0
