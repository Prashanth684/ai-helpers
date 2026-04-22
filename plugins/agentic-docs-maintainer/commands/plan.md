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
Breaks down an approved feature specification into ordered, implementable tasks. Creates tasks with clear acceptance criteria, dependencies, and verification steps.

**Approach**: Read the spec's implementation plan (Section 8), then break it into concrete tasks that match your feature type.

## Arguments

- `[spec-file]`: Path to spec document (optional, will search for SPEC-*.md)
- `--component <name>`: Component repository name (e.g., machine-config-operator)

## When to Use

✅ **Use for:**
- Approved specs ready for implementation
- Features needing ordered task breakdown
- Multi-week projects requiring checkpoints

❌ **Don't use for:**
- Spec not yet approved
- Simple one-file changes (just implement directly)
- Changes already clear from enhancement alone

## How It Works

### Phase 0: Read Specification

Reads SPEC-*.md to extract:
- Feature type (operator? CLI? library? bugfix?)
- Implementation phases from Section 8
- Components involved
- Dependencies

### Phase 1: Read Patterns

Reads implementation workflow patterns:
- `../enhancements/agentic/workflows/implementing-features.md`
- `../enhancements/agentic/practices/development/`
- `../{component}/agentic/` (if component specified)

### Phase 2: Create Plan

Breaks spec Section 8 into concrete tasks:
- Each task: 1-2 days of work
- Clear acceptance criteria
- Verification command
- Dependencies noted
- Checkpoints at milestones

### Phase 3: Approval Gate

Shows plan, waits for user approval before proceeding to `/build`.

## Output

Creates `PLAN-{name}.md` with:

**Task Structure** (adapts to feature):
- Description (what to build)
- Acceptance criteria (how you know it's done)
- Verification (command to check)
- Dependencies (what blocks this)
- Time estimate

**Checkpoints** (validation gates):
- Placed at key milestones
- Require manual approval before continuing

**Timeline Estimate**:
- Week-by-week breakdown
- Risk assessment

## Example Task Patterns

**For operator features**, tasks often include:
```
Task 1: Define API types
Task 2: Basic controller reconciliation
Checkpoint: MVP works
Task 3: Status conditions
Task 4: Validation (webhooks or controller)
Task 5: Integration tests
Checkpoint: Integration passes
Task 6: E2E tests
Task 7: Metrics and must-gather
Checkpoint: Ready for PR
```

**For CLI features**, tasks often include:
```
Task 1: Command structure and args
Task 2: Core functionality
Checkpoint: Basic command works
Task 3: Output formatting
Task 4: Integration with existing commands
Task 5: Unit + integration tests
Checkpoint: Tests pass
Task 6: Documentation
```

**For library features**, tasks often include:
```
Task 1: Interface design
Task 2: Core implementation
Checkpoint: Basic usage works
Task 3: Error handling
Task 4: Examples and tests
Checkpoint: Tests pass
Task 5: Documentation
```

**Your tasks should match YOUR feature - these are examples, not templates.**

## Examples

### Example 1: From Spec File

```bash
/agentic-docs-maintainer:plan SPEC-webhook-validation.md
```

**What happens:**
```
📖 Reading spec...
  ✅ Feature: Webhook validation
  ✅ Type: Operator feature
  ✅ Implementation phases: 4

📚 Reading patterns...
  ✅ implementing-features.md
  ✅ api-evolution.md

📝 Creating plan...
  ✅ PLAN-webhook-validation.md

Tasks: 7
Checkpoints: 3
Timeline: 4 weeks

⏸️  Review gate: approve to proceed
```

### Example 2: Component-Specific

```bash
/agentic-docs-maintainer:plan --component machine-config-operator
```

**What happens:**
```
📖 Reading spec...
  ✅ Found: SPEC-node-drain-timeout.md

📚 Reading patterns...
  ✅ implementing-features.md
  ✅ machine-config-operator/agentic/AGENTS.md
  ✅ machine-config-operator/agentic/architecture/

📝 Creating plan...
  ✅ PLAN-node-drain-timeout.md
  ✅ Tasks tailored to MCO architecture

Tasks: 6
Checkpoints: 2
Timeline: 3 weeks

⏸️  Review gate: approve to proceed
```

## Task Best Practices

**Good tasks:**
- ✅ 1-2 days of work (small, focused)
- ✅ Clear acceptance criteria ("tests pass", "API merged")
- ✅ Verifiable (command to check completion)
- ✅ Dependencies noted ("blocked by task 1")

**Bad tasks:**
- ❌ >1 week of work (too big, split it)
- ❌ Vague criteria ("make it better")
- ❌ No verification (how do you know it's done?)
- ❌ Missing dependencies (what must be done first?)

## Checkpoint Best Practices

Place checkpoints after:
- ✅ MVP implementation (core functionality works)
- ✅ Integration tests pass (works with other components)
- ✅ Pre-ship validation (all tests pass, ready for PR)

**Don't:**
- ❌ Skip checkpoints (they catch issues early)
- ❌ Add too many checkpoints (slows progress)
- ❌ Put checkpoints in wrong places (should be natural milestones)

## Integration with Other Skills

**Full workflow:**
```bash
# 1. SPEC
/agentic-docs-maintainer:spec enhancement.md
→ Approve spec

# 2. PLAN (this command)
/agentic-docs-maintainer:plan
→ Approve plan

# 3. BUILD
/agentic-docs-maintainer:build task-1
/agentic-docs-maintainer:build task-2
...

# 4. TEST
/agentic-docs-maintainer:test

# 5. REVIEW
/agentic-docs-maintainer:review

# 6. SHIP
/agentic-docs-maintainer:ship
```

## Validation

Before `/build`:
- ✅ All tasks have acceptance criteria
- ✅ Dependencies ordered correctly
- ✅ Checkpoints at key milestones
- ✅ **Human approves plan** ← GATE

## Implementation

Execution handled by skill at: `skills/plan/SKILL.md`

**Key phases:**
1. Read spec (extract implementation phases)
2. Read patterns (workflow and component architecture)
3. Create tasks (break phases into verifiable tasks)
4. Approval gate (wait for human review)

## See Also

- `/agentic-docs-maintainer:spec` - Create specification (previous step)
- `/agentic-docs-maintainer:build` - Implement tasks (next step)
- `/agentic-docs-maintainer:test` - Verify implementation

---

**Pattern**: OpenShift implementation planning  
**Version**: 2.0
