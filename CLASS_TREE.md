# Class Tree Reference - Blink Arcana

5 Class Lines × 3 Tiers ต่อสาย

---

## 🗡️ Sword Line

| Tier | Class | HP | ATK | DEF | SPD | MOV | RNG |
|------|-------|----|----|-----|-----|-----|-----|
| T1 | Myrmidon | 80 | 30 | 15 | 10 | 5 | 1 |
| T2 | Hero | 95 | 38 | 22 | 10 | 5 | 1 |
| T3 | Sword Master | 110 | 45 | 28 | 10 | 5 | 1-2 |

## 🔱 Lance Line

| Tier | Class | HP | ATK | DEF | SPD | MOV | RNG |
|------|-------|----|----|-----|-----|-----|-----|
| T1 | Soldier | 100 | 25 | 22 | 8 | 4 | 1 |
| T2 | Knight | 120 | 32 | 30 | 7 | 4 | 1 |
| T3 | General | 145 | 40 | 40 | 6 | 4 | 1 |

## 🐎 Rider Line

| Tier | Class | HP | ATK | DEF | SPD | MOV | RNG |
|------|-------|----|----|-----|-----|-----|-----|
| T1 | Cavalier | 90 | 28 | 18 | 9 | 7 | 1-2 |
| T2 | Paladin | 105 | 35 | 25 | 9 | 7 | 1-2 |
| T3 | Great Knight | 130 | 42 | 32 | 8 | 6 | 1-3 |

## 🏹 Archer Line

| Tier | Class | HP | ATK | DEF | SPD | MOV | RNG |
|------|-------|----|----|-----|-----|-----|-----|
| T1 | Archer | 75 | 28 | 12 | 10 | 5 | 3 |
| T2 | Sniper | 85 | 38 | 15 | 10 | 5 | 4 |
| T3 | Assassin | 80 | 40 | 15 | 12 | 6 | 3 |

## 🔮 Mage Line

| Tier | Class | HP | ATK | DEF | SPD | MOV | RNG |
|------|-------|----|----|-----|-----|-----|-----|
| T1 | Mage | 65 | 15 | 10 | 8 | 5 | 2 |
| T2 | Sage/Cleric | 75 | 20 | 12 | 8 | 5 | 2-3 |
| T3 | Archmage/Bishop | 90 | 30 | 18 | 8 | 5 | 3 |

---

## Class Promotion Rules

| Item | Effect | หาได้จาก |
|------|--------|----------|
| Junior Crest | T1 → T2 | Side Quest, Shop หายาก |
| Senior Crest | T2 → T3 | Boss Drop |
| Master Crest | Any → Any | End Game, Legendary |
| Alignment Scroll | Change Line (Keep Tier) | Rare Shop |

**ข้อจำกัดเมื่อเปลี่ยน Class:**
- Stats กลับไป Base ของ Class ใหม่
- Level และ EXP คงไว้
- Skill ที่ปลดลอคแล้ว คงไว้ (แต่ต้องมี Slot)

---

## Skill Unlock Table

> ดู **Type** ของสกิลแต่ละตัว (Passive / Active / Reactive / Command) รวมถึงกติกา Cooldown, Class Point, Skill Bank และ Guard ที่ [[SKILL_SYSTEM]]

### Sword Line (Reference Template — สายอื่นใช้โครงเดียวกัน)

| Tier 1 (Myrmidon) | Tier 2 (Hero) | Tier 3 (Master) |
|--------------------|----------------|-------------------|
| Sword E [1] | Sword A [1] | Sword S [1] |
| Dodge +5% [1] | Sword B [1] | Astra [2] |
| Focus +3 [1] | Counter [1] | Dodge +15% [1] |
| Parity +2 [1] | Dodge +10% [1] | Warding [1] |
| | Vantage [1] | Aether [2] |
| | Strong Hit +15% [2] | Strong Hit [1] |

> ตัวเลขใน [] = จำนวน Slot ที่ใช้ / ปลดลอคสกิล = เลื่อน Class ถึง Tier นั้นๆ

### Lance Line

> แนวคิดอ้างอิงจาก Langrisser: Lancer class เน้น Guard/ตั้งรับ และได้เปรียบสายที่เน้นความเร็ว (Rider) — ไม่ copy skill/lore ต้นฉบับ ใช้แค่แนวทาง "บทบาท" มาออกแบบสกิลใหม่

| Tier 1 (Soldier) | Tier 2 (Knight) | Tier 3 (General) |
|--------------------|-------------------|---------------------|
| Guard Stance [1] (DEF +15% เมื่อไม่เดิน) | Lance A [1] | Lance S [1] |
| Reach +1 RNG [1] | Counter Guard [1] (สะท้อนดาเมจเมื่อโดน Guard) | Bulwark [2] (แบ่งดาเมจ 50% ให้ Unit ข้างเคียง) |
| Brace vs Rider +20% [1] | Zone Control [1] (โจมตีฟรีเมื่อศัตรูเดินผ่านช่องติดกัน) | Immovable [1] (ยกเลิก Knockback/Forced Move) |
| Parity +2 DEF [1] | Formation +10% DEF [2] (บัฟ DEF Unit รอบข้าง) | Aegis [2] (Block โจมตีกายภาพ 1 ครั้ง/เทิร์น) |
| | Pierce Guard [1] (เจาะเกราะเป้าหมายที่ Guard อยู่) | Last Stand [1] (DEF +30% เมื่อ HP < 30%) |

### Rider Line

> แนวคิดอ้างอิงจาก Langrisser: Cavalry เน้นความเร็ว/เจาะแนว ได้เปรียบสายระยะประชิด (Sword) แต่เสียเปรียบสาย Guard (Lance)

| Tier 1 (Cavalier) | Tier 2 (Paladin) | Tier 3 (Great Knight) |
|--------------------|--------------------|---------------------------|
| Charge +15% ATK [1] (โบนัสเมื่อเดินก่อนโจมตี) | Lance A [1] | Lance S [1] |
| Canter +1 MOV [1] | Trample [1] (โจมตีแล้วเดินต่อได้ถ้าฆ่าเป้าหมาย) | Breakthrough [2] (โจมตีทะลุเป็นเส้นตรง 2 ช่อง) |
| Advance vs Sword +20% [1] | Rescue [1] (ย้าย Ally ที่ร่วงหล่นกลับเข้าแถว) | Vanguard [1] (ผู้เล่นเลือกลำดับเทิร์นได้ 1 ครั้ง/battle) |
| Mobility +2 AVO [1] | Momentum +10% Crit [2] (สะสมเมื่อเดินไกล) | Relentless Charge [2] (Charge ไม่มี cooldown) |
| | Flank [1] (ไม่โดน Zone Control) | Overrun [1] (Ignore Terrain MOV penalty) |

### Archer Line

> แนวคิดอ้างอิงจาก Langrisser: Archer อยู่นอกวงจร Priority หลัก เน้นระยะไกล/แม่นยำ

| Tier 1 (Archer) | Tier 2 (Sniper) | Tier 3 (Assassin) |
|--------------------|--------------------|------------------------|
| Precise Shot +10% Crit [1] | Bow A [1] | Bow S [1] |
| Range +1 [1] | Volley [2] (ยิงโจมตี 2 เป้าหมายในระยะ) | Lethality +Crit x3 [2] |
| Focus +3 ATK [1] | Snipe +20% Dmg vs Full HP target [1] | Shadow Step [1] (เดินได้โดยไม่ trigger Zone Control) |
| Dodge +5% [1] | No Counter Penalty [1] (ยิงได้แม้ Unit ศัตรูอยู่ติดกัน) | Execute [1] (Dmg +50% เมื่อเป้าหมาย HP < 25%) |
| | Steady Aim +10% Crit [2] (เมื่อไม่เดินก่อนยิง) | Vantage +5% Crit [1] |

### Mage Line

> แนวคิดอ้างอิงจาก Langrisser: สาย Magic เน้น Element/Support แยกจาก Class Priority ทางกายภาพ ผูกกับ Element System ที่มีอยู่แล้ว

| Tier 1 (Mage) | Tier 2 (Sage/Cleric) | Tier 3 (Archmage/Bishop) |
|--------------------|--------------------------|------------------------------|
| Elemental Bolt [1] (เลือก 1 ธาตุตอนปลดล็อค) | Tome A [1] | Tome S [1] |
| Heal +10% [1] | Sol [2] (Heal 50% ของดาเมจที่ทำได้) | Aether [2] (Dmg+Heal พร้อมกัน) |
| Focus +3 INT [1] | Warding +15% Resist ธาตุตรงข้าม [1] | Astra [2] (5 hit, x0.2 each) |
| Parity +2 RES [1] | Element Shift [1] (เปลี่ยนธาตุการโจมตีชั่วคราว) | Mass Heal [2] (Heal Ally ทุกตัวในระยะ RNG) |
| | Group Ward [2] (บัฟ RES ให้ Ally รอบข้าง) | Overload [1] (Dmg +25% แต่เสีย HP ตัวเอง 10%) |
