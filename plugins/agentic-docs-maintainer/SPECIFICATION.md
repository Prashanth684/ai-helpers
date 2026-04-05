# Agentic Directory Specification

**Purpose**: Defines "correct" state for the agentic/ directory  
**Used by**: Agentic Docs Maintainer verification and autonomous maintenance  
**Last Updated**: 2026-04-03

---

## 1. Completeness Requirements

### 1.1 All Platform Concepts Must Be Documented

**Verification**: Check that key OpenShift concepts have documentation

Required domain concepts:
- [x] ClusterOperator (domain/openshift/clusteroperator.md)
- [x] ClusterVersion (domain/openshift/clusterversion.md)
- [x] Machine (domain/openshift/machine.md)
- [x] MachineConfig (domain/openshift/machineconfig.md)
- [x] Route (domain/openshift/route.md)
- [x] CustomResourceDefinition (domain/kubernetes/crds.md)
- [ ] Deployment (domain/kubernetes/deployment.md) - Consider if frequently referenced
- [ ] Service (domain/kubernetes/service.md) - Consider if frequently referenced
- [ ] Pod (domain/kubernetes/pod.md) - Consider if frequently referenced
- [ ] Namespace (domain/kubernetes/namespace.md) - Consider if frequently referenced

**Dynamic Discovery**: Agentic Docs Maintainer should:
1. Scan `/enhancements/` for new API types being introduced
2. Create domain/ docs for new OpenShift-specific resources
3. Update existing domain/ docs when enhancements modify resources
4. Extract resource definitions, use cases, and examples from enhancements

### 1.2 All Operator Patterns Must Be Documented

**Verification**: Check platform/operator-patterns/

Required patterns:
- [x] controller-runtime.md
- [x] status-conditions.md
- [x] leader-election.md
- [x] finalizers.md
- [x] webhooks.md
- [x] owner-references.md
- [x] rbac-patterns.md
- [x] upgrade-strategies.md
- [x] must-gather.md
- [x] index.md

**Status**: COMPLETE ✅

### 1.3 Cross-Repo ADRs Must Be Documented

**Verification**: Check decisions/ for foundational platform decisions

Current ADRs:
- [x] adr-0001-operator-sdk.md
- [x] adr-0002-etcd-backend.md
- [x] adr-0003-cvo-upgrade-ordering.md

**Criteria for new ADRs**: Only add if decision affects ALL components

**Dynamic Discovery**: Agentic Docs Maintainer should:
1. Scan recent enhancements for "Alternatives Considered" sections
2. Identify cross-cutting architectural decisions (affects multiple components)
3. Extract decision rationale, alternatives, and consequences
4. Propose new ADRs (for human review before creating)
5. Update existing ADRs when enhancements supersede decisions

Potential future ADRs (to be extracted from enhancements):
- Routes vs pure Ingress (foundational)
- MachineConfig/Immutable Infrastructure (foundational)
- RHCOS + rpm-ostree choice (foundational)
- ClusterOperator pattern rationale (foundational)
- OVN-Kubernetes as default CNI (foundational)

**Status**: Appropriate scope, but should grow with platform ✅

### 1.4 Enhancement Knowledge Must Be Extracted

**Verification**: Check that recent enhancements have been processed

**Dynamic Knowledge Extraction**: Agentic Docs Maintainer should:

1. **Monitor enhancements/** for new/updated files (git log last 30 days)
2. **Extract key information**:
   - New API types → Create domain/ docs
   - Architectural decisions → Propose ADRs
   - New patterns → Add to platform/operator-patterns/
   - Security practices → Add to practices/security/
   - Testing approaches → Add to practices/testing/
   - New terminology → Add to references/glossary.md

3. **Enrich existing docs**:
   - Update DESIGN_PHILOSOPHY.md with new principles
   - Add examples from enhancements to pattern docs
   - Update references/enhancement-index.md with new categories
   - Cross-reference related enhancements in domain docs

4. **Create new content when justified**:
   - New operator pattern emerges across multiple enhancements
   - New OpenShift-specific resource type introduced
   - Major architectural shift documented in enhancement

**Example Flow**:
```
New enhancement: enhancements/network/bgp-ovn-kubernetes.md
  ↓
Ralph detects: New pattern for BGP integration
  ↓
Ralph extracts: Configuration approach, API design, upgrade strategy
  ↓
Ralph creates: platform/operator-patterns/bgp-integration.md (if pattern is reusable)
  OR
Ralph updates: domain/openshift/network.md (if specific to networking)
  ↓
Ralph updates: references/glossary.md (adds BGP terms)
  ↓
Ralph updates: references/enhancement-index.md (links to BGP enhancement)
```

**Tracking**: Maintain `.ralph-processed-enhancements.txt` to track what's been analyzed

---

## 2. Consistency Requirements

### 2.1 No Conflicting Information

**Verification**: Check that docs don't contradict each other

Rules:
- If /dev-guide/ has authoritative info, reference it (don't duplicate)
- If multiple agentic/ docs cover same topic, they must agree
- Status conditions pattern must match across all docs

**Checks**:
```bash
# Check for contradictions in API evolution guidance
grep -r "API version" agentic/practices/development/api-evolution.md
grep -r "API version" agentic/DESIGN_PHILOSOPHY.md
# Should agree on v1alpha1 → v1beta1 → v1 progression
```

### 2.2 References Must Be Accurate

**Verification**: All file references and links must exist

Rules:
- Internal links must point to existing files
- External GitHub links must be valid
- /dev-guide/ references must exist
- /enhancements/ references should exist (or be marked as examples)

**Checks**:
```bash
# Find broken internal references
grep -r '\[.*\](\.\/.*\.md)' agentic/ | while read line; do
  # Extract file path and verify it exists
  # Exit 1 if any broken
done
```

### 2.3 Index Files Must Be Complete

**Verification**: Index files must reference all relevant docs

Required indexes:
- decisions/index.md → lists all ADRs
- platform/operator-patterns/index.md → lists all patterns
- practices/testing/index.md → lists all testing docs
- references/index.md → links to all reference docs
- KNOWLEDGE_GRAPH.md → accurate file counts

**Checks**:
```bash
# Verify decisions/index.md lists all ADRs
ls agentic/decisions/adr-*.md | wc -l
grep -c "adr-" agentic/decisions/index.md
# Counts must match
```

---

## 3. Integration Requirements

### 3.1 Official Docs Must Be Referenced

**Verification**: Agentic docs must reference authoritative sources

Required references:
- [x] practices/development/api-evolution.md → /dev-guide/api-conventions.md
- [x] practices/testing/index.md → /dev-guide/test-conventions.md
- [x] workflows/enhancement-process.md → /guidelines/enhancement_template.md
- [x] practices/development/git-workflow.md → /guidelines/commit_and_pr_text.md
- [x] platform/operator-patterns/index.md → /dev-guide/operators.md
- [x] references/index.md → /dev-guide/ directory

**Status**: Per RECONCILIATION_NEEDED.md - NEEDS VERIFICATION

**Checks**:
```bash
# Verify each doc has proper reference
grep -l "/dev-guide/" agentic/practices/development/api-evolution.md || exit 1
grep -l "/dev-guide/" agentic/practices/testing/index.md || exit 1
# etc.
```

### 3.2 Enhancement Directory Must Be Indexed

**Verification**: references/enhancement-index.md must be accurate

Requirements:
- Lists major enhancement categories
- Links work (at least spot-check)
- Updated when new categories appear in /enhancements/

**Checks**:
```bash
# Count categories in /enhancements/ vs index
ls -d enhancements/*/ | wc -l
grep -c "enhancements/" agentic/references/enhancement-index.md
# Should be similar (index doesn't need EVERY category, just major ones)
```

---

## 4. Navigation Requirements

### 4.1 Three-Hop Maximum

**Verification**: Any concept reachable in ≤3 hops from OPENSHIFT_AGENTS.md

Rule: OPENSHIFT_AGENTS.md → Category → Subcategory → Specific Doc (max 3)

Examples:
- ✅ OPENSHIFT_AGENTS → platform → operator-patterns → status-conditions
- ✅ OPENSHIFT_AGENTS → DESIGN_PHILOSOPHY (1 hop)
- ❌ Too deep: OPENSHIFT_AGENTS → X → Y → Z → W (4 hops)

**Checks**: Manual verification via KNOWLEDGE_GRAPH.md paths

### 4.2 Entry Points Must Be Clear

**Verification**: Each major section has clear entry point

Required entry points:
- [x] OPENSHIFT_AGENTS.md (master entry)
- [x] DESIGN_PHILOSOPHY.md (WHY)
- [x] platform/operator-patterns/index.md
- [x] practices/testing/index.md
- [x] decisions/index.md
- [x] references/index.md

**Status**: COMPLETE ✅

---

## 5. Quality Requirements

### 5.1 Code Examples Must Be Valid

**Verification**: Go code snippets should be syntactically valid

Rules:
- Go examples should compile (or be clearly marked as pseudocode)
- YAML examples should be valid YAML
- Shell examples should be valid bash

**Checks**:
```bash
# Extract Go code blocks and attempt to parse
# Extract YAML and validate with yamllint
# This is lower priority - marks quality, not correctness
```

### 5.2 Markdown Must Be Well-Formed

**Verification**: All .md files should be valid markdown

Rules:
- Headers properly nested (no H1 → H3 without H2)
- Lists properly formatted
- Code blocks properly closed
- No broken image references

**Checks**:
```bash
# Use markdownlint or similar
markdownlint agentic/**/*.md
```

---

## 6. Freshness Requirements

### 6.1 Last Updated Dates

**Verification**: Files with "Last Updated" should be recent-ish

Rule: If major changes to platform, docs should reflect them

**Checks**: Manual - not automated (we don't want false positives)

### 6.2 Version References

**Verification**: Version numbers should be plausible

Rules:
- Don't reference versions that don't exist yet
- Don't reference old deprecated versions unless discussing history
- Use "4.x" or "current" instead of specific versions when possible

**Checks**: Grep for version numbers, manual review

---

## 7. Autonomy Requirements (For Agentic Docs Maintainer)

### 7.1 Verification Script Must Be Automated

**Verification**: verify-agentic.sh exits 0 if all checks pass

Requirements:
- Runs all automated checks
- Returns exit code 0 = success, 1 = needs work
- Prints actionable errors
- No false positives (don't flag things that are actually OK)

### 7.2 Changes Must Be Reviewable

**Verification**: Agentic Docs Maintainer should create commits, not just change files

Requirements:
- Each iteration creates a commit
- Commit message describes what changed
- Easy to review via git log
- Easy to roll back if needed

---

## 8. Stopping Conditions

### Agentic Docs Maintainer Should Stop When:

1. ✅ All verification checks pass (exit 0)
2. ✅ No changes made in last iteration (converged)
3. ⚠️ Max iterations reached (safety limit: 10)
4. ❌ Same error repeats 3 times (stuck)

### Agentic Docs Maintainer Should Continue When:

1. Verification fails but fixable
2. Changes were made and verification not yet clean
3. Under iteration limit
4. Making progress (different errors each time)

---

## 9. Success Metrics

### How to Measure "Good"

**Must Have** (Agentic Docs Maintainer should fix):
- ✅ All internal links work
- ✅ All index files are complete
- ✅ No contradictions between docs
- ✅ Official docs are referenced (per RECONCILIATION_NEEDED.md)

**Should Have** (manual review):
- Completeness (all major concepts documented)
- Quality (examples are correct)
- Freshness (reflects current platform)

**Nice to Have** (continuous improvement):
- More ADRs as platform evolves
- More patterns as best practices emerge
- Better examples as we learn what agents need

---

## 10. Content Creation Guidelines

### What Agentic Docs Maintainer SHOULD Create

**✅ Create when well-justified**:
- **Domain docs** for new OpenShift API types from enhancements
- **Pattern docs** when pattern appears in 3+ enhancements
- **Glossary entries** for new OpenShift-specific terminology
- **Enhancement index entries** for new categories
- **Examples** extracted from approved enhancements
- **ADR proposals** for cross-cutting decisions (human reviews before finalizing)

**✅ Update proactively**:
- **Existing domain docs** when enhancements modify resources
- **DESIGN_PHILOSOPHY.md** when new principles emerge
- **Pattern docs** with new examples from enhancements
- **References** when new repos or enhancements appear

### What Agentic Docs Maintainer Should NOT Do

**❌ Don't create**:
- Content without source material (must extract from enhancements)
- ADRs without flagging for human decision review
- Duplicate content that exists in /dev-guide/ or /enhancements/
- Docs for deprecated or rejected features
- Speculative documentation (only from approved enhancements)

**❌ Don't modify**:
- Official docs in /dev-guide/ or /enhancements/ (read-only)
- Core navigation structure without validation
- Content outside agentic/ directory

**✅ Do**:
- Fix broken links
- Update indexes
- Add missing references to official docs
- Fix contradictions by referencing authoritative source
- Improve existing docs for clarity
- **Extract knowledge from new enhancements**
- **Create new docs when patterns emerge**
- **Enrich existing docs with new examples**

---

## Current Compliance Status

Last verified: 2026-04-03

**Passing**:
- ✅ Platform operator patterns complete
- ✅ Decision ADRs appropriate scope
- ✅ Navigation structure sound (≤3 hops)
- ✅ Entry points clear

**Needs Work** (per RECONCILIATION_NEEDED.md):
- ⚠️ Add references to /dev-guide/ in relevant docs
- ⚠️ Verify all internal links work
- ⚠️ Update indexes to match actual files
- ⚠️ Check for contradictions

**Future Work** (not for Agentic Docs Maintainer):
- Consider additional foundational ADRs
- Consider basic Kubernetes concepts if agents ask frequently
- Monitor for gaps as platform evolves
