---
description: Incrementally implement tasks from plan following OpenShift patterns with tests
---

## Name
agentic-docs-maintainer:build

## Synopsis
```
/agentic-docs-maintainer:build <task-number> [--plan-file <path>]
```

## Description
Implements feature incrementally, one task at a time. For each task: reads relevant patterns, writes code, writes tests, verifies, commits atomically.

**Approach**: Let the task guide what patterns to read. Don't fetch everything - read only what you need.

## Arguments

- `<task-number>`: Which task to implement (e.g., task-1, task-3)
- `--plan-file <path>`: Path to plan document (optional, will search for PLAN-*.md)

## When to Use

✅ **Use for:**
- Implementing tasks from approved plan
- Need pattern guidance for specific task type
- Want incremental, verifiable progress

❌ **Don't use for:**
- Plan not yet created
- Prototyping (just code directly)
- Emergency hotfixes (skip process)

## How It Works

### For Each Task: 4-Phase Workflow

```
READ TASK → READ PATTERNS → IMPLEMENT → VERIFY & COMMIT
```

### Phase 0: Read Task

Reads task from PLAN-*.md:
- Description (what to build)
- Acceptance criteria (how to verify)
- Verification command (test to run)

### Phase 1: Read Relevant Patterns

**Based on task type, reads appropriate patterns**:

- **API tasks**: Read api-evolution.md, crds.md
- **Controller tasks**: Read controller-runtime.md, status-conditions.md
- **Webhook tasks**: Read webhooks.md
- **Testing tasks**: Read pyramid.md, e2e-framework.md
- **CLI tasks**: Read component architecture, similar commands

**Reads only what's needed for THIS task.**

### Phase 2: Implement

Writes code following patterns:
- Uses existing code structure
- Matches naming conventions
- Writes tests alongside code (TDD)
- Follows error handling patterns

### Phase 3: Verify & Commit

Runs verification from plan:
```bash
# Example verification
make test-unit
make test-integration
```

Creates atomic commit:
```bash
git commit -m "[Task X]: Brief description

[Longer context]

Implements: task-X from plan
Tests: [what tests added]
"
```

## Examples

### Example 1: Implement Controller Task

```bash
/agentic-docs-maintainer:build task-2
```

**What happens:**
```
📖 Reading task...
  ✅ Task 2: Basic reconciliation controller

📚 Reading patterns...
  ✅ controller-runtime.md
  ✅ status-conditions.md

📝 Implementing...
  ✅ pkg/controller/reconciler.go
  ✅ pkg/controller/reconciler_test.go

✅ Verifying...
  ✅ make test-unit PASS

📦 Committing...
  ✅ Committed: abc123

🎯 Next: /build task-3
```

### Example 2: Implement CLI Task

```bash
/agentic-docs-maintainer:build task-1
```

**What happens:**
```
📖 Reading task...
  ✅ Task 1: Add 'oc adm foo' command

📚 Reading patterns...
  ✅ ../oc/agentic/architecture/command-structure.md

📝 Implementing...
  ✅ cmd/oc/cli/admin/foo/foo.go
  ✅ cmd/oc/cli/admin/foo/foo_test.go

✅ Verifying...
  ✅ make test-unit PASS
  ✅ ./oc adm foo --help works

📦 Committing...
  ✅ Committed: def456

🎯 Next: /build task-2
```

## Checkpoints

When task is a checkpoint:
```
🚧 Checkpoint Reached!

Validation:
  ✅ [Check 1 from plan]
  ✅ [Check 2 from plan]

Manual approval required before continuing.

Respond:
  ✅ "proceed" → Continue to next task
  ✏️  "fix: <feedback>" → Address issues
  ❌ "abort" → Stop
```

## Best Practices

**Good implementation**:
- ✅ Write tests alongside code (not after)
- ✅ Run verification before committing
- ✅ Atomic commits (one task = one commit)
- ✅ Clear commit messages

**Bad implementation**:
- ❌ Write all code, then all tests
- ❌ Skip verification
- ❌ Big commits spanning multiple tasks
- ❌ Vague commit messages ("wip", "fixes")

## Integration with Other Skills

**Full workflow:**
```bash
# After /plan approved

# Implement tasks incrementally
/build task-1
/build task-2
# Checkpoint - manual approval
/build task-3
...

# After all tasks complete
/test          # Verify comprehensive testing
/review        # Check compliance
/ship          # Create PR
```

## Implementation

Execution handled by skill at: `skills/build/SKILL.md`

**Key phases:**
1. Read task from plan
2. Read relevant patterns (only what's needed)
3. Implement with tests
4. Verify and commit

## See Also

- `/agentic-docs-maintainer:plan` - Create task breakdown (previous step)
- `/agentic-docs-maintainer:test` - Verify comprehensive testing (after all tasks)
- `/agentic-docs-maintainer:review` - Check compliance (before ship)

---

**Pattern**: OpenShift incremental implementation  
**Version**: 2.0
