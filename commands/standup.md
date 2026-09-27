# /standup — Daily Standup

Show today's tasks, blockers, and plan.

## Usage

```
/standup
/standup <date>
```

## Output

```
=== Daily Standup - <date> ===

## Tasks Today
- [ ] TASK-001: Implement Grid System (in progress)
- [ ] TASK-002: Write combat.rs tests
- [ ] TASK-003: Review PR #15

## Blockers
- Waiting for Artist: Unit sprite sheets
- Linear Issue LIN-45: Pathfinding edge case

## Yesterday's Progress
- Completed: Unit Movement (TASK-001)
- PR #14 merged: Basic Combat

## Plan
1. Finish Grid System
2. Write tests for combat.rs
3. Code review PR #15
```

## Integration

- Reads from ClickUp (My Tasks)
- Reads from Linear (Assigned Issues)
- Shows Git commits from yesterday
