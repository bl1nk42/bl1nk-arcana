extends Node

## DataRegistry.gd
## Central data registry - loads from JSON/Resources and syncs with Rust
## Singleton: DataRegistry

var is_ready: bool = false
var data_loaded: bool = false

# Data caches
var units: Dictionary = {}
var skills: Dictionary = {}
var weapons: Dictionary = {}
var classes: Dictionary = {}
var items: Dictionary = {}

# Rust GDExtension reference
@onready var gdext_manager = RustCore

func _ready() -> void:
	print("[DataRegistry] Initialized")
	load_all_data()

func load_all_data() -> void:
	# Load from Godot resources
	_load_units()
	_load_skills()
	_load_weapons()
	_load_classes()
	_load_items()
	
	# Sync with Rust
	if gdext_manager and gdext_manager.is_initialized:
		_sync_with_rust()
	
	is_ready = true
	data_loaded = true
	print("[DataRegistry] All data loaded")

func _load_units() -> void:
	var files = DirAccess.get_files_at("res://resources/units/")
	for file in files:
		if file.ends_with(".tres"):
			var res = ResourceLoader.load("res://resources/units/" + file)
			if res:
				units[res.unit_id] = res

func _load_skills() -> void:
	var files = DirAccess.get_files_at("res://resources/skills/")
	for file in files:
		if file.ends_with(".tres"):
			var res = ResourceLoader.load("res://resources/skills/" + file)
			if res:
				skills[res.skill_id] = res

func _load_weapons() -> void:
	var files = DirAccess.get_files_at("res://resources/weapons/")
	for file in files:
		if file.ends_with(".tres"):
			var res = ResourceLoader.load("res://resources/weapons/" + file)
			if res:
				weapons[res.weapon_id] = res

func _load_classes() -> void:
	var files = DirAccess.get_files_at("res://resources/classes/")
	for file in files:
		if file.ends_with(".tres"):
			var res = ResourceLoader.load("res://resources/classes/" + file)
			if res:
				classes[res.class_id] = res

func _load_items() -> void:
	var files = DirAccess.get_files_at("res://resources/items/")
	for file in files:
		if file.ends_with(".tres"):
			var res = ResourceLoader.load("res://resources/items/" + file)
			if res:
				items[res.item_id] = res

func _sync_with_rust() -> void:
	# Get data from Rust GDExtension
	var rust_data = gdext_manager.get_data_registry()
	if rust_data is Dictionary:
		# Merge Rust data (Rust is authoritative for game logic)
		for unit in rust_data.get("units", []):
			if not units.has(unit.id):
				units[unit.id] = _unit_from_rust(unit)
		for skill in rust_data.get("skills", []):
			if not skills.has(skill.id):
				skills[skill.id] = _skill_from_rust(skill)
		# ... similarly for weapons, classes, items

func _unit_from_rust(rust_unit: Dictionary) -> Resource:
	var script = load("res://scripts/resources/UnitResource.gd")
	var unit = script.new()
	unit.unit_id = rust_unit.id
	unit.name = rust_unit.name
	unit.class_type = rust_unit.class_type
	unit.base_stats = rust_unit.base_stats
	unit.growth_rates = rust_unit.growth_rates
	unit.skills = rust_unit.skills
	return unit

func _skill_from_rust(rust_skill: Dictionary) -> Resource:
	var script = load("res://scripts/resources/SkillResource.gd")
	var skill = script.new()
	skill.skill_id = rust_skill.id
	skill.name = rust_skill.name
	skill.description = rust_skill.description
	skill.skill_type = rust_skill.skill_type
	skill.cost = rust_skill.cost
	skill.effects = rust_skill.effects
	return skill

func get_unit(unit_id: String) -> Resource:
	return units.get(unit_id, null)

func get_skill(skill_id: String) -> Resource:
	return skills.get(skill_id, null)

func get_weapon(weapon_id: String) -> Resource:
	return weapons.get(weapon_id, null)

func get_class_resource(class_id: String) -> Resource:
	return classes.get(class_id, null)

func get_item(item_id: String) -> Resource:
	return items.get(item_id, null)

func get_all_cards() -> Array:
	# Cards have been removed from the game — Skills are owned by units and
	# resolved through the skill_database instead. This stub returns [] so any
	# legacy caller keeps compiling until Phase 2 cleans up references.
	return []

func get_all_units() -> Array:
	return units.values()
