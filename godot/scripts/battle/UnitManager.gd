extends Node

## UnitManager.gd
## Manages battle units - spawning, actions, state

class_name UnitManager

signal unit_selected(unit: Object)
signal unit_action(action_data: Dictionary)
signal unit_died(unit: Object)
signal unit_leveled_up(unit: Object, new_level: int)

@onready var unit_container: Node2D = $UnitContainer
@onready var grid_manager: GridManager = get_node("../GridManager")

# Unit template
@export var unit_scene: PackedScene

# Active unit
var active_unit: Object = null

# Unit pools
var player_units: Array = []
var enemy_units: Array = []

func _ready() -> void:
	if not unit_scene:
		unit_scene = preload("res://scenes/units/Unit.tscn")

func spawn_unit(unit_data: Dictionary, is_player: bool, start_pos: Vector2i) -> Object:
	var unit = unit_scene.instantiate()
	unit.unit_id = unit_data.unit_id
	unit.unit_name = unit_data.name
	unit.team = 0 if is_player else 1
	unit.grid_pos = start_pos
	unit.load_from_data(unit_data)
	
	unit_container.add_child(unit)
	unit.position = grid_manager._grid_to_world(start_pos)
	grid_manager.set_occupant(start_pos, unit)
	
	if is_player:
		player_units.append(unit)
	else:
		enemy_units.append(unit)
	
	# Connect signals
	unit.died.connect(_on_unit_died)
	unit.leveled_up.connect(_on_unit_leveled_up)
	unit.selected.connect(unit_selected.emit)
	
	return unit

func load_from_rust_data(rust_unit: Dictionary) -> Object:
	# Create unit from Rust data
	var unit_data = {
		"unit_id": rust_unit.id,
		"name": rust_unit.name,
		"class_type": rust_unit.class_type,
		"level": rust_unit.level,
		"stats": rust_unit.stats,
		"skills": rust_unit.skills,
		"equipment": rust_unit.equipment
	}
	
	var is_player = rust_unit.team == 0
	var pos = Vector2i(rust_unit.x, rust_unit.y)
	return spawn_unit(unit_data, is_player, pos)

func set_active_unit(unit: Object) -> void:
	active_unit = unit
	if unit:
		unit.set_selected(true)
		unit_selected.emit(unit)

func get_active_unit() -> Object:
	return active_unit

func clear_active_unit() -> void:
	if active_unit:
		active_unit.set_selected(false)
	active_unit = null

func move_unit_along_path(unit: Object, path: Array[Vector2i], callback: Callable) -> void:
	if path.size() == 0:
		callback.call()
		return
	
	var tween = create_tween()
	var current_pos = unit.grid_pos
	
	for next_pos in path:
		grid_manager.set_occupant(current_pos, null)
		current_pos = next_pos
		
		var world_pos = grid_manager._grid_to_world(next_pos)
		tween.tween_property(unit, "position", world_pos, 0.3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_callback(grid_manager.set_occupant.bind(current_pos, unit))
	
	tween.tween_callback(callback)
	tween.tween_callback(_update_unit_position.bind(unit, current_pos))
	unit.grid_pos = current_pos

func _update_unit_position(unit: Object, pos: Vector2i) -> void:
	unit.grid_pos = pos

func attack(attacker: Object, target: Object, skill_id: String = "") -> void:
	# Calculate damage via Rust
	var attacker_data = attacker.get_rust_data()
	var target_data = target.get_rust_data()
	var skill_data = {}
	if skill_id != "":
		skill_data = DataRegistry.get_skill(skill_id)
	
	var result = RustCore.combat_resolve(attacker_data, target_data, {
		"skill_id": skill_id,
		"skill_data": skill_data
	})
	
	# Apply damage
	var damage = result.damage
	var is_crit = result.is_crit
	var is_miss = result.is_miss
	
	# Visual
	_play_attack_animation(attacker, target, skill_id, is_crit)
	
	# Apply to target
	target.take_damage(damage, is_crit, is_miss)
	
	# Check for counter
	if not is_miss and target.can_counter(attacker):
		_process_counter(target, attacker)
	
	# Emit action signal
	unit_action.emit({
		"action": "attack",
		"unit": attacker,
		"target": target,
		"result": result
	})

func _play_attack_animation(attacker: Object, target: Object, skill_id: String, is_crit: bool) -> void:
	await attacker.play_attack_animation(target, skill_id, is_crit)

func _process_counter(counter_unit: Object, attacker: Object) -> void:
	# Counter attack logic
	var result = RustCore.combat_resolve(counter_unit.get_rust_data(), attacker.get_rust_data(), {
		"is_counter": true
	})
	
	counter_unit.play_counter_animation(attacker)
	
	attacker.take_damage(result.damage, result.is_crit, result.is_miss)

func use_skill(user: Object, target: Object, skill_id: String) -> void:
	var skill = DataRegistry.get_skill(skill_id)
	if not skill:
		return
	
	if not skill.can_use(user.get_rust_data(), {"cp": user.cp, "cooldowns": user.cooldowns}):
		return
	
	# Pay costs
	user.mp -= skill.mp_cost
	user.hp -= skill.hp_cost
	user.cp -= skill.cp_cost
	user.set_cooldown(skill_id, skill.cooldown)
	
	# Get skill effect from Rust
	var result = RustCore.call_rust("skill_execute", {
		"user": user.get_rust_data(),
		"target": target.get_rust_data(),
		"skill_id": skill_id,
		"skill_data": skill
	})
	
	# Apply effects
	_apply_skill_effects(target, result.effects)
	
	# Visual
	user.play_skill_animation(target, skill_id)
	
	unit_action.emit({
		"action": "skill",
		"unit": user,
		"target": target,
		"skill_id": skill_id,
		"result": result
	})

func use_item(user: Object, target: Object, item_id: String) -> void:
	var item = DataRegistry.get_item(item_id)
	if not item:
		return
	
	var result = item.use(target.get_rust_data(), {"in_battle": true})
	
	# Apply effects
	for effect in result.effects:
		_apply_item_effect(target, effect)
	
	# Visual
	user.play_item_animation(target, item_id)
	
	unit_action.emit({
		"action": "item",
		"unit": user,
		"target": target,
		"item_id": item_id,
		"result": result
	})

func _apply_skill_effects(target: Object, effects: Array) -> void:
	for effect in effects:
		match effect.type:
			"damage":
				target.take_damage(effect.value, effect.is_crit, effect.is_miss)
			"heal":
				target.heal(effect.value)
			"buff":
				target.add_buff(effect.stat, effect.value, effect.duration)
			"debuff":
				target.add_debuff(effect.stat, effect.value, effect.duration)
			"status":
				target.add_status(effect.status, effect.duration)
			"move":
				# Forced movement
				var path = effect.path
				move_unit_along_path(target, path, func(): pass)

func _apply_item_effect(target: Object, effect: Dictionary) -> void:
	match effect.type:
		"heal_hp":
			target.heal(effect.amount)
		"heal_mp":
			target.restore_mp(effect.amount)
		"cure_status":
			target.remove_status(effect.status)
		"buff":
			target.add_buff(effect.stat, effect.value, effect.duration)
		"restore_durability":
			if target.equipped_weapon:
				target.equipped_weapon.repair(effect.amount)

func _on_unit_died(unit: Object) -> void:
	grid_manager.set_occupant(unit.grid_pos, null)
	
	if unit.team == 0:
		player_units.erase(unit)
	else:
		enemy_units.erase(unit)
	
	unit_died.emit(unit)
	
	# Death animation
	unit.play_death_animation()

func _on_unit_leveled_up(unit: Object, new_level: int) -> void:
	unit_leveled_up.emit(unit, new_level)
	unit.play_level_up_animation()

func get_all_units() -> Array:
	return player_units + enemy_units

func get_units_by_team(team: int) -> Array:
	return player_units if team == 0 else enemy_units

func get_alive_units(team: int = -1) -> Array:
	var units = get_all_units() if team == -1 else get_units_by_team(team)
	return units.filter(func(u): return u.is_alive())

func remove_unit(unit: Object) -> void:
	if unit.team == 0:
		player_units.erase(unit)
	else:
		enemy_units.erase(unit)
	grid_manager.set_occupant(unit.grid_pos, null)
	unit.queue_free()
