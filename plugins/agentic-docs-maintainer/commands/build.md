---
description: Incrementally implement tasks from plan following OpenShift operator patterns with TDD
---

## Name
agentic-docs-maintainer:build

## Synopsis
```
/agentic-docs-maintainer:build <task-number> [--plan-file <path>]
```

## Description
Implements feature incrementally following OpenShift operator patterns. For each task: fetches relevant patterns, writes code following those patterns, writes tests, verifies, and commits atomically.

**Key Innovation**: Uses `/fetch` before each task to retrieve specific implementation patterns for that task type.

## Arguments

- `<task-number>`: Which task to implement (e.g., task-1, task-3)
- `--plan-file <path>`: Path to plan document (optional, will search for PLAN-*.md)

## When to Use

- After `/plan` is approved and implementation begins
- Implementing each task from the plan incrementally
- Need guidance on OpenShift patterns for specific task types
- Want test-driven development workflow

**When NOT to use**:
- Plan not yet created
- Prototyping or exploring
- Emergency hotfixes

## How It Works

### For Each Task: 6-Step Workflow

```
1. Fetch Pattern   → Get implementation guidance for task type
2. Implement       → Write code following fetched pattern
3. Test            → Write tests (unit/integration/E2E)
4. Verify          → Run tests + linters
5. Commit          → Atomic commit with clear message
6. Checkpoint      → If checkpoint task, wait for approval
```

### Automatic Pattern Selection

Based on task goal, automatically fetches correct pattern:

| Task Type | Pattern Fetched |
|-----------|----------------|
| API Foundation | API evolution and CRD design |
| Basic Reconciliation | controller-runtime reconciliation |
| Status Reporting | status-conditions implementation |
| Validation/Webhook | webhook validation patterns |
| Integration Tests | envtest integration testing |
| E2E Tests | openshift-tests framework |
| Observability | Prometheus metrics + must-gather |
| Documentation | Tier 2 docs patterns |

## Examples

### Example 1: Implement Task 3 (Basic Reconciliation)

```bash
/agentic-docs-maintainer:build task-3
```

**What happens:**
```
📚 Fetching pattern: controller-runtime reconciliation
  ✅ platform/operator-patterns/controller-runtime.md
  - Reconcile() structure
  - Error handling (IgnoreNotFound)
  - Status update patterns

📝 Implementing...
  ✅ pkg/controller/myresource/controller.go created
  - Reconcile() method
  - Status updates
  - SetupWithManager()

📝 Testing...
  ✅ pkg/controller/myresource/controller_test.go created
  - TestReconcile_HappyPath
  - TestReconcile_ResourceNotFound

✅ Verification...
  ✅ make test-unit PASS (65% coverage)
  ✅ make verify PASS

📝 Committing...
  ✅ git commit -m "controller: Add basic reconciliation..."

🚧 Checkpoint 1 reached!
  - Feature compiles: ✅
  - Unit tests pass: ✅
  - Available=True: ✅
  - Waiting for human review before Task 4

✅ Task 3 complete!
```

### Example 2: Implement Task 5 (Validation)

```bash
/agentic-docs-maintainer:build task-5
```

**What happens:**
```
📚 Fetching pattern: webhook validation
  ✅ platform/operator-patterns/webhooks.md
  - ValidatingWebhookConfiguration
  - Validation handler interface
  - Error response format

📝 Implementing...
  ✅ pkg/webhook/validation.go created
  - ValidateCreate()
  - ValidateUpdate()
  - Clear error messages

📝 Testing...
  ✅ pkg/webhook/validation_test.go created
  - TestValidation_ValidConfig
  - TestValidation_InvalidConfig

✅ Verification...
  ✅ make test-unit PASS
  ✅ make verify PASS

📝 Committing...
  ✅ git commit -m "webhook: Add validating webhook..."

✅ Task 5 complete! Ready for Task 6.
```

## Task Implementation Guidance

### Task 1: API Foundation (1 week)
**Fetch**: API evolution patterns  
**Create**: openshift/api PR with CRD types  
**Test**: API generation succeeds  
**Commit**: "api: Add MyResource CRD types"

### Task 3: Basic Reconciliation (3 days)
**Fetch**: controller-runtime reconciliation  
**Create**: Controller with Reconcile() method  
**Test**: Unit tests for reconcile logic  
**Commit**: "controller: Add basic reconciliation"  
**Checkpoint**: ✓ Checkpoint 1 (MVP)

### Task 5: Validation (3 days)
**Fetch**: webhook validation patterns  
**Create**: Validating webhook or in-controller validation  
**Test**: Invalid configs rejected  
**Commit**: "webhook: Add validation"  
**Checkpoint**: ✓ Checkpoint 2 (Core complete)

### Task 7: E2E Testing (3 days)
**Fetch**: openshift-tests framework  
**Create**: E2E tests in test/extended/  
**Test**: Tests pass in CI  
**Commit**: "e2e: Add feature tests"  
**Checkpoint**: ✓ Checkpoint 3 (Tests complete)

## Anti-Patterns to Avoid

| Anti-Pattern | Why Bad | Instead |
|-------------|---------|---------|
| Implement all at once | Hard to debug | One task at a time |
| Skip tests | Breaks later | Write tests before done |
| Large commits | Hard to review | Atomic per task |
| Copy-paste code | Tech debt | Understand pattern, adapt |
| Ignore fetched pattern | Inconsistent | Follow agentic docs |

## Commit Message Format

Following `practices/development/git-workflow.md`:

```
<area>: <summary>

<detailed explanation>

- Bullet point 1
- Bullet point 2

Follows: <agentic doc reference>
Completes: Task X from PLAN-<feature>.md
```

**Example:**
```
controller: Add basic reconciliation for MyResource

Implements minimal reconciliation loop following controller-runtime
pattern.

- Reconcile() fetches resource, reconciles state, updates status
- Sets Available=True on successful reconciliation
- Uses IgnoreNotFound for deleted resources

Follows: platform/operator-patterns/controller-runtime.md
Completes: Task 3 from PLAN-webhook-validation.md
```

## Validation

**Per Task**:
- ✅ Tests pass (`make test-unit`, `make test-integration`)
- ✅ Linters pass (`make verify`)
- ✅ Code follows fetched pattern
- ✅ Commit is atomic and well-described
- ✅ Acceptance criteria from plan met

**At Checkpoints** (Tasks 3, 5, 7, 9):
- ✅ All tasks up to checkpoint complete
- ✅ No regressions (all tests still pass)
- ✅ Human reviews and approves
- 🚧 **GATE**: Must pass before next task

## Integration with Other Skills

**Full Workflow:**
```bash
# 1. SPEC created and approved
/agentic-docs-maintainer:spec "feature"

# 2. PLAN created with 9 tasks
/agentic-docs-maintainer:plan

# 3. BUILD incrementally (this command)
/agentic-docs-maintainer:build task-1  # API Foundation
/agentic-docs-maintainer:build task-2  # Vendor
/agentic-docs-maintainer:build task-3  # Basic Reconciliation → Checkpoint 1
# ... human approves ...
/agentic-docs-maintainer:build task-4  # Status Reporting
/agentic-docs-maintainer:build task-5  # Validation → Checkpoint 2
# ... continue through task-9 ...

# 4. TEST comprehensively
/agentic-docs-maintainer:test

# 5. REVIEW for quality
/agentic-docs-maintainer:review

# 6. SHIP safely
/agentic-docs-maintainer:ship
```

## Output

**Per Task**:
```
✅ Task X implemented
  Files: pkg/controller/*.go, pkg/controller/*_test.go
  Tests: 2 unit tests added
  Pattern: platform/operator-patterns/controller-runtime.md
  Commit: abc1234 "controller: Add basic reconciliation"
```

**At Checkpoints**:
```
🚧 Checkpoint Y reached
  Validation: 3/3 criteria met
  Gate: Waiting for human approval
  Next: Task Z (after approval)
```

## See Also

- `/agentic-docs-maintainer:plan` - Create implementation plan (previous step)
- `/agentic-docs-maintainer:test` - Verify all tests pass (next step)
- `/agentic-docs-maintainer:review` - Code review for compliance

---

**Pattern**: Test-driven incremental implementation  
**Version**: 1.0
