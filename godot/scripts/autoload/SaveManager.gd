extends Node

## SaveManager.gd
## Handles game save/load with encryption and versioning
## Singleton: SaveManager

const SAVE_VERSION = 1
const SAVE_SLOTS = 10
const SAVE_EXTENSION = ".save"

var current_slot: int = 0

func _ready() -> void:
	print("[SaveManager] Initialized")

func save_game(slot: int = -1, custom_data: Dictionary = {}) -> bool:
	if slot == -1:
		slot = current_slot
	
	var save_data = _gather_save_data()
	save_data.version = SAVE_VERSION
	save_data.timestamp = Time.get_unix_time_from_system()
	save_data.slot = slot
	
	# Merge custom data
	for key in custom_data:
		save_data[key] = custom_data[key]
	
	# Serialize
	var json_str = JSON.stringify(save_data)
	
	# Encrypt (simple XOR for now, replace with proper encryption)
	var encrypted = _encrypt(json_str)
	
	# Write to file
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://saves"))
	var file = FileAccess.open("user://saves/save_slot_%d%s" % [slot, SAVE_EXTENSION], FileAccess.WRITE)
	if not file:
		push_error("[SaveManager] Failed to open save file for writing")
		return false
	
	file.store_buffer(encrypted.to_utf8_buffer())
	file.close()
	
	print("[SaveManager] Game saved to slot %d" % slot)
	return true

func load_game(slot: int) -> Dictionary:
	var file = FileAccess.open("user://saves/save_slot_%d%s" % [slot, SAVE_EXTENSION], FileAccess.READ)
	if not file:
		push_error("[SaveManager] Save file not found: slot %d" % slot)
		return {}
	
	var encrypted = file.get_as_text()
	file.close()
	
	# Decrypt
	var json_str = _decrypt(encrypted)
	
	# Parse
	var parsed: Variant = JSON.parse_string(json_str)
	if not parsed is Dictionary:
		push_error("[SaveManager] Failed to parse save data as a dictionary")
		return {}
	
	var save_data: Dictionary = parsed
	
	# Version check
	if save_data.version != SAVE_VERSION:
		save_data = _migrate_save(save_data)
	
	print("[SaveManager] Game loaded from slot %d" % slot)
	return save_data

func apply_save_data(save_data: Dictionary) -> void:
	# Apply to game state
	if save_data.has("game_state"):
		GameManager.game_state = save_data.game_state
	
	if save_data.has("player_data"):
		# Apply to player/party
		_pass_to_rust("apply_player_data", save_data.player_data)
	
	if save_data.has("inventory"):
		_pass_to_rust("apply_inventory", save_data.inventory)
	
	if save_data.has("unlocks"):
		_pass_to_rust("apply_unlocks", save_data.unlocks)
	
	# Load scene
	if save_data.has("current_scene"):
		GameManager.change_scene(save_data.current_scene)

func _gather_save_data() -> Dictionary:
	var data = {}
	data.game_state = GameManager.game_state
	
	# Get player/party data from Rust
	data.player_data = _pass_to_rust("get_player_data", {})
	data.inventory = _pass_to_rust("get_inventory", {})
	data.unlocks = _pass_to_rust("get_unlocks", {})
	data.current_scene = GameManager.current_scene
	
	return data

func _pass_to_rust(method: String, args: Dictionary) -> Variant:
	if RustCore and RustCore.is_initialized:
		var rust_save = RustCore.get_save_system()
		if rust_save and rust_save.has_method(method):
			return rust_save.call(method, args)
	if method in ["get_player_data", "get_inventory", "get_unlocks"]:
		return {}
	return null

func _encrypt(data: String) -> String:
	# Simple XOR encryption - replace with proper crypto in production
	var key = "BlinkArcanaSaveKey2024"
	var result = PackedByteArray()
	var data_bytes = data.to_utf8_buffer()
	var key_bytes = key.to_utf8_buffer()
	for i in range(data_bytes.size()):
		result.append(data_bytes[i] ^ key_bytes[i % key_bytes.size()])
	return Marshalls.raw_to_base64(result)

func _decrypt(data: String) -> String:
	var key = "BlinkArcanaSaveKey2024"
	var decoded = Marshalls.base64_to_raw(data)
	var key_bytes = key.to_utf8_buffer()
	var result = PackedByteArray()
	for i in range(decoded.size()):
		result.append(decoded[i] ^ key_bytes[i % key_bytes.size()])
	return result.get_string_from_utf8()

func _migrate_save(old_data: Dictionary) -> Dictionary:
	# Handle save version migrations
	print("[SaveManager] Migrating save from version %d to %d" % [old_data.version, SAVE_VERSION])
	# Add migration logic here
	return old_data

func get_save_info(slot: int) -> Dictionary:
	var file = FileAccess.open("user://saves/save_slot_%d%s" % [slot, SAVE_EXTENSION], FileAccess.READ)
	if not file:
		return {"exists": false}
	
	var encrypted = file.get_as_text()
	file.close()
	
	var json_str = _decrypt(encrypted)
	var parsed: Variant = JSON.parse_string(json_str)
	if not parsed is Dictionary:
		return {"exists": true, "corrupted": true}
	
	var data: Dictionary = parsed
	var game_state: Dictionary = data.get("game_state", {})
	var player_data: Dictionary = data.get("player_data", {})
	return {
		"exists": true,
		"version": data.get("version", 0),
		"timestamp": data.get("timestamp", 0),
		"playtime": game_state.get("playtime", 0),
		"chapter": game_state.get("chapter", 1),
		"party_level": player_data.get("party_avg_level", 1)
	}

func delete_save(slot: int) -> void:
	var path = "user://saves/save_slot_%d%s" % [slot, SAVE_EXTENSION]
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
		print("[SaveManager] Deleted save slot %d" % slot)

func list_saves() -> Array:
	var saves = []
	for i in range(SAVE_SLOTS):
		saves.append(get_save_info(i))
	return saves
