# Quick Reference Card - Blink Arcana Project Management

## Tool Responsibilities

```
┌────────────────────────────────────────────────────────────────────┐
│                         TOOL SELECTION                              │
├──────────────────────┬─────────────────────────────────────────────┤
│       CLICKUP        │                  LINEAR                    │
├──────────────────────┼─────────────────────────────────────────────┤
│ • Feature planning   │ • Bug reports                               │
│ • Sprint planning    │ • Technical issues                          │
│ • Milestones        │ • Tech debt tracking                        │
│ • Team capacity     │ • Code-level tasks                          │
│ • Stakeholder view  │ • Developer view                            │
│ • High-level overview│ • Detailed tracking                        │
└──────────────────────┴─────────────────────────────────────────────┘
```

---

## ClickUp Quick Commands

| Task | Action |
|------|--------|
| Create feature | `C` → Select list → Fill template |
| Assign to sprint | Open task → Sprint dropdown |
| Add points | Open task → Points field |
| Link Linear | Add "Linear: ABC-123" in description |
| Filter my tasks | `F` → `assignee:me` |

### Folder Structure
```
Blink Arcana/
├── 🎮 Game Features/      # Features & sub-tasks
├── 🛠️ Infrastructure/     # DevOps, tooling
├── 🐛 Bug Tracking/       # (Sync with Linear)
├── 💡 Ideas & Feedback/  # New ideas
└── 📋 Templates/         # Reusable templates
```

---

## Linear Quick Commands

| Task | Action |
|------|--------|
| Create issue | `C` → Select template |
| Link ClickUp | Add "ClickUp: CUP-123" in description |
| Move status | `S` → Select state |
| Assign | `A` → Select member |
| Set priority | `P` → Select priority |
| Add label | `L` → Type label name |

### Issue Labels
```javascript
// By Type
🐛 bug          ✨ feature-request
💳 tech-debt    ⚡ performance

// By System
🦀 rust-core    🎮 godot    📡 proto

// By Priority
🔴 critical    🟠 high-priority
```

### Workflow States
```
Triage → Confirmed → Todo → In Progress → In Review → Done
  ↓                                              ↓
Cancelled ←───────────────────────────────────── Cancelled
```

---

## GitHub Integration

### Branch Naming
```bash
# Feature (linked to ClickUp)
feature/feature-name

# Bug fix (linked to Linear)
linear/ABC-123-bug-description

# Hotfix
hotfix/ABC-456-fix-description
```

### PR Title Convention
```bash
feat: ABC-123 add combat system      # Feature
fix: ABC-123 fix damage calculation  # Bug fix
refactor: ABC-123 optimize pathfinding # Refactor
```

### Auto-linking
- Linear GitHub App auto-links PRs with issue ID in title
- Example: `fix: ABC-123` → Auto-links to ABC-123

---

## Sprint Workflow

### Sprint Cycle (2 weeks)
```
Day 1:    Sprint Planning (ClickUp)
Days 2-4: Development (Linear for issues)
Day 5:    Mid-Sprint Review
Days 6-8: Continue Development
Day 9:    Sprint Testing
Day 10:   Sprint Review + Retrospective
```

### Daily Loop
```
1. Check Linear: Your assigned issues
2. Check ClickUp: Sprint progress
3. Create branch with Linear ID
4. Development
5. Open PR → Auto-links Linear
6. Move Linear to "In Review"
7. On merge → Move to "Done"
8. Update ClickUp task status
```

---

## Cross-Tool Linking

### In ClickUp Task Description
```markdown
## Linear Issues
- ABC-123: Combat damage bug
- ABC-456: Performance issue

## Related PRs
- #45: Combat system implementation
```

### In Linear Issue Description
```markdown
## ClickUp Parent
[CUP-123: Combat System Feature](https://app.clickup.com/t/CUP-123)

## Related PRs
#45: Combat system implementation
```

---

## Key Metrics

### From ClickUp
- Sprint velocity (points completed)
- Tasks by status
- Team capacity utilization

### From Linear
- Issues created vs closed
- Bug resolution time
- Tech debt addressed

### From GitHub
- PRs merged
- Code review time
- Build success rate

---

## Contacts

| Role | ClickUp | Linear |
|------|---------|--------|
| Admin | Contact admin | Contact admin |
| Bug reports | Use Linear | ABC-123 |
| Feature requests | ClickUp feature | Linear (with feature label) |

---

## Documentation

| Document | Location |
|----------|----------|
| Full ClickUp Guide | `docs/SETUP/CLICKUP-SETUP.md` |
| Full Linear Guide | `docs/SETUP/LINEAR-SETUP.md` |
| Integration Guide | `docs/SETUP/INTEGRATION-SYNC.md` |
| Bi-weekly Summary | `docs/SETUP/BIWEEKLY-SUMMARY.md` |
| This Quick Reference | `docs/SETUP/QUICK-REFERENCE.md` |

---

## Important URLs

```
ClickUp:  https://app.clickup.com
Linear:   https://linear.app/bl1nk-arcana
GitHub:   https://github.com/your-org/bl1nk-arcana
```

---

## Emergency Contacts

- **Critical Bug**: Create Linear issue + Priority Urgent + @mention team
- **Blocked Task**: Add `blocked` label in Linear + post in #dev Slack
- **Scope Change**: Update ClickUp + create Linear issue for impact analysis
