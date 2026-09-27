# ClickUp-Linear Integration Guide

## Overview
แนวทางการใช้ ClickUp และ Linear ร่วมกันสำหรับทีม Blink Arcana

---

## 1. Tool Responsibilities

```
┌─────────────────────────────────────────────────────────────┐
│                        BLINK ARCANA                         │
├─────────────────────┬───────────────────────────────────────┤
│       CLICKUP       │              LINEAR                   │
├─────────────────────┼───────────────────────────────────────┤
│ Features            │ Bugs                                   │
│ Sprints (Planning)  │ Issues                                │
│ Milestones          │ Technical Debt                        │
│ Team Availability   │ Code-specific problems                │
│ High-level overview │ Low-level tracking                   │
│ Stakeholder view    │ Developer view                        │
└─────────────────────┴───────────────────────────────────────┘
```

### Decision Matrix

| Scenario | Use Tool |
|----------|----------|
| Plan sprint features | ClickUp |
| Report gameplay bug | Linear |
| Track tech debt | Linear |
| Update PRD requirements | ClickUp |
| Code review comments | Linear |
| Design review | ClickUp |
| DevOps/infrastructure issues | Linear |
| Performance investigation | Linear |

---

## 2. Workflow Integration

### 2.1 Feature Development Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  ClickUp    │     │   Linear    │     │   GitHub    │
│  Feature    │────▶│  Sub-tasks  │────▶│   PR/MR     │
│  Created    │     │  Created    │     │   Merged    │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ Status:     │     │ Status:     │     │ Status:     │
│ In Progress │     │ Done        │     │ Merged      │
└─────────────┘     └─────────────┘     └─────────────┘
```

### 2.2 Bug Reporting Flow

```
User/QA reports bug
        │
        ▼
┌─────────────────┐
│  Linear Issue   │  ← Detailed bug report
│  Created        │
└─────────────────┘
        │
        ├──────────────────────────────┐
        │                              │
        ▼                              ▼
┌─────────────────┐          ┌─────────────────┐
│  Simple Fix    │          │  Complex Issue │
│  (1-2 days)    │          │  (Research)     │
└─────────────────┘          └─────────────────┘
        │                              │
        ▼                              ▼
┌─────────────────┐          ┌─────────────────┐
│  Fixed & Closed │          │  Create ClickUp │
│  in Linear      │          │  Spike/Research │
└─────────────────┘          └─────────────────┘
                                         │
                                         ▼
                               ┌─────────────────┐
                               │  Sub-tasks in   │
                               │  Linear         │
                               └─────────────────┘
                                         │
                                         ▼
                               ┌─────────────────┐
                               │  Implemented    │
                               │  & Verified     │
                               └─────────────────┘
```

---

## 3. Linking Between Tools

### 3.1 Manual Linking

**ClickUp ↔ Linear:**
```
ใน ClickUp task description:
"Linear: ABC-123"
"Related Linear issue: https://linear.app/bl1nk-arcana/issue/ABC-123"

ใน Linear issue description:
"ClickUp: [CUP-456](https://app.clickup.com/t/ CUP-456)"
"Parent feature: https://app.clickup.com/t/feature-task"
```

### 3.2 GitHub as Bridge

```
PR Title: feat: ABC-123 add combat damage calculation

GitHub PR Links:
- Linear: ABC-123 (auto-linked by Linear GitHub App)
- ClickUp: Manual link in PR description
```

### 3.3 Zapier/Make Automation

**Option A: Linear → ClickUp (Bug Sync)**

```javascript
// Zapier/Make Scenario
Trigger: New Linear Issue created
  - Filter: Label contains "bug"
Action: Create ClickUp Task
  - List: Bug Tracking
  - Name: From Linear title
  - Description: From Linear description
  - Priority: Map Linear priority
```

**Option B: ClickUp → Linear (Feature Breakdown)**

```javascript
Trigger: ClickUp task moved to "In Progress"
  - Filter: Type = "Feature"
Action: Create Linear Issue
  - Team: Engineering
  - Title: ClickUp task name
  - Description: Link back to ClickUp
```

---

## 4. Sprint Sync Process

### 4.1 Sprint Planning (ClickUp)

1. **Create Sprint in ClickUp**
   - Sprint Backlog list
   - Assign points
   - Set dates

2. **Identify Technical Tasks**
   - For each feature, create subtasks
   - Tag with `rust-core`, `godot`, `proto`

3. **Sync to Linear**
   - Create Linear issues for complex sub-tasks
   - Link back to ClickUp parent

### 4.2 Daily Sync

**Morning Standup:**
- Check Linear: Issues assigned to you
- Check ClickUp: Sprint progress

**GitHub PR Workflow:**
```
1. Create branch: feature/linear-issue-title
2. PR auto-links Linear issue
3. Move Linear issue to "In Review"
4. On merge: Move to "Done"
5. Update ClickUp task status
```

### 4.3 Sprint Closing

1. **Linear: Close sprint issues**
   - Review all done issues
   - Archive completed cycles

2. **ClickUp: Update sprint**
   - Mark sprint complete
   - Review velocity
   - Update backlog

---

## 5. Bi-Weekly Summary Template

### 5.1 Summary Structure

```markdown
# Sprint X Summary - [Date Range]

## 📊 Metrics

### Velocity
| Metric | This Sprint | Previous | Change |
|--------|-------------|---------|--------|
| Points Completed | X | Y | +Z% |
| Issues Closed | X | Y | +Z% |
| Bugs Fixed | X | Y | +Z% |

### Quality
| Metric | Value |
|--------|-------|
| Bug Escape Rate | X% |
| Reopened Issues | X |
| Critical Bugs | X |

### Team
| Metric | Value |
|--------|-------|
| Active Contributors | X |
| Avg Issues per Person | X |
| Capacity Utilization | X% |

---

## 🎯 Accomplishments

### Features Completed
- [Feature 1] - [CUP-123]
- [Feature 2] - [CUP-124]

### Bugs Fixed
- [Bug 1] - [ABC-123]
- [Bug 2] - [ABC-124]

### Technical Debt Addressed
- [Debt 1] - [ABC-125]

---

## 📋 Incomplete Items

### Carried Over
- [Item 1] - Reason: [Explanation]

### Blocked
- [Item 1] - Blocked by: [Dependency]

---

## 🔮 Next Sprint Goals

### Primary Objectives
1. [Objective 1]
2. [Objective 2]
3. [Objective 3]

### Key Features
- [Feature A]
- [Feature B]

---

## 📝 Notes & Learnings

### What Went Well
-

### What Could Improve
-

### Action Items
- [ ] Action 1
- [ ] Action 2
```

### 5.2 Metrics Collection

**From ClickUp:**
```javascript
// Sprint velocity query
{
  "tasks_completed": X,
  "points_completed": Y,
  "tasks_by_type": {
    "feature": A,
    "subtask": B,
    "spike": C
  }
}
```

**From Linear:**
```javascript
// Issue metrics
{
  "issues_created": X,
  "issues_closed": Y,
  "bugs_by_priority": {
    "urgent": A,
    "high": B,
    "medium": C,
    "low": D
  },
  "avg_resolution_time": "X days",
  "tech_debt_addressed": Z
}
```

**From GitHub:**
```javascript
// PR metrics
{
  "prs_merged": X,
  "prs_by_type": {
    "feature": A,
    "bugfix": B,
    "refactor": C
  },
  "review_time_avg": "X hours",
  "merge_time_avg": "Y hours"
}
```

---

## 6. Status Reporting Dashboard

### 6.1 Stakeholder View (ClickUp)

**Weekly Status Email Template:**

```markdown
## Blink Arcana - Weekly Status
### Week of [Date]

### 🎯 This Week's Focus
- [Focus area 1]
- [Focus area 2]

### ✅ Completed
- [Feature/Sprint item] - Done
- [Bug fix] - Fixed

### 🔄 In Progress
- [Feature] - X% complete, expected finish [Date]

### ⚠️ Blockers
- [Blocker 1] - Mitigation plan

### 📅 Next Week
- [Planned work 1]
- [Planned work 2]

### 📊 Metrics
- Sprint velocity: X points
- Bugs resolved: X
- Items remaining: X
```

### 6.2 Technical View (Linear)

**Weekly Dev Digest:**

```markdown
## Engineering Weekly Digest
### [Date Range]

### Issues Overview
- Created: X
- Closed: Y
- Open: Z

### Priority Breakdown
- 🔴 Critical: X
- 🟠 High: Y
- 🟡 Medium: Z

### Top Labels This Week
1. rust-core: X issues
2. godot: Y issues
3. bug: Z issues

### Cycle Progress
- Sprint X: X/Y tasks (Z%)
- Days remaining: N

### Long-Running Issues
- [Issue ABC-123] - 7 days open
- [Issue ABC-456] - 5 days open

### Tech Debt Addressed
- [Issue ABC-789]: Refactored pathfinding module
```

---

## 7. Conflict Resolution

### Scenario 1: ClickUp vs Linear Status Mismatch

**Problem:** ClickUp shows Done, Linear still open

**Resolution:**
```
1. Check Linear issue status
2. If PR merged → Ensure Linear moved to Done
3. If no PR → Verify actual completion
4. Update both systems to match
5. Document the sync process
```

### Scenario 2: Duplicate Work

**Problem:** Same work tracked in both systems

**Resolution:**
```
1. Use Linear for all bug/tech-debt work
2. Use ClickUp for features only
3. Cross-link when dependencies exist
4. Review sync points weekly
```

### Scenario 3: Missing Links

**Problem:** Issues not linked between tools

**Resolution:**
```
1. Add "Related Linear" field to ClickUp
2. Add "Parent ClickUp" field to Linear
3. Create automation to sync links
4. Audit monthly for orphaned items
```

---

## 8. Automation Rules

### 8.1 ClickUp Automations

```javascript
// Auto-create Linear issue for bugs
{
  "trigger": "Task created in Bug Tracking",
  "condition": "Type = bug",
  "action": "Webhook to Linear API"
}

// Auto-update ClickUp on Linear close
{
  "trigger": "Linear issue moved to Done",
  "condition": "Has ClickUp link",
  "action": "Update ClickUp task status"
}
```

### 8.2 Linear Automations

```javascript
// Auto-label based on project
{
  "trigger": "Issue created",
  "condition": "Team = Engineering",
  "action": "Add 'engineering' label"
}

// Notify on critical bugs
{
  "trigger": "Priority changed to Urgent",
  "condition": "Label contains 'bug'",
  "action": "Send Slack to #game-bugs"
}
```

### 8.3 GitHub Automations

```yaml
# .github/workflows/linear-sync.yml
name: Linear Sync

on:
  pull_request:
    types: [opened, closed, merged]

jobs:
  sync-linear:
    runs-on: ubuntu-latest
    steps:
      - name: Update Linear Issue
        uses: linear/hync-github-action@v1
        with:
          linear_token: ${{ secrets.LINEAR_TOKEN }}
          trigger: ${{ github.event.action }}
          pr_state: ${{ github.event.pull_request.state }}
```

---

## 9. Calendar Sync

### 9.1 Sprint Events

**ClickUp Calendar Export:**
1. Export: ClickUp → Calendar (ICS)
2. Import to: Google Calendar / Outlook

**Linear Cycles:**
1. Enable: Settings → Cycles → Show on Calendar
2. Sync to: Google Calendar

### 9.2 Review Schedule

```javascript
// Suggested calendar events
{
  "monday_0900": "Sprint Planning",
  "monday_1000": "Team Standup",
  "thursday_1400": "Mid-Sprint Review",
  "friday_1600": "Sprint Retrospective"
}
```

---

## 10. Access Control

### 10.1 ClickUp Permissions

| Role | Features | Bugs | Ideas | Admin |
|------|----------|------|-------|-------|
| Admin | Full | Full | Full | Yes |
| Developer | Edit | Edit | View | No |
| Designer | Edit | View | Edit | No |
| PM | Full | Edit | Edit | Limited |

### 10.2 Linear Permissions

| Role | Create | Edit | Close | Admin |
|------|--------|------|-------|-------|
| Admin | ✓ | ✓ | ✓ | ✓ |
| Member | ✓ | Own | ✓ | No |
| Viewer | View | - | - | No |

---

## 11. Backup & Export

### 11.1 ClickUp Backup

```javascript
// Weekly export
{
  "export_type": "CSV",
  "include": ["tasks", "time_logs", "comments"],
  "schedule": "Weekly (Sunday)"
}
```

### 11.2 Linear Backup

```javascript
// Via API
GET /api/export?format=json
```

### 11.3 Archival Policy

| Data | Keep | Archive | Delete |
|------|------|---------|--------|
| Completed tasks | 6 months | 12 months | After 1 year |
| Bugs | 3 months | 6 months | After 6 months |
| Ideas | 3 months | 12 months | After 1 year |
| Sprint data | 6 months | 12 months | After 1 year |

---

## 12. Success Metrics

### 12.1 Tool Adoption

| Metric | Target | Current |
|--------|--------|---------|
| ClickUp daily active users | 100% | - |
| Linear issues created with templates | >90% | - |
| GitHub PRs linked to Linear | 100% | - |
| Sprint tasks linked to Linear | >80% | - |

### 12.2 Process Efficiency

| Metric | Target | Current |
|--------|--------|---------|
| Avg time to close bug | <3 days | - |
| Sprint completion rate | >85% | - |
| Blocked task ratio | <5% | - |
| Reopened issues rate | <5% | - |

### 12.3 Team Satisfaction

| Metric | Target | Current |
|--------|--------|---------|
| Tool satisfaction score | >4/5 | - |
| Time tracking accuracy | >80% | - |
| Cross-tool confusion reports | <2/week | - |

---

## 13. Onboarding Checklist

### New Team Member

- [ ] Invite to ClickUp workspace
- [ ] Invite to Linear workspace
- [ ] Install GitHub integration (both)
- [ ] Join relevant teams
- [ ] Add to notification channels
- [ ] Review this integration guide
- [ ] Shadow one sprint cycle
- [ ] First contribution under mentor review
