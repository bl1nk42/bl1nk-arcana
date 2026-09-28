# Task Plan - Blink Arcana

## 👤 Team Structure: Solo Dev + AI

| บทบาท | ผู้รับผิดชอบ |
|--------|---------------|
| Design / Code (Godot + Rust) | Solo Developer |
| Art (Sprite, UI, Icon, Tileset, Animation, VFX) | Solo Developer + AI-generated Placeholder (จนกว่าจะทำ Art จริง/หา Asset Store) |
| Level Design / QA | Solo Developer |
| Documentation, Lore, Debug ช่วย | AI (Claude) |

**ข้อจำกัดที่ต้องวางแผนเพิ่มจากทีม 3 คน:**
- Time-boxing ต่อ Phase ควรยืดหยุ่นกว่าทีมใหญ่ (งานทำคนเดียวทุกด้าน)
- Art จะเป็นคอขวดหลัก → ใช้ Placeholder/AI-gen ก่อน แล้วค่อย polish ทีหลังใน Phase 3
- QA/Playtest ต้องอาศัยคนนอก (เพื่อน/community) ช่วย test เป็นระยะ ไม่ใช่ QA เต็มเวลา

---

## 🔧 Technical Stack (อ้างอิงจาก PDR.md)

Godot 4.x + Rust (GDExtension) | Git + GitHub | Build Target: PC (Windows/macOS/Linux)

---

## 📅 Phase 1: Core Prototype (4-6 สัปดาห์)

**Objective:** ให้เล่น Battle ได้ในระดับพื้นฐาน (ไม่ต้องสวย) เพื่อ validate core loop

- [ ] **Grid System (8x8) + Pathfinding**
  กิจกรรม: สร้าง Grid data structure ใน Rust, implement A* pathfinding, เชื่อมกับ Godot TileMap
  วัตถุประสงค์: Unit เดินบน Grid ได้ถูกต้องตามระยะ MOV

- [ ] **Unit Movement & Turn System**
  กิจกรรม: สร้าง turn_handler.gd, กำหนด turn order, สร้าง unit_selector.gd
  วัตถุประสงค์: สลับเทิร์น Player/Enemy ได้ถูกต้อง

- [ ] **Basic Combat (Attack/Damage)**
  กิจกรรม: Implement Combat Formula ใน combat.rs (ATK - DEF/2), เชื่อม damage calculation กับ UI
  วัตถุประสงค์: โจมตีแล้วเห็นค่าดาเมจถูกต้องตามสูตร

- [ ] **Simple AI (Move → Attack)**
  กิจกรรม: เขียน ai.rs เวอร์ชันพื้นฐาน (หาศัตรูใกล้สุด → เดินเข้าไป → โจมตี)
  วัตถุประสงค์: Enemy Turn ทำงานอัตโนมัติโดยไม่ crash/ค้าง

- [ ] **Basic UI (HP Bar, Turn Indicator)**
  กิจกรรม: สร้าง hud.tscn, bind HP data จาก unit resource
  วัตถุประสงค์: เห็นสถานะ HP และเทิร์นปัจจุบันแบบ real-time

- [ ] **1 Map Test**
  กิจกรรม: ออกแบบ map ทดสอบ 1 อัน (plain terrain พื้นฐาน)
  วัตถุประสงค์: มีสนามรบให้ทดสอบ loop เต็มรูปแบบ

- [ ] **1 Unit Class (Sword Line เริ่มต้น)**
  กิจกรรม: สร้าง unit resource ตาม stat ใน [[CLASS_TREE.md]] (Myrmidon)
  วัตถุประสงค์: มี Unit ให้เล่นได้จริงอย่างน้อย 1 ฝั่ง

- [ ] **Party Roster Starter (1 Class, 6 Slot Test)**
  กิจกรรม: สร้าง party_panel.tscn แบบ minimal (โชว์ 6 Slot, Unit 1 ตัวเป็น placeholder), ผูกกับ unit resource ตาม [[CLASS_TREE.md]] (Myrmidon)
  วัตถุประสงค์: มี Party Roster ให้เห็น UI จริงระหว่างเทสด Battle ก่อนผูก Class+Skill เต็มรูปแบบใน Phase 2

**Deliverable:** เล่น Battle จบ 1 รอบได้ (Start → Move → Basic Attack → Enemy Turn → End)

---

## 📅 Phase 2: Class & Skill Systems (4-6 สัปดาห์)

**Objective:** ระบบ Class + Skill + Element ครบ ผู้เล่นรู้สึกว่าเกมมีความลึก

- [ ] **5 Class Tree (3 Tiers each)** — 15 Class
  กิจกรรม: สร้าง class resource ทั้ง 15 คลาสตาม [[CLASS_TREE.md]] (Sword/Lance/Rider/Archer/Mage × T1/T2/T3)
  วัตถุประสงค์: ทุก Class มี stat และพร้อมใช้งานในเกม

- [ ] **Promotion System (Crest Item)**
  กิจกรรม: implement logic เปลี่ยน Class ตาม Crest item (Junior/Senior/Master + Alignment Scroll), reset stat ไป base ใหม่
  วัตถุประสงค์: เลื่อน Tier/เปลี่ยนสายได้ถูกต้องตามกติกา [[CLASS_TREE.md]]

- [ ] **Skill Pool ครบ 5 สาย × 3 Tier**
  กิจกรรม: เติม [[CLASS_TREE.md]] ส่วน Skill Unlock Table ให้ครบ (Sword template เสร็จแล้ว, เหลือ Lance/Rider/Archer/Mage 4 สาย)
  วัตถุประสงค์: ทุก Class Line มี Skill Pool พร้อมใช้งาน

- [ ] **Skill System (6 Slots, 1-2 Size)**
  กิจกรรม: สร้าง skill resource + slot allocation logic ตาม [[SKILL_SYSTEM.md]]
  วัตถุประสงค์: ใส่/ถอดสกิลได้ตาม slot จำกัด และสกิลมีผลจริงในคอมแบต (Passive/Active/Reactive/Command + Cooldown + CP)

- [ ] **Element System (5 Elements + Neutral)**
  กิจกรรม: implement effectiveness table จาก [[GDD.md]] (Element System) ใน combat.rs
  วัตถุประสงค์: ดาเมจเปลี่ยนตาม element matchup ถูกต้อง

- [ ] **Skill Effect Resolver**
  กิจกรรม: implement effect resolver รองรับ Damage, Heal, Buff/Debuff, Aura, Guard ตาม schema ใน [[SKILL_SYSTEM.md]]
  วัตถะประสงค์: สกิลแต่ละประเภททำงานตาม effect ที่กำหนดถูกต้อง

- [ ] **Party Slot UI (6 Slot ต่อผู้เล่น)**
  กิจกรรม: สร้าง party_panel.tscn, แสดง Unit roster + Skill ที่ติดตัว + สลับ Active 6 ตัว
  วัตถุประสงค์: ผู้เล่นเห็นและจัดการ Party ก่อน Battle ได้

**Deliverable:** ระบบ Class + Skill + Element + Party ทำงานร่วมกันครบ

---

## 📅 Phase 3: Content & Polish (4-6 สัปดาห์)

**Objective:** เกมเล่นได้ครบ Flow ตั้งแต่ต้นจนจบ

- [ ] **Skill Pool ขยาย** — เพิ่ม Skill ตัวเลือกในแต่ละ Class ให้หลากหลายขึ้น
- [ ] **10+ Maps** — ออกแบบ layout หลากหลาย terrain ตาม [[GDD.md]] (Terrain System)
- [ ] **10+ Enemy Types** — กำหนด unit resource ฝั่งศัตรู ตาม [[CLASS_TREE.md]]
- [ ] **Boss Design** — ออกแบบ boss encounter (ใช้ Throne terrain ตาม [[GDD.md]])
- [ ] **Terrain Types (8+)** — implement terrain ที่เหลือจาก [[GDD.md]] ให้ครบ (Forest, Mountain, River, Wall, Volcanic, Ice, Village, Death)
- [ ] **Item/Accessory System** — implement accessory ตาม rarity table ใน [[WEAPON_SYSTEM.md]] (Accessory section), กำหนดรายชื่อจริงแทน placeholder
- [ ] **Visual Effects & Animations** — Idle/Walk/Attack animation, damage numbers, particle
- [ ] **Sound & Music** — SFX คอมแบต + BGM

**Deliverable:** เกมเล่นได้ตั้งแต่ Explore → Battle → Upgrade ครบ Loop

---

## 📅 Phase 4: Smart AI & Balance (2-4 สัปดาห์)

**Objective:** AI สนุกท้าทาย ไม่โหดเกินไป และเกม balance ดี

- [ ] **Intention System** — แสดง indicator ว่า AI จะเดิน/โจมตีจุดไหนก่อนจบเทิร์นผู้เล่น
- [ ] **AI Personalities** (Aggressive/Defensive/Tactical) — ขยาย ai.rs รองรับ behavior หลายแบบ
- [ ] **Adaptive Difficulty** — ปรับ enemy stat/behavior ตาม performance ผู้เล่น
- [ ] **Balance Testing** — ทดสอบ stat/skill power/enemy difficulty ร่วมกับ playtester ภายนอก
- [ ] **Bug Fixing** — แก้ปัญหาจาก playtest feedback
- [ ] **Performance Optimization** — profile Rust core และ Godot scene ที่หนัก

**Deliverable:** AI มีพฤติกรรมที่คาดเดาได้บ้างแต่ท้าทาย, เกม balance ผ่านการทดสอบภายนอก

---

## 📅 Phase 5: Release (2-4 สัปดาห์)

**Objective:** เกมพร้อมปล่อยจริง

- [ ] **Main Menu & Save/Load** — implement save system (JSON/Resource-based)
- [ ] **Tutorial** — ออกแบบ onboarding สำหรับผู้เล่นใหม่
- [ ] **Final Polish** — เก็บรายละเอียด UI/UX/animation
- [ ] **Playtesting Final** — รอบทดสอบสุดท้ายก่อนปล่อย
- [ ] **Build for Target Platform** — export Windows/macOS/Linux build
- [ ] **Release!**

**Deliverable:** เกมเวอร์ชัน Release พร้อมจำหน่าย/เผยแพร่

---

## Total Estimated Timeline

**16-26 สัปดาห์ (4-6 เดือน)** — ตัวเลขนี้อิงจากทีม 3 คน ทำงานคนเดียวควรเผื่อ buffer เพิ่มโดยเฉพาะ Phase 3 (Content) ที่งาน Art/Content หนักสุด

---

## ✅ Checklist ก่อนเริ่ม (Before Day 1)

- [ ] ติดตั้ง Godot 4.x
- [ ] ติดตั้ง Visual Studio Build Tools (สำหรับ Rust บน Windows)
- [ ] ติดตั้ง Rust + cargo-generate
- [ ] สร้าง Git Repository (`bl1nk-arcana`)
- [ ] ตั้งค่า Project Structure ตาม [[PDR.md]] (มาตรา 3.2)
- [ ] ตั้งไฟล์นี้ (`TASK_PLAN.md`) เป็น Task Tracker หลักแทน Trello/Notion

## Day 1 - Week 1

- [ ] สร้าง Godot Project
- [ ] สร้าง Rust GDExtension
- [ ] เชื่อมต่อ Godot ↔ Rust ครั้งแรก (hello-world level)
- [ ] สร้าง Grid System พื้นฐาน
- [ ] ทำ Unit 1 ตัวเดินได้
- [ ] ทำ Basic Combat
- [ ] Test Prototype
