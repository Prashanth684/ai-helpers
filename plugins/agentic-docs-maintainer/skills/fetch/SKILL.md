---
name: fetch
description: Intelligent retrieval agent - navigates agentic docs to find context for OpenShift questions, features, and bugs
trigger: explicit
model: sonnet
---

# Fetch Skill - Retrieval Agent

## Purpose

Acts as a retrieval agent that intelligently navigates OpenShift documentation to gather the correct context for:
- Answering questions about OpenShift components and features
- Understanding how to implement a feature
- Investigating and fixing bugs
- Generating specifications for new work

**Key capability**: Follows agentic/ structure guidance to find information efficiently, avoiding reading all docs.

## When to Use This Skill

Use `/fetch` when:
- User asks a question about OpenShift enhancements or repositories
- Need to understand how a feature works across multiple components
- Planning a new feature and need context about existing patterns
- Debugging an issue and need to understand component interactions
- Generating a specification or design doc

## Arguments

```bash
/fetch <question|feature|bug> [--component <name>] [--output-spec]
```

**Arguments:**
- `<question|feature|bug>`: What you're investigating (required)
- `--component <name>`: Narrow search to specific component (optional)
- `--output-spec`: Generate a specification document based on findings (optional)
- `--tier1-only`: Only search Tier 1 ecosystem docs (optional)
- `--tier2 <repo>`: Search specific component's Tier 2 docs (optional)

**Examples:**
```bash
# Answer a question (auto mode - local first, fallback to remote)
/fetch "How do operators report status?"

# Force remote fetch (skip local checks)
/fetch "How do operators report status?" --remote

# Force local only (fail if not found)
/fetch "How do operators report status?" --local

# Research for feature implementation (remote component)
/fetch "implementing webhook validation" \
  --tier2 openshift/machine-config-operator \
  --output-spec

# Bug investigation (force remote)
/fetch "node reboot failures during upgrade" \
  --tier2 openshift/machine-config-operator \
  --remote

# Cross-component feature (local only)
/fetch "multi-tenant networking isolation" --output-spec --local
```

## How It Works

The fetch skill follows a **retrieval-led reasoning** approach:

```
1. Parse Query → 2. Locate Docs → 3. Navigate Intelligently → 4. Gather Context → 5. Synthesize
```

### Phase 1: Parse Query
- Identify intent (question/feature/bug)
- Extract key concepts and components
- Determine scope (cross-repo vs component-specific)

### Phase 2: Locate Documentation
- Find Tier 1 (ecosystem hub)
- Find Tier 2 (component repos) if specified
- Check for AGENTS.md entry points

### Phase 3: Navigate Intelligently
- Read KNOWLEDGE_GRAPH.md for navigation strategy
- Use "I want to..." task maps
- Follow references, NOT sequential reading
- Target 4-5 docs max (per KNOWLEDGE_GRAPH guidance)

### Phase 4: Gather Context
- Domain concepts (what things are)
- Platform patterns (how things work)
- Engineering practices (how to implement)
- ADRs (why decisions were made)
- Existing implementations (examples)

### Phase 5: Synthesize
- Answer question with context
- OR generate specification if --output-spec

## Execution Protocol

### Step 1: Parse and Analyze Query

**Actions:**
```markdown
1. Identify query type:
   - Question: "How does X work?"
   - Feature: "Implement Y" or "Add support for Z"
   - Bug: "X is failing" or "Debug Y issue"

2. Extract components:
   - Component names (e.g., "machine-config-operator", "cluster-network-operator")
   - Platform concepts (e.g., "ClusterOperator", "MachineConfig", "Route")
   - Patterns (e.g., "webhook", "status conditions", "finalizers")

3. Determine scope:
   - Cross-repo (Tier 1): Affects multiple components
   - Component-specific (Tier 2): Single component
```

**Output:**
```
Query Analysis:
  Type: [question|feature|bug]
  Components: [list]
  Concepts: [list]
  Scope: [tier1|tier2|both]
  Priority: [what to look for first]
```

### Step 2: Locate Documentation Structure

**CRITICAL**: Fetch supports **three modes**: `--local`, `--remote`, or auto (default)!

**Mode Selection:**
```bash
# Parse source mode from arguments
SOURCE_MODE="auto"  # default
if [ "$ARG_LOCAL" = "true" ]; then
    SOURCE_MODE="local"
elif [ "$ARG_REMOTE" = "true" ]; then
    SOURCE_MODE="remote"
fi

echo "🔍 Source mode: $SOURCE_MODE"
```

**Strategy by Mode:**

| Mode | Behavior | Use Case |
|------|----------|----------|
| `--local` | Only local filesystem, fail if not found | Offline dev, testing, known local clones |
| `--remote` | Only GitHub, skip local checks | Always get latest, no local repos, CI/CD |
| *(auto)* | Try local first, fallback to remote | Best of both worlds (default) |

**Actions:**
```bash
# ============================================
# Step 2.1: Locate Based on Mode
# ============================================

TIER1_PATH=""
TIER1_REMOTE=""
TIER2_PATH=""
TIER2_REMOTE=""

# ========== MODE: --local ==========
if [ "$SOURCE_MODE" = "local" ]; then
    echo "📁 Local-only mode: searching filesystem only"
    
    # Find Tier 1 - LOCAL ONLY
    for candidate in \
        "../enhancements/agentic" \
        "../../openshift/enhancements/agentic" \
        "$OPENSHIFT_ENHANCEMENTS_AGENTIC"; do
        if [ -d "$candidate" ]; then
            TIER1_PATH="$candidate"
            echo "  ✅ Tier 1 found: $TIER1_PATH"
            break
        fi
    done
    
    if [ -z "$TIER1_PATH" ]; then
        echo "  ❌ Tier 1 not found locally"
        echo "     Hint: Use --remote to fetch from GitHub, or clone repos locally"
        exit 1
    fi
    
    # Find Tier 2 - LOCAL ONLY
    if [ -n "$COMPONENT" ] || [ -n "$TIER2_FLAG" ]; then
        for candidate in \
            "../$COMPONENT/agentic" \
            "../../$COMPONENT/agentic" \
            "./$COMPONENT/agentic" \
            "./agentic"; do
            if [ -d "$candidate" ]; then
                TIER2_PATH="$candidate"
                echo "  ✅ Tier 2 found: $TIER2_PATH"
                break
            fi
        done
        
        if [ -z "$TIER2_PATH" ]; then
            echo "  ❌ Tier 2 not found locally"
            exit 1
        fi
    fi

# ========== MODE: --remote ==========
elif [ "$SOURCE_MODE" = "remote" ]; then
    echo "📡 Remote-only mode: fetching from GitHub only"
    
    # Skip local checks, go straight to remote
    TIER1_REMOTE="https://github.com/openshift/enhancements"
    echo "  📡 Tier 1: $TIER1_REMOTE"
    
    if [ -n "$TIER2_FLAG" ]; then
        TIER2_REMOTE="https://github.com/$TIER2_FLAG"
        echo "  📡 Tier 2: $TIER2_REMOTE"
    elif [ -n "$COMPONENT" ]; then
        # Try to infer GitHub repo
        if gh repo view "openshift/$COMPONENT" >/dev/null 2>&1; then
            TIER2_REMOTE="https://github.com/openshift/$COMPONENT"
            echo "  📡 Tier 2: $TIER2_REMOTE (inferred from component name)"
        else
            echo "  ⚠️  Cannot infer repo for component: $COMPONENT"
            echo "     Use: --tier2 org/repo"
        fi
    fi

# ========== MODE: auto (default) ==========
else
    echo "🔄 Auto mode: trying local first, fallback to remote"
    
    # Find Tier 1 - LOCAL FIRST
    for candidate in \
        "../enhancements/agentic" \
        "../../openshift/enhancements/agentic" \
        "$OPENSHIFT_ENHANCEMENTS_AGENTIC"; do
        if [ -d "$candidate" ]; then
            TIER1_PATH="$candidate"
            echo "  ✅ Tier 1 found locally: $TIER1_PATH"
            break
        fi
    done
    
    # Fallback to remote if not local
    if [ -z "$TIER1_PATH" ]; then
        TIER1_REMOTE="https://github.com/openshift/enhancements"
        echo "  📡 Tier 1 not found locally, will fetch from: $TIER1_REMOTE"
    fi
    
    # Find Tier 2 - LOCAL FIRST
    if [ -n "$COMPONENT" ] || [ -n "$TIER2_FLAG" ]; then
        for candidate in \
            "../$COMPONENT/agentic" \
            "../../$COMPONENT/agentic" \
            "./$COMPONENT/agentic" \
            "./agentic"; do
            if [ -d "$candidate" ]; then
                TIER2_PATH="$candidate"
                echo "  ✅ Tier 2 found locally: $TIER2_PATH"
                break
            fi
        done
        
        # Fallback to remote if not local
        if [ -z "$TIER2_PATH" ]; then
            if [ -n "$TIER2_FLAG" ]; then
                TIER2_REMOTE="https://github.com/$TIER2_FLAG"
                echo "  📡 Tier 2 not found locally, will fetch from: $TIER2_REMOTE"
            elif [ -n "$COMPONENT" ]; then
                if gh repo view "openshift/$COMPONENT" >/dev/null 2>&1; then
                    TIER2_REMOTE="https://github.com/openshift/$COMPONENT"
                    echo "  📡 Tier 2 not found locally, will fetch from: $TIER2_REMOTE"
                fi
            fi
        fi
    fi
fi
```

**Output:**
```
Documentation Locations:
  Tier 1:
    Local: $TIER1_PATH (found/not found)
    Remote: $TIER1_REMOTE (if not local)
  
  Tier 2:
    Local: $TIER2_PATH (found/not found)
    Remote: $TIER2_REMOTE (if not local)
  
  Entry Points:
    - Local: $TIER1_PATH/OPENSHIFT_AGENTS.md
    - Remote: $TIER1_REMOTE/blob/master/agentic/OPENSHIFT_AGENTS.md
    - Component: $TIER2_PATH/AGENTS.md (local) or $TIER2_REMOTE/blob/master/AGENTS.md (remote)
```

### Step 2.3: Helper - Fetch File from GitHub

**Function to read files from remote repos:**

```bash
# fetch_github_file <repo_url> <file_path>
# Examples:
#   fetch_github_file "https://github.com/openshift/enhancements" "agentic/OPENSHIFT_AGENTS.md"
#   fetch_github_file "https://github.com/outrigger-project/multiarch-tuning-operator" "AGENTS.md"

fetch_github_file() {
    local repo_url="$1"
    local file_path="$2"
    
    # Extract org/repo from URL
    local org_repo=$(echo "$repo_url" | sed 's|https://github.com/||' | sed 's|\.git$||')
    
    # Try using gh CLI first (handles authentication)
    if command -v gh >/dev/null 2>&1; then
        echo "🔍 Fetching via gh CLI: $org_repo/$file_path" >&2
        gh api "repos/$org_repo/contents/$file_path" \
            --jq '.content' | base64 -d
        return $?
    fi
    
    # Fallback to raw.githubusercontent.com (public repos only)
    local raw_url="https://raw.githubusercontent.com/$org_repo/master/$file_path"
    echo "🔍 Fetching via raw URL: $raw_url" >&2
    
    # Use WebFetch tool
    # (Note: In actual execution, this would be a tool call)
    curl -s "$raw_url" || {
        # Try main branch if master doesn't exist
        raw_url="https://raw.githubusercontent.com/$org_repo/main/$file_path"
        echo "🔍 Retrying with main branch: $raw_url" >&2
        curl -s "$raw_url"
    }
}

# Helper to read file (local or remote)
read_doc() {
    local file_path="$1"
    local remote_repo="$2"  # Optional: GitHub repo URL
    
    if [ -f "$file_path" ]; then
        # Local file
        cat "$file_path"
    elif [ -n "$remote_repo" ]; then
        # Remote file
        fetch_github_file "$remote_repo" "${file_path#*/agentic/}"
    else
        echo "❌ File not found: $file_path" >&2
        return 1
    fi
}
```

### Step 3: Navigate Using KNOWLEDGE_GRAPH

**CRITICAL: Follow retrieval-led reasoning - DON'T read all docs!**

**Actions:**
```markdown
1. Read entry point (OPENSHIFT_AGENTS.md or AGENTS.md):
   - LOCAL: Use Read tool with $TIER1_PATH/OPENSHIFT_AGENTS.md
   - REMOTE: Use fetch_github_file() or WebFetch tool
   - Get overview
   - Identify navigation strategy
   - Note "I want to..." task maps

2. Read KNOWLEDGE_GRAPH.md (if exists):
   - LOCAL: Use Read tool
   - REMOTE: Use fetch_github_file() or WebFetch tool
   - Find your task path
   - Identify 4-5 docs to read
   - Note cross-references

3. For your query type, navigate to relevant sections:

   **For Questions** ("How does X work?"):
   - domain/ → Understand what X is
   - platform/operator-patterns/ → Understand how X works
   - practices/ → Understand implementation details
   - examples in existing components

   **For Features** ("Implement Y"):
   - DESIGN_PHILOSOPHY.md → Understand principles
   - domain/ → Understand related concepts
   - platform/operator-patterns/ → Understand patterns to use
   - practices/development/ → Understand implementation approach
   - decisions/ → Understand architectural constraints
   - existing components → Find similar implementations

   **For Bugs** ("Debug Z issue"):
   - domain/ → Understand what should happen
   - architecture/ → Understand component structure
   - practices/reliability/ → Understand observability/debugging
   - existing issues/PRs → Similar problems
   - must-gather pattern → Diagnostic approach

4. Follow references selectively:
   - Read referenced docs if critical to understanding
   - Skip tangential references
   - Stop when you have enough context (target: 4-5 docs)
```

**Output:**
```
Navigation Path:
  1. Entry: OPENSHIFT_AGENTS.md
  2. Graph: KNOWLEDGE_GRAPH.md → task path: [list steps]
  3. Domain: [specific files to read]
  4. Patterns: [specific files to read]
  5. Examples: [component implementations]
  
  Total docs to read: [count] (target: ≤5)
```

### Step 4: Gather Context

**Actions:**
```markdown
For each doc in navigation path:

1. Read the document
2. Extract relevant information:
   - Key concepts and definitions
   - How things work (patterns, flows)
   - Why decisions were made (ADRs)
   - Examples from real implementations
   - Best practices and anti-patterns
   - Related components/concepts

3. Track references:
   - Official docs (dev-guide/, guidelines/)
   - Enhancement proposals
   - Component repositories
   - Related patterns

4. Build context incrementally:
   - Start with fundamentals (domain concepts)
   - Add implementation patterns
   - Add practical examples
   - Add constraints (ADRs, practices)
```

**Output (Internal Context):**
```markdown
## Context Gathered

### Domain Concepts
- [Concept 1]: [Definition from domain/]
- [Concept 2]: [Definition from domain/]

### Platform Patterns
- [Pattern 1]: [How it works from platform/operator-patterns/]
- [Pattern 2]: [Implementation details]

### Engineering Practices
- [Practice 1]: [Guidelines from practices/]
- [Best Practice]: [From existing implementations]

### Architectural Decisions
- [ADR 1]: [Why decision made from decisions/]
- [Constraint]: [Implications]

### Examples
- [Component 1]: [How it implements similar feature]
- [Component 2]: [Relevant patterns used]

### References
- Official docs: [Links]
- Enhancements: [Links]
- Code: [Repository links]
```

### Step 5: Synthesize Results

**For Questions** (default):
```markdown
# Answer to: [original question]

## Summary
[1-2 paragraph concise answer]

## How It Works
[Detailed explanation using gathered context]

## Key Concepts
- [Concept 1]: [Definition]
- [Concept 2]: [Definition]

## Implementation Pattern
[Relevant pattern with code examples if applicable]

## Examples in OpenShift
- [Component 1]: [How they do it]
- [Component 2]: [Similar implementation]

## Best Practices
- [Practice 1]
- [Practice 2]

## References
- Documentation: [Links to agentic/ docs read]
- Code: [Links to component implementations]
- Enhancements: [Links to relevant proposals]
```

**For Features** (with --output-spec):
```markdown
# Feature Specification: [feature name]

**Generated from**: Retrieval across OpenShift documentation
**Date**: [date]
**Scope**: [cross-repo | component-specific]

---

## Overview

[What the feature does, based on query]

## Context from Existing Patterns

### Related Domain Concepts
[Concepts from domain/ that apply]

### Applicable Platform Patterns
[Patterns from platform/operator-patterns/ to use]

### Similar Implementations
[Examples from existing components]

## Proposed Design

### API Changes
[If applicable - based on api-evolution.md practices]

```yaml
# Example CRD or API change
```

### Controller Implementation
[Based on controller-runtime.md pattern]

```go
// Reconciliation logic structure
func (r *Reconciler) Reconcile(ctx context.Context, req ctrl.Request) (ctrl.Result, error) {
    // 1. Fetch resource
    // 2. Reconcile to desired state
    // 3. Update status
}
```

### Status Reporting
[Based on status-conditions.md pattern]

### Testing Strategy
[Based on practices/testing/pyramid.md]
- Unit tests: [what to test]
- Integration tests: [what to test]
- E2E tests: [what to test]

## Engineering Practices to Follow

### Security
[Based on practices/security/]

### Reliability
[Based on practices/reliability/]

### Development
[Based on practices/development/]

## Architectural Constraints

### From ADRs
[Relevant decisions from decisions/]

### From DESIGN_PHILOSOPHY
[Relevant principles]

## Implementation Plan

### Phase 1: API
- [ ] Define CRD
- [ ] API review

### Phase 2: Controller
- [ ] Implement reconciliation
- [ ] Add status reporting

### Phase 3: Testing
- [ ] Unit tests
- [ ] Integration tests
- [ ] E2E tests

### Phase 4: Documentation
- [ ] Update AGENTS.md
- [ ] Add domain/ docs
- [ ] Create exec-plan

## References

### Documentation Read
[List all agentic/ docs consulted]

### Similar Features
[Links to similar implementations]

### Enhancement Proposals
[Relevant enhancements]

### Official Guides
[dev-guide/, guidelines/ references]
```

**For Bugs** (with debugging context):
```markdown
# Bug Investigation: [bug description]

**Generated from**: Retrieval across OpenShift documentation
**Component**: [component name]
**Date**: [date]

---

## Symptom
[What's failing]

## Expected Behavior
[From domain/ and architecture/ docs]

## Component Architecture
[From architecture/ docs - how component works]

## Relevant Patterns
[Patterns from platform/operator-patterns/ that apply]

## Debugging Approach

### 1. Observability
[From practices/reliability/observability.md]
- Logs to check: [locations]
- Metrics to check: [prometheus queries]
- Events to check: [kubectl get events]

### 2. Must-Gather
[From platform/operator-patterns/must-gather.md]
```bash
# Gather diagnostics
oc adm must-gather -- /usr/bin/gather_[component]
```

### 3. Common Issues
[From similar bugs in component]

### 4. Root Cause Hypotheses
Based on architecture and patterns:
1. [Hypothesis 1]
2. [Hypothesis 2]

## Validation Steps

### Check Status Conditions
[From status-conditions.md pattern]
```bash
oc get clusteroperator [name] -o yaml
# Check Available/Progressing/Degraded
```

### Check Reconciliation
[From controller-runtime.md pattern]
```bash
# Check controller logs for reconciliation errors
oc logs -n [namespace] deployment/[operator]
```

## Potential Fixes

### Based on Similar Issues
[From component history]

### Based on Patterns
[Standard fixes from practices/]

## References
- Architecture: [Links]
- Patterns: [Links]
- Similar bugs: [Links]
- Code: [Repository links]
```

## Examples

### Example 1: Question - "How do operators report status?" (Local)

```bash
/fetch "How do operators report status?"
```

**Retrieval Path:**
1. Read: `OPENSHIFT_AGENTS.md` (local if available, else fetch from GitHub)
2. Read: `platform/operator-patterns/status-conditions.md`
3. Read: `domain/openshift/clusteroperator.md`
4. Read: `domain/openshift/clusterversion.md`
5. Check examples in: `machine-config-operator`, `cluster-network-operator`

**Output:** Answer with pattern details, code examples, real implementations

### Example 1b: Question - "How do operators report status?" (Remote)

```bash
# No local enhancements repo - fetch from GitHub
/fetch "How do operators report status?"
```

**What happens:**
```
📡 Tier 1 not found locally, will fetch from: https://github.com/openshift/enhancements
🔍 Fetching via gh CLI: openshift/enhancements/agentic/OPENSHIFT_AGENTS.md
🔍 Fetching via gh CLI: openshift/enhancements/agentic/KNOWLEDGE_GRAPH.md
🔍 Fetching via gh CLI: openshift/enhancements/agentic/platform/operator-patterns/status-conditions.md
...
```

**Output:** Same answer, but fetched from GitHub instead of local filesystem

### Example 2: Feature - "Implement webhook validation for MachineConfig" (Remote Component)

```bash
/fetch "implementing webhook validation" \
  --tier2 openshift/machine-config-operator \
  --output-spec
```

**Retrieval Path:**
1. Read: `DESIGN_PHILOSOPHY.md` (Tier 1 - from openshift/enhancements)
2. Read: `platform/operator-patterns/webhooks.md` (Tier 1)
3. Read: `practices/development/api-evolution.md` (Tier 1)
4. Read: `practices/testing/pyramid.md` (Tier 1)
5. Read: `machine-config-operator/agentic/AGENTS.md` (Tier 2 - from GitHub)
6. Read: `machine-config-operator/agentic/architecture/components.md` (Tier 2 - from GitHub)
7. Check: Similar webhooks in other operators

**What happens:**
```
📡 Tier 1 not found locally, will fetch from: https://github.com/openshift/enhancements
📡 Tier 2 not found locally, will fetch from: https://github.com/openshift/machine-config-operator
🔍 Fetching via gh CLI: openshift/enhancements/agentic/DESIGN_PHILOSOPHY.md
🔍 Fetching via gh CLI: openshift/enhancements/agentic/platform/operator-patterns/webhooks.md
🔍 Fetching via gh CLI: openshift/machine-config-operator/agentic/AGENTS.md
...
```

**Output:** Full specification document with design, implementation plan, testing strategy

### Example 3: Bug - "Nodes failing to update during upgrade" (Remote Component)

```bash
/fetch "node reboot failures during upgrade" \
  --tier2 openshift/machine-config-operator
```

**Retrieval Path:**
1. Read: `machine-config-operator/agentic/AGENTS.md` (from GitHub)
2. Read: `machine-config-operator/agentic/architecture/components.md` (from GitHub)
3. Read: `platform/operator-patterns/upgrade-strategies.md` (Tier 1 from GitHub)
4. Read: `practices/reliability/observability.md` (Tier 1 from GitHub)
5. Check: Recent bugs/PRs in MCO using `gh` CLI

**What happens:**
```
📡 Tier 1 not found locally, will fetch from: https://github.com/openshift/enhancements
📡 Tier 2 not found locally, will fetch from: https://github.com/openshift/machine-config-operator
🔍 Fetching via gh CLI: openshift/machine-config-operator/agentic/AGENTS.md
🔍 Fetching via gh CLI: openshift/machine-config-operator/agentic/architecture/components.md
🔍 Searching recent issues: gh issue list --repo openshift/machine-config-operator --search "node reboot upgrade"
...
```

**Output:** Debugging guide with likely causes, diagnostic steps, potential fixes

### Example 4: Non-OpenShift Component (Outrigger Project)

```bash
/fetch "multi-architecture support patterns" \
  --tier2 outrigger-project/multiarch-tuning-operator \
  --output-spec
```

**Retrieval Path:**
1. Read: Tier 1 from openshift/enhancements (architecture patterns)
2. Read: `multiarch-tuning-operator/AGENTS.md` from outrigger-project (if exists)
3. Read: `multiarch-tuning-operator/README.md` (fallback if no agentic/)
4. Check: Similar patterns in openshift repos

**What happens:**
```
📡 Tier 1 not found locally, will fetch from: https://github.com/openshift/enhancements
📡 Tier 2 not found locally, will fetch from: https://github.com/outrigger-project/multiarch-tuning-operator
🔍 Fetching via gh CLI: openshift/enhancements/agentic/OPENSHIFT_AGENTS.md
🔍 Fetching via gh CLI: outrigger-project/multiarch-tuning-operator/AGENTS.md
⚠️  No agentic/ docs found in outrigger-project/multiarch-tuning-operator
🔍 Falling back to README.md and code structure
...
```

**Output:** Specification based on Tier 1 patterns + repo structure + existing code

## Success Criteria

**Effective retrieval when:**
- ✅ Read ≤5 documents (not all docs sequentially)
- ✅ Followed KNOWLEDGE_GRAPH navigation
- ✅ Found relevant context for query
- ✅ Included real examples from components
- ✅ Referenced official docs when applicable
- ✅ Generated actionable output (answer/spec/debug guide)

**Ineffective retrieval when:**
- ❌ Read >10 documents (too broad)
- ❌ Ignored KNOWLEDGE_GRAPH navigation
- ❌ Generic answers without OpenShift context
- ❌ No examples from actual components
- ❌ Missing official doc references

## Anti-Patterns

### ❌ DON'T read all docs sequentially

**Wrong:**
```markdown
Reading all 45 docs in agentic/...
```

**Right:**
```markdown
1. KNOWLEDGE_GRAPH.md → task path: webhook implementation
2. Read 4 docs: webhooks.md, api-evolution.md, threat-modeling.md, examples
3. Synthesize answer
```

### ❌ DON'T ignore existing examples

**Wrong:**
```markdown
Generated theoretical webhook design without checking existing implementations
```

**Right:**
```markdown
Checked:
- machine-api-operator: Validates Machine configurations
- cluster-network-operator: Mutates network configs
- console-operator: Validates console extensions

Pattern used: [extracted from examples]
```

### ❌ DON'T generate specs without foundation

**Wrong:**
```markdown
--output-spec → Created spec without reading DESIGN_PHILOSOPHY, patterns, practices
```

**Right:**
```markdown
--output-spec →
1. DESIGN_PHILOSOPHY.md (principles)
2. Relevant patterns (webhooks.md, status-conditions.md)
3. Relevant practices (api-evolution.md, testing/pyramid.md)
4. Examples (existing implementations)
5. Generate spec based on foundation
```

## Integration with Other Skills

**Fetch skill complements:**
- `/agentic-docs-maintainer:extract` - Fetch gathers, extract creates docs
- `/agentic-docs-maintainer:tier2-component` - Fetch researches, tier2 documents
- `/agentic-docs-maintainer:verify` - Fetch validates structure is navigable

**Workflow:**
```bash
# Research feature
/fetch "multi-tenancy for operators" --output-spec

# Create exec-plan in component repo
cd machine-config-operator
# Use fetch output to create exec-plans/active/multi-tenancy.md

# Verify docs are navigable
/agentic-docs-maintainer:verify
```

## Output Format

```
🔍 Fetch Results: [query]

Navigation Path:
  📍 Entry: [OPENSHIFT_AGENTS.md | AGENTS.md]
  🗺️  Graph: [task path from KNOWLEDGE_GRAPH]
  📚 Docs Read: [count] / 5 target
    - [doc 1]
    - [doc 2]
    - [doc 3]
    ...

Context Gathered:
  ✅ Domain Concepts: [count]
  ✅ Platform Patterns: [count]
  ✅ Engineering Practices: [count]
  ✅ Examples: [count] components
  ✅ References: [count] official docs

[SYNTHESIZED OUTPUT - answer/spec/debug guide]

---
⏱️  Retrieval Time: [estimated]
📊 Efficiency: [docs read]/[docs available] = [percentage]
```

## References

This skill implements:
- **Retrieval-led reasoning**: From KNOWLEDGE_GRAPH.md and OPENSHIFT_AGENTS.md
- **Two-tier navigation**: Tier 1 (ecosystem) + Tier 2 (component)
- **Progressive disclosure**: Read foundation + task-specific, not everything
- **Synthesis over search**: Generate actionable output from gathered context

---

**Pattern**: Intelligent documentation retrieval and synthesis
**Version**: 1.0
