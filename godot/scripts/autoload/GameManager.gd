extends Node

## GameManager.gd
## Core game state manager - bridges Godot and Rust GDExtension
## Singleton: GameManager

# Game state
var current_scene: String = ""
var game_state: Dictionary = {}
var is_battle_active: bool = false

# Rust GDExtension reference
@onready var gdext_manager = RustCore

func _ready() -> void:
	print("[GameManager] Initialized")
	# Initialize Rust GDExtension
	if gdext_manager and not gdext_manager.is_initialized:
		# RustCore boots itself from its own _ready(); the old call to
		# initialize() no longer existed and threw at runtime.
		print("[GameManager] Rust core: %s" % ("ready" if gdext_manager.is_initialized else "not yet loaded"))

func change_scene(scene_path: String) -> void:
	current_scene = scene_path
	get_tree().change_scene_to_file(scene_path)

func start_battle(battle_data: Dictionary) -> void:
	is_battle_active = true
	game_state.battle_data = battle_data
	change_scene("res://scenes/battle/BattleScene.tscn")

func end_battle(result: Dictionary) -> void:
	is_battle_active = false
	game_state.last_battle_result = result
	change_scene("res://scenes/ui/MainMenu.tscn")

func get_rust_combat() -> Object:
	"""Get Rust combat system instance"""
	if gdext_manager and gdext_manager.is_initialized:
		return gdext_manager.get_combat_system()
	return null

func get_rust_ai() -> Object:
	"""Get Rust AI system instance"""
	if gdext_manager and gdext_manager.is_initialized:
		return gdext_manager.get_ai_system()
	return null

func get_rust_pathfinding() -> Object:
	"""Get Rust pathfinding system instance"""
	if gdext_manager and gdext_manager.is_initialized:
		return gdext_manager.get_pathfinding_system()
	return null
