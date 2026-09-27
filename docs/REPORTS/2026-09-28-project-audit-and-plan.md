# รายงานตรวจโปรเจกต์และแผนงาน: Blink Arcana

**ตรวจจาก:** `bl1nk-arcana.zip` — สแกนไฟล์ 135 รายการ  
**วันที่ตรวจ:** 28 กันยายน 2026  
**ขอบเขต:** อ่านเอกสารและโค้ดสำคัญ, ตรวจ static findings, ทดลอง Godot headless, ตรวจ shell script และค้นแหล่ง asset/เอกสารทางการ  
**ข้อจำกัด:** ไม่ได้แก้ไฟล์ในต้นฉบับ; Rust test/build ยังรันไม่ได้เพราะ sandbox ไม่มี `cargo`/`rustc`

## สรุปสำหรับตัดสินใจ

Blink Arcana วางทิศทางเป็น **Tactical RPG + Roguelike** ใช้ Godot 4/GDScript ทำ scene, UI และ input; ใช้ Rust GDExtension ทำ combat, AI, pathfinding และข้อมูลเกม โครงสร้างและเอกสารตั้งใจไว้ดี มี PDR/GDD/specs, CI, asset pipeline และระบบ AI/personality ที่วางกรอบไว้แล้ว

อย่างไรก็ตาม สถานะจาก ZIP นี้ยังเป็น **ต้นแบบเชิงโครงสร้าง ไม่ใช่เกมที่พร้อมรันทดสอบ**: Godot เปิดโปรเจกต์จากไฟล์เดิมไม่ผ่าน, เมื่อแก้เฉพาะ syntax ในสำเนาชั่วคราวแล้วพบ GDScript parse/API errors อีกหลายจุด, Native library ไม่ตรงสถาปัตยกรรมเครื่องตรวจ, binding มีส่วนที่คืนค่า stub และไม่มี game assets ในโฟลเดอร์ assets เลย ดังนั้น **ยังไม่ควรเพิ่มจำนวนคลาส/การ์ด/แผนที่** ก่อนสร้าง buildable vertical slice ให้ผ่านก่อน

> **ข้อเสนอหลัก:** ทำให้โปรเจกต์เปิดและเชื่อม Godot↔Rust ได้จริง → ทำ battle loop ขนาดเล็กหนึ่งฉาก → ยืนยันด้วย tests/CI → จึงเลือก art direction และเติม assets/content

## สิ่งที่ตรวจพบ

### จุดแข็งที่ควรรักษา

- แยก Rust `blink-core` ออกจาก Godot binding มีแนวโน้มทำให้ logic ทดสอบแยกได้
- มีแผนระบบ grid/pathfinding, combat, AI intention/personality และ data pipeline ไว้แล้ว
- มี PDR, GDD, system specs, runbooks, glossary, task plan และ CI configuration เป็นฐานให้จัดขอบเขตงาน
- มี unit tests ใน Rust โดยเฉพาะ pathfinding, stats และ AI (ตรวจพบ test annotations 29 จุดจาก grep) แต่ยังยืนยันผลผ่านจริงไม่ได้
- มีสคริปต์ตรวจ asset และรูปแบบโฟลเดอร์กำหนดไว้ แม้ตัวตรวจ asset มี syntax error ที่ต้องแก้

### ประเด็นขวางทาง เรียงตามความเร่งด่วน

| ระดับ | สิ่งที่พบ | ผลกระทบ/การดำเนินการ |
|---|---|---|
| **P0** | `godot/project.godot` ใช้ `PackStringArray(...)` แทน `PackedStringArray(...)` และประกาศ `config/features` ซ้ำ | Godot 4.7.2 headless รายงาน parse error ที่ project settings ตั้งแต่เริ่ม; แก้ config แล้วรัน import/parse ใหม่ |
| **P0** | GDScript หลายไฟล์ parse ไม่ผ่านหรือเรียก API ผิดรูปแบบ | ในสำเนาชั่วคราวที่แก้เฉพาะชื่อ `PackedStringArray` พบ parse errors เพิ่ม เช่น loop syntax, ternary แบบ `? :`, class_name ชนชื่อ autoload, method static/instance ไม่ตรง, `get_class()` ชน method ของ Godot, preload แบบไม่ใช่ constant และ resource/API ที่หาไม่พบ; ควรแก้จน `godot --headless --editor --path godot --quit` ผ่านโดยไม่มี parse error |
| **P0** | GDExtension เชื่อมไม่ตรงกัน | manifest ตั้ง `entry_symbol = "gdextension_init"` แต่ไลบรารีที่ให้มา export `gdext_rust_init`; คู่มือ godot-rust ระบุ entry symbol เริ่มต้นเป็น `gdext_rust_init` จึงต้องปรับให้ตรงกันและ rebuild |
| **P0** | Native library ใน ZIP เป็น **ARM aarch64** แต่เครื่องตรวจเป็น **x86_64** | ไลบรารีที่แนบมาใช้แทน build ของเครื่อง x86_64 ไม่ได้; ควรเลิก commit binary เดียวที่ไม่รู้ target หรือสร้าง build artifact แยก OS/architecture ผ่าน CI |
| **P0** | GDScript คาดหวังคลาส `BlinkCombatSystem`, `BlinkAISystem`, `BlinkPathfindingSystem`, `BlinkSaveSystem` ฯลฯ แต่ Rust สร้างคลาสชื่อ `BlinkCombat`, `BlinkAI`, `BlinkPathfinding`, `BlinkStats`, `BlinkDataRegistry` | ต้องกำหนด API contract เดียวก่อนแก้สองฝั่ง รวมทั้ง signatures, ชนิดข้อมูลและ error behavior |
| **P0** | Rust binding บาง endpoint ยังเป็น stub | `resolve_combat` สร้างผล `

| **P0** | Rust binding บาง endpoint ยังเป็น stub | `resolve_combat` คืน damage 0, AI คืน `wait`, pathfinding คืน array ว่าง และ damage คืน 0; แม้ core logic บางส่วนมีอยู่ แต่ game layer เรียกผ่าน binding แล้วจะยังไม่ได้ผลตามระบบจริง |
| **P1** | ยังไม่มี game assets/resource จริง | `godot/assets` ไม่มีไฟล์ และ `godot/resources` ไม่มี `.tres`; `Unit.tscn` อ้าง `placeholder.png` ที่ไม่มี และ project icon ก็ชี้ไฟล์ที่ไม่มี |
| **P1** | `scripts/asset-check.sh` syntax ไม่ผ่าน | `bash -n` ชี้ error บรรทัด 47; ต้องแก้ก่อนนำ asset gate เข้า CI |
| **P1** | การสุ่มใน combat เป็น placeholder | `hit = hit_chance > 5` ไม่ได้สุ่มตามโอกาส และ crit ใช้เงื่อนไข `crit_rate > 50` ทั้งที่ GDD ระบุสูงสุด 35%; ใช้ RNG ที่กำหนด seed ได้และทดสอบซ้ำได้ |
| **P1** | สถานะงานในเอกสารไม่สอดคล้อง | `TASK_PLAN.md` ยังมี checkbox งาน 49 รายการไม่เสร็จ แต่ PDR/decision audit สื่อว่า foundation/Phase 1 จบแล้ว; ให้ยืนยันจาก build/tests ที่ผ่านจริง |
| **P2** | ลิงก์ใน README บางรายการชี้ผิดตำแหน่ง | `SKILL_SYSTEM.md` และ `CHARACTER_TEMPLATE.md` อยู่ใน `templates/`; แก้ลิงก์เพื่อให้ onboarding ใช้ได้ |
| **P2** | Design ยังไม่ล็อก | GDD เรียกธาตุ 5 ธาตุ แต่ตารางมี Fire/Water/Wind/Earth/Light/Dark (6) + Neutral; terrain บางค่าขึ้น `XXX` และ accessory ยังไม่ finalize |

**หมายเหตุ:** `docs/decision_audit.csv` มีประเด็น unwrap/FFI/CI ที่ควรตรวจต่อ แต่ตัวเลขชั่วโมงและความเสียหายทางธุรกิจในไฟล์ยังไม่มีหลักฐานอิสระรองรับ จึงไม่ควรนำไปอ้างเป็นข้อเท็จจริง

## สกิลที่ให้มา: ใช้ทำอะไรกับงานนี้ได้บ้าง

ระบุ `writing-prds` ซ้ำสองครั้ง; การซ้ำไม่ได้เพิ่มความสามารถใหม่

| สกิล | ความเหมาะสม | วิธีใช้กับโปรเจกต์ |
|---|---|---|
| **writing-prds** | **สูง / ทันที** | ย่อย PDR/GDD เป็น one-pager สำหรับ vertical slice: ปัญหา, เป้าหมาย, non-goals, metrics, acceptance criteria; ช่วยรวมเอกสารซ้ำและแก้ขอบเขต |
| **json-canvas** | **สูง / ทันที** | วาด architecture/dependency, data/API flow และแผน implementation ใน Obsidian Canvas |
| **skill-creator** | **ปานกลาง-สูง** | สร้าง skill เฉพาะ repo เพื่อให้ AI อ่าน spec ก่อนแก้, ตรวจ API contract, ห้าม stub/unwrap และรัน quality gates; ต้องระบุตัวอย่างการใช้งานก่อน |
| **video-generator** | **ปานกลาง / ภายหลัง** | ทำ teaser/devlog เมื่อมี gameplay/ภาพชัด ต้องระบุผู้ชม, narrative, ความยาว, style, เสียง และยืนยันแผนก่อน generation; ไม่ได้แก้เกมหรือทำ sprite production โดยตรง |
| **stitch-extract-design-md** | **ต่ำ** | ออกแบบมาสกัด design system จาก frontend (React/Vue/CSS); repo นี้เป็น Godot/Rust จึงใช้ได้เพียงเป็นแนวทาง ไม่ควรคาดหวังอ่าน `.tscn/.gd` ได้ตาม workflow |
| **gsap-plugins** | **ต่ำในเกมหลัก** | GSAP เหมาะเว็บ DOM/SVG/Pixi; ไม่ควรนำมาเป็น tween หลักของ Godot; อาจใช้กับ landing page/devlog แยกในอนาคต |
| **example-skill** | **ต่ำ-ปานกลาง** | เป็นตัวอย่าง Claude Code plugin skill ใช้ดู trigger/examples ได้ แต่สร้าง Manus skill จริงควรใช้ workflow ของ `skill-creator` |
| **financial-analysis** | **ไม่ตรงโจทย์** | ใช้ข้อมูลหุ้น/งบ/ตลาดจริง ไม่ใช่ balance combat หรือกำหนดราคาไอเทมในเกม |

## Asset research: shortlist และข้อควรระวัง

ยังไม่ได้ดาวน์โหลดหรือติดตั้ง asset ในโปรเจกต์ เพราะ art direction และขนาด tile ยังไม่ล็อก

| แหล่ง | เหมาะกับ | ใบอนุญาต/ข้อควรระวัง | คำแนะนำ |
|---|---|---|---|
| [Toen’s Medieval Strategy Sprite Pack (OpenGameArt)](https://opengameart.org/content/toens-medieval-strategy-sprite-pack-v10-16x16) | 16×16 tactical/RPG; terrain, buildings, roads, rivers, bridges, soldiers, siege, effects, GUI | CC BY 4.0; ใช้เชิงพาณิชย์/ดัดแปลงได้เมื่อให้เครดิตตามไฟล์ attribution และลิงก์ source | ตัวเลือกแรกสำหรับ battlefield prototype; เก็บ license/เครดิตใน repo |
| [Kenney UI Pack](https://kenney.nl/assets/ui-pack) | UI placeholder: 430 sprites สำหรับ buttons/panels/sliders | CC0 ตามหน้าแพ็ก; commercial use และไม่บังคับเครดิตตาม [Kenney FAQ](https://kenney.nl/support); ห้ามใช้โลโก้ Kenney | ใช้ prototype ได้ แต่ตรวจความเข้ากันกับ pixel-art style ก่อน |
| [Kenney asset catalog](https://kenney.nl/assets) / [หมวด Audio](https://kenney.nl/assets/category:Audio) | สำรวจ sprites, tiles, icons, SFX/music | Kenney ระบุ asset packs เป็น CC0; ตรวจ license file ที่มากับ download อีกครั้ง | ใช้ทำ shortlist ของ placeholder/SFX และบันทึกชื่อไฟล์ที่นำเข้า |
| [Summer Forest — Seliel](https://seliel-the-shaper.itch.io/summer-forest) | 16×16 forest tile สไตล์ SNES; มี sample ฟรี ส่วนแพ็กเต็มหน้าเว็บระบุ $19.99 | [User license](https://selieltheshaper.weebly.com/user-license.html) มีข้อห้ามใช้ผลงานร่วมกับ AI-generated image, writing, code หรือสื่อ AI อื่น | ไม่แนะนำให้ใช้กับ repo นี้จนตรวจ provenance/ขออนุญาต เพราะมี AI-assisted workflow ตามเอกสาร |

**Asset workflow ที่แนะนำ:** เลือก art style/tile size → เลือกแพ็กเดียว → สร้าง `ASSET_CREDITS.md` (ผู้สร้าง, URL, license, ไฟล์ที่ใช้, การดัดแปลง) → ทำ tilemap test scene หนึ่งฉาก → ตั้ง pixel import ให้คม (nearest/no filtering) → แก้ `asset-check.sh` และเพิ่มการตรวจเข้า CI

## แผนงานที่แนะนำ

### Gate 0 — ทำให้ Godot เปิดโปรเจกต์ได้ (P0)

1. ล็อก version matrix: Godot, `godot` crate/API feature, Rust toolchain, OS/architecture
2. แก้ `project.godot` syntax และ GDScript parse errors ทั้งหมด; แยกชื่อ `class_name` จาก autoload และแก้ static/instance calls
3. ให้ manifest `entry_symbol`, platform paths และไลบรารีที่ build ตรงกัน; สร้าง library ของ target จริง ไม่ใช้ ARM `.so` กับ x86_64
4. แก้ทุก scene/resource path ให้ชี้ไฟล์จริง และให้ headless import ทำงานใน CI แทน `echo` placeholder

**ผ่าน Gate เมื่อ:** `godot --headless --editor --path godot --quit` จบโดยไม่มี parse/resource errors และโหลด GDExtension บน target ที่กำหนดได้

### Gate 1 — เชื่อม Rust↔Godot และทดสอบ logic

1. ทำ contract ระบุ class/method/arguments/returns/error schema เป็นแหล่งอ้างอิงเดียว
2. ทำชื่อคลาส/signatures ให้ตรงกันและแทนที่ stub ด้วยการเรียก `blink-core`
3. ทำ RNG injectable/seedable และทดสอบ hit/crit/guard/element/heal/HP clamp
4. เพิ่ม boundary tests; ลด unchecked `unwrap`/panic บน production path ให้ตรงกฎ PDR

**ผ่าน Gate เมื่อ:** `cargo test --workspace`, GDExt build และ smoke tests ของ API ผ่าน; seed เดิมให้ผลเดิม

### Gate 2 — Playable vertical slice

สร้างสนาม 8×8 หนึ่งฉาก, player/enemy อย่างละ 1–2 ตัว: เลือก unit → เห็นช่องเดิน → เดิน → โจมตี → enemy turn → win/lose พร้อม HP/turn/action feedback

**ผ่าน Gate เมื่อ:** คนอื่นเล่นจบ battle โดยไม่ใช้ console และผล combat ตรงสูตร GDD; มี test สำหรับ blocked/occupied tile, unit ตาย, turn จบและไม่มี action ที่ถูกต้อง

### Gate 3 — Art และ content

เลือก palette/tile size/style → เติม asset ที่ license compatible และเครดิตครบ → เพิ่ม map/enemy/class/card จาก playtest → แก้ GDD จำนวนธาตุ, terrain, accessory, task status และ README links ให้ตรงกับ build ล่าสุด

> อย่าเพิ่มหลายคลาส/แผนที่ก่อน Gate 2 ผ่าน; สามารถทำ license research และเลือก art direction ขนานกับการแก้ระบบได้ แต่ยังไม่ควรผสาน asset โดยไม่ลงทะเบียนแหล่งที่มา

## งานที่ช่วยทำต่อได้โดยตรง

1. แก้ P0 ให้ project parse/เปิดได้ พร้อมรัน Godot headless รอบต่อรอบ
2. ทำ API contract และแก้ Rust binding stub โดยยึด `blink-core` เป็น source of truth
3. ทำ tests สำหรับ combat/pathfinding/AI และ FFI หลังมี Rust toolchain
4. เขียน PRD สำหรับ playable slice จาก PDR/GDD พร้อม acceptance criteria/non-goals
5. เลือก/นำเข้า asset prototype พร้อม license ledger และ scene ทดสอบ หลังยืนยัน art direction
6. สร้าง project-specific skill ให้การช่วยเขียนโค้ดตรวจ spec และ quality gates

## แหล่งอ้างอิง

- [Godot 4.4: GDExtension docs](https://docs.godotengine.org/en/4.4/tutorials/scripting/gdextension/index.html) — แนวคิด extension/manifest
- [godot-rust book: Hello World](https://godot-rust.github.io/book/intro/hello-world.html) — build, `.gdextension`, entry symbol และ class registration
- [Kenney UI Pack](https://kenney.nl/assets/ui-pack) และ [Kenney license FAQ](https://kenney.nl/support)
- [OpenGameArt: Toen’s Medieval Strategy Sprite Pack](https://opengameart.org/content/toens-medieval-strategy-sprite-pack-v10-16x16)
- [Seliel: Summer Forest](https://seliel-the-shaper.itch.io/summer-forest) และ [Mana Seed User License](https://selieltheshaper.weebly.com/user-license.html)

## หมายเหตุการยืนยันผล

- แตก ZIP ไป workspace แยก; ไม่แก้ source project
- Godot 4.7.2 headless ล้มเหลวตั้งแต่ project settings; สำเนาชั่วคราวที่แก้เฉพาะ `PackStringArray` ยังพบ parser/API errors ต่อเนื่อง
- `bash -n scripts/asset-check.sh` พบ syntax error ที่บรรทัด 47
- `file`/`nm` ยืนยันไลบรารีเป็น ELF AArch64 และ export `gdext_rust_init`; host เป็น x86_64; manifest ระบุ `gdextension_init`
- `cargo test --workspace` ยังรันไม่ได้เพราะไม่มี `cargo`/`rustc`; ผล Rust build/test **ยังไม่ยืนยัน**
- Asset source เป็นคำแนะนำจากหน้าเจ้าของ/ผู้เผยแพร่ที่ตรวจ ณ วันที่รายงาน ไม่ได้ติดตั้งหรือฝังแพ็กใน repo; รายงานไม่ใช่ security audit/legal opinion

**สรุป:** ใช้ `writing-prds` + `json-canvas` วางขอบเขตและแผน, ใช้ `skill-creator` เมื่อระบุ use case ชัด; แก้ P0 และทำ battle slice ให้เล่นได้ก่อน ส่วน GSAP/Stitch/financial-analysis ไม่ควรฝืนใช้กับโค้ดเกม Godot นี้

**ไม่มีการซื้อ asset หรือเปลี่ยนแปลง/เผยแพร่ข้อมูลภายนอก**
