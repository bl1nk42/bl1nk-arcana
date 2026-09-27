# ClickUp Setup Guide - Blink Arcana

## Overview
ClickUp สำหรับจัดการ Features, Sprints และ Planning สำหรับทีมพัฒนาเกม

---

## 1. Space Structure

### สร้าง Space ใหม่
1. คลิก **"+"** ข้าง Spaces
2. ตั้งชื่อ: `Blink Arcana`
3. เลือก **Team Space** (สำหรับทีม)
4. Color: เลือกสีที่ตรงกับแบรนด์เกม

### Folder Structure ภายใน Space

```
Blink Arcana/
├── 🎮 Game Features/
│   ├── Core Combat System/
│   ├── Class & Element System/
│   ├── Party Management/
│   ├── Terrain System/
│   ├── Skill System/
│   └── Equipment System/
├── 🛠️ Infrastructure/
│   ├── Godot Setup/
│   ├── Rust Core/
│   ├── Protocol Buffers/
│   ├── CI/CD & Buildkite/
│   └── DevOps/
├── 🐛 Bug Tracking/          ← Sync กับ Linear
├── 💡 Ideas & Feedback/
└── 📋 Templates/
```

---

## 2. List Configuration

### 2.1 Core Combat System List

**Location:** `Game Features/Core Combat System/`

**List Name:** `Core Combat`

**Custom Fields ที่ต้องสร้าง:**

| Field Name | Type | Options |
|------------|------|---------|
| Type | Dropdown | Feature, Sub-task, Spike, Research |
| Priority | Dropdown | Critical, High, Medium, Low |
| Status | Status | Backlog → In Progress → In Review → Done |
| Points | Number | 1, 2, 3, 5, 8, 13 |
| Sprint | Dropdown | Sprint 1, Sprint 2, ... |
| Epic | Dropdown | Combat, UI, AI, Backend |
| Dependencies | Text | ระบุ task ที่ต้องทำก่อน |
| Godot Scene | Text | e.g., `res://scenes/combat/BattleScene.tscn` |
| Rust Module | Text | e.g., `combat::turn_manager` |
| Test Status | Dropdown | Not Tested, Partial, Full Coverage |

**Task Templates:**

```markdown
## Task Template: Feature

**Title:** [Feature Name]
**Epic:** [Parent Epic]
**Description:**
- Context: (ทำไมต้องมี feature นี้)
- Requirements: (รายละเอียดจาก PRD)
- Acceptance Criteria: (Definition of Done)
- Technical Notes: (Design decisions)

**Sub-tasks:**
- [ ] Godot Scene/Script implementation
- [ ] Rust Core implementation (ถ้ามี)
- [ ] Protocol Buffer schema update (ถ้ามี)
- [ ] Unit tests
- [ ] Integration test
- [ ] Documentation

**Linked Linear Issues:** (Issue IDs จาก Linear)
```

### 2.2 Sprint Planning List

**Location:** `Blink Arcana/`

**List Name:** `Sprint Backlog`

**View:** Timeline (Gantt)

**Custom Fields:**

| Field Name | Type |
|------------|------|
| Sprint | Dropdown (Dynamic) |
| Assignee | Team Member |
| Due Date | Date |
| Status | Status Group |

---

## 3. Views Setup

### 3.1 Sprint Board View

**Location:** `Sprint Backlog/`

**View Type:** Board

**Columns (Status):**
```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│  Backlog    │ In Progress │ In Review   │    Done     │
├─────────────┼─────────────┼─────────────┼─────────────┤
│             │             │             │             │
│  [Card]     │  [Card]     │  [Card]     │  [Card]     │
│             │             │             │             │
│  [Card]     │  [Card]     │             │  [Card]     │
│             │             │             │             │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

**Settings:**
- Group by: Status
- Swimlanes: Assignee
- Card color: Priority
- Show subtasks: ✓

### 3.2 My Tasks View

**Location:** `Blink Arcana/` (Space-level)

**View Type:** List

**Filter:**
```
Assignee = [Current User]
AND Status not in [Done, Cancelled]
```

**Sort by:** Due Date → Priority

### 3.3 Timeline View (Sprint Planning)

**Location:** `Sprint Backlog/`

**View Type:** Timeline (Gantt)

**Settings:**
- Start Date: Start Date field
- End Date: Due Date field
- Height: 50px per task
- Show dependencies: ✓
- Show progress: ✓

### 3.4 Godot Scene Inventory View

**Location:** `Game Features/` (Folder-level)

**View Type:** Table

**Columns:**
- Task Name
- Godot Scene
- Rust Module
- Status
- Assignee

**Filter:**
```
Godot Scene is not empty
```

### 3.5 Saved Views

สร้าง views ที่ใช้บ่อย:

| View Name | Filter | Location |
|-----------|--------|----------|
| Current Sprint | Sprint = Current Sprint | Space-wide |
| Blocked Tasks | Dependencies contains [blocked] | Space-wide |
| High Priority | Priority = Critical or High | Space-wide |
| Unassigned | Assignee is empty | Space-wide |
| This Week | Due Date ≤ 7 days | Space-wide |

---

## 4. Dashboard Setup

### 4.1 Sprint Dashboard

**Location:** `Blink Arcana/Dashboards/`

**Dashboard Name:** `Sprint Dashboard`

**Widgets:**

#### Widget 1: Sprint Progress (Pie Chart)
```
Type: Pie Chart
Source: Sprint Backlog List
Data: Status breakdown
Filter: Sprint = Current Sprint
```

#### Widget 2: Velocity Chart (Line Chart)
```
Type: Line Chart
Source: Sprint Backlog List
Data: Points completed over sprints
X-Axis: Sprint
Y-Axis: Points
Time Range: Last 6 sprints
```

#### Widget 3: Sprint Burndown (Chart)
```
Type: Chart
Source: Sprint Backlog List
Data: Remaining work vs time
Chart Type: Burndown
Filter: Sprint = Current Sprint
```

#### Widget 4: Tasks by Priority (Bar Chart)
```
Type: Bar Chart
Source: All Tasks
Data: Count by Priority
Group by: Priority
Filter: Status not in [Done, Cancelled]
```

#### Widget 5: Recent Activity (List)
```
Type: List
Source: All Tasks
Display: Last 10 updated tasks
Show: Task name, Status, Assignee
```

#### Widget 6: My Tasks Summary (Number)
```
Type: Number
Source: My Tasks View
Data: Total open tasks
Filter: Assignee = Me
```

#### Widget 7: Sprint Goal Progress (Text/Checklist)
```
Type: Custom
Content: Sprint Goals checklist
```

### 4.2 Release Dashboard

**Location:** `Blink Arcana/Dashboards/`

**Dashboard Name:** `Release Tracker`

**Widgets:**

#### Widget 1: Feature Completion (Progress Bar)
```
Type: Progress
Source: Game Features folder
Data: Completed vs Total features
Filter: Status = Done
```

#### Widget 2: Milestone Progress (Timeline)
```
Type: Timeline
Source: Milestones
Data: Milestone dates and completion %
```

#### Widget 3: Blocker Summary (Table)
```
Type: Table
Source: All Tasks
Display: Blocked tasks with details
Filter: Dependencies contains [blocked]
```

---

## 5. Automations

### 5.1 Sprint Automations

**Automation 1: Auto-assign to Sprint**
```
Trigger: Task moved to "In Progress"
Action: Set Sprint field to current sprint
```

**Automation 2: Auto-update Status**
```
Trigger: Sub-tasks all completed
Action: Update parent status to "In Review"
```

**Automation 3: Due Date Reminder**
```
Trigger: 2 days before due date
Action: Send notification to Assignee
```

**Automation 4: Auto-close Completed**
```
Trigger: Task in "Done" for 3 days
Action: Add "Archive" tag
```

### 5.2 Status Transition Rules

```
Backlog → In Progress: Requires Estimate (Points > 0)
In Progress → In Review: Requires Sub-tasks complete
In Review → Done: Requires Approval checkbox = true
Done → In Progress: Requires "Reopen" tag
```

---

## 6. Integrations

### 6.1 GitHub Integration

**Setup:**
1. Go to: Settings → Integrations → GitHub
2. Connect repository: `your-org/bl1nk-arcana`
3. Enable:
   - Auto-assign PRs to tasks
   - Update task status on PR merge
   - Show PR status on tasks

**Branch Naming Convention:**
```
features/feature-name      → Feature task
bugfix/linear-issue-id    → Bug task
hotfix/issue-id           → Urgent fix
```

### 6.2 Linear Sync (Bug Tracking)

**Setup (via Zapier/Make):**
1. Trigger: Linear Issue created
2. Action: Create ClickUp task in Bug Tracking list

**Field Mapping:**
| Linear | ClickUp |
|--------|---------|
| Title | Task Name |
| Description | Description |
| Priority | Priority |
| Assignee | Assignee |
| Labels | Epic |

---

## 7. Folder Permissions

### Team Members Access

| Folder | Developer | Designer | PM |
|--------|----------|----------|-----|
| Game Features | Edit | View | Edit |
| Infrastructure | Edit | View | View |
| Bug Tracking | Edit | View | Edit |
| Ideas & Feedback | View | Edit | Edit |
| Templates | Edit | Edit | Edit |
| Dashboards | Edit | View | Edit |

---

## 8. Quick Start Checklist

### Day 1 Setup
- [ ] Create Space `Blink Arcana`
- [ ] Create Folder structure
- [ ] Setup custom fields (Type, Priority, Points, Epic)
- [ ] Create Sprint Backlog list
- [ ] Create first sprint view (Board)
- [ ] Setup dashboard with widgets
- [ ] Connect GitHub integration
- [ ] Create task templates
- [ ] Invite team members
- [ ] Setup notifications

### Weekly Maintenance
- [ ] Update sprint board
- [ ] Review backlog priorities
- [ ] Check blocked tasks
- [ ] Update dashboard widgets
- [ ] Archive completed tasks

---

## 9. Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `C` | Create task |
| `F` | Quick filter |
| `G` | Go to view |
| `,` | Open settings |
| `?` | Show all shortcuts |
| `/` | Command bar |

---

## 10. Mobile App Setup

**Recommended Settings:**
- Enable notifications for: Assigned to me, Mentions, Due soon
- Default view: My Tasks
- Quick actions: Create task, Log time
