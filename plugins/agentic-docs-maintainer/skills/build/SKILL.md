---
name: build
description: OpenShift incremental implementation - implements tasks from plan following operator patterns, with tests and verification at each step. Use after /plan is approved.
trigger: explicit
model: sonnet
---

# Build - OpenShift Incremental Implementation

## Overview

Implement feature incrementally following OpenShift operator patterns. For each task from the plan: fetch relevant patterns, write code following those patterns, write tests, verify, and commit atomically.

**Key Innovation**: Uses `/fetch` before each task to retrieve specific implementation patterns, ensuring code follows current OpenShift practices.

## What This Skill Operates On

**Input**: PLAN-*.md file + existing codebase + task-specific patterns
- PLAN-{feature-name}.md (task description and acceptance criteria)
- Existing codebase (to understand where to add code)
- Fetched pattern for specific task type (controller-runtime, webhooks, testing, etc.)
- Component code structure

**Output**: Code + tests + git commit
- Go source files (`pkg/controller/*.go`)
- Test files (`pkg/controller/*_test.go`)
- Git commit with descriptive message
- Checkpoint validation (if applicable)

**Artifacts Created**:
- Implementation files (Go code)
- Test files
- Git commits (atomic, one per task)

## When to Use

- After `/plan` is approved and implementation begins
- Implementing each task from the plan incrementally
- Need guidance on how to implement specific OpenShift patterns
- Want to follow test-driven development

**When NOT to use**:
- Plan not yet created or approved
- Just exploring or prototyping (no need for full TDD)
- Emergency hotfixes (skip process, fix directly)

**Natural Language**:
- "Implement task 3"
- "Build the basic reconciliation controller"
- "Write the code for task 5"

## Arguments

```bash
/build <task-number> [--plan-file <path>] [--feedback "text"] [--auto-approve] [--max-retries N]
```

**Arguments:**
- `<task-number>`: Which task to implement (e.g., task-1, task-3)
- `--plan-file <path>`: Path to plan document (optional, will search for PLAN-*.md)
- `--feedback "text"`: Revision feedback from previous attempt (optional, used to fix issues)
- `--auto-approve`: Skip approval gate and proceed to next task (optional, default: false for checkpoints, true for regular tasks)
- `--max-retries N`: Maximum fix attempts before giving up (optional, default: 3)

**Examples:**
```bash
# Implement task 1 from plan
/build task-1

# Implement task 3 with explicit plan file
/build task-3 --plan-file PLAN-webhook-validation.md

# Implement next checkpoint task
/build task-3  # (after completing task-1 and task-2)
```

## Execution Protocol

### Phase 0: Fetch Implementation Pattern for Task

**CRITICAL**: Retrieve specific pattern BEFORE writing code.

**Actions:**
```bash
# Step 1: Read task from plan
TASK_NUMBER=$1  # e.g., "task-3"
TASK_GOAL=$(grep "### Task $TASK_NUMBER:" PLAN-*.md -A 1)

# Step 2: Determine which pattern to fetch based on task goal
case "$TASK_GOAL" in
    *"API Foundation"*)
        PATTERN="API evolution and CRD design patterns"
        ;;
    *"Basic Reconciliation"*|*"MVP"*)
        PATTERN="controller-runtime reconciliation pattern"
        ;;
    *"Status Reporting"*)
        PATTERN="status conditions implementation"
        ;;
    *"Validation"*|*"Webhook"*)
        PATTERN="webhook validation and admission control"
        ;;
    *"Integration Testing"*)
        PATTERN="integration testing with envtest"
        ;;
    *"E2E Testing"*)
        PATTERN="E2E testing with openshift-tests framework"
        ;;
    *"Observability"*)
        PATTERN="Prometheus metrics and must-gather"
        ;;
    *)
        PATTERN="general implementation patterns"
        ;;
esac

# Step 3: Fetch the relevant pattern
echo "📚 Fetching pattern for $TASK_GOAL..."
/fetch "$PATTERN" --tier1-only

# Step 4: If component-specific, also fetch component patterns
if [ -n "$COMPONENT" ]; then
    /fetch "component implementation patterns" --tier2 openshift/$COMPONENT
fi
```

**Output from Phase 0:**
```markdown
📚 Fetched Pattern: controller-runtime reconciliation
  ✅ platform/operator-patterns/controller-runtime.md
  - Reconcile() function structure
  - Error handling patterns (IgnoreNotFound, requeue strategies)
  - Status update patterns
  - Watches and event filters
  
📚 Code Examples Found:
  - machine-api-operator: Similar reconciliation loop
  - cluster-network-operator: Status update pattern

🎯 Ready to implement Task 3!
```

### Phase 1: Implement Following Pattern

Based on fetched pattern, write code:

**Template for Task Implementation:**

#### Step 1.1: Create/Modify Files

```go
// Example: Task 3 - Basic Reconciliation
// File: pkg/controller/myresource/controller.go

// Structure from fetched pattern: controller-runtime.md

package myresource

import (
    "context"
    
    ctrl "sigs.k8s.io/controller-runtime"
    "sigs.k8s.io/controller-runtime/pkg/client"
    
    myv1 "github.com/openshift/api/mygroup/v1"
)

// MyReconciler reconciles MyResource
type MyReconciler struct {
    client.Client
}

// Reconcile implements the reconciliation loop
// Pattern source: platform/operator-patterns/controller-runtime.md
func (r *MyReconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    // 1. Fetch resource (pattern: handle not found gracefully)
    obj := &myv1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        // Pattern: IgnoreNotFound - resource was deleted, not an error
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }
    
    // 2. Reconcile to desired state (pattern: idempotent operations)
    if err := r.reconcile(ctx, obj); err != nil {
        // Pattern: Return error - controller-runtime will requeue automatically
        return ctrl.Result{}, err
    }
    
    // 3. Update status (pattern: Always update status, even on success)
    obj.Status.Conditions = []metav1.Condition{
        {
            Type:               "Available",
            Status:             metav1.ConditionTrue,
            Reason:             "AsExpected",
            Message:            "MyResource reconciled successfully",
            LastTransitionTime: metav1.Now(),
        },
    }
    
    if err := r.Status().Update(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }
    
    return ctrl.Result{}, nil
}

// reconcile performs the actual reconciliation logic
func (r *MyReconciler) reconcile(ctx context.Context, obj *myv1.MyResource) error {
    // TODO: Implement based on spec requirements
    // Pattern: Keep logic separate from status updates for testability
    return nil
}

// SetupWithManager sets up the controller with the Manager
// Pattern source: controller-runtime.md
func (r *MyReconciler) SetupWithManager(mgr ctrl.Manager) error {
    return ctrl.NewControllerManagedBy(mgr).
        For(&myv1.MyResource{}).
        Complete(r)
}
```

#### Step 1.2: Explain Patterns Used

```markdown
## Patterns Applied (from fetched docs)

### 1. IgnoreNotFound Error Handling
**Source**: `platform/operator-patterns/controller-runtime.md`
**Rationale**: Resource deletion is not an error condition - it means reconciliation is complete (resource gone).

### 2. Idempotent Reconciliation
**Source**: `DESIGN_PHILOSOPHY.md` (declarative over imperative)
**Rationale**: Reconcile() can be called multiple times, must produce same result.

### 3. Separate Business Logic from Status Updates
**Source**: `platform/operator-patterns/controller-runtime.md`
**Rationale**: Makes code testable - can test reconcile() without Kubernetes API.

### 4. Always Update Status
**Source**: `platform/operator-patterns/status-conditions.md`
**Rationale**: Consumers watch status for changes - even "no change" needs timestamp update.
```

### Phase 2: Write Tests

Following testing pyramid (60% unit, 30% integration, 10% E2E):

```go
// File: pkg/controller/myresource/controller_test.go

package myresource

import (
    "context"
    "testing"
    
    metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
    "k8s.io/apimachinery/pkg/runtime"
    ctrl "sigs.k8s.io/controller-runtime"
    "sigs.k8s.io/controller-runtime/pkg/client/fake"
    
    myv1 "github.com/openshift/api/mygroup/v1"
)

// Pattern source: practices/testing/pyramid.md - Unit tests (60%)

func TestReconcile_HappyPath(t *testing.T) {
    // Arrange: Create fake client with test object
    obj := &myv1.MyResource{
        ObjectMeta: metav1.ObjectMeta{
            Name:      "test",
            Namespace: "default",
        },
    }
    
    scheme := runtime.NewScheme()
    myv1.AddToScheme(scheme)
    
    client := fake.NewClientBuilder().
        WithScheme(scheme).
        WithObjects(obj).
        Build()
    
    reconciler := &MyReconciler{Client: client}
    
    // Act: Reconcile
    req := ctrl.Request{
        NamespacedName: client.ObjectKeyFromObject(obj),
    }
    result, err := reconciler.Reconcile(context.TODO(), req)
    
    // Assert: No error, status updated
    if err != nil {
        t.Fatalf("Reconcile failed: %v", err)
    }
    if result.Requeue {
        t.Error("Expected no requeue")
    }
    
    // Verify status condition
    var updated myv1.MyResource
    if err := client.Get(context.TODO(), req.NamespacedName, &updated); err != nil {
        t.Fatalf("Failed to get updated object: %v", err)
    }
    
    if len(updated.Status.Conditions) != 1 {
        t.Errorf("Expected 1 condition, got %d", len(updated.Status.Conditions))
    }
    
    if updated.Status.Conditions[0].Type != "Available" {
        t.Errorf("Expected Available condition, got %s", updated.Status.Conditions[0].Type)
    }
}

func TestReconcile_ResourceNotFound(t *testing.T) {
    // Pattern: IgnoreNotFound means this should succeed
    scheme := runtime.NewScheme()
    myv1.AddToScheme(scheme)
    
    client := fake.NewClientBuilder().
        WithScheme(scheme).
        Build()
    
    reconciler := &MyReconciler{Client: client}
    
    req := ctrl.Request{
        NamespacedName: types.NamespacedName{
            Name:      "does-not-exist",
            Namespace: "default",
        },
    }
    
    result, err := reconciler.Reconcile(context.TODO(), req)
    
    // Should NOT error (IgnoreNotFound)
    if err != nil {
        t.Errorf("Expected no error for not found, got: %v", err)
    }
    if result.Requeue {
        t.Error("Expected no requeue")
    }
}
```

### Phase 3: Verify Tests Pass

```bash
# Run unit tests
make test-unit

# Expected output:
# ✅ TestReconcile_HappyPath PASS
# ✅ TestReconcile_ResourceNotFound PASS
# ✅ Coverage: 65% (meets 60% unit test target)
```

### Phase 4: Verify Code Quality

```bash
# Run linters
make verify

# Expected checks:
# ✅ gofmt: Code formatted
# ✅ govet: No suspicious constructs
# ✅ golint: Style conformant
# ✅ go mod tidy: Dependencies clean
```

### Phase 5: Commit Atomically

Following `practices/development/git-workflow.md`:

```bash
# Add only files for this task
git add pkg/controller/myresource/controller.go
git add pkg/controller/myresource/controller_test.go

# Commit with descriptive message
git commit -m "controller: Add basic reconciliation for MyResource

Implements minimal reconciliation loop following controller-runtime
pattern from platform/operator-patterns/controller-runtime.md.

- Reconcile() fetches resource, reconciles state, updates status
- Sets Available=True on successful reconciliation
- Uses IgnoreNotFound for deleted resources
- Separates business logic (reconcile) from status updates

Tests:
- TestReconcile_HappyPath: Verifies successful reconciliation
- TestReconcile_ResourceNotFound: Verifies IgnoreNotFound pattern

Follows: platform/operator-patterns/controller-runtime.md
Completes: Task 3 from PLAN-myfeature.md
"
```

### Phase 6: Checkpoint Validation (if applicable)

If task is a checkpoint task (e.g., Task 3 = Checkpoint 1):

```markdown
## Checkpoint 1 Validation

From plan, must verify:
- [x] Feature compiles → `make build` succeeds
- [x] Unit tests pass → `make test-unit` succeeds  
- [x] Feature reports Available=True → Test verified
- [ ] Human reviews: Basic reconciliation works

🚧 **GATE**: Wait for human approval before proceeding to Task 4
```

**Output:**
```
✅ Task 3 complete!
📝 Checkpoint 1 reached
🚧 Waiting for human review before Task 4
```

### Phase 6.5: Approval Gate

**CRITICAL**: After completing each task, pause for human review unless `--auto-approve` is set.

**Note**: For checkpoint tasks (Task 3, 5, 7, 9), approval is ALWAYS required regardless of `--auto-approve`.

**Actions:**

```bash
# Determine if this is a checkpoint task
IS_CHECKPOINT=false
if grep -q "Checkpoint" PLAN-*.md | grep -q "Task $TASK_NUMBER"; then
    IS_CHECKPOINT=true
fi

# Check if auto-approve is enabled (ignored for checkpoints)
if [[ "$AUTO_APPROVE" == "true" ]] && [[ "$IS_CHECKPOINT" == "false" ]]; then
    echo "✓ Auto-approve enabled. Proceeding to next task."
    # Continue to next task
else
    # Show approval gate message
    cat <<EOF

════════════════════════════════════════════════════════════════
  REVIEW GATE: Task $TASK_NUMBER Complete
════════════════════════════════════════════════════════════════

📄 Task: $(grep "### Task $TASK_NUMBER:" PLAN-*.md)
✅ Implementation complete
✅ Tests passing
✅ Code committed: $(git log -1 --oneline)

Please review the implementation and respond:

  • "approve" or "looks good" 
    → I'll proceed to the next task
  
  • "revise: <your feedback>"
    → I'll fix the issues and re-implement this task
    → Example: "revise: add error handling for nil pointer case"
  
  • "abort" or "cancel"
    → I'll stop here without proceeding

Files changed:
$(git diff HEAD~1 --name-only)

Test results:
$(make test-unit 2>&1 | tail -5)

════════════════════════════════════════════════════════════════

$(if [[ "$IS_CHECKPOINT" == "true" ]]; then
    echo "🚧 CHECKPOINT: Human approval REQUIRED before proceeding"
else
    echo "Waiting for your review decision..."
fi)

EOF
    
    # Exit here - return control to user
    exit 0
fi
```

**Natural Language Detection:**

When the user responds, Claude Code's conversational layer detects intent:

**Approval phrases** (proceed to next task):
- "approve", "approved", "LGTM", "looks good", "proceed", "continue", "yes", "next task"

**Revision phrases** (fix and re-implement current task):
- "revise: <feedback>"
- "fix <feedback>"  
- "add <feedback>"
- "change <feedback>"
- "the code needs <feedback>"

**Abort phrases** (stop workflow):
- "abort", "cancel", "stop", "nevermind", "no"

**Revision Flow:**

When revision is detected:
1. Extract feedback from user message
2. Check attempt count (tracked in `.work/build-state-task-N.json`)
3. If attempts < max_retries:
   - Re-invoke: `/build task-N --feedback "user feedback"`
   - Increment attempt count
   - Fix identified issues
   - Re-run tests
   - Amend or create new commit
4. If attempts >= max_retries:
   - Report: "Maximum retries reached. Task may need manual fixing."
   - Save current state and exit

**State Tracking:**

```json
// .work/build-state-task-3.json
{
  "task_number": 3,
  "task_name": "Basic Reconciliation",
  "attempt": 2,
  "max_retries": 3,
  "last_commit": "abc123d",
  "last_feedback": "add error handling for nil pointer",
  "is_checkpoint": true
}
```

---

## Anti-Patterns to Avoid

Based on fetched practices:

| Anti-Pattern | Why Bad | What to Do Instead |
|-------------|---------|-------------------|
| **Implement all at once** | Hard to debug, test, review | One task at a time, verify before next |
| **Skip unit tests** | Breaks on refactor, no safety net | Write tests before marking task done |
| **Large commits** | Hard to review, hard to revert | Atomic commits per task |
| **Copy-paste code without understanding** | Doesn't match patterns, creates tech debt | Fetch pattern, understand, adapt to use case |
| **Ignore fetched patterns** | Code doesn't match OpenShift style | Follow pattern from fetched docs |
| **Modify multiple components in one commit** | Unclear scope, hard to revert | Separate commits for API vs implementation |

**Pattern Source**: `practices/development/implementing-features.md`

---

## Task-Specific Guidance

### Task 1: API Foundation
**Fetch**: API evolution patterns
**Files**: `config/v1/types_myresource.go` in openshift/api
**Key**: Start with alpha API, use +optional for all fields, kubebuilder validation
**Test**: API generation succeeds, CRD manifests valid

### Task 2: Vendor Dependencies
**Fetch**: Dependency management
**Files**: `go.mod`, `go.sum`, `vendor/`
**Key**: Vendor after openshift/api PR merges, verify build
**Test**: `make build` succeeds

### Task 3: Basic Reconciliation (MVP)
**Fetch**: controller-runtime reconciliation
**Files**: `pkg/controller/*/controller.go`
**Key**: Minimal reconcile loop, Available=True only
**Test**: Unit tests for reconcile logic

### Task 4: Full Status Reporting
**Fetch**: status-conditions implementation
**Files**: `pkg/controller/*/status.go`
**Key**: All 4 conditions (Available/Progressing/Degraded/Upgradeable)
**Test**: Unit tests for all condition transitions

### Task 5: Validation & Safety
**Fetch**: webhook validation patterns
**Files**: `pkg/webhook/validation.go`
**Key**: Validating webhook or in-controller validation
**Test**: Invalid config rejected, error messages clear

### Task 6: Integration Testing
**Fetch**: integration testing with envtest
**Files**: `test/integration/*_test.go`
**Key**: Real Kubernetes API (envtest), test reconcile loop end-to-end
**Test**: Integration tests pass

### Task 7: E2E Testing
**Fetch**: E2E framework (openshift-tests)
**Files**: `test/extended/*_test.go`
**Key**: Ginkgo v2, real cluster, user workflows
**Test**: E2E tests pass in CI

### Task 8: Observability
**Fetch**: Prometheus metrics patterns
**Files**: `pkg/metrics/metrics.go`, `manifests/servicemonitor.yaml`
**Key**: Counter, histogram, gauge metrics; must-gather script
**Test**: Metrics scraped, must-gather collects data

### Task 9: Documentation
**Fetch**: Tier 2 documentation patterns
**Files**: `agentic/AGENTS.md`, `agentic/exec-plans/active/*.md`
**Key**: Update architecture docs, create exec-plan
**Test**: Docs accurate and complete

---

## Validation

After each task:
1. ✅ Tests pass locally (`make test-unit`)
2. ✅ Code follows fetched pattern
3. ✅ Commit is atomic and well-described
4. ✅ If checkpoint: Wait for human approval

Before advancing to next task:
- ✅ Current task acceptance criteria met
- ✅ No regressions (all previous tests still pass)
- ✅ Ready to start next task

---

## Output Format

**Per Task:**
```
✅ Task X implemented
  - Files: [list of files created/modified]
  - Tests: [list of tests written]
  - Pattern: [which agentic doc followed]
  - Commit: [commit hash]
```

**At Checkpoints:**
```
🚧 Checkpoint Y reached
  - Validation: [checklist status]
  - Gate: Waiting for human approval
  - Next: Task Z (after approval)
```

---

## Example: Full Task Flow

```bash
# Start Task 3 (Basic Reconciliation)
$ /build task-3

# Phase 0: Fetch pattern
📚 Fetching pattern: controller-runtime reconciliation
  ✅ platform/operator-patterns/controller-runtime.md

# Phase 1: Implement
📝 Writing pkg/controller/myresource/controller.go
  - Reconcile() function
  - Error handling (IgnoreNotFound)
  - Status updates

# Phase 2: Test
📝 Writing pkg/controller/myresource/controller_test.go
  - TestReconcile_HappyPath
  - TestReconcile_ResourceNotFound

# Phase 3: Verify
✅ make test-unit PASS
✅ make verify PASS

# Phase 4: Commit
📝 git commit -m "controller: Add basic reconciliation..."

# Phase 5: Checkpoint
🚧 Checkpoint 1 reached - waiting for human approval

✅ Task 3 complete!
```

---

**Pattern Source**:
- `practices/development/implementing-features.md`
- `platform/operator-patterns/controller-runtime.md`
- `practices/testing/pyramid.md`
- `practices/development/git-workflow.md`

**Validation Gate**: Each task must pass tests and follow patterns before next task
