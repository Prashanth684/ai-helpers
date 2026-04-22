# Fetch Skill - Intelligent Retrieval Agent

## Overview

The `fetch` skill is an intelligent retrieval agent that navigates OpenShift agentic documentation to gather context for questions, feature planning, and bug investigation.

**Key Innovations**:
1. **Smart Navigation**: Instead of reading all docs sequentially, fetch follows KNOWLEDGE_GRAPH.md task maps to retrieve relevant information in ≤5 documents
2. **Remote & Local Support**: Works with both local clones AND remote GitHub repositories (including private repos via `gh` CLI)

## Use Cases

### 1. Answer Questions
```bash
/agentic-docs-maintainer:fetch "How do operators report status?"
```
**Output**: Explanation with code examples from real components

### 2. Research Feature Implementation
```bash
/agentic-docs-maintainer:fetch "implementing webhook validation" \
  --component machine-config-operator \
  --output-spec
```
**Output**: Complete specification with design, patterns, test strategy

### 3. Debug Issues
```bash
/agentic-docs-maintainer:fetch "nodes failing to update during upgrade" \
  --component machine-config-operator
```
**Output**: Debugging guide with diagnostics and potential fixes

### 4. Cross-Component Features
```bash
/agentic-docs-maintainer:fetch "multi-tenant network isolation" --output-spec
```
**Output**: Specification spanning multiple components

## How It Works

### Retrieval Strategy

```
1. Parse Query
   ↓
2. Locate Documentation (Tier 1 + Tier 2)
   ↓
3. Navigate Using KNOWLEDGE_GRAPH (≤5 docs)
   ↓
4. Gather Context (domain + patterns + practices + examples)
   ↓
5. Synthesize (answer | spec | debug guide)
```

### Navigation Intelligence

**Traditional approach** (inefficient):
- Read all 45 docs in agentic/
- Search for keywords
- Hope to find relevant info

**Fetch approach** (efficient):
- Read KNOWLEDGE_GRAPH.md → get task path
- Read 4-5 targeted docs based on query type
- Follow examples in real components
- Synthesize actionable output

### Query Types

| Type | Triggers | Navigation Path | Output |
|------|----------|----------------|--------|
| **Question** | "How does X work?" | domain/ → patterns/ → examples | Answer with context |
| **Feature** | "Implement Y" + `--output-spec` | DESIGN_PHILOSOPHY → patterns/ → practices/ → examples | Full specification |
| **Bug** | "X is failing" | architecture/ → patterns/ → observability/ → examples | Debug guide |

## Arguments

```bash
/agentic-docs-maintainer:fetch <query> [options]
```

| Argument | Description | Example |
|----------|-------------|---------|
| `<query>` | Question, feature, or bug (required) | `"How do webhooks work?"` |
| `--component <name>` | Narrow to specific component | `--component machine-config-operator` |
| `--output-spec` | Generate specification document | Flag |
| `--tier1-only` | Search only ecosystem hub | Flag |
| `--tier2 <repo>` | Search specific component docs | `--tier2 machine-config-operator` |

## Output Formats

### Questions (Default)
```markdown
# Answer to: [question]
## Summary
## How It Works
## Implementation Pattern
## Examples in OpenShift
## Best Practices
## References
```

### Features (--output-spec)
```markdown
# Feature Specification: [name]
## Context from Existing Patterns
## Proposed Design
   - API Changes
   - Controller Implementation
   - Status Reporting
   - Testing Strategy
## Engineering Practices to Follow
## Architectural Constraints
## Implementation Plan
## References
```

### Bugs (Debugging)
```markdown
# Bug Investigation: [description]
## Expected Behavior
## Component Architecture
## Debugging Approach
   - Observability
   - Must-Gather
   - Common Issues
## Root Cause Hypotheses
## Validation Steps
## Potential Fixes
## References
```

## Examples

### Example 1: Understanding a Pattern

**Query:**
```bash
/agentic-docs-maintainer:fetch "How do finalizers work?"
```

**Navigation Path:**
1. OPENSHIFT_AGENTS.md → operator patterns
2. platform/operator-patterns/finalizers.md
3. domain/kubernetes/crds.md (owner references)
4. Examples in: machine-api-operator, cluster-network-operator

**Output:**
- What finalizers are (domain concept)
- How they work (pattern with code)
- When to use them (best practices)
- Real examples from components

### Example 2: Feature Specification

**Query:**
```bash
/agentic-docs-maintainer:fetch "add metrics for reconciliation performance" \
  --component machine-config-operator \
  --output-spec
```

**Navigation Path:**
1. DESIGN_PHILOSOPHY.md (observability principle)
2. practices/reliability/observability.md (metrics patterns)
3. platform/operator-patterns/controller-runtime.md (where to instrument)
4. practices/testing/pyramid.md (testing metrics)
5. Examples: cluster-network-operator metrics

**Output:**
```markdown
# Feature Specification: Reconciliation Performance Metrics

## Context from Existing Patterns
- Observability: Prometheus metrics standard
- Controller-runtime: Instrument reconcile loop
- Examples: CNO uses reconcile_duration_seconds histogram

## Proposed Design
### Metrics to Add
```go
reconcileDuration := prometheus.NewHistogramVec(...)
reconcileErrors := prometheus.NewCounterVec(...)
```

### Testing Strategy
- Unit: Verify metrics registration
- Integration: Check metric values during reconcile
- E2E: Validate Prometheus scraping

## Implementation Plan
- [ ] Add prometheus metrics
- [ ] Instrument reconcile loop
- [ ] Add ServiceMonitor
- [ ] Test metric collection
...
```

### Example 3: Bug Investigation

**Query:**
```bash
/agentic-docs-maintainer:fetch "MachineConfigPool degraded after node drain" \
  --component machine-config-operator
```

**Navigation Path:**
1. machine-config-operator/agentic/AGENTS.md
2. architecture/components.md (MCD/MCC/MCS interaction)
3. domain/machineconfig.md (lifecycle)
4. platform/operator-patterns/status-conditions.md (degraded meaning)
5. practices/reliability/observability.md (debugging)

**Output:**
```markdown
# Bug Investigation: MachineConfigPool Degraded After Drain

## Expected Behavior
MCP should update nodes gracefully with maxUnavailable constraint

## Component Architecture
- MCD: Runs on each node, applies config
- MCC: Renders configs for pools
- MCS: Serves rendered configs

## Debugging Approach
### Check Status
```bash
oc get mcp worker -o yaml
# Look for Degraded condition reason
```

### Check Logs
```bash
oc logs -n openshift-machine-config-operator daemonset/machine-config-daemon
# Look for drain/update errors
```

### Common Issues
1. Node cordoning failed
2. Pod eviction timeout
3. Rendered config mismatch

## Root Cause Hypotheses
- Drain timeout too short
- Workload blocking eviction (PDB)
- Node annotation mismatch

## Validation Steps
[Commands to check each hypothesis]

## Potential Fixes
- Increase drain timeout
- Fix PDB configuration
- Force reboot if stuck
...
```

## Best Practices

### DO ✅
- Use KNOWLEDGE_GRAPH navigation (read ≤5 docs)
- Include examples from real components
- Reference official docs (dev-guide/) when applicable
- Generate actionable output (not just summaries)

### DON'T ❌
- Read all docs sequentially (inefficient)
- Ignore existing component implementations
- Create specs without reading DESIGN_PHILOSOPHY
- Generate generic answers without OpenShift context

## Integration with Other Skills

### Workflow: Research → Document
```bash
# 1. Research feature
/agentic-docs-maintainer:fetch "webhook validation" --output-spec > spec.md

# 2. Create exec-plan
cd machine-config-operator
cp spec.md agentic/exec-plans/active/webhook-validation.md

# 3. Verify structure
/agentic-docs-maintainer:verify
```

### Workflow: Debug → Fix → Document
```bash
# 1. Investigate bug
/agentic-docs-maintainer:fetch "upgrade failures" --component mco

# 2. Fix issue
# ... make code changes ...

# 3. Update docs
/agentic-docs-maintainer:tier2-component --maintain
```

## Success Metrics

**Effective retrieval:**
- Read 4-5 docs (not 45)
- Found relevant patterns
- Included real examples
- Generated actionable output

**Example:**
```
🔍 Fetch Results: "How do webhooks work?"

Navigation Path:
  📍 Entry: OPENSHIFT_AGENTS.md
  🗺️  Graph: operator patterns → webhooks → examples
  📚 Docs Read: 4 / 5 target
    - platform/operator-patterns/webhooks.md
    - practices/development/api-evolution.md
    - practices/security/threat-modeling.md
    - Examples: machine-api-operator, cluster-network-operator

Context Gathered:
  ✅ Domain Concepts: 2 (ValidatingWebhook, MutatingWebhook)
  ✅ Platform Patterns: 1 (webhooks.md)
  ✅ Engineering Practices: 2 (api-evolution, security)
  ✅ Examples: 3 components
  ✅ References: 2 official docs

[ANSWER WITH CODE EXAMPLES]

⏱️  Retrieval Time: ~3 min
📊 Efficiency: 4/45 docs = 8.9% (excellent!)
```

## Files

- `SKILL.md` - Full skill implementation
- `README.md` - This file
- Command: `../../commands/fetch.md` - User-facing command

## See Also

- `/agentic-docs-maintainer:extract` - Extract knowledge from enhancements
- `/agentic-docs-maintainer:tier2-component` - Create component docs
- `/agentic-docs-maintainer:verify` - Verify doc structure

---

**Pattern**: Intelligent retrieval and synthesis  
**Version**: 1.0
