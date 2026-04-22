# OpenShift Lifecycle Skills - Complete Guide

**Full-cycle feature development from specification through deployment with human-in-the-loop approval gates**

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [The Seven Skills](#the-seven-skills)
4. [Approval Gates](#approval-gates)
5. [Usage Guide](#usage-guide)
6. [Complete Workflow Example](#complete-workflow-example)
7. [Comparison to GitHub spec-kit](#comparison-to-github-spec-kit)
8. [Implementation Notes](#implementation-notes)

---

## Overview

The OpenShift Lifecycle Skills provide a complete workflow for developing OpenShift features, from initial specification through safe deployment. Built on Claude Code, these skills implement a pattern-driven approach with human approval gates at every critical phase.

### What Are These Skills?

Seven interconnected skills that guide you through the complete feature development lifecycle:

```
/fetch → /spec → /plan → /build → /test → /review → /ship
```

Each skill:
- **Fetches OpenShift patterns** before executing (Tier 1 ecosystem + Tier 2 component docs)
- **Pauses for human approval** at critical gates (approve/revise/abort)
- **Supports iterative refinement** with feedback loops
- **Tracks state** across invocations for resume capability

### Key Innovations

1. **Pattern-Driven**: Automatically fetches relevant patterns from agentic documentation
2. **Human-in-the-Loop**: Approval gates prevent runaway automation
3. **Iterative Refinement**: Revise and regenerate based on feedback
4. **Two-Tier Architecture**: Tier 1 (ecosystem hub) + Tier 2 (component-specific)
5. **Natural Language**: Approve with "looks good", revise with "fix X", abort with "cancel"

---

## Architecture

### Two-Tier Documentation System

**Tier 1: Ecosystem Hub** (`openshift/enhancements/agentic/`)
- Platform-wide patterns (operator patterns, controller-runtime, testing pyramid)
- Engineering practices (security, reliability, development workflows)
- Cross-repo ADRs (architectural decisions affecting multiple components)
- Kubernetes/OpenShift fundamentals

**Tier 2: Component Repositories** (`openshift/{component}/agentic/`)
- Component-specific domain concepts
- Component architecture and internal structure
- Component-specific ADRs
- Work tracking (exec-plans for active features)
- References Tier 1 for generic patterns

**Benefits:**
- 58% smaller docs (6,000 → 2,500 lines typical)
- 97% less duplication (144,000 → 4,000 lines ecosystem-wide)
- 1 Tier 1 PR updates all repos (vs 60+ component PRs)

### Data Flow Between Skills

```
┌──────────────────────────────────────────────────────────────┐
│                        User Input                             │
│              "Build multi-arch support for CVO"               │
└───────────────────────────┬──────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ /fetch - Pattern Retrieval                                   │
│ ├─ Input: Feature description                                │
│ ├─ Output: Fetched patterns (Tier 1 + Tier 2)               │
│ └─ Artifacts: None (in-memory)                              │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ /spec - Specification Generation                             │
│ ├─ Input: Feature description + fetched patterns            │
│ ├─ Output: SPEC-{feature}.md (12 sections)                  │
│ ├─ Approval Gate: Review spec before planning               │
│ └─ Artifacts: SPEC-{feature}.md, exec-plan                  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ /plan - Implementation Planning                              │
│ ├─ Input: SPEC-{feature}.md                                 │
│ ├─ Output: PLAN-{feature}.md (9 tasks, 4 checkpoints)       │
│ ├─ Approval Gate: Review plan before implementation         │
│ └─ Artifacts: PLAN-{feature}.md                             │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ /build - Incremental Implementation                          │
│ ├─ Input: PLAN-{feature}.md task-by-task                    │
│ ├─ Output: Code + tests + git commits                       │
│ ├─ Approval Gates: After each task (checkpoints required)   │
│ └─ Artifacts: Go files, test files, commits                 │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ /test - Comprehensive Testing                                │
│ ├─ Input: Actual codebase (all *_test.go files)             │
│ ├─ Output: Coverage report, pyramid analysis                │
│ ├─ Approval Gate: Review test results                       │
│ └─ Artifacts: Coverage reports, gap analysis                │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ /review - Code Review                                        │
│ ├─ Input: Actual codebase (static analysis)                 │
│ ├─ Output: Review report (5 axes, score /100)               │
│ ├─ Approval Gate: Review findings before shipping           │
│ └─ Artifacts: Review report, action items                   │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│ /ship - Safe Deployment                                      │
│ ├─ Input: Codebase + git state + CI status                  │
│ ├─ Output: GitHub PR + rollback plan                        │
│ ├─ Approval Gate 1: Before creating PR                      │
│ ├─ Approval Gate 2: Before merging PR                       │
│ └─ Artifacts: PR, rollback plan, deployment report          │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            ▼
                    ✅ Feature Deployed
```

**Document-Based Skills** (generate artifacts):
- /spec - Creates specification documents
- /plan - Creates implementation plans
- /build - Creates code and tests

**Codebase Analysis Skills** (analyze existing code):
- /test - Analyzes test coverage
- /review - Reviews code quality
- /ship - Validates deployment readiness

---

## The Seven Skills

### 1. /fetch - Pattern Retrieval

**Purpose**: Retrieve relevant OpenShift patterns before executing any skill

**What it does**:
- Searches Tier 1 (ecosystem hub) and Tier 2 (component docs)
- Navigates KNOWLEDGE_GRAPH.md to find relevant patterns
- Returns pattern content for use in other skills

**Usage**:
```bash
# Fetch design philosophy
/fetch "OpenShift design philosophy"

# Fetch specific pattern
/fetch "controller-runtime reconciliation pattern"

# Fetch from specific component
/fetch "MachineConfig architecture" --tier2 openshift/machine-config-operator
```

**Output**: Pattern content (in-memory, used by other skills)

**Natural Language**:
- "Find patterns for webhook validation"
- "Get controller-runtime examples"

---

### 2. /spec - Specification Generation

**Purpose**: Create comprehensive feature specification following OpenShift enhancement template

**What it does**:
- Fetches relevant patterns (DESIGN_PHILOSOPHY + domain patterns + component architecture)
- Generates 12-section specification document
- Creates exec-plan for component tracking
- **Approval Gate**: Pauses for human review before finalizing

**Usage**:
```bash
# Simple feature
/spec "Add webhook validation for MachineConfigPool"

# Component-specific
/spec "Node drain timeout" --component machine-config-operator

# Multi-component
/spec "Network isolation during updates" \
  --component machine-config-operator,cluster-network-operator
```

**Arguments**:
- `--component <name>` - Component name(s), comma-separated
- `--feedback "text"` - Revision feedback
- `--auto-approve` - Skip approval gate
- `--max-retries N` - Max attempts (default: 3)

**Output**: 
- `SPEC-{feature}.md` (12 sections)
- `{component}/agentic/exec-plans/active/{feature}.md`

**Approval Gate**:
```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Generated
════════════════════════════════════════════════════════════════

📄 SPEC-feature.md created

Please review and respond:
  • "approve" → I'll create exec-plan
  • "revise: <feedback>" → I'll regenerate
  • "abort" → I'll stop
════════════════════════════════════════════════════════════════
```

---

### 3. /plan - Implementation Planning

**Purpose**: Break down approved spec into ordered, implementable tasks

**What it does**:
- Fetches implementation workflow patterns
- Creates 9 standard tasks (API → Vendor → MVP → Status → Validation → Integration → E2E → Observability → Docs)
- Defines 4 checkpoints for validation gates
- Estimates timeline (typically 5 weeks)
- **Approval Gate**: Pauses for human review before implementation

**Usage**:
```bash
# Use spec from current directory
/plan

# Specify spec file
/plan SPEC-webhook-validation.md

# With component context
/plan --component machine-config-operator
```

**Arguments**:
- `[spec-file]` - Path to SPEC-*.md (optional, auto-detects)
- `--component <name>` - Component name
- `--feedback "text"` - Revision feedback
- `--auto-approve` - Skip approval gate
- `--max-retries N` - Max attempts (default: 3)

**Output**:
- `PLAN-{feature}.md` (9 tasks, 4 checkpoints, timeline)

**Approval Gate**:
```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Implementation Plan Generated
════════════════════════════════════════════════════════════════

📄 PLAN-feature.md created

Tasks: 9 defined
Timeline: 5 weeks
Checkpoints: 4

Please review and respond:
  • "approve" → I'll finalize
  • "revise: split task 3" → I'll adjust plan
  • "abort" → I'll stop
════════════════════════════════════════════════════════════════
```

---

### 4. /build - Incremental Implementation

**Purpose**: Implement tasks from plan incrementally, with tests and verification

**What it does**:
- Fetches task-specific patterns (controller-runtime, webhooks, testing, etc.)
- Implements one task at a time
- Writes tests (TDD approach)
- Verifies tests pass
- Creates atomic git commits
- **Approval Gate**: Pauses after each task (checkpoints ALWAYS require approval)

**Usage**:
```bash
# Implement task 1
/build task-1

# Implement task 3 with explicit plan
/build task-3 --plan-file PLAN-webhook-validation.md
```

**Arguments**:
- `<task-number>` - Which task (e.g., task-1, task-3)
- `--plan-file <path>` - Path to PLAN-*.md
- `--feedback "text"` - Revision feedback
- `--auto-approve` - Skip approval (except checkpoints)
- `--max-retries N` - Max attempts (default: 3)

**Output**:
- Go source files (`pkg/controller/*.go`)
- Test files (`pkg/controller/*_test.go`)
- Git commits (atomic, one per task)

**Approval Gate**:
```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Task 3 Complete (CHECKPOINT)
════════════════════════════════════════════════════════════════

📄 Task: Basic Reconciliation (MVP)
✅ Implementation complete
✅ Tests passing
✅ Committed: abc123d

Files changed:
  pkg/controller/myresource/controller.go
  pkg/controller/myresource/controller_test.go

Please review and respond:
  • "approve" → Proceed to task 4
  • "revise: add error handling" → Fix and re-implement
  • "abort" → Stop
════════════════════════════════════════════════════════════════

🚧 CHECKPOINT: Approval REQUIRED before proceeding
```

**Special**: Checkpoints (Tasks 3, 5, 7, 9) ignore `--auto-approve` and ALWAYS require human approval.

---

### 5. /test - Comprehensive Testing

**Purpose**: Verify testing pyramid compliance (60% unit / 30% integration / 10% E2E)

**What it does**:
- Runs all test suites (unit, integration, E2E)
- Analyzes coverage breakdown
- Calculates pyramid ratio
- Identifies missing tests
- **Approval Gate**: Pauses for human review before /review

**Usage**:
```bash
# Run all tests and analyze
/test

# Generate detailed coverage report
/test --coverage-report

# Identify and create missing tests
/test --fix-missing
```

**Arguments**:
- `--coverage-report` - Generate detailed report
- `--fix-missing` - Create missing tests
- `--feedback "text"` - Revision feedback
- `--auto-approve` - Skip approval gate
- `--max-retries N` - Max attempts (default: 3)

**Output**:
- Coverage reports (`coverage-*.out`)
- Pyramid analysis
- Missing test recommendations

**Approval Gate**:
```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Test Results
════════════════════════════════════════════════════════════════

📊 Test Coverage:
  • Unit: 62% (target: 60%) ✅
  • Integration: 28% (target: 30%) ❌
  • E2E: 12% (target: 10%) ✅

Pyramid: 58% / 29% / 13% (close to 60/30/10)

Please review and respond:
  • "approve" → Proceed to /review
  • "revise: add integration test for upgrade" → Fix gaps
  • "abort" → Stop
════════════════════════════════════════════════════════════════
```

---

### 6. /review - Code Review

**Purpose**: Review implementation for OpenShift compliance (5 axes)

**What it does**:
- Fetches review criteria (operator patterns, practices, component standards)
- Reviews code on five axes:
  1. **Correctness** (/20) - Logic, error handling, edge cases
  2. **Maintainability** (/20) - Code clarity, documentation, structure
  3. **Testing** (/20) - Coverage, test quality, assertions
  4. **Security** (/20) - RBAC, input validation, secret handling
  5. **Operability** (/20) - Metrics, logging, observability
- Generates score /100 and action items
- **Approval Gate**: Pauses for human review before /ship

**Usage**:
```bash
# Review current implementation
/review

# Component-specific review
/review --component machine-config-operator

# Auto-fix simple issues
/review --fix-auto
```

**Arguments**:
- `--component <name>` - Component name
- `--fix-auto` - Auto-fix linter issues
- `--feedback "text"` - Revision feedback
- `--auto-approve` - Skip approval gate
- `--max-retries N` - Max attempts (default: 3)

**Output**:
- Review report (5-axis scores)
- Action items (Must Fix / Should Fix / Nice to Have)
- Compliance checklist

**Approval Gate**:
```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Code Review Complete
════════════════════════════════════════════════════════════════

📊 Scores:
  • Correctness: 18/20 ✅
  • Maintainability: 16/20 ✅
  • Testing: 19/20 ✅
  • Security: 12/20 ⚠️
  • Operability: 15/20 ✅

Overall: 80/100 ✅ PASS

Action Items:
  • Must Fix: 2 security issues
  • Should Fix: 3 code quality issues

Please review and respond:
  • "approve" → Proceed to /ship
  • "revise: fix security issues" → Address findings
  • "abort" → Stop
════════════════════════════════════════════════════════════════
```

---

### 7. /ship - Safe Deployment

**Purpose**: Deploy feature safely with upgrade validation and rollback plan

**What it does**:
- Fetches shipping checklist and upgrade strategies
- Validates 32 pre-ship criteria
- Tests upgrade path (N → N+1)
- Creates GitHub PR
- Monitors CI status
- Documents rollback plan
- **Two Approval Gates**:
  1. Before creating PR
  2. Before merging PR

**Usage**:
```bash
# Full shipping workflow
/ship

# Dry-run (validate without creating PR)
/ship --dry-run

# Skip upgrade test (not recommended)
/ship --skip-upgrade-test
```

**Arguments**:
- `--dry-run` - Validate readiness only
- `--skip-upgrade-test` - Skip upgrade validation
- `--feedback "text"` - Revision feedback
- `--auto-approve` - Skip approval gates (NOT RECOMMENDED)
- `--max-retries N` - Max attempts (default: 3)

**Output**:
- GitHub PR with comprehensive description
- Rollback plan document
- CI monitoring status

**Approval Gate 1** (Pre-PR):
```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Pre-Ship Validation
════════════════════════════════════════════════════════════════

📋 Pre-Ship: 32/32 criteria met ✅
✅ All tests passing
✅ Review score: 85/100
✅ Upgrade test passes
✅ No uncommitted changes

Please review and respond:
  • "approve" → Create PR
  • "revise: upgrade test failing" → Fix issues
  • "abort" → Stop
════════════════════════════════════════════════════════════════
```

**Approval Gate 2** (Pre-Merge):
```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Pre-Merge Validation
════════════════════════════════════════════════════════════════

📄 PR: https://github.com/openshift/cvo/pull/123
✅ CI: 8/8 checks passing
✅ Reviews: 2 approvals

Please review and respond:
  • "approve" or "merge" → Deploy
  • "wait" → Hold for review
  • "revise: E2E flake" → Fix and update
  • "abort" → Close PR
════════════════════════════════════════════════════════════════

⚠️  FINAL GATE: This will merge and deploy
````

---

## Approval Gates

### What Are Approval Gates?

Approval gates are pause points where skills exit and wait for human decision before proceeding. Inspired by GitHub's spec-kit but adapted for Claude Code's conversational model.

### How They Work

**Two-Phase Pattern**:
1. **Generate & Pause**: Skill generates output, shows gate, exits
2. **User Responds**: User responds in natural language
3. **Detect Intent**: Claude detects approve/revise/abort
4. **Resume**: Skill re-invokes with appropriate action

### Natural Language Detection

**Approval Phrases**:
- "approve", "approved", "LGTM", "looks good"
- "proceed", "continue", "yes"
- Skill-specific: "create PR" (/ship), "merge" (/ship), "next task" (/build)

**Revision Phrases**:
- "revise: <feedback>" - Primary pattern
- "fix <feedback>"
- "change <feedback>"
- "add <feedback>"
- "update <feedback>"

**Abort Phrases**:
- "abort", "cancel", "stop"
- "nevermind", "no"

**Wait Phrases** (/ship only):
- "wait", "hold", "not yet"

### State Tracking

Each skill tracks attempts and feedback:

**File**: `.work/{skill}-state.json`

**Example** (`spec-state.json`):
```json
{
  "feature": "multi-arch support",
  "component": "cluster-version-operator",
  "attempt": 2,
  "max_retries": 3,
  "spec_file": "SPEC-multi-arch-support.md",
  "last_feedback": "add version skew handling"
}
```

### Max Retries

Default: 3 attempts per skill  
Configurable: `--max-retries N`

When exceeded:
```
⚠️  Maximum Retries Reached (3/3)

The specification has been revised 3 times but may not meet requirements.
You can:
  1. Manually edit SPEC-feature.md
  2. Start fresh with new approach
  3. Use current spec as-is (review carefully)
```

### Auto-Approve Mode

**Purpose**: Skip gates for automation (CI/CD)  
**Usage**: `--auto-approve` flag

**Recommendations**:
- ✅ Safe for: /spec, /plan (documentation generation)
- ⚠️  Caution for: /build, /test, /review (implementation)
- ❌ NOT recommended for: /ship (production deployment)

**Special Case**: /build checkpoints (Tasks 3, 5, 7, 9) ALWAYS require approval even with `--auto-approve`.

---

## Usage Guide

### Invocation Methods

**1. Explicit Command**:
```bash
/spec --component cluster-version-operator --feature "multi-arch support"
```

**2. Natural Language**:
```
User: Create a spec for adding webhook validation to MachineConfigPool
Claude: [Invokes /spec automatically]
```

**3. Short Form**:
```bash
/spec "multi-arch support"  # Minimal arguments
```

### Common Workflows

#### Workflow 1: New Feature (Full Lifecycle)

```bash
# 1. Create specification
/spec --component cluster-version-operator --feature "multi-arch support"
→ GATE: approve

# 2. Create implementation plan
/plan SPEC-multi-arch-support.md
→ GATE: approve

# 3. Implement tasks
/build task-1  → GATE: approve
/build task-2  → GATE: approve
/build task-3  → GATE (checkpoint): approve
... continue through task-9

# 4. Verify tests
/test
→ GATE: approve

# 5. Code review
/review
→ GATE: approve

# 6. Ship
/ship
→ GATE 1: approve (create PR)
→ GATE 2: merge (deploy)

✅ Feature complete!
```

#### Workflow 2: Specification Only

```bash
# Generate spec without implementation
/spec "feature description" --component myoperator
→ GATE: revise: add more detail
→ GATE: approve

# Stop here, use spec for enhancement PR
```

#### Workflow 3: Bug Fix (Skip Spec/Plan)

```bash
# For simple fixes, skip spec/plan and go directly to build
[Manually fix code]

# Verify tests
/test
→ GATE: approve

# Review
/review  
→ GATE: approve

# Ship
/ship
→ GATE 1: approve
→ GATE 2: merge
```

#### Workflow 4: Automated CI Integration

```bash
# Run with auto-approve for CI pipeline
/spec --auto-approve --component myoperator --feature "feature"
/plan --auto-approve SPEC-feature.md
/build task-1 --auto-approve
# Note: Checkpoints still require approval
/test --auto-approve
/review --auto-approve
# Do NOT use --auto-approve for /ship in production
```

### Revision Examples

**Good Feedback** (Specific, Actionable):
- ✅ "revise: add version skew handling between N and N+1"
- ✅ "revise: the security section doesn't address RBAC for ClusterVersion CR"
- ✅ "revise: split task 3 - watcher setup is independent of reconciliation"

**Poor Feedback** (Vague):
- ❌ "revise: make it better"
- ❌ "revise: too complex"
- ❌ "revise: I don't like it"

---

## Complete Workflow Example

### Scenario: Implement Multi-Arch Support in CVO

**User Request**:
> "I need to add multi-architecture support to the cluster-version-operator. 
> The CVO should detect the payload architecture and set it in ClusterVersion status."

#### Step 1: Specification (with Revision)

```
User: /spec --component cluster-version-operator \
           --feature "detect and report payload architecture in ClusterVersion status"

Agent:
=== Phase 0: Fetching Patterns ===
📚 Fetching OpenShift design philosophy...
📡 Fetching CVO architecture...

Patterns retrieved:
  ✅ DESIGN_PHILOSOPHY.md
  ✅ controller-runtime.md
  ✅ cluster-version-operator/agentic/AGENTS.md

=== Phase 2: Write Specification ===
[Generates SPEC-multi-arch-support.md]

════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Generated (Attempt 1/3)
════════════════════════════════════════════════════════════════

📄 SPEC-multi-arch-support.md created (1,650 lines)

Key sections:
## 1. Objective
## 2. Technical Design
## 3. Testing Strategy
...

Please review and respond:
  • "approve" → I'll create exec-plan
  • "revise: <feedback>" → I'll regenerate
  • "abort" → I'll stop
════════════════════════════════════════════════════════════════

User: The technical design doesn't explain how other components 
      (registry-operator, apiserver) will consume this field. Add a 
      data flow diagram showing CVO → registry → apiserver.

Agent:
=== Revision (Attempt 2/3) ===

Applying feedback...

Updated sections:
  ✓ Technical Design > Component Interaction (lines 250-380)
  ✓ Data flow diagram added
  ✓ Code examples from all 3 components

════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Revised (Attempt 2/3)
════════════════════════════════════════════════════════════════

Changes made:
  ✓ Component Interaction subsection (130 lines)
  ✓ Data flow: CVO → registry-operator → apiserver
  ✓ Code examples showing interaction

Please review and respond:
  • "approve" → I'll create exec-plan
  • "revise: <feedback>" → I'll regenerate (1 attempt left)
  • "abort" → I'll stop
════════════════════════════════════════════════════════════════

User: looks good

Agent: ✓ Specification approved

📄 Spec: SPEC-multi-arch-support.md
📋 Exec-Plan: cluster-version-operator/agentic/exec-plans/active/multi-arch-support.md

🎯 Next: /plan SPEC-multi-arch-support.md
```

#### Step 2: Planning

```
User: /plan SPEC-multi-arch-support.md

Agent:
=== Phase 0: Fetching Implementation Patterns ===
📚 Fetching implementation workflow...
📡 Fetching CVO code structure...

=== Phase 2: Create Vertical Slices ===
[Creates 9 tasks]

════════════════════════════════════════════════════════════════
  REVIEW GATE: Implementation Plan Generated (Attempt 1/3)
════════════════════════════════════════════════════════════════

📄 PLAN-multi-arch-support.md created

Tasks:
  1. API Foundation (1 week)
  2. Vendor Dependencies (1 day)
  3. Basic Reconciliation - MVP (3 days) [CHECKPOINT 1]
  4. Full Status Reporting (2 days)
  5. Validation & Safety (3 days) [CHECKPOINT 2]
  6. Integration Testing (2 days)
  7. E2E Testing (3 days) [CHECKPOINT 3]
  8. Observability (2 days)
  9. Documentation (2 days) [CHECKPOINT 4]

Timeline: 5 weeks

Please review and respond:
  • "approve" → I'll finalize
  • "revise: <feedback>" → I'll adjust plan
  • "abort" → I'll stop
════════════════════════════════════════════════════════════════

User: approve

Agent: ✓ Plan approved

🎯 Next: /build task-1
```

#### Step 3: Implementation (Task 3 - Checkpoint Example)

```
User: /build task-3

Agent:
=== Phase 0: Fetch Pattern ===
Pattern: controller-runtime reconciliation

=== Phase 1: Implement ===
[Creates pkg/cvo/architecture.go]
[Implements inferPayloadArchitecture()]

=== Phase 2: Write Tests ===
[Creates pkg/cvo/architecture_test.go]

=== Phase 3: Verify ===
✅ make test-unit: PASS
✅ gofmt: PASS
✅ go vet: PASS

=== Phase 5: Commit ===
git commit -m "CVO: Implement payload architecture detection

Adds inferPayloadArchitecture() method that reads release metadata
and sets ClusterVersion.status.desired.architecture field.

Follows: platform/operator-patterns/controller-runtime.md
Completes: Task 3 (MVP) from PLAN-multi-arch-support.md"

════════════════════════════════════════════════════════════════
  REVIEW GATE: Task 3 Complete (CHECKPOINT 1)
════════════════════════════════════════════════════════════════

📄 Task: Basic Reconciliation (MVP)
✅ Implementation complete
✅ Tests passing
✅ Committed: a1b2c3d

Files changed:
  pkg/cvo/architecture.go (120 lines)
  pkg/cvo/architecture_test.go (85 lines)

Test results:
  • TestInferPayloadArchitecture_Multi: PASS
  • TestInferPayloadArchitecture_Single: PASS
  • TestInferPayloadArchitecture_None: PASS

Please review and respond:
  • "approve" → Proceed to task 4
  • "revise: <feedback>" → Fix and re-implement
  • "abort" → Stop
════════════════════════════════════════════════════════════════

🚧 CHECKPOINT: Approval REQUIRED before proceeding

User: The code doesn't handle the case where release metadata is nil.
      Add error handling and a test for that scenario.

Agent:
=== Revision (Attempt 2/3) ===

Applying feedback...

Changes made:
  ✓ Added nil check in inferPayloadArchitecture() (line 45)
  ✓ Returns empty string instead of panic
  ✓ Added TestInferPayloadArchitecture_NilMetadata

Test results:
  • All tests: PASS (4/4)

Amended commit: a1b2c3d

════════════════════════════════════════════════════════════════
  REVIEW GATE: Task 3 Complete (CHECKPOINT 1) - Revised
════════════════════════════════════════════════════════════════

Changes applied:
  ✓ Nil metadata handling (lines 45-48)
  ✓ Test added: TestInferPayloadArchitecture_NilMetadata

Please review and respond:
  • "approve" → Proceed to task 4
  • "revise: <feedback>" → Fix again (1 attempt left)
  • "abort" → Stop
════════════════════════════════════════════════════════════════

User: approve

Agent: ✓ Checkpoint 1 passed

🎯 Next: /build task-4
```

#### Step 4: Testing

```
User: /test

Agent:
=== Phase 1: Analyze Coverage ===

Running tests...
  • Unit: 125 tests, 68% coverage
  • Integration: 45 tests, 32% coverage
  • E2E: 12 tests, 10% coverage

Pyramid ratio: 61% / 33% / 6%

════════════════════════════════════════════════════════════════
  REVIEW GATE: Test Results (Attempt 1/3)
════════════════════════════════════════════════════════════════

📊 Coverage:
  • Unit: 68% (target: 60%) ✅
  • Integration: 32% (target: 30%) ✅
  • E2E: 10% (target: 10%) ✅

Pyramid: 61% / 33% / 6% ⚠️ (E2E slightly low)

All tests passing: YES ✅

Please review and respond:
  • "approve" → Proceed to /review
  • "revise: <feedback>" → Address issues
  • "abort" → Stop
════════════════════════════════════════════════════════════════

User: approve (E2E coverage is acceptable)

Agent: ✓ Tests approved

🎯 Next: /review
```

#### Step 5: Review

```
User: /review --component cluster-version-operator

Agent:
=== Phase 0: Fetch Review Criteria ===
📚 Fetching operator patterns...
📚 Fetching code review standards...
📡 Fetching CVO-specific patterns...

=== Phase 1-5: Five-Axis Review ===

Review complete.

════════════════════════════════════════════════════════════════
  REVIEW GATE: Code Review Complete (Attempt 1/3)
════════════════════════════════════════════════════════════════

📊 Scores:
  • Correctness: 19/20 ✅
  • Maintainability: 18/20 ✅
  • Testing: 20/20 ✅
  • Security: 16/20 ✅
  • Operability: 12/20 ⚠️

Overall: 85/100 ✅ PASS

Action Items:
  • Must Fix: 0
  • Should Fix: 2
    - Add Prometheus metrics for architecture detection
    - Add must-gather support

Please review and respond:
  • "approve" → Proceed to /ship
  • "revise: <feedback>" → Address findings
  • "abort" → Stop
════════════════════════════════════════════════════════════════

User: revise: add the Prometheus metrics (must-gather can wait)

Agent:
=== Revision (Attempt 2/3) ===

Addressing feedback...

Changes:
  ✓ Added metrics: cvo_payload_architecture_total
  ✓ Instrumented inferPayloadArchitecture()
  ✓ Updated observability score

Committed: b2c3d4e "CVO: Add metrics for architecture detection"

Re-reviewing...

════════════════════════════════════════════════════════════════
  REVIEW GATE: Code Review Complete (Attempt 2/3)
════════════════════════════════════════════════════════════════

📊 Scores:
  • Correctness: 19/20 ✅
  • Maintainability: 18/20 ✅
  • Testing: 20/20 ✅
  • Security: 16/20 ✅
  • Operability: 18/20 ✅

Overall: 91/100 ✅ PASS

Action Items:
  • Must Fix: 0
  • Should Fix: 1 (must-gather)

Please review and respond:
  • "approve" → Proceed to /ship
  • "revise: <feedback>" → Address findings
  • "abort" → Stop
════════════════════════════════════════════════════════════════

User: approve

Agent: ✓ Review approved (score: 91/100)

🎯 Next: /ship
```

#### Step 6: Shipping

```
User: /ship

Agent:
=== Phase 0-4: Pre-Ship Validation ===

Validating 32 criteria...
  ✅ All tests passing
  ✅ Review score >= 80 (91)
  ✅ No uncommitted changes
  ✅ Branch up to date
  ... (28 more checks)

Running upgrade test (N → N+1)...
  ✅ Upgrade test passed

Creating rollback plan...
  ✅ ROLLBACK-multi-arch-support.md created

════════════════════════════════════════════════════════════════
  REVIEW GATE 1: Pre-Ship Validation (Attempt 1/3)
════════════════════════════════════════════════════════════════

📋 Pre-Ship: 32/32 criteria met ✅

Critical Items:
  ✅ All tests passing
  ✅ Review score: 91/100
  ✅ Upgrade test passes
  ✅ No uncommitted changes
  ✅ Branch up to date with main

Rollback Plan: ✅ Ready

Please review and respond:
  • "approve" → Create GitHub PR
  • "revise: <feedback>" → Fix issues
  • "abort" → Stop
════════════════════════════════════════════════════════════════

User: approve

Agent:
Creating GitHub PR...

PR created: https://github.com/openshift/cluster-version-operator/pull/1234

Title: Add multi-architecture support to ClusterVersion status

Description:
## Summary
Implements multi-architecture detection by reading release metadata
and setting ClusterVersion.status.desired.architecture field.

## Changes
- Added `inferPayloadArchitecture()` method
- Added metrics for architecture detection
- Full test coverage (unit + integration + E2E)

## Test Plan
- [x] Unit tests pass (68% coverage)
- [x] Integration tests pass (32% coverage)
- [x] E2E tests pass (10% coverage)
- [x] Upgrade test N → N+1 passes

## Review
- Code review score: 91/100
- All 5 axes reviewed

🤖 Generated with Claude Code OpenShift Skills

Waiting for CI...
  ⏳ ci/prow/unit: running
  ⏳ ci/prow/integration: running
  ⏳ ci/prow/e2e: running
  ⏳ ci/prow/upgrade: running

[5 minutes later]

CI Results:
  ✅ ci/prow/unit: passed
  ✅ ci/prow/integration: passed
  ✅ ci/prow/e2e: passed
  ✅ ci/prow/upgrade: passed

════════════════════════════════════════════════════════════════
  REVIEW GATE 2: Pre-Merge Validation (Attempt 1/3)
════════════════════════════════════════════════════════════════

📄 PR: https://github.com/openshift/cluster-version-operator/pull/1234
✅ CI: 8/8 checks passing

Critical Checks:
  ✅ Unit tests
  ✅ Integration tests
  ✅ E2E tests
  ✅ Upgrade test
  ✅ Linters
  ✅ Security scan
  ✅ Verify codegen
  ✅ Verify vendor

PR Approval:
  • Reviewers: 2 approvals (alice, bob)
  • Status: APPROVED

Please review and respond:
  • "approve" or "merge" → Deploy to production
  • "wait" → Hold for additional review
  • "revise: <feedback>" → Update PR
  • "abort" → Close PR
════════════════════════════════════════════════════════════════

⚠️  FINAL GATE: This will merge and deploy

User: merge

Agent:
Merging PR #1234...

✅ PR merged: commit c3d4e5f

Deploying...
  ✅ CVO updated in release payload
  ✅ New build: 4.17.0-ci.123
  ✅ Operator reports Available=True

🎉 Ship complete!

Feature deployed successfully.
Rollback plan: ROLLBACK-multi-arch-support.md
```

**Total time**: ~6 hours of iterative development with approval gates at each phase.

---

## Comparison to GitHub spec-kit

| Feature | spec-kit | OpenShift Skills |
|---------|----------|------------------|
| **Approval Gates** | ✅ Built-in | ✅ All 6 skills + /fetch |
| **Revision Loop** | ✅ do-while | ✅ --feedback param |
| **Max Retries** | ✅ max_iterations | ✅ --max-retries |
| **State Persistence** | ✅ `.specify/workflows/runs/` | ✅ `.work/{skill}-state.json` |
| **Resume Capability** | ✅ `specify workflow resume` | ✅ Re-invoke with state |
| **Natural Language** | ❌ Structured YAML | ✅ Conversational |
| **Interactive Input** | ✅ True stdin `read` | ⚠️ Two-phase (pause/resume) |
| **Control Flow** | ✅ if/switch/while/fan-out | ❌ Sequential only |
| **OpenShift Patterns** | ❌ Generic | ✅ Tier 1 + Tier 2 embedded |
| **Multi-Skill** | ✅ Workflow YAML | ✅ 7 skills |
| **Implementation** | Python, separate CLI | Go + Python, Claude Code native |

### Advantages of OpenShift Skills

1. **Native Claude Code**: No separate CLI, works within tool ecosystem
2. **Conversational**: "looks good" vs structured commands
3. **OpenShift-Specific**: Understands operator patterns, testing pyramid, upgrade strategies
4. **Incremental**: Approve at each phase (spec → plan → each task → test → review → ship)
5. **Pattern-Driven**: Fetches relevant patterns before every operation

### Advantages of spec-kit

1. **True Interactive Input**: Can use stdin `read` directly
2. **Complex Control Flow**: if/switch/while/fan-out for advanced workflows
3. **Catalog System**: Discovery of community workflows
4. **Framework Agnostic**: Works with any AI (Copilot, Claude, Gemini)

---

## Implementation Notes

### Technical Architecture

**Pattern Retrieval**: `/fetch` skill uses KNOWLEDGE_GRAPH.md to navigate Tier 1 and Tier 2 documentation

**Two-Phase Approval**: Skills can't use `read`, so they:
1. Generate output + show gate
2. Exit (return control)
3. User responds
4. Claude detects intent
5. Re-invokes with action

**State Management**: `.work/{skill}-state.json` tracks attempts, feedback, artifacts across invocations

**Checkpoint Enforcement**: /build tasks 3, 5, 7, 9 ignore `--auto-approve` for safety

### Development Timeline

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| Initial Proposal | 1 day | OPENSHIFT_SKILLS_PROPOSAL.md |
| /fetch + /spec | 2 days | Pattern retrieval + spec generation |
| /plan + /build | 2 days | Task breakdown + implementation |
| /test + /review + /ship | 2 days | Testing + review + deployment |
| Approval Gates | 1 day | All skills with human-in-the-loop |
| **Total** | **8 days** | Complete lifecycle with gates |

### File Structure

```
plugins/agentic-docs-maintainer/
├── skills/
│   ├── fetch/SKILL.md          # Pattern retrieval
│   ├── spec/SKILL.md           # Specification generation
│   ├── plan/SKILL.md           # Implementation planning
│   ├── build/SKILL.md          # Incremental implementation
│   ├── test/SKILL.md           # Comprehensive testing
│   ├── review/SKILL.md         # Code review
│   └── ship/SKILL.md           # Safe deployment
├── commands/
│   ├── fetch.md                # /fetch command
│   ├── spec.md                 # /spec command
│   ├── plan.md                 # /plan command
│   ├── build.md                # /build command
│   ├── test.md                 # /test command
│   ├── review.md               # /review command
│   └── ship.md                 # /ship command
├── .work/
│   ├── *-state.json            # State tracking
│   └── ...                     # Temporary files
├── OPENSHIFT_LIFECYCLE_SKILLS.md    # This comprehensive guide
├── APPROVAL_GATES_COMPLETE.md       # Approval gates implementation
└── README.md                        # Plugin overview
```

### Future Enhancements

**Short-Term** (1-2 months):
- [ ] Web UI approval buttons (Ambient integration)
- [ ] Workflow templates for common scenarios
- [ ] Cross-skill analytics (which gates have most revisions)

**Medium-Term** (3-6 months):
- [ ] Full workflow engine (YAML-based, like spec-kit Approach 1)
- [ ] Complex control flow (if/switch/while)
- [ ] Workflow catalog and discovery

**Long-Term** (6-12 months):
- [ ] Machine learning on feedback patterns
- [ ] Automated quality prediction
- [ ] Multi-user collaboration on same feature

---

## Getting Started

### 1. Install

```bash
# Plugin is already in ai-helpers/plugins/agentic-docs-maintainer
cd /path/to/your/openshift/component
```

### 2. Create Your First Spec

```bash
/spec "your feature description" --component your-operator-name
```

### 3. Follow the Workflow

```bash
/plan      # After spec approved
/build task-1  # Implement incrementally
/test      # After all tasks complete
/review    # Before shipping
/ship      # Deploy safely
```

### 4. Use Approval Gates

- Review output carefully at each gate
- Provide specific feedback for revisions
- Approve when ready to proceed

---

## Support and Contribution

**Questions**: Open an issue in `openshift/tmp/ai-helpers`  
**Bugs**: Report with skill name and approval gate step  
**Feature Requests**: Propose in GitHub discussions  
**Contributing**: PRs welcome for all skills

**Pattern**: OpenShift lifecycle skills with human-in-the-loop approval gates  
**Version**: 3.0.0  
**License**: Apache 2.0
