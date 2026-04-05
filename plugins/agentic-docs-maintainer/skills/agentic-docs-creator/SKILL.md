---
name: agentic-docs-creator
description: Create Tier 1 agentic documentation (ecosystem hub) in openshift/enhancements
trigger: explicit
model: sonnet
---

# Agentic Docs Creator - Tier 1 Ecosystem Hub

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

## Task Execution

When the user invokes this skill, execute the following:

### Phase 1: Assessment and Validation

**Goal:** Verify this is openshift/enhancements and Tier 1 doesn't already exist

**Actions:**
```bash
# Parse arguments to get repo path
REPO_PATH="${provided_path:-$PWD}"

# Verify this is openshift/enhancements
if [ ! -d "$REPO_PATH/enhancements" ] || [ ! -d "$REPO_PATH/dev-guide" ]; then
    echo "❌ ERROR: This doesn't appear to be openshift/enhancements repository"
    echo "Expected directories: enhancements/, dev-guide/"
    exit 1
fi

# Check if /agentic already exists
if [ -d "$REPO_PATH/agentic" ]; then
    echo "❌ ERROR: /agentic directory already exists"
    echo "Use agentic-docs-maintainer for maintenance instead"
    exit 1
fi

# Verify write permissions
if [ ! -w "$REPO_PATH" ]; then
    echo "❌ ERROR: No write permission to $REPO_PATH"
    exit 1
fi

echo "✅ Repository verified: openshift/enhancements"
echo "✅ Ready to create Tier 1 structure"
```

**Output:** Confirmation that prerequisites are met

### Phase 2: Create Directory Structure

**Goal:** Set up Tier 1 directory structure

**Actions:**
```bash
cd "$REPO_PATH"

# Create main structure
mkdir -p agentic/{platform,practices,domain,decisions,workflows,references}

# Create platform subdirectories
mkdir -p agentic/platform/{operator-patterns,openshift-specifics}

# Create practices subdirectories
mkdir -p agentic/practices/{testing,security,reliability,development}

# Create domain subdirectories
mkdir -p agentic/domain/{kubernetes,openshift}

echo "✅ Directory structure created"
```

**Expected structure:**
```
enhancements/
├── enhancements/        [EXISTING - keep as-is]
├── dev-guide/           [EXISTING - keep as-is]
└── agentic/             [NEW]
    ├── OPENSHIFT_AGENTS.md
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

### Phase 3: Create Master Entry Point

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

### Phase 4: Create Platform Patterns

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

**Repeat for:**
- `leader-election.md` - How leader election works, library-go usage
- `rbac-patterns.md` - ServiceAccount design, Role/ClusterRole patterns
- `finalizers.md` - Resource cleanup patterns
- `webhooks.md` - Admission controller webhooks
- `owner-references.md` - Resource ownership and garbage collection
- `upgrade-strategies.md` - Rolling updates, version skew
- `must-gather.md` - Diagnostic data collection pattern

#### 4.3: Create `platform/operator-patterns/index.md`

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

### Phase 5: Create Engineering Practices

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

**Repeat for:**
- `practices/testing/ci-integration.md` - Prow and OpenShift CI
- `practices/testing/test-flake-policy.md` - Flake definition, quarantine
- `practices/security/threat-modeling.md` - STRIDE framework
- `practices/security/rbac-guidelines.md` - Least privilege, role design
- `practices/security/secrets-management.md` - Secret rotation, avoiding logs
- `practices/reliability/slo-framework.md` - SLO definition, error budgets
- `practices/reliability/observability.md` - Metrics, logging, tracing
- `practices/reliability/alerting.md` - Alert design, runbooks
- `practices/development/git-workflow.md` - Branching, commit messages
- `practices/development/code-review.md` - LGTM/approval process
- `practices/development/api-evolution.md` - Versioning, deprecation

### Phase 6: Create Domain Concepts

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

**Repeat for:**
- `domain/openshift/clusterversion.md` - ClusterVersion, upgrades
- `domain/openshift/machine.md` - Machine API concepts
- `domain/openshift/route.md` - Route vs Ingress

### Phase 7: Create Cross-Repo ADRs

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

### Phase 8: Create Repository Index

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

### Phase 9: Validation

**Goal:** Verify Tier 1 structure and compliance

**Actions:**
```bash
cd "$REPO_PATH/agentic"

# 1. Check entry point size
AGENTS_LINES=$(wc -l < OPENSHIFT_AGENTS.md)
if [ "$AGENTS_LINES" -gt 150 ]; then
    echo "⚠️  OPENSHIFT_AGENTS.md is $AGENTS_LINES lines (recommended: 150-170)"
fi
echo "✅ OPENSHIFT_AGENTS.md: $AGENTS_LINES lines"

# 2. Check all links are valid
echo "Checking links..."
find . -name "*.md" -exec grep -H '\[.*\](.*\.md)' {} \; > /tmp/links.txt
# TODO: Validate each link exists

# 3. Check no component-specific content
if grep -r "machine-config-operator\|MCO-specific\|installer-specific" . | grep -v "repo-index.md" | grep -v "Examples"; then
    echo "⚠️  WARNING: Found component-specific content in Tier 1"
    echo "   Tier 1 should only contain cross-repo knowledge"
fi

# 4. Verify structure
for dir in platform practices domain decisions workflows references; do
    if [ ! -d "$dir" ]; then
        echo "❌ Missing required directory: $dir"
        exit 1
    fi
done
echo "✅ All required directories present"

# 5. Check required files
REQUIRED_FILES=(
    "OPENSHIFT_AGENTS.md"
    "platform/operator-patterns/index.md"
    "platform/operator-patterns/status-conditions.md"
    "platform/operator-patterns/controller-runtime.md"
    "practices/testing/pyramid.md"
    "practices/testing/e2e-framework.md"
    "domain/kubernetes/pods.md"
    "domain/openshift/clusteroperator.md"
    "decisions/index.md"
    "references/repo-index.md"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing required file: $file"
        exit 1
    fi
done
echo "✅ All required files present"

echo ""
echo "=================================="
echo "✅ Tier 1 Validation Complete"
echo "=================================="
echo "OPENSHIFT_AGENTS.md: $AGENTS_LINES lines"
echo "Structure: Complete"
echo "Links: (manual check needed)"
echo ""
echo "Next steps:"
echo "1. Review created documentation"
echo "2. Create git commit"
echo "3. Create component Tier 2 docs with agentic-docs-tier2 skill"
```

### Phase 10: Report Results

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
