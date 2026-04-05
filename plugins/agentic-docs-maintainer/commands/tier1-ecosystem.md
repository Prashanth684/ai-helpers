---
description: Create Tier 1 agentic documentation (ecosystem hub) in openshift/enhancements
---

## Name
agentic-docs-maintainer:tier1-ecosystem

## Synopsis
```
/agentic-docs-maintainer:tier1-ecosystem [--path <enhancements-path>] [--verify]
```

## Description
Creates **Tier 1 agentic documentation** in the `openshift/enhancements` repository that serves as the ecosystem hub for all OpenShift components. Tier 1 contains cross-repo knowledge shared across ALL components, avoiding duplication across 60+ repositories.

**Parameters:**
- `--path <enhancements-path>`: Path to openshift/enhancements repository (defaults to current directory)
- `--verify`: Verify existing Tier 1 docs for compliance
- No args: Create new Tier 1 structure

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

**Tier 1 structure (~4,000 lines, replaces 144,000 lines of duplication):**
```
enhancements/
├── enhancements/            [EXISTING - keep]
├── dev-guide/               [EXISTING - keep]
└── agentic/                 [NEW]
    ├── OPENSHIFT_AGENTS.md  [~150-170 lines entry point]
    ├── platform/
    │   ├── operator-patterns/      [Standard patterns all operators use]
    │   └── openshift-specifics/    [Platform concepts]
    ├── practices/
    │   ├── testing/                [Testing pyramid, E2E framework]
    │   ├── security/               [Threat modeling, RBAC]
    │   ├── reliability/            [SLO framework, observability]
    │   └── development/            [Git workflow, code review]
    ├── domain/
    │   ├── kubernetes/             [Pod, Node, Service, CRDs]
    │   └── openshift/              [ClusterOperator, Machine API]
    ├── decisions/                  [Cross-repo ADRs]
    └── references/
        └── repo-index.md           [Discovery of all components]
```

## What Gets Included in Tier 1

**Platform Patterns:**
- Status conditions (Available/Progressing/Degraded)
- controller-runtime reconciliation
- Leader election
- RBAC patterns
- Finalizers
- Webhooks
- Upgrade strategies

**Engineering Practices:**
- Testing pyramid (unit/integration/E2E)
- E2E framework (openshift-tests)
- CI integration (Prow)
- Threat modeling (STRIDE)
- RBAC guidelines
- SLO framework
- Observability patterns
- Git workflow
- Code review standards
- API evolution

**Domain Concepts:**
- Kubernetes: Pod, Node, Service, Deployment, CRDs
- OpenShift: ClusterOperator, ClusterVersion, Machine API, Route

**Cross-Repo ADRs:**
- Why OpenShift uses etcd
- Why operator-sdk for new operators
- How CVO coordinates upgrades

## What Does NOT Go in Tier 1

**Component-specific content** (belongs in Tier 2):
- ❌ MachineConfig CRD (MCO-only)
- ❌ MCO component architecture (MCD/MCC/MCS)
- ❌ Why MCO uses rpm-ostree
- ❌ Installer-specific workflows
- ❌ Component work tracking (exec-plans)

## Examples

### Example 1: Create Tier 1 from scratch

```bash
cd /path/to/openshift/enhancements
/agentic-docs-maintainer:tier1-ecosystem

# Creates:
# - agentic/ directory with full structure
# - OPENSHIFT_AGENTS.md (150-170 lines)
# - Platform patterns (9 files)
# - Engineering practices (13 files)
# - Domain concepts (9 files)
# - Cross-repo ADRs (3 files)
# - Repository index
```

### Example 2: Verify existing Tier 1

```bash
cd /path/to/openshift/enhancements
/agentic-docs-maintainer:tier1-ecosystem --verify

# Checks:
# ✅ OPENSHIFT_AGENTS.md ~150-170 lines
# ✅ All required directories exist
# ✅ No component-specific content
# ✅ All links valid
```

## Validation Criteria

**Tier 1 docs pass when:**
- ✅ OPENSHIFT_AGENTS.md ~150-170 lines
- ✅ All platform patterns documented (≥5 operator patterns)
- ✅ All practices documented (testing, security, reliability, development)
- ✅ All cross-repo ADRs present (≥3 ADRs)
- ✅ No component-specific content (except in examples)
- ✅ Repository index exists

## Metrics

**Expected Tier 1 size:**
- Total lines: ~4,000 lines
- OPENSHIFT_AGENTS.md: ~150-170 lines
- Platform patterns: ~1,200 lines
- Engineering practices: ~1,500 lines
- Domain concepts: ~800 lines
- Cross-repo ADRs: ~300 lines
- References: ~200 lines

**Ecosystem benefits:**
- Pattern updates: 1 Tier 1 PR vs 60+ component PRs
- Duplication across 60 repos: -97% (144,000 → 4,000 lines)
- Consistency: Immediate (all repos link to same Tier 1)

## Anti-Patterns

### ❌ DON'T put component-specific content in Tier 1

**Wrong:**
```markdown
# enhancements/agentic/domain/openshift/machineconfig.md

MachineConfig is how MCO manages node configuration...
```

**Right:**
```markdown
# This belongs in Tier 2:
# machine-config-operator/agentic/domain/machineconfig.md
```

### ❌ DON'T make OPENSHIFT_AGENTS.md too long

**Wrong:**
```markdown
# OPENSHIFT_AGENTS.md (200 lines)

## Detailed Operator Pattern Explanations
[100 lines of detail]
```

**Right:**
```markdown
# OPENSHIFT_AGENTS.md (120 lines)

## Operator Patterns
| Pattern | Link |
|---------|------|
| Status Conditions | [status-conditions.md](./platform/operator-patterns/status-conditions.md) |
```

### ❌ DON'T duplicate dev-guide content

**Wrong:** Copying dev-guide/operators.md verbatim

**Right:** Structure for AI parsing, link to dev-guide for narrative

## Prerequisites

**Before running this command:**
1. ✅ You have write access to openshift/enhancements repository
2. ✅ The `/agentic` directory does NOT already exist
3. ✅ You understand two-tier architecture

**If /agentic already exists:**
- Use `/agentic-docs-maintainer` for maintenance

**If creating component docs:**
- Use `/agentic-docs-maintainer:tier2-component` for lean Tier 2 docs

## When NOT to Use

**Don't use this command if:**
- Creating docs for component repository (use tier2-component instead)
- Tier 1 already exists (use agentic-docs-maintainer instead)
- Repository is not openshift/enhancements

## Implementation

### Execution Steps

**Step 1: SCRIPT - Create structure**
```bash
SKILL_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-creator" -type d | head -1)
bash "$SKILL_DIR/scripts/create-structure.sh" "$REPO_PATH"
```

What the script does:
- Creates empty directory structure (platform/, practices/, domain/, decisions/, references/)

**Step 2: SCRIPT - Populate base templates**
```bash
bash "$SKILL_DIR/scripts/populate-templates.sh" "$REPO_PATH"
```

What the script does:
- Copies 2 pre-written template files (DESIGN_PHILOSOPHY.md, KNOWLEDGE_GRAPH.md)

**Step 3: LLM - Create all documentation**

LLM reads SKILL.md and creates documentation using templates:
- **Phase 2**: OPENSHIFT_AGENTS.md (~150-170 lines)
- **Phase 3**: Platform patterns (operator patterns, OpenShift specifics)
- **Phase 4**: Engineering practices (testing, security, reliability, development)
- **Phase 5**: Domain concepts (critical Kubernetes and OpenShift APIs)
- **Phase 6**: Cross-repo ADRs (architectural decisions affecting multiple repos)
- **Phase 7**: Reference materials (repo index, glossary, enhancement index, API reference)
- **Phase 7.5**: Index files for major sections
- **Phase 7.6**: Workflow documentation (enhancement process, implementation)
- **Phase 7.7**: MachineConfig platform API documentation

The LLM identifies what's critical based on OpenShift ecosystem needs.

**Step 4: SCRIPT - Validate**
```bash
bash "$SKILL_DIR/scripts/validate.sh" "$REPO_PATH/agentic"
```

What the script does:
- Checks compliance against SPECIFICATION.md
- Reports validation results

## Success Output

```
✅ Tier 1 Agentic Documentation Created

Repository: openshift/enhancements
Location: /agentic

Structure Created:
  - OPENSHIFT_AGENTS.md: 167 lines (target: ~150-170) ✅
  - Platform patterns (operator patterns, OpenShift specifics)
  - Engineering practices (testing, security, reliability, development)
  - Domain concepts (Kubernetes and OpenShift platform APIs)
  - Cross-repo ADRs (architectural decisions)
  - Reference materials (repo index, glossary, enhancement index, API reference)
  - Workflow documentation (enhancement process, implementation)
  - Index files for major sections

Validation:
  ✅ OPENSHIFT_AGENTS.md ~150-170 lines
  ✅ All required directories present
  ✅ No component-specific content detected
  ✅ Critical platform patterns and practices documented
  ✅ Repository index created

Next Steps:
  1. Review documentation for accuracy
  2. Create component Tier 2 docs:
     cd /path/to/machine-config-operator
     /agentic-docs-maintainer:tier2-component
  3. Create git commit
```

## See Also

- `/agentic-docs-maintainer:tier2-component` - Create lean Tier 2 docs in component repos
- `/agentic-docs-maintainer` - Maintain existing agentic docs
- `/agentic-docs-maintainer:verify` - Verify documentation compliance

## Related Documentation

- [Tier 1 Examples](https://github.com/openshift/enhancements/tree/master/agentic)
- [Component Tier 2 Examples](https://github.com/openshift/machine-config-operator/tree/master/agentic)

---

**Pattern**: Two-tier agentic documentation (Tier 1 ecosystem hub)
**Version**: 1.0
