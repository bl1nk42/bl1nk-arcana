extends Node

## Minimal Godot 4 audio service; player nodes are created by the autoload at runtime.

var bgm_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var voice_player: AudioStreamPlayer
var bgm_cache: Dictionary = {}
var sfx_cache: Dictionary = {}
var master_volume: float = 1.0
var bgm_volume: float = 0.7
var sfx_volume: float = 1.0
var voice_volume: float = 1.0

func _ready() -> void:
	bgm_player = _ensure_player("BGMPlayer")
	sfx_player = _ensure_player("SFXPlayer")
	voice_player = _ensure_player("VoicePlayer")
	_load_audio_settings()
	_preload_common_sfx()
	print("[AudioManager] Initialized")

func _ensure_player(player_name: String) -> AudioStreamPlayer:
	var player := get_node_or_null(player_name) as AudioStreamPlayer
	if player == null:
		player = AudioStreamPlayer.new()
		player.name = player_name
		add_child(player)
	return player

func _load_audio_settings() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://settings"))
	var config := ConfigFile.new()
	if config.load("user://settings/audio.cfg") == OK:
		master_volume = float(config.get_value("audio", "master_volume", 1.0))
		bgm_volume = float(config.get_value("audio", "bgm_volume", 0.7))
		sfx_volume = float(config.get_value("audio", "sfx_volume", 1.0))
		voice_volume = float(config.get_value("audio", "voice_volume", 1.0))
	_apply_volumes()

func _apply_volumes() -> void:
	bgm_player.volume_db = linear_to_db(maxf(0.001, master_volume * bgm_volume))
	sfx_player.volume_db = linear_to_db(maxf(0.001, master_volume * sfx_volume))
	voice_player.volume_db = linear_to_db(maxf(0.001, master_volume * voice_volume))

func _preload_common_sfx() -> void:
	for sfx_name in ["ui_click", "ui_hover", "ui_confirm", "ui_cancel", "skill_use", "skill_cooldown", "skill_master", "attack_hit", "attack_miss", "attack_crit", "heal", "buff", "debuff", "level_up", "victory", "defeat"]:
		var path := "res://assets/audio/sfx/%s.ogg" % sfx_name
		if ResourceLoader.exists(path):
			sfx_cache[sfx_name] = load(path)

func play_bgm(bgm_name: String, _fade_time: float = 1.0) -> void:
	var stream: AudioStream = bgm_cache.get(bgm_name)
	if stream == null:
		var path := "res://assets/audio/bgm/%s.ogg" % bgm_name
		if not ResourceLoader.exists(path):
			push_warning("[AudioManager] BGM not found: " + path)
			return
		stream = load(path)
		bgm_cache[bgm_name] = stream
	bgm_player.stream = stream
	bgm_player.volume_db = linear_to_db(maxf(0.001, master_volume * bgm_volume))
	bgm_player.play()

func stop_bgm(_fade_time: float = 1.0) -> void:
	bgm_player.stop()

func play_sfx(sfx_name: String, volume_scale: float = 1.0) -> void:
	var stream: AudioStream = sfx_cache.get(sfx_name)
	if stream == null:
		var path := "res://assets/audio/sfx/%s.ogg" % sfx_name
		if not ResourceLoader.exists(path):
			push_warning("[AudioManager] SFX not found: " + path)
			return
		stream = load(path)
		sfx_cache[sfx_name] = stream
	sfx_player.stream = stream
	sfx_player.volume_db = linear_to_db(maxf(0.001, master_volume * sfx_volume * volume_scale))
	sfx_player.play()

func play_voice(voice_name: String) -> void:
	var path := "res://assets/audio/voice/%s.ogg" % voice_name
	if ResourceLoader.exists(path):
		voice_player.stream = load(path)
		voice_player.volume_db = linear_to_db(maxf(0.001, master_volume * voice_volume))
		voice_player.play()

func _save_audio_settings() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("user://settings"))
	var config := ConfigFile.new()
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "bgm_volume", bgm_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.set_value("audio", "voice_volume", voice_volume)
	config.save("user://settings/audio.cfg")

func set_master_volume(volume: float) -> void:
	master_volume = clampf(volume, 0.0, 1.0)
	_save_audio_settings()
	_apply_volumes()

func set_bgm_volume(volume: float) -> void:
	bgm_volume = clampf(volume, 0.0, 1.0)
	_save_audio_settings()
	_apply_volumes()

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	_save_audio_settings()
	_apply_volumes()
