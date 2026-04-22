---
description: Create OpenShift feature specifications from enhancements - architecture and decisions without code examples
---

## Name
agentic-docs-maintainer:spec

## Synopsis
```
/agentic-docs-maintainer:spec [enhancement-file-or-description] [--component <name>[,<name>...]] [--auto-approve]
```

## Description
Creates a comprehensive feature specification following OpenShift enhancement template and agentic patterns. Automatically fetches relevant patterns from Tier 1 (ecosystem hub) and Tier 2 (component docs) to ensure specs follow current best practices.

**Key approach**:
- **Pattern-driven**: Fetches OpenShift patterns before creating specs
- **Architecture-focused**: Documents decisions and data flows, not implementation code
- **No duplication**: References enhancement file, doesn't repeat its content
- **Plan-ready**: Provides enough detail for `/plan` to generate actionable tasks

## Arguments

- `[enhancement-file-or-description]`: EITHER:
  - Path to enhancement: `/path/to/enhancement.md` or URL
    - Can be in `openshift/enhancements/enhancements/{category}/{file}.md`
    - Or in component repo: `{component}/enhancements/{file}.md`
    - Or in optional operator repo: `{operator}/docs/{file}.md`
  - Feature description: `"Add webhook validation for MachineConfigPool"`
    - Required if no enhancement file exists
- `--component <name>[,<name>...]`: Component repository name(s)
  - Single: `machine-config-operator`
  - Multiple (comma-separated): `machine-config-operator,cluster-network-operator`
  - Auto-detected from enhancement if file path provided
  - Required if using feature description (no enhancement file)
- `--auto-approve`: Skip approval gate (optional, default: pause for review)

## When to Use

✅ **Use for:**
- Implementing an approved enhancement
- New operator features or CRD additions
- Multi-component architectural changes
- Features needing detailed architecture documentation

❌ **Don't use for:**
- Single-line fixes or typos
- Features fully specified in enhancement
- Non-OpenShift projects

## How It Works

### Phase 0: Read Enhancement (if provided)
```
📖 Reading enhancement file...
✅ Read: Feature name, Components, APIs, Workflows
```

### Phase 1: Fetch Patterns

**ALWAYS fetches Tier 1** (OpenShift guidelines from `openshift/enhancements/agentic/`):
```
📚 Fetching Tier 1 (OpenShift guidelines)...
Source: openshift/enhancements/agentic/
  ✅ DESIGN_PHILOSOPHY.md
  ✅ operator-patterns (controller-runtime, status-conditions, webhooks)
  ✅ practices (testing, security, reliability)
  ✅ ADRs (architectural constraints)
```

**Then fetches Tier 2** (component-specific, if --component specified):
```
📡 Fetching Tier 2 (component-specific)...
Source: {component}/agentic/
  ✅ Component architecture
  ✅ Component patterns
  ✅ Similar implementations
```

**This applies even if enhancement is in a component repo** - we always follow OpenShift platform guidelines.

### Phase 2: Write Specification
Creates 12-section spec:
1. **Objective** - What, why, success criteria
2. **Technical Design** - Architecture, API surface, data flows
3. **Testing Strategy** - 60/30/10 pyramid, critical scenarios
4. **Security** - STRIDE analysis, RBAC design
5. **Reliability & Observability** - Metrics, SLOs, must-gather
6. **Upgrade Strategy** - Version compat, migration
7. **Dependencies** - Tier 1/Tier 2, ADRs
8. **Implementation Plan** - Phases, timeline, risks
9. **Compliance Checklist** - Operator patterns + practices
10. **Open Questions** - Needs human input
11. **References** - Enhancement + fetched patterns
12. **Validation Gates** - Approval checklist

### Phase 3: Approval Gate (unless --auto-approve)
```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Generated
════════════════════════════════════════════════════════════════

📄 SPEC-{name}.md created

Please review and respond:
  • "approve" → I'll proceed
  • "revise: <feedback>" → I'll regenerate
  • "abort" → I'll stop
```

### Phase 4: Report
```
✅ Specification Complete

📄 SPEC-{name}.md
Components: [list]

🎯 Next: /plan SPEC-{name}.md
```

## Output Format

**Spec includes** (for good `/plan` task generation):
- Architecture diagrams (ASCII) showing component interactions
- API field definitions (YAML) with field descriptions
- Data flow sequences (numbered steps)
- Component responsibilities (what each component does)
- Test categories and coverage targets
- STRIDE threat analysis (table)
- Metrics to implement (names and purposes)
- Implementation phases (what to build in each phase)

**Spec excludes** (avoids duplication and verbosity):
- Go code examples (controllers, webhooks, tests)
- User stories already in enhancement
- Full motivation (links to enhancement instead)
- Implementation details (saved for actual code)

**Typical length**: Under 400 lines

## Examples

### Example 1: From Enhancement File
```bash
/agentic-docs-maintainer:spec enhancements/category/feature-name.md
```

**What happens:**
```
📖 Reading enhancement...
  ✅ Feature: [extracted name]
  ✅ Components: [auto-detected]

📚 Fetching patterns...
  ✅ DESIGN_PHILOSOPHY.md
  ✅ operator-patterns
  ✅ practices

📝 Creating spec...
  ✅ SPEC-[name].md

🎯 Ready for review!
```

### Example 2: From Description with Component
```bash
/agentic-docs-maintainer:spec "Feature description" --component component-name
```

**What happens:**
```
📚 Fetching patterns...
  ✅ Tier 1 (OpenShift guidelines)
  ✅ Tier 2 (component-specific)

📝 Creating spec...
  ✅ SPEC-[name].md

🎯 Ready for review!
```

### Example 3: Multi-Component Feature
```bash
/agentic-docs-maintainer:spec "Feature description" \
  --component component-a,component-b
```

**What happens:**
```
🌐 Multi-component feature detected

📚 Fetching Tier 1 patterns...
📡 Fetching from component-a...
📡 Fetching from component-b...

📝 Creating spec...
  ✅ SPEC-[name].md

🎯 Ready for review!
```

## Integration with Other Skills

**Full workflow:**
```bash
# 1. SPEC (this command) - Architecture & decisions
/agentic-docs-maintainer:spec enhancement.md

# 2. PLAN - Break into ordered tasks
/agentic-docs-maintainer:plan

# 3. BUILD - Implement tasks
/agentic-docs-maintainer:build

# 4. TEST - Verify compliance
/agentic-docs-maintainer:test

# 5. REVIEW - Check patterns
/agentic-docs-maintainer:review

# 6. SHIP - Deploy safely
/agentic-docs-maintainer:ship
```

## What Makes a Good Spec

**Architecture clarity** (enables good planning):
- ASCII diagrams show component interactions
- Data flows are numbered sequences
- Component responsibilities are 1-2 sentences each
- API fields have clear descriptions

**Decision documentation** (not implementation):
- Which components are involved and why
- How components coordinate (watch patterns, status propagation)
- What gets validated and where (webhook vs controller)
- Which metrics to track and why

**Enough detail for `/plan`**:
- Implementation phases with clear deliverables
- Test categories and what each tests
- API changes needed (which repos)
- Dependencies between components

## See Also

- `/agentic-docs-maintainer:fetch` - Pattern retrieval (used internally)
- `/agentic-docs-maintainer:plan` - Task breakdown (next step)
- `/agentic-docs-maintainer:build` - Implementation (after plan)

---

**Pattern**: OpenShift feature specification with pattern integration  
**Version**: 1.0
