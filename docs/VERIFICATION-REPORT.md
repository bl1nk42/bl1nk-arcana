# ผลการตรวจและแก้ — 28 กันยายน 2026

ตรวจด้วยการรันจริง ไม่ใช่การอ่านโค้ดอย่างเดียว

```
Godot   4.6.stable (godot-rust 0.5.5, API 4.6)
Rust    1.98.1
Target  x86_64-unknown-linux-gnu
ผล     ERROR 0 · SCRIPT ERROR 0 · WARNING 1
```

เกมเปิดได้, autoload ครบ 8 ตัว, Rust extension โหลดผ่าน, battle cycle
จบ, save ลง slot 0 ได้

---

## จุดที่ทำให้เปิดโปรเจกต์ไม่ได้เลย

| ไฟล์ | ปัญหา | แก้ |
| --- | --- | --- |
| `godot/project.godot` | `config/features=PackStringArray(...)` ผิดชนิด (ต้องเป็น `PackedStringArray`) และประกาศซ้ำสองบรรทัด → Godot parse ไม่ผ่าน โปรเจกต์เปิดไม่ได้ | รวมเหลือบรรทัดเดียว + ชี้ icon ไป `.svg` (ไฟล์ที่มีจริง) |
| `addons/blink_core/bin/libblink_gdext.so` | เป็น **ELF ARM aarch64** (build จาก Termux บน Android — path ในไฟล์คือ `/data/data/com.termux/...`) แต่ manifest ชี้ path ของ x86_64 Linux | build ใหม่จาก `rust/` เป็น x86_64 จริง |
| `blink_core.gdextension` | `entry_symbol = "gdextension_init"` เป็นชื่อของ godot-rust 0.1/0.2 — 0.5 export `gdext_rust_init` | เปลี่ยนเป็น `gdext_rust_init` |
| `scripts/autoload/*.gd` | autoload ทั้ง 8 ตัวประกาศ `class_name` ตรงกับชื่อ autoload ตัวเอง → Godot ปฏิเสธที่จะโหลด | ถอด `class_name` ออกทั้ง 8 (รุ่นที่หลุดทำถูก 7 ตัว ผมแก้ `GDExtensionManager` เพิ่ม) |

---

## ชื่อชนกับ class ของ Godot

`GDExtensionManager` เป็นชื่อ **class ที่มีอยู่ใน Godot 4.3+ จริง** ไม่ใช่แค่ชื่อ autoload
เมื่อ GDScript เจอ `GDExtensionManager.something` มันจะหยิบ class ของ engine ไปก่อน
ทำให้ทุกการเรียกไปยัง autoload ตัวนี้ parse ไม่ผ่าน

ตรวจด้วย `ClassDB.class_exists()` ยืนยันว่าชนจริง แล้วเปลี่ยนชื่อ autoload เป็น **`RustCore`**
(เปลี่ยนทั้ง `project.godot` และทุกจุดที่อ้างถึง รวม 10 ไฟล์)

---

## บั๊กใน GDScript ที่ทำให้ compile ไม่ผ่าน

แก้ไปทั้งหมดนี้ ตอนนี้ Parse Error = 0

| ไฟล์:บรรทัด | ปัญหา |
| --- | --- |
| `SettingsManager.gd:108` | ใช้ ternary แบบ C `a ? b : c` ซึ่ง GDScript ไม่มี |
| `SettingsManager.gd:108` | `RenderingServer.set_default_texture_filter()` **ไม่มีใน Godot 4** และ enum `TEXTURE_FILTER_*` ไม่ได้อยู่บน `RenderingServer` แต่อยู่บน `CanvasItem` → เปลี่ยนไปใช้ `ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", CanvasItem.TEXTURE_FILTER_*)` |
| `UnitResource.gd:79` | เขียน `def can_wear_armor()` — syntax ของ Python ในไฟล์ `.gd` |
| `SkillResource.gd:53,81` | `unit: Dictionary` แต่เรียก `unit.can_use_weapon()` ซึ่ง Dictionary เรียกเมธอดไม่ได้ → เปลี่ยนเป็น `Object` |
| `DataRegistry.gd:130` | `get_all_cards()` อ้างตัวแปร `cards` ที่ไม่เคยประกาศ (และ `cards` เป็นของ `CardDatabase` อยู่แล้ว) → ดึงจาก Rust registry แทน |
| `BattleController.gd:82,89` | `for i, unit_data in party_data:` — GDScript ไม่รองรับ tuple unpacking → `for i in party_data.size():` |
| `BattleController.gd:96` | `sort_custom(self, "_compare_speed")` เป็น API รุ่นเก่า → `sort_custom(Callable(self, "_compare_speed"))` |
| `BattleController.gd:144,168` | lambda หลายบรรทัด ซึ่ง GDScript ไม่รองรับ |
| `BattleController.gd:163,166` | ใช้ตัวแปร `enemies` / `map_data` ที่ประกาศในอีกฟังก์ชันหนึ่ง (scope bug) |
| `GDExtensionManager.gd:42-46` | เรียก `BlinkCombatSystem` / `BlinkAISystem` / `BlinkPathfindingSystem` / `BlinkSaveSystem` — Rust export จริงชื่อ `BlinkCombat` / `BlinkAI` / `BlinkPathfinding` / `BlinkDataRegistry` และ**ไม่มี save system เลย** |
| `GDExtensionManager.gd` | เรียก `.initialize()` บนทุกตัว แต่ Rust ไม่มีเมธอดนี้ |
| `RustCore.gd:41` | ใช้ `class_name` เป็นชื่อตัวแปรใน for-loop ซึ่งเป็น keyword ของ GDScript |
| `Unit.gd`, `GridManager.gd`, `SaveManager.gd` | เรียก `X.is_initialized()` แต่มันเป็น `var` ไม่ใช่ฟังก์ชัน |
| `GridManager.gd:198` | ส่ง `move_type` เป็น String แต่ Rust รับ int (`MoveType`: Walk=0, Fly=1) → เพิ่มตัวแปลง `_move_type_to_int()` |
| `GameManager.gd:19` | เรียก `gdext_manager.initialize()` ซึ่งไม่มีอยู่จริง |
| `UIManager.gd:237` | `log_panel.get_parent().scroll_vertical` — parent คือ CanvasLayer/Control ที่ไม่มีค่านี้ |
| `UIManager.gd` | `extends CanvasLayer` แต่ node ใน scene เป็น `Control` (ดูด้านล่าง) |
| `scenes/units/Unit.tscn` | `sprite_frames` เขียนด้วยรูปแบบ Godot 3 ที่ Godot 4 parse ไม่ได้ → ตัดออก ให้ `Unit.gd::_ensure_sprite_frames()` สร้างแทน (ซึ่งเป็นสิ่งที่รุ่นใหม่เตรียมไว้อยู่แล้ว) |

---

## สิ่งที่ผมเพิ่มทำนอกเหนือจากการรวมสองฝั่ง

1. **`UIManager` กลับเป็น `Control`** — รุ่นที่หลุดเปลี่ยน node เป็น `CanvasLayer` เพื่อให้ตรงกับ `extends CanvasLayer` แต่ลูกทุกตัวใน scene ใช้ `layout_mode`/`anchors` ซึ่ง Godot รับได้เฉพาะเมื่อพ่อเป็น `Control` — ผลคือ Godot **ตัด node ทิ้งเงียบๆ** เปลี่ยนกลับเป็น `Control` ทั้ง scene และสคริปต์ แล้วใช้ `z_index = 100` ให้วางทับสนามรบแทน

2. **`RustCore` เรียกผ่าน `ClassDB.instantiate()`** แทนการอ้างชื่อ class ตรงๆ — ทำให้สคริปต์ compile ได้แม้ตอนที่ยังไม่มีไลบรารี แล้วรายงานเป็น runtime error พร้อมบอกวิธี build แทนที่จะล้มทั้งโปรเจกต์

3. **`save_*` ใน `RustCore` มี null guard** เพราะ Rust ยังไม่ได้ทำ save system

---

## ยังไม่หาสาเหตุ — เปิดค้างไว้

**`LogPanel` และลูกอีก 4 ตัวไม่ถูกสร้างตอน instantiate scene**

```
UIManager/LogPanel                          ← ไม่เกิด
UIManager/LogPanel/LogContainer            ← ไม่เกิด
UIManager/VictoryScreen/VBoxContainer/RewardsContainer  ← ไม่เกิด
UIManager/VictoryScreen/VBoxContainer/ContinueButton   ← ไม่เกิด
UIManager/DefeatScreen/VBoxContainer/RetryButton       ← ไม่เกิด
```

Godot เตือนว่า `Parent path './UIManager/LogPanel' for node 'LogContainer' has vanished`
ขณะที่ node อื่นในไฟล์เดียวกัน (`TurnLabel`, `ActionMenu`, `VictoryScreen` ฯลฯ) สร้างครบ

ที่ลองไปแล้วและ **ตัดออก**:
- ไม่ใช่ syntax ของไฟล์ — ไบต์ตรวจแล้วสะอาด
- ไม่ใช่ `load_steps` — แก้เป็น 6 (ถูกอยู่แล้ว) ไม่ช่วย
- ไม่ใช่สคริปต์ — ถอด `script =` ออกแล้วก็ยังหาย
- ไม่ใช่ `layout_mode` — ทดสอบ ScrollContainer แบบเดียวกันทั้งค่า 1 และ 3 แล้วสร้างครบ
- ตัด node อื่นออกจนเหลือเฉพาะ LogPanel → สร้างครบ (แต่ใส่กลับทั้งหมด → หายอีก) แปลว่าเป็น interaction กับ node อื่น แต่ bisect แบบ binary หา isolate ไม่ได้

**ผลกระทบ:** battle log, รางวัลหลังชนะ, ปุ่ม Continue และ Retry จะไม่โผล่
แก้แค่ไม่ให้ crash (`UIManager.gd` เช็ค null ก่อนใช้) — ยังไม่ได้แก้ที่ต้นเหตุ

---

## เรื่องที่ยังไม่ตรงกัน ต้องให้คุณตัดสินใจ

**1. เวอร์ชัน Godot** — `project.godot` ประกาศ `4.3` แต่ `Cargo.toml` ของ `blink-gdext`
ใช้ `features = ["api-4-6"]` และ `DESKTOP_MIGRATION.md` บอกว่าเคยใช้ 4.7.2
extension ที่ build ด้วย API 4.6 **รันบน 4.3 ไม่ได้** ผมทดสอบด้วย 4.6 เพราะฉะนั้น
ต้องเลือก: เปลี่ยน `project.godot` เป็น 4.6 หรือลด feature ของ crate ลงเป็น 4.3

**2. `res://scenes/ui/MainMenu.tscn`** — `GameManager.gd:33` เรียกไฟล์นี้ แต่ไม่มีอยู่
จะ crash ตอนจบ battle ผมไม่สร้างให้ เพราะเป็นการออกแบบหน้าเมนู ไม่ใช่การตัดสินว่าไฟล์ไหนถูก

**3. ข้อมูลยังว่างทั้งหมด** — `godot/resources/{cards,classes,items,skills,units,weapons}/`
ไม่มีไฟล์ `.tres` เลย battle เลยจบทันทีเป็น "Victory!" เพราะไม่มียูนิตให้สู้
นี่ไม่ใช่บั๊ก แต่คืองานที่ยังไม่ได้ทำ

**4. โครงสร้างข้อมูล unit มี 3 แบบที่ไม่ตรงกัน** — `UnitResource` (Resource ข้อมูลล้วน),
`BattleUnit` (Unit.gd ตัวจริงในเกม), และ `Dictionary` ที่วางไว้ในลายเซ็น
`SkillResource` ยังเรียก `.mp` / `.hp` / `.level` / `.can_use_weapon()` ซึ่งไม่มีใน `UnitResource`
ผมแก้แค่ให้ compile ผ่าน (เปลี่ยนเป็น `Object`) แต่โครงสร้างข้อมูลจริงยังต้องรื้อ

---

## วิธี build สำหรับเครื่องที่ผมใช้

`rust/.cargo/config.toml` บังคับ `linker = "clang"` + `-fuse-ld=lld`
เครื่องนี้ไม่มี clang ผมจึง override ตอน build **โดยไม่แก้ไฟล์ config ของโปรเจกต์**:

```bash
cd rust
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER=cc
export CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_RUSTFLAGS="-C link-arg=-Wl,--as-needed"
export PROTOC=/path/to/protoc          # blink-proto ต้องใช้
cargo build -p blink-gdext
cp target/debug/libblink_gdext.so ../godot/addons/blink_core/bin/
```

ต้องมี `protoc` ด้วย ไม่งั้น `blink-proto` build ไม่ผ่าน (error: `Could not find protoc`)

ถ้าจะ build บนเครื่องที่มี clang/lld อยู่แล้ว ใช้คำสั่งปกติ `cargo build -p blink-gdext` ได้เลย
