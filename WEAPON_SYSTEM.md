# Weapon System - Blink Arcana

## Design Reference: Langrisser

แนวคิดที่หยิบมาจากระบบอาวุธของ Langrisser (ไม่ copy ชื่อ/ค่าตัวเลขอาวุธจริงจากเกม ใช้เฉพาะโครงสร้างระบบ):

1. **Weapon Type ผูกกับ Class** — แต่ละ Class Line ถืออาวุธได้เฉพาะประเภทของตัวเอง
2. **Weapon ให้ Stat Bonus ได้มากกว่า ATK ตัวเดียว** — อาวุธบางชิ้นให้ HP/INT/DEF ติดมาด้วย ไม่ใช่แค่ ATK
3. **Weapon Ability** — อาวุธ Rank สูง (C ขึ้นไป) ติดสกิลเฉพาะตัวมาด้วย โดย**ไม่กิน Skill Slot** (แยกทรัพยากรจาก [[SKILL_SYSTEM]])
4. **Weapon Rank ผูกกับ Skill Pool** — ปลดล็อค Weapon Rank ผ่านสกิล Passive ที่มีอยู่แล้ว (Sword E/A/B/S, Bow A/S, Lance A/S, Tome A/S ใน [[CLASS_TREE]])

---

## 1. Weapon Type × Class Line

| Class Line | Weapon Type | หมายเหตุ |
|------------|-------------|-----------|
| 🗡️ Sword | Sword | ระยะ 1 (Sword Master ได้ 1-2 จาก Skill) |
| 🔱 Lance | Lance | ระยะ 1 |
| 🐎 Rider | Lance | ใช้ Lance เดียวกับสาย Lance แต่ MOV สูงกว่า (ดู [[CLASS_TREE]]) |
| 🏹 Archer | Bow | ระยะ 3-4 |
| 🔮 Mage | Tome (Attack) / Staff (Heal) | Element ผูกกับ Tome ที่ถืออยู่ |

> Unit ถืออาวุธผิด Type ไม่ได้ — ถ้าเปลี่ยน Class ไป Line อื่น (ผ่าน Alignment Scroll) ต้องเปลี่ยนอาวุธตามด้วย

---

## 2. Weapon Rank Progression

| Rank | ATK Bonus (Base) | ปลดล็อคผ่านสกิล |
|------|-------------------|-------------------|
| E | +5 | ค่าเริ่มต้น (ไม่ต้องปลดล็อค) |
| D | +8 | *(Rank กลาง ไม่มีสกิลแยก ใช้ระหว่างทาง)* |
| C | +12 | *(Rank กลาง)* |
| B | +16 | Sword B / Bow B / Lance B / Tome B [1] |
| A | +20 | Sword A / Bow A / Lance A / Tome A [1] |
| S | +26 | Sword S / Bow S / Lance S / Tome S [1] |

- Unit ถืออาวุธ Rank สูงกว่าที่ตัวเอง**ปลดล็อคแล้ว**ไม่ได้ (เช่นยังไม่ปลดล็อค Sword A ก็ใช้อาวุธ Sword Rank A ไม่ได้ แม้จะเก็บมาได้)
- ค่า ATK Bonus ด้านบนคือ "พื้น" ของ Rank นั้น อาวุธแต่ละชิ้นอาจสูง/ต่ำกว่าเล็กน้อยตาม Secondary Stat ที่ติดมา (ดูข้อ 3)

---

## 3. Weapon Stat Template

อาวุธ 1 ชิ้นมี **Primary Stat (ATK)** เสมอ และมี **Secondary Stat** ได้ไม่เกิน 1 ค่า (trade-off design)

| Field | คำอธิบาย |
|-------|-----------|
| name | ชื่ออาวุธ |
| type | Sword / Lance / Bow / Tome / Staff |
| rank | E–S |
| atk_bonus | ค่าตาม Rank Progression (ข้อ 2) |
| secondary_stat | ไม่มี / HP / DEF / INT / SPD (เลือกได้ 1 อย่าง) |
| secondary_value | ค่าของ secondary stat |
| durability | จำนวนครั้งใช้ได้ก่อนต้องซ่อม |
| weapon_ability | สกิลติดอาวุธ (เฉพาะ Rank C ขึ้นไป, ดูข้อ 4) |
| element | เฉพาะ Tome เท่านั้น (Fire/Water/Wind/Earth/Light/Dark) |

**ตัวอย่าง (Rank C, Sword):**

| Name | Type | Rank | ATK | Secondary | Durability | Weapon Ability |
|------|------|------|-----|-----------|------------|------------------|
| Guard Breaker | Sword | C | +12 | - | 40 | Quickdraw (ดูข้อ 4) |
| Warden's Edge | Sword | C | +10 | DEF +4 | 45 | - |

---

## 4. Weapon Ability (ติดอาวุธ ไม่กิน Skill Slot)

เฉพาะอาวุธ Rank **C ขึ้นไป** เท่านั้นที่มี Weapon Ability — เป็นสกิลที่ติดกับตัวอาวุธ ถอดอาวุธเมื่อไหร่ Ability หายไปด้วย (คนละเรื่องกับ Skill Bank ใน [[SKILL_SYSTEM]])

| Weapon Type | Weapon Ability (ตัวอย่าง) | Rank ต่ำสุด | Type |
|-------------|-------------------------------|--------------|------|
| Sword | Quickdraw — Crit +5% เมื่อโจมตีก่อน | C | Passive |
| Sword | Riposte — สะท้อนดาเมจ 20% เมื่อรอด HP > 0 | A | Reactive |
| Lance | Brace — ไม่โดนดาเมจจาก Zone Control ของศัตรู | C | Passive |
| Lance | Unbreakable — DEF +10% เมื่อ HP < 50% | A | Passive |
| Bow | Pinpoint — เพิกเฉย AVO Bonus จาก Terrain ของเป้าหมาย | C | Passive |
| Bow | Farshot — Range +1 ในเทิร์นที่ไม่เดิน | A | Passive |
| Tome | Overcharge — Dmg เวทย์ +10% แต่เสีย HP ตัวเอง 3% | C | Active |
| Tome | Mana Flow — Cooldown สกิล Active ลดลง 1 เทิร์น | A | Passive |
| Staff | Lifebind — Heal +15% แต่ Range -1 | C | Passive |
| Staff | Sanctuary — Heal เป้าหมายที่ HP < 30% เพิ่มอีก 10% | A | Passive |

> S Rank ทุกชิ้น (End Game/Boss Drop) มี Weapon Ability เฉพาะตัว ออกแบบเป็นรายชิ้นตอน Phase 3 (Content & Polish) ไม่ใช้ Pool ตารางนี้

---

## 5. Durability & Repair

- อาวุธเสีย Durability **1 หน่วยต่อการโจมตี 1 ครั้ง** (ไม่เสียเมื่อ Guard/ใช้ Skill ที่ไม่ใช่โจมตีตรง)
- เมื่อ Durability = 0 → เข้าสถานะ **Worn**: ATK Bonus ลดเหลือครึ่งหนึ่ง และ Weapon Ability หยุดทำงาน (ไม่ใช่ถูกทำลายถาวร แบบ FE — ลดโทษให้เหมาะกับเกม Roguelike ที่ตายแล้วเริ่มใหม่)
- ซ่อมได้ที่ Shop (Explore Phase) ด้วย Gold ตามสัดส่วน Rank อาวุธ (Rank สูง = ซ่อมแพงกว่า)
- อาวุธ Rank S ไม่มี Durability (Unbreakable ตามธรรมชาติ ของหายากระดับ Boss Drop)

---

## 6. Magic Resist Note (เชื่อมกับ Combat Formula เดิม)

Weapon System นี้ไม่เพิ่ม Slot ใหม่ให้ Equipment (ยังคง 3 ช่อง: Weapon/Armor/Accessory ตาม [[GDD]]) แต่ตอกย้ำว่า:

- **RES** (ค่าที่ใช้ในสูตร `Magic Damage = INT - (RES/2)`) มาจาก Armor/Accessory เท่านั้น ไม่ใช่ Weapon
- Weapon ฝั่ง Mage (Tome/Staff) ปรับ **INT** ไม่ใช่ DEF/RES — ดังนั้น Mage ที่โดนโจมตีกายภาพยังต้องพึ่ง Armor ปกติ

---

*เอกสารที่เกี่ยวข้อง: [[GDD]] (Equipment System ภาพรวม), [[CLASS_TREE]] (Weapon Rank Skill ต่อ Class), [[SKILL_SYSTEM]] (แยกจาก Weapon Ability)*
