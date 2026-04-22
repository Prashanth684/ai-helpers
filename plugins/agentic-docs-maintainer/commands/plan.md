---
description: Break down approved spec into ordered, implementable tasks following OpenShift practices
---

## Name
agentic-docs-maintainer:plan

## Synopsis
```
/agentic-docs-maintainer:plan [spec-file] [--component <name>]
```

## Description
Breaks down an approved feature specification into ordered, implementable tasks following OpenShift development practices. Creates dependency graph, vertical slices with checkpoints, and timeline estimate.

**Key Innovation**: Uses `/fetch` to retrieve component architecture and implementation workflows before creating the task breakdown.

## Arguments

- `[spec-file]`: Path to spec document (optional, will search for SPEC-*.md)
- `--component <name>`: Component repository name (e.g., machine-config-operator)

## When to Use

- After `/spec` is approved and ready for implementation
- Breaking down a large feature into manageable tasks
- Planning implementation timeline and dependencies
- Need structured approach for multi-week projects

**When NOT to use**:
- Spec not yet approved
- Simple one-file changes
- Bug fixes that don't need planning

## How It Works

### Phase 0: Automatic Pattern Retrieval

```bash
# Automatically fetches implementation guidance
📚 Fetching OpenShift implementation patterns...
📡 Fetching component architecture...
🔍 Finding similar implementations...
```

### What Gets Fetched

**Always**:
- Implementation workflow (practices/development/implementing-features.md)
- Git workflow (practices/development/git-workflow.md)
- Testing pyramid (practices/testing/pyramid.md)
- API evolution patterns (practices/development/api-evolution.md)

**If --component specified**:
- Component architecture and code structure
- Similar feature implementations
- Component-specific patterns

### Output

Creates implementation plan with:

1. **Dependency Analysis** - What blocks what
2. **Vertical Slices** - 9 ordered tasks (API → MVP → Status → Validation → Integration → E2E → Observability → Docs)
3. **Checkpoints** - 4 validation gates
4. **Timeline Estimate** - Week-by-week breakdown
5. **Risk Assessment** - High/Medium/Low risks with mitigations

## Examples

### Example 1: Simple Feature

```bash
/agentic-docs-maintainer:plan SPEC-webhook-validation.md
```

**What happens:**
```
📚 Fetching implementation patterns...
  ✅ practices/development/implementing-features.md
  ✅ practices/development/git-workflow.md
  ✅ practices/testing/pyramid.md

📝 Creating implementation plan...
  ✅ PLAN-webhook-validation.md

🎯 Plan created!
  - 9 tasks defined
  - 4 checkpoints set
  - 5 week estimate
  - Ready for /build
```

### Example 2: Component-Specific Feature

```bash
/agentic-docs-maintainer:plan --component machine-config-operator
```

**What happens:**
```
📚 Fetching implementation patterns...
  ✅ practices/development/implementing-features.md
  ✅ practices/testing/pyramid.md

📡 Fetching component architecture...
  ✅ machine-config-operator/agentic/AGENTS.md
  ✅ machine-config-operator/agentic/architecture/components.md

🔍 Finding similar implementations...
  - cluster-network-operator: Similar reconciliation pattern
  - machine-api-operator: Similar status reporting

📝 Creating implementation plan...
  ✅ PLAN-node-drain-timeout.md
  ✅ machine-config-operator/agentic/exec-plans/active/node-drain-timeout.md

🎯 Plan created!
  - 9 tasks tailored to MCO architecture
  - Checkpoint gates aligned with MCO practices
```

## Task Structure

Each task includes:

### Task Metadata
- **Goal**: What this task delivers
- **Time Estimate**: Days/weeks
- **Depends On**: Prerequisites
- **Blocks**: What depends on this
- **Pattern Source**: Which agentic doc guided design

### Work Items
- [ ] Checklist of concrete steps
- [ ] Files to create/modify
- [ ] Commands to run
- [ ] Tests to write

### Acceptance Criteria
- ✅ Specific, testable conditions
- ✅ Must pass before next task

## Typical Task Breakdown

### Task 1: API Foundation (1 week)
- Define CRD types
- API review
- Merge openshift/api PR

### Task 2: Vendor Dependencies (1 day)
- Update go.mod
- Vendor openshift/api

### Task 3: Basic Reconciliation / MVP (3 days)
- Controller skeleton
- Reconcile() method
- Available=True status
- Unit tests

### Task 4: Full Status Reporting (2 days)
- Progressing condition
- Degraded condition
- Upgradeable condition
- All conditions tested

### Task 5: Validation & Safety (3 days)
- Validation logic
- Webhook (if needed)
- Error handling
- Validation tests

### Task 6: Integration Testing (2 days)
- Happy path test
- Error case tests
- Upgrade tests

### Task 7: E2E Testing (3 days)
- Feature installation test
- User workflow test
- Upgrade N→N+1 test
- openshift-tests integration

### Task 8: Observability (2 days)
- Prometheus metrics
- ServiceMonitor
- Must-gather support
- Alerts (if needed)

### Task 9: Documentation (2 days)
- Update AGENTS.md
- Create exec-plan
- Update architecture docs
- Enhancement merged

## Checkpoints

**4 validation gates** spaced throughout:

### Checkpoint 1: After Task 3 (MVP)
- Feature compiles
- Unit tests pass
- Available=True works
- Gate: Proceed to status reporting?

### Checkpoint 2: After Task 5 (Validation)
- All unit tests pass
- Integration tests pass
- Errors handled
- Gate: Proceed to E2E?

### Checkpoint 3: After Task 7 (E2E)
- E2E tests pass in CI
- Upgrade tests pass
- Gate: Proceed to observability?

### Checkpoint 4: After Task 9 (Docs)
- All tests pass
- Metrics working
- Docs complete
- Gate: Ready to ship?

## Timeline Estimate

Typical 5-week breakdown:

| Week | Focus | Checkpoint |
|------|-------|-----------|
| 1 | API foundation | - |
| 2 | MVP implementation | ✓ Checkpoint 1 |
| 3 | Status + validation | ✓ Checkpoint 2 |
| 4 | Integration + E2E | ✓ Checkpoint 3 |
| 5 | Observability + docs | ✓ Checkpoint 4 |

**Risk buffer**: +1 week for delays

## Integration with Other Skills

**Full Workflow:**
```bash
# 1. CREATE SPEC
/agentic-docs-maintainer:spec "feature description"
→ Spec created with patterns

# 2. PLAN IMPLEMENTATION (this command)
/agentic-docs-maintainer:plan
→ Tasks created with dependencies and checkpoints

# 3. BUILD INCREMENTALLY
/agentic-docs-maintainer:build task-1
→ Implement task 1 following patterns

/agentic-docs-maintainer:build task-2
→ Implement task 2 following patterns

# 4. TEST COMPREHENSIVELY
/agentic-docs-maintainer:test
→ Verify all tests pass

# 5. REVIEW FOR QUALITY
/agentic-docs-maintainer:review
→ Check compliance with patterns

# 6. SHIP SAFELY
/agentic-docs-maintainer:ship
→ Deploy with upgrade strategy
```

## Validation

Before advancing to `/build`:
- ✅ All 9 tasks have acceptance criteria
- ✅ Dependencies ordered correctly  
- ✅ Checkpoints defined
- ✅ **Human approves plan** ← GATE

## Implementation

Execution handled by skill at: `skills/plan/SKILL.md`

**Key phases:**
1. Phase 0: Fetch implementation patterns, component architecture
2. Phase 1: Analyze dependencies (API → implementation → tests → docs)
3. Phase 2: Create vertical slices (9 standard tasks)
4. Phase 3: Add checkpoints (4 validation gates)
5. Phase 4: Estimate timeline and risks

## See Also

- `/agentic-docs-maintainer:spec` - Create specification (previous step)
- `/agentic-docs-maintainer:build` - Implement tasks (next step)
- `/agentic-docs-maintainer:test` - Verify implementation

---

**Pattern**: OpenShift implementation planning with vertical slicing  
**Version**: 1.0
