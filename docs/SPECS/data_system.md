# Spec Sheet: Data System
**Feature ID:** DATA-001
**Status:** Draft
**Priority:** P0 (Core)
**Owner:** Lead Developer
**Created:** 2026-09-27
**Last Updated:** 2026-09-27

---

## 1. Overview
ระบบโหลดข้อมูลเกม (Units, Classes, Skills, Weapons, Maps, Items) จากไฟล์ JSON และ Godot .tres แปลงเป็น Protobuf สำหรับ Core Logic และ GDExtension

---

## 2. Scope
### In Scope
- Data Registry (Singleton Cache)
- JSON Loader (Units, Classes, Skills, Weapons, Items, Maps)
- Godot .tres Loader (Resources created in Editor)
- Protobuf Serialization/Deserialization
- Hot Reload (Development only)
- Validation & Error Reporting

### Out of Scope
- Runtime Data Mutation (Save/Load separate)
- Network Sync (Multiplayer Phase 5+)
- Asset Loading (Textures, Audio - Godot handles)

---

## 3. Data Structures

### 3.1 DataRegistry (Rust)
```rust
pub struct DataRegistry {
    units: HashMap<String, UnitData>,
    classes: HashMap<String, ClassData>,
    skills: HashMap<String, SkillData>,
    weapons: HashMap<String, WeaponData>,
    items: HashMap<String, ItemData>,
    maps: HashMap<String, MapData>,
    elements: HashMap<Element, ElementData>,
    terrains: HashMap<TerrainType, TerrainData>,
}
```

### 3.2 UnitData (protobuf)
```protobuf
message UnitData {
  string id = 1;
  string name = 2;
  string class_id = 3;
  int32 class_tier = 4;       // 1=Base, 2=Promoted, 3=Master
  Element element = 5;
  int32 level = 6;
  BaseStats base_stats = 7;
  GrowthRates growth_rates = 8;
  repeated string skill_ids = 9;      // Innate skills
  repeated string weapon_ranks = 10;  // Weapon proficiency
  string portrait_path = 11;
  string sprite_path = 12;
}
```

### 3.3 ClassData (protobuf)
```protobuf
message ClassData {
  string id = 1;
  string name = 2;
  ClassLine line = 3;         // LORD, CAVALRY, ARMOR, FLIER, MAGE, etc.
  int32 tier = 4;
  BaseStats base_stats = 5;
  GrowthRates growth_rates = 6;
  MoveType move_type = 7;
  int32 mov = 8;
  repeated string promotion_options = 9; // Class IDs
  repeated string class_skills = 10;     // Skills gained at this tier
  string icon_path = 11;
}
```

### 3.4 SkillData (protobuf)
```protobuf
message SkillData {
  string id = 1;
  string name = 2;
  SkillType type = 3;         // PASSIVE, ACTIVE, REACTION, COUNTER
  int32 cp_cost = 4;          // CP Cost to equip
  SkillTarget target = 5;     // SELF, ALLY, ENEMY, AREA, GLOBAL
  int32 range = 6;            // For ACTIVE/REACTION
  string effect_id = 7;       // References EffectData
  string description = 8;
  string icon_path = 9;
}
```

### 3.5 WeaponData (protobuf)
```protobuf
message WeaponData {
  string id = 1;
  string name = 2;
  WeaponType type = 3;        // SWORD, LANCE, AXE, BOW, TOME, STAFF, etc.
  int32 rank = 4;             // E, D, C, B, A, S (0-5)
  int32 mt = 5;               // Might
  int32 hit = 6;              // Hit Rate
  int32 crit = 7;             // Crit Rate
  int32 rng = 8;              // Range (1-3+)
  int32 weight = 9;
  int32 durability = 10;      // Max uses
  repeated WeaponAbility abilities = 11; // Brave, Effective, etc.
  string icon_path = 12;
}
```

### 3.6 MapData (protobuf)
```protobuf
message MapData {
  string id = 1;
  string name = 2;
  int32 width = 3;
  int32 height = 4;
  repeated TileData tiles = 5;
  repeated DeploymentSlot player_slots = 6;
  repeated DeploymentSlot enemy_slots = 7;
  repeated ObjectiveData objectives = 8;
  string background_path = 9;
  string music_id = 10;
}
```

---

## 4. File Formats

### 4.1 JSON Structure (data/*.json)
```json
{
  "version": "1.0",
  "units": [
    {
      "id": "unit_lord_alex",
      "name": "Alex",
      "class_id": "class_lord",
      "class_tier": 1,
      "element": "FIRE",
      "level": 1,
      "base_stats": {"hp": 20, "atk": 6, "def": 3, "int": 2, "spd": 5, "mov": 5, "rng": 1, "res": 2},
      "growth_rates": {"hp": 60, "atk": 45, "def": 30, "int": 20, "spd": 50, "mov": 0, "rng": 0, "res": 25},
      "skill_ids": ["skill_leadership"],
      "weapon_ranks": ["sword"],
      "portrait_path": "res://assets/sprites/portraits/alex.png",
      "sprite_path": "res://assets/sprites/units/alex.tscn"
    }
  ],
  "classes": [...],
  "skills": [...],
  "weapons": [...],
  "items": [...]
}
```

### 4.2 Godot .tres Resources
สร้างใน Godot Editor → โหลดผ่าน `ResourceLoader.load()`
- `UnitResource.tres` - Extends Resource, มี @export variables
- `ClassResource.tres`
- `SkillResource.tres`
- `WeaponResource.tres`
- `MapResource.tres` - Contains TileMap data

> **Convention**: JSON = Source of Truth (Git), .tres = Editor Authoring → Export to JSON via script

---

## 5. Functions (Rust API)

### 5.1 `DataRegistry::new() -> Self`
สร้าง Registry ว่าง

### 5.2 `load_from_dir(&mut self, path: &str) -> Result<(), DataError>`
โหลดข้อมูลทั้งหมดจากโฟลเดอร์ (JSON + .tres)

### 5.3 `load_json(&mut self, path: &str) -> Result<(), DataError>`
โหลดเฉพาะ JSON files

### 5.4 `load_tres(&mut self, path: &str) -> Result<(), DataError>`
โหลดเฉพาะ .tres files (ต้องการ Godot runtime - ใช้ผ่าน GDExtension)

### 5.5 Getters
```rust
fn get_unit(&self, id: &str) -> Option<&UnitData>
fn get_class(&self, id: &str) -> Option<&ClassData>
fn get_skill(&self, id: &str) -> Option<&SkillData>
fn get_weapon(&self, id: &str) -> Option<&WeaponData>
fn get_item(&self, id: &str) -> Option<&ItemData>
fn get_map(&self, id: &str) -> Option<&MapData>
fn all_units(&self) -> Vec<&UnitData>
fn units_by_class(&self, class_id: &str) -> Vec<&UnitData>
```

### 5.6 `reload(&mut self) -> Result<(), DataError>`
Hot Reload - ล้าง Cache โหลดใหม่ (Dev only)

### 5.7 `validate(&self) -> ValidationReport`
ตรวจสอบ: Missing refs, Circular deps, Stat bounds, Duplicate IDs

---

## 6. Validation Rules
| Rule | Severity |
|---|---|
| Unit references non-existent Class | ERROR |
| Unit references non-existent Skill | ERROR |
| Class promotion target missing | ERROR |
| Growth rates sum > 400% | WARN |
| Base stats exceed caps (99) | WARN |
| Weapon rank > S | ERROR |
| Duplicate ID in same category | ERROR |
| Map size > 16x16 | WARN |
| Missing required fields | ERROR |

---

## 7. Hot Reload (Development)
- Watch `data/` directory for changes
- On change: `registry.reload()` → emit `data_reloaded` signal
- Godot Editor: Auto-refresh resources
- **Production**: Disabled (compile-time embed via `include_str!`)

---

## 8. Error Types
```rust
enum DataError {
    IoError(std::io::Error),
    JsonError(serde_json::Error),
    ProtobufError(prost::DecodeError),
    ValidationError(ValidationReport),
    MissingResource(String),
    InvalidFormat(String),
    HotReloadDisabled,
}
```

---

## 9. Testing Requirements
- [ ] Load all JSON fixtures without error
- [ ] Validation catches all error types
- [ ] Getters return correct data
- [ ] Hot reload preserves references
- [ ] Protobuf round-trip (JSON → Proto → JSON)
- [ ] Performance: < 50ms full load (1000 units)

---

## 10. Integration Points
- **All Core Systems**: Query Registry for stats, skills, weapons
- **GDExtension**: Exposes `get_unit`, `load_data`, `validate` to Godot
- **Godot Editor**: Export .tres → JSON via Editor script
- **CI/CD**: `just validate-data` runs validation in pipeline

---

## 11. File Locations
```
data/
├── units.json
├── classes.json
├── skills.json
├── weapons.json
├── items.json
├── maps/
│   ├── map_ch01.json
│   ├── map_ch02.json
│   └── ...
├── elements.json
└── terrains.json

godot/resources/
├── units/          # .tres files
├── classes/
├── skills/
├── weapons/
├── items/
└── maps/
```

---

## 12. References
- PDR.md Section 3.3 (Protocol Buffers Schema)
- GDD.md (All System Data)
- CLASS_TREE.md (Class Data)
- SKILL_SYSTEM.md (Skill Data)
- WEAPON_SYSTEM.md (Weapon Data)
- CHARACTER_TEMPLATE.md (Unit Template)
