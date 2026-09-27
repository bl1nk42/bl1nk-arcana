extends Resource
class_name WeaponResource

@export var weapon_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var weapon_type: String = "sword"  # sword, axe, lance, bow, staff, dagger, fist, tome, gun, instrument

# Stats
@export var might: int = 1
@export var hit_bonus: int = 0
@export var crit_bonus: int = 0
@export var avo_bonus: int = 0
@export var weight: int = 5
@export var range_min: int = 1
@export var range_max: int = 1

# Durability
@export var max_durability: int = 50
@export var current_durability: int = 50

# Properties
@export var element: String = "physical"  # physical, fire, water, earth, air, light, dark
@export var weapon_rank: String = "E"  # E, D, C, B, A, S, SS, SSS
@export var is_magic: bool = false
@export var uses_mp: bool = false
@export var mp_cost_per_attack: int = 0

# Effects
@export var effects: Array[Dictionary] = []  # [{type, value, chance, condition}]
@export var skills_granted: Array[String] = []  # Skill IDs granted when equipped

# Requirements
@export var required_strength: int = 0
@export var required_magic: int = 0
@export var required_level: int = 1
@export var restricted_classes: Array[String] = []

# Visual
@export var icon: Texture2D
@export var model_path: String = ""
@export var sfx_attack: String = ""
@export var vfx_attack: String = ""

# Value
@export var buy_price: int = 100
@export var sell_price: int = 50

func _init() -> void:
	current_durability = max_durability

func get_effective_might(unit_strength: int, unit_magic: int) -> int:
	if is_magic:
		return might + unit_magic / 2
	return might + unit_strength / 2

func get_hit_rate(unit_skill: int, unit_luck: int) -> int:
	return 80 + hit_bonus + unit_skill * 2 + unit_luck

func get_crit_rate(unit_skill: int, unit_luck: int) -> int:
	return crit_bonus + unit_skill / 2 + unit_luck / 4

func get_weight() -> int:
	return weight

func can_equip(unit: BattleUnit) -> bool:
	if unit.level < required_level:
		return false
	if unit.get_stat("strength") < required_strength:
		return false
	if unit.get_stat("magic") < required_magic:
		return false
	if restricted_classes.size() > 0 and unit.class_type not in restricted_classes:
		return false
	return true

func repair(amount: int = -1) -> void:
	if amount < 0:
		current_durability = max_durability
	else:
		current_durability = min(max_durability, current_durability + amount)

func use_durability(amount: int = 1) -> bool:
	current_durability -= amount
	return current_durability > 0

func is_broken() -> bool:
	return current_durability <= 0
