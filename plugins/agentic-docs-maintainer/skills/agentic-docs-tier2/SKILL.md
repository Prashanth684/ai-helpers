---
name: agentic-docs-tier2
description: Create and maintain lean Tier 2 agentic documentation for component repos (references Tier 1)
trigger: explicit
model: sonnet
---

# Agentic Docs Tier 2 - Component Repository Documentation

## 🚨 MANDATORY EXECUTION CHECKLIST - READ THIS FIRST 🚨

**⚠️ BLOCKING REQUIREMENT: You MUST complete ALL critical phases marked with ⭐**

**DO NOT proceed to next phases without completing these:**

### ⭐ CRITICAL PHASE 2.5: Domain Discovery (REQUIRED: ≥4 concepts)
**WHAT:** Identify ALL types of domain concepts (not just CRDs!)
- [ ] **CHECK REFERENCE DOCS FIRST** (Phase 1 Step 4.5): _____________ (location if found)
- [ ] If reference found: list ALL concepts from reference domain/ → _____________
- [ ] API Resources (CRDs): _____________ (list them)
- [ ] Technologies (rpm-ostree, OVN, etc.): _____________ (list them)  
- [ ] Data Formats (Ignition, schemas): _____________ (list them)
- [ ] Abstractions (rendered config, etc.): _____________ (list them)
- [ ] Security/Reliability files needed? (Step 6 detection) → _____________
- [ ] **VERIFY: Total ≥4 concepts?** Current count: _____
- [ ] **CROSS-CHECK: If reference exists, verify no concepts missed**
- [ ] Create domain/ docs for each
- [ ] Mark complete: `bash scripts/check-phase-progress.sh . phase_2.5_domain_discovery mark-complete`

**❌ IF YOU SKIP THIS:** Validation WILL fail. Go to lines 503-739 for detailed checklist.

### ⭐ CRITICAL PHASE 5.2: ADR Extraction (REQUIRED: ≥3 ADRs)
**WHAT:** Extract architectural decisions from existing design docs
- [ ] Read ALL docs in docs/ directory: _____________ (list doc files)
- [ ] Architecture decisions (component structure): _____________ (list them)
- [ ] Technology choices (why this tool): _____________ (list them)
- [ ] Implementation patterns (why this way): _____________ (list them)
- [ ] **VERIFY: Total ≥3 ADRs?** Current count: _____
- [ ] Create decisions/adr-NNNN-*.md for each
- [ ] Mark complete: `bash scripts/check-phase-progress.sh . phase_5.2_adr_extraction mark-complete`

**❌ IF YOU SKIP THIS:** Validation WILL fail. Go to lines 1004-1286 for detailed checklist.

### Why These Minimums Exist

**≥4 Domain Concepts Required Because:**
- Non-trivial components manage multiple things (CRDs + technologies + mechanisms)
- Components with <4 concepts are usually trivial wrappers (don't need full docs)
- You must look beyond just CRDs - include technologies, formats, abstractions

**≥3 ADRs Required Because:**
- Every non-trivial component has made architectural decisions
- Minimum set: (1) Architecture decision, (2) Technology choice, (3) Implementation pattern
- If you can't find 3, you haven't looked in docs/ or git history

**If you can't meet minimums:**
- Either component is trivial (warnings OK, continue anyway)
- Or you haven't searched thoroughly (re-read Phase 2.5 and 5.2 checklists)

---

## 📋 Full Execution Checklist

**Before starting:**
- [ ] Acknowledge you've read the MANDATORY checklist above
- [ ] Understand you MUST complete Phase 2.5 (≥4 concepts) and Phase 5.2 (≥3 ADRs)
- [ ] Review time estimate (90-140 minutes for comprehensive docs)

**During execution:**
- [ ] **Phase 1**: Discovery (5-10 min) - Understand repository structure
- [ ] **Phase 2**: Structure creation (2-3 min) - Run create-structure.sh
- [ ] **Phase 2.5**: Domain discovery (20-30 min) ⭐ CRITICAL - See above
- [ ] **Phase 3**: AGENTS.md (10-15 min) - Create ≤100 line entry point with knowledge graph
  - **⚠️ BLOCK:** Check Phase 2.5 complete before starting
- [ ] **Phase 3.5**: ARCHITECTURE.md (10-15 min) - Populate root-level overview with component diagram
- [ ] **Phase 4**: ecosystem.md (5-10 min) - Link to Tier 1
- [ ] **Phase 5**: Component guides (15-30 min)
  - [ ] [COMPONENT]_DEVELOPMENT.md (always)
  - [ ] [COMPONENT]_TESTING.md (always)
  - [ ] [COMPONENT]_SECURITY.md (if Phase 2.5 Step 6 detected need)
  - [ ] [COMPONENT]_RELIABILITY.md (if Phase 2.5 Step 6 detected need)
- [ ] **Phase 5.2**: ADR extraction (30-45 min) ⭐ CRITICAL - See above
- [ ] **Phase 5.6**: Glossary (10-15 min) - Collect ALL terms from domain/CRDs/technologies
- [ ] **Phase 6**: Architecture docs (10-15 min) - Component internals
  - **⚠️ BLOCK:** Check Phase 5.2 complete before final validation
- [ ] **Phase 7**: Validation (5 min)
  - [ ] Run: `bash scripts/check-phase-progress.sh . check` (verify critical phases ⭐)
  - [ ] Run: `bash scripts/validate-categories.sh . --strict` (enforce minimums)
  - [ ] Fix any issues found
- [ ] **Phase 8**: Comparison (optional) - Compare with previous docs if they exist
- [ ] **Phase 9**: Report results

**If validation fails:**
1. Check `.skill-progress.json` to see which phases were completed
2. Review SKILL.md sections for incomplete phases
3. Re-read checklists for Phase 2.5 (lines 640-876) and Phase 5.2 (lines 1190-1521)
4. Fix issues and re-validate

**Success criteria:**
- ✅ All phases marked complete in `.skill-progress.json`
- ✅ `validate-categories.sh --strict` passes (≥4 domain concepts, ≥3 ADRs)
- ✅ `validate.sh` passes (comprehensive validation)

---

## ⚡ Quick Start - Execution Flow

**Multi-Phase Execution:**
1. **LLM** (Phase 1): Discovery & Assessment
2. **SCRIPT** (Phase 2): Create directory structure
3. **LLM** (Phase 2.5): ⭐ CRITICAL - Identify domain concepts (≥4 required)
4. **LLM** (Phase 3-6): Create lean documentation
5. **LLM** (Phase 5.2): ⭐ CRITICAL - Extract ADRs (≥3 required)
6. **SCRIPT** (Phase 7): Validate compliance
7. **LLM** (Phase 9): Report results

**What You DON'T Do:**
- ❌ Don't manually create directories (script handles this)
- ❌ Don't duplicate Tier 1 content (generic patterns, testing pyramid, etc.)
- ❌ Don't skip Phase 2.5 or Phase 5.2 (validation will catch you!)

**What You DO:**
- ✅ Complete Phase 2.5 (domain discovery) BEFORE creating AGENTS.md
- ✅ Complete Phase 5.2 (ADR extraction) BEFORE final validation
- ✅ Mark phases complete as you go
- ✅ Run validation checks before finishing

Before starting:
- [ ] Run preflight-check.sh to assess repository suitability
- [ ] Review time estimate (90-140 minutes for comprehensive docs)
- [ ] Identify expected minimums (≥4 domain concepts, ≥3 ADRs for non-trivial components)

During execution:
- [ ] **Phase 1**: Discovery (5-10 min) - Understand repository structure
- [ ] **Phase 2**: Structure creation (2-3 min) - Run create-structure.sh
- [ ] **Phase 2.5**: Domain discovery (20-30 min) ⭐ CRITICAL
  - [ ] Check CRDs/API types (vendor/github.com/openshift/api, pkg/apis/)
  - [ ] Check technologies (rpm-ostree, OVN, etc. in pkg/ imports)
  - [ ] Check data formats (Ignition, YAML schemas in pkg/)
  - [ ] Check abstractions (component-specific concepts in pkg/)
  - [ ] Create ≥4 domain concept docs
  - [ ] Mark progress: `bash scripts/check-phase-progress.sh . phase_2.5_domain_discovery mark-complete`
- [ ] **Phase 3**: AGENTS.md (10-15 min) - Create ≤100 line entry point
- [ ] **Phase 4**: ecosystem.md (5-10 min) - Link to Tier 1
- [ ] **Phase 5**: Component guides (15-20 min) - [COMPONENT]_DEVELOPMENT.md and [COMPONENT]_TESTING.md
- [ ] **Phase 5.2**: ADR extraction (30-45 min) ⭐ CRITICAL
  - [ ] Read all design docs in docs/ (ls docs/*Design.md docs/*.md)
  - [ ] Extract architectural decisions (why component structured this way)
  - [ ] Extract technology choices (why this tool/format)
  - [ ] Extract implementation decisions (why this approach)
  - [ ] Create ≥3 ADR docs (decisions/adr-NNNN-*.md)
  - [ ] Mark progress: `bash scripts/check-phase-progress.sh . phase_5.2_adr_extraction mark-complete`
- [ ] **Phase 6**: Architecture docs (10-15 min) - Component internals
- [ ] **Phase 7**: Validation (5 min)
  - [ ] Run: `bash scripts/check-phase-progress.sh . check` (verify critical phases)
  - [ ] Run: `bash scripts/validate-categories.sh . --strict` (enforce minimums)
  - [ ] Fix any issues found
- [ ] **Phase 8**: Comparison (optional) - Compare with previous docs if they exist
- [ ] **Phase 9**: Report results

**If validation fails:**
1. Check `.skill-progress.json` to see which phases were completed
2. Review SKILL.md sections for incomplete phases
3. Re-read checklists for Phase 2.5 (lines 455-672) and Phase 5.2 (lines 955-1236)
4. Fix issues and re-validate

**Success criteria:**
- ✅ All phases marked complete in `.skill-progress.json`
- ✅ `validate-categories.sh --strict` passes (≥4 domain concepts, ≥3 ADRs)
- ✅ `validate.sh` passes (comprehensive validation)

---

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

**Development mode:** If Tier 1 doesn't exist yet, you'll get a warning but can proceed

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

### Tier 2 (Component Repos): <component-name>/agentic/
**Purpose:** Component-specific knowledge unique to THIS component

**Contains:**
- Component domain concepts (e.g., MachineConfig, AuthenticationOperator, OVNKubernetesConfig)
- Component architecture (e.g., MCD/MCC/MCS, CNO daemonsets, installer stages)
- Component-specific ADRs (e.g., why rpm-ostree, why OVN-Kubernetes, why assisted-installer)
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
| Component-specific concept | **Tier 2** | MachineConfig (MCO), OAuthClient (authentication), Install (installer) |
| Component architecture | **Tier 2** | MCD/MCC/MCS (MCO), CNO daemonsets (CNO), installer stages (installer) |
| Component-specific decision | **Tier 2** | Why rpm-ostree (MCO), why OVN (CNO), why agent-based (installer) |
| Component work tracking | **Tier 2** | Active features per component |

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
# Checks: AGENTS.md ≤100 lines, no generic duplication, ecosystem.md exists, etc.
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
# - Component-specific content to KEEP (component CRDs, component architecture)
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
# 3. validate-categories.sh → Verify Tier 2 compliance (flexible)
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

### Phase 1: Discovery & Assessment

**Goal:** Discover existing structure and understand the component repository

**Actions:**

**Step 1: Run Discovery Script**
```bash
# Find the skill directory
SKILL_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-tier2" -type d | head -1)
REPO_PATH="${provided_path:-$PWD}"

# Run discovery to learn what exists
bash "$SKILL_DIR/scripts/discover.sh" "$REPO_PATH"
```

**What discovery does:**
- Checks if agentic/ directory exists
- Counts files by category
- Checks for AGENTS.md entry point
- Verifies Tier 1 integration (references/ecosystem.md)
- Suggests commonly missing files
- Warns about generic content (should be in Tier 1)

**Step 2: Determine Mode**
```bash
# Based on discovery:
if [ ! -d "$REPO_PATH/agentic" ]; then
    MODE="create"  # Create from scratch
else
    MODE="fill-gaps"  # Update existing
    bash "$SKILL_DIR/scripts/fill-gaps.sh" "$REPO_PATH"
fi
```

**Step 3: Verify this is an OpenShift component repo**
```bash
# Check if go.mod contains openshift dependencies
if grep -q "github.com/openshift" go.mod 2>/dev/null; then
    echo "✅ OpenShift component repository detected"
else
    echo "⚠️  Not an OpenShift repo - consider using full agentic-docs-maintainer instead"
    exit 1
fi
```

**Step 4: Verify Tier 1 exists (development mode: warning only)**
```bash
# Check if enhancements/agentic/ is accessible
TIER1_URL="https://github.com/openshift/enhancements/tree/master/agentic"
if curl -s -o /dev/null -w "%{http_code}" "$TIER1_URL" | grep -q "200"; then
    echo "✅ Tier 1 documentation exists"
else
    echo "⚠️  Tier 1 not found yet (development mode) - will reference when available"
    echo "   Tier 2 docs will be created with placeholders for Tier 1 links"
    # Don't exit - allow proceeding during development
fi
```

**Step 4.5: Check for Existing Reference Docs (CRITICAL)**
```bash
# Check if user has existing docs in alternate location (common: /tmp/$(basename $REPO_PATH))
REFERENCE_DOCS=""
for candidate in "/tmp/$(basename $REPO_PATH)" "$(dirname $REPO_PATH)/tmp/$(basename $REPO_PATH)"; do
    if [ -d "$candidate/agentic" ]; then
        REFERENCE_DOCS="$candidate/agentic"
        echo "⚠️  FOUND REFERENCE DOCS: $REFERENCE_DOCS"
        echo "   Will use to ensure completeness (all domain concepts, security/reliability)"
        break
    fi
done
```

**If reference docs found:**
- Note location for Phase 2.5 (use to verify ALL concepts covered)
- Use in Phase 5 (extract security/reliability component-specific content)
- Use for completeness check (ensure nothing missed)

**Step 5: Identify component:**
- Component name from repo name
- Main purpose (1 sentence)
- Key concepts (3-5)
- Related components

**Output:** Component profile for documentation + gaps identified + reference docs location

### Phase 2: Create Lean Tier 2 Structure

**Goal:** Create directory structure optimized for Tier 2

**Actions - Run structure script:**
```bash
# Find the skill directory
SKILL_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-tier2" -type d | head -1)
REPO_PATH="${provided_path:-$PWD}"

# Create lean Tier 2 structure
bash "$SKILL_DIR/scripts/create-structure.sh" "$REPO_PATH"
```

**What the script does:**
- Verifies this is an OpenShift component repo (checks go.mod)
- Creates lean directory tree: domain/, architecture/, decisions/, exec-plans/, references/
- Creates skeleton files: AGENTS.md, ARCHITECTURE.md, index.md files
- Creates component-specific guide templates

**Expected structure:**
```
component-repo/
├── AGENTS.md                           [~60-100 lines, LEAN]
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

### Phase 2.5: Understand What Domain Concepts to Document

**CRITICAL:** Before creating any documentation, understand what belongs in `domain/`

Domain concepts are NOT just API resources (CRDs). They include:

#### 1. API Resources (Kubernetes CRDs/Types)

**What**: Custom Resource Definitions your component manages

**Examples by component**:
- **MCO**: MachineConfig, MachineConfigPool, MachineConfigNode, ControllerConfig, MachineOSConfig, MachineOSBuild
- **CNO**: Network, ClusterNetwork, EgressNetworkPolicy
- **Storage**: StorageClass, PersistentVolume, CSIDriver
- **Auth**: OAuth, OAuthClient, Identity

**How to find**: Look in `vendor/github.com/openshift/api/{component}/` or `pkg/apis/`

#### 2. Underlying Technologies (Tools/Platforms Your Component Uses)

**What**: Technologies, tools, or platforms your component wraps or integrates with

**Examples by component**:
- **MCO**: Ignition (provisioning format), rpm-ostree (OS updates), RHCOS (operating system)
- **CNO**: OVN (network virtualization), OpenvSwitch (virtual switch)
- **Storage**: Ceph (storage backend), NFS (file protocol)
- **Auth**: OAuth 2.0 (protocol), LDAP (directory)
- **Installer**: Terraform (infrastructure provisioning), cloud provider APIs

**How to find**: 
- Look for `import` statements in code - what external tools are called?
- Check `/docs/` for design docs mentioning technologies
- Look for CLI commands executed (e.g., `rpm-ostree`, `ovn-nbctl`, `terraform`)

#### 3. Component-Specific Data Formats

**What**: File formats, configuration schemas, or data structures unique to your component

**Examples by component**:
- **MCO**: Ignition v3 config format, MachineConfig Ignition wrapper
- **Installer**: install-config.yaml structure, platform-specific manifests
- **CNO**: Multus network attachment definitions
- **Monitoring**: PrometheusRule format, AlertmanagerConfig

**How to find**:
- Look for serialization code (JSON, YAML marshaling)
- Check for schema validation functions
- Look in `/docs/` for format specifications

#### 4. Domain-Specific Concepts (Abstractions Your Component Introduces)

**What**: Logical concepts or abstractions your component creates

**Examples by component**:
- **MCO**: "Rendered config" (merged MachineConfigs), "On-cluster layering" (build concept)
- **CNO**: "Network segmentation", "Egress IP", "Hybrid networking"
- **CVO**: "Release payload", "Operator ordering", "Update graph"
- **Auth**: "Identity provider", "User identity mapping"

**How to find**:
- Look for unique terminology in design docs
- Check for abstractions that don't map 1:1 to Kubernetes resources
- Look for workflow concepts that span multiple resources

#### Decision Matrix: Should This Be in domain/?

Use this matrix to decide if a concept belongs in your Tier 2 domain/ directory:

| Question | If YES → | If NO → |
|----------|----------|---------|
| **Is your component the PRIMARY user in OpenShift?** | Document in Tier 2 | Link to Tier 1 or skip |
| **Is this concept specific to your component?** | Document in Tier 2 | Link to Tier 1 |
| **Would another component need to duplicate this doc?** | Belongs in Tier 1 | Document in Tier 2 |
| **Is this a Kubernetes/OpenShift platform concept?** | Link to Tier 1 | Document in Tier 2 |

**Examples**:

| Concept | Component | PRIMARY User? | Where? |
|---------|-----------|---------------|--------|
| **Ignition** | MCO | YES (only MCO generates/serves it) | Tier 2 MCO domain/ |
| **Pod** | All operators | NO (everyone uses Pods) | Tier 1 kubernetes/ |
| **rpm-ostree** | MCO | YES (only MCO calls rpm-ostree) | Tier 2 MCO domain/ |
| **etcd** | All operators | NO (many components use etcd) | Tier 1 (or link to external docs) |
| **OVN** | CNO | YES (only CNO manages OVN) | Tier 2 CNO domain/ |
| **ClusterOperator** | All operators | NO (all operators report status) | Tier 1 openshift/ |
| **Terraform** | Installer | YES (only installer uses Terraform) | Tier 2 Installer domain/ |
| **OAuth 2.0** | Auth | YES (only auth implements OAuth) | Tier 2 Auth domain/ |

#### What NOT to Document in domain/

❌ **Generic Kubernetes concepts** → Link to Tier 1 kubernetes/
- Pod, Node, Service, Deployment, etc.

❌ **Generic OpenShift platform concepts** → Link to Tier 1 openshift/
- ClusterOperator, ClusterVersion, Infrastructure, etc.

❌ **Generic operator patterns** → Link to Tier 1 operator-patterns/
- controller-runtime, status conditions, webhooks, etc.

❌ **Cross-component technologies** → Link to Tier 1 or external docs
- etcd (if used by many components)
- Prometheus (if used by many components)

#### Action: Create Domain Concept List

Before proceeding to Phase 3, create a list:

**Step 1: Identify CRDs**
```bash
# Find CRD type definitions
find vendor/github.com/openshift/api/ -name "*_types.go" | grep {component}
# OR
find pkg/apis/ -name "*_types.go"
```

**Step 2: Identify Technologies**
```bash
# Search for external command execution
grep -r "exec.Command" pkg/ | grep -v vendor

# Search for technology mentions in design docs
ls docs/*Design.md docs/*.md
```

**Step 3: List Domain Concepts**

Create a checklist. *Example checklist for machine-config-operator (adapt for your component):*

```
Domain concepts to document:
□ API Resources:
  □ MachineConfig
  □ MachineConfigPool
  □ ControllerConfig
  □ MachineOSConfig
  □ MachineOSBuild
  □ MachineConfigNode
  
□ Technologies:
  □ Ignition (provisioning format)
  □ rpm-ostree (OS update tool)
  □ RHCOS (operating system platform)
  
□ Data Formats:
  □ Ignition v3 config structure (how MCO generates it)
  
□ Abstractions:
  □ "Rendered config" (how MCO merges configs)
  □ "On-cluster layering" (how MCO builds custom OS images)
```

**Step 4: Focus Each Doc**

For each domain concept, focus on COMPONENT-SPECIFIC usage:

**Example - Ignition in MCO domain/**:
- ✅ How MCO generates Ignition from MachineConfig
- ✅ How MachineConfigServer serves Ignition
- ✅ MCO-specific Ignition sections (MCD bootstrap file)
- ❌ General Ignition spec (link to coreos.github.io/ignition instead)

**Example - rpm-ostree in MCO domain/**:
- ✅ MCO's specific rpm-ostree commands (rebase, status)
- ✅ How MCD orchestrates rpm-ostree updates
- ✅ MCO's integration with rpm-ostree (pkg/daemon/rpm-ostree.go)
- ❌ General rpm-ostree internals (link to coreos.github.io/rpm-ostree)

**Step 5: Comprehensive Discovery - CRITICAL MINIMUMS**

Before proceeding to Phase 3, ensure you have discovered SUFFICIENT concepts:

**MINIMUM TARGETS for non-trivial components:**
- ✅ **≥4 domain concepts** (combination of CRDs + technologies + formats + abstractions)
- ✅ **ALL user-facing CRDs** documented (check vendor/github.com/openshift/api/)
- ✅ **ALL configuration CRDs** documented (ControllerConfig, OperatorConfig, etc.)
- ✅ **Primary technology/platform** documented (what the component manages: OS, network, storage, etc.)
- ✅ **At least 1 core mechanism** documented (update system, config format, etc.)

**Discovery Checklist - Use This:**

```markdown
DOMAIN CONCEPT DISCOVERY CHECKLIST:

□ STEP 1: CRD Discovery (ALL types)
  □ Find ALL types: find vendor/github.com/openshift/api -name "*_types.go" -exec grep "^type.*struct" {} \;
  □ User-facing CRDs (resources users create): __________
  □ Configuration CRDs (*Config types): __________
  □ Pool/Group CRDs (*Pool, *Group, *Set): __________
  □ Status/State types (if complex): __________
  
□ STEP 2: Managed Resource Discovery (CRITICAL)
  □ What does this component CONTROL/MANAGE? __________
  □ Examples by type:
    - Infrastructure: VMs, nodes, networks, load balancers
    - Configuration: Operating systems, runtimes, kernels
    - Service: Databases, caches, message queues
    - Platform: OS (RHCOS), network fabric (OVN), storage backend (Ceph)
  □ Is this documented in domain/? __________
  
□ STEP 3: Core Technology Discovery
  □ Check imports: grep -r "exec.Command\|syscall\|external" pkg/ | head -20
  □ Check design docs: ls docs/*Design.md docs/*.md
  □ Technologies identified: __________
  □ Which are PRIMARY to this component (not generic)? __________
  
□ STEP 4: Configuration Format Discovery
  □ Custom formats (Ignition, Containerfile, custom YAML): __________
  □ Serialization code (JSON/YAML marshal/unmarshal): __________
  
□ STEP 5: Domain Abstraction Discovery  
  □ Unique terminology in README/docs: __________
  □ Workflows that span multiple resources: __________
  □ Concepts with no direct CRD mapping: __________

□ STEP 6: Security/Reliability File Detection (CRITICAL)
  □ Privileged containers? grep -r "privileged: true" manifests/ → __________
  □ Custom RBAC (>3 files)? ls manifests/*rbac*.yaml | wc -l → __________
  □ Host access? grep -r "hostNetwork\|hostPID\|hostIPC" manifests/ → __________
  □ **Decision**: [COMPONENT]_SECURITY.md needed? YES/NO (if any above = YES, create it)
  
  □ Metrics exposed? grep -r "prometheus\|metric" pkg/ | wc -l → __________
  □ SLOs in docs? grep -r "SLO\|SLA\|availability" docs/ → __________
  □ Alerts defined? find . -name "*alert*.yaml" -o -name "*rule*.yaml" → __________
  □ **Decision**: [COMPONENT]_RELIABILITY.md needed? YES/NO (if any above = YES, create it)
  
  □ Reference docs found (Step 4.5)? If YES:
    □ Read SECURITY.md → extract ONLY component-specific threats
    □ Read RELIABILITY.md → extract ONLY component-specific SLOs/metrics
    □ Skip generic content (STRIDE framework, SLO concept → link to Tier 1)

□ VALIDATION: Minimum Requirements Met
  □ Total concepts ≥4? Current count: __________
  □ All CRDs covered (including config types)? __________
  □ Managed resource documented? __________
  □ At least 1 technology/mechanism? __________
  
□ CROSS-CHECK with Reference Docs (if found in Step 4.5):
  □ Count concepts in reference: ls $REFERENCE_DOCS/domain/concepts/*.md | wc -l → __________
  □ Missing concepts? diff <(ls $REFERENCE_DOCS/domain/concepts/) <(ls agentic/domain/) → __________
  □ If missing concepts found → add them to checklist above
```

**If validation fails:** Go back to Steps 1-5 and discover missing concepts.

**Common Missed Concepts:**
1. **Configuration CRDs**: ControllerConfig, OperatorConfig, ClusterConfig
2. **Managed Resources**: The actual thing being controlled (OS, network, storage platform)
3. **Core Technologies**: rpm-ostree, Ignition, OVN, Terraform, OAuth, Ceph
4. **Abstractions**: "Rendered config", "Release payload", "Network segmentation"

**Cross-check with docs/:**
```bash
# Mine docs/ for concepts
grep -h "^## " docs/*.md | cut -d' ' -f2- | sort -u

# If docs/ has 10+ sections but you only have 3 domain concepts → investigate
```

---

### ✅ Example: Successful Phase 2.5 Completion

**Here's what successful domain discovery looks like (machine-config-operator example):**

```markdown
PHASE 2.5: DOMAIN DISCOVERY COMPLETE ✅

Component: machine-config-operator
Repository: /home/user/machine-config-operator
Reference Docs: /tmp/machine-config-operator/agentic (FOUND - used for completeness check)

Domain Concepts Identified:

1. API Resources (CRDs) - 5 concepts:
   ✅ MachineConfig (user-facing CRD)
   ✅ MachineConfigPool (grouping CRD)
   ✅ ControllerConfig (configuration CRD)
   ✅ MachineOSConfig (layering CRD)
   ✅ KubeletConfig (high-level API)

2. Technologies - 3 concepts:
   ✅ rpm-ostree (OS update mechanism) → domain/rpm-ostree.md
   ✅ Ignition (provisioning format) → domain/ignition.md
   ✅ RHCOS (operating system platform) → domain/rhcos.md

3. Data Formats - 1 concept:
   ✅ Ignition v3 config structure (MCO-specific rendering) → covered in ignition.md

4. Abstractions - 2 concepts:
   ✅ Rendered config (config merging concept) → domain/rendered-config.md
   ✅ On-cluster layering (build abstraction) → covered in machine-os-layering.md

TOTAL: 11 concepts identified
DOCUMENTED: 8 domain docs created (some concepts combined)
MINIMUM MET: ✅ (≥4 required, have 8)

Files Created:
- agentic/domain/machineconfig.md
- agentic/domain/machineconfigpool.md
- agentic/domain/controllerconfig.md
- agentic/domain/machine-os-layering.md
- agentic/domain/kubeletconfig.md
- agentic/domain/rpm-ostree.md
- agentic/domain/ignition.md
- agentic/domain/rhcos.md

Marking phase complete:
$ bash scripts/check-phase-progress.sh . phase_2.5_domain_discovery mark-complete
✅ Phase 2.5 marked complete in .skill-progress.json

Ready to proceed to Phase 3 (AGENTS.md creation)
```

**Your output should look similar** - adapt for your component's concepts.

---

### Phase 3: Create Lean AGENTS.md

---
## 🚨 BLOCKING CHECKPOINT: Phase 2.5 Required

**BEFORE starting Phase 3, verify Phase 2.5 is complete:**

```bash
# Check if Phase 2.5 was marked complete
if ! grep -q "phase_2.5_domain_discovery.*complete" .skill-progress.json 2>/dev/null; then
    echo "❌ BLOCKED: Phase 2.5 (Domain Discovery) NOT COMPLETE"
    echo ""
    echo "   You MUST complete Phase 2.5 before creating AGENTS.md"
    echo "   Required: ≥4 domain concepts (CRDs + technologies + formats + abstractions)"
    echo ""
    echo "   Go back to Phase 2.5 checklist (lines 640-876)"
    echo "   Or see MANDATORY CHECKLIST at top of this file"
    exit 1
fi

# Verify minimum domain concepts exist
DOMAIN_COUNT=$(find agentic/domain -name "*.md" -not -name "index.md" -not -name "glossary.md" 2>/dev/null | wc -l)
if [ $DOMAIN_COUNT -lt 4 ]; then
    echo "❌ BLOCKED: Only $DOMAIN_COUNT domain concepts found (minimum: 4)"
    echo ""
    echo "   Phase 2.5 requires ≥4 domain concept documents"
    echo "   Current: $DOMAIN_COUNT concepts"
    echo "   Required: 4+ concepts (CRDs + technologies + formats + abstractions)"
    echo ""
    echo "   Go back and complete Phase 2.5 (lines 640-876)"
    exit 1
fi

echo "✅ Phase 2.5 complete: $DOMAIN_COUNT domain concepts documented"
```

**Manual check if scripts unavailable:**
- [ ] Have you created ≥4 domain concept docs in agentic/domain/?
- [ ] Did you include CRDs, technologies, formats, AND abstractions?
- [ ] Did you mark Phase 2.5 complete?

**If NO to any:** Stop and go back to Phase 2.5 (lines 640-876)

---

**Goal:** Create entry point ≤100 lines with knowledge graph + navigation + exec-plans guidance

**Template (Knowledge Graph Structure):**
```markdown
# [component-name] - Agent Navigation & Knowledge Graph

> **OpenShift Platform**: [enhancements/agentic](https://github.com/openshift/enhancements/tree/master/agentic)  
> **[Component] Enhancements**: [enhancements/[component]](https://github.com/openshift/enhancements/tree/master/enhancements/[component])

## Knowledge Graph

```
                    ┌──────────────────────┐
                    │   AGENTS.md (START)  │
                    └──────────┬───────────┘
                               │
            ┌──────────────────┼──────────────────┐
            ▼                  ▼                  ▼
    ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
    │   DOMAIN     │  │ ARCHITECTURE │  │  DECISIONS   │
    │ [List top    │  │ Components   │  │  Why we      │
    │  3-4 key     │  │ [Diagram]    │  │  chose this  │
    │  concepts]   │  │              │  │              │
    └──────┬───────┘  └──────┬───────┘  └──────┬───────┘
           │                 │                  │
           ▼                 ▼                  ▼
    agentic/domain/   agentic/architecture/  agentic/decisions/
```

**Quick Lookup by Task**:
- **Understand**: [ARCHITECTURE.md](./ARCHITECTURE.md) → [domain/](./agentic/domain/)
- **Plan feature**: Create [exec-plan](./agentic/exec-plans/active/) → [DEVELOPMENT.md](./agentic/[COMPONENT]_DEVELOPMENT.md)
- **Implement**: Follow exec-plan → [domain/](./agentic/domain/) → [architecture/](./agentic/architecture/)
- **Debug**: [ARCHITECTURE.md](./ARCHITECTURE.md) → [TESTING.md](./agentic/[COMPONENT]_TESTING.md)
- **Generic patterns**: [Tier 1](https://github.com/openshift/enhancements/tree/master/agentic)

## [Component] Concepts

| Concept | Purpose | Docs |
|---------|---------|------|
| [Concept1] | [1-line] | [domain/concept1.md](./agentic/domain/concept1.md) |
| [Concept2] | [1-line] | [domain/concept2.md](./agentic/domain/concept2.md) |
[... 3-4 key concepts total]

## [Component] Architecture

```
[Simple ASCII diagram showing components]
[Example: Operator → Controller → Daemon → Nodes]
```

→ See [ARCHITECTURE.md](./ARCHITECTURE.md) for details

## Key Decisions (ADRs)

- [adr-0001-[decision]](./agentic/decisions/adr-0001-[decision].md) - Why [technology choice]
- [adr-0002-[decision]](./agentic/decisions/adr-0002-[decision].md) - Why [architecture pattern]
[... 2-3 key ADRs]

## Development Quick Start

```bash
make build     # Build
make test      # Test
```

→ [DEVELOPMENT.md](./agentic/[COMPONENT]_DEVELOPMENT.md) | [TESTING.md](./agentic/[COMPONENT]_TESTING.md)

## Docs

```
agentic/
├── domain/          # CRDs ([list 2-3 key ones])
├── architecture/    # [Component] internals
├── decisions/       # [Component]-specific ADRs
├── exec-plans/      # Feature planning (active/ & completed/)
└── references/      # Tier 1 links
```

## External References

- [OpenShift Patterns](https://github.com/openshift/enhancements/tree/master/agentic/platform)
- [Testing Practices](https://github.com/openshift/enhancements/tree/master/agentic/practices/testing)
- [Ecosystem Links](./agentic/references/ecosystem.md)

---
**Constraint**: ≤100 lines | Component-specific only | Links to Tier 1 for generic | Shows exec-plans/ in structure
```

**Key elements:**
1. **ASCII knowledge graph** showing doc relationships (compact version)
2. **Quick lookup table** by task type (understand/plan feature/implement/debug)
3. **Key concepts table** (3-4 most important, not all)
4. **Component architecture** (simple ASCII diagram)
5. **Key ADRs** (2-3 most important decisions)
6. **Quick start** (build/test commands)
7. **Docs section** showing directory structure (must include exec-plans/)
8. **External references** (links to Tier 1)

**Rules:**
- ✅ ≤100 lines (vs 150 for Tier 1)
- ✅ Knowledge graph shows relationships
- ✅ Task-based navigation (understand/implement/debug)
- ❌ NO detailed explanations (link instead)
- ❌ NO generic patterns (link to Tier 1)

**I need to understand the system**
→ [ARCHITECTURE.md](./ARCHITECTURE.md)
→ [Domain Concepts](./agentic/domain/)
→ [Component Architecture](./agentic/architecture/)

**I'm implementing a feature**
1. Read [ARCHITECTURE.md](./ARCHITECTURE.md) first
2. Check [domain concepts](./agentic/domain/) relevant to feature
3. **Create exec-plan** in [exec-plans/active/](./agentic/exec-plans/active/) - tracks implementation approach
4. Review [platform patterns](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/) for implementation
5. Implement with tests (see [testing guide](./agentic/[COMPONENT]_TESTING.md))
6. Move exec-plan to [exec-plans/completed/](./agentic/exec-plans/completed/) when done

**I'm fixing a bug**
→ [Architecture](./ARCHITECTURE.md)
→ [Development Guide](./agentic/[COMPONENT]_DEVELOPMENT.md)
→ [Testing Guide](./agentic/[COMPONENT]_TESTING.md)

**I need to understand a concept**
→ [Domain Concepts](./agentic/domain/)
→ [Glossary](./agentic/references/glossary.md) (if exists)
→ [OpenShift Glossary](https://github.com/openshift/enhancements/blob/master/agentic/references/glossary.md)

**New to OpenShift operators?**
→ [Operator Patterns](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/)
→ [Testing Practices](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/)

## [Component] Concepts

| Concept | Definition | Docs |
|---------|-----------|------|
| [Concept1] | [1-sentence] | [./agentic/domain/concept1.md] |
| [Concept2] | [1-sentence] | [./agentic/domain/concept2.md] |

## [Component] Architecture

```
[Simple ASCII diagram showing component boundaries]
```

See [ARCHITECTURE.md](./ARCHITECTURE.md) for details.

## Development

- **Build**: [build command]
- **Unit tests**: [test command]
- **E2E tests**: [e2e command]
- **Details**: [DEVELOPMENT.md](./agentic/[COMPONENT]_DEVELOPMENT.md)

## External References

- **OpenShift Platform**: [enhancements/agentic](https://github.com/openshift/enhancements/tree/master/agentic)
- **Operator Patterns**: [platform/operator-patterns/](https://github.com/openshift/enhancements/blob/master/agentic/platform/operator-patterns/)
- **Testing Practices**: [practices/testing/](https://github.com/openshift/enhancements/blob/master/agentic/practices/testing/)
- **Tier 1 Integration**: [ecosystem.md](./agentic/references/ecosystem.md)

---

**Constraint**: ≤150 lines. Details in agentic/ or Tier 1.
```

**Rules:**
1. **MUST be ≤150 lines** (lean but useful for AI navigation)
2. **Prominently link to Tier 1** at the top
3. **No generic explanations** - link to Tier 1 instead
4. **Component-specific only** - what makes THIS component unique
5. **Task-based navigation** - "Quick Navigation by Intent" section

**Validation:**
```bash
lines=$(wc -l < AGENTS.md)
if [ $lines -gt 80 ]; then
    echo "❌ AGENTS.md is $lines lines (max 80 for Tier 2)"
    exit 1
fi
```

### Phase 3.5: Populate ARCHITECTURE.md

**Goal:** High-level overview with component diagram (root level, entry point)

**Template:**
```markdown
# [Component] Architecture

## Overview

[1-2 sentences: what component does, how it fits in OpenShift]

## Component Diagram

```
[ASCII art showing main components and data flow]
[Example for MCO:
  Operator → Controller (renders) + Server (boots) → Daemon (applies) → OS
]
```

## Main Components

### [Component 1]
**Purpose**: [1 sentence]  
**Code**: `cmd/[name]/` or `pkg/[name]/`  
**Deep dive**: [agentic/architecture/components.md](./agentic/architecture/components.md)

[Repeat for 2-4 key components]

## Key Concepts

See [AGENTS.md](./AGENTS.md) for concept table, or browse [agentic/domain/](./agentic/domain/)

## Data Flow

[2-3 sentences: how config/data flows through system]

## Documentation

- **Domain concepts**: [agentic/domain/](./agentic/domain/)
- **Architecture details**: [agentic/architecture/](./agentic/architecture/)
- **Decisions**: [agentic/decisions/](./agentic/decisions/)
- **Development**: [agentic/[COMPONENT]_DEVELOPMENT.md](./agentic/[COMPONENT]_DEVELOPMENT.md)
```

**Rules:**
- ✅ Root level (visible before agentic/)
- ✅ 1-2 screens max (~100-150 lines)
- ✅ Component diagram (ASCII art)
- ✅ High-level only
- ❌ NO implementation details

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

#### [COMPONENT]_SECURITY.md (if Step 6 in Phase 2.5 indicated needed)

**Create ONLY if Phase 2.5 Step 6 found:** privileged containers, custom RBAC, host access

**Template:**
```markdown
# [Component] Security

> For security practices: [enhancements/practices/security/](https://github.com/openshift/enhancements/blob/master/agentic/practices/security/)

## [Component]-Specific Threats

**Threat**: [Component-specific threat - e.g., "Malicious MachineConfig injection"]
**Impact**: [What happens]
**Mitigation**: [How component mitigates]

## [Component] RBAC

**Why privileged**: [Explain why this component needs elevated permissions]

[Component-specific RBAC details]

## References

- [Threat Modeling (STRIDE)](https://github.com/openshift/enhancements/blob/master/agentic/practices/security/threat-modeling.md)
```

**Rules:**
- ✅ ONLY component-specific threats (malicious MachineConfig, compromised osImageURL, etc.)
- ❌ NO generic STRIDE explanation (link to Tier 1)
- ✅ Extract from reference docs SECURITY.md if found (Phase 1 Step 4.5)

#### [COMPONENT]_RELIABILITY.md (if Step 6 in Phase 2.5 indicated needed)

**Create ONLY if Phase 2.5 Step 6 found:** metrics, SLOs, alerts

**Template:**
```markdown
# [Component] Reliability

> For reliability practices: [enhancements/practices/reliability/](https://github.com/openshift/enhancements/blob/master/agentic/practices/reliability/)

## [Component] SLOs

**SLO**: [Component-specific target - e.g., "99.9% pool update success rate"]
**Measurement**: [How measured]

## [Component] Metrics

**Metric**: `[component]_specific_metric`
**Purpose**: [What it tracks]

## [Component] Alerts

**Alert**: [Component]AlertName
**Condition**: [When it fires]
**Response**: [What to do]

## References

- [SLO Framework](https://github.com/openshift/enhancements/blob/master/agentic/practices/reliability/slo-framework.md)
```

**Rules:**
- ✅ ONLY component-specific SLOs, metrics, alerts
- ❌ NO generic SLO framework explanation (link to Tier 1)
- ✅ Extract from reference docs RELIABILITY.md if found (Phase 1 Step 4.5)

### Phase 5.2: Extract Component-Specific ADRs

**Goal:** Identify architectural decisions from existing design docs and create ADRs

**Why this matters:**
Component repositories often have design docs (e.g., `/docs/MachineOSBuilderDesign.md`) that contain architectural decisions but aren't in ADR format. Extract these into structured ADRs for agent discoverability.

**Actions:**

**Step 1: Discover existing design docs**
```bash
# Find design documentation
ls docs/*Design.md docs/*ADR.md docs/*.md 2>/dev/null
```

**Step 2: Read and analyze design docs**
For each design doc found:
1. Read the document
2. Identify architectural decisions (sections with "Why X instead of Y", "Alternatives Considered", "Design Decision")
3. Determine if decision is component-specific or cross-repo

**Step 3: Decision Matrix - Tier 1 vs Tier 2**

| Decision Type | Where | Example |
|---------------|-------|---------|
| **Component-specific** | **Tier 2 (create ADR here)** | Why MCO uses rpm-ostree, why CNO uses OVN-Kubernetes |
| **Cross-repo** | **Tier 1 (link only)** | Why all operators use controller-runtime |
| **Technology choice for THIS component** | **Tier 2** | Why layering uses Buildah (MCO), why tunneling via Geneve (CNO) |
| **Pattern used by all components** | **Tier 1** | Status condition pattern |

**Quick rule:** "Would another component duplicate this decision?" 
- **NO** → Tier 2 ADR
- **YES** → Link to Tier 1

**Step 4: Create ADR files**

For each component-specific decision, create:
```
agentic/decisions/adr-NNNN-<decision-slug>.md
```

**ADR Format:**
```markdown
---
name: <Decision title>
description: <One-line summary>
type: decision
status: Accepted|Proposed|Deprecated|Superseded
date: YYYY-MM-DD
superseded_by: adr-NNNN (if applicable)
---

# ADR-NNNN: <Decision Title>

## Status

**Accepted** - <Brief status context>

## Context

<What problem needed solving>
<What were the constraints>
<What options were considered>

## Decision

<What was decided>
<Key points of the decision>

## Consequences

### Positive
- <Benefit 1>
- <Benefit 2>

### Negative
- <Tradeoff 1>
- <Tradeoff 2>

### Neutral
- <Implementation detail 1>
- <Integration point 1>

## Implementation

<How this decision is implemented in the codebase>
<Code paths or files affected>

## Alternatives Considered

### <Alternative 1>

**Rejected**: <Why it wasn't chosen>

### <Alternative 2>

**Rejected**: <Why it wasn't chosen>

## Related Decisions

- [ADR-NNNN](./adr-NNNN-<slug>.md) - Related component decision
- [Tier 1 ADR](https://github.com/openshift/enhancements/blob/master/agentic/decisions/adr-NNNN.md) - Related platform decision

## References

- [Design doc](/docs/<DesignDoc>.md)
- [Enhancement](https://github.com/openshift/enhancements/...)
- [External reference](https://...)
```

**Step 5: Create decisions/index.md**

```markdown
# [Component] Architectural Decisions

**Last Updated**: YYYY-MM-DD

## Active Decisions

| ADR | Decision | Status | Date |
|-----|----------|--------|------|
| [ADR-0001](./adr-0001-<slug>.md) | <Title> | Accepted | YYYY-MM-DD |
| [ADR-0002](./adr-0002-<slug>.md) | <Title> | Accepted | YYYY-MM-DD |

## Deprecated/Superseded

| ADR | Decision | Status | Superseded By |
|-----|----------|--------|---------------|
| [ADR-0003](./adr-0003-<slug>.md) | <Title> | Superseded | ADR-0005 |

## Cross-Repo Decisions (Tier 1)

Decisions affecting multiple OpenShift components are tracked in Tier 1:
[enhancements/agentic/decisions/](https://github.com/openshift/enhancements/tree/master/agentic/decisions/)

## Related Tier 1 ADRs

| ADR | Impact on [Component] |
|-----|----------------------|
| [adr-0001-operator-sdk](https://github.com/openshift/enhancements/blob/master/agentic/decisions/adr-0001.md) | <How it affects this component> |
```

**Common Component-Specific Decisions to Extract:**

1. **Technology choices**:
   - Why rpm-ostree? Why Ignition? Why Buildah?
   - Why X storage backend? Why Y protocol?

2. **Architecture patterns**:
   - Why daemon on every node? Why centralized controller?
   - Why client-server vs peer-to-peer?

3. **Data models**:
   - Why this CRD structure? Why these API groups?

4. **Operational patterns**:
   - Why update strategy X? Why rollback mechanism Y?

**Examples from machine-config-operator:**

From `docs/OSUpgrades.md` → Extract:
- ADR-0001: Use rpm-ostree for OS updates
- ADR-0006: Apply OS updates before kubelet

From `docs/MachineOSBuilderDesign.md` → Extract:
- ADR-0004: On-cluster layering via MachineOSBuilder
- ADR-0005: Use Buildah for image builds

From `docs/NodeDisruptionPolicy.md` → Extract:
- ADR-0007: Node disruption policy for non-reboot updates

**Rules:**
- ✅ Extract from existing `/docs/` design documents
- ✅ Component-specific decisions ONLY
- ❌ NO cross-repo decisions (those belong in Tier 1)
- ✅ Use standard ADR format for consistency
- ✅ Create index for navigation
- ❌ Don't duplicate decisions already in Tier 1

**Step 6: Comprehensive ADR Discovery - CRITICAL MINIMUMS**

**MINIMUM TARGET for non-trivial components: ≥3 ADRs**

Use this systematic discovery process:

**ADR DISCOVERY CHECKLIST:**

```markdown
ARCHITECTURAL DECISION DISCOVERY:

□ CATEGORY 1: Component Architecture Decisions
  □ Why this component split? (operator + controller + daemon + server)
    Example: Why MCO has autonomous daemon vs SSH-based updates
  □ Why this deployment type? (DaemonSet vs Deployment vs StaticPod)
  □ Why this pattern? (reconciliation loop vs event-driven vs imperative)
  □ Why this structure? (monolithic vs microservices)
  ADRs needed: __________

□ CATEGORY 2: Technology/Format Choices  
  □ Why this configuration format? (Ignition vs cloud-init, JSON vs YAML)
    Examples: Ignition for nodes (MCO), OVN northbound DB schema (CNO)
  □ Why this update mechanism? (image-based vs package-based)
    Examples: rpm-ostree for OS (MCO), image pull for operators (CVO)
  □ Why this storage? (CRD vs ConfigMap vs etcd vs file)
  □ Why this protocol/API? (gRPC vs REST vs custom)
  ADRs needed: __________

□ CATEGORY 3: Pattern/Implementation Decisions
  □ Why this state management? (cached vs always-fetch)
  □ Why this update strategy? (progressive vs all-at-once)
    Examples: Progressive rollout (MCO), canary releases (CVO)
  □ Why this error handling? (retry vs fail-fast vs degrade)
  □ Why this rollback approach? (automatic vs manual)
    Examples: Automatic on boot failure (MCO), manual operator rollback (CVO)
  ADRs needed: __________

□ CATEGORY 4: Mine Design Docs
  □ Find design docs: ls docs/*Design.md docs/*ADR*.md docs/*.md
  □ For EACH design doc found:
    □ Read for "why" decisions, "alternatives", "trade-offs"
    □ Extract into ADR if component-specific
  Design docs reviewed: __________
  ADRs extracted: __________

□ CATEGORY 5: Git History Analysis
  □ Find architectural commits:
    git log --all --oneline --grep="design\|architecture\|alternative\|why" | head -20
  □ Find major changes:
    git log --all --reverse --oneline | head -10
  □ Find refactoring:
    git log --all --oneline | grep -i "refactor\|redesign\|rewrite" | head -10
  Potential ADRs from git: __________

□ VALIDATION: Minimum Requirements Met
  □ Total ADRs ≥3? Current count: __________
  □ At least 1 architecture ADR (component structure)? __________
  □ At least 1 technology ADR (format/mechanism choice)? __________
  □ Each ADR has: Status, Context, Decision, Alternatives, Consequences? __________
  □ All ADRs are component-specific (not cross-repo)? __________
```

**Common Missed ADRs by Category:**

**Architecture:**
- Why autonomous daemon on nodes vs centralized control
- Why multiple controllers vs single monolithic controller
- Why client-server vs peer-to-peer architecture

**Technology:**
- Why Ignition vs cloud-init (MCO)
- Why rpm-ostree vs yum/dnf (MCO)
- Why OVN vs other SDNs (CNO)
- Why Terraform vs other IaC tools (Installer)

**Pattern:**
- Why snapshot-based rendering vs dynamic references
- Why progressive rollout vs big-bang updates
- Why automatic rollback vs manual intervention

**If you have <3 ADRs:**
1. Re-check docs/ for design rationale
2. Review git log for architectural changes
3. Analyze component structure and ask "why this way?"
4. Check for technology integrations and ask "why this technology?"

**Validation:**
After creating ADRs, check:
```bash
# MUST have at least 3 ADRs for non-trivial components
ADR_COUNT=$(ls agentic/decisions/adr-*.md 2>/dev/null | wc -l)
if [ $ADR_COUNT -lt 3 ]; then
    echo "⚠️  Only $ADR_COUNT ADRs found (minimum: 3)"
    echo "   Review categories above for missed decisions"
fi

# Each ADR should have standard format
grep "^## Status$" agentic/decisions/adr-*.md
grep "^## Context$" agentic/decisions/adr-*.md
grep "^## Decision$" agentic/decisions/adr-*.md
grep "^## Alternatives" agentic/decisions/adr-*.md
grep "^## Consequences" agentic/decisions/adr-*.md
```

---

### ✅ Example: Successful Phase 5.2 Completion

**Here's what successful ADR extraction looks like (machine-config-operator example):**

```markdown
PHASE 5.2: ADR EXTRACTION COMPLETE ✅

Component: machine-config-operator
Repository: /home/user/machine-config-operator

Design Docs Reviewed:
✅ docs/OSUpgrades.md
✅ docs/MachineOSBuilderDesign.md
✅ docs/NodeDisruptionPolicy.md
✅ docs/MachineConfigDaemon.md
✅ docs/MachineConfig.md

Architectural Decisions Extracted:

1. CATEGORY: Architecture Decision
   ✅ ADR-0001: Ignition configuration format
      - Why: Ignition vs cloud-init for node provisioning
      - Source: docs/MachineConfig.md design rationale
      - File: agentic/decisions/adr-0001-ignition-configuration-format.md

2. CATEGORY: Technology Choice
   ✅ ADR-0002: DaemonSet for MachineConfigDaemon
      - Why: DaemonSet vs SSH-based node management
      - Source: docs/MachineConfigDaemon.md architecture
      - File: agentic/decisions/adr-0002-daemonset-for-mcd.md

3. CATEGORY: Technology Choice
   ✅ ADR-0003: rpm-ostree for OS updates
      - Why: rpm-ostree vs yum/dnf for atomic updates
      - Source: docs/OSUpgrades.md design decision
      - File: agentic/decisions/adr-0003-rpm-ostree.md

4. CATEGORY: Implementation Pattern
   ✅ ADR-0004: On-cluster layering via Buildah
      - Why: Buildah for custom OS image builds
      - Source: docs/MachineOSBuilderDesign.md
      - File: agentic/decisions/adr-0004-on-cluster-layering.md

5. CATEGORY: Implementation Pattern
   ✅ ADR-0005: Node disruption policy for selective reboots
      - Why: Allow non-reboot updates for certain changes
      - Source: docs/NodeDisruptionPolicy.md
      - File: agentic/decisions/adr-0005-node-disruption-policy.md

TOTAL: 5 ADRs extracted
MINIMUM MET: ✅ (≥3 required, have 5)

Git History Checked:
✅ Reviewed first 10 commits for architectural decisions
✅ Searched for "design|architecture|alternative" in commit messages
✅ No additional decisions found (covered in design docs)

Created Files:
- agentic/decisions/adr-0001-ignition-configuration-format.md
- agentic/decisions/adr-0002-daemonset-for-mcd.md
- agentic/decisions/adr-0003-rpm-ostree.md
- agentic/decisions/adr-0004-on-cluster-layering.md
- agentic/decisions/adr-0005-node-disruption-policy.md
- agentic/decisions/index.md (ADR index)

Validation:
✅ All ADRs have Status, Context, Decision, Alternatives, Consequences
✅ All decisions are component-specific (not cross-repo)
✅ No duplication of Tier 1 ADRs

Marking phase complete:
$ bash scripts/check-phase-progress.sh . phase_5.2_adr_extraction mark-complete
✅ Phase 5.2 marked complete in .skill-progress.json

Ready to proceed to Phase 6 (Architecture docs)
```

**Your output should look similar** - adapt for your component's decisions.

---

### Phase 5.5: exec-plans for Work Tracking (Optional)

**Goal:** Document how to use exec-plans for tracking active features (optional but recommended)

**What exec-plans are:**
- Living documents that track in-progress features/enhancements
- Move from `active/` to `completed/` when done
- Link to enhancement proposals
- Component-specific implementation plans

**When to create:**
- New feature being implemented
- Enhancement proposal affecting this component
- Major refactoring or architectural change
- Cross-repo feature (component's portion)

**Directory structure (created automatically in Phase 2):**
```
agentic/exec-plans/
├── active/                 # Work in progress
│   ├── feature-xyz.md
│   └── enhancement-123.md
├── completed/              # Archived when done
│   └── old-feature.md
├── template.md             # Template for new exec-plans (auto-created)
└── README.md               # Usage guide (auto-created)
```

**Note:** `template.md` and `README.md` are automatically created by `create-structure.sh`

**Template for exec-plans (`agentic/exec-plans/template.md`):**
```markdown
---
status: active
enhancement: <link to enhancements repo>
owner: @username
target_version: vX.Y
started: YYYY-MM-DD
---

# Plan: [Feature Name]

## Goal
[What we're building - component-specific scope]

## Context
See [enhancement](link) for overall design.
This plan covers ONLY [COMPONENT]-specific implementation.

## Related Components
[Other repos involved, if cross-repo feature]

## Implementation Status
- [ ] Design review
- [ ] API changes
- [ ] Controller implementation
- [ ] Unit tests
- [ ] Integration tests
- [ ] E2E tests
- [ ] Documentation
- [ ] Performance validation

## Blockers
[Any blockers or dependencies]

## Component-Specific Considerations
[What's unique about implementing this in THIS component]

## Testing Strategy
[Component-specific testing approach]

## Rollout Plan
[How this will be deployed/enabled]

## Links
- Enhancement: [link]
- Jira: [link]
- Related ADRs: [link]
```

**Template for tech debt (`agentic/exec-plans/tech-debt-tracker.md`):**
```markdown
# [Component] Technical Debt Tracker

**Last Updated**: YYYY-MM-DD

## High Priority
| Item | Impact | Effort | Owner |
|------|--------|--------|-------|
| [Issue] | [What it affects] | [Estimate] | [@user] |

## Medium Priority
| Item | Impact | Effort | Owner |
|------|--------|--------|-------|

## Low Priority / Future
| Item | Impact | Effort | Owner |
|------|--------|--------|-------|

## Completed (Last 6 Months)
| Item | Completed | PR |
|------|-----------|-----|
```

**Workflow:**
1. **New feature starts:**
   ```bash
   # Copy template (auto-created during Phase 2)
   cp agentic/exec-plans/template.md agentic/exec-plans/active/feature-xyz.md
   
   # Fill in details
   # - Link to enhancement proposal
   # - Component-specific implementation plan
   # - Track progress with checkboxes
   ```

2. **During implementation:**
   ```bash
   # Update status as you go
   # Check off completed items
   # Add blockers as they arise
   # No need to commit every update - these are living docs
   ```

3. **Feature completed:**
   ```bash
   # Move to completed/
   mv agentic/exec-plans/active/feature-xyz.md agentic/exec-plans/completed/
   
   # Update status to "completed"
   # Add completion date
   # Commit the move
   ```

**Important notes:**
- **NOT required for Tier 2 compliance** - exec-plans are optional
- **No validation enforced** - these change frequently
- **Component teams decide** - you know your work best
- **Living documents** - update as needed, don't worry about perfection

**Example exec-plan:**
```markdown
---
status: active
enhancement: https://github.com/openshift/enhancements/blob/master/enhancements/machine-config/custom-os-images.md
owner: @mco-team
target_version: v4.16
started: 2026-03-15
---

# Plan: Custom OS Images (MCO Implementation)

## Goal
Allow users to specify custom OS images for OpenShift nodes.

## Context
See [enhancement](link) for overall design.
This plan covers MCO-specific implementation:
- MachineConfig API extension
- Image validation
- Node update coordination

## Related Components
- installer (initial node images)
- CVO (upgrade coordination)

## Implementation Status
- [x] Design review
- [x] API changes (MachineConfig.spec.osImageURL)
- [x] Controller implementation (pkg/controller/template/)
- [x] Unit tests
- [ ] Integration tests (in progress)
- [ ] E2E tests
- [ ] Documentation
- [ ] Performance validation

## Blockers
- Waiting for installer integration (blocked on installer#1234)

## Component-Specific Considerations
- MCO must validate image before applying to nodes
- Need to coordinate with MCD for image pull
- rpm-ostree requires specific image format

## Testing Strategy
- Unit: Image URL validation logic
- Integration: MachineConfig controller reconciliation
- E2E: Full node update with custom image

## Rollout Plan
- v4.16-alpha: Initial implementation (TechPreview)
- v4.16-GA: Stable after validation

## Links
- Enhancement: https://github.com/openshift/enhancements/pull/1234
- Jira: MCO-567
- Related ADRs: adr-0003-image-validation.md
```

**When to skip exec-plans:**
- New repository (no active work yet)
- Maintenance-only mode (no new features)
- Small bug fixes (not worth tracking)
- Your team prefers other tracking (Jira, GitHub issues, etc.)

**Note on exec-plans:**
Active repositories with ongoing work naturally have exec-plans to track features; new or stable repos don't need to create artificial ones just for the sake of having them. They're a tool for teams that find them useful, not a checklist item.

### Phase 5.6: Create Glossary

**Goal:** Collect ALL terms from domain concepts, CRDs, and technologies (ALWAYS required)

**Process:**

**Step 1: Collect terms from created files**
```bash
# Extract all CRDs from domain/
grep "^#" agentic/domain/*.md | grep -v "##" | cut -d: -f2 | sort -u

# Extract terms from AGENTS.md concepts table
grep "^|" AGENTS.md | cut -d'|' -f2 | tail -n +2 | sort -u
```

**Step 2: For each term, create glossary entry**

Format (alphabetical order):
```markdown
## [Term]

**Definition**: [1-2 sentence definition]  
**Type**: [CRD | Technology | Concept | Component]  
**Related**: [[Related Term 1]], [[Related Term 2]]  
**Details**: [link to detailed doc if exists]
```

**Step 3: Cross-check with reference docs** (if found in Phase 1 Step 4.5):
```bash
# Ensure no component-specific terms missed
if [ -f "$REFERENCE_DOCS/../glossary.md" ]; then
    echo "Cross-checking with reference glossary..."
    # List reference terms, ensure component terms covered
fi
```

**Template (agentic/domain/glossary.md):**
```markdown
# [Component] Glossary

> **Quick reference** for component-specific terms  
> **For platform terms**: [Tier 1 Glossary](https://github.com/openshift/enhancements/blob/master/agentic/references/glossary.md)

## [CRD Name 1]

**Definition**: [1-2 sentences]  
**Type**: CRD (API: machineconfiguration.openshift.io/v1)  
**Related**: [[Related CRD]], [[Related Concept]]  
**Details**: [domain/crd-name-1.md](./crd-name-1.md)

## [Technology 1]

**Definition**: [1-2 sentences - component's use of it]  
**Type**: Technology  
**Related**: [[Related CRD]], [[Component]]  
**Details**: [domain/technology-1.md](./technology-1.md)

## [Component Name]

**Definition**: [1 sentence - what it does]  
**Type**: Component  
**Code**: cmd/[component-name]/  
**Details**: [../architecture/components.md](../architecture/components.md)

[... ALL terms from domain concepts, CRDs, technologies, components]
```

**Rules:**
- ✅ Include ALL domain concepts (from Phase 2.5)
- ✅ Include ALL CRDs managed by component
- ✅ Include ALL technologies component uses
- ✅ Include main components (binaries)
- ✅ Alphabetical order
- ❌ NO generic Kubernetes terms (link to Tier 1 glossary)
- ❌ NO generic OpenShift terms (link to Tier 1 glossary)

**Minimum:** If component has 8 domain concepts, glossary should have ≥8 entries (concepts + related terms)

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

### Phase 6.5: Pre-Validation Gate ⭐ NEW

**Goal:** Verify critical phases completed BEFORE running final validation

**Why this phase exists:**
- Prevents skipping Phase 2.5 (domain discovery) and Phase 5.2 (ADR extraction)
- Catches missing content early before validation
- Provides specific guidance on what's missing

**Actions - Check phase progress:**
```bash
# Find the skill directory
SKILL_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-tier2" -type d | head -1)
REPO_PATH="${provided_path:-$PWD}"

# Check critical phase completion
bash "$SKILL_DIR/scripts/check-phase-progress.sh" "$REPO_PATH" check
```

**What this checks:**
1. **Phase 2.5 (Domain Discovery)** marked complete in `.skill-progress.json`
   - If not complete: Points to SKILL.md lines 455-672
   - Required: ≥4 domain concepts documented
2. **Phase 5.2 (ADR Extraction)** marked complete in `.skill-progress.json`
   - If not complete: Points to SKILL.md lines 955-1236
   - Required: ≥3 ADRs extracted from design docs

**If pre-validation fails:**

```
❌ Phase 2.5: Domain Discovery - NOT COMPLETE
   This phase is CRITICAL (≥4 domain concepts required)
   See SKILL.md lines 455-672 for checklist

❌ Phase 5.2: ADR Extraction - NOT COMPLETE
   This phase is CRITICAL (≥3 ADRs required)
   See SKILL.md lines 955-1236 for checklist
```

**Actions to fix:**
1. Go back to incomplete phase
2. Follow the checklist in SKILL.md
3. Mark phase complete when done:
   ```bash
   bash scripts/check-phase-progress.sh . phase_2.5_domain_discovery mark-complete
   bash scripts/check-phase-progress.sh . phase_5.2_adr_extraction mark-complete
   ```
4. Re-run pre-validation gate

**DO NOT proceed to Phase 7 validation if pre-validation fails!**

The final validation will fail if critical phases are incomplete, so fix issues now.

### Phase 7: Verify Tier 2 Compliance

---
## 🚨 BLOCKING CHECKPOINT: Phase 2.5 AND Phase 5.2 Required

**BEFORE validation, verify BOTH critical phases are complete:**

```bash
# Check Phase 2.5 (Domain Discovery)
if ! grep -q "phase_2.5_domain_discovery.*complete" .skill-progress.json 2>/dev/null; then
    echo "❌ BLOCKED: Phase 2.5 (Domain Discovery) NOT COMPLETE"
    echo "   Required: ≥4 domain concepts"
    echo "   Go to Phase 2.5 checklist (lines 640-876)"
    exit 1
fi

# Check Phase 5.2 (ADR Extraction)
if ! grep -q "phase_5.2_adr_extraction.*complete" .skill-progress.json 2>/dev/null; then
    echo "❌ BLOCKED: Phase 5.2 (ADR Extraction) NOT COMPLETE"
    echo "   Required: ≥3 ADRs from design docs"
    echo "   Go to Phase 5.2 checklist (lines 1190-1521)"
    exit 1
fi

# Verify minimums
DOMAIN_COUNT=$(find agentic/domain -name "*.md" -not -name "index.md" -not -name "glossary.md" 2>/dev/null | wc -l)
ADR_COUNT=$(find agentic/decisions -name "adr-*.md" -not -name "adr-template.md" 2>/dev/null | wc -l)

echo "✅ Phase 2.5 complete: $DOMAIN_COUNT domain concepts"
echo "✅ Phase 5.2 complete: $ADR_COUNT ADRs"

if [ $DOMAIN_COUNT -lt 4 ]; then
    echo "⚠️  WARNING: Only $DOMAIN_COUNT domain concepts (recommended: ≥4)"
    echo "   For non-trivial components, you should have more"
fi

if [ $ADR_COUNT -lt 3 ]; then
    echo "⚠️  WARNING: Only $ADR_COUNT ADRs (recommended: ≥3)"
    echo "   Check docs/ for missed architectural decisions"
fi
```

**Manual pre-validation check:**
- [ ] Phase 2.5 complete? (≥4 domain concepts created)
- [ ] Phase 5.2 complete? (≥3 ADRs extracted from docs/)
- [ ] Both phases marked in .skill-progress.json?

**If NO to any:** Go back and complete missing phases before validation.

---

**Goal:** Ensure Tier 2 docs are lean and link to Tier 1

**Actions - Run validation script:**
```bash
# Find the skill directory
SKILL_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-tier2" -type d | head -1)
REPO_PATH="${provided_path:-$PWD}"

# Run flexible category-based validation
bash "$SKILL_DIR/scripts/validate-categories.sh" "$REPO_PATH"
```

**What the script checks (FLEXIBLE):**
1. **Categories have content**: domain/, architecture/, decisions/, references/ (min files, not exact list)
2. **Entry point exists**: AGENTS.md or [COMPONENT]_AGENTS.md (warns if too short/long)
3. **Tier 1 integration**: references/ecosystem.md exists and links to Tier 1 (CRITICAL)
4. **Suggests common files**: exec-plans/template.md, adr-template.md, etc. (doesn't fail if missing)
5. **Warns about generic content**: Testing pyramid, operator patterns, etc. (should link to Tier 1)

**Validation is FLEXIBLE:**
- ✅ Fails only if categories missing or Tier 1 link missing
- ⚠️ Warns about size, suggestions, generic content (doesn't fail)
- ℹ️ Reports what's commonly recommended

**Expected metrics:**
- AGENTS.md: ≤100 lines (vs 143 for single-tier)
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
3. ✅ Keep AGENTS.md ≤100 lines
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
- Ensure AGENTS.md still ≤100 lines
- No generic content added
- All Tier 1 links valid
- Component-specific only

CREATE GIT COMMIT:
"docs: update Tier 2 docs for [changes summary]

- [Change 1]
- [Change 2]
- [Change 3]

Tier 2 compliance: ✅
AGENTS.md: X lines (≤100)

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

**Script available:**
```bash
# Use the autonomous maintenance loop script
bash "$SKILL_DIR/scripts/maintenance-loop.sh" "$REPO_PATH" --max-iterations 10
```

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
   Ensure still ≤100 lines (don't add details, link to architecture/)
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
  - AGENTS.md: X lines (target: ≤100)
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
  ✅ AGENTS.md ≤100 lines
  ✅ No generic duplication detected
  ✅ ecosystem.md created with Tier 1 links
  ✅ Component-specific content only

Next Steps:
  1. **Populate domain/ with ALL concept types** (see Phase 2.5):
     - CRDs/API resources (e.g., MachineConfig, MachineConfigPool)
     - Underlying technologies (e.g., Ignition, rpm-ostree, RHCOS)
     - Data formats (e.g., Ignition v3 config structure)
     - Component-specific abstractions (e.g., "rendered config", "on-cluster layering")
  2. Document component architecture (all components and their interactions)
  3. **Extract component-specific ADRs from /docs/ design documents** (see Phase 5.2)
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
  ✅ AGENTS.md: 78 lines (≤100)
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
  ✅ AGENTS.md still ≤100 lines (78 lines)
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
- AGENTS.md ≤ 100 lines (30% reduction from single-tier's 143 lines)
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

## Troubleshooting Content Discovery

This section helps when validation indicates insufficient domain concepts or ADRs.

### Problem: "I only have 2-3 domain concepts but validation says ≥4"

**Root causes and solutions:**

**1. Missed Configuration CRDs**

Configuration types often overlooked:
```bash
# Find all *Config types
find vendor/github.com/openshift/api -name "types.go" -exec grep "Config.*struct" {} \; -print

# Common patterns:
# - ControllerConfig (MCO, others)
# - OperatorConfig (various operators)
# - ClusterConfig (platform config)
```

**Action:** Document each config CRD found (they're component-specific).

**2. Missed Managed Resources**

**Question to answer:** "What external thing does this component modify?"

Examples by component type:
- **Infrastructure operators** → VMs, nodes, networks, load balancers
- **Configuration operators** → Operating system (RHCOS), container runtime (CRI-O)
- **Service operators** → Database clusters, caches, message queues
- **Platform operators** → Network fabric (OVN), storage backends (Ceph)

```bash
# Check what component manages
grep -ri "manages\|controls\|configures" README.md docs/ | head -10

# Check for external command execution (indicates managed technology)
grep -r "exec.Command" pkg/ | grep -v vendor | head -10
```

**Example:** MCO controls **RHCOS** (the operating system itself) - document this even though it's not a Go type in the repo.

**Action:** Create `domain/<managed-resource>.md` focusing on how THIS component interacts with it.

**3. Missed Core Mechanisms/Technologies**

Look for specialized technical systems:
```bash
# Find package names suggesting mechanisms
find pkg/ -type d -maxdepth 2 | grep -E "update|upgrade|render|sync|config|format"

# Examples of mechanisms to document:
# - Update systems: rpm-ostree, apt, image pull
# - Config formats: Ignition, cloud-init, Containerfile
# - State sync: OVN database sync, etcd watches
# - Rendering: Template merging, config generation
```

**Action:** Document 1-2 core mechanisms unique to this component.

**4. Cross-Reference with docs/**

```bash
# Mine existing docs for concepts
grep -h "^## " docs/*.md | cut -d' ' -f2- | sort -u

# If docs/ has 10+ sections but only 3 domain concepts → investigate
```

**Common pattern:** Design docs explain concepts not yet in agentic/domain/

**Action:** For each section in docs/, ask: "Is this a domain concept? Is it component-specific?"

---

### Problem: "I only have 1-2 ADRs but validation says ≥3"

**Common missed ADR categories:**

**1. Component Architecture ADR**

Every multi-component operator has this decision:

**Questions to answer with ADRs:**
- Why split into operator + controller + daemon + server?
- Why DaemonSet vs Deployment? (for node agents)
- Why reconciliation loop vs event-driven?
- Why autonomous agent vs SSH-based? (for node management)

**Example:** MCO has ADR explaining why MachineConfigDaemon is autonomous vs SSH-controlled.

**Where to find:** 
- Check docs/ for architecture explanations
- Check git log for initial architecture commits:
  ```bash
  git log --all --reverse --oneline | head -10
  ```

**2. Technology Choice ADR**

Why did this component choose Technology X over Y?

**Common patterns:**
- Configuration format choice: Why Ignition vs cloud-init?
- Update mechanism: Why rpm-ostree vs yum/dnf?
- Storage choice: Why CRD vs ConfigMap vs file?
- Protocol: Why gRPC vs REST?

**Where to find:**
```bash
# Check imports for external technologies
grep -r "import.*github.com" cmd/ pkg/ | grep -v vendor | cut -d'"' -f2 | sort -u | head -20

# Check design docs
ls docs/*Design.md docs/*.md
```

**Example:** MCO has ADR explaining why rpm-ostree (atomic updates) over yum (incremental).

**3. Pattern/Implementation ADR**

Non-obvious implementation choices:

**Questions to answer:**
- Why progressive rollout vs all-at-once?
- Why snapshot-based rendering vs dynamic references?
- Why automatic rollback vs manual?
- Why cached state vs always-fetch?

**Where to find:**
```bash
# Check for design decisions in docs
find docs/ -name "*.md" -exec grep -l "design\|decision\|alternative\|why\|rationale" {} \;

# Check git history
git log --all --grep="design\|architecture\|alternative" --oneline | head -20
```

**Example:** MCO has ADR explaining snapshot-based rendering (remote content embedded at render time) vs dynamic references.

**4. Check Peer Operators**

Similar operators often have similar ADRs:
- Node agents: cluster-node-tuning-operator
- Network: cluster-network-operator  
- Storage: cluster-storage-operator

Review their agentic/decisions/ for patterns.

---

### Problem: "Validation says I have generic content but I think it's component-specific"

**Test:** Would 3+ other components need to duplicate this explanation?
- **YES** → Generic (belongs in Tier 1, link to it)
- **NO** → Component-specific (keep in Tier 2)

**Generic patterns (link to Tier 1):**
- ❌ Testing pyramid philosophy
- ❌ Controller-runtime reconciliation loop mechanics
- ❌ Status condition semantics (Available/Progressing/Degraded meanings)
- ❌ STRIDE threat model framework
- ❌ SLO framework explanation
- ❌ Generic RBAC patterns

**Component-specific (keep in Tier 2):**
- ✅ How THIS component uses controller-runtime (specific reconcile logic)
- ✅ THIS component's specific status conditions (custom conditions beyond standard)
- ✅ THIS component's threat model (specific threats: malicious MachineConfig, OS image compromise)
- ✅ THIS component's SLOs (specific metrics: `mco_pool_update_duration_seconds`)
- ✅ THIS component's RBAC requirements (specific permissions needed)

**Rule of thumb:** 
- Generic = "What is X?" → Tier 1
- Component-specific = "How does THIS component use X?" → Tier 2

---

### Problem: "I documented everything I can think of but still <4 concepts or <3 ADRs"

**Is this truly a non-trivial component?**

Some components are genuinely simple:
- Thin wrappers around external tools
- Single-purpose utilities
- Small helper operators

**For simple components:**
- 2-3 domain concepts may be sufficient
- 1-2 ADRs may be sufficient
- Validation warnings are OK (not failures)

**For complex components (most operators):**
- Should have ≥4 concepts (CRDs + technologies + mechanisms)
- Should have ≥3 ADRs (architecture + technology + patterns)

**If in doubt:** Compare with peer operators of similar complexity.

---

### Quick Diagnostic Commands

**Discover CRDs:**
```bash
find vendor/github.com/openshift/api -name "*_types.go" -exec grep "^type.*struct" {} \; | wc -l
```

**Find technologies:**
```bash
grep -r "exec.Command" pkg/ | grep -v vendor | cut -d'"' -f2 | sort -u
```

**Find design docs:**
```bash
ls docs/*Design.md docs/*ADR*.md docs/*.md 2>/dev/null
```

**Find architectural commits:**
```bash
git log --all --oneline --grep="design\|architecture\|alternative" | head -10
```

**Check docs/ section count:**
```bash
grep -h "^## " docs/*.md | wc -l
```

**Compare with similar operators:**
```bash
# Example: compare with cluster-node-tuning-operator
ls ../cluster-node-tuning-operator/agentic/domain/
ls ../cluster-node-tuning-operator/agentic/decisions/
```

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
├── AGENTS.md                           [~60-100 lines]
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

## Example: Case Study (machine-config-operator)

*This is one illustrative example. The same approach works for any OpenShift component (CNO, installer, authentication-operator, etc.)*

**Before (Single-Tier):**
- 29 files, 6,000 lines
- AGENTS.md: 143 lines
- 40% generic content (2,400 lines duplicated from other repos)

**After (Tier 2 Lean):**
- 15 files, 2,500 lines (-58%)
- AGENTS.md: 78 lines (-45%)
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
