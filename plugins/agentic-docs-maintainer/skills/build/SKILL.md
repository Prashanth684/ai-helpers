---
name: build
description: OpenShift incremental implementation - implements tasks from plan following operator patterns, with tests and verification at each step. Use after /plan is approved.
trigger: explicit
model: sonnet
---

# Build - OpenShift Incremental Implementation

Implement feature incrementally, one task at a time. For each task: read relevant patterns, write code, write tests, verify, commit.

---

## 🚨 EXECUTE THESE PHASES IN ORDER 🚨

```
READ TASK ──→ READ PATTERNS ──→ IMPLEMENT ──→ VERIFY ──→ COMMIT
     │              │                │           │          │
     ▼              ▼                ▼           ▼          ▼
   Show          Show             Write        Run        Create
  Summary      Guidance           Code        Tests      Commit
```

**DO NOT skip phases. DO NOT proceed without completing current phase.**

---

## PHASE 0: Read Task from Plan

```
📖 Phase 0: Reading Task
Plan: PLAN-[name].md
Task: task-[number]
```

Extract from plan:
- Task description (what to build)
- Acceptance criteria (how you know it's done)
- Verification command (test to run)
- Dependencies (prerequisites)

```
✅ Task Read:
  Number: task-[X]
  Description: [what to build]
  Type: [API/controller/CLI/library/other]
  Acceptance: [list criteria]
```

---

## PHASE 1: Read Relevant Patterns (Inline)

**DO NOT use Skill("fetch"). Read files directly.**

### Identify What Patterns You Need

Based on task type:

**For API/CRD tasks** → Read:
- `../enhancements/agentic/practices/development/api-evolution.md`
- `../enhancements/agentic/domain/kubernetes/crds.md`

**For controller tasks** → Read:
- `../enhancements/agentic/platform/operator-patterns/controller-runtime.md`
- `../enhancements/agentic/platform/operator-patterns/status-conditions.md`

**For webhook tasks** → Read:
- `../enhancements/agentic/platform/operator-patterns/webhooks.md`

**For testing tasks** → Read:
- `../enhancements/agentic/practices/testing/pyramid.md`

**For CLI tasks** → Read:
- Component architecture/command structure
- Similar commands in codebase

**Read only what you need for THIS task. Don't read everything.**

### Report

```
✅ Patterns Retrieved:
  ✅ [pattern 1]
  ✅ [pattern 2]

🎯 Ready to implement
```

---

## PHASE 2: Implement Task

```
📝 Phase 2: Implementing Task [X]

Approach: Follow patterns, write tests alongside code
```

### Implementation Principles

**Write tests FIRST or ALONGSIDE code**:
- Unit test for business logic
- Integration test if touching multiple components
- E2E test if task requires it

**Follow patterns from Phase 1**:
- Use existing code structure
- Match naming conventions
- Follow error handling patterns

**Incremental commits**:
- Commit when feature works
- Commit message describes what changed

### What to Create

Based on task type, create appropriate files:

**For API tasks**: Types, validation, defaults
**For controller tasks**: Reconcile logic, client calls
**For webhook tasks**: Validation/mutation handlers
**For CLI tasks**: Command, flags, output
**For library tasks**: Interface, implementation

**Don't force a template. Build what the task requires.**

### Report Progress

```
✅ Implementation:
  Files created: [list]
  Files modified: [list]
  Tests added: [list]
```

---

## PHASE 3: Verify Task

```
✅ Phase 3: Verifying Task [X]

Run verification from plan
```

### Run Verification Command

Execute the verification command from the plan:
```bash
# Example from plan
make test-unit
make test-integration
```

### Check Acceptance Criteria

Go through each criterion from plan:
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

**If ANY criterion fails, go back to Phase 2.**

### Report

```
✅ Verification Complete:
  ✅ All tests pass
  ✅ All acceptance criteria met
```

---

## PHASE 4: Commit Changes

```
📦 Phase 4: Committing Task [X]
```

### Create Atomic Commit

```bash
git add [files]
git commit -m "$(cat <<'EOF'
[Task X]: [Brief description]

[Longer description if needed]

Implements: [reference to plan task]
Tests: [what tests were added]

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

### Report

```
✅ Committed: [commit hash]

🎯 Next: 
  - If checkpoint: Manual review required
  - If regular task: /build task-[X+1]
```

**DONE.**

---

## Red Flags - You're Doing It Wrong

| Red Flag | Fix |
|----------|-----|
| Writing code without tests | Write tests first or alongside code. |
| Skipping verification | Run tests. Check acceptance criteria. |
| Using Skill("fetch") | Read patterns inline. |
| Implementing multiple tasks at once | One task at a time. Commit atomically. |
| No commit message | Describe what changed and why. |

---

## Common Rationalizations - Don't Make These

| Excuse | Reality |
|--------|---------|
| "I'll write tests later" | Write tests now. Later never comes. |
| "Verification takes too long" | Fast feedback catches bugs early. |
| "One big commit is fine" | Atomic commits = easier to review/revert. |

---

## Pre-Implementation Checklist

- [ ] Task read from plan
- [ ] Task type identified
- [ ] Relevant patterns read (only what you need)
- [ ] Understand acceptance criteria
- [ ] Know verification command

**If unchecked, DO NOT implement.**

---

## Pre-Commit Checklist

- [ ] Code written
- [ ] Tests written (unit/integration/E2E as needed)
- [ ] Verification command passes
- [ ] All acceptance criteria met
- [ ] Files staged for commit

**If unchecked, DO NOT commit.**

---

**Pattern**: OpenShift incremental implementation  
**Version**: 2.0
