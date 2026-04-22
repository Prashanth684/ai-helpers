---
name: review
description: OpenShift code review - checks implementation against operator patterns, practices, and component standards. Five-axis review (correctness, maintainability, testing, security, operability). Use before /ship.
trigger: explicit
model: sonnet
---

# Review - OpenShift Code Review

Review implementation for OpenShift compliance. Checks code against patterns, practices, and standards.

---

## 🚨 EXECUTE THESE PHASES IN ORDER 🚨

```
READ PATTERNS → REVIEW CODE → REPORT → APPROVE
      │              │           │         │
      ▼              ▼           ▼         ▼
    Show          Check       Show       STOP
  Criteria       Issues      Score    & WAIT
```

**DO NOT skip phases. DO NOT proceed without completing current phase.**

---

## PHASE 0: Read Review Criteria (Inline)

**DO NOT use Skill("fetch"). Read files directly.**

### Check Local Patterns

```
📚 Phase 0: Reading Review Criteria
```

Check:
```bash
ls ../enhancements/agentic/platform/operator-patterns/
ls ../enhancements/agentic/practices/
```

### Read Files Directly

**Always read**:
- `../enhancements/agentic/platform/operator-patterns/` (relevant patterns)
- `../enhancements/agentic/practices/development/code-review.md` (if exists)
- `../enhancements/agentic/practices/security/` (security guidelines)

**If component specified**:
- `../{component}/agentic/` (component-specific standards)

**If NOT found**, fetch via gh CLI.

### Report

```
✅ Review Criteria Retrieved:
  ✅ operator-patterns (compliance checklist)
  ✅ practices/security (security guidelines)
  [✅ {component} standards - if applicable]

🎯 Ready to review
```

---

## PHASE 1: Review Code

```
🔍 Phase 1: Reviewing Implementation
```

### Five-Axis Review

**Axis 1: Correctness** - Does it work?
- [ ] Implements feature as specified
- [ ] Handles errors appropriately
- [ ] Edge cases considered

**Axis 2: Maintainability** - Can others work with it?
- [ ] Code is readable
- [ ] Follows existing patterns
- [ ] Has appropriate comments (why, not what)
- [ ] No code duplication

**Axis 3: Testing** - Is it tested?
- [ ] Unit tests for business logic
- [ ] Integration tests for component interactions
- [ ] E2E tests for critical paths
- [ ] Tests actually test behavior (not just coverage)

**Axis 4: Security** - Is it safe?
- [ ] No secrets in code/logs
- [ ] RBAC follows least privilege
- [ ] Input validation where needed
- [ ] No obvious vulnerabilities

**Axis 5: Operability** - Can it run in production?
- [ ] Metrics for monitoring
- [ ] Logs for debugging
- [ ] Status conditions for health
- [ ] must-gather support (if operator)

### Check Pattern Compliance

**For operator features**:
- [ ] Uses controller-runtime patterns
- [ ] Reports Available/Progressing/Degraded
- [ ] Supports upgrades (N→N+1)

**For CLI features**:
- [ ] Follows cobra patterns
- [ ] Has help text
- [ ] Handles errors gracefully

**For library features**:
- [ ] Clear interface
- [ ] Good documentation
- [ ] Examples provided

**Don't force operator patterns on non-operator code.**

### Report Issues

```
📋 Review Findings:

Correctness:
  ✅ Feature works as specified
  ⚠️  [Issue if found]

Maintainability:
  ✅ Code is readable
  ⚠️  [Issue if found]

Testing:
  ✅ Good test coverage
  ⚠️  [Issue if found]

Security:
  ✅ No vulnerabilities found
  ⚠️  [Issue if found]

Operability:
  ✅ Metrics and logging present
  ⚠️  [Issue if found]

Pattern Compliance:
  ✅ Follows OpenShift patterns
  ⚠️  [Issue if found]
```

---

## PHASE 2: Calculate Score

```
📊 Phase 2: Scoring Review
```

### Score Each Axis

- Correctness: [X]/10
- Maintainability: [X]/10
- Testing: [X]/10
- Security: [X]/10
- Operability: [X]/10

**Total: [X]/50**

### Categorize Issues

**Must Fix** (blocking):
- Functional bugs
- Security vulnerabilities
- Missing critical tests

**Should Fix** (recommended):
- Code clarity issues
- Missing non-critical tests
- Minor pattern deviations

**Nice to Have** (optional):
- Code style improvements
- Additional metrics
- Documentation enhancements

---

## PHASE 3: APPROVAL GATE

**🛑 STOP HERE. WAIT FOR USER DECISION. 🛑**

```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Code Review Complete
════════════════════════════════════════════════════════════════

Score: [X]/50

Issues:
  Must Fix: [count]
  Should Fix: [count]
  Nice to Have: [count]

Status: ✅ APPROVED / ⚠️  NEEDS WORK / ❌ REJECTED

────────────────────────────────────────────────────────────────

Respond:
  ✅ "approve" / "ship" → Continue to /ship
  ✏️  "fix: <feedback>" → Address issues
  ❌ "abort" → Stop

════════════════════════════════════════════════════════════════

⏸️  Waiting for your decision...
```

**EXIT SKILL.**

---

## PHASE 4: Report (if approved)

```
✅ Code Review Complete

Score: [X]/50
Status: APPROVED

Issues Fixed:
  [List if any were addressed]

🎯 Next: /ship
```

**DONE.**

---

## Red Flags - You're Doing It Wrong

| Red Flag | Fix |
|----------|-----|
| Score <30/50 | Major issues. Fix before shipping. |
| No tests | Add tests before approval. |
| Security vulnerabilities | Fix immediately. |
| Using Skill("fetch") | Read patterns inline. |
| Forcing operator patterns on CLI code | Review based on feature type. |

---

## Common Rationalizations - Don't Make These

| Excuse | Reality |
|--------|---------|
| "It works, ship it" | Working code can still have security/maintenance issues. |
| "Tests are optional" | Tests are required for production code. |
| "Style doesn't matter" | Readable code = maintainable code. |

---

## Pre-Review Checklist

- [ ] All /build tasks complete
- [ ] /test passed
- [ ] Review criteria read
- [ ] Code compiles
- [ ] Tests pass

**If unchecked, fix before reviewing.**

---

## Pre-Approval Checklist

- [ ] All axes reviewed
- [ ] Score calculated
- [ ] Issues categorized (must/should/nice)
- [ ] No blocking issues OR issues addressed

**If unchecked, complete review first.**

---

**Pattern**: OpenShift code review  
**Version**: 2.0
