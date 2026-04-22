---
description: Safe deployment with upgrade validation, PR creation, and rollback plan
---

## Name
agentic-docs-maintainer:ship

## Synopsis
```
/agentic-docs-maintainer:ship [--dry-run] [--skip-upgrade-test]
```

## Description
Safely deploy feature with upgrade strategy validation, PR creation, CI verification, and rollback plan. Final step in the OpenShift development workflow.

**Key Innovation**: Uses `/fetch` to retrieve upgrade strategies and shipping checklists for safe deployment.

## Arguments

- `--dry-run`: Validate readiness without creating PR
- `--skip-upgrade-test`: Skip upgrade test (not recommended)

## When to Use

- After `/review` passes
- Ready to create PR and ship
- Final step before deployment
- Need upgrade validation and rollback plan

## Six-Phase Shipping Workflow

```
1. Pre-Ship Checklist   → Validate 32 criteria
2. Upgrade Validation   → Test N → N+1 upgrade
3. Create PR            → Generate PR with summary
4. Verify CI            → Monitor all CI checks
5. Rollback Plan        → Document recovery procedures
6. Ship!                → Merge and deploy
```

## Pre-Ship Checklist (32 Criteria)

### API Changes (5 checks)
- openshift/api PR merged
- Vendored into component
- API review complete
- CRD manifests generated
- No breaking changes

### Implementation (5 checks)
- All tasks complete
- Operator patterns followed
- RBAC minimal
- Status conditions implemented
- Validation present

### Testing (6 checks)
- Unit tests ≥60%
- Integration tests ~30%
- E2E tests ~10%
- Upgrade test passes
- CI passes
- No flaky tests

### Security (5 checks)
- STRIDE model applied
- Input validation
- No secrets in logs
- RBAC least privilege
- No CVEs

### Observability (5 checks)
- Metrics implemented
- ServiceMonitor created
- Must-gather support
- Alerts defined
- Logs structured

### Documentation (4 checks)
- Enhancement merged
- AGENTS.md updated
- Exec-plan created
- Architecture docs updated

### Upgrade Strategy (2 checks)
- Upgradeable condition
- Handles N → N+1

## Example

```bash
/agentic-docs-maintainer:ship
```

**Output:**
```
📚 Fetching shipping guidance...
  ✅ platform/operator-patterns/upgrade-strategies.md
  ✅ practices/development/shipping-checklist.md
  ✅ practices/reliability/rollback-procedures.md

✅ Pre-Ship Checklist: 32/32 criteria met

🧪 Testing upgrade path...
  📦 Installing cluster N (4.15.0)
  ⬆️  Upgrading to N+1 (4.16.0-rc)
  ✅ Feature deployed successfully
  ✅ Upgradeable=True
  ⬆️  Testing skip-level (4.17.0-rc)
  ✅ Upgrade validation PASS

📝 Creating PR...
  ✅ PR created: https://github.com/openshift/myoperator/pull/123

🔍 Monitoring CI checks...
  ✅ verify (2m 15s)
  ✅ unit-tests (3m 42s)
  ✅ integration-tests (8m 18s)
  ✅ e2e-tests (45m 22s)
  ✅ upgrade-test (52m 10s)
  ✅ build (5m 33s)

📋 Rollback plan documented

🎯 Ready to ship!
  Next: Wait for reviewers to approve PR
  Then: Merge PR → Feature deploys automatically
```

## Upgrade Validation

Tests three scenarios:
1. **Install N → Upgrade N+1**: Feature appears correctly
2. **Verify Upgradeable**: Condition reports True
3. **Skip-level N+1 → N+2**: Feature survives upgrade

## Rollback Options

1. **Revert PR** (pre-merge): Close PR
2. **Revert commit** (post-merge): Create revert PR
3. **Feature flag** (if available): Disable via env var
4. **Cluster rollback**: Downgrade to previous version

## Success Criteria

Ship completes when:
- ✅ All 32 pre-ship criteria met
- ✅ Upgrade test passes
- ✅ PR created and approved
- ✅ All CI checks green
- ✅ Rollback plan ready
- ✅ PR merged
- ✅ Feature deployed
- ✅ Operator Available=True

## See Also

- `/agentic-docs-maintainer:review` - Code review (previous step)
- **Full Workflow**: spec → plan → build → test → review → ship ✅

---

**Pattern**: Safe deployment with upgrade validation  
**Version**: 1.0  
🎉 **Final step in the OpenShift development workflow!**
