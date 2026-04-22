---
name: spec
description: OpenShift feature specification - creates specs following enhancement template and agentic patterns. Use when starting a new operator feature, adding CRDs/APIs, or proposing enhancements.
trigger: explicit
model: sonnet
---

# Spec - OpenShift Feature Specification

## Overview

Create a feature specification following the OpenShift enhancement template and agentic documentation patterns. The spec uses `/fetch` to retrieve relevant patterns from Tier 1 (ecosystem hub) and Tier 2 (component docs), then guides you through creating a complete specification.

**Key Innovation**: Automatically fetches OpenShift patterns and guidelines before starting, ensuring your spec follows current best practices.

## What This Skill Operates On

**Input**: User requirements + fetched OpenShift patterns
- Feature description (from user)
- Fetched Tier 1 patterns: DESIGN_PHILOSOPHY, operator patterns, practices, ADRs
- Fetched Tier 2 architecture (if --component specified)
- Similar implementations (from fetch)

**Output**: Comprehensive 12-section specification
- SPEC-{feature-name}.md file
- Implementation guidance
- Compliance checklists
- References to fetched patterns

**Artifacts Created**:
- `SPEC-{feature-name}.md`
- Optional: `{component}/agentic/exec-plans/active/{feature-name}.md`

## When to Use

- Starting a new operator feature
- Adding a new CRD or API to openshift/api
- Making architectural changes to OpenShift components
- Proposing enhancements in openshift/enhancements
- Need to align with OpenShift design philosophy and patterns

**When NOT to use**: 
- Single-line fixes or typos
- Changes that don't need a spec (already spec'd in enhancement)
- Non-OpenShift projects

**Natural Language**:
- "Create a spec for webhook validation"
- "Write a specification for..."
- "I need a spec for implementing..."

## Arguments

```bash
/spec [feature-description] [--component <name>[,<name>...]] [--feedback "text"] [--auto-approve] [--max-retries N]
```

**Arguments:**
- `[feature-description]`: Brief description of what you're building (optional, will prompt if not provided)
- `--component <name>[,<name>...]`: Component repo name(s)
  - Single: `--component machine-config-operator`
  - Multiple (comma-separated): `--component machine-config-operator,cluster-network-operator`
  - Multiple components fetch context from all specified repos
- `--feedback "text"`: Revision feedback from previous attempt (optional, used for iterative refinement)
- `--auto-approve`: Skip approval gate and proceed directly (optional, default: false)
- `--max-retries N`: Maximum revision attempts before giving up (optional, default: 3)

**Examples:**
```bash
# Platform-wide feature (no component)
/spec "Add webhook validation for MachineConfigPool"
→ Fetches: Tier 1 patterns only

# Single component feature
/spec "Node drain timeout configuration" --component machine-config-operator
→ Fetches: Tier 1 + machine-config-operator/agentic

# Multi-component feature (explicit)
/spec "Network isolation during node updates" \
  --component machine-config-operator,cluster-network-operator
→ Fetches: Tier 1 + MCO/agentic + CNO/agentic

# Multi-component feature (auto-detected from description)
/spec "Coordinate node reboots between MCO and CNO"
→ Detects: Cross-component from keywords ("between")
→ Fetches: Tier 1 + relevant component docs for MCO and CNO
```

## Execution Protocol

### Phase 0: Fetch OpenShift Patterns

**CRITICAL**: Retrieve patterns BEFORE writing spec. This ensures spec follows current OpenShift guidelines.

**Actions:**
```bash
# Step 1: Fetch design philosophy (ALWAYS)
echo "📚 Fetching OpenShift design philosophy..."
/fetch "OpenShift design philosophy and principles" --tier1-only

# Step 2: Fetch relevant patterns based on feature scope
echo "🔍 Fetching relevant patterns for: $FEATURE_DESC"

if [ -n "$COMPONENT" ]; then
    # Check if multiple components (comma-separated)
    if [[ "$COMPONENT" == *","* ]]; then
        # Multi-component feature (explicit)
        echo "🌐 Multi-component feature: fetching from multiple repos"
        
        # Fetch platform patterns first
        /fetch "$FEATURE_DESC" --output-spec --tier1-only
        
        # Then fetch from each component
        IFS=',' read -ra COMPONENTS <<< "$COMPONENT"
        for comp in "${COMPONENTS[@]}"; do
            echo "📡 Fetching from: $comp"
            /fetch "$FEATURE_DESC architecture and patterns" --tier2 openshift/$comp
        done
    else
        # Single component feature
        /fetch "$FEATURE_DESC" --output-spec --tier2 openshift/$COMPONENT
    fi
    
elif [[ "$FEATURE_DESC" =~ "coordinate"|"across"|"between" ]]; then
    # Multi-component feature (auto-detected from description)
    echo "🌐 Cross-component feature detected from description"
    
    # Platform patterns first
    /fetch "$FEATURE_DESC" --output-spec --tier1-only
    
    # Fetch skill will identify relevant components from the query
    # and find similar implementations across multiple components
    # Example: "coordinate reboots between MCO and CNO"
    # → Fetch navigates to similar patterns in both components
    
else
    # Platform-wide feature (no specific component)
    /fetch "$FEATURE_DESC" --output-spec
fi
```

**Why this is generic:**
- No hardcoded feature types (crd, webhook, controller, etc.)
- Fetch skill's Phase 0 parses the feature description automatically
- KNOWLEDGE_GRAPH.md routes to relevant domain/, patterns/, practices/ docs
- Adapts as new patterns are added to agentic/
- Works for ANY feature description
- **Detects cross-component features** from keywords like "coordinate", "across", "between"

**Example flows:**
```bash
# Single component
/spec "Add webhook validation" --component machine-config-operator
→ Fetch: Tier 1 + machine-config-operator/agentic

# Multi-component (auto-detected)
/spec "Coordinate node reboots between MCO and CNO"
→ Fetch: Tier 1 + machine-config-operator/agentic + cluster-network-operator/agentic

# Platform-wide
/spec "Add Prometheus metrics for all operators"
→ Fetch: Tier 1 only + similar implementations across components

# Multi-component (explicit)
/spec "Network isolation" --component machine-config-operator,cluster-network-operator
→ Fetch: Tier 1 + both components
```

**Output from Phase 0:**
```markdown
📚 Fetched Patterns:
  ✅ DESIGN_PHILOSOPHY.md (core principles)
  ✅ platform/operator-patterns/webhooks.md (webhook pattern)
  ✅ practices/development/api-evolution.md (API design)
  ✅ practices/testing/pyramid.md (testing strategy)
  ✅ machine-config-operator/agentic/AGENTS.md (component overview)
  ✅ machine-config-operator/agentic/architecture/components.md (architecture)

📝 Similar Implementations Found:
  - cluster-network-operator: Webhook for NetworkPolicy validation
  - machine-api-operator: Webhook for Machine validation
  
🎯 Ready to create spec following these patterns!
```

### Phase 1: Clarify Requirements

Based on fetched patterns, surface assumptions and ask clarifying questions.

**Actions:**
```markdown
## Requirements Analysis

Based on fetched OpenShift patterns, I need to clarify:

### ASSUMPTIONS I'M MAKING:
1. **Component Type**: This is a ClusterOperator-managed feature
   - Reports status via ClusterOperator CRD (Available/Progressing/Degraded)
   - Managed by CVO for upgrades
   
2. **Implementation Pattern** (from controller-runtime.md):
   - Uses controller-runtime framework
   - Reconciliation-based (not imperative)
   - Leader election for HA
   
3. **Status Reporting** (from status-conditions.md):
   - Available/Progressing/Degraded conditions required
   - Upgradeable condition for cluster upgrades
   - Follows OpenShift condition semantics
   
4. **Testing** (from testing pyramid.md):
   - Unit tests: 60% coverage (business logic)
   - Integration tests: 30% coverage (reconciliation)
   - E2E tests: 10% coverage (user workflows)
   - Uses openshift-tests framework (Ginkgo v2)
   
5. **Security** (from DESIGN_PHILOSOPHY.md):
   - Least-privilege RBAC (ServiceAccount with minimal permissions)
   - Input validation (webhook or in-controller)
   - No secrets in logs
   
6. **Observability** (from observability.md):
   - Prometheus metrics (reconciliation rate, errors, duration)
   - Must-gather support for diagnostics
   - SLO defined (e.g., 99.9% reconciliation success)

7. **Upgrade Strategy** (from upgrade-strategies.md):
   - Supports N → N+1 minor version upgrades
   - Handles version skew gracefully
   - Data migration strategy (if CRD changes)

### CLARIFYING QUESTIONS:

1. **Scope**: Is this a new feature or enhancement to existing?
   - New feature → Need to define entire API
   - Enhancement → Build on existing CRD

2. **User Persona**: Who uses this feature?
   - Cluster admin → ClusterRole with broad permissions
   - Namespace admin → Role with scoped permissions
   - End user → Read-only access via RBAC

3. **Platform Impact**:
   - Single component only → Tier 2 documentation
   - Cross-component → Tier 1 documentation + multiple Tier 2

4. **Breaking Changes**:
   - API changes → Need deprecation strategy
   - Behavior changes → Need migration path
   - None → Can proceed without version bump

5. **Timeline**:
   - Next release (4.17) → Can use alpha/beta APIs
   - Future release (4.18+) → More time for GA readiness

6. **Dependencies**:
   - Requires new openshift/api types → Create API PR first
   - Requires library changes → Coordinate across repos
   - Self-contained → Can implement in single component

→ **Please answer these questions, or confirm assumptions are correct.**
```

**Validation Gate**: Wait for human response before proceeding.

### Phase 2: Write Specification Document

**Actions:**

Based on `--feedback` parameter:
- **First attempt** (no feedback): Generate spec from scratch using fetched patterns
- **Revision** (feedback provided): Read existing spec, apply feedback, update only affected sections

Create comprehensive spec following fetched patterns:

**File**: `SPEC-[feature-name].md` (in current directory) or enhancement PR in openshift/enhancements

```markdown
# Spec: [Feature Name]

**Component**: [e.g., machine-config-operator, cluster-network-operator, cross-component]  
**Enhancement PR**: [Link if exists, or "To be created"]  
**Tier**: [Tier 1 Platform | Tier 2 Component | Both]  
**Author**: [Your name/team]  
**Status**: [Draft | In Review | Approved | Implemented]  
**Created**: [YYYY-MM-DD]  
**Last Updated**: [YYYY-MM-DD]  

---

## 1. Objective

### What We're Building

[Feature description - 1-2 paragraphs]

### Why (Motivation from DESIGN_PHILOSOPHY.md)

**OpenShift Design Principle**: [Which principle from DESIGN_PHILOSOPHY this supports]

Example principles:
- Operators manage cluster state declaratively
- Platform must be self-healing and reliable
- Upgrades must be safe and predictable
- Everything must be observable and debuggable

**User Story**: 
```
As a [cluster admin | namespace admin | developer],
I want [goal],
So that [benefit].
```

**Platform Impact**: [Single component | Cross-component | Platform-wide]

### Success Criteria

Based on fetched patterns, define testable success criteria:

- [ ] **Functional**: Feature works as specified
  - [ ] [Specific behavior 1]
  - [ ] [Specific behavior 2]

- [ ] **Status Reporting** (from status-conditions.md):
  - [ ] Reports Available=True when operational
  - [ ] Reports Progressing=True during changes
  - [ ] Reports Degraded=True on failures
  - [ ] Reports Upgradeable=True when safe to upgrade

- [ ] **Upgrade Safety** (from upgrade-strategies.md):
  - [ ] Works across upgrade N → N+1
  - [ ] Handles version skew gracefully
  - [ ] Data migration works (if applicable)

- [ ] **Observability** (from observability.md):
  - [ ] Metrics exported to Prometheus
  - [ ] Must-gather collects diagnostics
  - [ ] Logs provide debugging context

- [ ] **Testing** (from testing pyramid.md):
  - [ ] Unit tests pass (60% coverage)
  - [ ] Integration tests pass (30% coverage)
  - [ ] E2E tests pass (10% coverage)

---

## 2. Technical Design

### 2.1 API Design

**Follows**: `practices/development/api-evolution.md` (fetched)

#### New CRD (if applicable)

```yaml
apiVersion: [group].openshift.io/v1alpha1  # Start with alpha
kind: [NewResource]
metadata:
  name: [example]
  namespace: [namespace or cluster-scoped]
spec:
  # Fields based on fetched API patterns
  [field1]: [type]
  [field2]: [type]
  
status:
  # Standard conditions (from status-conditions.md)
  conditions:
  - type: Available
    status: "True|False|Unknown"
    reason: "AsExpected|ErrorOccurred"
    message: "Human-readable message"
  - type: Progressing
    status: "True|False|Unknown"
    reason: "..."
    message: "..."
  - type: Degraded
    status: "True|False|Unknown"
    reason: "..."
    message: "..."
  
  # Feature-specific status
  [statusField1]: [type]
```

**API Review Required**: [Yes | No]  
**Breaking Changes**: [None | List changes + deprecation plan]  
**openshift/api PR**: [Link when created]

**Pattern Source**: 
- `practices/development/api-evolution.md`
- `domain/openshift/[similar-resource].md`

### 2.2 Controller Implementation

**Follows**: `platform/operator-patterns/controller-runtime.md` (fetched)

```go
// Reconciliation structure (from fetched pattern)
package controller

import (
    "context"
    ctrl "sigs.k8s.io/controller-runtime"
    "sigs.k8s.io/controller-runtime/pkg/client"
)

type Reconciler struct {
    client.Client
    // Dependencies
}

func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    log := ctrl.LoggerFrom(ctx)
    
    // 1. Fetch resource (from pattern)
    obj := &myv1.MyResource{}
    if err := r.Get(ctx, req.NamespacedName, obj); err != nil {
        return ctrl.Result{}, client.IgnoreNotFound(err)
    }
    
    // 2. Validate spec (from pattern)
    if err := r.validateSpec(obj); err != nil {
        // Set Degraded=True
        r.updateCondition(obj, "Degraded", metav1.ConditionTrue, "ValidationFailed", err.Error())
        return ctrl.Result{}, r.Status().Update(ctx, obj)
    }
    
    // 3. Set Progressing=True (from pattern)
    r.updateCondition(obj, "Progressing", metav1.ConditionTrue, "Reconciling", "Reconciling resource")
    r.Status().Update(ctx, obj)
    
    // 4. Reconcile to desired state (feature-specific logic)
    if err := r.reconcile(ctx, obj); err != nil {
        // Set Degraded=True
        r.updateCondition(obj, "Degraded", metav1.ConditionTrue, "ReconcileFailed", err.Error())
        return ctrl.Result{}, r.Status().Update(ctx, obj)
    }
    
    // 5. Update status conditions (from pattern)
    r.updateCondition(obj, "Available", metav1.ConditionTrue, "AsExpected", "Feature operational")
    r.updateCondition(obj, "Progressing", metav1.ConditionFalse, "AsExpected", "")
    r.updateCondition(obj, "Degraded", metav1.ConditionFalse, "AsExpected", "")
    
    return ctrl.Result{}, r.Status().Update(ctx, obj)
}

func (r *Reconciler) SetupWithManager(mgr ctrl.Manager) error {
    return ctrl.NewControllerManagedBy(mgr).
        For(&myv1.MyResource{}).
        // Owns/Watches (from pattern)
        Complete(r)
}
```

**Pattern Source**: `platform/operator-patterns/controller-runtime.md`

### 2.3 Validation (if applicable)

**Follows**: `platform/operator-patterns/webhooks.md` (fetched)

```go
// Validating webhook (if needed)
package webhook

import (
    "context"
    "net/http"
    "sigs.k8s.io/controller-runtime/pkg/webhook/admission"
)

type Validator struct {
    decoder *admission.Decoder
}

func (v *Validator) Handle(ctx context.Context, req admission.Request) admission.Response {
    obj := &myv1.MyResource{}
    if err := v.decoder.Decode(req, obj); err != nil {
        return admission.Errored(http.StatusBadRequest, err)
    }
    
    // Validation logic (feature-specific)
    if err := validateResource(obj); err != nil {
        return admission.Denied(err.Error())
    }
    
    return admission.Allowed("")
}
```

**Pattern Source**: `platform/operator-patterns/webhooks.md`

---

## 3. Testing Strategy

**Follows**: `practices/testing/pyramid.md` (fetched)

### Test Distribution

| Test Level | Coverage | What to Test | Files | Time |
|-----------|----------|--------------|-------|------|
| **Unit** | 60% | Business logic, validation, state transitions | `pkg/*_test.go` | < 1s per test |
| **Integration** | 30% | Controller reconciliation, API contracts, webhooks | `test/integration/` | < 10s per test |
| **E2E** | 10% | Full user workflow, upgrade paths, cross-component | `test/e2e-agnostic/` | < 5min per test |

### Test Framework

**Framework**: openshift-tests (Ginkgo v2)  
**Pattern Source**: `practices/testing/e2e-framework.md`

### Critical Test Scenarios

#### Unit Tests
```go
// pkg/controller/myresource_controller_test.go
func TestReconcile_HappyPath(t *testing.T) { }
func TestReconcile_ResourceNotFound(t *testing.T) { }
func TestReconcile_ValidationError(t *testing.T) { }
func TestReconcile_ReconciliationError(t *testing.T) { }
func TestUpdateStatus_AllConditions(t *testing.T) { }
```

#### Integration Tests
```go
// test/integration/myfeature_test.go
func TestMyFeature_Integration(t *testing.T) {
    // Test controller with fake Kubernetes client
    // Verify reconciliation loop works
    // Verify status updates correctly
}
```

#### E2E Tests (Critical Paths Only)
```go
// test/e2e-agnostic/myfeature_test.go
var _ = ginkgo.Describe("[sig-mycomponent] MyFeature", func() {
    ginkgo.It("should work on fresh install", func() { })
    ginkgo.It("should survive upgrade N → N+1 [Slow]", func() { })
    ginkgo.It("should degrade gracefully on failure", func() { })
})
```

**E2E Test Labels** (from e2e-framework.md):
- `[sig-mycomponent]` - Component owner
- `[Slow]` - Takes >1 minute
- `[Serial]` - Cannot run in parallel
- `[Disruptive]` - May affect other tests

---

## 4. Security Considerations

**Follows**: `practices/security/threat-modeling.md` (fetched)

### STRIDE Threat Model

| Threat | Risk | Mitigation |
|--------|------|-----------|
| **Spoofing** | Attacker impersonates feature's ServiceAccount | Use dedicated ServiceAccount with least-privilege RBAC |
| **Tampering** | Malicious modification of CRD | Validating webhook rejects invalid configs |
| **Repudiation** | Action cannot be traced | Audit logs for all API changes |
| **Information Disclosure** | Secrets leaked in logs/status | Sanitize logs, use opaque references |
| **Denial of Service** | Resource exhaustion | Rate limiting, resource quotas |
| **Elevation of Privilege** | ServiceAccount gains cluster-admin | RBAC review, principle of least privilege |

### RBAC Design

**Follows**: `practices/security/rbac-guidelines.md` (fetched)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: my-feature-controller
rules:
# Minimal permissions (least privilege)
- apiGroups: ["myapi.openshift.io"]
  resources: ["myresources"]
  verbs: ["get", "list", "watch", "update", "patch"]
- apiGroups: ["myapi.openshift.io"]
  resources: ["myresources/status"]
  verbs: ["update", "patch"]
# Add only what's strictly necessary
```

**Pattern Source**: `practices/security/rbac-guidelines.md`

---

## 5. Reliability & Observability

**Follows**: `practices/reliability/observability.md` (fetched)

### Metrics

```go
// Prometheus metrics (from observability.md pattern)
var (
    reconcileTotal = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "myfeature_reconcile_total",
            Help: "Total reconciliations",
        },
        []string{"result"}, // "success" or "error"
    )
    
    reconcileDuration = prometheus.NewHistogramVec(
        prometheus.HistogramOpts{
            Name:    "myfeature_reconcile_duration_seconds",
            Help:    "Reconciliation duration",
            Buckets: prometheus.DefBuckets,
        },
        []string{},
    )
    
    reconcileErrors = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "myfeature_reconcile_errors_total",
            Help: "Total reconciliation errors",
        },
        []string{"error_type"},
    )
)
```

### SLO (Service Level Objective)

**Follows**: `practices/reliability/slo-framework.md` (fetched)

**Target**: 99.9% of reconciliations succeed within 30 seconds

```yaml
# PrometheusRule for SLO alerting
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: myfeature-slo
spec:
  groups:
  - name: myfeature-slo
    rules:
    - alert: MyFeatureSLOBudgetBurn
      expr: |
        (
          sum(rate(myfeature_reconcile_total{result="error"}[5m]))
          /
          sum(rate(myfeature_reconcile_total[5m]))
        ) > 0.001
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "MyFeature SLO budget burning (current error rate: {{ $value }})"
```

**Pattern Source**: `practices/reliability/slo-framework.md`

### Must-Gather

**Follows**: `platform/operator-patterns/must-gather.md` (fetched)

```bash
# Diagnostic collection
oc adm must-gather -- /usr/bin/gather_myfeature

# Must-gather should collect:
# - MyResource CRDs (all instances)
# - Controller logs
# - Related resources (ConfigMaps, Secrets, etc.)
# - Events
# - Metrics snapshot
```

**Pattern Source**: `platform/operator-patterns/must-gather.md`

---

## 6. Upgrade Strategy

**Follows**: `platform/operator-patterns/upgrade-strategies.md` (fetched)

### Version Compatibility

- **Supported**: N → N+1 (single minor version)
- **Tested**: N → N+1 → N+2 (skip one minor version)
- **Not Supported**: N → N+2 direct

### Upgrade Flow

```
1. CVO detects new version in update payload
   ↓
2. Feature operator reports Upgradeable=True (if safe to upgrade)
   ↓
3. CVO orders upgrade: [Component] upgrades after [dependencies]
   ↓
4. Feature controller starts with new version
   ↓
5. Feature migrates existing resources (if CRD changed)
   ↓
6. Feature validates new version works
   ↓
7. Feature reports Available=True
```

### Migration Strategy

[None | Data migration | CRD version conversion]

**If CRD changes**:
- v1alpha1 → v1beta1: Conversion webhook required
- Add fields: Defaults in controller
- Remove fields: Deprecation cycle (N-1 warns, N removes)

**Pattern Source**: `platform/operator-patterns/upgrade-strategies.md`

---

## 7. Dependencies & Integration

### Tier 1 Dependencies (from fetched patterns)

Based on fetched patterns, this feature depends on:
- ClusterOperator CRD (status reporting to CVO)
- controller-runtime framework (reconciliation)
- OpenShift E2E test framework (testing)
- library-go helpers (conditions, status)

### Component Dependencies

[List specific component dependencies]

Example:
- machine-config-operator: For node configuration
- cluster-network-operator: For network policies

### Architectural Decision Records (ADRs)

Based on fetched `decisions/`, relevant ADRs:
- [ADR-0001: Use operator-sdk](agentic/decisions/adr-0001-operator-sdk.md) - Must use operator-sdk
- [ADR-0002: etcd backend](agentic/decisions/adr-0002-etcd-backend.md) - State stored in etcd
- [ADR-0003: CVO upgrade ordering](agentic/decisions/adr-0003-cvo-upgrade-ordering.md) - CVO controls upgrades

**ADRs Constrain**:
- Implementation approach
- Technology choices
- Upgrade strategy

---

## 8. Implementation Plan (High-Level)

Will be broken down in `/plan` phase. High-level estimate:

### Week 1: API Design & Review
- [ ] Create CRD types in openshift/api
- [ ] API review with @openshift/api-reviewers
- [ ] Merge openshift/api PR
- [ ] Vendor into component

### Week 2-3: Controller Implementation
- [ ] Basic reconciliation loop
- [ ] Status condition reporting
- [ ] Validation logic (webhook or in-controller)
- [ ] Unit tests (60% coverage)

### Week 4: Integration & E2E Testing
- [ ] Integration tests (30% coverage)
- [ ] E2E tests (10% coverage - critical paths)
- [ ] Upgrade tests (N → N+1)

### Week 5: Observability & Documentation
- [ ] Prometheus metrics
- [ ] Must-gather support
- [ ] Update AGENTS.md (Tier 2)
- [ ] Create exec-plan
- [ ] Enhancement PR (if not already done)

**Total Estimate**: 5 weeks for initial implementation

---

## 9. Compliance Checklist

### Operator Patterns (Tier 1) - ALL REQUIRED

Based on fetched `platform/operator-patterns/`:

- [ ] **controller-runtime**: Implements Reconcile() pattern
- [ ] **status-conditions**: Reports Available/Progressing/Degraded
- [ ] **leader-election**: Uses leader election for HA
- [ ] **finalizers**: Uses finalizers for cleanup (if needed)
- [ ] **webhooks**: Implements validation/mutation (if needed)
- [ ] **rbac-patterns**: Defines ServiceAccount with least privilege
- [ ] **upgrade-strategies**: Supports safe upgrades
- [ ] **must-gather**: Provides diagnostic collection

### Engineering Practices (Tier 1) - ALL REQUIRED

Based on fetched `practices/`:

- [ ] **Testing**: Follows pyramid (60/30/10)
- [ ] **Security**: Applies STRIDE threat model
- [ ] **Reliability**: Defines SLO and error budget
- [ ] **Observability**: Exports metrics, implements must-gather
- [ ] **Development**: Follows API evolution guidelines
- [ ] **CI/CD**: Uses OpenShift CI (Prow)
- [ ] **Git Workflow**: Small PRs, atomic commits

### Component-Specific (Tier 2)

Based on fetched component agentic/ docs:
[Checklist from component AGENTS.md]

Example for machine-config-operator:
- [ ] Follows MCD/MCC/MCS architecture
- [ ] Uses rpm-ostree for node configuration
- [ ] Handles node reboots safely
- [ ] Updates rendered MachineConfig

---

## 10. Open Questions

[Things that need human input before proceeding]

Example questions:
1. Should this feature be alpha, beta, or GA in first release?
2. What is the deprecation timeline for old behavior (if changing)?
3. Are there customer commitments or timelines?
4. Should this be behind a feature gate initially?

---

## 11. References

### Fetched Documentation (Auto-Retrieved)

**Tier 1 (Ecosystem Hub)**:
- `agentic/DESIGN_PHILOSOPHY.md` - Core principles
- `agentic/platform/operator-patterns/controller-runtime.md` - Reconciliation pattern
- `agentic/platform/operator-patterns/status-conditions.md` - Status reporting
- `agentic/platform/operator-patterns/webhooks.md` - Validation pattern
- `agentic/platform/operator-patterns/upgrade-strategies.md` - Upgrade safety
- `agentic/platform/operator-patterns/must-gather.md` - Diagnostics
- `agentic/practices/testing/pyramid.md` - Testing strategy
- `agentic/practices/testing/e2e-framework.md` - E2E testing
- `agentic/practices/security/threat-modeling.md` - STRIDE framework
- `agentic/practices/security/rbac-guidelines.md` - RBAC design
- `agentic/practices/reliability/observability.md` - Metrics and logging
- `agentic/practices/reliability/slo-framework.md` - SLO definition
- `agentic/practices/development/api-evolution.md` - API design
- `agentic/decisions/[adrs].md` - Architectural constraints

**Tier 2 (Component-Specific)**:
- `$COMPONENT/agentic/AGENTS.md` - Component overview
- `$COMPONENT/agentic/architecture/components.md` - Component architecture
- `$COMPONENT/agentic/decisions/[adrs].md` - Component decisions

### Official Documentation (OpenShift)

- Enhancement template: `/guidelines/enhancement_template.md`
- API conventions: `/dev-guide/api-conventions.md`
- Test conventions: `/dev-guide/test-conventions.md`
- Operators guide: `/dev-guide/operators.md`

### Similar Features (Found via Fetch)

[Links to similar implementations]

Example:
- machine-api-operator: Webhook for Machine validation
  - https://github.com/openshift/machine-api-operator/blob/master/pkg/webhooks/
- cluster-network-operator: Controller for NetworkPolicy
  - https://github.com/openshift/cluster-network-operator/blob/master/pkg/controller/

---

## 12. Validation Gates

### Before Advancing to `/plan`

- [ ] All sections of spec complete
- [ ] Fetched patterns applied correctly
- [ ] Compliance checklist reviewed
- [ ] Open questions answered
- [ ] **Human approves spec** ← GATE

### Human Review Checklist

When reviewing this spec, check:
- [ ] Objective is clear and aligned with OpenShift strategy
- [ ] Technical design follows fetched patterns
- [ ] Testing strategy is comprehensive
- [ ] Security considerations are addressed
- [ ] Upgrade strategy is safe
- [ ] Implementation estimate is reasonable

---

**Status**: [Draft | Ready for Review | Approved]  
**Next Step**: After approval, run `/plan` to break this down into implementable tasks

---

**Pattern**: OpenShift feature specification with fetch integration  
**Version**: 1.0  
**Last Updated**: [YYYY-MM-DD]
```

### Phase 2.5: Approval Gate

**CRITICAL**: After generating or revising the spec, pause for human review unless `--auto-approve` is set.

**Actions:**

```bash
# Check if auto-approve is enabled
if [[ "$AUTO_APPROVE" == "true" ]]; then
    echo "✓ Auto-approve enabled. Skipping review gate."
    # Proceed to Phase 3
else
    # Find the generated spec file
    SPEC_FILE=$(find . -maxdepth 1 -name "SPEC-*.md" -type f | head -1)
    
    # Show approval gate message
    cat <<EOF

════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Generated
════════════════════════════════════════════════════════════════

📄 $SPEC_FILE created

Please review the specification and respond:

  • "approve" or "looks good" 
    → I'll proceed to create the exec-plan and mark this phase complete
  
  • "revise: <your feedback>"
    → I'll regenerate the spec incorporating your feedback
    → Example: "revise: add more detail about version skew handling"
  
  • "abort" or "cancel"
    → I'll stop here without proceeding

Key sections to review:
$(grep "^## " "$SPEC_FILE" | head -12)

════════════════════════════════════════════════════════════════

I'm waiting for your review decision...

EOF
    
    # Exit here - return control to user
    # User will respond in natural language, and Claude will detect their intent
    exit 0
fi
```

**Natural Language Detection:**

When the user responds, Claude Code's conversational layer detects intent:

**Approval phrases** (proceed to Phase 3):
- "approve", "approved", "LGTM", "looks good", "proceed", "continue", "yes"

**Revision phrases** (re-invoke /spec with feedback):
- "revise: <feedback>"
- "change <feedback>"  
- "update <feedback>"
- "fix <feedback>"
- "add <feedback>"

**Abort phrases** (stop workflow):
- "abort", "cancel", "stop", "nevermind", "no"

**Revision Flow:**

When revision is detected:
1. Extract feedback from user message
2. Check attempt count (tracked in `.work/spec-state.json`)
3. If attempts < max_retries:
   - Re-invoke: `/spec --component X --feature Y --feedback "user feedback"`
   - Increment attempt count
4. If attempts >= max_retries:
   - Report: "Maximum retries reached. Spec may not meet requirements."
   - Save final spec and exit

**State Tracking:**

```json
// .work/spec-state.json
{
  "feature": "dynamic ImageStream importMode",
  "component": "cluster-version-operator",
  "attempt": 2,
  "max_retries": 3,
  "spec_file": "SPEC-dynamic-imagestream-importmode.md",
  "last_feedback": "add more detail about version skew"
}
```

### Phase 3: Create Exec-Plan (if component-specific)

If `--component` was specified, also create an exec-plan in the component's agentic/exec-plans/:

**File**: `$COMPONENT/agentic/exec-plans/active/[feature-name].md`

```markdown
# Exec-Plan: [Feature Name]

**Component**: [component-name]  
**Status**: Active  
**Start Date**: [YYYY-MM-DD]  
**Target Completion**: [YYYY-MM-DD]  
**Owner**: [team/person]  

## Overview
[Brief summary - references the full spec]

## Full Specification
See: [SPEC-feature-name.md](../../specs/SPEC-feature-name.md)

## Implementation Checklist

### Phase 1: API (Week 1)
- [ ] openshift/api PR created
- [ ] API review complete
- [ ] PR merged
- [ ] Vendored into component

### Phase 2: Controller (Week 2-3)
- [ ] Reconciliation implemented
- [ ] Status reporting working
- [ ] Unit tests pass

### Phase 3: Testing (Week 4)
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Upgrade tests pass

### Phase 4: Observability (Week 5)
- [ ] Metrics implemented
- [ ] Must-gather support added
- [ ] Documentation updated

## Dependencies
[Links to other exec-plans or features this depends on]

## Risks
[What could go wrong, mitigation strategies]

## References
- Full Spec: [link]
- Enhancement PR: [link]
- Tracking Issue: [link]
```

### Phase 4: Report Results

**Output varies based on approval gate:**

**On First Generation (Paused for Review):**
```
✅ OpenShift Feature Specification Generated

📄 Spec Created: SPEC-[feature-name].md (Attempt 1/3)

📚 Patterns Fetched:
  ✅ DESIGN_PHILOSOPHY.md (core principles)
  ✅ controller-runtime.md (reconciliation pattern)
  ✅ status-conditions.md (status reporting)
  ✅ webhooks.md (validation pattern)
  ✅ upgrade-strategies.md (upgrade safety)
  ✅ testing pyramid.md (testing strategy)
  ✅ $COMPONENT architecture (component specifics)

✅ Compliance Checks:
  ✅ Operator patterns: 8/8 addressed
  ✅ Engineering practices: 7/7 addressed
  ✅ Component patterns: [n/n addressed]

📊 Implementation Estimate: 5 weeks

════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Generated
════════════════════════════════════════════════════════════════

📄 SPEC-feature.md created

Please review and respond:
  • "approve" → I'll create exec-plan and mark complete
  • "revise: <feedback>" → I'll regenerate with your feedback
  • "abort" → I'll stop here

════════════════════════════════════════════════════════════════
```

**On Revision (After Feedback Applied):**
```
✅ Specification Revised (Attempt 2/3)

Feedback applied:
"add more detail about version skew handling"

Changes made:
  ✓ Updated Design Details > Version Skew Strategy (lines 850-920)
  ✓ Added backward compatibility explanation
  ✓ Documented fallback behavior for old components

📄 Updated: SPEC-[feature-name].md

════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Revised
════════════════════════════════════════════════════════════════

Changes applied. Please review and respond:
  • "approve" → I'll create exec-plan and mark complete
  • "revise: <feedback>" → I'll regenerate again (1 attempt left)
  • "abort" → I'll stop here

════════════════════════════════════════════════════════════════
```

**On Approval (Complete):**
```
✅ OpenShift Feature Specification Complete

📄 Spec Approved: SPEC-[feature-name].md
📋 Exec-Plan Created: $COMPONENT/agentic/exec-plans/active/[feature-name].md

🎯 Next Step: Run `/plan SPEC-[feature-name].md` to break down into tasks
```

**On Max Retries:**
```
⚠️  Maximum Retries Reached (3/3)

📄 Final spec saved: SPEC-[feature-name].md

The specification has been revised 3 times but may not fully meet requirements.
You can:
  1. Manually edit SPEC-[feature-name].md
  2. Start fresh with new approach
  3. Use current spec as-is (not recommended without review)
```

## Revision Workflow Example

### Scenario: Multi-Arch Feature Specification with Iteration

**Attempt 1: Initial Generation**

```
User: /spec --component cluster-version-operator \
           --feature "dynamic ImageStream importMode based on architecture"

Agent:
=== Phase 0: Fetching Patterns ===
📚 Fetching OpenShift design philosophy...
🔍 Fetching: dynamic ImageStream importMode architecture

Patterns retrieved:
  ✅ DESIGN_PHILOSOPHY.md
  ✅ controller-runtime.md
  ✅ status-conditions.md
  ✅ cluster-version-operator/agentic/AGENTS.md

=== Phase 1: Clarify Requirements ===
[Shows assumptions and asks clarifying questions]

=== Phase 2: Write Specification ===
[Generates SPEC-dynamic-imagestream-importmode.md]

════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Generated (Attempt 1/3)
════════════════════════════════════════════════════════════════

📄 SPEC-dynamic-imagestream-importmode.md created (1,850 lines)

Key sections:
## 1. Objective
## 2. Technical Design
## 3. Testing Strategy
## 4. Security Considerations
## 5. Reliability & Observability
## 6. Upgrade Strategy
...

Please review and respond:
  • "approve" → I'll create exec-plan
  • "revise: <feedback>" → I'll regenerate
  • "abort" → I'll stop

════════════════════════════════════════════════════════════════
```

**Attempt 2: Revision Requested**

```
User: revise: The proposal section doesn't explain how registry-operator and 
      apiserver interact with CVO. Add a data flow diagram and code examples 
      from each component showing the interaction pattern.

Agent:
=== Phase 2: Write Specification (Revision) ===

Applying feedback:
"The proposal section doesn't explain how registry-operator and apiserver..."

Reading existing spec: SPEC-dynamic-imagestream-importmode.md

Changes being made:
  • Adding "Component Interaction" subsection to Technical Design
  • Creating data flow diagram: CVO → registry-operator → apiserver
  • Adding code example from CVO: inferPayloadArchitecture()
  • Adding code example from registry-operator: ClusterVersion watcher
  • Adding code example from apiserver: applying defaults

Updated sections:
  ✓ Technical Design > Component Interaction (lines 245-380)
  ✓ Added data flow diagram
  ✓ Added 3 code examples showing full interaction chain

════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Revised (Attempt 2/3)
════════════════════════════════════════════════════════════════

📄 SPEC-dynamic-imagestream-importmode.md revised

Changes made:
  ✓ Component Interaction subsection added (135 lines)
  ✓ Data flow diagram showing CVO → registry → apiserver
  ✓ Code examples from all 3 components

Please review and respond:
  • "approve" → I'll create exec-plan
  • "revise: <feedback>" → I'll regenerate (1 attempt left)
  • "abort" → I'll stop

════════════════════════════════════════════════════════════════
```

**Attempt 3: Approval**

```
User: looks good

Agent:
✓ Specification approved

=== Phase 3: Create Exec-Plan ===
[Creates exec-plan in cluster-version-operator/agentic/exec-plans/active/]

✅ OpenShift Feature Specification Complete

📄 Spec Approved: SPEC-dynamic-imagestream-importmode.md
📋 Exec-Plan Created: cluster-version-operator/agentic/exec-plans/active/dynamic-imagestream-importmode.md

🎯 Next Step: Run `/plan SPEC-dynamic-imagestream-importmode.md`
```

### Revision Best Practices

**Good Feedback** (Specific, Actionable):
- ✅ "revise: add version skew handling between CVO v4.16 and registry-operator v4.15"
- ✅ "revise: the security section doesn't address RBAC for reading ClusterVersion CR"
- ✅ "revise: upgrade strategy needs rollback plan if registry-operator fails"

**Poor Feedback** (Vague, Hard to Apply):
- ❌ "revise: make it better"
- ❌ "revise: add more detail" (which section?)
- ❌ "revise: I don't like it" (what specifically?)

**When to Abort:**
- Feature description is fundamentally unclear
- Missing critical context that can't be inferred from patterns
- Scope is too large for single spec (should be split)

**When to Approve:**
- All 12 sections are complete
- Fetched patterns are correctly applied
- Technical design is sound and follows OpenShift conventions
- No blocking questions remain unanswered

## Success Criteria

**Spec is complete when:**
- ✅ All 12 sections filled in
- ✅ Fetched patterns correctly applied
- ✅ Compliance checklist addressed
- ✅ Human approves spec
- ✅ Ready to advance to `/plan` phase

## Anti-Patterns to Avoid

| Anti-Pattern | Why Bad | What to Do Instead |
|-------------|---------|-------------------|
| Skipping fetch phase | Miss current patterns | Always fetch DESIGN_PHILOSOPHY + relevant patterns |
| Ignoring fetched patterns | Non-compliant implementation | Apply patterns from Tier 1/Tier 2 |
| Skipping compliance checklist | Fail review later | Check all operator patterns and practices |
| No human validation | Build wrong thing | Wait for approval before `/plan` |
| Vague success criteria | Can't validate "done" | Make criteria specific and testable |

**Pattern Source**: `workflows/enhancement-process.md`

---

## Integration with Other Skills

**Workflow:**
```bash
# 1. CREATE SPEC (this skill)
/spec "Add webhook validation for MachineConfigPool" --component machine-config-operator
→ Fetches patterns, creates spec
→ Human approves

# 2. PLAN IMPLEMENTATION (next skill)
/plan
→ Reads approved spec
→ Breaks down into ordered tasks

# 3. BUILD INCREMENTALLY
/build task-1
→ Implements first task
→ Continues through all tasks

# 4. TEST COMPREHENSIVELY
/test
→ Verifies all tests pass
→ Checks coverage

# 5. REVIEW FOR COMPLIANCE
/review
→ Checks against fetched patterns
→ Validates compliance

# 6. SHIP SAFELY
/ship
→ Upgrade validation
→ Deployment
```

---

**Pattern**: OpenShift feature specification with automatic pattern retrieval  
**Version**: 1.0
