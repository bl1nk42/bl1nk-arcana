# Linear Setup Guide - Blink Arcana

## Overview
Linear สำหรับติดตาม Bugs, Issues และ Technical Debt ของทีม Developer

---

## 1. Workspace Setup

### 1.1 Create Workspace

1. ไปที่ https://linear.app
2. คลิก **"Create workspace"**
3. กรอกข้อมูล:
   - **Workspace name:** `Blink Arcana`
   - **URL slug:** `bl1nk-arcana`
   - **Icon:** เลือก icon หรือ upload ได้เลย
4. เลือก **"Start from scratch"** (ไม่ต้อง import)

---

## 2. Team Structure

### 2.1 Create Teams

**Navigation:** Settings → Teams → New team

#### Team 1: Engineering (Backend)
```
Name: Engineering
Icon: ⚙️
Members: [Dev leads]
Description: Rust core, Godot scripts, DevOps
```

#### Team 2: QA
```
Name: QA
Icon: 🔍
Members: [QA leads]
Description: Bug verification, playtesting
```

#### Team 3: All Hands (Optional)
```
Name: All Hands
Icon: 👥
Members: Everyone
Description: Cross-team issues
```

### 2.2 Team Settings

**Per Team Configuration:**

| Setting | Value |
|---------|-------|
| Auto-close state | Done |
| Default workflow | Linear Default |
| Triage state | Triage |
| Inbox state | Inbox |
| Cycle lock state | Cancelled |

---

## 3. Projects

### 3.1 Create Projects

**Navigation:** Sidebar → Projects → New project

#### Project 1: Core Engine
```
Name: Core Engine
Icon: 🎯
Teams: Engineering
Description: Rust GDExtension, combat logic, AI
```

#### Project 2: Godot Frontend
```
Name: Godot Frontend
Icon: 🎨
Teams: Engineering
Description: UI scenes, animations, user input
```

#### Project 3: Infrastructure
```
Name: Infrastructure
Icon: 🏗️
Teams: Engineering
Description: CI/CD, build pipeline, tooling
```

#### Project 4: Active Bugs
```
Name: Active Bugs
Icon: 🐛
Teams: Engineering, QA
Description: Current sprint bugs
```

### 3.2 Project Structure

```
Blink Arcana/
├── 🔴 Active Bugs/
│   ├── Sprint 1/
│   ├── Sprint 2/
│   └── Backlog/
├── ⚙️ Core Engine/
│   ├── Combat System/
│   ├── AI System/
│   └── Pathfinding/
├── 🎨 Godot Frontend/
│   ├── Main Menu/
│   ├── Battle Scene/
│   └── Party UI/
└── 🏗️ Infrastructure/
    ├── CI/CD/
    └── DevOps/
```

---

## 4. Workflow States

### 4.1 Default Workflow

**Navigation:** Settings → Workflows → Linear Default

**States (และสี):**

```
Triage (Gray)        → Backlog (Blue) → Todo (Purple)
    ↓                                    ↓
Cancelled (Red)    ←   Done (Green)   ←  In Review (Yellow)
                                            ↓
                                       In Progress (Orange)
```

### 4.2 Custom Workflow for Bugs

**Navigation:** Settings → Workflows → New workflow

**Workflow Name:** `Bug Workflow`

**States Configuration:**

| State | Type | Color |
|-------|------|-------|
| Triage | No type | Gray `#8A8A8A` |
| Confirmed | No type | Blue `#007AFF` |
| Todo | No type | Purple `#8E44AD` |
| In Progress | No type | Orange `#FF9500` |
| In Review | No type | Yellow `#FFCC00` |
| Done | Completed | Green `#34C759` |
| Cancelled | Cancelled | Red `#FF3B30` |
| Archived | Cancelled | Gray `#636C73` |

### 4.3 State Transitions

**Allowed Transitions:**

```
Triage → Confirmed, Cancelled
Confirmed → Todo, Cancelled
Todo → In Progress, Cancelled
In Progress → In Review, Todo
In Review → Done, In Progress
Done → Archived
Cancelled → Triage (reopen)
```

---

## 5. Labels

### 5.1 Label Structure

**Navigation:** Settings → Labels → New label

#### Category 1: Issue Type

| Label | Color | Description |
|-------|-------|-------------|
| `bug` | Red | Something not working |
| `feature-request` | Blue | Enhancement request |
| `tech-debt` | Orange | Technical debt item |
| `performance` | Yellow | Performance related |
| `security` | Purple | Security issue |
| `ui-bug` | Pink | Visual/UI issue |
| `gameplay-bug` | Cyan | Gameplay logic issue |

#### Category 2: System

| Label | Color | Description |
|-------|-------|-------------|
| `rust-core` | Green | Rust GDExtension code |
| `godot` | Purple | Godot GDScript code |
| `proto` | Blue | Protocol Buffer changes |
| `database` | Yellow | Data persistence |
| `ci-cd` | Gray | Build pipeline |

#### Category 3: Priority

| Label | Color | Description |
|-------|-------|-------------|
| `critical` | Red | Critical issue |
| `high-priority` | Orange | High priority |
| `needs-design` | Pink | Awaiting design decision |

#### Category 4: Status

| Label | Color | Description |
|-------|-------|-------------|
| `blocked` | Red | Blocked by other issue |
| `waiting-on-user` | Yellow | Waiting for external input |
| `needs-info` | Gray | Needs more information |
| `ready-to-test` | Green | Ready for QA |

### 5.2 Label Hierarchy

```
Issue Type
├── 🐛 bug
├── ✨ feature-request
├── 💳 tech-debt
└── ⚡ performance

System
├── 🦀 rust-core
├── 🎮 godot
└── 📡 proto

Priority
├── 🔴 critical
└── 🟠 high-priority
```

---

## 6. Cycles (Sprints)

### 6.1 Create Cycle

**Navigation:** Sidebar → Cycles → New cycle

**Cycle Settings:**

| Field | Value |
|-------|-------|
| Name | `Sprint 1` |
| Start Date | [Monday] |
| End Date | [Friday + 2 weeks] |
| Status | Active |

### 6.2 Cycle Templates

สร้าง cycle template สำหรับ sprint ต่อไป:

**Navigation:** Settings → Cycles → Cycle templates → New template

```markdown
Template: Standard Sprint

Duration: 2 weeks
Start: Monday
End: Friday (2 weeks later)

Default points: 13 per developer
Team capacity: Calculate automatically
```

### 6.3 Cycle Views

**View 1: Sprint Board**
```
Layout: Board
Group by: Status
Filter: Cycle = Current
```

**View 2: My Issues**
```
Layout: List
Filter: Assignee = Me AND Cycle = Current
Sort: Priority
```

**View 3: Velocity**
```
Layout: Chart
Type: Line
Data: Completed points over cycles
```

---

## 7. Issue Templates

### 7.1 Bug Report Template

**Navigation:** Settings → Issue templates → New template

**Template Name:** `Bug Report`

**Template Content:**

```markdown
## Bug Description
<!-- อธิบายว่าเกิดอะไรขึ้น -->

## Steps to Reproduce
1.
2.
3.

## Expected Behavior
<!-- คาดหวังว่าควรเป็นอย่างไร -->

## Actual Behavior
<!-- สิ่งที่เกิดขึ้นจริง -->

## Environment
- Godot Version:
- Rust Version:
- OS:
- Build:

## Screenshots/Videos
<!-- แนบรูปหรือวิดีโอ -->

## Additional Context
<!-- ข้อมูลเพิ่มเติม -->

## Labels
- [ ] bug
- [ ] rust-core / godot / ci-cd
- [ ] ui-bug / gameplay-bug
```

### 7.2 Feature Request Template

**Template Name:** `Feature Request`

```markdown
## Feature Summary
<!-- สรุปสั้นๆว่าต้องการอะไร -->

## Problem Statement
<!-- ปัญหาที่ต้องการแก้ -->

## Proposed Solution
<!-- เสนอแนวทางแก้ -->

## PRD Reference
<!-- Link ไปยัง PRD section -->

## Acceptance Criteria
- [ ] Criteria 1
- [ ] Criteria 2

## Technical Notes
<!-- ข้อควรพิจารณาทางเทคนิค -->

## Labels
- [ ] feature-request
- [ ] rust-core / godot / proto
```

### 7.3 Tech Debt Template

**Template Name:** `Tech Debt`

```markdown
## What is the debt?
<!-- อธิบายว่า code ตรงไหนที่เป็นปัญหา -->

## Why is it a problem?
<!-- ทำไมต้องแก้ -->

## Impact if not addressed
<!-- ผลกระทบถ้าไม่แก้ -->

## Suggested Solution
<!-- แนวทางแก้ -->

## Estimated Effort
<!-- เวลาที่ต้องใช้ -->

## Labels
- [ ] tech-debt
- [ ] rust-core / godot
```

---

## 8. Views (Saved Queries)

### 8.1 Create Views

**Navigation:** Sidebar → Views → New view

#### View 1: Inbox
```
Name: Inbox
Filter:
  - Triage state
  - No assignee
Sort: Created at (newest)
Display: List
```

#### View 2: My Issues (Priority)
```
Name: My Issues
Filter:
  - Assignee = Me
  - Status not in [Done, Cancelled]
Sort: Priority → Due date
Group by: Status
```

#### View 3: Critical Issues
```
Name: Critical
Filter:
  - Priority = Urgent
  - Status not in [Done, Cancelled]
Sort: Created at
```

#### View 4: Blocked Issues
```
Name: Blocked
Filter:
  - Label: blocked
  - Status not in [Done, Cancelled]
```

#### View 5: Ready for Review
```
Name: Ready for Review
Filter:
  - Status = In Review
Sort: Updated at
```

#### View 6: This Week
```
Name: This Week
Filter:
  - Due date ≤ 7 days
  - Status not in [Done, Cancelled]
Sort: Due date
```

### 8.2 Default View Settings

**Navigation:** Settings → Preferences → Default views

| View | Set as Default |
|------|----------------|
| My Issues | ✓ (for all users) |
| Inbox | ✓ (notifications) |

---

## 9. Dashboard

### 9.1 Create Dashboard

**Navigation:** Sidebar → Dashboards → New dashboard

**Dashboard Name:** `Engineering Dashboard`

### 9.2 Widgets

#### Widget 1: Issue Velocity (Chart)
```
Type: Line chart
Data: Issues completed over time
Time range: Last 30 days
```

#### Widget 2: Open by Priority (Donut)
```
Type: Donut chart
Data: Open issues by priority
```

#### Widget 3: Team Workload (Bar)
```
Type: Bar chart
Data: Open issues per assignee
```

#### Widget 4: Recent Activity (Feed)
```
Type: Activity feed
Data: Last 20 updates
Filter: Project = Current project
```

#### Widget 5: Cycle Progress (Progress)
```
Type: Progress bar
Data: Completed vs Total in current cycle
```

#### Widget 6: Untriaged Issues (Number)
```
Type: Number
Data: Count of triage issues
Goal: 0
```

### 9.3 Dashboard Sharing

**Settings per widget:**
- Public to workspace: ✓
- Allow comments: ✓
- Auto-refresh: Every 5 minutes

---

## 10. Integrations

### 10.1 GitHub Integration

**Setup:**

1. **In Linear:**
   - Settings → Integrations → GitHub
   - Connect GitHub account
   - Select repository: `bl1nk-arcana`

2. **In GitHub:**
   - Install Linear GitHub App
   - Configure per repository

**Features Enabled:**
- Auto-link PRs to Linear issues
- Update Linear status on PR events
- Show Linear issue status in GitHub

**PR Branch Convention:**
```
linear/ABC-123-feature-name    → Issue ABC-123
```

### 10.2 Slack Integration

**Setup:**
- Settings → Integrations → Slack
- Connect workspace
- Configure channels:
  - `#game-bugs` → Bug labels
  - `#game-dev` → All activity

**Notifications:**
```
New issue created → #game-bugs
Issue assigned to you → DM
Issue status changed → Depends on transition
Daily summary → #game-dev
```

### 10.3 Git Integration (CLI)

**Installation:**
```bash
# macOS
brew install linear-team/linear/linear

# Linux
curl -sSL https://get.linear.app | sh
```

**Usage:**
```bash
# Login
linear login

# Create issue
linear issue create --title "Bug in combat" --priority urgent

# Sync with git
git commit -m "fix: ABC-123 combat damage calc"
linear git link --execute
```

---

## 11. Keyboard Shortcuts

### Navigation
| Shortcut | Action |
|----------|--------|
| `G then I` | Go to Inbox |
| `G then D` | Go to Dashboard |
| `G then P` | Go to Project |
| `G then C` | Go to Cycles |
| `Tab` | Next issue |
| `Shift + Tab` | Previous issue |

### Actions
| Shortcut | Action |
|----------|--------|
| `C` | Create issue |
| `E` | Edit issue |
| `S` | Set status |
| `A` | Assign |
| `L` | Add label |
| `D` | Set due date |
| `M` | Set milestone |
| `P` | Set priority |
| `Enter` | Open issue |
| `Esc` | Close modal |

### Command Menu
| Shortcut | Action |
|----------|--------|
| `Cmd/Ctrl + K` | Command menu |
| `Cmd/Ctrl + /` | Show shortcuts |

---

## 12. Mobile App Setup

### iOS/Android Settings

**Notifications:**
- New issues in your projects: ✓
- Assigned to you: ✓
- @mentioned: ✓
- Status changes on your issues: ✓
- Daily digest: ✓ (8:00 AM)

**Defaults:**
- Default view: My Issues
- Quick actions: Create issue, Log time

---

## 13. Team Onboarding Checklist

### New Developer Setup

- [ ] Join Linear workspace
- [ ] Install desktop app
- [ ] Install browser extension
- [ ] Configure notifications
- [ ] Set up GitHub integration
- [ ] Join relevant teams (Engineering)
- [ ] Review issue templates
- [ ] Bookmark important views

### Standard Settings

**Per User:**
1. Profile → Settings → Preferences:
   - Theme: System/Light/Dark
   - Keyboard shortcuts: Default
   - Notification schedule: Do not disturb 10 PM - 8 AM

2. Notifications → Customize:
   - All notifications: Slack
   - Daily digest: Email (optional)

---

## 14. Best Practices

### Issue Creation
1. Use templates เสมอ
2. Include reproduction steps สำหรับ bugs
3. Link to PRD/spec section
4. Add relevant labels
5. Set proper priority

### Workflow
1. Issues start in Triage
2. Confirm before moving to Todo
3. Avoid skipping In Review
4. Close with action taken noted

### Communication
1. Use Linear for technical discussions
2. Keep comments focused
3. Use @mentions sparingly
4. Update status proactively

---

## 15. Troubleshooting

### Common Issues

**Issue: Can't see all projects**
→ Check team membership in Settings → Teams

**Issue: Notifications not working**
→ Check notification settings per issue + global settings

**Issue: GitHub integration not linking**
→ Verify GitHub app permissions on repository

**Issue: Custom workflow not applying**
→ Check team settings → Workflow

---

## 16. Quick Reference

### Linear Issue URL Format
```
https://linear.app/bl1nk-arcana/issue/ABC-123/issue-title
```

### Issue ID Format
```
ABC-123
├── ABC = Project prefix
└── 123 = Sequential number
```

### API Usage (for automation)
```bash
# Get API key
# Settings → API → Create key

# API base URL
https://api.linear.app/graphql

# Example query
curl -X POST \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"query": "{ issues { nodes { id title state { name } } } }"}' \
  https://api.linear.app/graphql
```
