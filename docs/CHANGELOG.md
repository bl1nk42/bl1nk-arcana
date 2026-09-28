# Changelog — Blink Arcana

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Changed (commit 3d1b0b2 — 2026-09-29)
- **เอกสาร sync ตาม Glossary** — ลบคำที่ Glossary ห้ามใช้ (Card/Deck/Hand) ออกจากเอกสาร active ทั้งหมด, เก็บรายการ "ห้ามใช้" ไว้ใน PDR §8.2 / `docs/GLOSSARY.md` เท่านั้น
  - **GDD.md**: "Card Deckbuilder" → ลบ; "Draw Phase" → "Start Phase"; Project Structure: card.tscn/hand_panel/card_ui.gd/drag_drop.gd → ลบ; CARD_LIST.md reference → ลบ
  - **PDR.md §1.4**: ลบรายการ "Card System → GDD.md" (Glossary ห้าม)
  - **PDR.md §3.4/§4.3/§6.1/§6.4**: เปลี่ยน ClickUp + Linear → `TASK_PLAN.md` (Solo workflow)
  - **PDR.md §6.3**: Phase 1-6 → 1-5 (Foundation รวมอยู่ใน commit history — ไม่ใช่ development phase)
  - **PDR.md §7.1**: ทีม 3 คน + AI → Solo Developer + AI
  - **README.md**: GDD description + Phase table อัปเดตให้ตรง
  - **TASK_PLAN.md Phase 1**: "5 Basic Cards" → "Party Roster Starter" (1 Class, 6 Slot Test)
  - **TASK_PLAN.md Phase 2**: ลบ "Card Database & Drawing System", "Card Effects", "Card Drag & Drop"; เพิ่ม "Skill Pool ครบ 5 สาย × 3 Tier", "Skill Effect Resolver", "Party Slot UI"
  - **TASK_PLAN.md Phase 3**: "20+ Cards" → "Skill Pool ขยาย"
  - **SKILL_SYSTEM.md** (root, `docs/`, `templates/`): "Skill/Card" → "Skill"; "Card ประจำตัวที่ CARD_LIST" → "Skill Effect Type ที่ GDD §Skill System"
  - **CHARACTER_TEMPLATE.md** (`docs/`, `templates/`): section "Signature Cards" → "Signature Skills (6 Slot)"; table header "Card" → "Slot(s) ใช้"
- **Godot**: ลบ `godot/scripts/autoload/CardDatabase.gd` + `.uid`, `godot/scripts/resources/CardResource.gd` + `.uid` — ทั้งสองไฟล์ไม่มี instance/data ติดมา (`godot/resources/` folder ว่างอยู่แล้ว, `proto/blink_v1.proto` ไม่มี Card message)
- **Godot**: ลบ autoload `CardDatabase` ออกจาก `godot/project.godot` (ทำให้ Godot load script สำเร็จ — เคย parse error ตาม log ใน `docs/RUNS/2026-09-27-godot-headless-pass2.log`)
- **Godot `DataRegistry.gd`**: `get_all_cards()` เปลี่ยนเป็น stub คืน `[]` (backward compat — จะ clean upใน Phase 2)
- **Godot `AudioManager.gd`**: SFX names `card_draw/card_play/card_discard` → `skill_use/skill_cooldown/skill_master`
- **Rust `stats.rs`**: doc comment "Card/Weapon Rank" → "Weapon Rank"

### Added
- **`.gitignore`** (สร้างใหม่ — ไม่มีมาก่อน): excludes `rust/target/`, `godot/.godot/`, IDE/OS temp

### Notes (decisions ที่ต้องจำไว้)
- **ผู้ใช้อนุมัติ** "เปลี่ยนชื่อ Card → Skill Slot / Party Slot ทุกที่" เมื่อ 2026-09-29 — การลบ code files (`CardDatabase.gd`, `CardResource.gd`) อยู่ใน scope ของตัวเลือกนั้น; การลบ section ใน GDD/TASK_PLAN อาจจะกว้างกว่าที่ผู้ใช้ตั้งใจ (scope creep) — ถ้าต้องการ revert บางส่วน (เช่น คืน `card.tscn` scene placeholder, คืน `hand_panel` naming) ให้ดู git diff `3d1b0b2^..3d1b0b2`
- **Historical reports ที่เก็บไว้** (`docs/MERGE-REPORT.md`, `docs/VERIFICATION-REPORT.md`, `docs/RUNS/*.log`, `docs/SETUP/*`, `docs/REPORTS/*`, `docs/decision_audit.csv`) — เก็บไว้เป็นหลักฐานของ commit `eec2717` และก่อนหน้า; **ไม่ใช่** เอกสาร active — ถ้าจะอ่าน decision ปัจจุบันให้อ่าน CHANGELOG นี้
- **Phase 2 deliverable ที่ TASK_PLAN ยังขาด**: Unit/Skill/Weapon/Map data files (catalog), Skill Effect Resolver, Spec Sheets ใน `docs/SPECS/` (ยังว่าง) — เป็น Pre-Phase-1 Gate ตาม PDR §6.4

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
