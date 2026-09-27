# Spec Sheet: GDExtension Binding Layer
**Feature ID:** GDEXT-001
**Status:** Draft
**Priority:** P0 (Core)
**Owner:** Lead Developer
**Created:** 2026-09-27
**Last Updated:** 2026-09-27

---

## 1. Overview
ชั้น Binding แบบบาง (Thin Layer) ระหว่าง Godot 4 (GDScript) ↔ Protocol Buffers ↔ blink-core (Rust) ใช้ `godot` crate v0.5 กับ feature `api-4-6`

---

## 2. Scope
### In Scope
- GDExtension Entry Point (ExtensionLibrary trait)
- Class Registration (BlinkCombat, BlinkAI, BlinkPathfinding, BlinkStats, BlinkDataRegistry)
- Variant/Dictionary/Array ↔ Protobuf Conversion
- Error Handling (Rust Error → Godot Variant)
- Thread Safety (Registry Mutex)

### Out of Scope
- Core Logic Implementation (in blink-core)
- Protobuf Generation (in blink-proto)
- GDScript API Design (Godot layer)

---

## 3. Exposed Classes (Godot Side)

### 3.1 BlinkCombat (Autoload)
```gdscript
# Methods
func resolve_combat(input: Dictionary) -> Dictionary
func calculate_damage(attacker: Dictionary, defender: Dictionary, weapon: Dictionary, terrain_bonus: int) -> int
func calculate_hit_chance(attacker: Dictionary, defender: Dictionary, terrain_bonus: int, support_bonus: int) -> int
func calculate_heal(healer_int: int, target_max_hp: int, target_current_hp: int) -> int
func calculate_avo(spd: int, terrain_bonus: int, skill_bonus: int) -> int
func calculate_hit_chance(avo: int) -> int
func calculate_crit_rate(weapon_rank_bonus: int, skill_bonus: int) -> int
```

### 3.2 BlinkAI (Autoload)
```gdscript
func decide_action(unit: Dictionary, allies: Array, enemies: Array, grid: Dictionary, personality: int, difficulty: float) -> Dictionary
func get_intentions(unit: Dictionary, allies: Array, enemies: Array, grid: Dictionary, personality: int, difficulty: float) -> Array
func evaluate_threats(unit: Dictionary, allies: Array, enemies: Array, grid: Dictionary) -> Array
```

### 3.3 BlinkPathfinding (Autoload)
```gdscript
func find_path(grid: Dictionary, start_x: int, start_y: int, goal_x: int, goal_y: int, move_type: int, max_mov: int) -> Dictionary
func get_reachable(grid: Dictionary, start_x: int, start_y: int, max_mov: int, move_type: int) -> Dictionary
func get_attack_range(grid: Dictionary, reachable: Dictionary, unit: Dictionary, weapon: Dictionary) -> Array
func get_threat_zones(grid: Dictionary, enemies: Array) -> Array
```

### 3.4 BlinkStats (Autoload)
```gdscript
# Static methods - stat calculations
func calculate_damage(atk: int, def: int, element_mult: float) -> int
func calculate_magic_damage(int: int, res: int, element_mult: float) -> int
func calculate_heal(int: int, target_max_hp: int, target_current_hp: int) -> int
func calculate_avo(spd: int, terrain_bonus: int, skill_bonus: int) -> int
func calculate_hit_chance(avo: int) -> int
func calculate_crit_rate(weapon_rank_bonus: int, skill_bonus: int) -> int
```

### 3.5 BlinkDataRegistry (Autoload)
```gdscript
func load_data(path: String) -> bool
func get_unit(id: String) -> Dictionary
func get_class(id: String) -> Dictionary
func get_skill(id: String) -> Dictionary
func get_weapon(id: String) -> Dictionary
func get_item(id: String) -> Dictionary
func get_map(id: String) -> Dictionary
func validate() -> Dictionary
func reload() -> bool
```

---

## 4. Data Conversion Rules

### 4.1 Variant ↔ Protobuf
| Rust Type | Godot Variant | Protobuf |
|---|---|---|
| `i32` | `int` | `int32` |
| `f32` | `float` | `float` |
| `bool` | `bool` | `bool` |
| `String` | `String` | `string` |
| `Vec<T>` | `Array` | `repeated` |
| `HashMap<K,V>` | `Dictionary` | `map` |
| `Option<T>` | `Variant` (null if None) | `optional` |
| `UnitData` | `Dictionary` | `message` |
| `CombatResult` | `Dictionary` | `message` |

### 4.2 Dictionary Key Conventions
- ใช้ `snake_case` สำหรับ keys (Godot convention)
- Boolean keys: `is_*`, `has_*`, `can_*`
- Array keys: plural (`skills`, `weapons`, `units`)

### 4.3 Error Handling
```rust
// Rust side
Result<Variant, BindingError>

// Godot side receives Dictionary with:
{
  "error": true,
  "code": "INVALID_INPUT",
  "message": "Human readable error"
}
```

---

## 5. Implementation Details

### 5.1 Entry Point (godot crate 0.5)
```rust
use godot::prelude::*;

#[gdextension]
unsafe impl ExtensionLibrary for BlinkExtension {
    fn on_level_init(level: InitLevel) {
        if level == InitLevel::Scene {
            let mut app = get_engine().unwrap();
            app.register_class::<BlinkCombat>();
            app.register_class::<BlinkAI>();
            app.register_class::<BlinkPathfinding>();
            app.register_class::<BlinkStats>();
            app.register_class::<BlinkDataRegistry>();
        }
    }

    fn on_level_deinit(_level: InitLevel) {}
}

struct BlinkExtension;
```

### 5.2 Class Structure Pattern
```rust
#[derive(GodotClass)]
#[class(base=RefCounted)]
struct BlinkCombat;

#[godot_api]
impl BlinkCombat {
    #[func]
    fn resolve_combat(&self, input: Dictionary) -> Variant {
        // 1. Convert Dictionary → CombatInput (protobuf)
        // 2. Call blink_core::combat::resolve_combat
        // 3. Convert CombatResult → Dictionary → Variant
        // 4. Handle errors → return error Dictionary
    }
}
```

### 5.3 Conversion Helpers (register.rs)
```rust
// Protobuf → Variant
fn unit_to_variant(unit: &UnitData) -> Variant { ... }
fn combat_result_to_variant(result: CombatResult) -> Variant { ... }
fn path_result_to_variant(result: PathResult) -> Variant { ... }

// Variant → Protobuf
fn variant_to_unit_data(dict: Dictionary) -> Result<UnitData, BindingError> { ... }
fn variant_to_combat_input(dict: Dictionary) -> Result<CombatInput, BindingError> { ... }
fn variant_to_grid_map(dict: Dictionary) -> Result<GridMap, BindingError> { ... }
```

### 5.4 Registry Thread Safety
```rust
// In BlinkDataRegistry
registry: Arc<Mutex<DataRegistry>>

// Each method:
fn get_unit(&self, id: GString) -> Variant {
    let reg = self.registry.lock().unwrap();
    reg.get_unit(&id.to_string())
        .map(unit_to_variant)
        .unwrap_or(Variant::nil())
}
```

---

## 6. Build Configuration

### 6.1 Cargo.toml (blink-gdext)
```toml
[package]
name = "blink-gdext"
crate-type = ["cdylib", "rlib"]

[dependencies]
godot = { version = "0.5", features = ["api-4-6"] }
blink-core = { path = "../blink-core" }
blink-proto = { path = "../blink-proto" }
thiserror = { workspace = true }
```

### 6.2 .gdextension Manifest
```ini
[configuration]
entry_symbol = "gdextension_rust_init"
compatibility_minimum = "4.3"

[libraries]
linux.debug.x86_64 = "res://addons/blink_core/bin/libblink_gdext.so"
linux.release.x86_64 = "res://addons/blink_core/bin/libblink_gdext.so"
macos.debug.x86_64 = "res://addons/blink_core/bin/libblink_gdext.dylib"
macos.release.x86_64 = "res://addons/blink_core/bin/libblink_gdext.dylib"
windows.debug.x86_64 = "res://addons/blink_core/bin/blink_gdext.dll"
windows.release.x86_64 = "res://addons/blink_core/bin/blink_gdext.dll"
android.debug.arm64 = "res://addons/blink_core/bin/libblink_gdext_arm64.so"
android.release.arm64 = "res://addons/blink_core/bin/libblink_gdext_arm64.so"
web.debug.wasm32 = "res://addons/blink_core/bin/blink_gdext.wasm"
web.release.wasm32 = "res://addons/blink_core/bin/blink_gdext.wasm"
```

---

## 7. Testing Requirements
- [ ] All 5 classes register without error
- [ ] Dictionary → Protobuf → Dictionary round-trip
- [ ] Error cases return proper error Dictionary
- [ ] Thread safety: concurrent calls to Registry
- [ ] Memory: no leaks after 1000 calls
- [ ] Godot Editor: Classes appear in Autoload list

---

## 8. Performance Targets
- Conversion overhead: < 0.1ms per call
- Registry lock contention: < 1ms under load
- Binary size: < 5MB (release, stripped)

---

## 9. Integration Points
- **blink-core**: Core logic implementation
- **blink-proto**: Protobuf types
- **Godot**: Autoload singletons, called from GDScript
- **just build**: Compiles → copies to `godot/addons/blink_core/bin/`

---

## 10. References
- PDR.md Section 3.1 (Hybrid Architecture)
- PDR.md Section 3.2 (Repository Structure)
- godot-rust Book: https://godot-rust.github.io/book/
- godot crate docs: https://docs.rs/godot/0.5/
