# Common Rules for Blink Arcana

## Before Any Implementation

1. **Check PRD first** — Use `/prd check <feature>` to verify feature exists in PDR.md
2. **Read Spec Sheet** — Use `/spec <feature>` to read or create spec
3. **Confirm understanding** — Use `/understand <feature>` before coding
4. **No unauthorized features** — If not in PRD, ask user first

## Change Control

- All feature changes require **Change Request** (`/change <details>`)
- CR must include: Current state, Proposed change, Reason, Impact Analysis, Approval, Rollback Plan
- No direct implementation without approval

## Quality Gates (must pass before commit)

```bash
just fmt      # Format all code
just lint     # Lint all code (Clippy, gdlint, typos, etc.)
just quality  # All quality gates
just precommit # Pre-commit checks
```

## Banned Terms (from GLOSSARY.md)

| Banned | Use Instead |
|--------|-------------|
| Card (generic) | Unit Display / Party Slot |
| Deck | Party / Unit Roster |
| Hand | Party Slots |

## Documentation Standards

- All comments in **Thai language**
- Explain **WHY** not **WHAT**
- TODO comments must include Task ID: `// TODO(TASK-123): ...`
- Update docs/CHANGELOG.md on every feature change

## Code Style

- Rust: Edition 2024, no `unwrap()` in production
- GDScript: Type hints required, early return pattern
- Conventional Commits: `feat/fix/docs/style/refactor/perf/test/build/ci/chore/revert`

## Workflow

1. `/standup` — Daily tasks & blockers
2. `/spec` + `/understand` — Read spec, confirm
3. Code → `just fmt` → `just lint` → `just quality`
4. Commit (Conventional) + Push
5. Update ClickUp + Linear + docs

## Before Commit Checklist

- [ ] อ่าน `.claude/rules/common.md` + `godot.md` + `rust.md` + `comment.md` ครบ
- [ ] อ่าน PDR.md (อย่างน้อย §6.1 Daily Workflow + §7.1 Team + §4.2 Change Control)
- [ ] ถามตัวเองก่อนแก้ section ที่ไม่ได้ถูกสั่ง: ผู้ใช้ขอไหม? ผู้ใช้ต้องการไหม? ผู้ใช้จะขอบคุณไหม?
- [ ] ถ้าข้อใดข้างบน "ไม่มี" → ถาม user 1 บรรทัด ไม่ทำเอง ไม่ assume
- [ ] ทุก commit ต้อง update `docs/CHANGELOG.md` (§38)
- [ ] CHANGELOG entry ห้ามใช้ "user-approved" เพราะ AI อื่นอ่านจะ assume scope ทั้งหมด approved ใช้ "lesson learned" / "scope note" แทน
