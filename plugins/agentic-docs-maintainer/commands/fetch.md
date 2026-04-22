---
description: Intelligent retrieval agent - gather context from OpenShift agentic docs for questions, features, and bugs
---

## Name
agentic-docs-maintainer:fetch

## Synopsis
```
/agentic-docs-maintainer:fetch <query> [--component <name>] [--output-spec] [--tier1-only] [--tier2 <org/repo>] [--local | --remote]
```

## Description
Acts as a retrieval agent that intelligently navigates OpenShift agentic documentation to gather context for:
- Answering questions about OpenShift components
- Researching feature implementation approaches
- Investigating bugs and generating debugging guides
- Creating specifications based on existing patterns and practices

**Key capability**: Follows the agentic/ structure's guidance (KNOWLEDGE_GRAPH.md, navigation maps) to find information efficiently without reading all docs.

## Arguments

- `<query>`: Question, feature, or bug to investigate (required)
- `--component <name>`: Narrow search to specific component repository (optional)
- `--output-spec`: Generate a specification document based on findings (optional)
- `--tier1-only`: Only search Tier 1 ecosystem hub docs (optional)
- `--tier2 <org/repo>`: Search specific component's Tier 2 docs from GitHub (optional)
  - Examples: `--tier2 openshift/machine-config-operator`
  - Examples: `--tier2 outrigger-project/multiarch-tuning-operator`

**Source Mode** (choose one):
- `--local`: Force local-only mode (fail if repos not found locally)
- `--remote`: Force remote-only mode (skip local filesystem, always fetch from GitHub)
- *(default)*: Auto mode - try local first, fallback to remote if not found

## Source Modes

**NEW**: The fetch skill supports **three modes** for accessing documentation!

### Mode Comparison

| Mode | Behavior | When to Use |
|------|----------|-------------|
| **Auto** (default) | Try local first, fallback to remote | Best of both worlds - fast when local, works when not |
| **--local** | Only local filesystem, fail if not found | Offline development, testing, known local clones |
| **--remote** | Only GitHub, skip local checks | Always get latest, no local repos, CI/CD pipelines |

### How Each Mode Works

#### Auto Mode (Default)
```bash
/agentic-docs-maintainer:fetch "How do webhooks work?"

# 1. Try local first (fast)
#    ✅ ../enhancements/agentic → found
#    → Use local files

# 2. If not local, fetch from GitHub
#    ❌ ../enhancements/agentic → not found
#    📡 Fetching from: https://github.com/openshift/enhancements
```

#### --local Mode (Local Only)
```bash
/agentic-docs-maintainer:fetch "How do webhooks work?" --local

# Only search local filesystem
# ✅ Found → use it
# ❌ Not found → fail with error
#    "Tier 1 not found locally. Use --remote to fetch from GitHub."
```

**Use when:**
- Working offline
- Testing with specific local versions
- You know repos are cloned

#### --remote Mode (Remote Only)
```bash
/agentic-docs-maintainer:fetch "How do webhooks work?" --remote

# Skip local checks, go straight to GitHub
# 📡 Always fetch from: https://github.com/openshift/enhancements
# ✅ Get latest version from GitHub
```

**Use when:**
- Want latest docs (ignore local clones)
- Running in CI/CD (no local clones)
- Don't want stale local copies

### GitHub Access Methods

| Method | Auth | Public Repos | Private Repos | Speed |
|--------|------|--------------|---------------|-------|
| `gh` CLI | ✅ Yes | ✅ Yes | ✅ Yes | Fast |
| raw.githubusercontent.com | ❌ No | ✅ Yes | ❌ No | Fast |
| Local clone | N/A | ✅ Yes | ✅ Yes | Fastest |

**Recommendation**: Install `gh` CLI for best experience with private repos.

## How It Works

### Retrieval-Led Reasoning Approach

```
Parse Query → Locate Docs → Navigate (≤5 docs) → Gather Context → Synthesize
```

**NOT** sequential reading - uses KNOWLEDGE_GRAPH task maps!

### Navigation Strategy

1. **Entry Point**: Read AGENTS.md / OPENSHIFT_AGENTS.md
2. **Task Map**: Use KNOWLEDGE_GRAPH.md to find relevant path
3. **Targeted Reading**: Read 4-5 specific docs based on query type
4. **Examples**: Check real component implementations
5. **Synthesis**: Generate answer/spec/debug guide

### Query Types

| Type | Example | Output |
|------|---------|--------|
| **Question** | "How do operators report status?" | Answer with pattern details + examples |
| **Feature** | "Implement webhook validation" + `--output-spec` | Full specification with design + implementation plan |
| **Bug** | "Node reboot failures during upgrade" | Debugging guide with diagnostics + potential fixes |

## Examples

### Example 1a: Answer a Question (Local Repos)

```bash
# Assumes you have local clones of:
# - ../enhancements (Tier 1)
# - ../machine-config-operator (for examples)

/agentic-docs-maintainer:fetch "How do operators report status?"
```

**What it does:**
1. Reads local: `../enhancements/agentic/OPENSHIFT_AGENTS.md`
2. Reads local: `../enhancements/agentic/platform/operator-patterns/status-conditions.md`
3. Reads local: `../enhancements/agentic/domain/openshift/clusteroperator.md`
4. Checks local: `../machine-config-operator`, `../cluster-network-operator`
5. **Output**: Answer with Available/Progressing/Degraded pattern + code examples

### Example 1b: Answer a Question (Force Remote)

```bash
# Force remote mode - always fetch latest from GitHub
# (even if local repos exist)

/agentic-docs-maintainer:fetch "How do operators report status?" --remote
```

**What it does:**
```
🔍 Source mode: remote
📡 Remote-only mode: fetching from GitHub only
  📡 Tier 1: https://github.com/openshift/enhancements
🔍 Fetching via gh CLI: openshift/enhancements/agentic/OPENSHIFT_AGENTS.md
🔍 Fetching via gh CLI: openshift/enhancements/agentic/KNOWLEDGE_GRAPH.md
🔍 Fetching via gh CLI: openshift/enhancements/agentic/platform/operator-patterns/status-conditions.md
🔍 Fetching via gh CLI: openshift/enhancements/agentic/domain/openshift/clusteroperator.md
```

**Output**: Answer with latest docs from GitHub (guaranteed fresh)

### Example 1c: Answer a Question (Force Local)

```bash
# Force local mode - fail if not found locally
# (useful for offline development)

/agentic-docs-maintainer:fetch "How do operators report status?" --local
```

**What it does:**
```
🔍 Source mode: local
📁 Local-only mode: searching filesystem only
  ✅ Tier 1 found: ../enhancements/agentic
🔍 Reading local files...
```

**If repos not found locally:**
```
🔍 Source mode: local
📁 Local-only mode: searching filesystem only
  ❌ Tier 1 not found locally
     Hint: Use --remote to fetch from GitHub, or clone repos locally
```

### Example 2: Research Feature Implementation

```bash
/agentic-docs-maintainer:fetch "implementing webhook validation" --component machine-config-operator --output-spec
```

**What it does:**
1. Reads DESIGN_PHILOSOPHY.md (principles)
2. Reads platform/operator-patterns/webhooks.md (pattern)
3. Reads practices/development/api-evolution.md (API guidelines)
4. Reads practices/testing/pyramid.md (testing strategy)
5. Checks similar webhooks in: machine-api-operator, cluster-network-operator
6. **Output**: Full spec with design, implementation plan, test strategy, code templates

### Example 3: Debug an Issue

```bash
/agentic-docs-maintainer:fetch "nodes failing to update during upgrade" --component machine-config-operator
```

**What it does:**
1. Reads machine-config-operator/agentic/AGENTS.md
2. Reads architecture/components.md (MCD/MCC/MCS)
3. Reads platform/operator-patterns/upgrade-strategies.md
4. Reads practices/reliability/observability.md
5. Checks recent MCO bugs/PRs
6. **Output**: Debugging guide with diagnostics, logs to check, potential causes

### Example 4: Cross-Component Feature Research

```bash
/agentic-docs-maintainer:fetch "multi-tenant network isolation patterns" --output-spec
```

**What it does:**
1. Reads OPENSHIFT_AGENTS.md
2. Reads domain/openshift/route.md, domain/kubernetes/service.md
3. Reads practices/security/threat-modeling.md
4. Reads platform/operator-patterns/rbac-patterns.md
5. Checks implementations in: cluster-network-operator, authentication-operator
6. **Output**: Cross-component spec with network policies, RBAC patterns, examples

### Example 5: Non-OpenShift Component (Outrigger Project)

```bash
/agentic-docs-maintainer:fetch "multi-architecture support patterns" \
  --tier2 outrigger-project/multiarch-tuning-operator \
  --output-spec
```

**What it does:**
```
📡 Tier 1 not found locally, will fetch from: https://github.com/openshift/enhancements
📡 Tier 2 specified: https://github.com/outrigger-project/multiarch-tuning-operator
🔍 Fetching via gh CLI: openshift/enhancements/agentic/OPENSHIFT_AGENTS.md
🔍 Fetching via gh CLI: outrigger-project/multiarch-tuning-operator/AGENTS.md
⚠️  No agentic/ docs found in outrigger-project/multiarch-tuning-operator
🔍 Falling back to README.md and repository structure
🔍 Analyzing code structure for patterns
```

**Output**: Specification based on:
- Tier 1 patterns from openshift/enhancements
- Repository structure from outrigger-project/multiarch-tuning-operator
- Similar patterns in openshift components
- README.md and existing code analysis

## Output Formats

### For Questions (default)
```markdown
# Answer to: [question]

## Summary
[Concise answer]

## How It Works
[Detailed explanation with context]

## Implementation Pattern
[Code examples from patterns]

## Examples in OpenShift
- Component 1: [how they do it]
- Component 2: [similar approach]

## Best Practices
[From practices/]

## References
- Docs: [agentic/ files read]
- Code: [component links]
```

### For Features (--output-spec)
```markdown
# Feature Specification: [name]

## Context from Existing Patterns
### Related Domain Concepts
### Applicable Platform Patterns
### Similar Implementations

## Proposed Design
### API Changes
### Controller Implementation
### Status Reporting
### Testing Strategy

## Engineering Practices to Follow
### Security
### Reliability
### Development

## Architectural Constraints
### From ADRs
### From DESIGN_PHILOSOPHY

## Implementation Plan
[Phases with checkboxes]

## References
[All docs consulted]
```

### For Bugs (debugging context)
```markdown
# Bug Investigation: [description]

## Expected Behavior
[From domain/architecture docs]

## Component Architecture
[How it should work]

## Debugging Approach
### Observability (logs, metrics, events)
### Must-Gather
### Common Issues

## Root Cause Hypotheses
[Based on patterns and architecture]

## Validation Steps
[Commands to check status]

## Potential Fixes
[Based on similar issues and patterns]

## References
[Architecture, patterns, similar bugs]
```

## Success Criteria

**Effective retrieval:**
- ✅ Read ≤5 documents (used KNOWLEDGE_GRAPH navigation)
- ✅ Found relevant context for query
- ✅ Included real examples from components
- ✅ Generated actionable output
- ✅ Referenced official docs when applicable

**Ineffective retrieval:**
- ❌ Read >10 documents (ignored navigation maps)
- ❌ Generic answers without OpenShift context
- ❌ No examples from actual implementations

## Use Cases

### Use Case 1: Learning How Something Works
```bash
# New to OpenShift, want to understand status reporting
/agentic-docs-maintainer:fetch "How do ClusterOperators work?"

# Result: Clear explanation of ClusterOperator pattern with examples
```

### Use Case 2: Planning a New Feature
```bash
# Need to add a new webhook to MCO
/agentic-docs-maintainer:fetch "add validating webhook for MachineConfigPool" \
  --component machine-config-operator \
  --output-spec

# Result: Complete spec ready to use for implementation
```

### Use Case 3: Debugging Production Issue
```bash
# Nodes stuck in "Progressing" during upgrade
/agentic-docs-maintainer:fetch "MachineConfigPool stuck progressing" \
  --component machine-config-operator

# Result: Debugging guide with diagnostics and common causes
```

### Use Case 4: Cross-Component Design
```bash
# Designing feature spanning multiple operators
/agentic-docs-maintainer:fetch "coordinate upgrades across operators" --output-spec

# Result: Spec with CVO pattern, upgrade-strategies, coordination approach
```

## Integration with Other Skills

**Use fetch before:**
- Creating exec-plans (research first)
- Implementing features (understand patterns first)
- Debugging complex issues (gather context first)

**Use fetch with:**
```bash
# Research → Document
/agentic-docs-maintainer:fetch "multi-tenancy" --output-spec > multi-tenancy-spec.md

# Research → Create exec-plan
cd machine-config-operator
/agentic-docs-maintainer:fetch "SELinux labeling" --component mco --output-spec
# Use output to populate exec-plans/active/selinux-labeling.md

# Research → Verify navigability
/agentic-docs-maintainer:fetch "operator patterns"
/agentic-docs-maintainer:verify  # Check if navigation worked
```

## When NOT to Use

**Don't use fetch if:**
- You already know exactly which file to read (just read it directly)
- Question is about non-OpenShift topics
- Agentic docs don't exist yet
- Need to modify docs (use :fix, :extract, or :tier2-component instead)

## Implementation

Execution handled by skill at: `skills/fetch/SKILL.md`

**Key phases:**
1. Parse query (identify type, components, concepts)
2. Locate docs (find Tier 1 + Tier 2)
3. Navigate (use KNOWLEDGE_GRAPH, read ≤5 docs)
4. Gather context (domain + patterns + practices + examples)
5. Synthesize (generate answer/spec/debug guide)

## See Also

- `/agentic-docs-maintainer:extract` - Extract knowledge FROM enhancements TO create docs
- `/agentic-docs-maintainer:tier2-component` - Create component documentation
- `/agentic-docs-maintainer:verify` - Verify documentation structure

---

**Pattern**: Intelligent retrieval and synthesis
**Version**: 1.0
