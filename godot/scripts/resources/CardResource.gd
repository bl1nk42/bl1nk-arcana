extends Resource
class_name CardResource

@export var card_id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var class_type: String = ""  # warrior, mage, rogue, etc.
@export var rarity: String = "common"  # common, rare, epic, legendary, mythic
@export var cost: int = 1
@export var element: String = "neutral"  # fire, water, earth, air, light, dark, neutral

# Card effects
@export var effects: Array[Dictionary] = []

# Visual
@export var artwork: Texture2D
@export var frame_style: String = "default"

# Stats (for unit cards)
@export var base_stats: Dictionary = {}
@export var growth_rates: Dictionary = {}

func _init() -> void:
	pass

func get_effect_summary() -> String:
	var summaries = []
	for effect in effects:
		var type = effect.type
		var value = effect.value
		var target = effect.target
		summaries.append("%s: %s (target: %s)" % [type, value, target])
	return "\n".join(summaries)

func is_unit_card() -> bool:
	return class_type != "" and base_stats.size() > 0

func is_skill_card() -> bool:
	return !is_unit_card()