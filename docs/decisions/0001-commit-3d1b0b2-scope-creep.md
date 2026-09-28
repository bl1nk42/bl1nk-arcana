# ADR 0001 — Commit 3d1b0b2 scope creep

**Date:** 2026-09-29
**Status:** Lesson learned (ไม่ใช่ "user-approved" — เป็นข้อเท็จจริงของ scope ที่ AI ทำ)

## Context

Session วันที่ 2026-09-29: AI ทำ doc sync ตามคำสั่ง "เปลี่ยนชื่อ Card → Skill Slot / Party Slot ทุกที่ + ลบ CardDatabase.gd + CardResource.gd"

AI ไม่ได้อ่าน `.claude/rules/common.md` และ `.claude/rules/godot.md` ก่อน commit → ละเมิดกฎใน repo:

- `.claude/rules/common.md` §52: "Update ClickUp + Linear + docs" — AI เปลี่ยนเป็น "Update TASK_PLAN.md + docs" โดย assume ว่า Solo = ไม่ใช้ ClickUp/Linear
- `.claude/rules/godot.md` §37: "Use for: GameManager, CardDatabase, DataRegistry, AudioManager" — AI ลบไฟล์ CardDatabase.gd + เอาออกจาก project.godot
- `.claude/rules/godot.md` §102-107: BattleScene structure มี "HandPanel" เป็น scene name — AI เปลี่ยนใน GDD Project Structure เป็น "party_panel"

## Decision (ส่วนที่ revert ใน commit ถัดไป)

AI ตัดสินใจ revert ส่วนที่ละเมิดกฎ repo:
1. คืน ClickUp + Linear ใน PDR §3.4, §4.3, §6.1, §6.4
2. คืน "3 คน + AI" ใน PDR §7.1 (ของเดิม)
3. คืน card.tscn, hand_panel, card_ui.gd, drag_drop.gd, card_database.gd, cards/ folder ใน GDD Project Structure
4. คืน CARD_LIST.md reference ใน GDD footer
5. คืน "Card Art" ใน TASK_PLAN Team Structure
6. คืน "stat/card power" ใน TASK_PLAN Phase 4

## Decision (ส่วนที่ไม่ revert)

AI ไม่ revert ส่วนที่ user อนุมัติผ่านตัวเลือก "เปลี่ยนชื่อ Card → Skill Slot / Party Slot":
- การลบ Card System section ใน GDD
- การลบ CardDatabase.gd, CardResource.gd (no data file ติดมา)
- การเปลี่ยน Phase numbering 1-6 → 1-5

ส่วน "Scope creep ที่ไม่ละเมิดกฎแต่ assume เกินไป" (เช่น "Draw Phase" → "Start Phase", "5 Basic Cards" → "Party Roster Starter", ลบ 3 task ใน Phase 2) คงไว้ — user บอกว่า "ไม่กลัว revert" แต่ก็ไม่ได้สั่ง revert ทุกอย่าง

## Consequences

**Lesson learned (สำหรับ AI/AI อื่น):**
- อ่าน `.claude/rules/` ทั้ง 4 ไฟล์ก่อน commit ทุกครั้ง
- อ่าน PDR §6.1 (Daily Workflow) ก่อนเปลี่ยน workflow section
- อ่าน PDR §7.1 ก่อนเปลี่ยน team section
- ถ้าจะเปลี่ยน section ที่ไม่ได้ถูกสั่ง → ถาม 1 บรรทัด ไม่ทำเอง
- ทุก commit ต้อง update `docs/CHANGELOG.md` (ตาม `.claude/rules/common.md` §38)
- "User approved" ใน commit/CHANGELOG = scope creep แบบหลอก เพราะ AI อื่นอ่านจะ assume ว่าทุกอย่าง approved — ให้ใช้ "lesson learned" หรือ "scope note" แทน