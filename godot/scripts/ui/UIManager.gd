extends Control
# NOTE: must stay a Control. Every child in BattleScene.tscn uses
# layout_mode/anchors, which Godot only accepts under a Control parent — with a
# CanvasLayer here, Godot silently dropped LogPanel and LogContainer.
# z_index is set on the node instead, to draw the HUD above the battle field.

## UIManager.gd
## Manages all battle UI - action menus, unit info, turn display

class_name UIManager

signal end_turn_pressed
signal skill_selected(skill_id: String)
signal item_selected(item_id: String)
signal unit_action(action_data: Dictionary)

@onready var turn_label: Label = $TurnLabel
@onready var phase_label: Label = $PhaseLabel
@onready var action_menu: Control = $ActionMenu
@onready var skill_menu: Control = $SkillMenu
@onready var item_menu: Control = $ItemMenu
@onready var unit_info_panel: Control = $UnitInfoPanel
@onready var target_info_panel: Control = $TargetInfoPanel
@onready var damage_preview: Control = $DamagePreview
@onready var log_panel: Control = get_node_or_null("LogPanel")
@onready var victory_screen: Control = $VictoryScreen
@onready var defeat_screen: Control = $DefeatScreen

var current_unit: Object = null

func _ready() -> void:
	_hide_all_menus()
	action_menu.visible = false
	skill_menu.visible = false
	item_menu.visible = false
	unit_info_panel.visible = false
	target_info_panel.visible = false
	damage_preview.visible = false
	victory_screen.visible = false
	defeat_screen.visible = false
	var buttons := action_menu.get_node("VBoxContainer")
	buttons.get_node("MoveButton").pressed.connect(_on_MoveButton_pressed)
	buttons.get_node("AttackButton").pressed.connect(_on_AttackButton_pressed)
	buttons.get_node("SkillButton").pressed.connect(_on_SkillButton_pressed)
	buttons.get_node("ItemButton").pressed.connect(_on_ItemButton_pressed)
	buttons.get_node("WaitButton").pressed.connect(_on_WaitButton_pressed)
	get_node("EndTurnButton").pressed.connect(_on_EndTurnButton_pressed)

func _clear_children(container: Node) -> void:
	for child in container.get_children():
		child.queue_free()

func show_unit_actions(unit: Object) -> void:
	current_unit = unit
	action_menu.visible = true
	_update_action_menu(unit)
	
	# Position menu near unit
	var screen_pos = get_viewport().get_visible_rect().size / 2.0
	action_menu.global_position = screen_pos + Vector2(-150, -100)

func _update_action_menu(unit: Object) -> void:
	var can_move = unit.get_stat("mov") > 0
	var can_attack = unit.equipped_weapon != null
	var has_skills = unit.skills.size() > 0
	var has_items = _get_usable_items(unit).size() > 0
	
	var buttons := action_menu.get_node("VBoxContainer")
	buttons.get_node("MoveButton").disabled = not can_move
	buttons.get_node("AttackButton").disabled = not can_attack
	buttons.get_node("SkillButton").disabled = not has_skills
	buttons.get_node("ItemButton").disabled = not has_items
	buttons.get_node("WaitButton").disabled = false

func _get_usable_items(unit: Object) -> Array:
	var items = []
	# Check inventory for usable items
	# This would connect to the inventory system
	return items

func hide_menus() -> void:
	action_menu.visible = false
	skill_menu.visible = false
	item_menu.visible = false

func show_unit_info(unit: Object) -> void:
	unit_info_panel.visible = true
	
	var info = unit_info_panel
	info.get_node("NameLabel").text = unit.unit_name
	info.get_node("ClassLabel").text = "%s Lv.%d" % [unit.class_type, unit.level]
	info.get_node("HPLabel").text = "HP: %d/%d" % [unit.hp, unit.max_hp]
	info.get_node("MPLabel").text = "MP: %d/%d" % [unit.mp, unit.max_mp]
	info.get_node("CPLabel").text = "CP: %d/%d" % [unit.cp, unit.max_cp]
	
	# Stats
	var stats_grid = info.get_node("StatsGrid")
	stats_grid.get_node("AtkLabel").text = "ATK: %d" % unit.atk
	stats_grid.get_node("DefLabel").text = "DEF: %d" % unit.def
	stats_grid.get_node("MatkLabel").text = "MATK: %d" % unit.matk
	stats_grid.get_node("MdefLabel").text = "MDEF: %d" % unit.mdef
	stats_grid.get_node("SpdLabel").text = "SPD: %d" % unit.spd
	stats_grid.get_node("HitLabel").text = "HIT: %d" % unit.hit
	stats_grid.get_node("AvoLabel").text = "AVO: %d" % unit.avo
	stats_grid.get_node("CritLabel").text = "CRIT: %d" % unit.crit
	stats_grid.get_node("CavoLabel").text = "CAVO: %d" % unit.cavo
	stats_grid.get_node("MovLabel").text = "MOV: %d" % unit.mov
	
	# Status effects
	_update_status_display(info.get_node("StatusContainer"), unit)

func _update_status_display(container: Control, unit: Object) -> void:
	_clear_children(container)
	
	for status in unit.statuses:
		var label = Label.new()
		label.text = "%s (%d)" % [status, unit.statuses[status].duration]
		label.add_theme_color_override("font_color", Color(1, 0.5, 0))
		container.add_child(label)
	
	for stat in unit.buffs:
		var label = Label.new()
		label.text = "↑ %s +%d (%d)" % [stat, unit.buffs[stat].value, unit.buffs[stat].duration]
		label.add_theme_color_override("font_color", Color(0, 1, 0))
		container.add_child(label)
	
	for stat in unit.debuffs:
		var label = Label.new()
		label.text = "↓ %s %d (%d)" % [stat, unit.debuffs[stat].value, unit.debuffs[stat].duration]
		label.add_theme_color_override("font_color", Color(1, 0, 0))
		container.add_child(label)

func show_target_info(target: Object) -> void:
	target_info_panel.visible = true
	
	var info = target_info_panel
	info.get_node("NameLabel").text = target.unit_name
	info.get_node("ClassLabel").text = "%s Lv.%d" % [target.class_type, target.level]
	info.get_node("HPLabel").text = "HP: %d/%d" % [target.hp, target.max_hp]
	
	# Show damage preview if attacking
	if current_unit and current_unit.equipped_weapon:
		show_damage_preview(current_unit, target)

func show_damage_preview(attacker: Object, target: Object) -> void:
	damage_preview.visible = true
	
	var preview = RustCore.combat_get_damage_preview(
		attacker.get_rust_data(),
		target.get_rust_data(),
		{"skill_id": ""}  # Basic attack
	)
	
	var panel = damage_preview
	panel.get_node("DamageLabel").text = "DMG: %d ~ %d" % [preview.min_damage, preview.max_damage]
	panel.get_node("HitLabel").text = "HIT: %d%%" % preview.hit_chance
	panel.get_node("CritLabel").text = "CRIT: %d%%" % preview.crit_chance
	
	if preview.is_fatal:
		panel.get_node("FatalLabel").visible = true
	else:
		panel.get_node("FatalLabel").visible = false

func hide_damage_preview() -> void:
	damage_preview.visible = false

func show_skill_menu(unit: Object) -> void:
	skill_menu.visible = true
	
	var container = skill_menu.get_node("SkillContainer")
	_clear_children(container)
	
	for skill_id in unit.skills:
		var skill = DataRegistry.get_skill(skill_id)
		if not skill:
			continue
		
		var can_use = skill.can_use(unit.get_rust_data(), {"cp": unit.cp, "cooldowns": unit.cooldowns})
		
		var btn = Button.new()
		btn.text = "%s (MP: %d)" % [skill.name, skill.mp_cost]
		btn.disabled = not can_use
		btn.pressed.connect(skill_selected.emit.bind(skill_id))
		container.add_child(btn)

func show_item_menu(unit: Object) -> void:
	item_menu.visible = true
	
	var container = item_menu.get_node("ItemContainer")
	_clear_children(container)
	
	var items = _get_usable_items(unit)
	for item_id in items:
		var item = DataRegistry.get_item(item_id)
		if not item:
			continue
		
		var btn = Button.new()
		btn.text = "%s x%d" % [item.name, item.current_stack]
		btn.pressed.connect(item_selected.emit.bind(item_id))
		container.add_child(btn)

func update_turn_display(turn: int, phase: int) -> void:
	turn_label.text = "Turn: %d" % turn
	
	var phase_names = ["SETUP", "PLAYER TURN", "ENEMY TURN", "PLAYER END", "ENEMY END", "VICTORY", "DEFEAT", "ESCAPE"]
	if phase < phase_names.size():
		phase_label.text = phase_names[phase]

func show_victory_screen() -> void:
	victory_screen.visible = true
	var rewards := victory_screen.get_node_or_null("VBoxContainer/RewardsContainer")
	if rewards == null:
		return
	_clear_children(rewards)
	# Rewards populated by BattleController

func show_defeat_screen() -> void:
	defeat_screen.visible = true

func hide_all() -> void:
	_hide_all_menus()

func _hide_all_menus() -> void:
	action_menu.visible = false
	skill_menu.visible = false
	item_menu.visible = false
	unit_info_panel.visible = false
	target_info_panel.visible = false
	damage_preview.visible = false

func add_log_message(message: String, color: Color = Color(1, 1, 1)) -> void:
	# LogPanel does not survive scene instantiation (see docs/MERGE-REPORT.md).
	# Until that is root-caused, fail soft instead of crashing the battle loop.
	if log_panel == null:
		return
	var label = Label.new()
	label.text = message
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	log_panel.add_child(label)
	
	# Keep only last 50 messages
	if log_panel.get_child_count() > 50:
		log_panel.get_child(0).queue_free()
	
	# Scroll to bottom. log_panel IS the ScrollContainer; its parent is
	# its parent UIManager, which has no scroll_vertical — the old
	# get_parent() chain would have thrown at runtime.
	log_panel.scroll_vertical = int(log_panel.get_v_scroll_bar().max_value)

# Button handlers
func _on_MoveButton_pressed() -> void:
	unit_action.emit({"action": "move", "unit": current_unit})

func _on_AttackButton_pressed() -> void:
	unit_action.emit({"action": "attack", "unit": current_unit})

func _on_SkillButton_pressed() -> void:
	show_skill_menu(current_unit)

func _on_ItemButton_pressed() -> void:
	show_item_menu(current_unit)

func _on_WaitButton_pressed() -> void:
	unit_action.emit({"action": "wait", "unit": current_unit})

func _on_EndTurnButton_pressed() -> void:
	end_turn_pressed.emit()
