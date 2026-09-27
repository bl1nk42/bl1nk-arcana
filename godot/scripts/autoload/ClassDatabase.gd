extends Node

## Registry for ClassResource lookup via the ClassDatabase autoload.

var _classes: Dictionary = {}
var _initialized: bool = false

func initialize() -> void:
	if _initialized:
		return
	var directory := "res://resources/classes/"
	if DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(directory)):
		for resource_file in DirAccess.get_files_at(directory):
			if resource_file.ends_with(".tres"):
				var resource = ResourceLoader.load(directory + resource_file)
				if resource is ClassResource:
					_classes[resource.class_id] = resource
	_initialized = true
	print("[ClassDatabase] Initialized with %d classes" % _classes.size())

func get_class_resource(class_id: String) -> ClassResource:
	if not _initialized:
		initialize()
	return _classes.get(class_id) as ClassResource

func has_class(class_id: String) -> bool:
	if not _initialized:
		initialize()
	return _classes.has(class_id)

func get_all_classes() -> Array:
	if not _initialized:
		initialize()
	return _classes.values()

func get_by_tier(tier: int) -> Array:
	if not _initialized:
		initialize()
	var result: Array = []
	for class_resource in _classes.values():
		if class_resource.tier == tier:
			result.append(class_resource)
	return result

func get_promotion_options(base_class: String) -> Array:
	if not _initialized:
		initialize()
	var result: Array = []
	if _classes.has(base_class):
		var base = _classes[base_class]
		for promo_id in base.promotion_classes:
			if _classes.has(promo_id):
				result.append(_classes[promo_id])
	return result

func get_base_classes() -> Array:
	return get_by_tier(1)
