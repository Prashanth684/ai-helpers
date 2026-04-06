# Agentic Docs Tier 2 (agentic-docs-tier2) Scripts

Deterministic scripts for creating, validating, and maintaining lean Tier 2 documentation in component repositories.

## Scripts

### create-structure.sh

Creates lean Tier 2 directory structure in component repository.

**Usage:**
```bash
./create-structure.sh [path-to-component-repo]
```

**What it does:**
- Detects component name from repository path
- Verifies this is an OpenShift component (checks go.mod)
- Creates lean Tier 2 directories (NOT full single-tier):
  - domain/, architecture/, decisions/
  - exec-plans/{active,completed}
  - references/, scripts/
- Warns if agentic/ already exists

**Exit codes:**
- 0: Success
- 1: Error or user cancelled

**Example:**
```bash
cd /path/to/machine-config-operator
../../../../ai-helpers/plugins/agentic-docs-maintainer/skills/agentic-docs-tier2/scripts/create-structure.sh .
```

---

### validate.sh

Validates Tier 2 lean documentation compliance.

**Usage:**
```bash
./validate.sh [path-to-component-repo]
```

**Checks performed:**
1. AGENTS.md exists and ≤100 lines (NOT 150 like Tier 1)
2. ecosystem.md exists with Tier 1 links (≥5 recommended)
3. No generic content duplication (testing pyramid, controller-runtime philosophy, etc.)
4. Domain concepts are component-specific (not Pod, Node, Service)
5. ADRs are component-specific (not cross-repo decisions)
6. AGENTS.md links to Tier 1
7. All internal links valid
8. Required Tier 2 directories present
9. Component-specific guide files exist
10. Documentation size reasonable (~2,500 lines, not 6,000 like single-tier)

**Exit codes:**
- 0: All checks passed (compliant)
- 1: Issues found
- 2: **CRITICAL** - Contains Tier 1 content (serious violation)

**Example:**
```bash
cd /path/to/machine-config-operator
./agentic/scripts/validate.sh .
```

**Output:**
```
✅ Tier 2 lean validation PASSED!
```
or
```
❌ CRITICAL: Tier 1 content detected in Tier 2!

Issues:
  - Found generic content that belongs in Tier 1: 'testing pyramid'
  - Found generic content that belongs in Tier 1: 'controller-runtime reconciliation loop'
```

---

### detect-changes.sh

Detects changes in component repository requiring documentation updates.

**Usage:**
```bash
./detect-changes.sh [path-to-component-repo]
```

**Detections:**
1. New CRDs/API types (vendor/github.com/openshift/api)
2. Code structure changes (git diff pkg/ cmd/)
3. New controllers/packages (pkg/controller)
4. New enhancements (../enhancements/enhancements)
5. Architectural decisions (git log --grep)
6. Tier 1 updates (GitHub API)

**Exit codes:**
- 0: No changes detected
- 1: Changes detected (with recommendations)

**Example:**
```bash
cd /path/to/machine-config-operator
./agentic/scripts/detect-changes.sh .
```

**Output:**
```
📝 Changes detected requiring documentation updates

Recommended actions:
  1. Review detected changes above
  2. Update relevant documentation:
     - New CRDs → agentic/domain/
     - Code changes → agentic/architecture/
     - New controllers → agentic/architecture/components.md
     - Enhancements → agentic/exec-plans/active/
     - Decisions → agentic/decisions/
```

---

### maintenance-loop.sh

Autonomous maintenance loop for Tier 2 documentation.

**Usage:**
```bash
./maintenance-loop.sh [path-to-component-repo] [--max-iterations N]
```

**What it does:**
1. Runs `detect-changes.sh` to find what changed
2. Runs `validate.sh` to check compliance
3. If changes or issues found:
   - Creates task file for AI agent
   - Waits for AI/human to apply updates
   - Re-validates
4. Repeats until compliant and current (max 10 iterations)

**Stopping conditions:**
- ✅ No changes + all checks pass
- ❌ Max iterations reached (default 10)
- ❌ Stuck (same issues 3 times)

**Example:**
```bash
cd /path/to/machine-config-operator
./agentic/scripts/maintenance-loop.sh . --max-iterations 5
```

**Output:**
```
🔄 Iteration 1/10
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🔍 Detecting changes...
  📝 New CRDs detected:
    - machineconfiguration.openshift.io/v1/MachineConfigNode

🔍 Validating compliance...
  ❌ AGENTS.md is 110 lines (must be ≤100 for Tier 2 lean)

📝 Task created: .tier2-maintenance-iteration-1.md

⏸️  AI agent intervention needed
Press Enter when iteration 1 complete...
```

---

## Workflows

### Creating New Tier 2 Lean Documentation

```bash
# 1. Create structure
./create-structure.sh /path/to/component

# 2. Populate with component-specific content (AI or manual)
# - Create AGENTS.md (≤100 lines, link to Tier 1, show exec-plans/)
# - Create ecosystem.md (link to Tier 1 patterns)
# - Document component domain concepts
# - Document component architecture
# - Create component-specific ADRs
# - Use exec-plans/active/ for feature planning
# - Create exec-plans for active work

# 3. Validate
./validate.sh /path/to/component
```

### Maintaining Existing Tier 2

```bash
# Option 1: Manual check
./detect-changes.sh /path/to/component
# Review output, update docs manually
./validate.sh /path/to/component

# Option 2: Autonomous loop
./maintenance-loop.sh /path/to/component
# Loop detects changes, creates tasks, validates
```

### Migrating from Single-Tier to Tier 2 Lean

```bash
# 1. Detect what to keep vs remove
./detect-changes.sh /path/to/component

# 2. Create lean structure alongside existing
./create-structure.sh /path/to/component

# 3. Extract component-specific content
# (Use AI agent to identify generic vs component-specific)

# 4. Validate lean compliance
./validate.sh /path/to/component

# 5. Remove old single-tier docs once validated
```

## Integration with Skills

The `agentic-docs-tier2` skill uses these scripts:

1. **Phase 2 (Structure Creation)**: Calls `create-structure.sh`
2. **Phase 3-7 (Content Population)**: AI agent creates component-specific content
3. **Phase 8.1 (Change Detection)**: Calls `detect-changes.sh`
4. **Phase 8.2-8.5 (Autonomous Updates)**: Calls `maintenance-loop.sh`
5. **Phase 9 (Validation)**: Calls `validate.sh`

## CI Integration

Add to `.github/workflows/validate-tier2.yml`:

```yaml
name: Validate Tier 2 Docs
on: [pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate Tier 2 Lean
        run: |
          if [ -d agentic ]; then
            ./agentic/scripts/validate.sh .
          else
            echo "No Tier 2 docs yet"
          fi
```

## Requirements

- bash 4.0+
- Standard Unix tools: grep, find, wc, sed, git
- Git repository
- curl (optional, for Tier 1 update checks)

## Tier 2 Lean Rules

**CRITICAL - These are enforced by validate.sh:**

1. ✅ **AGENTS.md ≤100 lines** (NOT 150 like Tier 1)
2. ✅ **AGENTS.md must show exec-plans/ directory structure**
3. ❌ **NO generic content duplication**
   - Link to Tier 1 instead of duplicating
   - Examples of forbidden: testing pyramid, controller-runtime philosophy, STRIDE threat model
4. ✅ **ecosystem.md must exist** with Tier 1 links
5. ✅ **Component-specific only**
   - Domain: Component CRDs/APIs only (not Pod, Node, Service)
   - ADRs: Component decisions only (not cross-repo like "use etcd")
5. ✅ **Lean structure** (no practices/, workflows/ like single-tier)

## Troubleshooting

**"AGENTS.md is 110 lines (must be ≤100)"**
- Entry point too long for Tier 2 lean
- Move details to agentic/ subdirectories
- Link to details instead of inline

**"Found generic content: 'testing pyramid'"**
- Remove generic explanation
- Replace with: `See [Testing Pyramid](https://github.com/openshift/enhancements/.../pyramid.md)`

**"Missing ecosystem.md"**
- Create `agentic/references/ecosystem.md`
- List all Tier 1 patterns this component uses
- This is the bridge between Tier 2 and Tier 1

**"Domain has generic K8s/OpenShift concept: Pod"**
- Don't create `agentic/domain/pod.md` (that's in Tier 1)
- Create component-specific concepts only (e.g., MachineConfig for MCO)

**Exit code 2: CRITICAL violation**
- Contains Tier 1 content in Tier 2 (serious)
- Must remove generic content and link to Tier 1 instead
- Common culprits: operator patterns, testing practices, K8s fundamentals
