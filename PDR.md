# Blink Arcana — Foundation Document (ฉบับแก้ไข v1.1)

Tactical RPG + Roguelike · Godot 4 + Rust (GDExtension)
เวอร์ชัน: 1.1 · วันที่: 26 กันยายน 2026 · สถานะ: Foundation Document

> **การเปลี่ยนแปลงจาก v1.0:** รวบรวม GDD, Class Tree, Skill System, Weapon System ที่มีอยู่แล้วเป็น Foundation Document เดียว และออกแบบโครงสร้างรีโพใหม่แทนโครงสร้างเดิมที่ใช้งานไม่ได้

---

## 1. ภาพรวมโปรเจกต์

### 1.1 ข้อมูลพื้นฐาน

| รายการ | รายละเอียด |
| --- | --- |
| ชื่อเกม | **Blink Arcana** (bl1nk-arcana) |
| ประเภทเกม | Tactical RPG + Roguelike (Turn-based) |
| แรงบันดาลใจ | Fire Emblem, Slay the Spire, Into the Breach, Final Fantasy Record Keeper |
| Engine | Godot 4.x (GDScript สำหรับ UI/Scene) + Rust (GDExtension สำหรับ Core Logic) |
| Rust | Version 1.98.1 (Edition 2024) |
| แพลตฟอร์มเป้าหมาย | PC (เวอร์ชันแรก) — ขยายได้ในอนาคต |
| โหมดการเล่น | Single-player — รองรับ AI แข่งขันในอนาคต |

### 1.2 วิสัยทัศน์และเป้าหมาย

สร้างเกม Tactical RPG ที่ผสมผสานความลึกของระบบ Class/Element กับความน่าสนใจของ Roguelike โดยเน้นให้ผู้เล่นรู้สึกว่าการตัดสินใจทุกครั้งมีความหมาย

AI ในเกมต้อง "สนุก" ไม่ใช่แค่ "โหด" — ผู้เล่นควรรู้ว่า AI จะทำอะไร (Intention System) และมีโอกาสหาทางตอบได้

**หลักการออกแบบหลัก:** "Ask First, Code Later" — ทุก Feature ต้องผ่าน PRD + Spec Sheet ก่อนเขียนโค้ด

### 1.3 Core Loop (วงจรการเล่นหลัก)

1. **EXPLORE** — เลือกเส้นทางบนแผนที่ (แบบ Slay the Spire)
2. **BATTLE** — ต่อสู้แบบ Tactical บน Grid (แบบ Fire Emblem)
3. **UPGRADE** — อัปเกรด Unit หลังชนะ
4. **LOOP** — เริ่มรอบใหม่หรือจบ Run (Roguelike)

### 1.4 เอกสารอ้างอิงระบบหลัก (Reference Docs)

ระบบต่อไปนี้มีเอกสารรายละเอียดครบอยู่แล้ว ให้อ้างอิงโดยตรง:

- **Class Tree / Promotion** → `CLASS_TREE.md`
- **Skill System** → `SKILL_SYSTEM.md`
- **Weapon System** → `WEAPON_SYSTEM.md`
- **Unit / Stats / Element / Terrain / Combat Formula / Smart AI** → `GDD.md`

> **หมายเหตุ:** เกมนี้ไม่มีระบบ Card/Deck/Hand ตามที่กำหนดใน `docs/GLOSSARY.md` — Action ทั้งหมดของ Unit มาจาก Skill ที่ติดตัว (จำกัดด้วย Slot) ไม่ใช่การจั่วไพ่

---

## 2. ระบบเกมหลัก (Core Game Systems)

### 2.1 Unit System และ Stats ตัวละคร (Unit)

ตัวละคร (Unit) แต่ละตัวมีสถิติพื้นฐานดังนี้:

| Stat | คำอธิบาย | หมายเหตุ |
| --- | --- | --- |
| HP | Health Points — จุดเลือด | ตายเมื่อ HP = 0 |
| ATK | Attack Power — พลังโจมตี | ใช้กับ Physical Damage |
| DEF | Defense — ลดความเสียหายกายภาพ | Damage = ATK - (DEF/2) |
| INT | Intelligence — พลังเวทย์/รักษา | ใช้กับ Magic Damage + Heal |
| SPD | Speed — ความเร็ว | ส่งผลต่อการหลบหลีก |
| MOV | Movement — จำนวนช่องที่เดินได้ | หักลบด้วย Terrain/Armor |
| RNG | Range — ระยะโจมตี (ช่อง) | 1 = ติดกัน, 2+ = ระยะไกล |
| RES | Resistance — ความต้านทานเวทย์ | Magic Damage = INT - (RES/2) |

### 2.2 Element System — 5 ธาตุ + Neutral

> ดูตาราง Effectiveness เต็มและกติกาการเปลี่ยน Element ที่ [[GDD.md]]

### 2.3 Terrain System — ภูมิประเทศในแมพ

> ดูตาราง Terrain และผลต่อ DEF/AVO/MOV/พิเศษ ที่ [[GDD.md]]

### 2.4 สูตรการต่อสู้ (Combat Formula) — Base Formula

```
Physical Damage = ATK - (DEF / 2) × Element Multiplier (เสมอกัน = 1)
Magic Damage = INT - (RES / 2) × Element Multiplier (เสมอกัน = 1)
AVO (Avoid) = (SPD × 2) + Terrain Bonus (Cap 100%)
Hit Chance = 100 - AVO (Clamp 5%-95%)
Heal Amount = INT × 0.5 (สูงสุดเท่ากับ Max HP)
```

| Bonus จาก Weapon Rank/Skill/Aura/Class ดูในเอกสารอ้างอิง: [[GDD.md]] [[CLASS_TREE.md]] [[SKILL_SYSTEM.md]] [[WEAPON_SYSTEM.md]]

### 2.5 Smart AI System

> ดูรายละเอียด Intention System, AI Personality, Adaptive Difficulty, Rewind System ที่ [[GDD.md]] (Smart AI System section)

---

## 3. สถาปัตยกรรมเทคนิค

### 3.1 Hybrid Architecture — Godot + Rust

| Godot 4 (GDScript) — UI Layer | Rust (GDExtension) — Core Engine Layer |
| --- | --- |
| UI Layer, Scene Management, Animation, Input Handling, Unit Display | Combat, AI, Pathfinding, Stats, Data Structures |
| Scene files (.tscn), Scripts (.gd), Resources (.tres), Autoload Managers | combat.rs, ai.rs, pathfinding.rs, stats.rs, data.rs, error.rs |

**กฎสำคัญ:** ห้ามใช้ `unwrap()` ใน Production Code — ใช้ `?` operator, `unwrap_or()`, `if let`, หรือ `match` แทน จัดการข้อผิดพลาดด้วย `thiserror` และกำหนด Error Type ที่ชัดเจน

### 3.2 โครงสร้างรีโพใหม่ (แทนโครงสร้างเดิมที่พัง)

หลักการออกแบบ: แยก Godot project กับ Rust workspace ออกจากกันชัดเจน คอมไพล์ Rust แล้วคัดลอกไลบรารีเข้า `godot/addons/` อัตโนมัติด้วย `just build` ไม่ปนไฟล์ build กับ source

```text
blink-arcana/
├── godot/ # Godot 4 project root (เปิด Editor ที่นี่)
│   ├── project.godot
│   ├── addons/
│   │   └── blink_core/ # GDExtension .so/.dylib/.dll ถูก copy มาที่นี่โดย just build
│   │   ├── blink_core.gdextension
│   │   └── bin/
│   ├── assets/
│   │   ├── sprites/ # Unit, Enemy, Tileset
│   │   ├── ui/ # HUD, Menu, Icon
│   │   ├── maps/ # Map data และ Tilemap scene
│   │   └── fonts/
│   ├── scenes/
│   │   ├── units/ # Scene ของ Unit แต่ละแบบ
│   │   ├── battle/ # Battle scene, Grid, Cursor
│   │   ├── ui/ # HUD, Party screen, Menu
│   │   └── autoload/ # GameManager, Database (singleton scenes)
│   ├── scripts/
│   │   ├── autoload/ # Global managers (.gd)
│   │   ├── battle/ # Battle UI logic, input handling
│   │   └── ui/ # UI scripts
│   └── resources/ # .tres — Unit data, Item data, Terrain data
├── rust/ # Rust workspace
│   ├── Cargo.toml # [workspace] members = ["crates/*"]
│   ├── crates/
│   │   ├── blink-core/ # Logic ล้วน: combat, stats, pathfinding (ไม่ผูก Godot)
│   │   │   └── src/
│   │   │   ├── combat.rs
│   │   │   ├── ai/
│   │   │   │   ├── mod.rs
│   │   │   │   ├── intention.rs
│   │   │   │   └── personality.rs
│   │   │   ├── pathfinding.rs
│   │   │   ├── stats.rs
│   │   │   └── error.rs # thiserror — ห้าม unwrap
│   │   ├── blink-proto/ # Protobuf messages + แปลงเป็น/จาก blink-core types
│   │   │   ├── Cargo.toml
│   │   │   ├── build.rs # prost-build
│   │   │   └── src/lib.rs
│   │   └── blink-gdext/ # GDExtension binding — ชั้นบาง แปลง Godot ↔ proto ↔ core
│   │       └── src/
│   │       ├── lib.rs
│   │       └── register.rs
│   └── tests/ # Integration tests (Rust ล้วน ไม่ต้องเปิด Godot)
├── proto/
│   └── blink_v1.proto # Schema กลาง (prost) — Unit, Skill*, Item, Tile, Map,
│   # BattleState, CombatResult, AIDecision,
│   # BattleCommand, BattleEvent, PlayerData, GameSaveData
│   # (Class/Skill/Weapon fields ดูที่เอกสารอ้างอิง)
├── PDR.md
├── GDD.md
├── CLASS_TREE.md
├── SKILL_SYSTEM.md
├── WEAPON_SYSTEM.md
├── TASK_PLAN.md
├── CHARACTER_TEMPLATE.md
├── docs/
│   ├── GLOSSARY.md
│   ├── SPECS/ # Feature Spec Sheets (ทุก Feature ต้องมี)
│   ├── architecture.md
│   └── CHANGELOG.md
├── .claude/
│   ├── commands/ # 7 slash commands (/ticket /prd /glossary /spec /change /standup /understand)
│   └── rules/ # common.md godot.md rust.md comment.md
├── .github/workflows/ # CI
├── docker/Dockerfile # Multi-stage: builder → protoc → godot-export → runtime
├── justfile # setup fmt lint quality build test-all precommit ci-check
├── clippy.toml # กฎ Clippy (ห้าม unwrap)
├── rust-toolchain.toml # ล็อก Rust 1.98.1 / Edition 2024
├── .pre-commit-config.yaml
├── CLAUDE.md
├── LICENSE
└── README.md
```

**เหตุผลที่โครงสร้างนี้แก้ปัญหาเดิม:**

1. `rust/crates/blink-core` ไม่ผูกกับ Godot → เทส combat/AI/pathfinding ได้ด้วย `cargo test` เพียวๆ ไม่ต้องเปิดเกม
2. `blink-gdext` เป็นชั้นบางมีหน้าที่เดียว: แปลงข้อมูลระหว่าง Godot, proto และ core — แก้เรื่องพึ่งพากันวน
3. ไลบรารีคอมไพล์แล้วอยู่ใน `godot/addons/blink_core/bin/` ตามมาตรฐาน Godot 4
4. `rust-toolchain.toml` ล็อกเวอร์ชัน ทุกเครื่องในทีม (และ CI/Docker) ใช้ Rust ตรงกัน
5. Dockerfile แยกออกมาใน `docker/` ไม่ปนกับ source

### 3.3 Protocol Buffers Schema

ใช้ Protocol Buffers (proto3) ผ่าน `prost` crate เป็น Data Layer กลางระหว่าง Rust กับ Godot ครอบคลุม Entity:
Unit, Item, Tile, Map, BattleState, CombatResult, AIDecision, BattleCommand, BattleEvent, PlayerData, GameSaveData

> หมายเหตุ: ฟิลด์เกี่ยวกับ Class/Skill/Weapon อ้างอิงเพิ่มเติมจากเอกสาร: [[GDD.md]] [[CLASS_TREE.md]] [[SKILL_SYSTEM.md]] [[WEAPON_SYSTEM.md]]

### 3.4 Tech Stack สรุป

| ส่วน | เทคโนโลยี |
| --- | --- |
| Engine | Godot 4.x |
| Script (UI) | GDScript |
| Core Logic | Rust 1.98.1 (Edition 2024) ผ่าน GDExtension |
| Data Serialization | Protocol Buffers (prost crate) |
| Error Handling | thiserror (ห้าม unwrap) |
| Logging | tracing |
| Build Tool | Just (justfile) + Docker |
| CI/CD | Buildkite หรือ GitHub Actions |
| Version Control | Git + GitHub |
| การจัดการ Project | ClickUp (Features) + Linear (Bugs/Issues) — ดู [§4.3](#43-clickup--linear) |

---

## 4. การจัดการโปรเจกต์

### 4.1 ขั้นตอนเอกสาร (Documentation Layer)

ทุก Feature ต้องผ่านกระบวนการเอกสาร 4 ชั้นก่อนเขียนโค้ด:

1. **PRD** (Product Requirements Document) — ยืนยันว่าอะไรมี/ไม่มีในเกม
2. **Glossary** — กำหนดคำศัพท์ตายตัว (และคำที่ห้ามใช้)
3. **Spec Sheet** — รายละเอียด: UI, Data, Functions, Edge Cases
4. **Change Request** — ถ้าต้องเปลี่ยนแปลง ต้องขอ Approval ก่อน

### 4.2 Change Control Process

การเปลี่ยนแปลง Feature ต้องสร้าง **Change Request (CR)** ประกอบด้วย:
สถานะปัจจุบัน, ข้อเสนอการเปลี่ยนแปลง, เหตุผล, Impact Analysis (Features ที่ได้รับผล, Files ที่ต้องแก้, เวลาที่ใช้), Approval, Rollback Plan

**หลักการสำคัญ:** "ถ้าไม่แน่ใจ → ถามก่อน อย่าเดา" — AI ต้องตรวจสอบ PRD และ Spec Sheet ก่อน Implement ทุกครั้ง ถ้าไม่มีใน PRD ต้องถาม User ก่อน ห้ามเพิ่ม Feature เอง

### 4.3 ClickUp + Linear

**ClickUp — "จะทำอะไร" (Work to do):** Sprint Planning, Feature/Design/Documentation Tasks, Views: Board/List/Timeline/Workload/Calendar

**Linear — "มีปัญหาอะไร" (Problems to fix):** Bug/Issue Tracking, Tech Debt, Performance/Security Issues, Workflow: Triage → Confirmed → Todo → In Progress → In Review → Done, Labels: bug, feature-request, tech-debt, performance, rust-core, godot, proto

**การเชื่อมโยง:** ใส่ Linear Issue ID ใน ClickUp Task (และกลับกัน) · GitHub PR: `feat(BLN-123): ...` + `Fixes LIN-456` · Branch: `feature/xxx` (ClickUp), `linear/ABC-123-xxx` (Linear Bug)

### 4.4 Claude Code Setup

Slash Commands: `/ticket` `/prd` `/glossary` `/spec` `/change` `/standup` `/understand`

| Rule File | เนื้อหาสำคัญ |
| --- | --- |
| common.md | ตรวจ PRD/Spec ก่อนทำ, ห้ามใช้ศัพท์ต้องห้าม, Change Control, Quality Gates |
| godot.md | Naming, Signal Pattern, Autoload, Type Hints, Early Return |
| rust.md | ห้าม unwrap(), ใช้ ? operator, thiserror, Protobuf, Builder Pattern |
| comment.md | คอมเมนต์ภาษาไทย, อธิบาย "ทำไม" ไม่ใช่ "ทำอะไร", TODO ต้องมี Task ID |

---

## 5. คุณภาพโค้ดและ CI/CD

### 5.1 Linters และ Formatters

| ภาษา | Formatter | Linter | คำสั่ง |
| --- | --- | --- | --- |
| Rust | rustfmt | Clippy | `cargo fmt` · `cargo clippy -- -D warnings` |
| GDScript | gdformat | gdlint | `gdformat -r scripts/` · `gdlint -r scripts/` |
| TOML | taplo | — | `taplo fmt **/*.toml` |
| Dependencies | — | cargo-deny, cargo-audit, cargo-udeps | License, Security, Unused Deps |
| Spell Check | — | typos | ยกเว้นคำเฉพาะ: bl1nk, arcana, gdext |

### 5.2 Just — Task Runner

| คำสั่ง | หน้าที่ |
| --- | --- |
| `just setup` | ติดตั้ง Dev Tools ทั้งหมด (ครั้งแรก) |
| `just fmt` | Format โค้ดทุกภาษา |
| `just lint` | Lint โค้ดทุกภาษา |
| `just quality` | Quality Gates ทั้งหมด |
| `just build` | Build Rust workspace + copy library เข้า `godot/addons/blink_core/bin/` |
| `just test-all` | รัน Tests ทั้งหมด (cargo test + Godot headless check) |
| `just godot` | เปิด Godot Editor |
| `just precommit` | ตรวจสอบทั้งหมดก่อน Commit |
| `just ci-check` | จำลอง CI Pipeline ในเครื่อง |

### 5.3 Docker — Multi-stage Build

4 Stage: (1) Builder — Build Rust ด้วย rust:1.98.1-bookworm (2) Protoc — Compile Protocol Buffers (3) Godot Export — Export เกม headless (4) Runtime — รันเกม พร้อม dev stage สำหรับทดสอบ

### 5.4 CI/CD Pipeline

Format Check → Clippy → GDLint → Unit Tests → Integration Tests → Security Audit → Dependency Check → Build (Linux/Windows) → Godot Export → Docker Build → Deploy (main เท่านั้น)

### 5.5 Pre-commit Hooks

rustfmt, clippy, taplo, gdformat, gdlint, typos, trailing-whitespace, end-of-file-fixer, check-yaml, conventional-commit, shellcheck, markdownlint

### 5.6 Commit Message Convention (Conventional Commits)

```
feat(combat): เพิ่มระบบธาตุ 5 ธาตุ
fix(battle): แก้ Damage ติดลบเมื่อ DEF > ATK
docs: อัปเดต PRD ส่วน Battle System
```

Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

---

## 6. ขั้นตอนการพัฒนาและ Sprint

### 6.1 Daily Workflow Loop

1. `/standup` — ดู tasks วันนี้, blockers, วางแผน
2. `/spec` + `/understand` — อ่าน Spec Sheet, ยืนยันความเข้าใจ
3. เขียน Code — ตาม Spec, คอมเมนต์ภาษาไทย, เขียน Test
4. `just fmt` → `just lint` → `just quality`
5. Commit + Push — Conventional Commits
6. Update ClickUp + Linear + docs

### 6.2 2-Week Sprint Cycle

| วัน | กิจกรรม |
| --- | --- |
| Day 1 (จันทร์) | Sprint Planning — Review Backlog, เลือก Tasks, Estimate |
| Day 2-4 | Development — Daily Standup, Implement, Link Linear Issues |
| Day 5 (ศุกร์) | Mid-Sprint Review |
| Day 6-8 | Continue Development, Code Review, Testing |
| Day 9 | Sprint Testing — Integration, Bug Fixes, Polish |
| Day 10 (ศุกร์) | Sprint Review + Retrospective |

### 6.3 Development Phases

| Phase | ระยะเวลา | สิ่งที่ทำ | Deliverable |
| --- | --- | --- | --- |
| Phase 1: Foundation | 1-2 สัปดาห์ | ตั้ง Repo ตามโครงสร้างใหม่, CI/CD, Docker, PRD, Glossary, ClickUp/Linear | Dev Environment พร้อมใช้งาน |
| Phase 2: Core Prototype | 4-6 สัปดาห์ | Grid System, Unit Movement, Basic Combat, Simple AI, 1 Map | เล่น Battle ได้ |
| Phase 3: Systems | 4-6 สัปดาห์ | ระบบ Card/Class/Skill/Weapon ตามเอกสารอ้างอิง [[GDD.md]] [[CLASS_TREE.md]] [[SKILL_SYSTEM.md]] [[WEAPON_SYSTEM.md]] | ระบบหลักครบ |
| Phase 4: Content & Polish | 4-6 สัปดาห์ | Maps, Enemy Types, Boss, Terrain, Item, VFX, Sound | เกมเล่นได้ครบ Flow |
| Phase 5: Smart AI & Balance | 2-4 สัปดาห์ | Intention System, AI Personalities, Adaptive Difficulty, Balance | AI สนุก ไม่โหดเกินไป |
| Phase 6: Release | 2-4 สัปดาห์ | Main Menu, Save/Load, Tutorial, Playtesting, Build, Release | เกมจำหน่ายได้ |

### 6.4 Pre-Development Checklist

- ☑ PRD สมบูรณ์ · Glossary ครบ · Spec Sheets สำหรับทุก Feature
- ☑ Repository ตามโครงสร้างใหม่ (มาตรา 3.2) · Git Flow · Docker Dev Environment · CI/CD ทำงานได้
- ☑ ClickUp Workspace + Task Templates + Epics + Sprint แรกวางแผนแล้ว
- ☑ CLAUDE.md + Commands (7 ตัว) + Rules (4 ไฟล์) สร้างเสร็จ
- ☑ Core Loop Prototype ทำแล้ว · Paper Prototype ทดสอบแล้ว
- ☑ Core Features Locked · Change Control Process ชัดเจน
- ☑ Communication Channel ตั้งค่าแล้ว · Daily Standup ตกลงเวลาแล้ว

---

## 7. โครงสร้างทีมและหน้าที่

### 7.1 ทีมขนาด 3 คน + AI (แนะนำ)

| บทบาท | หน้าที่หลัก |
| --- | --- |
| **Producer / Lead Developer** | Design Decisions, GDScript, Rust Core, Integration, PM |
| **Artist / Visual Designer** | Character Sprites, UI/UX, Terrain Tiles, Animation, VFX, Icons |
| **Level Designer / QA Tester** | Map Layout, Enemy Placement, Boss Encounter, Balance, Playtest, Lore |

**AI Tools ใช้ได้:** Placeholder Art, Lore/Flavor Text, Naming, Debug, Documentation

**ห้ามใช้ AI ทำ:** Character Design หลัก, Game Design หลัก, Core Mechanics (ต้องเป็นคนตัดสินใจ)

### 7.2 Godot-Specific Task Management

แบ่งงานฝั่ง Godot เป็น 5 Phase ต่อ Task: Scene Setup → Build Hierarchy → Script → Connect Signals → Test & Polish
Track: Scene Inventory (.tscn), Script Inventory (.gd), Node Dependencies, Signal Connections

---

## 8. ภาคผนวก: Glossary และ Quick Reference

### 8.1 Glossary — คำศัพท์ที่ใช้ในโปรเจกต์

| คำศัพท์ | ความหมาย | หมายเหตุ |
| --- | --- | --- |
| Party | กลุ่มตัวละครที่จะลง Battle | มี 6 Slot |
| Unit | ตัวละครในเกม | มี Stats, Element |
| Element | ธาตุของ Unit | Fire, Water, Wind, Earth, Light, Dark, Neutral |
| Battle | การต่อสู้ | Turn-based tactical บน Grid |
| Map | แผนที่สำหรับ Battle | Grid-based |
| Terrain | ภูมิประเทศใน Map | มีผลต่อ Stats |

### 8.2 คำศัพท์ที่ห้ามใช้ (NOT in this game)

| คำที่ห้ามใช้ | เหตุผล | คำที่ควรใช้แทน |
| --- | --- | --- |
| Card (เฉยๆ) | ไม่ใช่เกมการ์ด | Unit Display / Party Slot |
| Deck | ไม่มีระบบสำรับ | Party / Unit Roster |
| Hand (ของการ์ด) | ไม่มี Hand | Party Slots |

### 8.3 Quick Reference — คำสั่งที่ใช้บ่อย

| การกระทำ | คำสั่ง / เครื่องมือ |
| --- | --- |
| Format โค้ดทั้งหมด | `just fmt` |
| Lint โค้ดทั้งหมด | `just lint` |
| Quality Gates ทั้งหมด | `just quality` |
| Build ทั้งหมด | `just build` |
| เปิด Godot Editor | `just godot` |
| ตรวจสอบก่อน Commit | `just precommit` |
| ดู Task วันนี้ | `/standup` |
| ตรวจ Feature มีใน PRD ไหม | `/prd check <feature>` |
| สร้าง Change Request | `/change <รายละเอียด>` |

### 8.4 Key Files ในโปรเจกต์

| ไฟล์/โฟลเดอร์ | หน้าที่ |
| --- | --- |
| `PDR.md` | Foundation Document |
| `GDD.md` | Game Design — Unit/Stats/Element/Terrain/Combat Formula/Smart AI |
| `CLASS_TREE.md` | Class Tree + Promotion Rules |
| `SKILL_SYSTEM.md` | Skill Types, CP, Bank, Guard, Aura |
| `WEAPON_SYSTEM.md` | Weapon Type, Rank, Ability, Durability |
| `TASK_PLAN.md` | Task Tracker |
| `CHARACTER_TEMPLATE.md` | Character sheet template |
| `docs/GLOSSARY.md` | คำศัพท์ที่ใช้ได้/ห้ามใช้ |
| `docs/SPECS/` | Feature Spec Sheets (ทุก Feature ต้องมี) |
| `CLAUDE.md` | Context หลักสำหรับ AI Assistant |
| `.claude/rules/` | Rules (common, godot, rust, comment) |
| `justfile` | Task Runner คำสั่งทั้งหมด |
| `proto/blink_v1.proto` | Protocol Buffers Data Schema |
| `rust/crates/blink-core/` | Core Logic ล้วน (combat, ai, pathfinding) |
| `rust/crates/blink-gdext/` | GDExtension binding ชั้นบาง |
| `docker/Dockerfile` | Multi-stage Build |
| `rust/crates/blink-core/Cargo.toml` | Rust Dependencies (Edition 2024, MSRV 1.98.1) |
| `clippy.toml` | กฎ Clippy (ห้าม unwrap) |
