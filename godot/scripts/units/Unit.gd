extends CharacterBody2D

## Unit.tscn script
## Base unit class for battle units

class_name BattleUnit

const PLACEHOLDER_UNIT_TEXTURE: Texture2D = preload("res://assets/sprites/units/placeholder.svg")

signal died(unit: Object)
signal leveled_up(unit: Object, new_level: int)
signal selected(unit: Object)
signal animation_finished

# Unit identity
@export var unit_id: String = ""
@export var unit_name: String = ""
@export var team: int = 0  # 0 = player, 1 = enemy

# Position
@export var grid_pos: Vector2i = Vector2i(0, 0)

# Class & Level
@export var class_type: String = "warrior"
@export var class_tier: int = 1
@export var level: int = 1
@export var exp: int = 0

# Stats (runtime)
var max_hp: int = 100
var hp: int = 100
var max_mp: int = 50
var mp: int = 50
var atk: int = 10
var def: int = 10
var matk: int = 10
var mdef: int = 10
var spd: int = 10
var hit: int = 100
var avo: int = 0
var crit: int = 5
var cavo: int = 0
var mov: int = 5
var jmp: int = 2

# Growth rates
var growth_rates: Dictionary = {}

# Skills
var skills: Array[String] = []
var cooldowns: Dictionary = {}

# Equipment
var equipped_weapon: Object = null
var equipped_armor: Object = null
var equipped_accessory: Object = null

# Status effects
var buffs: Dictionary = {}
var debuffs: Dictionary = {}
var statuses: Dictionary = {}

# CP (Command Points)
var cp: int = 0
var max_cp: int = 5

# Visual
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var name_label: Label = $NameLabel
@onready var selection_indicator: Node2D = $SelectionIndicator

# Animation
var is_selected: bool = false
var facing_right: bool = true

func _ready() -> void:
	_ensure_sprite_frames()
	_setup_visuals()
	_update_health_bar()

func _ensure_sprite_frames() -> void:
	if not sprite or sprite.sprite_frames:
		return
	var frames := SpriteFrames.new()
	for animation_name in ["idle", "move", "attack", "skill", "hit", "die", "counter", "item"]:
		frames.add_animation(animation_name)
		frames.add_frame(animation_name, PLACEHOLDER_UNIT_TEXTURE)
		frames.set_animation_speed(animation_name, 5.0)
		frames.set_animation_loop(animation_name, animation_name == "idle" or animation_name == "move")
	sprite.sprite_frames = frames

func _setup_visuals() -> void:
	name_label.text = unit_name
	health_bar.max_value = max_hp
	health_bar.value = hp
	selection_indicator.visible = false
	
	if sprite and sprite.sprite_frames:
		sprite.play("idle")

func load_from_data(data: Dictionary) -> void:
	unit_id = data.unit_id
	unit_name = data.name
	class_type = data.class_type
	level = data.level
	
	# Load base stats from class
	var class_res = DataRegistry.get_class_resource(class_type)
	if class_res:
		_apply_class_stats(class_res)
	
	# Apply level growth
	_apply_level_growth(level)
	
	# Load skills
	skills = data.skills if data.has("skills") else []
	
	# Load equipment
	if data.has("equipment"):
		_equip_items(data.equipment)

func _apply_class_stats(class_res: ClassResource) -> void:
	var base_stats = class_res.base_stats
	var modifiers = class_res.get_total_stat_modifiers()
	
	for stat in base_stats:
		set_stat(stat, base_stats[stat] + modifiers.get(stat, 0))
	
	growth_rates = class_res.growth_rates.duplicate()
	var growth_mods = class_res.get_total_growth_modifiers()
	for stat in growth_rates:
		growth_rates[stat] += growth_mods.get(stat, 0)

func _apply_level_growth(level: int) -> void:
	for i in range(2, level + 1):
		for stat in growth_rates:
			var growth = growth_rates[stat]
			var increase = max(1, int(randf_range(0.8, 1.2) * growth / 100.0))
			increment_stat(stat, increase)

func _equip_items(equipment: Dictionary) -> void:
	if equipment.has("weapon"):
		equip_weapon(DataRegistry.get_weapon(equipment.weapon))
	if equipment.has("armor"):
		equip_armor(DataRegistry.get_item(equipment.armor))
	if equipment.has("accessory"):
		equip_accessory(DataRegistry.get_item(equipment.accessory))

func equip_weapon(weapon: WeaponResource) -> void:
	equipped_weapon = weapon
	# Apply weapon stats
	atk += weapon.might
	hit += weapon.hit_bonus
	crit += weapon.crit_bonus

func equip_armor(armor: ItemResource) -> void:
	equipped_armor = armor
	if armor.equip_stats:
		for stat in armor.equip_stats:
			increment_stat(stat, armor.equip_stats[stat])

func equip_accessory(accessory: ItemResource) -> void:
	equipped_accessory = accessory
	if accessory.equip_stats:
		for stat in accessory.equip_stats:
			increment_stat(stat, accessory.equip_stats[stat])

func set_stat(stat: String, value: int) -> void:
	match stat:
		"hp": max_hp = value
		"mp": max_mp = value
		"atk": atk = value
		"def": def = value
		"matk": matk = value
		"mdef": mdef = value
		"spd": spd = value
		"hit": hit = value
		"avo": avo = value
		"crit": crit = value
		"cavo": cavo = value
		"mov": mov = value
		"jmp": jmp = value

func get_stat(stat: String) -> int:
	match stat:
		"hp": return max_hp
		"mp": return max_mp
		"atk": return atk
		"def": return def
		"matk": return matk
		"mdef": return mdef
		"spd": return spd
		"hit": return hit
		"avo": return avo
		"crit": return crit
		"cavo": return cavo
		"mov": return mov
		"jmp": return jmp
	return 0

func increment_stat(stat: String, amount: int) -> void:
	var current = get_stat(stat)
	set_stat(stat, current + amount)
	if stat == "hp":
		hp = min(hp + amount, max_hp)
	elif stat == "mp":
		mp = min(mp + amount, max_mp)

func get_rust_data() -> Dictionary:
	return {
		"id": unit_id,
		"name": unit_name,
		"team": team,
		"class_type": class_type,
		"level": level,
		"x": grid_pos.x,
		"y": grid_pos.y,
		"hp": hp,
		"max_hp": max_hp,
		"mp": mp,
		"max_mp": max_mp,
		"stats": {
			"atk": atk,
			"def": def,
			"matk": matk,
			"mdef": mdef,
			"spd": spd,
			"hit": hit,
			"avo": avo,
			"crit": crit,
			"cavo": cavo,
			"mov": mov,
			"jmp": jmp
		},
		"skills": skills,
		"cooldowns": cooldowns,
		"buffs": buffs,
		"debuffs": debuffs,
		"statuses": statuses,
		"equipped_weapon": equipped_weapon.weapon_id if equipped_weapon else "",
		"cp": cp,
		"max_cp": max_cp
	}

func get_state() -> Dictionary:
	return get_rust_data()

func is_alive() -> bool:
	return hp > 0

func die() -> void:
	if hp > 0:
		hp = 0
	_update_health_bar()
	died.emit(self)
	play_death_animation()

func take_damage(amount: int, is_crit: bool = false, is_miss: bool = false) -> void:
	if is_miss:
		_show_damage_text("Miss", Color(0.5, 0.5, 0.5))
		return
	
	# Apply defense
	var actual_damage = max(1, amount - def)
	
	hp -= actual_damage
	hp = max(0, hp)
	_update_health_bar()
	
	if is_crit:
		_show_damage_text("CRIT %d" % actual_damage, Color(1, 0.2, 0.2))
	else:
		_show_damage_text("%d" % actual_damage, Color(1, 1, 1))
	
	play_hit_animation()
	
	if hp <= 0:
		die()

func heal(amount: int) -> void:
	var old_hp = hp
	hp = min(max_hp, hp + amount)
	var healed = hp - old_hp
	_update_health_bar()
	_show_damage_text("+%d" % healed, Color(0.2, 1, 0.2))

func restore_mp(amount: int) -> void:
	mp = min(max_mp, mp + amount)

func add_buff(stat: String, value: int, duration: int) -> void:
	buffs[stat] = {"value": value, "duration": duration}
	increment_stat(stat, value)

func add_debuff(stat: String, value: int, duration: int) -> void:
	debuffs[stat] = {"value": -value, "duration": duration}
	increment_stat(stat, -value)

func add_status(status: String, duration: int) -> void:
	statuses[status] = {"duration": duration}

func remove_status(status: String) -> void:
	statuses.erase(status)

func has_status(status: String) -> bool:
	return statuses.has(status)

func has_buff(stat: String) -> bool:
	return buffs.has(stat)

func can_counter(attacker: Object) -> bool:
	# Check if unit can counter-attack
	if not equipped_weapon:
		return false
	
	var dist = grid_pos.distance_to(attacker.grid_pos)
	var range_min = equipped_weapon.range_min
	var range_max = equipped_weapon.range_max
	
	return dist >= range_min and dist <= range_max

func set_cooldown(skill_id: String, turns: int) -> void:
	if turns > 0:
		cooldowns[skill_id] = turns

func process_turn_effects() -> void:
	# Process cooldowns
	for skill_id in cooldowns:
		cooldowns[skill_id] -= 1
		if cooldowns[skill_id] <= 0:
			cooldowns.erase(skill_id)
	
	# Process buffs
	for stat in buffs:
		buffs[stat].duration -= 1
		if buffs[stat].duration <= 0:
			increment_stat(stat, -buffs[stat].value)
			buffs.erase(stat)
	
	# Process debuffs
	for stat in debuffs:
		debuffs[stat].duration -= 1
		if debuffs[stat].duration <= 0:
			increment_stat(stat, -debuffs[stat].value)
			debuffs.erase(stat)
	
	# Process statuses
	for status in statuses:
		statuses[status].duration -= 1
		if statuses[status].duration <= 0:
			statuses.erase(status)
	
	# Regen CP
	cp = min(max_cp, cp + 1)
	
	# HP/MP regen from buffs
	if has_buff("hp_regen"):
		heal(buffs["hp_regen"].value)
	if has_buff("mp_regen"):
		restore_mp(buffs["mp_regen"].value)

func gain_exp(amount: int) -> void:
	exp += amount
	var exp_needed = _get_exp_for_level(level + 1)
	if exp >= exp_needed:
		level_up()

func level_up() -> void:
	level += 1
	_apply_level_growth(level)
	hp = max_hp
	mp = max_mp
	leveled_up.emit(self, level)

func _get_exp_for_level(lvl: int) -> int:
	return lvl * lvl * 100

func get_exp_reward() -> int:
	return level * 10

func get_gold_reward() -> int:
	return level * 5

func get_drops() -> Array:
	# Return possible item drops
	return []

func set_selected(value: bool) -> void:
	is_selected = value
	selection_indicator.visible = value
	if value:
		selected.emit(self)

func _show_damage_text(text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.font_size = 24
	label.add_theme_color_override("font_color", color)
	label.global_position = global_position + Vector2(0, -50)
	get_parent().add_child(label)
	
	var tween = create_tween()
	tween.tween_property(label, "global_position", label.global_position + Vector2(0, -30), 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free.bind())

func _update_health_bar() -> void:
	health_bar.max_value = max_hp
	health_bar.value = hp
	
	if hp <= max_hp * 0.25:
		health_bar.add_theme_color_override("fill_color", Color(1, 0.2, 0.2))
	elif hp <= max_hp * 0.5:
		health_bar.add_theme_color_override("fill_color", Color(1, 0.8, 0.2))
	else:
		health_bar.add_theme_color_override("fill_color", Color(0.2, 1, 0.2))

func play_idle_animation() -> void:
	if sprite:
		sprite.play("idle")

func play_move_animation() -> void:
	if sprite:
		sprite.play("move")

func play_attack_animation(target: Object, skill_id: String, is_crit: bool) -> void:
	if sprite:
		sprite.play("attack")
	await animation_finished

func play_counter_animation(attacker: Object) -> void:
	if sprite:
		sprite.play("counter")
	await animation_finished

func play_skill_animation(target: Object, skill_id: String) -> void:
	if sprite:
		sprite.play("skill")
	await animation_finished

func play_item_animation(target: Object, item_id: String) -> void:
	if sprite:
		sprite.play("item")
	await animation_finished

func play_hit_animation() -> void:
	if sprite:
		sprite.play("hit")
	await animation_finished

func play_death_animation() -> void:
	if sprite:
		sprite.play("die")
		await animation_finished
		queue_free()

func play_level_up_animation() -> void:
	# Show level up effect
	var effect = GPUParticles2D.new()
	effect.emitting = true
	effect.amount = 20
	effect.lifetime = 1.0
	effect.explosiveness = 1.0
	effect.spread = 180
	effect.gravity = Vector2(0, -100)
	add_child(effect)
	await get_tree().create_timer(1.0).timeout
	effect.queue_free()
