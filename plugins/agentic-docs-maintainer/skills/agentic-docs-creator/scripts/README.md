# Tier 1 (agentic-docs-creator) Scripts

Deterministic scripts for creating and validating Tier 1 documentation in `openshift/enhancements/agentic/`.

## Scripts

### create-structure.sh

Creates Tier 1 directory structure in openshift/enhancements repository.

**Usage:**
```bash
./create-structure.sh [path-to-enhancements-repo]
```

**What it does:**
- Verifies this is openshift/enhancements (checks for enhancements/ and dev-guide/)
- Creates all required directories:
  - platform/{operator-patterns,openshift-specifics}
  - practices/{testing,security,reliability,development}
  - domain/{kubernetes,openshift}
  - decisions/, workflows/, references/
- Warns if agentic/ already exists

**Exit codes:**
- 0: Success
- 1: Error (wrong repo or user cancelled)

**Example:**
```bash
cd /path/to/openshift/enhancements
../../ai-helpers/plugins/agentic-docs-maintainer/skills/agentic-docs-creator/scripts/create-structure.sh .
```

---

### validate.sh

Validates Tier 1 documentation compliance.

**Usage:**
```bash
./validate.sh [path-to-enhancements-repo]
```

**Checks performed:**
1. OPENSHIFT_AGENTS.md exists and ≤150 lines
2. All required directories present
3. No component-specific content (e.g., "MCO-specific", "installer-only")
4. All internal links valid
5. All dev-guide references exist
6. Index files complete (decisions/index.md lists all ADRs)
7. Required pattern files exist (status-conditions.md, controller-runtime.md, etc.)
8. Required practice files exist (pyramid.md, e2e-framework.md, etc.)
9. Required domain files exist (pods.md, clusteroperator.md, etc.)

**Exit codes:**
- 0: All checks passed (compliant)
- 1: Issues found (list printed to stdout)

**Example:**
```bash
cd /path/to/openshift/enhancements
./agentic/scripts/validate.sh .
```

**Output:**
```
✅ Tier 1 validation PASSED!
```
or
```
❌ Tier 1 validation FAILED with 3 issue(s):
  - OPENSHIFT_AGENTS.md is 165 lines (must be ≤150)
  - Broken link in platform/index.md: ./missing.md
  - Missing required pattern: platform/operator-patterns/finalizers.md
```

---

## Workflow

### Creating New Tier 1 Documentation

```bash
# 1. Create structure
./create-structure.sh /path/to/enhancements

# 2. Populate with content (AI agent or manual)
# - Create OPENSHIFT_AGENTS.md (≤150 lines)
# - Create platform patterns
# - Create practices docs
# - Create domain docs
# - Create decisions/ADRs

# 3. Validate
./validate.sh /path/to/enhancements
```

### Validating Existing Tier 1

```bash
# Run validation anytime
./validate.sh /path/to/enhancements

# Use in CI
if ./validate.sh /path/to/enhancements; then
    echo "Tier 1 docs are compliant"
else
    echo "Fix issues before merging"
    exit 1
fi
```

## Integration with Skills

The `agentic-docs-creator` skill uses these scripts:

1. **Phase 2 (Structure Creation)**: Calls `create-structure.sh`
2. **Phase 3-8 (Content Population)**: AI agent creates content
3. **Phase 9 (Validation)**: Calls `validate.sh`

## CI Integration

Add to `.github/workflows/validate-tier1.yml`:

```yaml
name: Validate Tier 1 Docs
on: [pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Validate Tier 1
        run: |
          cd plugins/agentic-docs-maintainer/skills/agentic-docs-creator/scripts
          ./validate.sh ../../../../
```

## Requirements

- bash 4.0+
- Standard Unix tools: grep, find, wc, sed
- Git repository

## Troubleshooting

**"This doesn't appear to be openshift/enhancements repository"**
- Ensure you're running in the enhancements repo root
- Directory must contain `enhancements/` and `dev-guide/`

**"OPENSHIFT_AGENTS.md is 165 lines (must be ≤150)"**
- Entry point is too long
- Move details to subdirectory docs
- Link to details instead of including inline

**"Found component-specific content"**
- Tier 1 should only contain cross-repo knowledge
- Component-specific content belongs in Tier 2 (component repos)
- Example: MachineConfig docs belong in machine-config-operator/agentic/, not enhancements/agentic/
