# /change — Create Change Request

Create a Change Request (CR) for feature modifications.

## Usage

```
/change <description>
```

## CR Template

```markdown
# Change Request: <title>

**Date:** <date>
**Author:** <name>
**Status:** Pending / Approved / Rejected / Implemented
**Related Task:** <ClickUp Task ID>

---

## 1. Current State
Description of how it works now.

## 2. Proposed Change
What you want to change.

## 3. Reason
Why this change is needed.

## 4. Impact Analysis
- **Features Affected:** <list>
- **Files to Modify:** <list>
- **Estimated Time:** <hours/days>
- **Dependencies:** <other CRs/tasks>

## 5. Approval
- [ ] Lead Developer
- [ ] Artist (if visual)
- [ ] QA (if behavior change)

## 6. Rollback Plan
How to revert if issues arise.
```

## Example

```
/change "Change Element effectiveness: Water vs Fire from +30% to +25%"
```
