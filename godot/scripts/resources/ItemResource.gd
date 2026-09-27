extends Resource
class_name ItemResource

@export var item_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var item_type: String = "consumable"  # consumable, equipment, material, key, currency

# Stacking
@export var max_stack: int = 99
@export var current_stack: int = 1

# Usage
@export var usable_in_battle: bool = true
@export var usable_out_of_battle: bool = true
@export var target_type: String = "ally"  # self, ally, enemy, all, none

# Effects (for consumables)
@export var effects: Array[Dictionary] = []  # [{type, value, duration, ...}]

# Equipment bonuses (for equipment items)
@export var equip_stats: Dictionary = {}
@export var equip_skills: Array[String] = []

# Value
@export var buy_price: int = 10
@export var sell_price: int = 5

# Rarity
@export var rarity: String = "common"  # common, uncommon, rare, epic, legendary, mythic

# Visual
@export var icon: Texture2D
@export var model_path: String = ""

# Tags
@export var tags: Array[String] = []  # healing, status_cure, buff, offensive, crafting, quest

func _init() -> void:
	current_stack = min(current_stack, max_stack)

func can_use(unit: BattleUnit, context: Dictionary) -> bool:
	if item_type == "consumable":
		if context.in_battle and not usable_in_battle:
			return false
		if not context.in_battle and not usable_out_of_battle:
			return false
		# Check if effect would do anything
		for effect in effects:
			if _would_have_effect(unit, effect):
				return true
		return false
	return true  # Equipment can always be "used" (equipped)

func _would_have_effect(unit: BattleUnit, effect: Dictionary) -> bool:
	match effect.type:
		"heal_hp":
			return unit.hp < unit.max_hp
		"heal_mp":
			return unit.mp < unit.max_mp
		"cure_status":
			return unit.has_status(effect.status)
		"buff_stat":
			return not unit.has_buff(effect.stat)
		"restore_durability":
			return unit.equipped_weapon and unit.equipped_weapon.current_durability < unit.equipped_weapon.max_durability
	return true

func use(unit: BattleUnit, context: Dictionary) -> Dictionary:
	var results = []
	for effect in effects:
		var result = _apply_effect(unit, effect, context)
		results.append(result)
	
	current_stack -= 1
	return {"effects": results, "consumed": current_stack <= 0}

func _apply_effect(unit: BattleUnit, effect: Dictionary, context: Dictionary) -> Dictionary:
	match effect.type:
		"heal_hp":
			var amount = min(effect.value, unit.max_hp - unit.hp)
			unit.hp += amount
			return {"type": "heal_hp", "amount": amount}
		"heal_mp":
			var amount = min(effect.value, unit.max_mp - unit.mp)
			unit.mp += amount
			return {"type": "heal_mp", "amount": amount}
		"cure_status":
			unit.remove_status(effect.status)
			return {"type": "cure_status", "status": effect.status}
		"buff_stat":
			unit.add_buff(effect.stat, effect.value, effect.duration)
			return {"type": "buff", "stat": effect.stat, "value": effect.value}
		"damage":
			# For offensive items
			return {"type": "damage", "value": effect.value, "element": effect.element}
		"restore_durability":
			if unit.equipped_weapon:
				unit.equipped_weapon.repair(effect.value)
				return {"type": "repair", "amount": effect.value}
	return {"type": "unknown"}

func add_to_stack(amount: int) -> int:
	var old = current_stack
	current_stack = min(max_stack, current_stack + amount)
	return current_stack - old

func is_full_stack() -> bool:
	return current_stack >= max_stack

func get_total_value() -> int:
	return sell_price * current_stack
