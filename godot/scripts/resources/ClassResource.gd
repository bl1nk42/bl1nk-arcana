extends Resource
class_name ClassResource

@export var class_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var tier: int = 1  # 1=base, 2=advanced, 3=master

# Base class (for promotion)
@export var base_class: String = ""
@export var promotion_classes: Array[String] = []  # Class IDs this promotes to

# Stat modifiers (applied on top of unit base stats)
@export var stat_modifiers: Dictionary = {
	"hp": 0,
	"mp": 0,
	"atk": 0,
	"def": 0,
	"matk": 0,
	"mdef": 0,
	"spd": 0,
	"hit": 0,
	"avo": 0,
	"crit": 0,
	"cavo": 0,
	"mov": 0,
	"jmp": 0
}

# Growth modifiers (percentage added to unit growth rates)
@export var growth_modifiers: Dictionary = {
	"hp": 0,
	"mp": 0,
	"atk": 0,
	"def": 0,
	"matk": 0,
	"mdef": 0,
	"spd": 0,
	"hit": 0,
	"avo": 0,
	"crit": 0,
	"cavo": 0
}

# Weapon proficiency
@export var weapon_ranks: Dictionary = {}  # {"sword": "C", "lance": "E", ...}

# Skills
@export var class_skills: Array[Dictionary] = []  # [{skill_id, level_unlock}]
@export var mastery_skill: String = ""  # Skill unlocked at max mastery

# Movement
@export var move_type: String = "foot"
@export var terrain_costs: Dictionary = {}

# Requirements to promote
@export var promotion_level: int = 10
@export var promotion_items: Array[String] = []  # Item IDs required

# Visual
@export var icon: Texture2D
@export var portrait_base: String = ""
@export var color_scheme: int = 0

func _init() -> void:
	pass

func get_total_stat_modifiers() -> Dictionary:
	var total = stat_modifiers.duplicate()
	if base_class != "" and ClassDatabase.has_class(base_class):
		var base = ClassDatabase.get_class_resource(base_class)
		for stat in base.stat_modifiers:
			total[stat] = total.get(stat, 0) + base.stat_modifiers[stat]
	return total

func get_total_growth_modifiers() -> Dictionary:
	var total = growth_modifiers.duplicate()
	if base_class != "" and ClassDatabase.has_class(base_class):
		var base = ClassDatabase.get_class_resource(base_class)
		for stat in base.growth_modifiers:
			total[stat] = total.get(stat, 0) + base.growth_modifiers[stat]
	return total

func get_weapon_rank(weapon_type: String) -> String:
	var rank = weapon_ranks.get(weapon_type, "E")
	if base_class != "" and ClassDatabase.has_class(base_class):
		var base = ClassDatabase.get_class_resource(base_class)
		var base_rank = base.get_weapon_rank(weapon_type)
		# Return higher rank
		return _higher_rank(rank, base_rank)
	return rank

func _higher_rank(a: String, b: String) -> String:
	var ranks = ["E", "D", "C", "B", "A", "S", "SS", "SSS"]
	var ai = ranks.find(a)
	var bi = ranks.find(b)
	return ranks[max(ai, bi)]

func get_learnable_skills() -> Array[Dictionary]:
	var skills = class_skills.duplicate()
	if base_class != "" and ClassDatabase.has_class(base_class):
		var base = ClassDatabase.get_class_resource(base_class)
		for skill in base.class_skills:
			if not _skill_exists(skills, skill.skill_id):
				skills.append(skill)
	return skills

func _skill_exists(skills: Array, skill_id: String) -> bool:
	for s in skills:
		if s.skill_id == skill_id:
			return true
	return false

func can_promote_to(target_class: String) -> bool:
	return target_class in promotion_classes

func get_promotion_requirements() -> Dictionary:
	return {
		"level": promotion_level,
		"items": promotion_items
	}
