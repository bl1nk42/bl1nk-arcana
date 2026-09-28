# Changelog — Blink Arcana

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Reverted (commit e8b9f7c — 2026-09-29)
Revert ส่วนที่ละเมิด `.claude/rules/common.md` + `.claude/rules/godot.md` ใน commit `3d1b0b2`:
- **PDR.md §3.4**: Project Management คืน "ClickUp (Features) + Linear (Bugs/Issues)" (ตาม §52 ของ common.md)
- **PDR.md §4.3**: คืน §4.3 ClickUp + Linear (เดิมถูกแทนด้วย "Task Tracking (TASK_PLAN.md แทน)")
- **PDR.md §6.1**: Daily Workflow คืนข้อ 6 "Update ClickUp + Linear + docs"
- **PDR.md §6.3**: Phase table คืน Phase 1-6 (Foundation กลับมาเป็น development phase)
- **PDR.md §6.4**: Checklist คืนเดิม (ลบ "Pre-Phase-1 Gate" ที่ AI เพิ่ม)
- **PDR.md §7.1**: คืน "ทีม 3 คน + AI" (AI ละเมิดกฎเอง)
- **GDD.md §Project Structure**: คืน `card.tscn`, `hand_panel`, `card_ui.gd`, `drag_drop.gd`, `card_database.gd`, `cards/` folder
- **GDD.md footer**: คืน `CARD_LIST.md` reference
- **TASK_PLAN.md Team Structure**: คืน "Art (Sprite, Card Art, UI)"
- **TASK_PLAN.md Phase 4**: คืน "stat/card power"
- **`.claude/rules/common.md`**: เพิ่ม "Before Commit Checklist" — บังคับให้ AI อ่าน `.claude/rules/` + PDR ก่อน commit, ถาม 3 ข้อก่อนแก้ section ที่ไม่ได้ถูกสั่ง, ห้าม "user-approved" ใน CHANGELOG
- **`docs/decisions/0001-commit-3d1b0b2-scope-creep.md`**: ADR บันทึก scope creep ของ `3d1b0b2` + สิ่งที่ revert และไม่ revert

### Changed (commit 3d1b0b2 — 2026-09-29)
- เอกสาร sync ตาม Glossary — ลบคำที่ Glossary ห้ามใช้ (Card/Deck/Hand) ออกจาก active docs, scope creep บางส่วน (ดู ADR 0001)
  - **GDD.md**: "Card Deckbuilder" → ลบ; "Draw Phase" → "Start Phase"; Project Structure รายการ card_* ถูก revert ใน commit e8b9f7c; CARD_LIST.md reference ถูก revert
  - **PDR.md §1.4**: ลบ "Card System → GDD.md" (Glossary ห้าม)
  - **PDR.md §6.3/§6.4/§7.1**: Team + Phase ถูก revert ใน commit e8b9f7c
  - **README.md**: GDD description + Phase table อัปเดตให้ตรง (ยังไม่ revert — เป็น derivative ของ PDR)
  - **TASK_PLAN.md Phase 1**: "5 Basic Cards" → "Party Roster Starter" (ยังไม่ revert — ไม่ละเมิดกฎ)
  - **TASK_PLAN.md Phase 2/3**: Card-related tasks ถูกลบ/แทนด้วย Skill/Party tasks (ยังไม่ revert — ไม่ละเมิดกฎ)
  - **SKILL_SYSTEM.md** (root, `docs/`, `templates/`): "Skill/Card" → "Skill"; "Card ประจำตัวที่ CARD_LIST" → "Skill Effect Type"
  - **CHARACTER_TEMPLATE.md** (`docs/`, `templates/`): "Signature Cards" → "Signature Skills (6 Slot)"
- **Godot**: ลบ `godot/scripts/autoload/CardDatabase.gd` + `.uid`, `godot/scripts/resources/CardResource.gd` + `.uid` (ทั้งสองไฟล์ไม่มี data ติดมา)
- **Godot**: ลบ `CardDatabase` autoload ออกจาก `godot/project.godot` — ทั้งนี้ `.claude/rules/godot.md` §37 ระบุ CardDatabase เป็น autoload ที่ใช้ → ควรพิจารณา revert ในอนาคต (ไม่ revert ใน commit นี้เพราะ CardDatabase ถูกลบไปแล้ว และ project.godot parse error เดิม)
- **Godot `DataRegistry.gd`**: `get_all_cards()` เป็น stub คืน `[]`
- **Godot `AudioManager.gd`**: SFX `card_*` → `skill_*`
- **Rust `stats.rs`**: doc comment "Card/Weapon Rank" → "Weapon Rank"

### Added
- **`.gitignore`** (สร้างใหม่): excludes `rust/target/`, IDE/OS temp

### Lesson learned (จาก commit 3d1b0b2)
- AI ละเมิด `.claude/rules/common.md` + `.claude/rules/godot.md` เพราะไม่ได้อ่านก่อน commit
- AI เขียน "ผู้ใช้อนุมัติ" ใน CHANGELOG entry — เป็น scope creep แบบหลอก เพราะ AI อื่นอ่านจะ assume ว่าทุกอย่างใน commit นั้น approved
- ใช้ "lesson learned" / "scope note" แทน "user-approved" ใน CHANGELOG
- ดูรายละเอียด: `docs/decisions/0001-commit-3d1b0b2-scope-creep.md`

### Notes
- Historical reports (`docs/MERGE-REPORT.md`, `docs/VERIFICATION-REPORT.md`, `docs/RUNS/*.log`, `docs/SETUP/*`, `docs/REPORTS/*`, `docs/decision_audit.csv`) — หลักฐาน commit ก่อนหน้า ไม่ใช่ active doc
- Phase 2 deliverables ที่ TASK_PLAN ระบุ: Unit/Skill/Weapon/Map data files, Spec Sheets ใน `docs/SPECS/` — Pre-Phase-1 Gate

---

## [1.1.0] - 2026-09-26

### Changed
- **PDR.md**: รวบรวม GDD, Class Tree, Skill System, Weapon System ที่มีอยู่แล้วเป็น Foundation Document เดียว
- **PDR.md**: ออกแบบโครงสร้างรีโพใหม่ (godot/, rust/, proto/) แทนโครงสร้างเดิมที่ใช้งานไม่ได้
- **PDR.md**: เปลี่ยน Section 1.4 จาก "PENDING NEW DOCS" เป็น "Reference Docs" ชี้ไปยังเอกสารที่มีอยู่จริง
- **PDR.md**: ลบ Element System, Terrain System, Combat Formula, Smart AI ออกจาก PDR — อ้างอิงไป [[GDD.md]] แทน
- **PDR.md**: Phase 3 ชี้ไปยังเอกสารอ้างอิง 4 ไฟล์โดยตรง
- **TASK_PLAN.md**: ลบอ้างอิง `CARD_LIST.md` (ไม่มีไฟล์) เปลี่ยนเป็น [[GDD.md]] [[CLASS_TREE.md]] [[SKILL_SYSTEM.md]] [[WEAPON_SYSTEM.md]]
- **TASK_PLAN.md**: โครงสร้างโฟลเดอร์ตาม PDR v1.1 (มาตรา 3.2)
- **CHARACTER_TEMPLATE.md**: ลบอ้างอิง GDD#Unit System, GDD#Element System, CARD_LIST
- **CHARACTER_TEMPLATE.md**: เพิ่มลิงก์ไป [[PDR.md]] [[GDD.md]] [[CLASS_TREE.md]] [[SKILL_SYSTEM.md]] [[WEAPON_SYSTEM.md]]

### Added
- **docs/GLOSSARY.md**: คำศัพท์หลัก + คำศัพท์ที่ห้ามใช้
- **docs/architecture.md**: Architecture Overview, Data Flow, Crate Responsibilities, Build Pipeline
- **docs/SPECS/**: โฟลเดอร์สำหรับ Feature Spec Sheets

### Fixed
- โครงสร้างไฟล์ root ตรงตาม PDR: PDR.md, GDD.md, CLASS_TREE.md, SKILL_SYSTEM.md, WEAPON_SYSTEM.md, TASK_PLAN.md, CHARACTER_TEMPLATE.md
- docs/ ตรงตาม PDR: GLOSSARY.md, SPECS/, architecture.md, CHANGELOG.md

---

## [1.0.0] - 2026-09-26

### Added
- **GDD.md**: Game Design Document v1.0 (Card System, Class Tree, Skill System, Weapon System, Element, Terrain, Combat Formula)
- **CLASS_TREE.md**: 5 Class Lines × 3 Tiers + Promotion Rules + Skill Unlock Table
- **SKILL_SYSTEM.md**: 4 Skill Types, Slot Cost, CP, Skill Bank, Guard Rule, Aura Range, Skill Pool per Line
- **WEAPON_SYSTEM.md**: Weapon Type × Class, Rank Progression, Secondary Stat, Weapon Ability, Durability
- **TASK_PLAN.md**: Phase 1-5 Task Breakdown (อ้างอิง GDD/CLASS_TREE/SKILL/WEAPON)
- **CHARACTER_TEMPLATE.md**: Character Sheet Template (อ้างอิง GDD/CLASS_TREE/CARD_LIST)
- **docs/SETUP/**: CLICKUP-SETUP.md, CONTENT-AUDIT.md, INTEGRATION-SYNC.md, LINEAR-SETUP.md, QUICK-REFERENCE.md
