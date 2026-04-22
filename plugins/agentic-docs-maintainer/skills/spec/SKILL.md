---
name: spec
description: OpenShift feature specification - creates specs following enhancement template and agentic patterns with fetched OpenShift patterns
trigger: explicit
model: sonnet
---

# Spec - OpenShift Feature Specification

Write an OpenShift feature specification BEFORE implementing code. The spec defines what we're building and how it follows OpenShift patterns.

---

## 🚨 EXECUTE THESE PHASES IN ORDER 🚨

```
READ ──→ FETCH ──→ WRITE ──→ APPROVE
  │        │         │          │
  ▼        ▼         ▼          ▼
Show     Show     Create     STOP
Summary  Patterns  File     & WAIT
```

**DO NOT skip phases. DO NOT proceed without completing current phase.**

---

## PHASE 0: Read & Surface Assumptions

### Read Enhancement (if file path provided)

```
📖 Phase 0: Reading Enhancement
File: [path]
```

Extract: feature name, components, APIs, workflows.

```
✅ Read: [filename]
  Feature: [name]
  Components: [list]
```

### SURFACE ASSUMPTIONS IMMEDIATELY

**Before writing ANYTHING, list your assumptions:**

```
🔍 ASSUMPTIONS I'M MAKING:

1. [Architecture assumption]
2. [Component assumption]
3. [API assumption]
4. [Deployment assumption]

→ Correct me now or I'll proceed with these.
```

**STOP. Wait for user to confirm or correct.**

---

## PHASE 1: Read OpenShift Patterns (Inline)

**DO NOT use Skill("fetch"). Read files directly.**

### Step 1.1: Check Tier 1 Location

```
📚 Phase 1: Reading OpenShift Patterns

Tier 1: ../enhancements/agentic/ (ALWAYS)
Tier 2: ../{component}/agentic/ (if components specified)
```

Check local:
```bash
ls ../enhancements/agentic/
```

### Step 1.2: Read Tier 1 Files Directly

**If found locally**, use Read tool on:
- `../enhancements/agentic/OPENSHIFT_AGENTS.md`
- `../enhancements/agentic/DESIGN_PHILOSOPHY.md`
- `../enhancements/agentic/platform/operator-patterns/controller-runtime.md`
- `../enhancements/agentic/platform/operator-patterns/status-conditions.md`
- `../enhancements/agentic/platform/operator-patterns/upgrade-strategies.md`
- `../enhancements/agentic/practices/testing/pyramid.md`
- `../enhancements/agentic/practices/security/threat-modeling.md`
- `../enhancements/agentic/decisions/adr-0003-cvo-coordination.md`

**If NOT found locally**, fetch from GitHub:
```bash
gh api repos/openshift/enhancements/contents/agentic/OPENSHIFT_AGENTS.md --jq .content | base64 -d
# Repeat for each file
```

### Step 1.3: Read Tier 2 (if components specified)

**For each component**, check:
```bash
ls ../{component}/agentic/
```

**If found**, read:
- `../{component}/agentic/AGENTS.md`
- `../{component}/agentic/architecture/` (relevant files)

**If NOT found locally**, fetch:
```bash
gh api repos/openshift/{component}/contents/agentic/AGENTS.md --jq .content | base64 -d
```

### Step 1.4: Report

```
✅ Patterns Retrieved:

Tier 1 (OpenShift Guidelines):
  ✅ DESIGN_PHILOSOPHY.md
  ✅ operator-patterns/[list]
  ✅ practices/[list]
  ✅ decisions/[ADRs]

[Tier 2: - if applicable
  ✅ {component}/agentic/AGENTS.md]

🎯 Ready to write spec
```

---

## PHASE 2: Write Specification

```
📝 Phase 2: Creating Specification

File: SPEC-[name].md
Target: <400 lines
Sections: 12
```

### WHAT TO INCLUDE

✅ **Include** (architecture & decisions):
- ASCII diagrams
- API fields (YAML with descriptions)
- Data flows (numbered steps)
- Component responsibilities (tables)
- Test categories & coverage targets
- STRIDE threat table
- Metrics names & purposes
- Implementation phases

❌ **NEVER include** (implementation):
- Go code (controllers, webhooks, tests)
- User stories from enhancement (link instead)
- Detailed procedures (those → /plan)
- Test code examples

**Target: Under 400 lines. If >400 lines, CUT CONTENT.**

### 12 Sections (concise)

1. **Objective** (~30 lines) - What, why, success criteria
2. **Technical Design** (~50 lines) - ASCII diagram, component table, data flows, API fields (YAML only)
3. **Testing Strategy** (~35 lines) - 60/30/10 pyramid, critical scenarios
4. **Security** (~30 lines) - STRIDE table, RBAC table
5. **Reliability** (~30 lines) - Metrics table, SLO
6. **Upgrade Strategy** (~40 lines) - N→N+1 flow, migration
7. **Dependencies** (~25 lines) - Tier 1/2 deps, ADRs
8. **Implementation Plan** (~40 lines) - Phases, risks
9. **Compliance** (~30 lines) - Pattern checklists
10. **Open Questions** (~20 lines) - Questions + assumptions
11. **References** (~25 lines) - Enhancement, patterns
12. **Validation Gates** (~20 lines) - Checklist, next step

**Total: ~375 lines**

### Create File

Use Write tool: `SPEC-[name].md`

```
✅ Created: SPEC-[name].md
Lines: [X]
Sections: 12/12
```

---

## PHASE 3: APPROVAL GATE

**🛑 STOP HERE. WAIT FOR USER APPROVAL. 🛑**

### Check Auto-Approve

```
if --auto-approve:
    → Skip to Phase 4
else:
    → Show gate, EXIT skill
```

### Display Gate and EXIT

```
════════════════════════════════════════════════════════════════
  REVIEW GATE: Specification Ready
════════════════════════════════════════════════════════════════

📄 SPEC-[name].md ([X] lines)

Review sections:
  1. Objective - Clear goal?
  2. Architecture - Sound design?
  3. Testing - Adequate coverage?
  4. Security - Threats addressed?
  5. Upgrade - Safe migration?

────────────────────────────────────────────────────────────────

Respond:
  ✅ "approve" / "looks good" / "LGTM" → I'll complete
  ✏️  "revise: <feedback>" → I'll update
  ❌ "abort" / "cancel" → I'll stop

════════════════════════════════════════════════════════════════

⏸️  Waiting for your decision...
```

**EXIT SKILL. Return control to user.**

---

## PHASE 4: Report (if approved)

```
✅ Specification Complete

📄 SPEC-[name].md ([X] lines)
Components: [list]

📚 Patterns Applied:
  ✅ [list key patterns]

🎯 Next: /plan SPEC-[name].md
```

**DONE.**

---

## Red Flags - You're Doing It Wrong

| Red Flag | Fix |
|----------|-----|
| Writing Go code | Remove it. Describe decision instead. |
| Spec >400 lines | Cut content. Too verbose. |
| Using Skill("fetch") | Read patterns inline instead. |
| Skipping approval gate | STOP. Show gate. Wait. |
| Copying enhancement verbatim | Link instead. Summarize. |
| Writing test code | Describe test categories only. |

---

## Common Rationalizations - Don't Make These

| Excuse | Reality |
|--------|---------|
| "Patterns don't apply here" | ALL features follow patterns. Simple = shorter spec. |
| "I'll fetch after writing" | Read patterns FIRST or rewrite later. |
| "Approval slows us down" | 5-min review prevents hours of rework. |
| "I know OpenShift patterns" | Your training is stale. Read current patterns. |

---

## Pre-Writing Checklist

- [ ] Enhancement read OR feature description captured
- [ ] Assumptions surfaced & user confirmed
- [ ] Tier 1 patterns read (DESIGN_PHILOSOPHY, operator-patterns, practices, ADRs)
- [ ] Tier 2 patterns read (if applicable)
- [ ] Target: <400 lines
- [ ] Approach: Architecture, NO code

**If unchecked, DO NOT write.**

---

## Pre-Approval Checklist

- [ ] 12 sections complete
- [ ] ASCII diagram included
- [ ] API fields (YAML, not Go)
- [ ] Test categories (not code)
- [ ] STRIDE table
- [ ] RBAC table
- [ ] Under 400 lines
- [ ] NO Go code

**If unchecked, revise before approval gate.**

---

**Pattern**: OpenShift feature specification with pattern integration  
**Version**: 2.0
