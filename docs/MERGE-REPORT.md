# ผลการตัดสินใจรวมไฟล์ — 28 กันยายน 2026

## สรุปสั้น

ของที่หลุดออกมาจาก export รอบก่อน **ไม่ใช่ของเก่า** — เป็นรุ่นที่ผ่านการแก้หลังรัน `godot --headless` ไปแล้ว (ตรงกับบันทึกใน `DESKTOP_MIGRATION.md`) ส่วนชั้นที่อยู่ในโครงสร้างเดิมคือรุ่น**ก่อนแก้**

หลักฐาน: autoload ทั้ง 8 ตัวในชั้นเดิมมี `class_name` ตรงกับชื่อ autoload ตัวเอง ซึ่ง Godot 4 ปฏิเสธที่จะโหลด → เปิดโปรเจกต์ไม่ได้เลย รุ่นที่หลุดถอดออกหมด 7 ตัว (เหลือ `GDExtensionManager` ที่ไม่ได้แก้ ผมแก้ให้)

**สรุป: เอารุ่นที่หลุดมาเป็นหลัก แล้วแก้กลับสิ่งที่รุ่นนั้นพังเอง 5 จุด**

---

## ตารางตัดสินใจ 17 ไฟล์

| ไฟล์ | ตัดสิน | เหตุผล |
| --- | --- | --- |
| `autoload/AudioManager.gd` | **ของหลุด** + คืน 2 ส่วน | รุ่นเดิมเรียก `$BGMPlayer` ที่ autoload ไม่มี child node → null; รุ่นหลุดสร้าง player ตอน runtime + กัน log(0) + ทำโฟลเดอร์ `user://settings` แต่ตัด sfx จาก 16 เหลือ 11 และลบ crossfade ของ BGM → คืนรายการเต็มและ crossfade |
| `autoload/CardDatabase.gd` | **ของหลุด** | รุ่นเดิมประกาศ `var class_name = ...` ซึ่งเป็น keyword ของ GDScript → parse error; รุ่นหลุดเปลี่ยนชื่อเป็น `unit_class_name` และแก้ `is_ready` จากเรียกเป็นฟังก์ชันเป็นอ่าน property (ตรงกับ `var is_ready` จริง) |
| `autoload/ClassDatabase.gd` | **ของหลุด** | รุ่นเดิมใช้ `static func` บน autoload instance + ตั้ง `class_name ClassDatabase` ชนกับ autoload; รุ่นหลุดเป็น instance จริง เปลี่ยน `get()` → `get_class_resource()` |
| `autoload/DataRegistry.gd` | **ของหลุด** + คืน 2 ส่วน | ตัด `class_name` ชน autoload, `get_class()` → `get_class_resource()` (ชนกับ `Object.get_class()`), เพิ่ม guard `is Dictionary`; แต่ทิ้ง `get_all_cards()` ให้คืน `[]` และเรียก `RustBridge` ที่ไม่มีจริง → คืนทั้งคู่ |
| `autoload/GameManager.gd` | **ของหลุด** | ต่างกันแค่ถอด `class_name` + เพิ่ม newline ท้ายไฟล์ |
| `autoload/SaveManager.gd` | **ของหลุด** + แก้กลับ 1 | รุ่นหลุดเพิ่ม `DirAccess.make_dir_recursive` (โฟลเดอร์ `user://saves` ไม่มีจริง), เปลี่ยน `encode_base64()` → `Marshalls.raw_to_base64()` (Godot 4.3+ ถอดฟังก์ชันเดิมแล้ว), แก้ JSON parse; แต่เรียก `RustBridge` → แก้กลับ |
| `autoload/SettingsManager.gd` | **ของหลุด** + คืน 1 บรรทัด | รุ่นหลุดแก้ `window_set_mode()` ให้ใช้ค่าคงที่ `WINDOW_MODE_*` จริง (รุ่นเดิมส่งเลขดิบ `0/1/2` ซึ่งผิดค่าความหมาย) และเปลี่ยน default fullscreen เป็น windowed; แต่ทิ้งบรรทัด `set_default_texture_filter` → คืน |
| `autoload/GDExtensionManager.gd` | **ฐาน + แก้เพิ่ม** | ไม่อยู่ในชุดที่หลุดเลย ยังมี `class_name GDExtensionManager` ชน autoload → ถอดออก |
| `battle/GridManager.gd` | **ของหลุด** + แก้กลับ 1 | รุ่นหลุดเพิ่ม `ResourceLoader.exists()` guard, พิมพ์ `Array[Dictionary]` ถูกต้อง, เปลี่ยน `enumerate()` → `range()`; เรียก `RustBridge` → แก้กลับ |
| `battle/UnitManager.gd` | **ของหลุด** + แก้กลับ 1 | รุ่นหลุดเปลี่ยนจากอ้าง autoload เป็น `@onready var grid_manager = get_node(...)` (ปลอดภัยกว่า ไม่ต้องพึ่งลำดับ autoload) และตัด `.bind()` ที่ Godot 4 ไม่ต้องใช้; เรียก `RustBridge` → แก้กลับ |
| `resources/ClassResource.gd` | **ของหลุด** | เรียก `ClassDatabase.has_class()` / `get_class_resource()` ตรงกับชื่อฟังก์ชันใหม่ — **ต้องไปพร้อมกับ ClassDatabase.gd** |
| `resources/ItemResource.gd` | **ของหลุด** | เปลี่ยนพารามิเตอร์จาก `Dictionary` เป็น `BattleUnit` ให้ตรงกับชนิดที่ส่งจริง |
| `resources/WeaponResource.gd` | **ของหลุด** | เหมือนกันข้างบน |
| `ui/UIManager.gd` | **ของหลุด** + แก้กลับ 1 | รุ่นหลุดต่อ signal ปุ่มทั้ง 6 ตัว (รุ่นเดิมไม่ต่อเลย = ปุ่มกดไม่ทำงาน), แก้ path `action_menu.get_node("VBoxContainer")` ให้ตรงกับโครงสร้างใน `BattleScene.tscn` (รุ่นเดิมอ้าง `MoveButton` ที่อยู่ใต้ VBox), เปลี่ยน `get_camera_2d()` → `get_visible_rect()` (พังถ้าฉากไม่มี Camera2D); เรียก `RustBridge` → แก้กลับ |
| `units/Unit.gd` | **ของหลุด** | เพิ่ม `_ensure_sprite_frames()` โหลด placeholder ให้เอง (รุ่นเดิมพึ่ง sprite frame ที่ไม่มี), เพิ่ม `die()`, แก้ `get_class` → `get_class_resource` |
| `scenes/battle/BattleScene.tscn` | **ของหลุด** + คืน 2 บรรทัด | รุ่นเดิมประกาศ `UIManager` เป็น `Control` แต่สคริปต์ `extends CanvasLayer` → ชนิดไม่ตรง; รุ่นหลุดแก้เป็น `CanvasLayer` แต่ทิ้ง `drag_enabled` ของกล้องไป → คืน; ส่วน `sub_resource Shader_1` ที่รุ่นหลุดลบออก **ไม่ต้องคืน** เพราะไม่มี node ไหนอ้างถึงเลยเป็น dead code |
| `scripts/asset-check.sh` | **ของหลุด** | resolve path จาก `BASH_SOURCE` (รุ่นเดิม hardcode และพิมพ์ ANSI escape ที่ขาดเครื่องหมาย `\`) |
| `.gitignore` | **ของหลุด** | รุ่นเดิม ignore `Cargo.lock` ทั้งที่โปรเจกต์มี binary (`blink-gdext` เป็น cdylib) และมีไฟล์ lock อยู่จริง → ควร commit lock |

---

## บั๊กที่แก้เพิ่ม ไม่ใช่การรวมสองฝั่ง

`GDExtensionManager.is_initialized` ประกาศเป็น `var is_initialized: bool` แต่ทั้งสองรุ่นเรียกเป็น `GDExtensionManager.is_initialized()` — GDScript จะโยน `Invalid call. Nonexistent function 'is_initialized'` ตอนรัน แก้เป็นอ่าน property ใน 5 ไฟล์:

`DataRegistry.gd` · `GameManager.gd` · `SaveManager.gd` · `SettingsManager.gd` · `GridManager.gd`

และ `Unit.tscn` ชี้ `placeholder.png` ที่ไม่มีไฟล์ (มีแต่ `.svg`) → ชี้ไป `.svg` ให้ตรงกับ `Unit.gd`

---

## `RustBridge` — เรื่องเดียวที่ต้องรู้

รุ่นที่หลุดเรียก `RustBridge` 9 จุด แต่ **`RustBridge` ไม่มีอยู่ในโปรเจกต์เลย** ไม่มีใน autoload ไม่มีในสคริปต์ไหน และ `project.godot` ก็ประกาศ autoload ชื่อ `GDExtensionManager` เท่านั้น

ดูเหมือนเป็นการ rename ที่ทำค้างไว้ครึ่งทาง ผมแก้กลับทั้งหมดเป็น `GDExtensionManager` และเช็คแล้วว่า method ที่ถูกเรียกทั้งหมด (`combat_resolve`, `combat_get_damage_preview`, `pathfinding_get_reachable`, `get_save_system`, `call_rust`, `get_data_registry`) มีอยู่จริงใน `GDExtensionManager.gd`

**ถ้าตั้งใจจะเปลี่ยนชื่อจริง** ต้องแก้ `project.godot` ด้วย ไม่งั้น autoload จะไม่มีตัวนี้

---

## ยังไม่แก้ — รอคุณตัดสินใจ

`GameManager.gd` บรรทัด 33 เรียก `change_scene("res://scenes/ui/MainMenu.tscn")` แต่ไม่มีไฟล์นี้ → จะ crash ตอนจบ battle

ผมไม่สร้างให้ เพราะเป็นการแต่งคอนเทนต์ใหม่ (ต้องออกแบบหน้าเมนู, ปุ่ม, flow) ไม่ใช่การตัดสินใจว่าไฟล์ไหนดีกว่า — อันนี้เป็นงานออกแบบ

ทางแก้ชั่วคราวถ้าอยากให้รันได้ก่อน: เปลี่ยนเป็น `change_scene("res://scenes/battle/BattleScene.tscn")` หรือ guard ด้วย `ResourceLoader.exists()`

---

## ไฟล์ต้นฉบับทั้งสองฝั่งยังอยู่

- `_incoming/from-loose-root/` — รุ่นที่หลุด (ต้นแบบที่เอามา)
- `_incoming/from-base/` — รุ่นเดิมก่อน merge (ไว้ diff ย้อนกลับ)

diff ย้อนหลัง:

```bash
diff -u _incoming/from-base/godot/scripts/units/Unit.gd godot/scripts/units/Unit.gd
```
