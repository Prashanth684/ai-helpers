---
description: OpenShift safe deployment - validates upgrade strategy, creates PR, verifies CI, and ships with rollback plan
---

## Name
agentic-docs-maintainer:ship

## Synopsis
```
/agentic-docs-maintainer:ship
```

## Description
Safely deploy feature following OpenShift shipping practices. Validates readiness, creates PR with context, and provides rollback plan. Use after `/review` passes.

**Approach**: Read shipping guidance, check readiness, create PR, monitor CI.

## When to Use

✅ **Use for:**
- After `/review` passes
- Ready to create PR
- Final step before deployment

❌ **Don't use for:**
- Tests not passing
- Review not approved
- Work-in-progress code

## How It Works

### Phase 0: Read Shipping Patterns

Reads upgrade strategies and shipping guidance:
- `../enhancements/agentic/platform/operator-patterns/upgrade-strategies.md`
- Component shipping practices (if applicable)

### Phase 1: Pre-Ship Validation

Checks readiness:
- **Code**: Tests pass, review approved, no uncommitted changes
- **API Changes**: openshift/api PR merged (if applicable)
- **Documentation**: Enhancement/docs updated (if needed)
- **Upgrade**: Supports N→N+1 upgrade (if applicable)

### Phase 2: Create Pull Request

Creates PR with:
- Brief title (<70 chars)
- Summary (what changed)
- Test plan (how to verify)
- Upgrade notes (if applicable)
- References (spec, plan)

### Phase 3: Report Completion

Reports PR created, provides rollback plan.

## Example

```bash
/agentic-docs-maintainer:ship
```

**Output:**
```
📚 Reading shipping guidance...
  ✅ upgrade-strategies.md
  ✅ [component practices - if applicable]

📋 Pre-Ship Validation:

✅ Code ready
  ✅ All tests pass
  ✅ Review approved

[✅ API changes merged - if applicable]

[✅ Documentation updated - if needed]

[✅ Upgrade strategy validated - if applicable]

📝 Creating PR...
  ✅ PR created: [URL]

🎯 Next: Monitor CI, address feedback, merge when approved
```

## Pre-Ship Validation

Checks vary by feature type:

**For operator features**, validates:
- Controller tests pass
- Status conditions implemented
- Upgrade strategy supports N→N+1

**For CLI features**, validates:
- Command tests pass
- Help text present
- User experience verified

**For library features**, validates:
- API tests pass
- Documentation updated
- Examples work

**Adapts validation to feature type - doesn't force operator checks everywhere.**

## Rollback Plan

Options if issues arise:
- **Pre-merge**: Close PR
- **Post-merge**: Create revert PR
- **Feature flag** (if available): Disable via config

## Integration with Other Skills

**Full workflow:**
```bash
# After /review passes

/ship
→ Validate readiness
→ Create PR
→ Monitor CI
→ Merge when approved
```

## Implementation

Execution handled by skill at: `skills/ship/SKILL.md`

**Key phases:**
1. Read shipping patterns (inline)
2. Validate pre-ship checklist
3. Create PR with context
4. Report completion and rollback plan

## See Also

- `/agentic-docs-maintainer:review` - Code review (previous step)
- **Full Workflow**: spec → plan → build → test → review → ship ✅

---

**Pattern**: OpenShift safe deployment  
**Version**: 2.0
