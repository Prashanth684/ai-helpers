---
description: Five-axis code review against OpenShift patterns and practices
---

## Name
agentic-docs-maintainer:review

## Synopsis
```
/agentic-docs-maintainer:review [--component <name>]
```

## Description
Reviews implementation across five axes: correctness, maintainability, testing, security, and operability. Checks compliance with OpenShift patterns and practices.

**Approach**: Read review criteria, check code, report issues.

## Arguments

- `--component <name>`: Component name for component-specific checks (optional)

## When to Use

✅ **Use for:**
- After `/test` passes
- Before creating PR (`/ship`)
- Self-review against OpenShift standards

❌ **Don't use for:**
- Tests not yet passing
- Work-in-progress code

## Five-Axis Review

Reviews code across five dimensions:

### Axis 1: Correctness
**Does it work?**
- Implements feature as specified
- Handles errors appropriately
- Edge cases considered

### Axis 2: Maintainability
**Can others work with it?**
- Code is readable
- Follows existing patterns
- Appropriate comments
- No unnecessary duplication

### Axis 3: Testing
**Is it tested?**
- Unit tests for business logic
- Integration tests for component interactions
- E2E tests for critical paths
- Tests verify behavior (not just coverage)

### Axis 4: Security
**Is it safe?**
- No secrets in code/logs
- RBAC follows least privilege
- Input validation present
- No obvious vulnerabilities

### Axis 5: Operability
**Can it run in production?**
- Metrics for monitoring
- Logs for debugging
- Status reporting (if operator)
- must-gather support (if operator)

## Example

```bash
/agentic-docs-maintainer:review --component machine-config-operator
```

**Output:**
```
📚 Reading review criteria...
  ✅ operator-patterns
  ✅ practices/security
  ✅ machine-config-operator/agentic

🔍 Reviewing implementation...

Correctness: ✅
  ✅ Feature works as specified
  ✅ Error handling present

Maintainability: ✅
  ✅ Code is readable
  ✅ Follows existing patterns

Testing: ⚠️
  ✅ Unit tests (60%)
  ⚠️  Integration tests low (23% vs 30% target)
  ✅ E2E tests (10%)

Security: ✅
  ✅ No vulnerabilities found
  ✅ RBAC least-privilege

Operability: ✅
  ✅ Metrics present
  ✅ must-gather support

────────────────────────────────────────────────────────────────

Issues Found:

Must Fix: 0
Should Fix: 1
  - Add 5 integration tests to reach 30% target

Nice to Have: 0

Status: ✅ APPROVED (with recommendations)

════════════════════════════════════════════════════════════════
  REVIEW GATE
════════════════════════════════════════════════════════════════

Respond:
  ✅ "approve" / "ship" → Continue to /ship
  ✏️  "fix: add tests" → Address issues
```

## Issue Categories

**Must Fix** (blocking - cannot ship):
- Functional bugs
- Security vulnerabilities
- Missing critical tests
- Major pattern violations

**Should Fix** (recommended - ship with plan to address):
- Code clarity issues
- Missing non-critical tests
- Minor pattern deviations
- Missing metrics

**Nice to Have** (optional - can ship as-is):
- Code style improvements
- Additional documentation
- Extra logging

## Pattern Compliance

Reviews based on feature type:

**For operator features**, checks:
- controller-runtime patterns
- Status condition reporting
- Upgrade support
- RBAC design

**For CLI features**, checks:
- Command structure (cobra)
- Help text present
- Error handling
- User experience

**For library features**, checks:
- Clear interface
- Documentation
- Examples
- API design

**Adapts review to feature type - doesn't force operator patterns everywhere.**

## Integration with Other Skills

**Full workflow:**
```bash
# After /test passes

/review
→ Review code against patterns
→ Fix issues if needed
→ Approve

/ship
→ Create PR
```

## Implementation

Execution handled by skill at: `skills/review/SKILL.md`

**Key phases:**
1. Read review criteria (patterns, practices, component standards)
2. Review code (five axes + pattern compliance)
3. Report issues (must/should/nice categories)
4. Approval gate

## See Also

- `/agentic-docs-maintainer:test` - Verify testing (previous step)
- `/agentic-docs-maintainer:ship` - Create PR (next step)

---

**Pattern**: OpenShift code review  
**Version**: 2.0
