# Agentic Docs Maintainer Plugin

**Autonomous maintenance and knowledge extraction for AI-friendly documentation**

---

## Quick Start

### Via Claude Code Skills

```bash
# Use current directory
/agentic-docs-maintainer                # Fix compliance issues
/agentic-docs-maintainer:extract        # Extract knowledge from enhancements
/agentic-docs-maintainer:verify         # Check only (no changes)

# Or specify repository path
/agentic-docs-maintainer --path /path/to/enhancements
/agentic-docs-maintainer:extract --path /path/to/enhancements
```

### Or Run Scripts Directly

```bash
cd plugins/agentic-docs-maintainer

./scripts/verify.sh                     # Check compliance
./scripts/loop.sh                       # Fix issues
./scripts/loop.sh --extract             # Extract + fix
```

---

## What It Does

An autonomous system that:

**1. FIXES** broken things (Compliance Mode)
- Broken links, incomplete indexes, missing references

**2. UPDATES** existing docs when enhancements change (Extraction Mode)
- Enriches docs with new examples
- Updates glossary with new terminology

**3. CREATES** new documentation from scratch (Extraction Mode)
- Domain docs for new API types
- Pattern docs for reusable patterns
- ADR proposals for decisions (human review)

## Two-Tier Architecture Support

For **OpenShift component repositories**, this plugin supports creating **lean Tier 2 documentation** that references a central **Tier 1 ecosystem hub**.

### Tier 1: Ecosystem Hub (openshift/enhancements/agentic/)
- Platform patterns (operator patterns, controller-runtime, status conditions)
- Engineering practices (testing pyramid, E2E framework, CI integration)
- Cross-repo ADRs (etcd backend, CVO ordering, operator SDK)
- Kubernetes/OpenShift fundamentals
- **Owned by:** Enhancement reviewers, platform architecture team

### Tier 2: Component Repos (lean)
- Component-specific domain concepts (e.g., MachineConfig for MCO)
- Component architecture (internal structure)
- Component-specific ADRs (e.g., why MCO uses rpm-ostree)
- Component work tracking (exec-plans)
- **Owned by:** Component maintainers
- **Links to:** Tier 1 for generic patterns

**Benefits:**
- 58% smaller docs (6,000 → 2,500 lines typical)
- 97% less duplication across ecosystem (144,000 → 4,000 lines)
- 1 Tier 1 PR updates all repos (vs 60+ component PRs)
- Clear separation: generic (Tier 1) vs component-specific (Tier 2)

---

## Plugin Structure

```
agentic-docs-maintainer/
├── .claude-plugin/
│   └── plugin.json              Plugin metadata
├── commands/
│   ├── fix.md                   /agentic-docs-maintainer (default)
│   ├── extract.md               /agentic-docs-maintainer:extract
│   └── verify.md                /agentic-docs-maintainer:verify
├── skills/
│   └── agentic-docs-maintainer.md   Main skill implementation
├── scripts/
│   ├── verify.sh                Verification script
│   ├── loop.sh                  Main autonomous loop
│   ├── extract.sh               Extraction only
│   └── autonomous.sh            Fully autonomous variant
├── README.md                    This file
├── GUIDE.md                     Complete reference
├── PLUGIN.md                    Plugin documentation
├── INSTALL.md                   Installation guide
└── SPECIFICATION.md             Customizable requirements
```

---

## Installation

### Install in Your Repo

```bash
# Copy entire plugin
cp -r plugins/agentic-docs-maintainer /path/to/your/repo/agentic/

# Copy skill to .claude/skills/
cp plugins/agentic-docs-maintainer/skills/agentic-docs-maintainer.md \
   /path/to/your/repo/.claude/skills/
```

See [INSTALL.md](INSTALL.md) for detailed instructions.

---

## Commands

### Documentation Maintenance

| Command | Description |
|---------|-------------|
| `/agentic-docs-maintainer [--path <repo>]` | Fix compliance issues automatically (single-tier) |
| `/agentic-docs-maintainer:extract [--path <repo>]` | Extract knowledge + fix issues (single-tier) |
| `/agentic-docs-maintainer:verify [--path <repo>]` | Check compliance (read-only) |
| `/agentic-docs-maintainer:tier1-ecosystem [--path <repo>]` | Create Tier 1 ecosystem hub in openshift/enhancements |
| `/agentic-docs-maintainer:tier2-component [--path <repo>]` | Create lean Tier 2 docs for OpenShift components |

### OpenShift Lifecycle Skills ✨ NEW

Full-cycle feature development from specification through deployment with human-in-the-loop approval gates.

| Command | Description | Approval Gate |
|---------|-------------|---------------|
| `/agentic-docs-maintainer:fetch [query]` | Retrieve OpenShift patterns from Tier 1/2 docs | No |
| `/agentic-docs-maintainer:spec [feature] --component <name>` | Generate feature specification (12 sections) | Yes |
| `/agentic-docs-maintainer:plan [spec-file]` | Create implementation plan (9 tasks, 4 checkpoints) | Yes |
| `/agentic-docs-maintainer:build <task-number>` | Implement tasks incrementally with tests | Yes (per task) |
| `/agentic-docs-maintainer:test` | Verify testing pyramid (60/30/10) | Yes |
| `/agentic-docs-maintainer:review` | Five-axis code review (score /100) | Yes |
| `/agentic-docs-maintainer:ship` | Safe deployment with upgrade validation | Yes (2 gates) |

**See**: [OPENSHIFT_LIFECYCLE_SKILLS.md](OPENSHIFT_LIFECYCLE_SKILLS.md) for complete guide with examples.

**Note:** `--path` defaults to current working directory if not specified.

### Which Command to Use?

**Use tier1-ecosystem for:**
- Creating Tier 1 agentic docs in openshift/enhancements
- Establishing ecosystem hub for all OpenShift components
- First-time setup of two-tier architecture

**Use tier2-component for:**
- OpenShift component repositories (part of multi-repo ecosystem)
- When Tier 1 exists in openshift/enhancements/agentic/
- Want to avoid duplicating platform-wide knowledge
- Need lean docs that reference ecosystem hub

**Use default commands for:**
- Standalone repositories (not part of OpenShift)
- Self-contained documentation needed
- No Tier 1 hub exists

**Use lifecycle skills for:**
- Full feature development (spec → plan → build → test → review → ship)
- Pattern-driven implementation with OpenShift best practices
- Human-in-the-loop approval gates at every critical phase
- Iterative refinement with feedback loops

---

## OpenShift Lifecycle Skills

A complete workflow for developing OpenShift features with approval gates:

```
┌──────┐   ┌──────┐   ┌──────┐   ┌───────┐   ┌──────┐   ┌────────┐   ┌──────┐
│fetch │ → │ spec │ → │ plan │ → │ build │ → │ test │ → │ review │ → │ ship │
└──────┘   └──────┘   └──────┘   └───────┘   └──────┘   └────────┘   └──────┘
           ↓ GATE     ↓ GATE     ↓ GATE       ↓ GATE     ↓ GATE       ↓ GATE
         Approve    Approve    Per Task     Approve    Approve     2 Gates
```

### Quick Start

```bash
# 1. Create specification with approval gate
/agentic-docs-maintainer:spec "multi-arch support" --component cluster-version-operator
→ GATE: Review spec
User: approve

# 2. Create implementation plan
/agentic-docs-maintainer:plan
→ GATE: Review plan
User: approve

# 3. Implement incrementally
/agentic-docs-maintainer:build task-1
→ GATE: Review task 1
User: approve

# 4-6. Test, review, ship
/agentic-docs-maintainer:test → GATE → approve
/agentic-docs-maintainer:review → GATE → approve
/agentic-docs-maintainer:ship → GATE 1 → approve → GATE 2 → merge

✅ Feature deployed!
```

### Key Features

**✅ Approval Gates**: Human review at every critical phase (approve/revise/abort)  
**✅ Iterative Refinement**: Provide feedback and regenerate until satisfied  
**✅ Pattern-Driven**: Fetches OpenShift patterns before each operation  
**✅ Natural Language**: "looks good" to approve, "revise: fix X" to iterate  
**✅ State Tracking**: Resume across invocations with attempt limits  

### Approval Gate Example

```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Generated (Attempt 1/3)
════════════════════════════════════════════════════════════════

📄 SPEC-multi-arch-support.md created

Please review and respond:
  • "approve" → I'll create exec-plan
  • "revise: add version skew handling" → I'll regenerate
  • "abort" → I'll stop
════════════════════════════════════════════════════════════════
```

**See**: [OPENSHIFT_LIFECYCLE_SKILLS.md](OPENSHIFT_LIFECYCLE_SKILLS.md) for:
- Complete workflow examples
- All 7 skills detailed documentation
- Approval gates guide
- Comparison to GitHub spec-kit

---

## Example: Knowledge Extraction

**Enhancement merged:**
```
enhancements/workload/kueue-integration.md
```

**Run extraction:**
```bash
/agentic-docs-maintainer:extract
```

**What happens:**
- ✅ Detects new API type: ClusterQueue
- ✅ Creates `domain/openshift/clusterqueue.md`
- ✅ Proposes `decisions/adr-0004-kueue.md` (DRAFT)
- ✅ Updates glossary (+3 terms)
- ✅ Creates git commits
- ⚠️  Flags ADR for human review

---

## Safety Features

✅ Max 10 iterations - prevents infinite loops  
✅ Stuck detection - stops if same error 3x  
✅ Git commits - every change traceable  
✅ Human review for ADRs - no autonomous decisions  
✅ Source-based only - extracts from enhancements  
✅ Read-only outside target directory

---

## Use Cases

### OpenShift Enhancements Repo
Keep agentic/ docs in sync with enhancements/

### Any Documentation Project
Extract knowledge from specifications into structured docs

### API Documentation
Auto-generate docs from API definitions

---

## Further Reading

### Documentation Maintenance
- **[GUIDE.md](GUIDE.md)** - Complete reference with examples
- **[PLUGIN.md](PLUGIN.md)** - Plugin documentation
- **[SPECIFICATION.md](SPECIFICATION.md)** - Customizable requirements

### OpenShift Lifecycle Skills
- **[OPENSHIFT_LIFECYCLE_SKILLS.md](OPENSHIFT_LIFECYCLE_SKILLS.md)** - Complete guide (all 7 skills + approval gates + examples)

---

**Pattern:** Ralph loop (autonomous AI iteration) + Human-in-the-loop approval gates  
**Version:** 3.0.0  
**License:** Apache 2.0
