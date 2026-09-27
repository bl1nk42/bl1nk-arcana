extends Node

## GridManager.gd
## Manages battle grid - tiles, pathfinding integration, highlights

class_name GridManager

# Grid configuration
@export var grid_width: int = 8
@export var grid_height: int = 8
@export var tile_size: Vector2 = Vector2(64, 64)
@export var tile_origin: Vector2 = Vector2(0, 0)

# Tile data
var tiles: Array = []
var tile_map: Dictionary = {}  # "x,y" -> tile_data

# Visual
@onready var highlight_layer: Node2D = $HighlightLayer
@onready var tile_sprites: Node2D = $TileSprites

# Current highlights
var move_highlights: Array[Node2D] = []
var attack_highlights: Array[Node2D] = []
var skill_highlights: Array[Node2D] = []
var path_preview: Array[Node2D] = []

func _ready() -> void:
	_init_grid()

func _init_grid() -> void:
	tiles.clear()
	tile_map.clear()
	
	for y in range(grid_height):
		for x in range(grid_width):
			var pos = Vector2i(x, y)
			var tile_data = {
				"position": pos,
				"world_pos": _grid_to_world(pos),
				"terrain": "plain",
				"height": 0,
				"occupant": null,
				"passable": true,
				"move_cost": 1
			}
			tiles.append(tile_data)
			tile_map["%d,%d" % [x, y]] = tile_data
	
	_draw_grid()

func _grid_to_world(pos: Vector2i) -> Vector2:
	return tile_origin + Vector2(pos.x * tile_size.x, pos.y * tile_size.y)

func _world_to_grid(pos: Vector2) -> Vector2i:
	var local = pos - tile_origin
	return Vector2i(int(local.x / tile_size.x), int(local.y / tile_size.y))

func load_map(map_id: String) -> void:
	var map_path := "res://assets/maps/%s.tres" % map_id
	if ResourceLoader.exists(map_path):
		var map_resource = ResourceLoader.load(map_path)
		if map_resource:
			_apply_map_data(map_resource)
		else:
			_generate_default_map()
	else:
		# Generate a deterministic fallback while no authored map resources exist.
		_generate_default_map()
	
	_draw_grid()

func _apply_map_data(map_data: Resource) -> void:
	grid_width = map_data.width
	grid_height = map_data.height
	tile_size = map_data.tile_size
	tile_origin = map_data.origin
	
	_init_grid()
	
	for tile_info in map_data.tiles:
		var key = "%d,%d" % [tile_info.x, tile_info.y]
		if tile_map.has(key):
			tile_map[key].terrain = tile_info.terrain
			tile_map[key].height = tile_info.height
			tile_map[key].passable = tile_info.passable
			tile_map[key].move_cost = tile_info.move_cost

func _generate_default_map() -> void:
	# Simple default map
	for tile in tiles:
		var x = tile.position.x
		var y = tile.position.y
		
		# Add some variation
		if (x + y) % 3 == 0:
			tile.terrain = "grass"
			tile.move_cost = 1
		elif (x + y) % 5 == 0:
			tile.terrain = "forest"
			tile.move_cost = 2
		elif x == 0 or x == grid_width - 1 or y == 0 or y == grid_height - 1:
			tile.terrain = "wall"
			tile.passable = false
			tile.move_cost = 99

func _draw_grid() -> void:
	tile_sprites.queue_free()
	tile_sprites = Node2D.new()
	tile_sprites.name = "TileSprites"
	add_child(tile_sprites)
	
	for tile in tiles:
		var sprite = Sprite2D.new()
		sprite.position = tile.world_pos
		sprite.texture = _get_terrain_texture(tile.terrain)
		sprite.modulate = _get_terrain_color(tile.terrain)
		tile_sprites.add_child(sprite)

func _get_terrain_texture(terrain: String) -> Texture2D:
	# Return appropriate texture
	return null  # Placeholder

func _get_terrain_color(terrain: String) -> Color:
	match terrain:
		"plain": return Color(0.8, 0.8, 0.8)
		"grass": return Color(0.4, 0.7, 0.3)
		"forest": return Color(0.2, 0.5, 0.2)
		"water": return Color(0.2, 0.4, 0.8)
		"mountain": return Color(0.5, 0.5, 0.5)
		"wall": return Color(0.3, 0.3, 0.3)
		"sand": return Color(0.9, 0.8, 0.5)
		"lava": return Color(0.9, 0.3, 0.1)
		_ : return Color(0.7, 0.7, 0.7)

func get_tile(pos: Vector2i) -> Dictionary:
	var key = "%d,%d" % [pos.x, pos.y]
	return tile_map.get(key, null)

func get_tile_at_world(world_pos: Vector2) -> Dictionary:
	return get_tile(_world_to_grid(world_pos))

func set_occupant(pos: Vector2i, unit: Object) -> void:
	var tile = get_tile(pos)
	if tile:
		tile.occupant = unit

func get_occupant(pos: Vector2i) -> Object:
	var tile = get_tile(pos)
	return tile.occupant if tile else null

func is_passable(pos: Vector2i, move_type: String = "foot") -> bool:
	var tile = get_tile(pos)
	if not tile:
		return false
	if not tile.passable:
		return false
	if tile.occupant:
		return false
	return true

func get_move_cost(pos: Vector2i, move_type: String) -> int:
	var tile = get_tile(pos)
	if not tile:
		return 99
	
	# Modify cost based on move type and terrain
	var base_cost = tile.move_cost
	match move_type:
		"fly":
			return 1  # Flying ignores terrain
		"horse":
			if tile.terrain in ["forest", "mountain"]:
				return base_cost + 1
		"armor":
			if tile.terrain in ["forest", "sand", "water"]:
				return base_cost + 2
	return base_cost

func get_map_data() -> Dictionary:
	return {
		"width": grid_width,
		"height": grid_height,
		"tiles": tiles.map(func(t): {
			"x": t.position.x,
			"y": t.position.y,
			"terrain": t.terrain,
			"height": t.height,
			"passable": t.passable,
			"move_cost": t.move_cost,
			"occupant_id": t.occupant.unit_id if t.occupant else ""
		})
	}

func get_walkable_positions(start: Vector2i, move_range: int, move_type: String) -> Array[Vector2i]:
	# Use Rust pathfinding for reachable tiles
	if RustCore.is_initialized:
		# Rust takes MoveType as an int (Walk=0, Fly=1); this script uses strings.
		return RustCore.pathfinding_get_reachable(start, move_range, get_map_data(), _move_type_to_int(move_type))
	
	# Fallback: simple BFS
	return _bfs_reachable(start, move_range, move_type)

func _bfs_reachable(start: Vector2i, move_range: int, move_type: String) -> Array[Vector2i]:
	var visited = {}
	var queue: Array[Dictionary] = [{"pos": start, "cost": 0}]
	var reachable = []
	
	while queue.size() > 0:
		var current = queue.pop_front()
		var pos: Vector2i = current["pos"]
		var cost: int = current["cost"]
		
		var key = "%d,%d" % [pos.x, pos.y]
		if visited.has(key):
			continue
		visited[key] = true
		
		if cost <= move_range:
			reachable.append(pos)
			
			# Check neighbors
			for dir in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
				var next_pos = pos + dir
				if is_passable(next_pos, move_type):
					var next_cost = cost + get_move_cost(next_pos, move_type)
					if next_cost <= move_range:
						queue.append({"pos": next_pos, "cost": next_cost})
	
	return reachable

# Highlight functions
func show_move_range(start: Vector2i, move_range: int, move_type: String) -> void:
	clear_highlights()
	
	var reachable = get_walkable_positions(start, move_range, move_type)
	for pos in reachable:
		var highlight = _create_highlight(pos, Color(0, 1, 0, 0.5))
		move_highlights.append(highlight)
		highlight_layer.add_child(highlight)

func show_attack_range(start: Vector2i, range_min: int, range_max: int) -> void:
	clear_attack_highlights()
	
	for y in range(grid_height):
		for x in range(grid_width):
			var pos = Vector2i(x, y)
			var dist = start.distance_to(pos)
			if dist >= range_min and dist <= range_max:
				var tile = get_tile(pos)
				if tile and tile.occupant:
					var highlight = _create_highlight(pos, Color(1, 0, 0, 0.5))
					attack_highlights.append(highlight)
					highlight_layer.add_child(highlight)

func show_skill_range(start: Vector2i, range: int, aoe_radius: int, aoe_shape: String, target_type: String) -> void:
	clear_skill_highlights()
	
	# Show valid target positions based on skill properties
	var valid_positions = _get_valid_skill_positions(start, range, aoe_radius, aoe_shape, target_type)
	for pos in valid_positions:
		var color = Color(0, 0.5, 1, 0.5) if target_type == "ally" else Color(1, 0.5, 0, 0.5)
		var highlight = _create_highlight(pos, color)
		skill_highlights.append(highlight)
		highlight_layer.add_child(highlight)

func show_item_range(start: Vector2i, range: int, target_type: String) -> void:
	show_skill_range(start, range, 0, "circle", target_type)

func show_path_preview(path: Array[Vector2i]) -> void:
	clear_path_preview()
	
	for i in range(path.size()):
		var pos = path[i]
		var highlight = _create_highlight(pos, Color(1, 1, 0, 0.7))
		if i == path.size() - 1:
			# Destination marker
			highlight.modulate = Color(1, 1, 0, 1.0)
			var label = Label.new()
			label.text = "%d" % (i + 1)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			highlight.add_child(label)
		path_preview.append(highlight)
		highlight_layer.add_child(highlight)

func _get_valid_skill_positions(start: Vector2i, range: int, aoe_radius: int, aoe_shape: String, target_type: String) -> Array[Vector2i]:
	var positions = []
	
	for y in range(grid_height):
		for x in range(grid_width):
			var pos = Vector2i(x, y)
			var dist = start.distance_to(pos)
			
			if dist <= range:
				var tile = get_tile(pos)
				var valid = false
				
				match target_type:
					"enemy":
						valid = tile and tile.occupant and tile.occupant.team != 0
					"ally":
						valid = tile and tile.occupant and tile.occupant.team == 0
					"self":
						valid = pos == start
					"empty":
						valid = tile and not tile.occupant
					"all", "area":
						valid = true
				
				if valid:
					positions.append(pos)
	
	return positions

func _create_highlight(pos: Vector2i, color: Color) -> Node2D:
	var tile = get_tile(pos)
	if not tile:
		return null
	
	var highlight = Polygon2D.new()
	highlight.polygon = PackedVector2Array([Vector2.ZERO, Vector2(tile_size.x, 0), tile_size, Vector2(0, tile_size.y)])
	highlight.position = tile.world_pos
	highlight.color = color
	return highlight

func clear_highlights() -> void:
	for h in move_highlights:
		h.queue_free()
	move_highlights.clear()

func clear_attack_highlights() -> void:
	for h in attack_highlights:
		h.queue_free()
	attack_highlights.clear()

func clear_skill_highlights() -> void:
	for h in skill_highlights:
		h.queue_free()
	skill_highlights.clear()

func clear_path_preview() -> void:
	for h in path_preview:
		h.queue_free()
	path_preview.clear()

func clear_all_highlights() -> void:
	clear_highlights()
	clear_attack_highlights()
	clear_skill_highlights()
	clear_path_preview()

func _move_type_to_int(move_type: String) -> int:
	# Keep in sync with MoveType in rust/crates/blink-core/src/pathfinding.rs
	match move_type:
		"fly", "air", "flying":
			return 1
		_:
			return 0
