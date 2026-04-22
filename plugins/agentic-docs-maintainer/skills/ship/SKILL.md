---
name: ship
description: OpenShift safe deployment - validates upgrade strategy, creates PR, verifies CI, and ships with rollback plan. Use after /review passes. Final step in workflow.
trigger: explicit
model: sonnet
---

# Ship - OpenShift Safe Deployment

Deploy feature safely: validate readiness, create PR, monitor CI.

---

## 🚨 EXECUTE THESE PHASES IN ORDER 🚨

```
READ PATTERNS → PRE-SHIP → CREATE PR → REPORT
      │            │           │          │
      ▼            ▼           ▼          ▼
    Show        Check       Create      Done
  Checklist    Ready       & Push
```

**DO NOT skip phases. DO NOT proceed without completing current phase.**

---

## PHASE 0: Read Shipping Patterns (Inline)

**DO NOT use Skill("fetch"). Read files directly.**

### Check Local Patterns

```
📚 Phase 0: Reading Shipping Checklist
```

Check:
```bash
ls ../enhancements/agentic/platform/operator-patterns/
ls ../enhancements/agentic/practices/development/
```

### Read Files Directly

**If found locally**:
- `../enhancements/agentic/platform/operator-patterns/upgrade-strategies.md`
- `../enhancements/agentic/practices/development/` (shipping checklist if exists)

**If NOT found**, fetch via gh CLI.

### Report

```
✅ Shipping Guidance Retrieved:
  ✅ upgrade-strategies.md
  ✅ [shipping checklist]

🎯 Ready for pre-ship validation
```

---

## PHASE 1: Pre-Ship Validation

```
🔍 Phase 1: Pre-Ship Checklist
```

### Check Readiness

**Code**:
- [ ] All tests pass
- [ ] Review approved
- [ ] No uncommitted changes OR changes ready to commit

**API Changes** (if applicable):
- [ ] openshift/api PR merged
- [ ] Vendored into component
- [ ] CRDs generated

**Documentation**:
- [ ] Enhancement updated (if needed)
- [ ] Component docs updated (if needed)

**Upgrade** (if applicable):
- [ ] Supports N→N+1 upgrade
- [ ] Version skew considered
- [ ] Migration documented (if breaking)

### Report

```
📋 Pre-Ship Validation:

✅ Code ready
  ✅ All tests pass
  ✅ Review approved

[✅ API changes merged - if applicable]

[✅ Documentation updated - if needed]

[✅ Upgrade strategy validated - if applicable]

🎯 Ready to create PR
```

---

## PHASE 2: Create Pull Request

```
📝 Phase 2: Creating PR
```

### Check Git State

```bash
git status
git log origin/master..HEAD
```

### Create PR with Context

Use `gh pr create` with:
- **Title**: Brief, descriptive (<70 chars)
- **Body**: 
  - Summary (what changed)
  - Why (link to enhancement/issue)
  - Test plan (how to verify)
  - Upgrade notes (if applicable)
  - References (spec, plan if they exist)

**Example body**:
```markdown
## Summary
[What changed - 2-3 bullet points]

## Why
Implements: [enhancement link or issue]

## Test Plan
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] E2E tests pass
- [ ] Manual verification: [steps]

## Upgrade Notes
[If applicable - version compatibility, migration steps]

## References
- Spec: SPEC-[name].md
- Plan: PLAN-[name].md

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Report

```
✅ PR Created

PR URL: [URL]
Title: [title]
Commits: [count]

🎯 Next: Monitor CI
```

---

## PHASE 3: Report Completion

```
✅ Feature Shipped

📄 PR: [URL]

Next Steps:
  1. Monitor CI (tests must pass)
  2. Address review feedback
  3. Merge when approved

Rollback Plan:
  - Revert PR: gh pr close [number] && git revert [commits]
  - If merged: Create revert PR
```

**DONE.**

---

## Red Flags - You're Doing It Wrong

| Red Flag | Fix |
|----------|-----|
| Tests failing | Fix tests before creating PR. |
| Review not approved | Get review approval first. |
| No PR description | Add summary, test plan, references. |
| Force-pushing to master | Never force-push to protected branches. |

---

## Common Rationalizations - Don't Make These

| Excuse | Reality |
|--------|---------|
| "Tests will pass in CI" | Fix tests locally first. |
| "I'll add description later" | Add it now. Future you won't remember context. |
| "Just merge it" | PRs need review for quality and knowledge sharing. |

---

## Pre-Ship Checklist

- [ ] All tests pass locally
- [ ] Review approved
- [ ] API changes merged (if applicable)
- [ ] Documentation updated (if needed)
- [ ] Upgrade strategy validated (if applicable)

**If unchecked, fix before shipping.**

---

## Post-Ship Checklist

- [ ] PR created
- [ ] CI running
- [ ] PR description complete
- [ ] Reviewers notified

**Monitor PR and address feedback.**

---

**Pattern**: OpenShift safe deployment  
**Version**: 2.0
