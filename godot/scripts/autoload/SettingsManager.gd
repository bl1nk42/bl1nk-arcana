extends Node

## SettingsManager.gd
## Manages game settings (video, audio, gameplay, controls)
## Singleton: SettingsManager

const SETTINGS_FILE = "user://settings/game.cfg"

# Video settings
var resolution: Vector2i = Vector2i(1280, 720)
var fullscreen_mode: int = 0  # 0=windowed, 1=fullscreen, 2=exclusive fullscreen
var vsync_enabled: bool = true
var fps_cap: int = 60
var render_scale: float = 1.0
var texture_filter: int = 1  # 0=nearest, 1=linear

# Gameplay settings
var battle_speed: float = 1.0
var auto_battle: bool = false
var show_damage_numbers: bool = true
var show_hit_chance: bool = true
var confirm_actions: bool = true
var language: String = "en"

# Accessibility
var high_contrast: bool = false
var large_text: bool = false
var reduce_motion: bool = false
var colorblind_mode: String = "none"  # none, protanopia, deuteranopia, tritanopia

func _ready() -> void:
	print("[SettingsManager] Initialized")
	load_settings()
	_apply_video_settings()

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load(SETTINGS_FILE) != OK:
		_reset_to_defaults()
		return
	
	# Video
	resolution = Vector2i(config.get_value("video", "width", 1280), config.get_value("video", "height", 720))
	fullscreen_mode = config.get_value("video", "fullscreen_mode", 0)
	vsync_enabled = config.get_value("video", "vsync", true)
	fps_cap = config.get_value("video", "fps_cap", 60)
	render_scale = config.get_value("video", "render_scale", 1.0)
	texture_filter = config.get_value("video", "texture_filter", 1)
	
	# Gameplay
	battle_speed = config.get_value("gameplay", "battle_speed", 1.0)
	auto_battle = config.get_value("gameplay", "auto_battle", false)
	show_damage_numbers = config.get_value("gameplay", "show_damage_numbers", true)
	show_hit_chance = config.get_value("gameplay", "show_hit_chance", true)
	confirm_actions = config.get_value("gameplay", "confirm_actions", true)
	language = config.get_value("gameplay", "language", "en")
	
	# Accessibility
	high_contrast = config.get_value("accessibility", "high_contrast", false)
	large_text = config.get_value("accessibility", "large_text", false)
	reduce_motion = config.get_value("accessibility", "reduce_motion", false)
	colorblind_mode = config.get_value("accessibility", "colorblind_mode", "none")

func save_settings() -> void:
	var config = ConfigFile.new()
	
	# Video
	config.set_value("video", "width", resolution.x)
	config.set_value("video", "height", resolution.y)
	config.set_value("video", "fullscreen_mode", fullscreen_mode)
	config.set_value("video", "vsync", vsync_enabled)
	config.set_value("video", "fps_cap", fps_cap)
	config.set_value("video", "render_scale", render_scale)
	config.set_value("video", "texture_filter", texture_filter)
	
	# Gameplay
	config.set_value("gameplay", "battle_speed", battle_speed)
	config.set_value("gameplay", "auto_battle", auto_battle)
	config.set_value("gameplay", "show_damage_numbers", show_damage_numbers)
	config.set_value("gameplay", "show_hit_chance", show_hit_chance)
	config.set_value("gameplay", "confirm_actions", confirm_actions)
	config.set_value("gameplay", "language", language)
	
	# Accessibility
	config.set_value("accessibility", "high_contrast", high_contrast)
	config.set_value("accessibility", "large_text", large_text)
	config.set_value("accessibility", "reduce_motion", reduce_motion)
	config.set_value("accessibility", "colorblind_mode", colorblind_mode)
	
	config.save(SETTINGS_FILE)
	print("[SettingsManager] Settings saved")

func _apply_video_settings() -> void:
	DisplayServer.window_set_size(resolution)
	var window_mode := DisplayServer.WINDOW_MODE_WINDOWED
	if fullscreen_mode == 1:
		window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	elif fullscreen_mode == 2:
		window_mode = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	DisplayServer.window_set_mode(window_mode)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync_enabled else DisplayServer.VSYNC_DISABLED)
	
	if fps_cap > 0:
		Engine.max_fps = fps_cap
	else:
		Engine.max_fps = 0  # Unlimited
	
	# Godot 4.3 has no RenderingServer.set_default_texture_filter(); the default
	# 2D filter is a project setting, and the enum lives on CanvasItem.
	# texture_filter here: 0 = nearest, 1 = linear.
	ProjectSettings.set_setting(
		"rendering/textures/canvas_textures/default_texture_filter",
		CanvasItem.TEXTURE_FILTER_NEAREST if texture_filter == 0 else CanvasItem.TEXTURE_FILTER_LINEAR
	)
	

func _reset_to_defaults() -> void:
	resolution = Vector2i(1280, 720)
	fullscreen_mode = 0
	vsync_enabled = true
	fps_cap = 60
	render_scale = 1.0
	texture_filter = 1
	battle_speed = 1.0
	auto_battle = false
	show_damage_numbers = true
	show_hit_chance = true
	confirm_actions = true
	language = "en"
	high_contrast = false
	large_text = false
	reduce_motion = false
	colorblind_mode = "none"
	save_settings()

func set_resolution(width: int, height: int) -> void:
	resolution = Vector2i(width, height)
	_apply_video_settings()
	save_settings()

func set_fullscreen_mode(mode: int) -> void:
	fullscreen_mode = clamp(mode, 0, 2)
	_apply_video_settings()
	save_settings()

func set_vsync(enabled: bool) -> void:
	vsync_enabled = enabled
	_apply_video_settings()
	save_settings()

func set_fps_cap(cap: int) -> void:
	fps_cap = max(0, cap)
	_apply_video_settings()
	save_settings()

func set_battle_speed(speed: float) -> void:
	battle_speed = clamp(speed, 0.5, 3.0)
	save_settings()
	# Notify Rust if needed
	if RustCore and RustCore.is_initialized:
		RustCore.call_rust("set_battle_speed", battle_speed)

func set_language(lang: String) -> void:
	language = lang
	save_settings()
	# Apply translation
	TranslationServer.set_locale(lang)

func apply_accessibility() -> void:
	# Apply accessibility settings to UI
	if high_contrast:
		# Apply high contrast theme
		pass
	if large_text:
		# Scale UI fonts
		pass
	if reduce_motion:
		# Disable/reduce animations
		pass
	# Colorblind mode handled in shaders/materials
