---
name: agentic-docs-tier2
description: Create and maintain lean Tier 2 agentic documentation for component repos (references Tier 1)
trigger: explicit
model: sonnet
---

# Agentic Docs Tier 2 - Component Repository Documentation

## What This Skill Does

Creates and maintains **lean** agentic documentation in OpenShift component repositories that:
- Contains ONLY component-specific knowledge
- References Tier 1 (openshift/enhancements/agentic/) for generic patterns
- Avoids duplication of platform-wide knowledge
- Maintains ~60% smaller documentation footprint

## When to Use This Skill

Use this skill when:
- Creating agentic documentation for an OpenShift component repository
- The repository is part of the OpenShift ecosystem (multi-repo)
- Generic patterns exist in openshift/enhancements/agentic/ (Tier 1)
- You want to avoid duplicating platform-wide knowledge

**DO NOT use this skill if:**
- Creating documentation for openshift/enhancements itself (use tier1-ecosystem skill)
- Repository is standalone (not part of OpenShift) - use full agentic-docs-maintainer instead
- No Tier 1 documentation exists yet (create Tier 1 first)

## Arguments

```bash
/agentic-docs-tier2 [--path <repo-path>] [--verify] [--detect] [--migrate] [--maintain] [--update]
```

**Arguments:**
- `--path <repo-path>`: Path to component repository (default: current directory)
- `--verify`: Verify existing Tier 2 docs for compliance
- `--detect`: Detect changes requiring documentation updates (report only, no fixes)
- `--migrate`: Migrate from single-tier to Tier 2 lean (extract component-specific content)
- `--maintain`: Run autonomous maintenance loop (detect changes + update docs)
- `--update`: One-shot update based on recent repository changes (detect + fix once)
- No args: Create new lean Tier 2 structure

**Legacy (deprecated):**
- `--extract`: Alias for `--migrate` (will be removed in future version)

## Two-Tier Architecture Overview

### Tier 1 (Ecosystem Hub): openshift/enhancements/agentic/
**Purpose:** Cross-repo knowledge shared across ALL OpenShift components

**Contains:**
- Platform patterns (operator patterns, controller-runtime, status conditions)
- Engineering practices (testing pyramid, E2E framework, CI integration)
- Cross-repo ADRs (etcd backend, CVO ordering, operator SDK)
- Kubernetes/OpenShift fundamentals (Pod, Node, ClusterOperator)
- Master entry point: OPENSHIFT_AGENTS.md (~150 lines)

**Owned by:** Enhancement reviewers, platform architecture team

### Tier 2 (Component Repos): machine-config-operator/agentic/
**Purpose:** Component-specific knowledge unique to THIS component

**Contains:**
- Component domain concepts (MachineConfig, MachineConfigPool)
- Component architecture (MCD, MCC, MCS internals)
- Component-specific ADRs (why rpm-ostree, why on-node daemon)
- Component work tracking (exec-plans)
- Component-specific development/testing details
- Links to Tier 1: references/ecosystem.md

**Owned by:** Component maintainers

## Decision Matrix: What Goes Where?

| Knowledge Type | Tier | Example |
|----------------|------|---------|
| Affects multiple repos | **Tier 1** | Why OpenShift uses etcd |
| Generic pattern (all operators) | **Tier 1** | Status conditions, controller-runtime |
| Shared practice (all teams) | **Tier 1** | Testing pyramid, E2E framework |
| Kubernetes fundamental | **Tier 1** | Pod, Node, Service |
| OpenShift platform concept | **Tier 1** | ClusterOperator, Machine API |
| Component-specific concept | **Tier 2** | MachineConfig (MCO-only) |
| Component architecture | **Tier 2** | MCD/MCC/MCS relationships |
| Component-specific decision | **Tier 2** | Why MCO uses rpm-ostree |
| Component work tracking | **Tier 2** | Active MCO features |

**Quick Rule:** "Would another component repo need to duplicate this?"
- **YES** → Tier 1 (enhancements)
- **NO** → Tier 2 (component repo)

## Understanding the Modes

### Create Mode (No args)
**Use when:** Starting fresh, no agentic/ directory exists  
**What it does:** Creates lean Tier 2 structure and template files

```bash
/agentic-docs-tier2
# Creates: AGENTS.md, agentic/domain/, agentic/architecture/, etc.
```

---

### Verify Mode (`--verify`)
**Use when:** Checking existing Tier 2 docs for compliance  
**What it does:** Runs 10 validation checks, reports issues

```bash
/agentic-docs-tier2 --verify
# Checks: AGENTS.md ≤80 lines, no generic duplication, ecosystem.md exists, etc.
# Exit: 0=pass, 1=fail, 2=CRITICAL (Tier 1 content detected)
```

---

### Detect Mode (`--detect`)
**Use when:** You want to see what changed but not auto-fix yet  
**What it does:** Compares repo vs docs, reports what needs updating (read-only)

```bash
/agentic-docs-tier2 --detect

# Compares:
# - types.go vs domain/index.md → New CRDs?
# - git diff HEAD~10 pkg/ → Code changes?
# - pkg/controller/ vs architecture/index.md → New controllers?
# - ../enhancements/ → New enhancements affecting this component?

# Output: List of detected changes
# Action: None (just reports)
```

**Example output:**
```
📝 Changes detected:
  - New CRD: MachineConfigNode
  - New controller: pkg/controller/validator/
  - Code changes: pkg/daemon refactored
  
→ Action needed: Run --update or --maintain to apply updates
```

---

### Migrate Mode (`--migrate`, formerly `--extract`)
**Use when:** Converting from single-tier to Tier 2 lean  
**What it does:** Identifies generic vs component-specific content, removes duplication

```bash
/agentic-docs-tier2 --migrate

# Identifies:
# - Generic content to REMOVE (testing pyramid, operator patterns)
# - Component-specific content to KEEP (MachineConfig, MCO architecture)
# - Suggests replacements with Tier 1 links

# Use case: You have old single-tier docs (6,000 lines)
# Result: Lean Tier 2 docs (2,500 lines) linking to Tier 1
```

**Not for detecting new features!** This is a one-time migration helper.

---

### Update Mode (`--update`)
**Use when:** You want a one-shot update based on recent changes  
**What it does:** Detects changes + updates docs + validates (runs once)

```bash
/agentic-docs-tier2 --update

# Sequence:
# 1. detect-changes.sh → Find what changed
# 2. AI agent → Update docs for detected changes
# 3. validate.sh → Verify Tier 2 compliance
# 4. Done (exits)

# Best for: Manual/scheduled updates
```

---

### Maintain Mode (`--maintain`)
**Use when:** You want continuous autonomous maintenance  
**What it does:** Runs detect → update → validate loop until compliant (max 10 iterations)

```bash
/agentic-docs-tier2 --maintain

# Autonomous loop:
# Iteration 1:
#   detect-changes.sh → New CRD found
#   AI updates docs
#   validate.sh → Still issues
# Iteration 2:
#   detect-changes.sh → No new changes
#   validate.sh → Pass
#   ✅ Done

# Best for: Autonomous continuous maintenance
```

---

### Mode Comparison

| Mode | Compares Repo vs Docs? | Makes Changes? | Iterations | Use Case |
|------|------------------------|----------------|------------|----------|
| (no args) | No | Yes (creates) | 1 | Initial creation |
| `--verify` | No | No | 1 | Compliance check |
| `--detect` | **YES** | No | 1 | **See what changed** |
| `--migrate` | Yes (generic vs component) | Yes | 1 | Single-tier → Tier 2 |
| `--update` | **YES** | Yes | 1 | **One-shot update** |
| `--maintain` | **YES** | Yes | 1-10 | **Autonomous loop** |

---

### Which Mode Should I Use?

**Scenario 1: "I added a new CRD to my component repo"**
```bash
/agentic-docs-tier2 --detect   # See if it's detected
/agentic-docs-tier2 --update   # Update docs for it
```

**Scenario 2: "I want continuous maintenance, detect and fix automatically"**
```bash
/agentic-docs-tier2 --maintain
```

**Scenario 3: "I have old single-tier docs, want to convert to lean Tier 2"**
```bash
/agentic-docs-tier2 --migrate
```

**Scenario 4: "Just check if my docs are compliant"**
```bash
/agentic-docs-tier2 --verify
```

**Scenario 5: "Starting fresh, no docs yet"**
```bash
/agentic-docs-tier2
```

## Task Execution

When the user invokes this skill, execute the following:

### Phase 0: Parse Arguments and Route

**Goal:** Determine which mode to execute based on arguments

**Parse user arguments:**
```bash
# Extract from user input: /agentic-docs-tier2 [OPTIONS]
MODE="create"  # default
REPO_PATH="."  # default

while [[ $# -gt 0 ]]; do
    case $1 in
        --path)
            REPO_PATH="$2"
            shift 2
            ;;
        --verify)
            MODE="verify"
            shift
            ;;
        --detect)
            MODE="detect"
            shift
            ;;
        --migrate|--extract)  # --extract is legacy alias
            MODE="migrate"
            shift
            ;;
        --update)
            MODE="update"
            shift
            ;;
        --maintain)
            MODE="maintain"
            shift
            ;;
        *)
            shift
            ;;
    esac
done
```

**Route to appropriate execution:**
- `MODE="create"` → Execute Phases 1-7 (Create new Tier 2 structure)
- `MODE="verify"` → Execute Phase 9 only (Validation)
- `MODE="detect"` → Execute Phase 8.1 only (Detect changes, report only)
- `MODE="migrate"` → Execute Phase 6 (Extract component-specific content)
- `MODE="update"` → Execute Phases 8.1-8.3 once (Detect + Update + Validate)
- `MODE="maintain"` → Execute Phase 8.4 (Autonomous maintenance loop)

---

### Phase 1: Assessment

**Goal:** Understand the component repository

**Actions:**
1. **Verify this is an OpenShift component repo:**
   ```bash
   # Check if go.mod contains openshift dependencies
   if grep -q "github.com/openshift" go.mod 2>/dev/null; then
       echo "✅ OpenShift component repository detected"
   else
       echo "⚠️  Not an OpenShift repo - consider using full agentic-docs-maintainer instead"
       exit 1
   fi
   ```

2. **Verify Tier 1 exists:**
   ```bash
   # Check if enhancements/agentic/ is accessible
   TIER1_URL="https://github.com/openshift/enhancements/tree/master/agentic"
   if curl -s -o /dev/null -w "%{http_code}" "$TIER1_URL" | grep -q "200"; then
       echo "✅ Tier 1 documentation exists"
   else
       echo "❌ Tier 1 not found - create enhancements/agentic/ first"
       exit 1
   fi
   ```

3. **Identify component:**
   - Component name from repo name
   - Main purpose (1 sentence)
   - Key concepts (3-5)
   - Related components

**Output:** Component profile for documentation

### Phase 2: Create Lean Tier 2 Structure

**Goal:** Create directory structure optimized for Tier 2

**Actions:**
```bash
REPO_ROOT="${REPO_PATH:-$(pwd)}"
cd "$REPO_ROOT"

# Create Tier 2 lean structure
mkdir -p agentic/{domain,architecture,decisions,exec-plans/{active,completed},references,scripts}

# Create index files
for dir in domain architecture decisions references; do
    touch "agentic/$dir/index.md"
done

# Create required files
touch AGENTS.md
touch ARCHITECTURE.md
touch "agentic/exec-plans/template.md"
touch "agentic/exec-plans/tech-debt-tracker.md"
touch "agentic/references/ecosystem.md"

# Create component-specific guides (LEAN versions)
COMPONENT_NAME=$(basename "$REPO_ROOT")
touch "agentic/${COMPONENT_NAME}_DEVELOPMENT.md"
touch "agentic/${COMPONENT_NAME}_TESTING.md"

echo "✅ Tier 2 structure created"
```

**Expected structure:**
```
component-repo/
├── AGENTS.md                           [~60-80 lines, LEAN]
├── ARCHITECTURE.md
└── agentic/
    ├── domain/                         [Component concepts ONLY]
    ├── architecture/                   [Component internals]
    ├── decisions/                      [Component ADRs ONLY]
    ├── exec-plans/
    │   ├── active/
    │   ├── completed/
    │   ├── template.md
    │   └── tech-debt-tracker.md
    ├── [COMPONENT]_DEVELOPMENT.md      [Lean - component-specific only]
    ├── [COMPONENT]_TESTING.md          [Lean - component-specific only]
    ├── references/
    │   └── ecosystem.md                [Links to Tier 1 - CRITICAL]
    └── scripts/
```

### Phase 3: Create Lean AGENTS.md

**Goal:** Create entry point ≤80 lines that links to Tier 1

**Template:**
```markdown
# [component-name] - Agent Navigation

> For OpenShift platform docs: [enhancements/agentic](https://github.com/openshift/enhancements/tree/master/agentic)
> For [Component] enhancements: [enhancements/[component]](https://github.com/openshift/enhancements/tree/master/enhancements/[component])

**Version**: 1.0
**Last Updated**: YYYY-MM-DD

## What This Component Does

[1-2 sentences describing component-specific purpose]

## Quick Start

**New to OpenShift operators?**
→ [Operator Patterns](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/)

**Understanding [Component]**
→ [Architecture](./ARCHITECTURE.md)
→ [Domain Concepts](./agentic/domain/)

**Implementing a feature**
1. Review [enhancements](https://github.com/openshift/enhancements/tree/master/enhancements/[component])
2. Create [exec-plan](./agentic/exec-plans/active/)
3. Implement + tests

## [Component] Concepts

| Concept | Definition | Docs |
|---------|-----------|------|
| [Concept1] | [1-sentence] | [./agentic/domain/concept1.md] |
| [Concept2] | [1-sentence] | [./agentic/domain/concept2.md] |

## [Component] Architecture

```
[Simple ASCII diagram]
```

See [ARCHITECTURE.md](./ARCHITECTURE.md).

## Development

- **Build**: [build command]
- **Unit tests**: [test command]
- **E2E tests**: [e2e command]
- **Details**: [agentic/[COMPONENT]_DEVELOPMENT.md](./agentic/[COMPONENT]_DEVELOPMENT.md)

## External References

- [OpenShift Platform](https://github.com/openshift/enhancements/tree/master/agentic)
- [Operator Patterns](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/)
- [Testing Practices](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/)

---

**Constraint**: ≤80 lines. Details in agentic/ or Tier 1.
```

**Rules:**
1. **MUST be ≤80 lines** (not 150 like single-tier)
2. **Prominently link to Tier 1** at the top
3. **No generic explanations** - link to Tier 1 instead
4. **Component-specific only** - what makes THIS component unique

**Validation:**
```bash
lines=$(wc -l < AGENTS.md)
if [ $lines -gt 80 ]; then
    echo "❌ AGENTS.md is $lines lines (max 80 for Tier 2)"
    exit 1
fi
```

### Phase 4: Create references/ecosystem.md (CRITICAL)

**Goal:** Central index of all Tier 1 knowledge this component uses

**Template:**
```markdown
# [Component] → Ecosystem Reference

**Last Updated**: YYYY-MM-DD

## Platform Patterns [Component] Uses

| Pattern | Link |
|---------|------|
| Status Conditions | [status-conditions.md](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/status-conditions.md) |
| controller-runtime | [controller-runtime.md](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/controller-runtime.md) |
| Leader Election | [leader-election.md](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/leader-election.md) |
| RBAC Patterns | [rbac-patterns.md](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/rbac-patterns.md) |

## Practices [Component] Follows

| Practice | Link |
|----------|------|
| Testing Pyramid | [pyramid.md](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/pyramid.md) |
| E2E Framework | [e2e-framework.md](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/e2e-framework.md) |
| CI Integration | [ci-integration.md](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/ci-integration.md) |
| Threat Modeling | [threat-modeling.md](https://github.com/openshift/enhancements/blob/master/agentic/practices/security/threat-modeling.md) |
| RBAC Guidelines | [rbac-guidelines.md](https://github.com/openshift/enhancements/blob/master/agentic/practices/security/rbac-guidelines.md) |
| SLO Framework | [slo-framework.md](https://github.com/openshift/enhancements/blob/master/agentic/practices/reliability/slo-framework.md) |
| Observability | [observability.md](https://github.com/openshift/enhancements/blob/master/agentic/practices/reliability/observability.md) |

## Cross-Repo Decisions Affecting [Component]

| ADR | Impact |
|-----|--------|
| [adr-0001-operator-sdk](https://github.com/openshift/enhancements/blob/master/agentic/decisions/adr-0001-operator-sdk.md) | [How it affects this component] |
| [adr-0002-etcd-backend](https://github.com/openshift/enhancements/blob/master/agentic/decisions/adr-0002-etcd-backend.md) | [How it affects this component] |
| [adr-0003-cvo-upgrade-ordering](https://github.com/openshift/enhancements/blob/master/agentic/decisions/adr-0003-cvo-upgrade-ordering.md) | [How it affects this component] |

## Related Components

| Component | Relationship | Link |
|-----------|--------------|------|
| [component1] | [Interaction] | [AGENTS.md](https://github.com/openshift/[component1]/blob/master/AGENTS.md) |
| [component2] | [Interaction] | [AGENTS.md](https://github.com/openshift/[component2]/blob/master/AGENTS.md) |

## Enhancements

[enhancements/[component]/](https://github.com/openshift/enhancements/tree/master/enhancements/[component])

## OpenShift Knowledge

For general OpenShift concepts, see:
- [Kubernetes Fundamentals](https://github.com/openshift/enhancements/blob/master/agentic/domain/kubernetes/)
- [OpenShift Platform](https://github.com/openshift/enhancements/blob/master/agentic/domain/openshift/)
- [Glossary](https://github.com/openshift/enhancements/blob/master/agentic/domain/glossary.md)
```

**Purpose:** This file is the BRIDGE between Tier 2 and Tier 1

### Phase 5: Create Lean Component-Specific Guides

**Goal:** Replace generic content with component-specific content + links to Tier 1

#### [COMPONENT]_DEVELOPMENT.md

**Template:**
```markdown
# [Component] Development Guide

> For general practices: [enhancements/practices/development/](https://github.com/openshift/enhancements/blob/master/agentic/practices/development/)

## [Component]-Specific Setup

### Prerequisites
- Go 1.21+
- [Component-specific deps]

### Build
```bash
make
```

### Run Locally
```bash
make run-local
```

## [Component]-Specific Considerations

**[Unique aspect]**: [Why it matters for THIS component]

## Debugging [Component]

**[Component-specific scenario]**:
```bash
# Commands specific to this component
```

## References

- [General Git Workflow](https://github.com/openshift/enhancements/blob/master/agentic/practices/development/git-workflow.md)
- [Code Review Standards](https://github.com/openshift/enhancements/blob/master/agentic/practices/development/code-review.md)
- [API Evolution](https://github.com/openshift/enhancements/blob/master/agentic/practices/development/api-evolution.md)
```

**Rules:**
- ✅ Component-specific details ONLY
- ❌ NO generic git workflows
- ❌ NO generic code review standards
- ✅ Link to Tier 1 for generic practices

#### [COMPONENT]_TESTING.md

**Template:**
```markdown
# [Component] Testing

> For testing practices: [enhancements/practices/testing/](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/)

## [Component] Test Suites

### Unit Tests
```bash
make test-unit
```

**[Component]-Specific Coverage**:
- [Area 1]: pkg/[area1]/*_test.go
- [Area 2]: pkg/[area2]/*_test.go

### Integration Tests
```bash
make test-integration
```

**[Component]-Specific Scenarios**:
- [Scenario 1]
- [Scenario 2]

### E2E Tests
```bash
make test-e2e
```

**[Component]-Specific E2E**:
- test/e2e-agnostic/[component]_test.go

## [Component]-Specific Testing Challenges

**[Challenge]**: [Why it's unique to THIS component]

## References

- [Testing Pyramid](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/pyramid.md)
- [E2E Framework](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/e2e-framework.md)
- [CI Integration](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/ci-integration.md)
```

**Rules:**
- ✅ Component-specific test suites
- ❌ NO testing pyramid explanation
- ❌ NO E2E framework philosophy
- ✅ Link to Tier 1 for testing practices

### Phase 6: Extract Component-Specific Content

**Goal:** If migrating from single-tier, extract only component-specific content

**Process:**

1. **Identify generic content to REMOVE:**
   ```bash
   # Patterns that belong in Tier 1:
   - Operator patterns (controller-runtime, status conditions, leader election)
   - Testing practices (test pyramid, E2E framework)
   - Security practices (STRIDE, threat modeling, RBAC guidelines)
   - Reliability practices (SLO framework, observability)
   - Kubernetes fundamentals (Pod, Node, Service)
   ```

2. **Identify component-specific content to KEEP:**
   ```bash
   # Content unique to THIS component:
   - Component domain concepts (e.g., MachineConfig for MCO)
   - Component architecture (e.g., MCD/MCC/MCS for MCO)
   - Component-specific decisions (e.g., why rpm-ostree for MCO)
   - Component work tracking (exec-plans)
   ```

3. **Replace generic with links:**
   - Before: 187-line TESTING.md (60% generic)
   - After: 90-line MCO_TESTING.md (100% MCO-specific) + links to Tier 1

4. **Update indexes:**
   - Remove deleted content from indexes
   - Add links to Tier 1 equivalents

**Validation:**
```bash
# Check for generic content that should be removed
if grep -r "test pyramid\|controller-runtime philosophy\|STRIDE framework" agentic/; then
    echo "❌ Found generic content - should link to Tier 1 instead"
    exit 1
fi
```

### Phase 7: Verify Tier 2 Compliance

**Goal:** Ensure Tier 2 docs are lean and link to Tier 1

**Validation checks:**

1. **AGENTS.md length:**
   ```bash
   lines=$(wc -l < AGENTS.md)
   if [ $lines -gt 80 ]; then
       echo "❌ AGENTS.md too long: $lines lines (max 80)"
   fi
   ```

2. **No generic duplication:**
   ```bash
   # Forbidden patterns (belong in Tier 1):
   FORBIDDEN=(
       "testing pyramid"
       "controller-runtime reconciliation"
       "Available/Progressing/Degraded conditions"
       "STRIDE threat model"
       "SLO error budget"
   )
   
   for pattern in "${FORBIDDEN[@]}"; do
       if grep -ri "$pattern" agentic/; then
           echo "❌ Found generic content: '$pattern'"
           echo "   Should link to Tier 1 instead"
       fi
   done
   ```

3. **Required links to Tier 1:**
   ```bash
   # Must have ecosystem.md
   if [ ! -f "agentic/references/ecosystem.md" ]; then
       echo "❌ Missing agentic/references/ecosystem.md"
   fi
   
   # Must reference Tier 1 in AGENTS.md
   if ! grep -q "enhancements/blob/master/agentic" AGENTS.md; then
       echo "❌ AGENTS.md doesn't link to Tier 1"
   fi
   ```

4. **Component-specific content only:**
   ```bash
   # All domain concepts should be component-specific
   # All ADRs should be component-specific
   # All architecture docs should be component-specific
   ```

**Expected metrics:**
- AGENTS.md: ≤80 lines (vs 143 for single-tier)
- Total agentic/: ~2,500 lines (vs 6,000 for single-tier)
- Generic duplication: 0% (vs 40% for single-tier)
- Links to Tier 1: ≥10 references

### Phase 8: Maintenance and Updates (--detect, --update, or --maintain)

**Goal:** Keep Tier 2 docs synchronized with component repository changes

#### Phase 8.1: Detect Component Changes (used by --detect, --update, --maintain)

**What this phase does:**
- Compares repository state vs documentation timestamps
- Detects new CRDs, controllers, code changes, enhancements, architectural decisions
- **For --detect mode:** Reports findings and STOPS (no updates)
- **For --update/--maintain modes:** Continues to Phase 8.2 to apply updates

**Script to use:**
```bash
# Run the detect-changes.sh script
./agentic/scripts/detect-changes.sh "$REPO_ROOT"
```

**Manual detection (if script not available):**
```bash
# Identify what changed in the component repo
cd "$REPO_ROOT"

# 1. Check for new API types (CRDs)
NEW_CRDS=$(find vendor/github.com/openshift/api -name "types.go" \
    -newer agentic/domain/index.md 2>/dev/null)

# 2. Check for code structure changes
RECENT_CODE_CHANGES=$(git diff HEAD~10..HEAD --stat pkg/ cmd/ | grep -E "^\s+(pkg|cmd)/")

# 3. Check for new controllers/components
NEW_CONTROLLERS=$(find pkg/controller -type d -maxdepth 1 \
    -newer agentic/architecture/index.md 2>/dev/null)

# 4. Check for decision-worthy changes (architectural)
ARCHITECTURAL_COMMITS=$(git log --since="30 days ago" \
    --grep="design\|decision\|alternative\|architecture" --oneline)

# 5. Check for enhancement references
COMPONENT_NAME=$(basename "$REPO_ROOT")
RECENT_ENHANCEMENTS=$(find ../enhancements/enhancements -name "*${COMPONENT_NAME}*" \
    -newer agentic/references/ecosystem.md 2>/dev/null)
```

**Output format:**
```
📝 Changes detected requiring documentation updates

[1/5] New CRDs/API types:
  - machineconfiguration.openshift.io/v1/MachineConfigNode
  → Action needed: Create domain docs for new types

[2/5] Code structure changes:
  - 15 files changed in pkg/daemon/
  → Action needed: Review architecture docs for updates

[3/5] New controllers:
  - pkg/controller/validator/
  → Action needed: Document new controller in architecture/

[4/5] New enhancements:
  - enhancements/machine-config/custom-os-images.md
  → Action needed: Create exec-plan in active/

[5/5] Architectural decisions:
  - 3 commits with architectural keywords
  → Action needed: Review for potential ADRs

Exit code: 1 (changes detected)
```

**If --detect mode:** STOP here and report to user  
**If --update/--maintain:** Continue to Phase 8.2

#### Phase 8.2: Identify Documentation Updates Needed

**Process:**

1. **New API types detected:**
   ```bash
   if [ -n "$NEW_CRDS" ]; then
       echo "📝 New CRDs detected - need domain docs:"
       echo "$NEW_CRDS" | xargs -I{} basename {} .go
       
       # For each new CRD:
       # - Create agentic/domain/[crd-name].md
       # - Add to domain/index.md
       # - Link from ARCHITECTURE.md if architectural
   fi
   ```

2. **Code structure changes:**
   ```bash
   # New packages or significant refactoring
   if git diff HEAD~10..HEAD --stat pkg/ | grep -q "pkg/.*\.go"; then
       echo "📝 Code structure changed - review architecture docs"
       
       # Check if architecture docs need updates:
       # - New components added?
       # - Component responsibilities changed?
       # - Data flow altered?
   fi
   ```

3. **New enhancements merged:**
   ```bash
   # Check for merged enhancements affecting this component
   COMPONENT_NAME=$(basename "$REPO_ROOT")
   RECENT_ENHANCEMENTS=$(find ../enhancements/enhancements -name "*${COMPONENT_NAME}*" -newer agentic/references/ecosystem.md 2>/dev/null)
   
   if [ -n "$RECENT_ENHANCEMENTS" ]; then
       echo "📝 New enhancements - may need:"
       echo "  - New exec-plans in active/"
       echo "  - New domain concepts"
       echo "  - Updated ecosystem.md references"
   fi
   ```

4. **Check Tier 1 for updates:**
   ```bash
   # Detect if Tier 1 patterns have been updated
   TIER1_URL="https://api.github.com/repos/openshift/enhancements/commits?path=agentic&since=$(date -d '30 days ago' --iso-8601)"
   
   if curl -s "$TIER1_URL" | grep -q "sha"; then
       echo "📝 Tier 1 updated - verify ecosystem.md links are current"
   fi
   ```

**Decision matrix for updates:**

| Change Type | Documentation Action | Location |
|-------------|---------------------|----------|
| New CRD/API type | Create domain doc | agentic/domain/[type].md |
| New controller/component | Update architecture | agentic/architecture/components.md |
| Significant design decision | Create ADR | agentic/decisions/adr-NNNN.md |
| New feature started | Create exec-plan | agentic/exec-plans/active/[feature].md |
| Feature completed | Move exec-plan | exec-plans/active/ → completed/ |
| Code refactoring | Update architecture | agentic/architecture/ |
| New dependencies | Update ARCHITECTURE.md | ARCHITECTURE.md |
| Test changes | Update [COMPONENT]_TESTING.md | agentic/[COMPONENT]_TESTING.md |
| Build changes | Update [COMPONENT]_DEVELOPMENT.md | agentic/[COMPONENT]_DEVELOPMENT.md |

#### Phase 8.3: Update Documentation (Autonomous)

**Goal:** Spawn autonomous agent to make updates while preserving Tier 2 principles

**Agent Task Prompt:**
```
You are the Agentic Docs Tier 2 Maintenance Agent.

GOAL: Update component documentation based on detected changes.

REPOSITORY: $REPO_ROOT
COMPONENT: $COMPONENT_NAME

DETECTED CHANGES:
[List of changes from Phase 8.1]

TIER 2 RULES (MUST FOLLOW):
1. ✅ Component-specific content ONLY
2. ❌ NO generic patterns (link to Tier 1 instead)
3. ✅ Keep AGENTS.md ≤80 lines
4. ✅ All new docs reference Tier 1 where appropriate
5. ✅ Update ecosystem.md if new Tier 1 links needed

TASKS:
[Generated based on changes detected]

Example tasks:
1. New CRD detected: MachineConfigNode
   → Create agentic/domain/machineconfignode.md
   → Document API structure, purpose, lifecycle
   → Link to Tier 1 CRD patterns
   → Add to domain/index.md

2. New component: pkg/controller/validator/
   → Update agentic/architecture/components.md
   → Document validator component, responsibilities
   → Update component diagram in ARCHITECTURE.md

3. New enhancement merged: custom-os-images
   → Create agentic/exec-plans/active/custom-os-images.md
   → Reference enhancement in enhancements repo
   → Document component-specific implementation plan

4. Tier 1 updated: New observability pattern
   → Update agentic/references/ecosystem.md
   → Add link to new observability pattern
   → Review [COMPONENT]_TESTING.md for applicability

VALIDATION BEFORE COMMIT:
- Run Tier 2 compliance checks
- Ensure AGENTS.md still ≤80 lines
- No generic content added
- All Tier 1 links valid
- Component-specific only

CREATE GIT COMMIT:
"docs: update Tier 2 docs for [changes summary]

- [Change 1]
- [Change 2]
- [Change 3]

Tier 2 compliance: ✅
AGENTS.md: X lines (≤80)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

**Agent spawning:**
```bash
# Spawn autonomous agent with task
echo "$AGENT_TASK" > "$REPO_ROOT/.tier2-update-task.md"

echo "🤖 Spawning Tier 2 update agent..."
echo "📋 Task: $REPO_ROOT/.tier2-update-task.md"
echo ""
echo "Agent will:"
echo "  1. Review detected changes"
echo "  2. Update documentation (component-specific only)"
echo "  3. Preserve Tier 2 lean principles"
echo "  4. Validate compliance"
echo "  5. Create git commit"
```

#### Phase 8.4: Maintenance Loop (--maintain)

**Goal:** Continuous verification and fixing (like agentic-docs-maintainer loop)

**Loop structure:**
```bash
MAX_ITERATIONS=10
ITERATION=1

while [ $ITERATION -le $MAX_ITERATIONS ]; do
    echo "🔄 Iteration $ITERATION/$MAX_ITERATIONS"
    
    # 1. Detect changes
    CHANGES=$(detect_component_changes)
    
    # 2. Verify Tier 2 compliance
    ISSUES=$(verify_tier2_compliance)
    
    # 3. Check if done
    if [ -z "$CHANGES" ] && [ -z "$ISSUES" ]; then
        echo "✅ No changes detected, all compliant"
        break
    fi
    
    # 4. Spawn agent to fix/update
    spawn_tier2_agent "$CHANGES" "$ISSUES"
    
    # 5. Wait for agent completion
    wait_for_agent_completion
    
    # 6. Check progress
    NEW_ISSUES=$(verify_tier2_compliance)
    
    if [ "$ISSUES" = "$NEW_ISSUES" ]; then
        echo "⚠️  Same issues - stuck"
        break
    fi
    
    ITERATION=$((ITERATION + 1))
done

# Report results
echo ""
echo "=================================="
if [ $ITERATION -gt $MAX_ITERATIONS ]; then
    echo "⚠️  Max iterations reached"
elif [ -n "$NEW_ISSUES" ]; then
    echo "⚠️  Stuck - manual intervention needed"
else
    echo "✅ Maintenance complete"
fi
echo "=================================="
```

**Stopping conditions:**
- ✅ No changes detected AND all compliance checks pass
- ⚠️ Max 10 iterations reached
- ⚠️ Same issues repeat 3x (stuck)

#### Phase 8.5: Specific Update Scenarios

**Scenario 1: New CRD Added**

```bash
# Detected: New MachineConfigNode CRD in vendor/github.com/openshift/api

# Actions:
1. Create agentic/domain/machineconfignode.md
   Template:
   ---
   concept: MachineConfigNode
   type: CRD
   related: [MachineConfig, Node]
   ---
   
   # MachineConfigNode
   
   ## Definition
   [What it is - component-specific]
   
   ## Purpose
   [Why it exists in THIS component]
   
   ## Relationship to Platform
   - **CRD Pattern**: [K8s CRDs](https://github.com/openshift/enhancements/blob/master/agentic/domain/kubernetes/crds.md)
   - **Node Concept**: [Node](https://github.com/openshift/enhancements/blob/master/agentic/domain/kubernetes/nodes.md)
   
   ## API Structure
   [Component-specific fields]
   
   ## Implementation
   - **Location**: pkg/controller/machineconfignode/
   - **Reconciliation**: [How THIS component handles it]

2. Update agentic/domain/index.md
   Add: - [MachineConfigNode](./machineconfignode.md) - Per-node config tracking

3. Update ARCHITECTURE.md (if architectural)
   Add to component diagram if it's a major concept

4. Verify ecosystem.md has CRD pattern link
   If not, add:
   | CRD Patterns | [crds.md](https://github.com/openshift/enhancements/blob/master/agentic/domain/kubernetes/crds.md) |
```

**Scenario 2: New Controller Added**

```bash
# Detected: New pkg/controller/validator/ directory

# Actions:
1. Update agentic/architecture/components.md
   Add section:
   
   ### Validator Controller
   **Purpose**: Validates MachineConfig changes before application
   **Location**: pkg/controller/validator/
   **Responsibilities**:
   - Pre-apply validation
   - Safety checks
   - Rejection of invalid configs
   
   **Pattern**: Uses [controller-runtime](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/controller-runtime.md)

2. Update ARCHITECTURE.md
   Add validator to component diagram

3. Check if ADR needed
   If architectural decision (why validator exists):
   → Create agentic/decisions/adr-NNNN-validation.md
```

**Scenario 3: Feature Enhancement Merged**

```bash
# Detected: New enhancement in enhancements/machine-config/custom-os-images.md

# Actions:
1. Create agentic/exec-plans/active/custom-os-images.md
   ---
   status: active
   related_enhancement: https://github.com/openshift/enhancements/blob/master/enhancements/machine-config/custom-os-images.md
   ---
   
   # Plan: Custom OS Images (MCO Side)
   
   ## Goal
   Implement MCO portion of custom OS images enhancement.
   
   ## Context
   See [enhancement](link) for overall design.
   This plan covers ONLY MCO-specific implementation.
   
   [Component-specific plan]

2. Update agentic/references/ecosystem.md
   If new Tier 1 ADR created for this feature:
   Add to "Cross-Repo Decisions" table
```

**Scenario 4: Code Refactoring**

```bash
# Detected: pkg/daemon/ refactored into pkg/daemon/{apply,update,reboot}

# Actions:
1. Update agentic/architecture/daemon.md
   Reflect new structure:
   
   ## Daemon Architecture
   
   The MachineConfigDaemon is organized into:
   - **Apply**: pkg/daemon/apply/ - Config application logic
   - **Update**: pkg/daemon/update/ - OS update handling  
   - **Reboot**: pkg/daemon/reboot/ - Node reboot coordination
   
   [Update component descriptions]

2. Update ARCHITECTURE.md
   Refresh component diagram if significant change

3. Check AGENTS.md
   Ensure still ≤80 lines (don't add details, link to architecture/)
```

**Scenario 5: Tier 1 Pattern Updated**

```bash
# Detected: Tier 1 status-conditions.md updated with new Upgradeable condition

# Actions:
1. Review component usage
   Check if component implements Upgradeable condition:
   grep -r "Upgradeable" pkg/

2. If implemented:
   → Update agentic/architecture/components.md
   → Add reference to updated Tier 1 pattern
   
3. Update agentic/references/ecosystem.md
   Verify link to status-conditions.md is current
   
4. Do NOT duplicate Tier 1 content
   ❌ Don't copy Upgradeable explanation to component docs
   ✅ Link to Tier 1, document component-specific usage
```

### Phase 9: Report Results

**Output for creation (no args):**
```
✅ Tier 2 Lean Documentation Created

Component: [component-name]
Repository: [repo-path]

Structure Created:
  - AGENTS.md: X lines (target: ≤80)
  - Domain concepts: Y files
  - Architecture docs: Z files
  - Component ADRs: N files
  - Ecosystem references: ecosystem.md

Tier 1 Links:
  - Operator patterns: [count] links
  - Testing practices: [count] links
  - Security practices: [count] links
  - Cross-repo ADRs: [count] links

Validation:
  ✅ AGENTS.md ≤80 lines
  ✅ No generic duplication detected
  ✅ ecosystem.md created with Tier 1 links
  ✅ Component-specific content only

Next Steps:
  1. Review and populate domain concept docs
  2. Document component architecture
  3. Create component-specific ADRs
  4. Add exec-plans for active work
  5. Run: /agentic-docs-tier2 --maintain (for ongoing updates)

For generic patterns, see:
  https://github.com/openshift/enhancements/tree/master/agentic
```

**Output for maintenance (--maintain):**
```
✅ Tier 2 Lean Documentation Maintenance Complete

Component: [component-name]
Iterations: X/10

Changes Detected:
  - New CRD: MachineConfigNode
  - New controller: pkg/controller/validator
  - Enhancement merged: custom-os-images
  - Tier 1 updated: observability pattern

Documentation Updates:
  ✅ Created agentic/domain/machineconfignode.md
  ✅ Updated agentic/architecture/components.md (validator)
  ✅ Created agentic/exec-plans/active/custom-os-images.md
  ✅ Updated agentic/references/ecosystem.md

Commits Created:
  - docs: add MachineConfigNode domain doc
  - docs: document validator controller
  - docs: create exec-plan for custom-os-images
  - docs: update Tier 1 references

Tier 2 Compliance:
  ✅ AGENTS.md: 62 lines (≤80)
  ✅ No generic duplication
  ✅ All Tier 1 links valid
  ✅ Component-specific only

Status: ✅ PASS - All updates applied and verified
```

**Output for updates (--update):**
```
✅ Tier 2 Documentation Updated

Repository: [repo-path]
Changes Since: [last update date]

Updates Applied:
  1. New API: MachineConfigNode
     → Created domain/machineconfignode.md
     → Updated domain/index.md
     
  2. Architecture change: Daemon refactoring
     → Updated architecture/daemon.md
     → Refreshed ARCHITECTURE.md diagram
     
  3. Tier 1 reference: New observability pattern
     → Updated references/ecosystem.md

Validation:
  ✅ AGENTS.md still ≤80 lines (62 lines)
  ✅ No generic content added
  ✅ All Tier 1 links valid

Git Commit:
  SHA: abc123
  Message: "docs: update Tier 2 docs for recent changes"
```

## Anti-Patterns to Avoid

### ❌ DON'T: Duplicate Tier 1 Content

**Wrong:**
```markdown
# MCO/agentic/TESTING.md (187 lines)

## Testing Pyramid

[100 lines explaining testing pyramid philosophy]

## E2E Framework

[50 lines explaining OpenShift E2E framework]

## MCO Tests

[37 lines MCO-specific]
```

**Right:**
```markdown
# MCO/agentic/MCO_TESTING.md (90 lines)

> For testing practices: [enhancements/practices/testing/](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/)

## MCO Test Suites

[37 lines MCO-specific]

See [E2E Framework](link) for general patterns.
```

### ❌ DON'T: Create Cross-Repo ADRs in Component

**Wrong:**
```markdown
# MCO/agentic/decisions/adr-0004-etcd-backend.md

Decision: Use etcd for cluster state
Affects: All operators, control plane
```
→ This belongs in Tier 1 (enhancements/agentic/decisions/)

**Right:**
```markdown
# MCO/agentic/decisions/adr-0001-rpm-ostree.md

Decision: Use rpm-ostree for OS updates
Affects: MCO only
References: [Tier 1 ADR-0003](link) for CVO coordination
```

### ❌ DON'T: Explain Generic Patterns

**Wrong:**
```markdown
# MCO/agentic/domain/machineconfig.md

## What is controller-runtime?

controller-runtime is the standard library for building Kubernetes operators...
[200 lines explaining controller-runtime]
```

**Right:**
```markdown
# MCO/agentic/domain/machineconfig.md

## MachineConfig Controller Implementation

MCO uses [controller-runtime](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/controller-runtime.md) 
to reconcile MachineConfigs.

**MCO-specific behavior:**
- Watches MachineConfig and MachineConfigPool resources
- Renders merged configuration
- Coordinates with MachineConfigDaemon
- Code: pkg/controller/template/
```

## Success Metrics

**Tier 2 documentation is successful when:**

✅ **Size:**
- AGENTS.md ≤ 80 lines (58% reduction from single-tier)
- Total agentic/ ≤ 50% of single-tier size
- Zero generic content duplication

✅ **Structure:**
- All directories created
- ecosystem.md exists with Tier 1 links
- Component-specific content only

✅ **Navigation:**
- Any concept reachable in ≤2 hops from AGENTS.md
- Clear links to Tier 1 for generic knowledge
- Bi-directional discovery (Tier 2 ↔ Tier 1)

✅ **Quality:**
- No broken links
- All Tier 1 references current
- Component-specific content is complete

✅ **Maintainability:**
- Updates to generic patterns require 0 component PRs
- Component changes require 1 component PR
- Clear ownership (component vs platform)

## Frequently Asked Questions

### Q: When should I use Tier 2 lean docs vs full agentic-docs-maintainer?

**Use Tier 2 lean docs (this skill) when:**
- Repository is part of OpenShift ecosystem
- Generic patterns exist in openshift/enhancements/agentic/
- You want to avoid duplication
- Multiple repos would need same patterns

**Use full agentic-docs-maintainer when:**
- Repository is standalone (not part of OpenShift)
- No Tier 1 hub exists
- Self-contained documentation is desired

### Q: What if Tier 1 doesn't have a pattern I need?

**If pattern is generic (affects multiple repos):**
1. Create the pattern in Tier 1 first
2. Then reference it from Tier 2

**If pattern is component-specific:**
1. Document it in Tier 2
2. Do NOT duplicate it in other component repos
3. If other repos need it, move to Tier 1

### Q: How do I handle cross-repo features?

**Process:**
1. Enhancement proposal in enhancements/enhancements/[component]/
2. If cross-repo ADR needed → enhancements/agentic/decisions/
3. Exec-plan in each affected component repo
4. Each exec-plan references the enhancement

### Q: Can Tier 2 docs reference Tier 2 docs in other repos?

**Yes, through ecosystem.md:**

```markdown
## Related Components

| Component | Relationship | Link |
|-----------|--------------|------|
| installer | MCO integrates with installer for first-boot | [installer AGENTS.md](link) |
```

But prefer linking through Tier 1 when possible (clearer navigation).

## Files This Skill Creates

```
component-repo/
├── AGENTS.md                           [~60-80 lines]
├── ARCHITECTURE.md
└── agentic/
    ├── domain/
    │   ├── index.md
    │   └── [concept].md                [Component concepts ONLY]
    ├── architecture/
    │   ├── index.md
    │   └── [component].md              [Component internals]
    ├── decisions/
    │   ├── index.md
    │   ├── adr-template.md
    │   └── adr-NNNN-[decision].md      [Component ADRs ONLY]
    ├── exec-plans/
    │   ├── active/
    │   ├── completed/
    │   ├── template.md
    │   └── tech-debt-tracker.md
    ├── [COMPONENT]_DEVELOPMENT.md      [Lean, component-specific]
    ├── [COMPONENT]_TESTING.md          [Lean, component-specific]
    ├── references/
    │   ├── index.md
    │   └── ecosystem.md                [CRITICAL - Links to Tier 1]
    └── scripts/
        └── [validation scripts]
```

## Example: machine-config-operator

**Before (Single-Tier):**
- 29 files, 6,000 lines
- AGENTS.md: 143 lines
- 40% generic content (2,400 lines duplicated from other repos)

**After (Tier 2 Lean):**
- 15 files, 2,500 lines (-58%)
- AGENTS.md: 60 lines (-58%)
- 0% generic content (links to Tier 1 instead)
- ecosystem.md: 40 lines of Tier 1 references

**Savings:**
- 3,500 lines removed
- 100% of generic duplication eliminated
- Maintenance: 1 Tier 1 PR updates all repos vs 60+ component PRs

## Related Skills

- **tier1-ecosystem**: Create Tier 1 docs in openshift/enhancements
- **agentic-docs-maintainer**: Full single-tier docs (standalone repos)
- **tier2-verify**: Verify Tier 2 compliance (separate skill)

---

**Version**: 1.0
**Last Updated**: 2026-04-03
