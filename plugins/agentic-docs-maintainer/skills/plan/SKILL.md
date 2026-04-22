---
name: plan
description: OpenShift implementation planning - breaks down approved spec into ordered, implementable tasks following OpenShift development practices. Use after /spec is approved.
trigger: explicit
model: sonnet
---

# Plan - OpenShift Implementation Planning

Break down an approved specification into ordered, implementable tasks. Tasks should be small, verifiable, and have clear acceptance criteria.

---

## 🚨 EXECUTE THESE PHASES IN ORDER 🚨

```
READ SPEC ──→ READ PATTERNS ──→ CREATE PLAN ──→ APPROVE
     │              │                 │            │
     ▼              ▼                 ▼            ▼
   Show          Show              Write         STOP
  Summary      Workflow            Tasks        & WAIT
```

**DO NOT skip phases. DO NOT proceed without completing current phase.**

---

## PHASE 0: Read Specification

```
📖 Phase 0: Reading Specification
File: SPEC-[name].md
```

Extract:
- Feature name and type (operator feature? CLI tool? library? bug fix?)
- Components involved
- Implementation phases from spec
- Dependencies and ordering constraints

```
✅ Spec Read:
  Feature: [name]
  Type: [operator/CLI/library/other]
  Components: [list]
  Implementation phases: [from spec Section 8]
```

---

## PHASE 1: Read Implementation Patterns (Inline)

**DO NOT use Skill("fetch"). Read files directly.**

### Check Local Patterns

```
📚 Phase 1: Reading Implementation Workflow
```

Check:
```bash
ls ../enhancements/agentic/workflows/
```

### Read Files Directly

**If found locally**, use Read tool:
- `../enhancements/agentic/workflows/implementing-features.md`
- `../enhancements/agentic/practices/development/` (relevant files)

**If components specified**, also read:
- `../{component}/agentic/AGENTS.md` (component architecture)
- `../{component}/agentic/architecture/` (code structure)

**If NOT found**, fetch via gh CLI.

### Report

```
✅ Workflow Patterns Retrieved:
  ✅ implementing-features.md
  ✅ [relevant practice files]
  [✅ {component}/architecture - if applicable]

🎯 Ready to create plan
```

---

## PHASE 2: Create Implementation Plan

```
📝 Phase 2: Creating Plan

File: PLAN-[name].md
Approach: Break spec into ordered, verifiable tasks
```

### Read Spec Section 8 (Implementation Plan)

The spec already has high-level phases. Your job:
- Break each phase into concrete tasks
- Add dependencies and ordering
- Add verification steps
- Add checkpoints

### Task Principles

Each task should:
- **Be implementable in 1-2 days** (if bigger, split it)
- **Have clear acceptance criteria** (how do you know it's done?)
- **Include verification** (command to run, test to check)
- **Note dependencies** (what must be done first?)

### Example Task Structures (Adapt to Your Feature)

**For operator features**, tasks might include:
- Define CRD types → Controller reconciliation → Status conditions → Validation webhooks → Tests

**For CLI features**, tasks might include:
- Command structure → Flags and args → Output formatting → Integration with existing commands → Tests

**For library features**, tasks might include:
- Interface design → Core implementation → Error handling → Examples → Tests

**For bug fixes**, tasks might include:
- Root cause identification → Fix implementation → Regression tests → Backport considerations

**Don't force a template. Build tasks that make sense for YOUR feature.**

### Checkpoint Placement

Add checkpoints (validation gates) after:
- MVP implementation (can you demo core functionality?)
- Integration tests pass (does it work with other components?)
- Pre-ship validation (ready for PR?)

**Checkpoints are manual gates - user must approve before continuing.**

### Plan File Structure

```markdown
# Implementation Plan: [Feature Name]

**Spec**: SPEC-[name].md  
**Timeline**: [estimated weeks]  
**Components**: [list]

---

## Task Breakdown

### Task 1: [Name]
**Description**: [What to build]

**Acceptance Criteria**:
- [ ] [Criterion 1]
- [ ] [Criterion 2]

**Verification**:
```bash
# Command to verify task completion
```

**Estimated Time**: [days]

**Dependencies**: None

---

### Task 2: [Name]
...

### Checkpoint: [Name]
**Validation Gate**: [What to verify before proceeding]

- [ ] [Check 1]
- [ ] [Check 2]

**Approval Required**: Yes

---

### Task 3: [Name]
...

[Continue for all tasks...]

---

## Timeline

| Week | Tasks | Milestone |
|------|-------|-----------|
| 1 | Task 1-2 | [Milestone] |
| 2 | Task 3-4 | [Milestone] |
...

---

## Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| [Risk 1] | Low/Med/High | Low/Med/High | [How to mitigate] |

---

## Next Step

After approval: `/build task-1`
```

**Target length**: 200-400 lines (depends on complexity)

### Create File

Use Write tool: `PLAN-[name].md`

```
✅ Created: PLAN-[name].md
Tasks: [X]
Checkpoints: [Y]
Timeline: [Z] weeks
```

---

## PHASE 3: APPROVAL GATE

**🛑 STOP HERE. WAIT FOR USER APPROVAL. 🛑**

```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Plan Ready
════════════════════════════════════════════════════════════════

📄 PLAN-[name].md

Task breakdown:
  [List all tasks and checkpoints]

Timeline: [X] weeks

────────────────────────────────────────────────────────────────

Respond:
  ✅ "approve" / "looks good" → Start /build
  ✏️  "revise: <feedback>" → I'll update plan
  ❌ "abort" → I'll stop

════════════════════════════════════════════════════════════════

⏸️  Waiting for your decision...
```

**EXIT SKILL.**

---

## PHASE 4: Report (if approved)

```
✅ Implementation Plan Complete

📄 PLAN-[name].md
Tasks: [X]
Checkpoints: [Y]
Timeline: [Z] weeks

🎯 Next: /build task-1
```

**DONE.**

---

## Red Flags - You're Doing It Wrong

| Red Flag | Fix |
|----------|-----|
| >20 tasks | Too granular. Tasks should be 1-2 days each. |
| No acceptance criteria | Add "how you know it's done" for each task. |
| No verification steps | Add commands/tests to verify completion. |
| No checkpoints | Add validation gates at key milestones. |
| Using Skill("fetch") | Read patterns inline. |
| Tasks assume operator pattern | Adapt to actual feature type. |

---

## Common Rationalizations - Don't Make These

| Excuse | Reality |
|--------|---------|
| "Just use the template" | Templates don't fit all features. Read the spec. |
| "Skip checkpoints for speed" | Checkpoints catch issues early. Add them. |
| "One big task is fine" | Big tasks are hard to verify. Break them down. |

---

## Pre-Writing Checklist

- [ ] Spec read (especially Section 8)
- [ ] Feature type identified (operator/CLI/library/other)
- [ ] Workflow patterns read
- [ ] Component architecture read (if applicable)
- [ ] Tasks will be 1-2 days each
- [ ] Each task has acceptance criteria
- [ ] Checkpoints identified

**If unchecked, DO NOT write.**

---

## Pre-Approval Checklist

- [ ] All tasks have descriptions
- [ ] All tasks have acceptance criteria
- [ ] All tasks have verification steps
- [ ] Checkpoints included at key milestones
- [ ] Timeline estimated
- [ ] Dependencies noted
- [ ] Tasks match feature type (not forced into template)

**If unchecked, revise before approval gate.**

---

**Pattern**: OpenShift implementation planning  
**Version**: 2.0
