# Fetch Skill - All Options Explained

## Command Syntax

```bash
/agentic-docs-maintainer:fetch <query> [options]
```

## Required Argument

### `<query>`

**What it is:** The question, feature description, or bug you're investigating.

**How it's used:** Fetch skill parses this to:
1. Identify query type (question/feature/bug)
2. Extract concepts (e.g., "webhook", "validation", "MachineConfigPool")
3. Navigate KNOWLEDGE_GRAPH.md to find relevant docs

**Examples:**
```bash
# Question
/fetch "How do operators report status?"
→ Returns: Explanation with patterns + code examples

# Feature (with --output-spec)
/fetch "Add webhook validation for MachineConfigPool" --output-spec
→ Returns: Complete specification document

# Bug
/fetch "nodes failing to update during upgrade" --component machine-config-operator
→ Returns: Debugging guide with diagnostics
```

---

## Optional Flags

### `--output-spec`

**What it does:** Changes output format from "answer" to "specification document"

**Use when:** You want a full spec for implementing a feature (not just an answer)

**Without --output-spec (default):**
```bash
/fetch "How do webhooks work?"
```
**Output:**
```markdown
# Answer: How Webhooks Work

## Summary
Webhooks in OpenShift operators use controller-runtime's webhook framework...

## How It Works
1. Register webhook server with admission controller
2. Define validation/mutation logic
...

## Examples
- machine-api-operator: Validates Machine resources
- cluster-network-operator: Validates NetworkPolicy
```

**With --output-spec:**
```bash
/fetch "implementing webhook validation" --output-spec
```
**Output:**
```markdown
# Feature Specification: Webhook Validation

## Context from Existing Patterns
### Related Domain Concepts
- Admission control (Kubernetes)
- API validation patterns
...

## Proposed Design
### API Changes
- Add ValidatingWebhookConfiguration
...

### Controller Implementation
- Implement validation.Handler interface
...

## Testing Strategy
- Unit: 60% (validation logic)
- Integration: 30% (webhook server)
- E2E: 10% (admission flow)

## Implementation Plan
- [ ] Phase 1: Define validation logic
- [ ] Phase 2: Create webhook server
...
```

**Key difference:** Answer vs Full Spec with implementation plan

---

### `--component <name>`

**What it does:** Narrows search to a specific OpenShift component repository

**Use when:** Your question/feature is component-specific (not platform-wide)

**Examples:**
```bash
# Platform-wide question (no --component)
/fetch "How do ClusterOperators work?"
→ Searches: Tier 1 only (openshift/enhancements/agentic)

# Component-specific question
/fetch "How does MCO handle node updates?" --component machine-config-operator
→ Searches: Tier 1 + machine-config-operator/agentic
```

**What happens:**
```
Without --component:
  📚 Tier 1: openshift/enhancements/agentic/
  
With --component machine-config-operator:
  📚 Tier 1: openshift/enhancements/agentic/
  📡 Tier 2: machine-config-operator/agentic/
    - AGENTS.md
    - architecture/components.md
    - patterns/node-updates.md
```

---

### `--tier2 <org/repo>`

**What it does:** Explicitly specifies a GitHub repository for Tier 2 docs (supports any GitHub org/repo)

**Use when:** 
- Component name doesn't match repo (e.g., "mco" → machine-config-operator)
- Non-OpenShift components (e.g., outrigger-project/multiarch-tuning-operator)
- Want explicit control over which repo to fetch from

**Examples:**
```bash
# OpenShift component (explicit org/repo)
/fetch "webhook validation" --tier2 openshift/machine-config-operator

# Non-OpenShift component
/fetch "multi-architecture scheduling" --tier2 outrigger-project/multiarch-tuning-operator

# Any GitHub repo with agentic/ docs
/fetch "controller patterns" --tier2 kubernetes-sigs/controller-runtime
```

**Difference from --component:**
- `--component mco` → Assumes openshift/machine-config-operator
- `--tier2 openshift/machine-config-operator` → Explicit GitHub path
- `--tier2 outrigger-project/multiarch-tuning-operator` → Works with ANY GitHub org

---

### `--tier1-only`

**What it does:** Only search Tier 1 ecosystem hub docs (skip component-specific docs)

**Use when:** 
- Platform-wide questions (not component-specific)
- Learning general patterns (not implementations)
- Want ecosystem-level guidance only

**Examples:**
```bash
# Only Tier 1 patterns
/fetch "operator design patterns" --tier1-only
→ Searches: openshift/enhancements/agentic/ ONLY

# Without --tier1-only (and with --component)
/fetch "operator design patterns" --component machine-config-operator
→ Searches: Tier 1 + machine-config-operator/agentic/
```

**Use case:**
```bash
# Learning phase - just want patterns, not component details
/fetch "status reporting patterns" --tier1-only

# Implementation phase - want patterns + component architecture
/fetch "status reporting" --component machine-config-operator
```

---

## Source Mode Flags

Controls WHERE fetch retrieves documentation from.

### Default (Auto Mode)

**No flag specified** → Try local first, fallback to remote

**Behavior:**
```bash
/fetch "How do webhooks work?"

# 1. Check local filesystem first
if [ -d "../enhancements/agentic" ]; then
    # Use local (fast)
else
    # Fetch from GitHub (convenient)
fi
```

**Best for:** General use - fast when local exists, works when it doesn't

---

### `--local`

**What it does:** Force local-only mode - fail if repos not found on filesystem

**Use when:**
- Working offline (no internet)
- Testing with specific local versions
- Want guaranteed fast access
- You know repos are cloned locally

**Examples:**
```bash
/fetch "webhooks" --local

# Success (repos exist locally):
📁 Local-only mode: searching filesystem only
  ✅ Tier 1 found: ../enhancements/agentic
  ✅ Reading local files...

# Failure (repos don't exist locally):
📁 Local-only mode: searching filesystem only
  ❌ Tier 1 not found locally
     Hint: Use --remote to fetch from GitHub, or clone repos locally
```

**Directory search order:**
1. `../enhancements/agentic` (sibling directory)
2. `~/workspace/enhancements/agentic` (home workspace)
3. `/home/user/openshift/enhancements/agentic` (explicit path)

---

### `--remote`

**What it does:** Force remote-only mode - skip local checks, always fetch from GitHub

**Use when:**
- Want latest docs (ignore stale local copies)
- Running in CI/CD (no local clones)
- Don't have local clones
- Explicitly want fresh data from GitHub

**Examples:**
```bash
/fetch "webhooks" --remote

# Always fetches from GitHub (even if local exists):
📡 Remote-only mode: fetching from GitHub only
  📡 Tier 1: https://github.com/openshift/enhancements
🔍 Fetching via gh CLI: openshift/enhancements/agentic/OPENSHIFT_AGENTS.md
🔍 Fetching via gh CLI: openshift/enhancements/agentic/platform/operator-patterns/webhooks.md
```

**Access methods:**
1. **gh CLI** (preferred) - Supports private repos, authentication
2. **raw.githubusercontent.com** (fallback) - Public repos only, no auth needed

---

## Source Mode Comparison

| Mode | Speed | Offline | Latest Docs | Use Case |
|------|-------|---------|-------------|----------|
| **Auto** (default) | Fast* | ✅ (if local) | ⚠️ (if local) | General use - smart fallback |
| **--local** | Fastest | ✅ | ❌ | Offline dev, testing, fast iteration |
| **--remote** | Fast | ❌ | ✅ | CI/CD, guarantee latest, no local repos |

\* Fast when local, slightly slower when remote

---

## Flag Combinations

### Common Combinations

```bash
# 1. Simple question (local first, remote fallback)
/fetch "How do operators report status?"
→ Auto mode, Tier 1 only, answer format

# 2. Feature spec (always latest from GitHub)
/fetch "webhook validation" --output-spec --remote
→ Remote mode, Tier 1 only, spec format

# 3. Component feature (local development)
/fetch "node drain timeout" --component machine-config-operator --output-spec --local
→ Local mode, Tier 1 + Tier 2, spec format

# 4. Non-OpenShift component (remote only)
/fetch "multi-arch scheduling" --tier2 outrigger-project/multiarch-tuning-operator --output-spec --remote
→ Remote mode, Tier 1 + specified Tier 2, spec format

# 5. Platform patterns only (offline)
/fetch "upgrade strategies" --tier1-only --local
→ Local mode, Tier 1 only, answer format
```

### Incompatible Combinations

```bash
# ❌ Can't specify both --local AND --remote
/fetch "webhooks" --local --remote
→ Error: Choose one source mode

# ❌ Can't use --component AND --tier2 (redundant)
/fetch "webhooks" --component mco --tier2 openshift/machine-config-operator
→ Warning: --tier2 takes precedence, --component ignored
```

---

## How Fetch Uses These Options

### Internal Flow

```bash
# User runs:
/fetch "Add webhook validation" --component machine-config-operator --output-spec --remote

# Fetch skill processes:
QUERY="Add webhook validation"
OUTPUT_FORMAT="spec"  # because --output-spec
SOURCE_MODE="remote"  # because --remote
TIER2_REPO="openshift/machine-config-operator"  # from --component

# Phase 0: Parse query
→ Detects: "webhook", "validation"
→ Query type: feature (because --output-spec)

# Phase 1: Locate docs (REMOTE mode)
→ Skip local filesystem checks
→ Fetch from GitHub:
  - https://github.com/openshift/enhancements (Tier 1)
  - https://github.com/openshift/machine-config-operator (Tier 2)

# Phase 2: Navigate (KNOWLEDGE_GRAPH)
→ Read OPENSHIFT_AGENTS.md
→ Use KNOWLEDGE_GRAPH.md to find:
  - platform/operator-patterns/webhooks.md
  - practices/development/api-evolution.md
  - machine-config-operator/agentic/AGENTS.md
  - machine-config-operator/agentic/architecture/

# Phase 3: Gather context
→ Extract patterns, practices, architecture

# Phase 4: Synthesize
→ Generate SPEC (not answer, because --output-spec)
→ Include: design, implementation plan, testing, security, etc.
```

---

## Quick Reference

| Flag | Purpose | Example |
|------|---------|---------|
| `<query>` | What to search for | `"How do webhooks work?"` |
| `--output-spec` | Generate spec (not answer) | `/fetch "feature" --output-spec` |
| `--component` | Search specific component | `--component machine-config-operator` |
| `--tier2` | Explicit GitHub repo | `--tier2 openshift/machine-config-operator` |
| `--tier1-only` | Platform patterns only | `--tier1-only` |
| `--local` | Local filesystem only | `--local` (offline mode) |
| `--remote` | GitHub only (latest) | `--remote` (CI/CD, fresh docs) |

---

## When to Use Each Flag

### Decision Tree

```
Is this a question or feature implementation?
├─ Question → No --output-spec
└─ Feature → Add --output-spec

Is this platform-wide or component-specific?
├─ Platform → No --component / --tier2
├─ OpenShift component → --component <name>
└─ Non-OpenShift → --tier2 <org/repo>

Do you need latest docs or working offline?
├─ Latest (online) → --remote
├─ Offline → --local
└─ Don't care → (auto mode, default)

Do you want ecosystem patterns only?
├─ Yes → --tier1-only
└─ No → (includes Tier 2 if --component specified)
```

---

**Pattern**: Flexible retrieval with explicit control  
**Version**: 2.5.0
