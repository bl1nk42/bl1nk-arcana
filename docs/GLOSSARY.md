# Glossary — คำศัพท์ที่ใช้ในโปรเจกต์ Blink Arcana

> อ้างอิงจาก [[PDR.md#81-glossary--คำศัพท์ที่ใช้ในโปรเจกต์]]

---

## คำศัพท์หลัก

| คำศัพท์ | ความหมาย | หมายเหตุ |
| --- | --- | --- |
| Party | กลุ่มตัวละครที่จะลง Battle | มี 6 Slot |
| Unit | ตัวละครในเกม | มี Stats, Element |
| Element | ธาตุของ Unit | Fire, Water, Wind, Earth, Light, Dark, Neutral |
| Battle | การต่อสู้ | Turn-based tactical บน Grid |
| Map | แผนที่สำหรับ Battle | Grid-based |
| Terrain | ภูมิประเทศใน Map | มีผลต่อ Stats |
| Class Line | สายอาชีพของ Unit | Sword, Lance, Rider, Archer, Mage |
| Class Tier | ระดับ Class | T1, T2, T3 |
| Promotion | การเลื่อน Class Tier | ต้องใช้ Crest Item |
| Skill Bank | สกิลที่ปลดล็อคสะสมไว้ | ใช้ได้ข้าม Class |
| Class Point (CP) | ทรัพยากรปลดล็อคสกิล/Class | ได้จาก Level Up |

---

## คำศัพท์ทางเทคนิค

| คำศัพท์ | ความหมาย |
| --- | --- |
| GDExtension | Godot Extension สำหรับ Rust |
| Protobuf | Protocol Buffers — Data serialization |
| prost | Rust crate สำหรับ Protobuf |
| thiserror | Rust crate สำหรับ Error handling |
| A* Pathfinding | อัลกอริทึมหาทางบน Grid |

---

## คำศัพท์ที่ห้ามใช้ (NOT in this game)

| คำที่ห้ามใช้ | เหตุผล | คำที่ควรใช้แทน |
| --- | --- | --- |
| Card (เฉยๆ) | ไม่ใช่เกมการ์ด | Unit Display / Party Slot |
| Deck | ไม่มีระบบสำรับ | Party / Unit Roster |
| Hand (ของการ์ด) | ไม่มี Hand | Party Slots |
