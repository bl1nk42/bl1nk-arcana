extends Resource
class_name UnitResource

@export var unit_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var class_type: String = ""  # warrior, mage, rogue, archer, cleric, etc.
@export var class_tier: int = 1  # 1=base, 2=advanced, 3=master

# Base stats
@export var base_stats: Dictionary = {
	"hp": 100,
	"mp": 50,
	"atk": 10,
	"def": 10,
	"matk": 10,
	"mdef": 10,
	"spd": 10,
	"hit": 100,
	"avo": 0,
	"crit": 5,
	"cavo": 0,
	"mov": 5,
	"jmp": 2
}

# Growth rates (per level, 0-100%)
@export var growth_rates: Dictionary = {
	"hp": 60,
	"mp": 40,
	"atk": 50,
	"def": 40,
	"matk": 40,
	"mdef": 40,
	"spd": 30,
	"hit": 10,
	"avo": 10,
	"crit": 5,
	"cavo": 5
}

# Skills
@export var starting_skills: Array[String] = []
@export var learnable_skills: Array[Dictionary] = []  # [{skill_id, level}]

# Equipment
@export var weapon_types: Array[String] = []  # sword, axe, lance, bow, staff, etc.
@export var armor_types: Array[String] = []  # light, medium, heavy

# Movement
@export var move_type: String = "foot"  # foot, horse, fly, armor
@export var terrain_costs: Dictionary = {}

# Visual
@export var sprite_path: String = ""
@export var portrait_path: String = ""
@export var color_palette: int = 0

# Element affinity
@export var element_affinities: Dictionary = {}

func _init() -> void:
	pass

func get_stat_at_level(stat: String, level: int) -> int:
	var base = base_stats.get(stat, 0)
	var growth = growth_rates.get(stat, 0)
	return base + int((level - 1) * growth / 100.0)

func get_all_stats_at_level(level: int) -> Dictionary:
	var result = {}
	for stat in base_stats:
		result[stat] = get_stat_at_level(stat, level)
	return result

func can_use_weapon(weapon_type: String) -> bool:
	return weapon_type in weapon_types

func can_wear_armor(armor_type: String) -> bool:
	return armor_type in armor_types

func get_terrain_cost(terrain: String) -> int:
	return terrain_costs.get(terrain, 1)