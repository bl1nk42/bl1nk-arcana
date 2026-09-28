# Skill System - Blink Arcana

## Design Reference: Langrisser

แนวคิดที่หยิบมาจาก Langrisser (ไม่ copy ชื่อ/เนื้อหาต้นฉบับ ใช้เฉพาะกลไกระดับระบบ):

1. **สกิลผูกกับ Class Tree** — ปลดล็อคสกิลโดยเลื่อน Class ถึง Tier นั้น ๆ
2. **Skill Bank (สกิลคงอยู่ข้าม Class)** — สกิลที่เคยปลดล็อคแล้ว ใช้ได้ตลอดแม้เปลี่ยนไป Class อื่น (ต้องมี Slot ว่างพอ)
3. **Class Point (CP)** — ทรัพยากรที่ใช้ปลดล็อค/เชี่ยวชาญ (master) สกิลและ Class ใหม่ แยกจาก EXP/Level
4. **Guard เฉพาะกายภาพ** — สกิล/การ์ดประเภท Guard ป้องกันดาเมจกายภาพเท่านั้น ไม่กันดาเมจเวทย์ (INT-based)
5. **Area of Command (Aura)** — สกิลบางประเภทบัฟ Ally ที่อยู่ในระยะ โดยอัตโนมัติตราบที่ Unit ยังอยู่บนสนาม ไม่ต้องกด Action

---

## 1. Skill Categories

ทุกสกิลในเกมจัดอยู่ใน 4 ประเภท:

| Type | สัญลักษณ์ | นิยาม | ตัวอย่าง |
|------|-----------|--------|----------|
| **Passive** | P | ทำงานอัตโนมัติตลอดเวลา ไม่กิน Action, ไม่มี Cooldown | Dodge +5%, Focus +3 ATK |
| **Active** | A | ต้องเลือกใช้แทน Action ปกติในเทิร์นตัวเอง มี Cooldown | Astra, Volley, Sol |
| **Reactive** | R | ทำงานอัตโนมัติเมื่อเงื่อนไข trigger เกิดขึ้น (ถูกโจมตี/ป้องกัน) ไม่กิน Action | Counter, Vantage, Lethality |
| **Command / Aura** | C | บัฟ Ally ทุกตัวในระยะ RNG ของ Unit นี้โดยอัตโนมัติ ไม่กิน Action, หยุดทำงานถ้า Unit ตายหรือถูกเรียกกลับ | Formation, Group Ward, Bulwark |

> กติกา: Unit เห็น Type ของสกิลได้จาก UI Skill Slot เสมอ เพื่อให้ผู้เล่นวางแผนได้ว่าสกิลไหนต้องกด (A) สกิลไหนทำงานเอง (P/R/C)

---

## 2. Slot Cost & Cooldown Default

| Slot Cost | ใช้กับ | Cooldown เริ่มต้น (เฉพาะ Type: Active) |
|-----------|--------|------------------------------------------|
| 1 Slot | สกิลเล็ก (Passive/Reactive ส่วนใหญ่, Active เบา) | 2 เทิร์น |
| 2 Slot | สกิลใหญ่/Ultimate (Active หนัก, Command ระดับ AoE) | 3 เทิร์น |

- Unit มี **6 Slot** รวม, ใส่สกิลได้ผสมกันไม่เกิน Slot ที่เหลือ
- Cooldown เริ่มนับตั้งแต่เทิร์นที่ใช้สกิลนั้นจบลง
- Type Passive/Reactive/Command ไม่มี Cooldown (ทำงานได้ทุกเงื่อนไข/ทุกเทิร์น)

---

## 3. Unlock Progression (Class Point)

| ระบบ | รายละเอียด |
|------|-------------|
| **ได้ CP** | +1 CP ทุกครั้งที่ Level Up |
| **ใช้ CP ปลดล็อคสกิล** | สกิล 1-Slot = 2 CP / สกิล 2-Slot = 4 CP |
| **ใช้ CP เลื่อน Class (ร่วมกับ Promotion Item)** | T1→T2 = 10 CP + Junior Crest / T2→T3 = 20 CP + Senior Crest |
| **Master Bonus** | ปลดล็อคสกิลครบทุกตัวใน Tier นั้น = Class นั้น "Mastered" → เห็น Badge ใน UI (ตาม Langrisser ที่ต้อง Master Class ก่อนเลื่อน Tier ถัดไปได้) |

> การ "Master" Class (ปลดล็อคสกิลครบ Tier) เป็นเงื่อนไขเพิ่มเติมนอกจาก Promotion Item — ป้องกันผู้เล่นโดดข้าม Tier โดยไม่สำรวจสกิลของ Class นั้นก่อน

---

## 4. Skill Bank Rule

- สกิลที่ปลดล็อคแล้วทุกตัว (จากทุก Class ที่เคยผ่านมา) ถูกเก็บใน "Skill Bank" ประจำ Unit นั้น ๆ
- เปลี่ยน Class เมื่อไหร่ก็ได้ตราบที่ถือ Promotion Item — สกิลใน Bank ไม่หาย แค่ต้องจัด Slot ใหม่ (รวม Slot สูงสุดยังคง 6 เท่าเดิม)
- Unit คนละตัวมี Skill Bank แยกกัน (ไม่ share ข้าม Unit)

---

## 5. Guard Rule (ทุก Skill ประเภท Guard)

> อ้างอิงจากกลไก Guard ของ Langrisser: บล็อกดาเมจกายภาพเท่านั้น เวทย์ทะลุผ่านได้เสมอ

- Guard/Bulwark/Aegis ทุกสกิลที่ "บล็อก" หรือ "ลดดาเมจ" มีผลกับ **Physical Damage เท่านั้น** (สูตร ATK-DEF/2)
- **ไม่มีผล**กับ Magic Damage (สูตร INT-RES/2) — ผู้เล่นต้องรับมือหน่วย Mage/Elemental ด้วยวิธีอื่น (Warding, RES, ระยะ, Terrain)
- ข้อยกเว้นต้องระบุชัดในสกิลนั้น ๆ (เช่นถ้าจะให้กันเวทย์ด้วยต้องเขียนไว้ตรง ๆ)

---

## 6. Command / Aura Range Rule

- Command/Aura skill มีระยะเป็นค่า RNG เฉพาะของสกิลนั้น (ปกติ 1-2 ช่องรอบ Unit)
- Aura **ไม่ Stack กับตัวเอง** ถ้ามี Unit หลายตัวถือ Aura เดียวกันซ้อนกัน — Ally ได้รับ Effect สูงสุดตัวเดียว (ไม่บวกกัน)
- Aura คนละชนิดกัน Stack กันได้ปกติ (เช่น Formation DEF + Group Ward RES ใช้พร้อมกันได้)

---

## 7. Skill Pool ต่อ Class Line (พร้อม Type)

รายละเอียด Effect เต็ม + Slot Cost → ดู [[CLASS_TREE]]
สรุป Type ของแต่ละสกิลไว้ที่นี่เพื่อใช้ประกอบตอน implement `skills.rs`:

### 🗡️ Sword Line

| Tier | Skill | Type |
|------|-------|------|
| T1 | Sword E | P |
| T1 | Dodge +5% | P |
| T1 | Focus +3 ATK | P |
| T1 | Parity +2 DEF | P |
| T2 | Sword A / Sword B | P |
| T2 | Counter | R |
| T2 | Dodge +10% | P |
| T2 | Vantage | R |
| T2 | Strong Hit +15% | P |
| T3 | Sword S | P |
| T3 | Astra | A |
| T3 | Dodge +15% | P |
| T3 | Warding | P |
| T3 | Aether | A |

### 🔱 Lance Line

| Tier | Skill | Type |
|------|-------|------|
| T1 | Guard Stance | A |
| T1 | Reach +1 RNG | P |
| T1 | Brace vs Rider +20% | P |
| T1 | Parity +2 DEF | P |
| T2 | Lance A | P |
| T2 | Counter Guard | R |
| T2 | Zone Control | R |
| T2 | Formation +10% DEF | C |
| T2 | Pierce Guard | A |
| T3 | Lance S | P |
| T3 | Bulwark | C |
| T3 | Immovable | P |
| T3 | Aegis | R |
| T3 | Last Stand | P |

### 🐎 Rider Line

| Tier | Skill | Type |
|------|-------|------|
| T1 | Charge +15% ATK | P |
| T1 | Canter +1 MOV | P |
| T1 | Advance vs Sword +20% | P |
| T1 | Mobility +2 AVO | P |
| T2 | Lance A | P |
| T2 | Trample | A |
| T2 | Rescue | A |
| T2 | Momentum +10% Crit | P |
| T2 | Flank | P |
| T3 | Lance S | P |
| T3 | Breakthrough | A |
| T3 | Vanguard | A |
| T3 | Relentless Charge | P |
| T3 | Overrun | P |

### 🏹 Archer Line

| Tier | Skill | Type |
|------|-------|------|
| T1 | Precise Shot +10% Crit | P |
| T1 | Range +1 | P |
| T1 | Focus +3 ATK | P |
| T1 | Dodge +5% | P |
| T2 | Bow A | P |
| T2 | Volley | A |
| T2 | Snipe +20% Dmg vs Full HP | P |
| T2 | No Counter Penalty | P |
| T2 | Steady Aim +10% Crit | P |
| T3 | Bow S | P |
| T3 | Lethality | R |
| T3 | Shadow Step | P |
| T3 | Execute | P |
| T3 | Vantage +5% Crit | R |

### 🔮 Mage Line

| Tier | Skill | Type |
|------|-------|------|
| T1 | Elemental Bolt | A |
| T1 | Heal +10% | P |
| T1 | Focus +3 INT | P |
| T1 | Parity +2 RES | P |
| T2 | Tome A | P |
| T2 | Sol | A |
| T2 | Warding +15% Resist | P |
| T2 | Element Shift | A |
| T2 | Group Ward | C |
| T3 | Tome S | P |
| T3 | Aether | A |
| T3 | Astra | A |
| T3 | Mass Heal | A |
| T3 | Overload | A |

---

## 8. Implementation Note (Rust: `skills.rs`)

โครงสร้างข้อมูลแนะนำต่อสกิล 1 ตัว:

```rust
struct Skill {
    id: String,
    name: String,
    slot_cost: u8,        // 1 or 2
    skill_type: SkillType, // Passive | Active | Reactive | Command
    cooldown: Option<u8>,  // Some(n) เฉพาะ Active
    range: Option<u8>,     // Some(n) เฉพาะ Command/Aura
    unlock_cp: u8,         // 2 (1-slot) หรือ 4 (2-slot)
    effect: EffectData,
}
```

ดูสกิลแต่ละตัวพร้อม Effect เต็มที่ [[CLASS_TREE]] และ Skill Effect Type ที่ [[GDD]] (Skill System section)
