extends Node2D

## BattleController.gd
## Main battle scene controller - coordinates all battle systems
## Uses Rust GDExtension for combat, AI, pathfinding calculations

class_name BattleController

# Battle state
enum BattlePhase {
	SETUP,
	PLAYER_TURN,
	ENEMY_TURN,
	PLAYER_PHASE_END,
	ENEMY_PHASE_END,
	VICTORY,
	DEFEAT,
	ESCAPE
}

@export var battle_phase: BattlePhase = BattlePhase.SETUP
@export var turn_count: int = 0
@export var current_team: int = 0  # 0 = player, 1 = enemy

# References
@onready var grid_manager = $GridManager
@onready var unit_manager = $UnitManager
@onready var ui_manager = $UIManager
@onready var camera_controller = $CameraController
@onready var effect_manager = $EffectManager

# Rust systems (via RustCore)
var combat_system: Object
var ai_system: Object
var pathfinding_system: Object

# Battle data
var battle_data: Dictionary = {}
var player_units: Array = []
var enemy_units: Array = []
var turn_order: Array = []

func _ready() -> void:
	print("[BattleController] Initializing battle...")
	
	# Get Rust systems
	combat_system = RustCore.get_combat_system()
	ai_system = RustCore.get_ai_system()
	pathfinding_system = RustCore.get_pathfinding_system()
	
	# Connect signals
	unit_manager.unit_selected.connect(_on_unit_selected)
	unit_manager.unit_action.connect(_on_unit_action)
	ui_manager.end_turn_pressed.connect(_on_end_turn)
	ui_manager.skill_selected.connect(_on_skill_selected)
	ui_manager.item_selected.connect(_on_item_selected)
	
	# Load battle data
	if GameManager.game_state.has("battle_data"):
		battle_data = GameManager.game_state.battle_data
	
	_setup_battle()

func _setup_battle() -> void:
	# Load map
	var map_id = battle_data.get("map_id", "default")
	grid_manager.load_map(map_id)
	
	# Spawn units
	_spawn_player_units()
	_spawn_enemy_units()
	
	# Calculate turn order
	_calculate_turn_order()
	
	# Start first turn
	battle_phase = BattlePhase.PLAYER_TURN
	_start_turn()

func _spawn_player_units() -> void:
	var party_data = battle_data.get("party", [])
	for i in party_data.size():
		var unit = unit_manager.spawn_unit(party_data[i], true, Vector2i(i, 0))
		player_units.append(unit)
		turn_order.append({"unit": unit, "team": 0, "has_acted": false})

func _spawn_enemy_units() -> void:
	var enemy_data = battle_data.get("enemies", [])
	for i in enemy_data.size():
		var unit = unit_manager.spawn_unit(enemy_data[i], false, Vector2i(i, 7))
		enemy_units.append(unit)
		turn_order.append({"unit": unit, "team": 1, "has_acted": false})

func _calculate_turn_order() -> void:
	# Sort by speed (SPD stat)
	turn_order.sort_custom(Callable(self, "_compare_speed"))

func _compare_speed(a: Dictionary, b: Dictionary) -> int:
	var spd_a = a.unit.get_stat("spd")
	var spd_b = b.unit.get_stat("spd")
	return spd_b - spd_a  # Descending

func _start_turn() -> void:
	# Find next unit that hasn't acted
	for entry in turn_order:
		if not entry.has_acted:
			var unit = entry.unit
			if unit.is_alive():
				unit_manager.set_active_unit(unit)
				current_team = entry.team
				
				if entry.team == 0:
					battle_phase = BattlePhase.PLAYER_TURN
					ui_manager.show_unit_actions(unit)
				else:
					battle_phase = BattlePhase.ENEMY_TURN
					_process_enemy_turn(unit)
				return
	
	# All units have acted - end phase
	_end_phase()

func _process_enemy_turn(unit: Object) -> void:
	# Get AI decision from Rust
	var allies = enemy_units.filter(func(u): return u.is_alive())
	var enemies = player_units.filter(func(u): return u.is_alive())
	var map_data = grid_manager.get_map_data()
	
	var decision = ai_system.decide_action(
		unit.get_rust_data(),
		allies.map(func(u): return u.get_rust_data()),
		enemies.map(func(u): return u.get_rust_data()),
		map_data
	)
	
	_execute_ai_decision(unit, decision)

func _execute_ai_decision(unit: Object, decision: Dictionary) -> void:
	var action_type = decision.action_type
	# Recomputed here rather than passed in: _execute_ai_decision is also called
	# from _check_followup_action, so it cannot rely on the caller's locals.
	var enemies = player_units.filter(func(u): return u.is_alive())
	var map_data = grid_manager.get_map_data()
	
	match action_type:
		"move":
			var path = decision.path
			unit_manager.move_unit_along_path(unit, path, func(): _check_followup_action(unit, decision))
		"attack":
			var target = _find_unit_by_id(decision.target_id)
			if target:
				unit_manager.attack(unit, target, decision.skill_id)
		"skill":
			var target = _find_unit_by_id(decision.target_id)
			if target:
				unit_manager.use_skill(unit, target, decision.skill_id)
		"item":
			var target = _find_unit_by_id(decision.target_id)
			if target:
				unit_manager.use_item(unit, target, decision.item_id)
		"wait":
			_end_unit_turn(unit)
		"retreat":
			# Move away from enemies
			var safe_pos = _find_safe_position(unit, enemies)
			if safe_pos:
				var path = pathfinding_system.find_path(
					unit.grid_pos, safe_pos, map_data, unit.move_type
				)
				unit_manager.move_unit_along_path(unit, path, func(): _end_unit_turn(unit))

func _check_followup_action(unit: Object, decision: Dictionary) -> void:
	if decision.has_followup:
		# Execute followup action (attack after move, etc.)
		_execute_ai_decision(unit, decision.followup)
	else:
		_end_unit_turn(unit)

func _find_unit_by_id(unit_id: String) -> Object:
	for unit in player_units + enemy_units:
		if unit.unit_id == unit_id:
			return unit
	return null

func _find_safe_position(unit: Object, enemies: Array) -> Vector2i:
	# Find position farthest from enemies
	var best_pos = unit.grid_pos
	var best_dist = 0
	
	for pos in grid_manager.get_walkable_positions(unit.grid_pos, unit.get_stat("mov"), unit.move_type):
		var min_dist = INF
		for enemy in enemies:
			var dist = pos.distance_to(enemy.grid_pos)
			min_dist = min(min_dist, dist)
		if min_dist > best_dist:
			best_dist = min_dist
			best_pos = pos
	
	return best_pos if best_dist > 0 else unit.grid_pos

func _on_unit_selected(unit: Object) -> void:
	if battle_phase != BattlePhase.PLAYER_TURN:
		return
	ui_manager.show_unit_info(unit)
	grid_manager.show_move_range(unit.grid_pos, unit.get_stat("mov"), unit.move_type)

func _on_unit_action(action_data: Dictionary) -> void:
	var action = action_data.action
	var unit = action_data.unit
	
	match action:
		"move":
			var path = action_data.path
			unit_manager.move_unit_along_path(unit, path, func():
				ui_manager.show_action_menu(unit)
			)
		"attack":
			var target = action_data.target
			var skill_id = action_data.skill_id
			unit_manager.attack(unit, target, skill_id)
		"skill":
			var target = action_data.target
			var skill_id = action_data.skill_id
			unit_manager.use_skill(unit, target, skill_id)
		"item":
			var target = action_data.target
			var item_id = action_data.item_id
			unit_manager.use_item(unit, target, item_id)
		"wait":
			_end_unit_turn(unit)

func _on_skill_selected(skill_id: String) -> void:
	var unit = unit_manager.get_active_unit()
	if not unit:
		return
	
	var skill = DataRegistry.get_skill(skill_id)
	if not skill:
		return
	
	grid_manager.show_skill_range(unit.grid_pos, skill.range, skill.aoe_radius, skill.aoe_shape, skill.target_type)

func _on_item_selected(item_id: String) -> void:
	var unit = unit_manager.get_active_unit()
	if not unit:
		return
	
	var item = DataRegistry.get_item(item_id)
	if not item:
		return
	
	grid_manager.show_item_range(unit.grid_pos, item.range, item.target_type)

func _on_end_turn() -> void:
	var unit = unit_manager.get_active_unit()
	if unit:
		_end_unit_turn(unit)

func _end_unit_turn(unit: Object) -> void:
	# Mark as acted in turn order
	for entry in turn_order:
		if entry.unit == unit:
			entry.has_acted = true
			break
	
	unit_manager.clear_active_unit()
	grid_manager.clear_highlights()
	ui_manager.hide_menus()
	
	_start_turn()

func _end_phase() -> void:
	turn_count += 1
	
	# Reset has_acted for all
	for entry in turn_order:
		entry.has_acted = false
	
	# Apply turn-based effects (regeneration, status ticks, etc.)
	_process_turn_effects()
	
	# Check victory/defeat
	if _check_victory():
		battle_phase = BattlePhase.VICTORY
		_on_victory()
		return
	
	if _check_defeat():
		battle_phase = BattlePhase.DEFEAT
		_on_defeat()
		return
	
	# Start next phase
	_start_turn()

func _process_turn_effects() -> void:
	for unit in player_units + enemy_units:
		if unit.is_alive():
			unit.process_turn_effects()

func _check_victory() -> bool:
	for unit in enemy_units:
		if unit.is_alive():
			return false
	return true

func _check_defeat() -> bool:
	for unit in player_units:
		if unit.is_alive():
			return false
	return true

func _on_victory() -> void:
	print("[BattleController] Victory!")
	ui_manager.show_victory_screen()
	
	# Calculate rewards
	var rewards = _calculate_rewards()
	GameManager.game_state.last_battle_result = {"victory": true, "rewards": rewards}
	
	# Save
	SaveManager.save_game()

func _on_defeat() -> void:
	print("[BattleController] Defeat!")
	ui_manager.show_defeat_screen()
	
	GameManager.game_state.last_battle_result = {"victory": false}

func _calculate_rewards() -> Dictionary:
	# Calculate EXP, gold, items from defeated enemies
	var total_exp = 0
	var total_gold = 0
	var items = []
	
	for unit in enemy_units:
		total_exp += unit.get_exp_reward()
		total_gold += unit.get_gold_reward()
		for drop in unit.get_drops():
			if randf() < drop.chance:
				items.append(drop.item_id)
	
	return {
		"exp": total_exp,
		"gold": total_gold,
		"items": items
	}

func get_battle_state() -> Dictionary:
	return {
		"phase": battle_phase,
		"turn": turn_count,
		"player_units": player_units.map(func(u): return u.get_state()),
		"enemy_units": enemy_units.map(func(u): return u.get_state())
	}