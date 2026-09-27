# บันทึกส่งมอบ: Blink Arcana สำหรับ Desktop

**สถานะ ณ 28 กันยายน 2026** — แก้ในสำเนาทำงานจาก ZIP ต้นฉบับ ไม่เขียนทับไฟล์ที่อัปโหลด

## สรุปสถานะ

| รายการ | ผลตรวจ |
|---|---|
| Host ที่สร้าง | Ubuntu Linux x86_64 |
| Godot | 4.7.2 stable; project ใช้ Rust `godot` crate กับ API 4.6 |
| Rust/Cargo | 1.98.1 |
| `cargo test --workspace` | ผ่าน: 26 tests; ก่อนหน้านี้พบและแก้ 3 ปัญหาใน guard/pathfinding และแก้ test ที่ตั้งเงื่อนไขการเดินอ้อมไม่ถูกต้อง |
| Linux x86_64 GDExtension | สร้าง `libblink_gdext.so` ได้ และวางใน path ที่ manifest ระบุ |
| Asset checker | `bash -n` ผ่าน และรายงานไม่พบ static asset references ที่หาย |
| Godot headless editor import | ผ่านโดยไม่มี GDScript parse errors; พบ warning เรื่อง parent path ของ `LogContainer` ใน `BattleScene.tscn` ซึ่งต้องตรวจต่อ |
| Runtime/gameplay | **ยังไม่รับรอง** — smoke run เต็มก่อนหน้าพบ node path ของ UI ผิด/หาไม่พบ; หลังจากนั้นแก้ fallback map, empty-battle handling, registry guard และ save/base64 แล้ว แต่ยังไม่ได้รัน gameplay smoke ซ้ำก่อนแพ็ก |
| Windows/macOS/Android export | ไม่ได้ build/test เพิ่มในรอบนี้; มีไฟล์ Android ARM64 เดิมแนบไว้ตามด้านล่าง |

## ไฟล์ native และ target

- `godot/addons/blink_core/bin/linux-x86_64/libblink_gdext.so` — สร้างใหม่บน host x86_64 และยืนยันว่าเป็น ELF x86-64
- `godot/addons/blink_core/bin/android-arm64/libblink_gdext.so` — เก็บไลบรารี ARM64 จาก ZIP ไว้ที่ target Android; `readelf` พบ `.note.android.ident` และ AArch64 จึงไม่ใช่ไลบรารีที่ Linux x86_64 จะโหลดได้
- `godot/addons/blink_core/blink_core.gdextension` — แยก path ตาม OS/architecture, ใช้ `gdext_rust_init` ซึ่งตรงกับ `godot-rust` และกำหนด API ขั้นต่ำ 4.6

ไฟล์ Android ARM64 เป็นของเดิมที่เก็บรักษา ไม่ได้ rebuild หรือทดสอบบนอุปกรณ์ Android ในงานนี้ ส่วน path Windows/macOS/Android x86_64/Web ใน manifest ยังต้องใส่ artifact ให้ครบก่อน export target เหล่านั้น

## การเปลี่ยนแปลงสำคัญในสำเนานี้

- ปรับค่าเริ่มต้น Godot ให้เปิดหน้าต่าง desktop และเลือก window mode ผ่าน Godot 4 API; เพิ่มไอคอน SVG และ placeholder unit sprite ของโปรเจกต์เอง
- แก้ GDScript/Godot 4 ที่ขัดขวางการ compile: ชนกันระหว่างชื่อ autoload กับ native class, autoload เปลี่ยนชื่อเป็น `RustBridge` แต่ยังชี้ไปไฟล์ `GDExtensionManager.gd`, syntax/indentation/loop/API บางจุด, การเรียก `DataRegistry.is_ready` และการผูก scene node
- เพิ่ม Rust↔Godot adapter calls ให้ตรงกับชื่อ class/method ที่มีใน native extensionเท่าที่ binding ปัจจุบันเปิดไว้
- แก้ Rust guard ให้ใช้ integer floor ตาม unit test; แก้ pathfinding A* ให้ใช้ `i64` และ blocked-edge penalty ที่ไม่ overflow; เพิ่ม/แก้ tests ให้ตรวจ detour และทางตันอย่างตรงความหมาย
- แก้ `scripts/asset-check.sh` ให้ตรวจ static paths ได้โดยไม่ตีความ `%s` ใน dynamic resource path เป็นไฟล์จริง
- แก้ runtime error บางส่วนที่พบใน smoke run: ไม่พยายามโหลด map ที่ไม่มี, ไม่ประกาศชัยชนะเมื่อไม่มี party/enemies, ตรวจชนิดข้อมูลจาก Rust registry ก่อนอ่าน และใช้ `Marshalls`/สร้างโฟลเดอร์เซฟ

> การแก้เหล่านี้ทำให้ **build และ editor import** ผ่าน แต่ไม่ได้เปลี่ยนเกมให้เป็น vertical slice ที่เล่นจบได้: Rust binding บางตัวใน `rust/crates/blink-gdext/src/lib.rs` ยังเป็น stub, ยังไม่มี map `.tres`/unit resources จริงครบชุด และ UI path warning ยังต้องตรวจใน runtime

## สร้างซ้ำบน Linux x86_64

จาก root ของโปรเจกต์:

```bash
./scripts/build-linux-x86_64.sh
```

สคริปต์จะรัน `cargo test --workspace`, build `blink-gdext`, คัดลอกไลบรารีไป target folder, ตรวจ asset references และเปิด Godot headless editor เพื่อตรวจ import/parse

**เครื่องมือที่ต้องมี:** Rust/Cargo ที่เข้ากับ `rust-toolchain.toml`, `clang`, `ld.lld`, `protoc` และ Godot 4.6 ขึ้นไป; workspace ล็อก dependency ผ่าน `rust/Cargo.lock`. หากต้องการ build release เอง:

```bash
cd rust
cargo build --release -p blink-gdext
```

จากนั้นคัดลอก `rust/target/release/libblink_gdext.so` ไป `godot/addons/blink_core/bin/linux-x86_64/libblink_gdext.so` (หรือเพิ่มโหมด release ใน build script)

## สิ่งที่แนะนำให้ทำต่อ

1. เปิด `BattleScene.tscn` ใน Godot แล้วแก้ warning parent path `./UIManager/LogPanel` / ตรวจว่า `UIManager` ได้ child nodes ที่คาดไว้ใน runtime
2. รัน runtime smoke test ด้วย `godot --headless --path godot --quit-after 120`; แก้ node lookup ทั้ง `LogPanel` และ `VictoryScreen/VBoxContainer/RewardsContainer` หากยังเกิด
3. เพิ่ม map resource และ unit/party/enemy `.tres` หรือ fixture ที่ชัดเจน แล้วทำ battle vertical slice 1 ผู้เล่น + 1 ศัตรู ก่อนเติม content
4. แทน Rust binding stubs ของ combat/AI/pathfinding/stats ด้วยการเรียก `blink-core`; ทดสอบ contract ของข้อมูล GDScript↔Rust ก่อนใช้ผลใน gameplay
5. ยืนยัน Godot export สำหรับ Android ARM64 บนอุปกรณ์/CI และ build target Windows/macOS แยกตาม architecture; อย่านำ `.so` ของ Android ไปใช้แทน Linux desktop
6. เลือกและนำเข้า asset หลังอนุมัติ art direction; ดูใบอนุญาต/credits และตัวเลือก 5 ชุดใน [รายงานวิจัยเกมและ asset](../../deliverables/วิจัยเกมและตัวเลือก-assets.md)

**ขอบเขตการยืนยัน:** ผ่าน build/test ที่ระบุในตารางเท่านั้น ไม่ใช่การรับรองเกมเต็มรูปแบบ, Android APK หรือ legal opinion
