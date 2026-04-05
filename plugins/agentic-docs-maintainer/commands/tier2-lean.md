---
description: Create lean Tier 2 agentic documentation for OpenShift component repositories
---

## Name
agentic-docs-maintainer:tier2-lean

## Synopsis
```
/agentic-docs-maintainer:tier2-lean [--path <repo-path>] [--verify] [--extract]
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
├── AGENTS.md                      [~60-80 lines, links to Tier 1]
├── ARCHITECTURE.md
└── agentic/
    ├── domain/                    [Component concepts ONLY]
    ├── architecture/              [Component internals]
    ├── decisions/                 [Component ADRs ONLY]
    ├── exec-plans/
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
/agentic-docs-maintainer:tier2-lean

# Creates:
# - AGENTS.md (60 lines)
# - agentic/domain/, architecture/, decisions/
# - agentic/references/ecosystem.md (links to Tier 1)
# - MCO_DEVELOPMENT.md, MCO_TESTING.md (lean)
```

### Example 2: Extract from existing single-tier docs

```bash
cd machine-config-operator
/agentic-docs-maintainer:tier2-lean --extract

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
/agentic-docs-maintainer:tier2-lean --verify

# Checks:
# ✅ AGENTS.md ≤80 lines
# ✅ No generic duplication
# ✅ ecosystem.md exists
# ✅ All Tier 1 links valid
```

## Validation Criteria

**Tier 2 docs pass when:**
- ✅ AGENTS.md ≤ 80 lines
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

Executes the agentic-docs-tier2 skill with the following phases:

1. **Assessment**: Verify OpenShift component, check Tier 1 exists
2. **Structure**: Create lean directory tree
3. **AGENTS.md**: Create ≤80 line entry point with Tier 1 links
4. **ecosystem.md**: Create Tier 1 reference index (CRITICAL)
5. **Lean guides**: Create component-specific development/testing docs
6. **Extract** (if --extract): Remove generic content, keep component-specific
7. **Verify**: Check compliance with Tier 2 requirements

## Success Output

```
✅ Tier 2 Lean Documentation Complete

Component: machine-config-operator
Repository: /path/to/repo

Structure Created:
  - AGENTS.md: 60 lines (target: ≤80) ✅
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
  ✅ AGENTS.md ≤80 lines
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
- [Two-Tier Architecture](https://github.com/openshift/enhancements/blob/master/agentic/TWO_TIER_ARCHITECTURE.md)
- [Tier 2 Examples](https://github.com/openshift/machine-config-operator/tree/master/agentic)

---

**Pattern**: Two-tier agentic documentation (lean component repos)
**Version**: 1.0
