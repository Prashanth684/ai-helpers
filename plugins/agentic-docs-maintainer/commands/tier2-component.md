---
description: Create lean Tier 2 agentic documentation for OpenShift component repositories
---

## Name
agentic-docs-maintainer:tier2-component

## Synopsis
```
/agentic-docs-maintainer:tier2-component [--path <repo-path>] [--verify] [--extract]
```

## Description
Creates **lean** Tier 2 agentic documentation for OpenShift component repositories that:
- Contains ONLY component-specific knowledge (~60% smaller)
- References Tier 1 (openshift/enhancements/agentic/) for generic patterns
- Eliminates duplication of platform-wide knowledge
- Maintains bi-directional navigation with ecosystem hub

**Parameters:**
- `--path <repo-path>`: Path to component repository (defaults to current directory)
- `--verify`: Verify existing Tier 2 docs for compliance
- `--extract`: Extract component-specific content from existing single-tier docs
- `--maintain`: Ongoing maintenance - sync docs with code changes
- No args: Create new lean Tier 2 structure

## Two-Tier Architecture

### Tier 1: Ecosystem Hub (openshift/enhancements/agentic/)
**Contains:** Platform patterns, engineering practices, cross-repo ADRs, K8s/OpenShift fundamentals
**Example:** Status conditions pattern, testing pyramid, etcd backend decision

### Tier 2: Component Repos (lean)
**Contains:** Component domain concepts, component architecture, component ADRs, exec-plans
**Example:** MachineConfig (MCO-specific), rpm-ostree decision, MCO architecture

**Decision Rule:** "Would another repo need to duplicate this?"
- YES → Tier 1 (enhancements)
- NO → Tier 2 (component)

## What Gets Created

**Lean structure (~2,500 lines vs 6,000 for single-tier):**
```
component-repo/
├── AGENTS.md                      [~60-100 lines, links to Tier 1]
├── ARCHITECTURE.md
└── agentic/
    ├── domain/                    [Component concepts ONLY]
    ├── architecture/              [Component internals]
    ├── decisions/                 [Component ADRs ONLY]
    ├── exec-plans/
    │   ├── active/                [Features being implemented]
    │   └── completed/             [Completed features]
    ├── [COMPONENT]_DEVELOPMENT.md [Lean, component-specific]
    ├── [COMPONENT]_TESTING.md     [Lean, component-specific]
    └── references/
        └── ecosystem.md           [Links to Tier 1 - CRITICAL]
```

## What Gets Removed (moved to Tier 1)

❌ Generic operator patterns (controller-runtime, status conditions)
❌ Testing practices (test pyramid, E2E framework)
❌ Security practices (STRIDE, RBAC guidelines)
❌ Reliability practices (SLO framework, observability)
❌ Kubernetes fundamentals (Pod, Node, Service)

## Examples

### Example 1: Create new Tier 2 docs

```bash
cd machine-config-operator
/agentic-docs-maintainer:tier2-component

# Creates:
# - AGENTS.md (60-100 lines)
# - agentic/domain/, architecture/, decisions/, exec-plans/
# - agentic/references/ecosystem.md (links to Tier 1)
# - MCO_DEVELOPMENT.md, MCO_TESTING.md (lean)
```

### Example 2: Extract from existing single-tier docs

```bash
cd machine-config-operator
/agentic-docs-maintainer:tier2-component --extract

# Process:
# 1. Identifies generic content (testing pyramid, operator patterns)
# 2. Removes generic content (2,400 lines)
# 3. Keeps component-specific (3,600 lines)
# 4. Creates ecosystem.md with Tier 1 links
# 5. Reduces AGENTS.md from 143 → 60 lines
```

### Example 3: Verify Tier 2 compliance

```bash
cd machine-config-operator
/agentic-docs-maintainer:tier2-component --verify

# Checks:
# ✅ AGENTS.md ≤100 lines
# ✅ No generic duplication
# ✅ ecosystem.md exists
# ✅ All Tier 1 links valid
```

## Validation Criteria

**Tier 2 docs pass when:**
- ✅ AGENTS.md ≤ 100 lines
- ✅ Zero generic content duplication
- ✅ ecosystem.md exists with Tier 1 links
- ✅ Component-specific content only
- ✅ No broken links to Tier 1

**Forbidden patterns (belong in Tier 1):**
- "testing pyramid"
- "controller-runtime reconciliation"
- "Available/Progressing/Degraded conditions"
- "STRIDE threat model"
- "SLO error budget"

## Metrics

**Expected reduction from single-tier:**
- AGENTS.md: -58% (143 → 60 lines)
- Total docs: -58% (6,000 → 2,500 lines)
- Generic duplication: -100% (2,400 → 0 lines)
- Context budget: -54% for component tasks

**Ecosystem benefits:**
- Pattern updates: 1 Tier 1 PR vs 60+ component PRs
- Duplication across 60 repos: -97% (144,000 → 4,000 lines)
- Consistency: Immediate (all repos link to same Tier 1)

## Anti-Patterns

### ❌ DON'T duplicate Tier 1 content

**Wrong:**
```markdown
# TESTING.md (187 lines, 60% generic)

## Testing Pyramid
[100 lines explaining pyramid]

## MCO Tests
[37 lines MCO-specific]
```

**Right:**
```markdown
# MCO_TESTING.md (90 lines, 100% MCO-specific)

> Testing practices: [Tier 1](link)

## MCO Tests
[37 lines MCO-specific]
```

### ❌ DON'T create cross-repo ADRs in component

**Wrong:** ADR about etcd in machine-config-operator
**Right:** ADR about etcd in enhancements/agentic/decisions/

### ❌ DON'T explain generic patterns

**Wrong:** Explaining controller-runtime in MCO docs
**Right:** Link to Tier 1, document MCO-specific usage

## Prerequisites

**Before running this command:**
1. ✅ Tier 1 exists at openshift/enhancements/agentic/
2. ✅ Repository is OpenShift component (has openshift dependencies)
3. ✅ You understand two-tier architecture

**If Tier 1 doesn't exist:**
- Create it first using /agentic-docs-maintainer:tier1-ecosystem
- OR use full /agentic-docs-maintainer for standalone repos

## When NOT to Use

**Don't use Tier 2 lean docs if:**
- Repository is standalone (not part of OpenShift ecosystem)
- No Tier 1 hub exists
- Repository prefers self-contained documentation
- Generic patterns don't exist in Tier 1 yet

**Use full agentic-docs-maintainer instead** for standalone repos.

## Implementation

### Mode 1: Create New Tier 2 Structure (Default)

**Step 1: SCRIPT - Create structure**
```bash
SKILL_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-tier2" -type d | head -1)
bash "$SKILL_DIR/scripts/create-structure.sh" "$REPO_PATH"
```

What the script does:
- Creates empty directories (domain/, architecture/, decisions/, references/, exec-plans/)
- Creates exec-plans/template.md for feature planning
- Creates exec-plans/README.md with usage guide

**Step 2: LLM - Create lean documentation**

LLM reads SKILL.md and creates:
- AGENTS.md (~60-100 lines, includes exec-plans/ in structure)
- Component-specific domain concepts
- Component architecture docs
- Component ADRs
- ecosystem.md with Tier 1 links
- Lean [COMPONENT]_DEVELOPMENT.md and [COMPONENT]_TESTING.md

Key principles:
- Component-specific content ONLY
- Links to Tier 1 for generic patterns
- AGENTS.md ≤100 lines
- Guidance on using exec-plans/ for feature planning

**Step 3: SCRIPT - Validate**
```bash
bash "$SKILL_DIR/scripts/validate.sh" "$REPO_PATH/agentic"
```

What the script does:
- Checks AGENTS.md ≤100 lines
- Verifies no generic duplication
- Confirms ecosystem.md exists

---

### Mode 2: Verify Existing Docs (--verify)

**Step 1: SCRIPT - Run validate.sh**
```bash
bash "$SKILL_DIR/scripts/validate.sh" "$REPO_PATH/agentic"
```

What the script does:
- Checks AGENTS.md ≤100 lines
- Verifies no generic content duplication
- Confirms ecosystem.md exists with Tier 1 links
- Reports validation results (read-only, no changes)

---

### Mode 3: Extract from Single-Tier (--extract)

**Step 1: LLM - Analyze and extract**

LLM analyzes existing single-tier documentation:
1. Identifies generic content duplicating Tier 1 patterns
2. Removes generic content (~2,400 lines):
   - Testing pyramid → Remove, link to Tier 1
   - controller-runtime → Remove, link to Tier 1
   - Operator patterns → Remove, link to Tier 1
   - STRIDE/SLO/etc → Remove, link to Tier 1
3. Keeps component-specific content (~3,600 lines)
4. Creates ecosystem.md with Tier 1 links
5. Reduces AGENTS.md from ~143 lines to ~60-100 lines

**Step 2: SCRIPT - Validate**
```bash
bash "$SKILL_DIR/scripts/validate.sh" "$REPO_PATH/agentic"
```

---

### Mode 4: Ongoing Maintenance (--maintain)

**Step 1: SCRIPT - Detect code changes**
```bash
bash "$SKILL_DIR/scripts/detect-changes.sh" "$REPO_PATH"
```

What the script does:
- Checks for new CRDs/API types
- Checks for code structure changes (pkg/, cmd/)
- Checks for new controllers/packages
- Checks for new enhancements affecting this component
- Checks for architectural decisions in git log
- Checks if Tier 1 has been updated
- Reports what needs updating

**Step 2: SCRIPT - Run maintenance loop**
```bash
bash "$SKILL_DIR/scripts/maintenance-loop.sh" "$REPO_PATH"
```

What the script does:
- Runs detect-changes.sh + validate.sh
- Creates `.tier2-maintenance-iteration-N.md` task file
- Waits for LLM intervention

**Step 3: LLM - Update docs based on code changes**

LLM reads task file and updates:
- New CRD detected → Create domain/[crd-name].md
- Code structure changed → Update architecture/components.md
- New controller → Update architecture/components.md
- New enhancement → Create exec-plans/active/[name].md
- Architectural decision → Create decisions/adr-NNNN.md
- Tier 1 updated → Update ecosystem.md links

Critical rules:
- Component-specific content ONLY
- NO generic content duplication
- Keep AGENTS.md ≤100 lines
- Update ecosystem.md for new Tier 1 links

**Step 4: SCRIPT - Re-validate**
```bash
bash "$SKILL_DIR/scripts/validate.sh" "$REPO_PATH/agentic"
```

Loop continues until:
- ✅ No changes detected AND validation passes → SUCCESS
- ❌ Same issues 3x → STUCK
- ⚠️ Max 10 iterations → TIMEOUT

## Success Output

```
✅ Tier 2 Lean Documentation Complete

Component: machine-config-operator
Repository: /path/to/repo

Structure Created:
  - AGENTS.md: 78 lines (target: ≤100) ✅
  - Domain concepts: 4 files
  - Architecture docs: 3 files
  - Component ADRs: 3 files
  - Ecosystem references: ecosystem.md ✅

Tier 1 Links:
  - Operator patterns: 5 links ✅
  - Testing practices: 3 links ✅
  - Security practices: 2 links ✅
  - Cross-repo ADRs: 3 links ✅

Validation:
  ✅ AGENTS.md ≤100 lines
  ✅ No generic duplication detected
  ✅ ecosystem.md created with Tier 1 links
  ✅ Component-specific content only

Next Steps:
  1. Review and populate domain concept docs
  2. Document component architecture
  3. Create component-specific ADRs
  4. Add exec-plans for active work
```

## See Also

- `/agentic-docs-maintainer` - Full single-tier docs (standalone repos)
- `/agentic-docs-maintainer:verify` - Verify documentation compliance
- `/agentic-docs-maintainer:extract` - Extract knowledge from enhancements

## Related Documentation

- [Tier 1 Hub](https://github.com/openshift/enhancements/tree/master/agentic)
- [Tier 2 Examples](https://github.com/openshift/machine-config-operator/tree/master/agentic)

---

**Pattern**: Two-tier agentic documentation (lean component repos)
**Version**: 1.0
