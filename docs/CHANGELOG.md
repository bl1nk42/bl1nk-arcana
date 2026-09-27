# Changelog — Blink Arcana

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
