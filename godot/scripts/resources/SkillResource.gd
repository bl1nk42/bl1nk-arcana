extends Resource
class_name SkillResource

@export var skill_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var skill_type: String = "active"  # active, passive, reaction, counter, command

# Cost
@export var mp_cost: int = 0
@export var hp_cost: int = 0
@export var cp_cost: int = 0  # Command Points
@export var cooldown: int = 0
@export var max_charges: int = 1

# Targeting
@export var target_type: String = "enemy"  # self, ally, enemy, all, area, line, empty_tile
@export var range: int = 1
@export var aoe_radius: int = 0
@export var aoe_shape: String = "circle"  # circle, square, line, cross, diamond
@export var require_line_of_sight: bool = true
@export var can_target_empty: bool = false

# Effects
@export var effects: Array[Dictionary] = []  # [{type, value, element, chance, duration, ...}]

# Requirements
@export var required_class: String = ""
@export var required_level: int = 1
@export var required_weapon: String = ""
@export var forbidden_states: Array[String] = []  # silence, stun, etc.

# Visual
@export var icon: Texture2D
@export var animation: String = ""
@export var sfx_name: String = ""
@export var vfx_name: String = ""

# AI
@export var ai_priority: int = 50
@export var ai_tags: Array[String] = []  # damage, heal, buff, debuff, move, utility

func _init() -> void:
	pass

func get_total_cost() -> Dictionary:
	return {
		"mp": mp_cost,
		"hp": hp_cost,
		"cp": cp_cost
	}

func can_use(unit: Object, context: Dictionary) -> bool:
	# Check MP
	if unit.mp < mp_cost:
		return false
	# Check HP
	if unit.hp <= hp_cost:
		return false
	# Check CP
	if context.cp < cp_cost:
		return false
	# Check cooldown
	if context.cooldowns.has(skill_id) and context.cooldowns[skill_id] > 0:
		return false
	# Check class
	if required_class != "" and unit.class_type != required_class:
		return false
	# Check level
	if unit.level < required_level:
		return false
	# Check weapon
	if required_weapon != "" and not unit.can_use_weapon(required_weapon):
		return false
	# Check forbidden states
	for state in forbidden_states:
		if context.unit_states.has(state):
			return false
	return true

func get_ai_score(unit: Object, target: Object, context: Dictionary) -> float:
	# Base score from ai_priority
	var score = ai_priority
	
	# Adjust based on effects
	for effect in effects:
		match effect.type:
			"damage":
				score += effect.value * 0.1
			"heal":
				score += effect.value * 0.15
			"buff":
				score += 20
			"debuff":
				score += 25
			"move":
				score += 10
	
	# Adjust for target
	if target:
		if "heal" in ai_tags and target.hp < target.max_hp * 0.5:
			score += 30
		if "damage" in ai_tags and target.hp > 0:
			score += 10
	
	return score