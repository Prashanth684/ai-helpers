---
description: Five-axis code review against OpenShift operator patterns and practices
---

## Name
agentic-docs-maintainer:review

## Synopsis
```
/agentic-docs-maintainer:review [--component <name>] [--fix-auto]
```

## Description
Reviews implementation across five axes: correctness, maintainability, testing, security, and operability. Checks compliance with operator patterns, engineering practices, and component standards.

**Key Innovation**: Uses `/fetch` to retrieve review criteria from agentic documentation for automated compliance checking.

## Arguments

- `--component <name>`: Component name for component-specific checks
- `--fix-auto`: Automatically fix linter issues where possible

## When to Use

- After `/test` passes
- Before creating PR
- Self-review against OpenShift standards
- Automated compliance checking before `/ship`

## Five-Axis Review

| Axis | Focus | Score |
|------|-------|-------|
| **1. Correctness** | Does it work? | /20 |
| **2. Maintainability** | Can it be understood? | /20 |
| **3. Testing** | Is it proven? | /20 |
| **4. Security** | Is it safe? | /20 |
| **5. Operability** | Will it run well? | /20 |

**Total**: /100

## Example

```bash
/agentic-docs-maintainer:review --component machine-config-operator
```

**Output:**
```
📚 Fetching review criteria...
  ✅ platform/operator-patterns/ (8 patterns)
  ✅ practices/development/code-review.md
  ✅ practices/security/threat-modeling.md
  ✅ machine-config-operator/agentic/patterns/

🔍 Reviewing implementation...

## Axis 1: Correctness ✅ 20/20
  ✅ Controller runtime pattern followed
  ✅ Status conditions correct
  ✅ RBAC minimal and appropriate

## Axis 2: Maintainability ✅ 18/20
  ✅ Code style consistent
  ⚠️  Function `reconcileComplex()` is 75 lines (recommend <50)

## Axis 3: Testing ✅ 19/20
  ✅ Testing pyramid (60/29/11)
  ⚠️  Integration tests 1% below target

## Axis 4: Security ✅ 20/20
  ✅ STRIDE analysis complete
  ✅ No secrets in logs

## Axis 5: Operability 🟡 17/20
  ✅ Metrics + must-gather present
  ⚠️  Resource limits not set

📊 Overall Score: 94/100 🟢 PASS

## Action Items:
  Must Fix (Blocking): None
  Should Fix: Set resource limits, add 1 integration test
  Nice to Have: Refactor large function

✅ APPROVED for merge (after "Should Fix" items)
```

## Compliance Checklists

### Operator Patterns (8 checks)
- Controller-runtime reconciliation
- Status conditions
- Leader election
- Finalizers
- Webhooks
- RBAC patterns
- Upgrade safety
- Must-gather

### Engineering Practices (7 checks)
- Testing pyramid
- STRIDE threat model
- SLO defined
- CI integration
- ADRs documented
- Git workflow
- Resource limits

## See Also

- `/agentic-docs-maintainer:test` - Run tests (previous step)
- `/agentic-docs-maintainer:ship` - Deploy safely (next step)

---

**Pattern**: Five-axis code review with automated compliance  
**Version**: 1.0
