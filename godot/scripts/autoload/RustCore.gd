extends Node

## RustCore.gd
## Manages Rust GDExtension lifecycle and provides Godot-friendly API
## Singleton: RustCore

# NOTE: no `class_name` here — it would collide with the autoload of the same
# name and Godot 4 refuses to load the project ("hides an autoload singleton").
# Same rule as every other script in scripts/autoload/.

# Extension state
var is_initialized: bool = false
var extension_version: String = ""
var rust_info: Dictionary = {}

# Cached Rust system references
var _combat_system: Object = null
var _ai_system: Object = null
var _pathfinding_system: Object = null
var _data_registry: Object = null
var _save_system: Object = null  # NOTE: blink-gdext exports no save system yet — stays null until Rust adds one

# Signal when Rust is ready
signal rust_ready(version: String)
signal rust_error(message: String)

func _ready() -> void:
	print("[RustCore] Initializing...")
	_initialize_extension()

func _initialize_extension() -> void:
	# The GDExtension is loaded automatically by Godot via blink_core.gdextension
	# We just need to verify it's available and get the entry point
	
	# Instantiate via ClassDB rather than naming the classes directly. The Rust
	# classes only exist once the GDExtension library loads, and referencing them
	# by identifier would make this script fail to parse when it doesn't.
	# Result: this file always compiles, and a missing library becomes a clear
	# runtime error instead of a parse error that takes the whole project down.
	var missing := []
	for rust_class in ["BlinkCombat", "BlinkAI", "BlinkPathfinding", "BlinkDataRegistry"]:
		if not ClassDB.class_exists(rust_class):
			missing.append(rust_class)

	if not missing.is_empty():
		push_error("[RustCore] Rust classes not registered: %s" % ", ".join(missing))
		push_error("[RustCore] Build the library with 'cargo build -p blink-gdext' (in rust/), then copy target/debug/libblink_gdext.so to godot/addons/blink_core/bin/.")
		rust_error.emit("GDExtension not loaded — missing: %s" % ", ".join(missing))
		return

	_combat_system = ClassDB.instantiate("BlinkCombat")
	_ai_system = ClassDB.instantiate("BlinkAI")
	_pathfinding_system = ClassDB.instantiate("BlinkPathfinding")
	_data_registry = ClassDB.instantiate("BlinkDataRegistry")

	if _combat_system == null or _ai_system == null or _pathfinding_system == null or _data_registry == null:
		push_error("[RustCore] Failed to instantiate one or more Rust systems")
		rust_error.emit("Failed to instantiate Rust systems")
		return

	is_initialized = true
	extension_version = _get_rust_version()
	rust_info = _get_rust_info()
	print("[RustCore] Rust GDExtension initialized: v%s" % extension_version)
	rust_ready.emit(extension_version)

func _get_rust_version() -> String:
	if _data_registry and _data_registry.has_method("get_version"):
		return _data_registry.call("get_version")
	return "unknown"

func _get_rust_info() -> Dictionary:
	if _data_registry and _data_registry.has_method("get_info"):
		return _data_registry.call("get_info")
	return {}

# Public API - Combat
func get_combat_system() -> Object:
	return _combat_system

func combat_calculate_damage(attacker: Dictionary, defender: Dictionary, skill: Dictionary) -> Dictionary:
	if not is_initialized:
		return {"error": "Rust not initialized"}
	return _combat_system.calculate_damage(attacker, defender, skill)

func combat_calculate_heal(healer: Dictionary, target: Dictionary, skill: Dictionary) -> Dictionary:
	if not is_initialized:
		return {"error": "Rust not initialized"}
	return _combat_system.calculate_heal(healer, target, skill)

func combat_resolve(attacker: Dictionary, defender: Dictionary, action: Dictionary) -> Dictionary:
	if not is_initialized:
		return {"error": "Rust not initialized"}
	return _combat_system.resolve_combat(attacker, defender, action)

func combat_get_damage_preview(attacker: Dictionary, defender: Dictionary, skill: Dictionary) -> Dictionary:
	if not is_initialized:
		return {"error": "Rust not initialized"}
	return _combat_system.get_damage_preview(attacker, defender, skill)

# Public API - AI
func get_ai_system() -> Object:
	return _ai_system

func ai_decide_action(unit: Dictionary, allies: Array, enemies: Array, map_data: Dictionary) -> Dictionary:
	if not is_initialized:
		return {"error": "Rust not initialized"}
	return _ai_system.decide_action(unit, allies, enemies, map_data)

func ai_get_intentions(unit: Dictionary) -> Array:
	if not is_initialized:
		return []
	return _ai_system.get_intentions(unit)

func ai_set_personality(unit_id: String, personality: String) -> void:
	if not is_initialized:
		return
	_ai_system.set_personality(unit_id, personality)

# Public API - Pathfinding
func get_pathfinding_system() -> Object:
	return _pathfinding_system

func pathfinding_find_path(start: Vector2i, goal: Vector2i, map_data: Dictionary, move_type: int) -> Array:
	if not is_initialized:
		return []
	return _pathfinding_system.find_path(start, goal, map_data, move_type)

func pathfinding_get_reachable(start: Vector2i, move_range: int, map_data: Dictionary, move_type: int) -> Array:
	if not is_initialized:
		return []
	return _pathfinding_system.get_reachable(start, move_range, map_data, move_type)

func pathfinding_calculate_cost(from: Vector2i, to: Vector2i, map_data: Dictionary, move_type: int) -> int:
	if not is_initialized:
		return -1
	return _pathfinding_system.calculate_cost(from, to, map_data, move_type)

# Public API - Data Registry
func get_data_registry() -> Object:
	return _data_registry

func data_get_unit(unit_id: String) -> Dictionary:
	if not is_initialized:
		return {}
	return _data_registry.get_unit(unit_id)

func data_get_skill(skill_id: String) -> Dictionary:
	if not is_initialized:
		return {}
	return _data_registry.get_skill(skill_id)

func data_get_weapon(weapon_id: String) -> Dictionary:
	if not is_initialized:
		return {}
	return _data_registry.get_weapon(weapon_id)

func data_get_all_units() -> Array:
	if not is_initialized:
		return []
	return _data_registry.get_all_units()

func data_get_all_skills() -> Array:
	if not is_initialized:
		return []
	return _data_registry.get_all_skills()

# Public API - Save System
func get_save_system() -> Object:
	return _save_system

func save_get_player_data() -> Dictionary:
	if not is_initialized or _save_system == null:
		return {}
	return _save_system.get_player_data()

func save_get_inventory() -> Dictionary:
	if not is_initialized or _save_system == null:
		return {}
	return _save_system.get_inventory()

func save_get_unlocks() -> Dictionary:
	if not is_initialized or _save_system == null:
		return {}
	return _save_system.get_unlocks()

func save_apply_player_data(data: Dictionary) -> void:
	if not is_initialized or _save_system == null:
		return
	_save_system.apply_player_data(data)

func save_apply_inventory(data: Dictionary) -> void:
	if not is_initialized or _save_system == null:
		return
	_save_system.apply_inventory(data)

func save_apply_unlocks(data: Dictionary) -> void:
	if not is_initialized or _save_system == null:
		return
	_save_system.apply_unlocks(data)

# Generic Rust call
func call_rust(method: String, args: Variant = null) -> Variant:
	if not is_initialized:
		return null
	
	# Try each system
	for system in [_combat_system, _ai_system, _pathfinding_system, _data_registry, _save_system]:
		if system and system.has_method(method):
			if args == null:
				return system.call(method)
			else:
				return system.call(method, args)
	
	push_warning("[RustCore] Method not found in any Rust system: " + method)
	return null

# Utility
func is_ready() -> bool:
	return is_initialized

func get_version() -> String:
	return extension_version

func get_info() -> Dictionary:
	return rust_info

func reload_extension() -> void:
	# Hot reload - reinitialize
	print("[RustCore] Reloading extension...")
	is_initialized = false
	_combat_system = null
	_ai_system = null
	_pathfinding_system = null
	_data_registry = null
	_save_system = null
	_initialize_extension()