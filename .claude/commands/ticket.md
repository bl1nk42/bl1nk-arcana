# /ticket — Create Task from Spec

Create a new task in ClickUp from a feature spec.

## Usage

```
/ticket <feature_name> [priority]
```

## Parameters

- `feature_name` — Feature name from SPECS/ (required)
- `priority` — high/medium/low (default: medium)

## Example

```
/ticket "Card Draw System" high
```

## Template

```markdown
## Task: <feature_name>

**Priority:** <priority>
**Spec:** SPECS/<feature_name>.md
**PRD Section:** PDR.md#<section>

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

### Implementation Notes
- Reference: <file_path>:<line>
- Dependencies: <other_tasks>

### Test Cases
- Case 1: ...
- Case 2: ...
```
