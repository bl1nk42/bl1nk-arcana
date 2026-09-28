# Game Design Document - Blink Arcana

## 🎮 Game Overview

**ชื่อเกม:** Blink Arcana
**ประเภท:** Tactical RPG + Roguelike
**Engine:** Godot 4.x + Rust (GDExtension)
**Platform:** PC (เวอร์ชันแรก), ขยายได้ในอนาคต

### Core Loop

```
┌─────────┐    ┌─────────┐    ┌─────────┐
│ EXPLORE │───▶│ BATTLE  │───▶│ UPGRADE │
└─────────┘    └─────────┘    └─────────┘
     ▲                                │
     └────────────────────────────────┘
```

### Turn Structure

1. Start Phase (สถานะเริ่มเทิร์น + ผลของ Terrain/Aura ต่อเนื่อง)
2. Player Turn: เลือก Unit → Move (≤ MOV) → Action (Basic Attack หรือ Skill ที่ติดตัว)
3. Enemy Turn (Smart AI)
4. End Phase (ล้างสถานะหมดเทิร์น, ตรวจชนะ/แพ้)

> **หมายเหตุ:** เกมนี้ไม่มีระบบการ์ด (Card/Deck/Hand) — ทุก Action เป็น Skill ที่ติด Unit ตาม Slot จำกัด (ดู [[SKILL_SYSTEM]]) และทุก Unit เลือก Action ได้จาก Skill ของตัวเองโดยตรง ไม่ต้อง Draw

---

## ⚔️ Unit System

### Stats

| Stat | ความหมาย |
|------|-----------|
| HP | Health Points (จุดเลือด) |
| ATK | Attack Power (พลังโจมตีปกติ) |
| DEF | Defense (ลดความเสียหายจากโจมตีปกติ) |
| INT | Intelligence (พลังเวทย์/รักษา) |
| SPD | Speed (ความเร็ว, AVO) |
| MOV | Movement (จำนวนช่องที่เดินได้) |
| RNG | Range (ระยะโจมตี) |

### Derived Stats

```
AVO (Avoid) = (SPD × 2) + Terrain Bonus + Skill Bonus
Crit Rate   = Weapon Rank Bonus + Skill Bonus
```

### Combat Formula

```
PHYSICAL DAMAGE:
Damage = ATK - (DEF / 2)

MAGIC DAMAGE:
Damage = INT - (RES / 2)

CRITICAL HIT:
Crit Damage = Normal Damage × 2
Crit Rate: E(+5%) D(+10%) C(+15%) B(+20%) A(+25%) S(+35%)

HEALING:
Heal Amount = INT × 0.5 + Skill Bonus  (ห้ามเกิน Max HP)
```

รายละเอียด Class Tree และ Stat ต่อ Tier → ดู `CLASS_TREE.md`

---

## 🔥 Element System

5 ธาตุ: 🔥 Fire, 💧 Water, ⚡ Wind, 🌿 Earth, 🌑 Dark/Light

### Effectiveness Table

|         | Fire | Water | Wind | Earth | Light | Dark |
|---------|------|-------|------|-------|-------|------|
| Fire    | x    | -30%  | x    | x     | x     | x    |
| Water   | +30% | x     | x    | x     | x     | x    |
| Wind    | x    | -30%  | x    | -30%  | x     | x    |
| Earth   | x    | x     | +30% | x     | x     | x    |
| Light   | x    | x     | x    | x     | x     | -30% |
| Dark    | x    | x     | x    | x     | -30%  | x    |

- +30% = พลังเพิ่ม | -30% = พลังลดลง
- Light vs Dark = Neutral (ไม่มี bonus/penalty)
- ตัวละครแต่ละตัวมี Element หลัก 1 ธาตุ, เปลี่ยนได้ด้วย Element Orb (หายาก)
- ไม่มีธาตุ (Neutral) = ไม่ได้เปรียบ/เสียเปรียบใคร

---

## 🎴 Skill System

**6 Slots ต่อ Unit**, สกิลมี 2 ขนาด: 1 Slot (เล็ก) หรือ 2 Slots (ใหญ่) — **สกิลติดตัว Unit โดยตรง ไม่มีระบบ Draw/Hand/Deck**

| 1 Slot (เล็ก) | 2 Slots (ใหญ่) |
|---------------|-----------------|
| Dodge +5% | Astra (5 hit, x0.2 each) |
| Counter +10% | Sol (Heal 50% dmg) |
| Focus +3 ATK | Pavise (DEF x2) |
| Vantage +5% Crit | Lethality (x3 Crit) |
| Heal +10% | Aether (Dmg+Heal) |
| Wrath +10% Dmg | |

Skill Pool ต่อ Class Line → ดู `CLASS_TREE.md`
กติกา: ปลดลอคสกิล = เลื่อน Class ถึง Tier นั้นๆ / สกิลที่เคยปลดลอค = จำไว้แม้เปลี่ยน Class (ถ้ามี Slot)

**ระบบสกิลฉบับเต็ม** (Skill Type: Passive/Active/Reactive/Command, Cooldown, Class Point, Skill Bank, Guard Rule) → ดู `SKILL_SYSTEM.md`

---

## ⚔️ Equipment System

3 ช่อง: 🗡️ Weapon / 👕 Armor / 💍 Accessory (หายาก)

### Weapon

- ประเภท: Sword, Lance, Bow, Tome, Staff
- Rank: E < D < C < B < A < S
- หาจาก: Enemy Drop, Shop, เริ่มต้น
- มี Durability, S Rank หายากมาก (Boss Drop เท่านั้น)

ตัวอย่าง: Iron Sword — Rank C, ATK +10, Durability 50

**ระบบอาวุธฉบับเต็ม** (Weapon Type × Class, Rank Progression, Weapon Ability, Durability/Repair) → ดู `WEAPON_SYSTEM.md`

### Armor

- ประเภท: Leather (Light), Cloth (Mage), Heavy (Knight)
- ต้อง Fit กับ Class ไม่งั้นเสีย Stats (เช่น Mage ใส่ Heavy Armor → เสีย MOV มาก)

ตัวอย่าง: Leather Armor — Type Light, DEF +8, MOV +0

### Accessory (Rarity: 1-5 ดาว)

หาจาก Rare Drop, Event, Legendary Boss

| Rarity | ตัวอย่าง Effect |
|--------|-----------------|
| ⭐ (Common) | DEF/INT/HP/ATK เพิ่มเล็กน้อย |
| ⭐⭐ (Uncommon) | Stat bonus สูงขึ้น |
| ⭐⭐⭐ (Rare) | Bonus + Passive เล็กน้อย (เช่น AVO, Crit) |
| ⭐⭐⭐⭐ (Epic) | Bonus สูง + Passive ชัดเจน |
| ⭐⭐⭐⭐⭐ (Legendary) | Unique Effect (Auto-Revive, Full Heal Cooldown, Block Attack ฯลฯ) |

> รายการไอเทมแบบละเอียด (ชื่อ/Effect ทั้งหมด) ยังไม่ finalize — ให้กำหนดเพิ่มช่วง Phase 3 (Content & Polish)

---

## 🗺️ Terrain System

| Terrain | DEF | AVO | MOV | Heal | Special |
|---------|-----|-----|-----|------|---------|
| Plain | - | - | - | - | - |
| Road | - | - | +1 | - | - |
| Forest | +15% | +10% | -1 | - | - |
| Mountain | XXX | XXX | XXX | - | Fly OK |
| River | - | - | -1 | XXX | No Heal |
| Wall | +20% | +5% | -1 | - | - |
| Volcanic | +10% | - | - | - | Fire+ |
| Ice | - | - | -1 | - | Water+ |
| Throne | +10% | +10% | - | - | Boss |
| Village | - | - | - | +20% | - |
| Death | XXX | XXX | XXX | XXX | Die! |

XXX = ผ่านไม่ได้/ยืนไม่ได้ | Fire+/Water+ = ธาตุนั้นได้เปรียบ

---

## 📂 Project Structure

```
bl1nk-arcana/
├── godot_project/
│   ├── scenes/
│   │   ├── main.tscn / battle.tscn / map.tscn / unit.tscn
│   │   └── ui/ (hud, party_panel, unit_info, shop)
│   ├── scripts/
│   │   ├── autoload/ (game_manager.gd, skill_database.gd)
│   │   ├── battle/ (battle_manager.gd, turn_handler.gd, unit_selector.gd, tile_highlighter.gd)
│   │   ├── ui/ (skill_ui.gd, party_panel.gd)
│   │   └── main_menu.gd
│   ├── resources/ (units/ classes/ skills/ items/)
│   ├── assets/ (sprites/ sfx/ music/)
│   └── project.godot
├── rust_core/
│   └── src/ (lib.rs, combat.rs, ai.rs, pathfinding.rs, data.rs, skills.rs)
├── docs/ (GDD.md, CLASS_TREE.md, SKILL_SYSTEM.md, TASK_PLAN.md)
└── build/ (windows/ macos/ linux/)
```

> **หมายเหตุ:** โครงสร้างในไฟล์นี้เป็นเวอร์ชันเก่า (godot_project/rust_core แบนรวมกัน) — โครงสร้างจริงที่ใช้แยก Godot project กับ Rust workspace ตาม [[PDR.md#32-โครงสร้างรีโพใหม่-แทนโครงสร้างเดิมที่พัง]]

---

## 🔧 Technical Stack

- **Engine/Language:** Godot 4.x (GDScript สำหรับ UI/Scene/Animation) + Rust GDExtension (Combat, AI, Pathfinding, Data)
- **Art:** Aseprite (Pixel Art) / Stable Diffusion (Placeholder/Concept) — ดูรายละเอียดใน `TASK_PLAN.md` (Solo + AI workflow)
- **Version Control:** Git + GitHub
- **Project Management:** ไฟล์ `TASK_PLAN.md` ใน docs/ (แทน Trello/Notion)
- **Build Target:** PC (Windows/macOS/Linux) — เวอร์ชันแรก
- **Deployment (Web build ถ้ามี):** พิจารณา Vercel สำหรับหน้า landing/devlog

*เอกสารที่เกี่ยวข้อง: `CLASS_TREE.md` (รายละเอียด Class/Skill), `SKILL_SYSTEM.md` (กติกา Skill/CP/Slot/Bank/Guard), `TASK_PLAN.md` (แผนงานและ Task Breakdown)*
