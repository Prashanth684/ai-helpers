---
name: agentic-docs-creator
description: Create Tier 1 agentic documentation (ecosystem hub) in openshift/enhancements
trigger: explicit
model: sonnet
---

# Agentic Docs Creator - Tier 1 Ecosystem Hub

## ⚡ Quick Start - Execution Flow

**READ THIS FIRST to understand the execution model:**

### Two-Phase Execution
1. **SCRIPTS** (Phase 1): Setup directories and copy templates
   - Run `create-structure.sh` → creates directory tree
   - Run `populate-templates.sh` → copies 2 base files (DESIGN_PHILOSOPHY.md, KNOWLEDGE_GRAPH.md)
   
2. **LLM** (Phase 2-9): Create all documentation
   - You (the LLM) create ~30-40 markdown files following the templates in this SKILL.md
   - Each phase specifies what files to create with full examples

### What You DON'T Do
- ❌ Don't manually create directories (scripts handle this)
- ❌ Don't create DESIGN_PHILOSOPHY.md or KNOWLEDGE_GRAPH.md (scripts copy these)
- ❌ Don't run inline bash validation commands (use validate.sh script)

### What You DO
- ✅ Call the scripts in Phase 1
- ✅ Create all documentation files in Phase 2-7
- ✅ Call validate.sh script in Phase 8
- ✅ Report results in Phase 9

---

## What This Skill Does

Creates **Tier 1 agentic documentation** in the `openshift/enhancements` repository that serves as the ecosystem hub for ALL OpenShift components.

**Tier 1 contains:**
- Cross-repo architectural decisions (ADRs)
- Platform patterns (operator patterns, controller-runtime, status conditions)
- Engineering practices (testing pyramid, E2E framework, CI integration)
- Kubernetes & OpenShift fundamentals (Pod, Node, ClusterOperator)
- Repository index (discovery of all components)

**NOT included in Tier 1** (belongs in Tier 2 component repos):
- Component-specific domain concepts (e.g., MachineConfig for MCO)
- Component architecture internals
- Component-specific decisions
- Component work tracking

## When to Use This Skill

Use this skill when:
- Creating agentic documentation in the `openshift/enhancements` repository
- The `/agentic` directory does NOT exist in openshift/enhancements
- You want to establish the Tier 1 ecosystem hub

**DO NOT use this skill if:**
- Creating docs for a component repository (use agentic-docs-tier2 instead)
- The `/agentic` directory already exists in enhancements (use agentic-docs-maintainer instead)

## Arguments

```bash
/agentic-docs-creator [--path <enhancements-path>] [--verify]
```

**Arguments:**
- `--path <enhancements-path>`: Path to openshift/enhancements repo (default: ../enhancements or current directory)
- `--verify`: Verify Tier 1 structure and compliance
- No args: Create new Tier 1 structure

## Two-Tier Architecture Overview

### The Problem with Single-Tier

OpenShift is a **multi-repo ecosystem** with 60+ component repositories. Original single-tier approach required each repo to duplicate generic patterns:
- Generic operator patterns duplicated across 60+ repos = 144,000 lines of duplication
- Cross-repo features had no natural home
- Updating a pattern required 60+ PRs
- Impossible to maintain consistency

### The Two-Tier Solution

**Tier 1 (Ecosystem Hub): openshift/enhancements/agentic/**
- Cross-repo knowledge shared across ALL OpenShift components
- Platform patterns, engineering practices, cross-repo ADRs
- Kubernetes/OpenShift fundamentals
- Master entry point: OPENSHIFT_AGENTS.md (~150 lines)
- Owned by: Enhancement reviewers, platform architecture team

**Tier 2 (Component Repos): machine-config-operator/agentic/**
- Component-specific knowledge unique to THIS component
- Component domain concepts, architecture, ADRs, exec-plans
- Lean entry point: AGENTS.md (~60-80 lines)
- Links to Tier 1 for generic patterns
- Owned by: Component maintainers

### Decision Matrix: What Goes Where?

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

### Benefits

| Metric | Single-Tier | Two-Tier | Improvement |
|--------|-------------|----------|-------------|
| MCO doc size | 6,000 lines | 2,500 lines | **-58%** |
| Generic duplication (60 repos) | 144,000 lines | 4,000 lines | **-97%** |
| Pattern update PRs | 60+ PRs | 1 PR | **-98%** |
| Context budget | 650 lines | 300 lines | **-54%** |

## Important: Template Pattern Usage

This SKILL.md provides **2-3 full templates per category** as examples. You must use these templates as patterns and infer the structure for remaining files.

**Example**: Phase 4 provides full templates for:
- `status-conditions.md` (validation/mutation pattern)
- `controller-runtime.md` (code-heavy technical pattern)  
- `webhooks.md` (configuration + code pattern)

When you see "**Repeat for:** `leader-election.md` - How leader election works", you should:
1. **Infer structure** from the 3 templates above
2. **Match the pattern type**: leader-election is similar to status-conditions (technical pattern with code examples)
3. **Create consistent content**: Same sections (Overview, Key Concepts, Implementation, Best Practices, Examples, References)
4. **Adapt to topic**: Replace webhook-specific content with leader-election-specific content

**Quality bar**:
- ✅ All files should have similar length and depth as the provided templates
- ✅ All files should include code examples, tables, and best practices
- ✅ All files should reference related OpenShift components
- ❌ Don't create stub files with just a few lines
- ❌ Don't skip sections that the templates include

## Use Your Judgment

**Important**: The file suggestions in "Repeat for" sections are **examples, not requirements**. You should:

✅ **DO**:
- Identify what's critical for the OpenShift ecosystem
- Create files for concepts that are widely used across components
- Document patterns that prevent duplication across repos
- Add content that provides value to LLM agents and developers
- Skip files if the concept is too specific or rarely used

❌ **DON'T**:
- Feel obligated to create every suggested file
- Create files just to hit a specific count
- Add content that duplicates what's elsewhere
- Document every possible Kubernetes/OpenShift concept

**Example**: If you determine that "nodes.md" would just duplicate basic Kubernetes documentation available elsewhere, skip it. If "route.md" is critical for OpenShift and widely referenced, create it.

## Task Execution

**IMPORTANT - READ THIS FIRST:**

This skill has a **two-phase execution model**:
1. **SCRIPTS** handle setup (Phase 1-2): Directory creation, template copying
2. **LLM** creates content (Phase 3+): All documentation files

When the user invokes this skill, execute the following:

### Phase 1: Run Setup Scripts

**Goal:** Create directory structure and copy base templates

**Actions - Run these scripts in sequence:**

```bash
# Find the skill directory
SKILL_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-creator" -type d | head -1)
REPO_PATH="${provided_path:-$PWD}"

# Step 1: Create directory structure
bash "$SKILL_DIR/scripts/create-structure.sh" "$REPO_PATH"

# Step 2: Populate base templates
bash "$SKILL_DIR/scripts/populate-templates.sh" "$REPO_PATH"
```

**What the scripts do:**
- `create-structure.sh`: 
  - Validates this is openshift/enhancements repository
  - Checks /agentic directory doesn't exist
  - Creates directory tree: platform/, practices/, domain/, decisions/, workflows/, references/
  
- `populate-templates.sh`:
  - Copies 2 pre-written template files:
    - `DESIGN_PHILOSOPHY.md` (~400 lines)
    - `KNOWLEDGE_GRAPH.md` (~300 lines)

**Expected structure after scripts:**
```
enhancements/
├── enhancements/        [EXISTING - keep as-is]
├── dev-guide/           [EXISTING - keep as-is]
└── agentic/             [NEW]
    ├── DESIGN_PHILOSOPHY.md      [Created by script]
    ├── KNOWLEDGE_GRAPH.md        [Created by script]
    ├── platform/
    │   ├── operator-patterns/
    │   └── openshift-specifics/
    ├── practices/
    │   ├── testing/
    │   ├── security/
    │   ├── reliability/
    │   └── development/
    ├── domain/
    │   ├── kubernetes/
    │   └── openshift/
    ├── decisions/
    ├── workflows/
    └── references/
```

**After scripts complete:** You (the LLM) create all remaining documentation starting with Phase 2.

### Phase 2: Create Master Entry Point

**Goal:** Create OPENSHIFT_AGENTS.md (~150-170 lines)

**File:** `agentic/OPENSHIFT_AGENTS.md`

**Template:**
```markdown
# OpenShift - Agent Navigation

> Master entry point for all OpenShift repositories

**Version**: 1.0  
**Last Updated**: YYYY-MM-DD  

## Quick Navigation by Role

**Working on a specific component**  
→ [Repo index](./references/repo-index.md)

**Understanding OpenShift platform**  
→ [Platform architecture](./platform/)

**Implementing cross-repo feature**  
→ [Enhancement proposals](../enhancements/)

**Learning engineering practices**  
→ [Practices](./practices/)

## Core Platform Concepts

| Concept | Description | Link |
|---------|-------------|------|
| ClusterOperator | How operators report status | [clusteroperator.md](./domain/openshift/clusteroperator.md) |
| ClusterVersion | Platform upgrades | [clusterversion.md](./domain/openshift/clusterversion.md) |
| Machine API | Node lifecycle | [machine.md](./domain/openshift/machine.md) |
| Route | OpenShift routing | [route.md](./domain/openshift/route.md) |
| Pod | K8s workload unit | [pods.md](./domain/kubernetes/pods.md) |
| Node | K8s cluster nodes | [nodes.md](./domain/kubernetes/nodes.md) |
| Service | K8s service discovery | [services.md](./domain/kubernetes/services.md) |

## Standard Operator Patterns

| Pattern | Purpose | Link |
|---------|---------|------|
| Status Conditions | Available/Progressing/Degraded | [status-conditions.md](./platform/operator-patterns/status-conditions.md) |
| controller-runtime | Reconciliation loops | [controller-runtime.md](./platform/operator-patterns/controller-runtime.md) |
| Leader Election | HA for controllers | [leader-election.md](./platform/operator-patterns/leader-election.md) |
| RBAC Patterns | ServiceAccount design | [rbac-patterns.md](./platform/operator-patterns/rbac-patterns.md) |
| Finalizers | Resource cleanup | [finalizers.md](./platform/operator-patterns/finalizers.md) |
| Webhooks | Admission control | [webhooks.md](./platform/operator-patterns/webhooks.md) |

## Component Repository Index

See [repo-index.md](./references/repo-index.md) for all component repositories.

## Engineering Practices

| Practice | Link |
|----------|------|
| Testing Pyramid | [pyramid.md](./practices/testing/pyramid.md) |
| E2E Framework | [e2e-framework.md](./practices/testing/e2e-framework.md) |
| CI Integration | [ci-integration.md](./practices/testing/ci-integration.md) |
| Threat Modeling | [threat-modeling.md](./practices/security/threat-modeling.md) |
| RBAC Guidelines | [rbac-guidelines.md](./practices/security/rbac-guidelines.md) |
| SLO Framework | [slo-framework.md](./practices/reliability/slo-framework.md) |
| Observability | [observability.md](./practices/reliability/observability.md) |
| Git Workflow | [git-workflow.md](./practices/development/git-workflow.md) |
| Code Review | [code-review.md](./practices/development/code-review.md) |
| API Evolution | [api-evolution.md](./practices/development/api-evolution.md) |

## Cross-Repo Architectural Decisions

See [decisions/](./decisions/) for ADRs affecting multiple repositories.

---

**Constraint**: This file should be ~150-170 lines (concise entry point).
```

**Validation:**
```bash
wc -l agentic/OPENSHIFT_AGENTS.md
# Target: 150-170 lines
```

### Phase 3: Create Platform Patterns

**Goal:** Document operator patterns used across all repos

**Create these files:**

#### 4.1: `platform/operator-patterns/status-conditions.md`

```markdown
# Operator Status Conditions Pattern

**Category**: Platform Pattern  
**Applies To**: All ClusterOperators  
**Last Updated**: YYYY-MM-DD  

## Overview

All ClusterOperators report status using Available/Progressing/Degraded conditions.

## Condition Types

| Condition | Meaning | When to Set |
|-----------|---------|-------------|
| Available | Operator functional | Reconciliation successful |
| Progressing | Operator updating | During rollouts, config changes |
| Degraded | Operator failing | Errors, unable to reconcile |
| Upgradeable | Safe to upgrade | Prerequisites met |

## Implementation

```go
import "github.com/openshift/library-go/pkg/operator/v1helpers"

v1helpers.SetOperatorCondition(&operatorStatus.Conditions,
    operatorv1.OperatorCondition{
        Type:   operatorv1.OperatorStatusTypeAvailable,
        Status: operatorv1.ConditionTrue,
        Reason: "AsExpected",
        Message: "All components running",
    })
```

## Best Practices

1. **Set all conditions**: Always maintain Available, Progressing, Degraded
2. **Meaningful reasons**: Use descriptive reason strings
3. **Actionable messages**: Help users understand what's wrong
4. **Transition accuracy**: Update status when state changes

## Examples in Components

| Component | Implementation | Notes |
|-----------|---------------|-------|
| machine-config-operator | pkg/operator/status.go | Sets Degraded when nodes fail |
| cluster-version-operator | pkg/cvo/status.go | Aggregates operator statuses |
| cluster-network-operator | pkg/operator/status.go | Sets Progressing during SDN migration |

## References

- **Library-go**: https://github.com/openshift/library-go/pkg/operator
- **CVO**: [cluster-operators.md](../openshift-specifics/cluster-operators.md)
- **API Conventions**: [dev-guide/api-conventions.md](../../dev-guide/api-conventions.md)
```

#### 4.2: `platform/operator-patterns/controller-runtime.md`

```markdown
# controller-runtime Pattern

**Category**: Platform Pattern  
**Applies To**: All Kubernetes operators  
**Last Updated**: YYYY-MM-DD  

## Overview

OpenShift operators use controller-runtime for reconciliation loops.

## Pattern

```go
import (
    ctrl "sigs.k8s.io/controller-runtime"
    "sigs.k8s.io/controller-runtime/pkg/client"
)

func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    // 1. Fetch resource
    obj := &MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }
    
    // 2. Reconcile to desired state
    if err := r.reconcile(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }
    
    // 3. Update status
    if err := r.Status().Update(ctx, obj); err != nil {
        return ctrl.Result{}, err
    }
    
    return ctrl.Result{}, nil
}
```

## Key Concepts

- **Watches**: Monitor resources for changes
- **Informers**: Cache resources locally (reduces API load)
- **Reconciliation**: Drive actual state → desired state
- **Requeue**: Retry on transient errors (use exponential backoff)

## Common Patterns

### Requeue with Delay
```go
// Requeue after 30 seconds
return ctrl.Result{RequeueAfter: 30 * time.Second}, nil
```

### Error Handling
```go
// Let controller-runtime handle requeue with backoff
if err := r.reconcile(ctx, obj); err != nil {
    return ctrl.Result{}, fmt.Errorf("reconcile failed: %w", err)
}
```

### Watches
```go
func (r *Reconciler) SetupWithManager(mgr ctrl.Manager) error {
    return ctrl.NewControllerManagedBy(mgr).
        For(&MyResource{}).
        Owns(&corev1.ConfigMap{}).
        Complete(r)
}
```

## Examples

| Component | Controller | Notes |
|-----------|-----------|-------|
| machine-config-operator | MachineConfigController | Renders configs for node pools |
| cluster-network-operator | NetworkController | Manages CNI (SDN/OVN) |
| machine-api-operator | MachineController | Node lifecycle management |

## References

- **Upstream**: https://github.com/kubernetes-sigs/controller-runtime
- **OpenShift**: [operator-sdk.md](./operator-sdk.md)
- **Operator Patterns**: [index.md](./index.md)
```

#### 4.3: `platform/operator-patterns/webhooks.md`

```markdown
# Webhooks Pattern

**Category**: Platform Pattern  
**Applies To**: Operators needing admission control  
**Last Updated**: YYYY-MM-DD  

## Overview

Webhooks allow operators to validate or mutate resources before they're persisted in etcd.

## Types

| Type | Purpose | When to Use |
|------|---------|-------------|
| Validating | Reject invalid resources | Enforce business rules, schema validation |
| Mutating | Modify resources before storage | Set defaults, inject sidecars |

## Implementation

### Validating Webhook

```go
import (
    "context"
    "net/http"
    "sigs.k8s.io/controller-runtime/pkg/webhook/admission"
)

type MyResourceValidator struct {
    decoder *admission.Decoder
}

func (v *MyResourceValidator) Handle(ctx context.Context, req admission.Request) admission.Response {
    obj := &MyResource{}
    if err := v.decoder.Decode(req, obj); err != nil {
        return admission.Errored(http.StatusBadRequest, err)
    }
    
    // Validate
    if obj.Spec.Replicas < 1 {
        return admission.Denied("replicas must be >= 1")
    }
    
    return admission.Allowed("")
}
```

### Mutating Webhook

```go
func (m *MyResourceMutator) Handle(ctx context.Context, req admission.Request) admission.Response {
    obj := &MyResource{}
    if err := m.decoder.Decode(req, obj); err != nil {
        return admission.Errored(http.StatusBadRequest, err)
    }
    
    // Set defaults
    if obj.Spec.Replicas == 0 {
        obj.Spec.Replicas = 3
    }
    
    marshaledObj, err := json.Marshal(obj)
    if err != nil {
        return admission.Errored(http.StatusInternalServerError, err)
    }
    
    return admission.PatchResponseFromRaw(req.Object.Raw, marshaledObj)
}
```

## Configuration

### WebhookConfiguration

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingWebhookConfiguration
metadata:
  name: myresource-validator
webhooks:
- name: myresource.openshift.io
  clientConfig:
    service:
      name: my-operator-webhook
      namespace: openshift-my-operator
      path: /validate-myresource
  rules:
  - apiGroups: ["myapi.openshift.io"]
    apiVersions: ["v1"]
    operations: ["CREATE", "UPDATE"]
    resources: ["myresources"]
  sideEffects: None
  admissionReviewVersions: ["v1"]
```

## Best Practices

1. **Fail open on errors**: Use `failurePolicy: Ignore` for non-critical validation
2. **Short timeouts**: Default 10s is often too long, use 2-3s
3. **Avoid side effects**: Webhooks should be idempotent
4. **Use object selectors**: Limit webhook scope to relevant objects
5. **Handle DELETE carefully**: Old object may not pass current validation

## Common Patterns

### Version-Specific Validation

```go
func (v *Validator) validateV1(obj *MyResourceV1) error {
    // v1-specific validation
}

func (v *Validator) validateV2(obj *MyResourceV2) error {
    // v2-specific validation
}
```

### Namespace-Aware Mutation

```go
if obj.Namespace == "openshift-monitoring" {
    // Apply monitoring-specific defaults
    obj.Spec.MonitoringEnabled = true
}
```

## Examples

| Component | Webhook Type | Purpose |
|-----------|-------------|---------|
| machine-api-operator | Validating | Prevent invalid machine configurations |
| cluster-network-operator | Mutating | Inject network configuration defaults |
| console-operator | Validating | Ensure console extensions are valid |

## Debugging

```bash
# Check webhook configuration
oc get validatingwebhookconfigurations
oc get mutatingwebhookconfigurations

# View webhook logs
oc logs -n openshift-my-operator deployment/my-operator-webhook

# Test webhook locally
curl -k -X POST https://localhost:9443/validate-myresource \
  -H "Content-Type: application/json" \
  -d @admission-request.json
```

## References

- **K8s Admission Controllers**: https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/
- **controller-runtime Webhooks**: https://book.kubebuilder.io/cronjob-tutorial/webhook-implementation.html
- **OpenShift Webhooks**: [webhook-best-practices.md](../../practices/development/webhook-best-practices.md)
```

**Repeat for** (follow the structure and patterns from status-conditions.md, controller-runtime.md, and webhooks.md above):
- `leader-election.md` - How leader election works, library-go usage, HA patterns
- `rbac-patterns.md` - ServiceAccount design, Role/ClusterRole patterns, least privilege
- `finalizers.md` - Resource cleanup patterns, deletion flow, common pitfalls
- `owner-references.md` - Resource ownership, garbage collection, cascade deletion
- `upgrade-strategies.md` - Rolling updates, version skew, upgrade ordering
- `must-gather.md` - Diagnostic data collection pattern, what to include

#### 4.4: Create `platform/operator-patterns/index.md`

```markdown
# Operator Patterns Index

**Last Updated**: YYYY-MM-DD  

## Overview

Standard patterns used by all OpenShift operators.

## Core Patterns

| Pattern | Purpose | File |
|---------|---------|------|
| Status Conditions | Report operator health to CVO | [status-conditions.md](./status-conditions.md) |
| controller-runtime | Reconciliation loop framework | [controller-runtime.md](./controller-runtime.md) |
| Leader Election | High availability for controllers | [leader-election.md](./leader-election.md) |
| RBAC Patterns | ServiceAccount and permissions | [rbac-patterns.md](./rbac-patterns.md) |
| Finalizers | Resource cleanup on deletion | [finalizers.md](./finalizers.md) |
| Webhooks | Admission control | [webhooks.md](./webhooks.md) |
| Owner References | Resource ownership | [owner-references.md](./owner-references.md) |
| Upgrade Strategies | Safe operator upgrades | [upgrade-strategies.md](./upgrade-strategies.md) |
| must-gather | Diagnostic collection | [must-gather.md](./must-gather.md) |

## Usage

All ClusterOperators should follow these patterns unless there's a documented reason not to.

## See Also

- [OpenShift Specifics](../openshift-specifics/)
- [Engineering Practices](../../practices/)
- [Example Implementations](../../references/repo-index.md)
```

### Phase 4: Create Engineering Practices

**Goal:** Document testing/security/reliability practices

#### 5.1: `practices/testing/pyramid.md`

```markdown
# Testing Pyramid

**Category**: Engineering Practice  
**Applies To**: All OpenShift repositories  
**Last Updated**: YYYY-MM-DD  

## Philosophy

```
         /\
        /  \  E2E (10%)
       /────\
      /      \  Integration (30%)
     /────────\
    /          \  Unit (60%)
   /────────────\
```

## Coverage Targets

| Level | Coverage | Time | Cost | Purpose |
|-------|----------|------|------|---------|
| Unit | 60% | ms | Low | Fast feedback, pinpoint failures |
| Integration | 30% | sec | Medium | Component interactions, API contracts |
| E2E | 10% | min | High | Full system validation, real behavior |

## Rationale

**Why this distribution?**
- **Unit tests** are fast and cheap - catch most bugs early
- **Integration tests** verify contracts between components
- **E2E tests** are slow and expensive - use sparingly for critical paths

**Anti-pattern**: Too many E2E tests
- Slow CI
- Flaky tests
- Hard to debug
- Expensive to maintain

## Implementation

### Unit Tests
```bash
# Run unit tests
make test-unit

# With coverage
go test ./... -coverprofile=coverage.out
go tool cover -html=coverage.out
```

**What to test:**
- Business logic
- Edge cases
- Error handling
- Input validation

**Example:**
```go
func TestMachineConfigValidation(t *testing.T) {
    mc := &MachineConfig{
        Spec: MachineConfigSpec{
            OSImageURL: "invalid://url",
        },
    }
    
    err := ValidateMachineConfig(mc)
    if err == nil {
        t.Error("Expected validation error for invalid URL")
    }
}
```

### Integration Tests
```bash
# Run integration tests
make test-integration
```

**What to test:**
- Component interactions
- API contracts
- Database/external service interactions
- Controller reconciliation loops

**Example:**
```go
func TestMachineConfigController(t *testing.T) {
    // Setup fake client
    client := fake.NewClientBuilder().Build()
    
    // Create MachineConfig
    mc := &MachineConfig{...}
    client.Create(context.TODO(), mc)
    
    // Trigger reconciliation
    result, err := controller.Reconcile(...)
    
    // Verify expected behavior
    assert.NoError(t, err)
    assert.Equal(t, ctrl.Result{}, result)
}
```

### E2E Tests
```bash
# Run E2E tests
make test-e2e
```

**What to test:**
- Critical user workflows
- Upgrade paths
- Disaster recovery
- Multi-component interactions

**When NOT to use E2E:**
- Unit tests can cover it
- Integration tests can cover it
- Flaky or slow tests

## Examples in Components

| Component | Unit | Integration | E2E |
|-----------|------|-------------|-----|
| machine-config-operator | pkg/*_test.go | test/integration/ | test/e2e-agnostic/ |
| cluster-network-operator | pkg/*_test.go | test/integration/ | test/e2e/ |
| installer | pkg/*_test.go | tests/terraform/ | tests/e2e/ |

## References

- [E2E Framework](./e2e-framework.md)
- [CI Integration](./ci-integration.md)
- [Test Flake Policy](./test-flake-policy.md)
```

#### 5.2: `practices/testing/e2e-framework.md`

```markdown
# OpenShift E2E Testing Framework

**Category**: Engineering Practice  
**Applies To**: All OpenShift repositories  
**Last Updated**: YYYY-MM-DD  

## Overview

OpenShift uses `openshift-tests` for E2E testing.

## Framework Structure

```bash
# Run all conformance tests
openshift-tests run openshift/conformance

# Run specific suite
openshift-tests run openshift/network

# Run regex match
openshift-tests run --dry-run | grep -i machine | openshift-tests run --file -
```

## Test Organization

```
test/
├── e2e-agnostic/     # Cloud-agnostic tests (most tests go here)
├── e2e-aws/          # AWS-specific tests
├── e2e-azure/        # Azure-specific tests
└── e2e-gcp/          # GCP-specific tests
```

**Guideline:** Prefer cloud-agnostic tests unless the test is truly platform-specific.

## Writing Tests

```go
package e2e

import (
    "github.com/onsi/ginkgo/v2"
    "github.com/onsi/gomega"
)

var _ = ginkgo.Describe("[sig-machineconfig] MachineConfig", func() {
    ginkgo.It("should apply file changes [Slow]", func() {
        // Test implementation
        gomega.Expect(result).To(gomega.Succeed())
    })
})
```

### Test Labels

Use Ginkgo labels to categorize tests:

| Label | Meaning | Example |
|-------|---------|---------|
| `[Slow]` | >1 minute | Node reboot tests |
| `[Serial]` | Cannot run in parallel | Cluster-wide config changes |
| `[Disruptive]` | May affect other tests | Node deletion |
| `[sig-NAME]` | Special interest group | [sig-machineconfig] |

### Best Practices

1. **Use descriptive names**: Test name should explain what it tests
2. **Clean up resources**: Use `ginkgo.DeferCleanup()` or `AfterEach()`
3. **Avoid sleeps**: Poll with Eventually/Consistently
4. **Make tests idempotent**: Should work if run multiple times

## Example Test

```go
var _ = ginkgo.Describe("[sig-machineconfig] MachineConfigDaemon", func() {
    var (
        mc    *machineconfigv1.MachineConfig
        pool  *machineconfigv1.MachineConfigPool
    )
    
    ginkgo.BeforeEach(func() {
        // Setup
        mc = &machineconfigv1.MachineConfig{...}
        Expect(k8sClient.Create(ctx, mc)).To(Succeed())
    })
    
    ginkgo.AfterEach(func() {
        // Cleanup
        k8sClient.Delete(ctx, mc)
    })
    
    ginkgo.It("should update nodes when MachineConfig changes", func() {
        // Modify MachineConfig
        mc.Spec.Config.Storage.Files = append(mc.Spec.Config.Storage.Files, ...)
        Expect(k8sClient.Update(ctx, mc)).To(Succeed())
        
        // Wait for update to complete
        gomega.Eventually(func() bool {
            pool := &machineconfigv1.MachineConfigPool{}
            k8sClient.Get(ctx, types.NamespacedName{Name: "worker"}, pool)
            return pool.Status.UpdatedMachineCount == pool.Status.MachineCount
        }, timeout, interval).Should(BeTrue())
    })
})
```

## CI Integration

E2E tests run in Prow CI on every PR and merge.

See [ci-integration.md](./ci-integration.md) for details.

## References

- **openshift-tests**: https://github.com/openshift/origin/tree/master/test
- **Testing Pyramid**: [pyramid.md](./pyramid.md)
- **Ginkgo**: https://onsi.github.io/ginkgo/
```

#### 5.3: `practices/security/threat-modeling.md`

```markdown
# Threat Modeling

**Category**: Engineering Practice  
**Applies To**: All OpenShift components  
**Last Updated**: YYYY-MM-DD  

## Overview

Use the STRIDE framework to identify security threats during design and implementation.

## STRIDE Framework

| Threat | Question | Example |
|--------|----------|---------|
| **S**poofing | Can an attacker impersonate? | Fake ServiceAccount tokens |
| **T**ampering | Can data be modified? | ConfigMap injection |
| **R**epudiation | Can actions be denied? | Missing audit logs |
| **I**nformation Disclosure | Can data be leaked? | Secrets in logs |
| **D**enial of Service | Can availability be disrupted? | Resource exhaustion |
| **E**levation of Privilege | Can permissions be escalated? | RBAC bypass |

## When to Apply

- **Design phase**: New features, APIs, controllers
- **Code review**: Changes affecting security boundaries
- **Incident response**: Understanding attack vectors

## Process

### 1. Identify Assets

```markdown
## Assets
- Cluster credentials (etcd encryption keys)
- User data (PersistentVolumes)
- Control plane availability
```

### 2. Map Data Flows

```
User → API Server → Operator → Managed Resource
  ↓         ↓           ↓            ↓
 RBAC    Webhook    Leader       Secrets
         Validation  Election
```

### 3. Apply STRIDE to Each Flow

**Example: Operator reads Secret**

| Threat | Risk | Mitigation |
|--------|------|-----------|
| Spoofing | Operator pod impersonated | Use ServiceAccount with limited RBAC |
| Tampering | Secret modified in transit | TLS between components |
| Information Disclosure | Secret logged | Sanitize logs, avoid printing secrets |
| Elevation of Privilege | Operator gains cluster-admin | Least privilege RBAC |

### 4. Document Mitigations

```go
// Mitigation: Information Disclosure
// Never log the entire secret
log.Info("Processing secret", "name", secret.Name) // OK
log.Info("Secret data", "data", secret.Data)       // NEVER
```

## Common Threats in OpenShift

### Spoofing: ServiceAccount Token Theft

**Attack**: Attacker gains access to pod, steals `/var/run/secrets/kubernetes.io/serviceaccount/token`

**Mitigations**:
- Least privilege RBAC
- Short-lived tokens (TokenRequest API)
- Audit ServiceAccount usage

### Tampering: Malicious Admission Webhooks

**Attack**: Attacker deploys webhook that modifies resources

**Mitigations**:
- Restrict webhook creation (RBAC)
- Validate webhook configurations
- Use `failurePolicy: Fail` for critical webhooks

### Information Disclosure: Secrets in Container Images

**Attack**: Credentials hardcoded in images

**Mitigations**:
- Mount secrets as volumes
- Use external secret managers
- Scan images for secrets (pre-commit hooks)

## OpenShift-Specific Considerations

### Multi-Tenancy

**Threat**: Tenant A accesses Tenant B's resources

**Mitigations**:
- Network policies (isolate namespaces)
- RBAC (namespace-scoped roles)
- SCCs (prevent privileged containers)

### Node Access

**Threat**: Container escapes to node

**Mitigations**:
- SCCs (restrict privileged, hostPath, hostNetwork)
- SELinux enforcement
- Read-only root filesystems

## Examples

| Component | Threat Identified | Mitigation |
|-----------|------------------|-----------|
| console-operator | XSS in console UI | CSP headers, input sanitization |
| machine-api-operator | Cloud credentials exposure | Short-lived credentials, credential rotation |
| cluster-network-operator | Network policy bypass | Default-deny policies, validation webhooks |

## References

- **STRIDE**: https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats
- **OpenShift Security**: [security-guidelines.md](./security-guidelines.md)
- **Secrets Management**: [secrets-management.md](./secrets-management.md)
```

#### 5.4: `practices/reliability/slo-framework.md`

```markdown
# SLO Framework

**Category**: Engineering Practice  
**Applies To**: All OpenShift ClusterOperators  
**Last Updated**: YYYY-MM-DD  

## Overview

Service Level Objectives (SLOs) define reliability targets for OpenShift components.

## Definitions

| Term | Definition | Example |
|------|-----------|---------|
| **SLI** | Service Level Indicator (metric) | API request success rate |
| **SLO** | Service Level Objective (target) | 99.9% of API requests succeed |
| **SLA** | Service Level Agreement (contract) | 99.5% uptime or refund |
| **Error Budget** | Allowed failure rate | 0.1% = ~43 minutes/month downtime |

## OpenShift SLO Structure

### Availability SLO

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: my-operator-slos
spec:
  groups:
  - name: my-operator-availability
    interval: 30s
    rules:
    - record: my_operator:availability:ratio_rate5m
      expr: |
        sum(rate(my_operator_reconcile_success_total[5m]))
        /
        sum(rate(my_operator_reconcile_total[5m]))
    - alert: MyOperatorSLOAvailabilityBudgetBurn
      expr: my_operator:availability:ratio_rate5m < 0.999
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "My Operator availability below SLO (current: {{ $value }})"
```

### Latency SLO

```yaml
- record: my_operator:latency:p99_rate5m
  expr: histogram_quantile(0.99, rate(my_operator_reconcile_duration_seconds_bucket[5m]))

- alert: MyOperatorSLOLatencyBudgetBurn
  expr: my_operator:latency:p99_rate5m > 5
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "My Operator P99 latency above SLO (current: {{ $value }}s, target: <5s)"
```

## Calculating Error Budget

**Formula**: `Error Budget = (1 - SLO) × Time Window`

**Example** (99.9% monthly SLO):
```
Error Budget = (1 - 0.999) × 30 days × 24 hours × 60 minutes
             = 0.001 × 43,200 minutes
             = 43.2 minutes per month
```

## Error Budget Policy

### Budget Remaining > 50%

- ✅ Ship new features
- ✅ Perform experiments
- ✅ Deploy during business hours

### Budget Remaining 10-50%

- ⚠️ Slow down feature velocity
- ⚠️ Focus on reliability fixes
- ⚠️ Require deployment approval

### Budget Exhausted (<10%)

- ❌ Feature freeze
- ❌ Focus ONLY on reliability
- ❌ Root cause analysis required

## Implementation

### 1. Define SLIs

```go
// Instrument code with metrics
reconcileTotal := prometheus.NewCounterVec(
    prometheus.CounterOpts{
        Name: "my_operator_reconcile_total",
        Help: "Total reconciliations",
    },
    []string{"result"}, // "success" or "error"
)

reconcileDuration := prometheus.NewHistogramVec(
    prometheus.HistogramOpts{
        Name:    "my_operator_reconcile_duration_seconds",
        Help:    "Reconciliation duration",
        Buckets: prometheus.DefBuckets,
    },
    []string{},
)
```

### 2. Define SLOs

```markdown
## My Operator SLOs

| SLO | Target | Measurement Window |
|-----|--------|-------------------|
| Availability | 99.9% | 30 days |
| P99 Latency | <5s | 5 minutes |
| Error Rate | <0.1% | 1 hour |
```

### 3. Monitor Error Budget

```promql
# Error budget consumption rate (30-day window)
(1 - my_operator:availability:ratio_rate30d) / (1 - 0.999)
```

## Examples

| Component | SLO | Error Budget Policy |
|-----------|-----|---------------------|
| kube-apiserver | 99.9% availability | Feature freeze if budget exhausted |
| machine-config-operator | 99% node configuration success | Require approval for risky changes |
| cluster-network-operator | P95 < 10s network configuration | Alert if P95 > 10s for >5min |

## References

- **SRE Book**: https://sre.google/sre-book/service-level-objectives/
- **Error Budgets**: https://sre.google/workbook/error-budget-policy/
- **OpenShift Monitoring**: [observability.md](./observability.md)
```

#### 5.5: `practices/development/git-workflow.md`

```markdown
# Git Workflow

**Category**: Engineering Practice  
**Applies To**: All OpenShift repositories  
**Last Updated**: YYYY-MM-DD  

## Overview

Standard Git workflow for OpenShift development.

## Branch Strategy

### Main Branches

```
master (or main)
  ↓
release-4.16
  ↓
release-4.15
  ↓
release-4.14
```

**Rules**:
- `master`: Active development, latest code
- `release-X.Y`: Maintained releases, backports only
- All changes go to `master` first, then cherry-pick to release branches

### Feature Branches

```
username/feature-description
  └─> PR to master
```

**Naming**:
- `username/OCPBUGS-12345-fix-memory-leak`
- `username/add-webhook-support`
- `username/update-dependencies`

## Commit Messages

### Format

```
<area>: <short summary (50 chars)>

<Detailed explanation (72 chars per line)>

Why this change is needed.
What it changes.
How it was tested.

Fixes: https://issues.redhat.com/browse/OCPBUGS-12345
```

### Examples

**Good**:
```
controller: Fix memory leak in reconciliation loop

The reconcile loop was not releasing watch handles, causing
memory to grow unbounded over time.

Added finalizer to clean up watches when resources are deleted.

Tested by running operator for 24h with 1000 resources.
Memory usage now stable at 100MB.

Fixes: https://issues.redhat.com/browse/OCPBUGS-12345
```

**Bad**:
```
fix bug
```

### Commit Message Rules

1. ✅ Start with lowercase area: `controller:`, `pkg/util:`, `docs:`
2. ✅ Imperative mood: "Fix bug" not "Fixed bug"
3. ✅ 50 char summary, 72 char body lines
4. ✅ Reference Jira/GitHub issues
5. ❌ Don't end summary with period

## Pull Request Workflow

### 1. Create Feature Branch

```bash
git checkout -b username/OCPBUGS-12345-fix-leak master
```

### 2. Make Changes

```bash
git add pkg/controller/reconcile.go
git commit -m "controller: Fix memory leak in reconciliation loop

..."
```

### 3. Push and Create PR

```bash
git push origin username/OCPBUGS-12345-fix-leak

# Create PR via GitHub UI or CLI
gh pr create --base master --head username/OCPBUGS-12345-fix-leak
```

### 4. Address Review Comments

```bash
# Make changes
git add pkg/controller/reconcile.go
git commit --amend  # Amend last commit
git push --force    # Force push (safe on feature branch)
```

### 5. Merge

**Options**:
- **Squash merge**: Multiple commits → single commit (preferred for small changes)
- **Merge commit**: Preserve commit history (preferred for large features)
- **Rebase**: Never use (breaks cherry-pick traceability)

## Cherry-Picking to Release Branches

### When to Cherry-Pick

- ✅ Bug fixes
- ✅ Security patches
- ✅ Documentation updates
- ❌ New features (except in rare cases)

### Process

```bash
# 1. Merge to master first
# 2. After merge, cherry-pick to release branch

git checkout release-4.16
git cherry-pick <commit-sha>

# If conflicts, resolve and continue
git cherry-pick --continue

# Create PR for release branch
git push origin username/OCPBUGS-12345-fix-leak-4.16
gh pr create --base release-4.16
```

### Cherry-Pick PR Format

```
[release-4.16] controller: Fix memory leak

Cherry-pick of #123

Original commit: abc123

/cherry-pick release-4.15
```

## Revert Process

```bash
# Create revert commit
git revert <commit-sha>

# Create PR
git push origin username/revert-memory-leak-fix
gh pr create --base master
```

**Revert commit message**:
```
Revert "controller: Fix memory leak"

This reverts commit abc123.

Reason: Introduced regression in reconciliation latency.
Breaking CI: https://prow.ci.openshift.org/...

Will resubmit with fix after investigation.
```

## Examples

| Repository | Branch Strategy | Merge Policy |
|------------|----------------|--------------|
| kubernetes/kubernetes | master + release branches | Squash for small, merge for large |
| openshift/machine-config-operator | master + release branches | Squash preferred |
| openshift/enhancements | master only | Squash always |

## References

- **OpenShift Git Workflow**: [dev-guide/git-workflow.md](../../dev-guide/git-workflow.md)
- **Commit Message Guide**: https://www.conventionalcommits.org/
- **Cherry-Pick Guide**: [dev-guide/cherry-picks.md](../../dev-guide/cherry-picks.md)
```

**Repeat for** (follow the structure and patterns from pyramid.md, e2e-framework.md, threat-modeling.md, slo-framework.md, and git-workflow.md above):
- `practices/testing/ci-integration.md` - Prow and OpenShift CI integration, job configuration
- `practices/testing/test-flake-policy.md` - Flake definition, quarantine process, fixing flakes
- `practices/security/rbac-guidelines.md` - Least privilege, Role vs ClusterRole, ServiceAccount design
- `practices/security/secrets-management.md` - Secret rotation, avoiding logs, external secret stores
- `practices/reliability/observability.md` - Metrics, logging, tracing, debugging
- `practices/reliability/alerting.md` - Alert design, runbooks, on-call best practices
- `practices/development/code-review.md` - LGTM/approval process, review checklist
- `practices/development/api-evolution.md` - API versioning, deprecation policy, breaking changes

### Phase 5: Create Domain Concepts

**Goal:** Document Kubernetes and OpenShift fundamentals

#### 6.1: `domain/kubernetes/pods.md`

```markdown
# Pods

**Type**: Kubernetes Core Concept  
**Last Updated**: YYYY-MM-DD  

## Overview

Pod is the smallest deployable unit in Kubernetes.

## Key Concepts

- **Containers**: One or more containers
- **Shared Network**: All containers share network namespace (localhost)
- **Shared Storage**: Volumes mounted into containers
- **Lifecycle**: Pending → Running → Succeeded/Failed

## Common Patterns

### Init Containers
```yaml
spec:
  initContainers:
  - name: init
    image: busybox
    command: ['sh', '-c', 'setup']
  containers:
  - name: app
    image: myapp
```

**Use case:** Setup before main container starts

### Sidecar Pattern
```yaml
spec:
  containers:
  - name: app
    image: myapp
  - name: sidecar
    image: logging-agent
```

**Use case:** Additional functionality alongside main container

### Resource Limits
```yaml
spec:
  containers:
  - name: app
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

## Pod Lifecycle

| Phase | Meaning |
|-------|---------|
| Pending | Waiting for scheduling |
| Running | At least one container running |
| Succeeded | All containers completed successfully |
| Failed | At least one container failed |
| Unknown | Cannot determine state |

## Related Concepts

- **Deployment**: Manages Pods via ReplicaSets ([deployments.md](./deployments.md))
- **Service**: Exposes Pods ([services.md](./services.md))
- **Node**: Where Pods run ([nodes.md](./nodes.md))

## References

- **Upstream**: https://kubernetes.io/docs/concepts/workloads/pods/
```

**Repeat for:**
- `domain/kubernetes/nodes.md` - Node concept, conditions, taints/tolerations
- `domain/kubernetes/services.md` - Service discovery, endpoints
- `domain/kubernetes/deployments.md` - Deployment, ReplicaSet, rollout
- `domain/kubernetes/crds.md` - CustomResourceDefinition patterns

#### 6.2: `domain/openshift/clusteroperator.md`

```markdown
# ClusterOperator

**Type**: OpenShift Platform Concept  
**Last Updated**: YYYY-MM-DD  

## Overview

ClusterOperator is how operators report status to CVO (Cluster Version Operator).

## API Structure

```yaml
apiVersion: config.openshift.io/v1
kind: ClusterOperator
metadata:
  name: machine-config
spec: {}
status:
  conditions:
  - type: Available
    status: "True"
    reason: "AsExpected"
    message: "All components running"
  - type: Progressing
    status: "False"
    reason: "AsExpected"
  - type: Degraded
    status: "False"
    reason: "AsExpected"
  versions:
  - name: operator
    version: 4.15.0
  relatedObjects:
  - group: machineconfiguration.openshift.io
    resource: machineconfigpools
    name: worker
```

## Lifecycle

1. **Operator creates/updates ClusterOperator**
   - Sets status conditions
   - Reports current version
   - Lists related objects

2. **CVO monitors all ClusterOperators**
   - Aggregates status for ClusterVersion
   - Coordinates upgrades
   - Detects degraded operators

3. **ClusterVersion reflects overall state**
   - Available if all operators Available
   - Progressing if any operator Progressing
   - Degraded if any operator Degraded

## Status Conditions

See [status-conditions.md](../../platform/operator-patterns/status-conditions.md) for pattern details.

## Examples by Component

| Component | ClusterOperator Name | Notes |
|-----------|---------------------|-------|
| machine-config-operator | machine-config | Reports node update status |
| cluster-network-operator | network | Reports SDN/OVN status |
| cluster-version-operator | version | Reports cluster version |

## References

- **Pattern**: [status-conditions.md](../../platform/operator-patterns/status-conditions.md)
- **CVO**: [clusterversion.md](./clusterversion.md)
- **API**: https://github.com/openshift/api/blob/master/config/v1/types_cluster_operator.go
```

#### 6.3: `domain/kubernetes/services.md`

```markdown
# Services

**Type**: Kubernetes Core Concept  
**Last Updated**: YYYY-MM-DD  

## Overview

Service provides stable network endpoint for accessing Pods.

## Key Concepts

- **Stable IP**: Service gets a cluster IP that doesn't change
- **Load Balancing**: Distributes traffic across Pod replicas
- **Service Discovery**: DNS name for the service (my-svc.my-namespace.svc.cluster.local)
- **Port Mapping**: Map service port to container port

## Service Types

| Type | Purpose | When to Use |
|------|---------|-------------|
| **ClusterIP** | Internal cluster access | Most services |
| **NodePort** | External access via node IP | Testing, legacy apps |
| **LoadBalancer** | External load balancer | Cloud environments |
| **ExternalName** | DNS CNAME | External service alias |

## Examples

### ClusterIP (Default)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: ClusterIP
  selector:
    app: myapp
  ports:
  - port: 80        # Service port
    targetPort: 8080 # Container port
```

**Access**: `http://my-service.my-namespace.svc.cluster.local`

### NodePort

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: NodePort
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
    nodePort: 30080  # 30000-32767
```

**Access**: `http://<node-ip>:30080`

### LoadBalancer

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-service
spec:
  type: LoadBalancer
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

**Access**: `http://<external-ip>` (cloud provider assigns)

### Headless Service (No ClusterIP)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-headless-service
spec:
  clusterIP: None
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 8080
```

**Use case**: StatefulSets, direct Pod access (returns Pod IPs in DNS)

## Service Discovery

### DNS

```bash
# Within same namespace
curl http://my-service

# Cross-namespace
curl http://my-service.other-namespace

# Fully qualified
curl http://my-service.my-namespace.svc.cluster.local
```

### Environment Variables

```bash
# Kubernetes injects these automatically
MY_SERVICE_SERVICE_HOST=10.96.0.10
MY_SERVICE_SERVICE_PORT=80
```

## Session Affinity

```yaml
spec:
  sessionAffinity: ClientIP
  sessionAffinityConfig:
    clientIP:
      timeoutSeconds: 3600
```

**Use case**: Sticky sessions (same client → same Pod)

## OpenShift Considerations

### Routes vs Services

```yaml
# Service (internal)
apiVersion: v1
kind: Service
---
# Route (external, OpenShift-specific)
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: my-route
spec:
  to:
    kind: Service
    name: my-service
```

See [route.md](../openshift/route.md) for details.

## Examples in OpenShift

| Component | Service Type | Purpose |
|-----------|-------------|---------|
| kube-apiserver | ClusterIP + LoadBalancer | Internal + external API access |
| console | ClusterIP + Route | Web console access |
| prometheus | ClusterIP | Metrics collection |

## References

- **Kubernetes Services**: https://kubernetes.io/docs/concepts/services-networking/service/
- **OpenShift Routes**: [route.md](../openshift/route.md)
- **DNS**: https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/
```

#### 6.4: `domain/openshift/clusterversion.md`

```markdown
# ClusterVersion

**Type**: OpenShift Platform Concept  
**Last Updated**: YYYY-MM-DD  

## Overview

ClusterVersion represents the desired and current version of the OpenShift cluster.

## Key Concepts

- **Desired Version**: Target OpenShift version (from update payload)
- **Current Version**: Actively running version
- **Update Payload**: Container image with all operators and manifests
- **Upgrade Ordering**: CVO coordinates operator upgrades

## API Structure

```yaml
apiVersion: config.openshift.io/v1
kind: ClusterVersion
metadata:
  name: version  # Singleton
spec:
  channel: stable-4.16
  clusterID: abc123
  desiredUpdate:
    version: 4.16.1
    image: quay.io/openshift-release-dev/ocp-release@sha256:...
status:
  desired:
    version: 4.16.1
    image: quay.io/openshift-release-dev/ocp-release@sha256:...
  history:
  - version: 4.16.1
    state: Completed
    startedTime: "2024-01-15T10:00:00Z"
    completionTime: "2024-01-15T10:45:00Z"
  - version: 4.16.0
    state: Completed
  conditions:
  - type: Available
    status: "True"
  - type: Progressing
    status: "False"
  - type: Failing
    status: "False"
```

## Upgrade Process

### 1. Check Available Updates

```bash
oc get clusterversion version -o json | jq '.status.availableUpdates'
```

### 2. Trigger Upgrade

```bash
oc adm upgrade --to=4.16.1

# Or edit ClusterVersion
oc edit clusterversion version
# Set spec.desiredUpdate.version
```

### 3. Monitor Progress

```bash
# Watch overall status
oc get clusterversion

# Watch operator status
oc get clusteroperators

# Watch CVO logs
oc logs -n openshift-cluster-version deployment/cluster-version-operator
```

## Upgrade Ordering

CVO ensures operators upgrade in the correct order:

```
1. Machine Config Operator (node updates)
   ↓
2. Kube API Server
   ↓
3. Kube Controller Manager
   ↓
4. Kube Scheduler
   ↓
5. Network Operator
   ↓
6. Other operators (parallel when possible)
```

## Update Channels

| Channel | Purpose | When to Use |
|---------|---------|-------------|
| **stable-4.16** | Stable releases | Production |
| **fast-4.16** | Early access | Testing new features |
| **candidate-4.16** | Pre-release | Early validation |
| **eus-4.16** | Extended Update Support | Long-term support |

## Conditions

| Condition | Meaning |
|-----------|---------|
| **Available** | Cluster is operational |
| **Progressing** | Upgrade in progress |
| **Failing** | Upgrade failed |
| **RetrievedUpdates** | Update graph fetched |

## Pausing Updates

```yaml
spec:
  overrides:
  - kind: Deployment
    group: apps
    name: console-operator
    namespace: openshift-console
    unmanaged: true  # Don't upgrade this operator
```

**Use case**: Pause specific operator during upgrade (emergency only)

## Version Skew Policy

- ✅ **Supported**: N → N+1 minor version (4.15 → 4.16)
- ❌ **Not supported**: N → N+2 (4.15 → 4.17, must go through 4.16)
- ✅ **Patch updates**: Always supported (4.16.0 → 4.16.5)

## Examples

### Check Current Version

```bash
oc get clusterversion version -o jsonpath='{.status.history[0].version}'
```

### Check Upgrade Status

```bash
oc get clusterversion version -o jsonpath='{.status.conditions[?(@.type=="Progressing")].message}'
```

### Force Upgrade (Override Version)

```bash
oc adm upgrade --to-image=quay.io/openshift-release-dev/ocp-release@sha256:... --force
```

**⚠️ Warning**: Only use `--force` for disaster recovery

## Component Relationship

| Component | Role |
|-----------|------|
| **cluster-version-operator** | Manages ClusterVersion, coordinates upgrades |
| **ClusterOperators** | Report status to CVO via conditions |
| **Update Service** | Provides update graph (Cincinnati) |

## References

- **CVO**: [Cluster Version Operator](../../references/components/cluster-version-operator.md)
- **Update Process**: [upgrade-process.md](../../workflows/upgrade-process.md)
- **Operator Patterns**: [status-conditions.md](../../platform/operator-patterns/status-conditions.md)
- **API**: https://github.com/openshift/api/blob/master/config/v1/types_cluster_version.go
```

**Repeat for** (follow the structure and patterns from pods.md, clusteroperator.md, services.md, and clusterversion.md above):
- `domain/kubernetes/nodes.md` - Node lifecycle, taints and tolerations, node selectors
- `domain/kubernetes/crds.md` - Custom Resource Definitions, extending Kubernetes API
- `domain/openshift/machine.md` - Machine API concepts, node provisioning, autoscaling
- `domain/openshift/route.md` - Route vs Ingress, TLS termination, custom domains

### Phase 6: Create Cross-Repo ADRs

**Goal:** Document architectural decisions affecting multiple repos

#### 7.1: `decisions/adr-0002-etcd-backend.md`

```markdown
---
title: Use etcd for Cluster State
status: Accepted
date: YYYY-MM-DD
affected_components:
  - kube-apiserver
  - openshift-apiserver
  - all operators
---

# ADR 0002: Use etcd for Cluster State

## Status

**Accepted**

## Context

OpenShift needs persistent, consistent storage for cluster state.

## Decision

Use etcd as the backend for Kubernetes and OpenShift API servers.

## Rationale

- ✅ **Upstream alignment**: Kubernetes uses etcd
- ✅ **Strong consistency**: Raft consensus protocol
- ✅ **Performance**: Handles OpenShift scale (1000s of nodes)
- ✅ **Mature tooling**: Battle-tested in production

## Alternatives Considered

### PostgreSQL
- **Pro**: Relational database, familiar to many
- **Con**: Not K8s standard, would diverge from upstream

### Consul
- **Pro**: Similar to etcd, supports K/V store
- **Con**: Less K8s tooling, not upstream choice

### Custom Solution
- **Pro**: Could optimize for OpenShift use cases
- **Con**: High development/maintenance cost, unproven

## Consequences

**Positive**:
- Standard K8s patterns work
- Upstream knowledge applies
- Existing tools (etcdctl, backup/restore) work

**Negative**:
- etcd quorum loss = cluster down
- Must backup etcd for disaster recovery
- Upgrade procedures must handle etcd version compatibility

## Affected Components

- **kube-apiserver**: Stores K8s resources
- **openshift-apiserver**: Stores OpenShift resources
- **All operators**: Read state from API server backed by etcd

## Mitigation

- **Quorum loss**: Run etcd with 3+ members
- **Backups**: Automated etcd backup via etcd-operator
- **Upgrades**: Coordinated etcd version upgrades via CVO

## References

- **Upstream**: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/
- **etcd operator**: https://github.com/openshift/cluster-etcd-operator
```

**Repeat for:**
- `decisions/adr-0001-operator-sdk.md` - Use operator-sdk for new operators
- `decisions/adr-0003-cvo-upgrade-ordering.md` - CVO coordinates operator upgrades

#### 7.2: Create `decisions/index.md` and `decisions/adr-template.md`

```markdown
# Architectural Decision Records Index

**Last Updated**: YYYY-MM-DD  

## Purpose

Cross-repo architectural decisions affecting multiple OpenShift components.

## Active ADRs

| ADR | Title | Status | Date | Affected Components |
|-----|-------|--------|------|-------------------|
| [adr-0001](./adr-0001-operator-sdk.md) | Use operator-sdk for New Operators | Accepted | YYYY-MM-DD | All new operators |
| [adr-0002](./adr-0002-etcd-backend.md) | Use etcd for Cluster State | Accepted | YYYY-MM-DD | All components |
| [adr-0003](./adr-0003-cvo-upgrade-ordering.md) | CVO Coordinates Upgrades | Accepted | YYYY-MM-DD | All ClusterOperators |

## Template

See [adr-template.md](./adr-template.md) for creating new ADRs.

## When to Create ADR

Create ADR when:
- Decision affects >1 repository
- Significant architectural impact
- Alternatives were considered
- Rationale should be documented

**Don't create ADR for:**
- Component-specific decisions (use component's agentic/decisions/)
- Implementation details
- Temporary experiments
```

### Phase 7: Create Repository Index

**Goal:** Create index of all component repos

**File:** `references/repo-index.md`

```markdown
# OpenShift Repository Index

**Last Updated**: YYYY-MM-DD  

## Purpose

Map of all OpenShift component repositories with their agentic documentation.

## Core Platform

| Repo | Purpose | AGENTS.md | Agentic Docs | Status |
|------|---------|-----------|--------------|--------|
| [machine-config-operator](https://github.com/openshift/machine-config-operator) | OS configuration and updates | [AGENTS.md](https://github.com/openshift/machine-config-operator/blob/master/AGENTS.md) | [agentic/](https://github.com/openshift/machine-config-operator/tree/master/agentic) | ✅ Pilot |
| [cluster-version-operator](https://github.com/openshift/cluster-version-operator) | Platform updates | [AGENTS.md](link) | [agentic/](link) | ⏳ Planned |
| [installer](https://github.com/openshift/installer) | Cluster installation | [AGENTS.md](link) | [agentic/](link) | ⏳ Planned |

## Networking

| Repo | Purpose | AGENTS.md | Agentic Docs | Status |
|------|---------|-----------|--------------|--------|
| [cluster-network-operator](https://github.com/openshift/cluster-network-operator) | SDN/OVN networking | [AGENTS.md](link) | [agentic/](link) | 📝 Not started |

## Storage

[Add storage components...]

## By Capability

### OS Management
- **Primary**: machine-config-operator
- **Related**: installer (first-boot), rhcos (OS images)

### Node Lifecycle
- **Primary**: machine-api-operator
- **Related**: installer (initial nodes), machine-config-operator (OS)

### Upgrades
- **Primary**: cluster-version-operator
- **Related**: machine-config-operator (OS updates), machine-api-operator (node updates)

[Add all capabilities...]

## Status Legend

- ✅ Tier 2 implemented
- ⏳ Planned
- 📝 Not started
```

**Also create** (follow repo-index.md pattern):
- `references/index.md` - Navigation hub for all reference materials
- `references/glossary.md` - OpenShift and Kubernetes terminology
- `references/enhancement-index.md` - Index of all enhancements by category
- `references/api-reference.md` - Quick reference for platform APIs

### Phase 7.5: Create Index Files

**Goal:** Create index/navigation files for major sections

#### 8.5.1: `practices/testing/index.md`

```markdown
# Testing Practices Index

**Last Updated**: YYYY-MM-DD  

## Overview

Testing practices for OpenShift components.

## Test Types

| Practice | Purpose | File |
|----------|---------|------|
| Testing Pyramid | Test distribution strategy | [pyramid.md](./pyramid.md) |
| E2E Framework | openshift-tests usage | [e2e-framework.md](./e2e-framework.md) |
| CI Integration | Prow and OpenShift CI | [ci-integration.md](./ci-integration.md) |
| Test Flake Policy | Handling flaky tests | [test-flake-policy.md](./test-flake-policy.md) |

## Quick Start

1. Write unit tests first (fastest feedback)
2. Add integration tests for component interactions
3. Add E2E tests for critical user workflows
4. Monitor test flakes and quarantine if needed

## See Also

- [Pyramid](./pyramid.md) - Distribution strategy
- [CI Integration](./ci-integration.md) - Running tests in CI
- [Security Testing](../security/) - Security-specific tests
```

**Also create** (similar pattern):
- `references/index.md` - Hub for glossary, enhancement-index, api-reference, repo-index

### Phase 7.6: Create Workflow Documentation

**Goal:** Document common OpenShift development workflows

#### 8.6.1: `workflows/enhancement-process.md`

```markdown
# Enhancement Process

**Last Updated**: YYYY-MM-DD  

## Overview

How to propose and implement enhancements in OpenShift.

## Process Flow

```
1. Proposal → 2. Review → 3. Approval → 4. Implementation → 5. Graduation
```

## 1. Write Enhancement Proposal

Create `enhancements/<area>/<feature-name>.md`:

```markdown
---
title: Feature Name
authors:
  - "@your-github"
reviewers:
  - "@reviewer1"
approvers:
  - "@approver1"
creation-date: 2024-01-15
last-updated: 2024-01-15
status: provisional
---

# Feature Name

## Summary

[One paragraph summary]

## Motivation

### Goals
- Goal 1
- Goal 2

### Non-Goals
- Non-goal 1

## Proposal

[Detailed design]

## Implementation History
- 2024-01-15: Initial proposal
```

## 2. Submit for Review

```bash
git checkout -b enhancements/my-feature
git add enhancements/my-area/my-feature.md
git commit -m "Enhancement: My Feature"
gh pr create
```

## 3. Address Review Comments

Reviewers will check:
- **Technical feasibility**
- **Alignment with OpenShift goals**
- **Upgrade impact**
- **API design**
- **User experience**

## 4. Get Approval

Required approvals:
- ✅ Area owner (OWNERS file)
- ✅ API reviewers (if adding/changing APIs)
- ✅ Architecture review (for large changes)

## 5. Implement

After approval:
```bash
# Create implementation PRs referencing enhancement
git commit -m "Implement my-feature

Enhancement: https://github.com/openshift/enhancements/pull/123"
```

## 6. Graduate (if applicable)

For features with maturity levels:
- **Alpha**: Tech preview, may change
- **Beta**: Supported, API stable
- **GA**: Fully supported, production-ready

## References

- [Enhancement Template](https://github.com/openshift/enhancements/blob/master/TEMPLATE.md)
- [Review Process](https://github.com/openshift/enhancements/blob/master/PROCESS.md)
```

#### 8.6.2: `workflows/implementing-features.md`

```markdown
# Implementing Features

**Last Updated**: YYYY-MM-DD  

## Overview

Workflow for implementing approved enhancements.

## Prerequisites

- ✅ Enhancement proposal approved
- ✅ Design finalized
- ✅ API review complete (if adding APIs)

## Implementation Steps

### 1. Break Down Work

```markdown
## Implementation Plan
- [ ] API changes (if any)
- [ ] Controller implementation
- [ ] E2E tests
- [ ] Documentation
- [ ] Upgrade testing
```

### 2. API Changes First

If adding/changing APIs:

```bash
# 1. Update openshift/api
cd openshift/api
# Add CRD types
git commit -m "API: Add MyResource type"

# 2. Vendor into your repo
cd openshift/my-operator
go get github.com/openshift/api@latest
go mod vendor
```

### 3. Implement Controller

```go
// pkg/controller/myresource/controller.go
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    // Implementation
}
```

### 4. Add Tests

```bash
# Unit tests
make test-unit

# Integration tests
make test-integration

# E2E tests
make test-e2e
```

### 5. Update Documentation

- Update AGENTS.md with new feature
- Add domain docs if new concepts
- Update exec-plans

### 6. Test Upgrades

```bash
# Install old version
openshift-install create cluster --version=4.15.0

# Upgrade to new version with feature
oc adm upgrade --to=4.16.0-rc
```

### 7. Submit PRs

```bash
# Reference enhancement in all PRs
git commit -m "Implement my-feature controller

This implements the controller for my-feature as described in:
https://github.com/openshift/enhancements/pull/123

Testing: Unit + integration + E2E tests included"
```

## Best Practices

1. **Start with tests**: Write failing tests, then implement
2. **Small PRs**: Break large features into reviewable chunks
3. **Document as you go**: Update docs in same PR as code
4. **Test upgrades**: Verify feature works across upgrades
5. **Monitor CI**: Fix flakes immediately

## Common Pitfalls

- ❌ Implementing before approval
- ❌ Skipping API review
- ❌ Not testing upgrades
- ❌ Large, monolithic PRs
- ❌ Missing documentation

## References

- [Enhancement Process](./enhancement-process.md)
- [Testing Practices](../practices/testing/)
- [API Evolution](../practices/development/api-evolution.md)
```

### Phase 7.7: Add MachineConfig Domain Doc

**Goal:** Document platform-level MachineConfig API

**File:** `domain/openshift/machineconfig.md`

```markdown
# MachineConfig & MachineConfigPool

**Type**: OpenShift Platform API  
**API Group**: `machineconfiguration.openshift.io/v1`  
**Repository**: [openshift/api](https://github.com/openshift/api)  
**Managed By**: [machine-config-operator](https://github.com/openshift/machine-config-operator)  

## Overview

MachineConfig defines operating system configuration for OpenShift nodes. While managed by machine-config-operator, this is a platform-level API used across OpenShift.

**Key principle**: Nodes are immutable. OS changes require reboot.

## MachineConfig

Defines OS configuration fragment:

```yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 99-worker-custom
spec:
  kernelArguments:
  - 'systemd.unified_cgroup_hierarchy=0'
  config:
    ignition:
      version: 3.2.0
    storage:
      files:
      - path: /etc/myapp/config.yaml
        mode: 0644
        contents:
          source: data:,example-content
```

## MachineConfigPool

Groups nodes and manages rollout:

```yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfigPool
metadata:
  name: worker
spec:
  machineConfigSelector:
    matchLabels:
      machineconfiguration.openshift.io/role: worker
  nodeSelector:
    matchLabels:
      node-role.kubernetes.io/worker: ""
  maxUnavailable: 1  # Rolling update constraint
```

## When to Use

- ✅ Configure OS-level settings (sysctls, kernel args)
- ✅ Deploy files to nodes
- ✅ Configure systemd units
- ❌ Application configuration (use ConfigMaps)
- ❌ Secrets (use Secrets API)

## Lifecycle

```
Create MachineConfig → MCO renders for pool → Node applies → Node reboots
```

**Important**: Nodes reboot to apply changes!

## Examples

| Use Case | Example |
|----------|---------|
| Kernel tuning | Set vm.max_map_count for Elasticsearch |
| CA certificates | Add custom CA to /etc/pki/ca-trust |
| Network config | Configure bonding, VLANs |
| Systemd units | Deploy custom systemd service |

## Component Usage

| Component | Uses MachineConfig For |
|-----------|------------------------|
| cluster-network-operator | Network interface configuration |
| kubelet | Kubelet config overrides |
| crio | Container runtime configuration |

## References

- **Managed By**: [machine-config-operator](../../references/repo-index.md#machine-config-operator)
- **API Docs**: https://github.com/openshift/api/blob/master/machineconfiguration/v1/types.go
- **Best Practices**: See MCO documentation for detailed usage
```

**Note**: MachineConfig is included in Tier 1 because it's a platform API in openshift/api used by multiple components, even though it's managed by machine-config-operator.

### Phase 8: Validation

**Goal:** Verify Tier 1 structure and compliance

**Actions - Run validation script:**
```bash
# Find the skill directory
SKILL_DIR=$(find ~/.claude/plugins/cache -path "*/agentic-docs-creator" -type d | head -1)
REPO_PATH="${provided_path:-$PWD}"

# Run validation
bash "$SKILL_DIR/scripts/validate.sh" "$REPO_PATH"
```

**What the script checks:**
- OPENSHIFT_AGENTS.md exists and is ~150-170 lines
- All required directories present
- All required files exist
- No component-specific content in Tier 1
- Links are valid
- Structure complies with SPECIFICATION.md

### Phase 9: Report Results

**Goal:** Summarize what was created

**Output:**
```
✅ Tier 1 Agentic Documentation Created

Repository: openshift/enhancements
Location: /agentic

Structure Created:
  - OPENSHIFT_AGENTS.md: $AGENTS_LINES lines (target: ~150-170) ✅
  - platform/operator-patterns/: 9 files
  - platform/openshift-specifics/: 2 files
  - practices/testing/: 4 files
  - practices/security/: 3 files
  - practices/reliability/: 3 files
  - practices/development/: 3 files
  - domain/kubernetes/: 5 files
  - domain/openshift/: 4 files
  - decisions/: 4 files (3 ADRs + index + template)
  - references/: 1 file (repo-index.md)

Validation:
  ✅ OPENSHIFT_AGENTS.md ~150-170 lines
  ✅ All required directories present
  ✅ All required files present
  ✅ No component-specific content detected

Next Steps:
  1. Review documentation for accuracy
  2. Add more ADRs as needed
  3. Populate repo-index.md with all components
  4. Create component Tier 2 docs:
     cd /path/to/machine-config-operator
     /agentic-docs-tier2
  5. Create git commit:
     git add agentic/
     git commit -m "Add Tier 1 agentic documentation
     
     Creates ecosystem hub for all OpenShift components.
     
     Structure:
     - Platform patterns (operator patterns, OpenShift specifics)
     - Engineering practices (testing, security, reliability)
     - Domain concepts (K8s and OpenShift fundamentals)
     - Cross-repo ADRs
     - Repository index for discovery
     
     Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"
```

## Validation Criteria

**Tier 1 docs pass when:**
- ✅ OPENSHIFT_AGENTS.md ~150-170 lines
- ✅ All platform patterns documented (≥5 operator patterns)
- ✅ All practices documented (testing, security, reliability, development)
- ✅ All cross-repo ADRs present (≥3 ADRs)
- ✅ No component-specific content (except in examples)
- ✅ Repository index exists

**Forbidden in Tier 1** (belongs in Tier 2):
- Component-specific domain concepts (e.g., "MachineConfig" as main topic)
- Component architecture (e.g., "MCD/MCC/MCS components")
- Component-specific decisions (e.g., "Why MCO uses rpm-ostree")
- Component work tracking (exec-plans)

## Common Mistakes to Avoid

### Mistake 1: Including Component-Specific Content

**Wrong:**
```markdown
# domain/openshift/machineconfig.md

MachineConfig is how MCO manages node configuration...
```

**Right:**
```markdown
# This belongs in Tier 2 (machine-config-operator/agentic/domain/machineconfig.md)
```

### Mistake 2: OPENSHIFT_AGENTS.md Too Long

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
See [platform/operator-patterns/](./platform/operator-patterns/)
```

### Mistake 3: Duplicating dev-guide Content

**Wrong:**
```markdown
# Copying dev-guide/operators.md verbatim
```

**Right:**
```markdown
# Structure for AI parsing, link to dev-guide for narrative

See [dev-guide/operators.md](../dev-guide/operators.md) for tutorial.
```

## References

This skill implementation is based on:
- **TWO_TIER_RULEBOOK.md** - Phases 1-8 for Tier 1
- **TWO_TIER_AGENTIC_DOCS.md** - Full architecture and decision matrix
- **AGENTIC_DOCS_RULEBOOK.md** - Content guidance (adapted for Tier 1)

---

**Pattern**: Two-tier agentic documentation (Tier 1 ecosystem hub)  
**Version**: 1.0
