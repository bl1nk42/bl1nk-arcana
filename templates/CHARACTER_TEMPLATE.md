---
name: "{{title}}"
aliases: []
type: character
role: playable # playable / enemy / boss / npc
class_line: "" # Sword / Lance / Rider / Archer / Mage
class: "" # เช่น Myrmidon, Soldier, Cavalier, Archer, Mage
class_tier: 1 # 1 / 2 / 3
element: "" # Fire / Water / Wind / Earth / Light / Dark / Neutral
level: 1
portrait: ""
status: draft # draft / in-progress / final
tags:
  - character
  - "class/{{class_line}}"
  - "element/{{element}}"
created: "{{date}}"
---

# {{title}}

![[{{portrait}}]]

> [!info] Summary
> คำโปรยสั้น ๆ 1-2 บรรทัดเกี่ยวกับตัวละครนี้ (บทบาทในเรื่อง/สไตล์การเล่น)

## Quick Stats

Class:: [[{{class}}]]
Class Line:: [[{{class_line}} Line]]
Tier:: {{class_tier}}
Element:: [[{{element}}]]
Level:: {{level}}

| Stat | Value |
|------|-------|
| HP | |
| ATK | |
| DEF | |
| INT | |
| SPD | |
| MOV | |
| RNG | |

> [!note] Derived Stats
> AVO = (SPD × 2) + Terrain Bonus + Skill Bonus
> Crit Rate = Weapon Rank Bonus + Skill Bonus
> อ้างอิงสูตรเต็มที่ [[PDR.md#24-สู่ตรการต่อส-ยง-combat-formula--base-formula]]

---

## Class & Promotion Path

- Base Class: [[{{class}}]] (ดูตาราง Stat เต็มที่ [[CLASS_TREE.md]])
- Promotion ถัดไป: [[]]
- Promotion Item ที่ต้องใช้: [[]]

```dataview
TABLE class, class_tier, element
FROM #character
WHERE class_line = this.class_line
SORT class_tier ASC
```

---

## Equipment

> ดูรายละเอียด Weapon Type × Class Line, Rank, Secondary Stat, Weapon Ability, Durability ที่ [[WEAPON_SYSTEM.md]]

| Slot | Item | Effect |
|------|------|--------|
| 🗡️ Weapon | [[]] | |
| 👕 Armor | [[]] | |
| 💍 Accessory | [[]] | |

Weapon Rank::
Durability::

---

## Skills (6 Slots)

> ดู Skill Types (Passive/Active/Reactive/Command), Slot Cost, CP, Skill Bank, Guard Rule, Aura Range ที่ [[SKILL_SYSTEM.md]]

| Slot(s) ใช้ | Skill | Effect |
|-------------|-------|--------|
| | [[]] | |
| | [[]] | |
| | [[]] | |

> [!tip] Skill Pool ของสายนี้
> ดูรายการสกิลทั้งหมดที่ปลดล็อคได้ที่ [[CLASS_TREE.md]] (Skill Unlock Table)

Slots Used:: 0 / 6

---

## Starting / Signature Cards (Unit Display / Party Slot)

> เฉพาะตัวละครที่มีการ์ดประจำตัว (ถ้าไม่มีให้ลบ section นี้)
> ดูรายละเอียด Card System, Card Effects, Card Types ที่ [[GDD.md]] (Card System section)

| Card | Type | Effect |
|------|------|--------|
| [[]] | | |

---

## Element Interaction

> ดูตาราง Effectiveness เต็ม (5 ธาตุ + Neutral) ที่ [[GDD.md]] (Element System section)

- ได้เปรียบ: [[]]
- เสียเปรียบ: [[]]

---

## Lore / Backstory

> [!quote] Bio
> เนื้อเรื่อง/ความสัมพันธ์กับตัวละครอื่น ๆ

**เกี่ยวข้องกับ:** [[]]
**ปรากฏใน Map:** [[]]

---

## Dev Notes

> [!warning] TODO
> - [ ] กำหนด Stat ให้ครบ (อ้างอิง [[CLASS_TREE.md]])
> - [ ] เลือก Portrait/Sprite
> - [ ] ผูก Skill/Card เข้ากับ resource ใน Godot (`godot/resources/units/`)
> - [ ] ตรวจสอบ Element, Weapon Type, Class Line ตรงกับเอกสารอ้างอิง

#character #status/{{status}}
