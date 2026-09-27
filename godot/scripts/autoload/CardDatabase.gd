extends Node

## CardDatabase.gd
## Manages card definitions, loads from resources and Rust data
## Singleton: CardDatabase

# Card cache: card_id -> card_data
var cards: Dictionary = {}
var cards_by_class: Dictionary = {}
var cards_by_rarity: Dictionary = {}

# Rust data registry reference
@onready var data_registry = DataRegistry

func _ready() -> void:
	print("[CardDatabase] Initialized")
	load_all_cards()

func load_all_cards() -> void:
	# Load from Godot resources (.tres files in resources/cards/)
	var card_files = DirAccess.get_files_at("res://resources/cards/")
	for file in card_files:
		if file.ends_with(".tres"):
			var card_resource = ResourceLoader.load("res://resources/cards/" + file)
			if card_resource:
				_register_card(card_resource)
	
	# Also sync with Rust data registry
	if data_registry and data_registry.is_ready:
		_sync_with_rust()

func _register_card(card_data: Resource) -> void:
	var id = card_data.card_id
	cards[id] = card_data
	
	var unit_class_name = card_data.class_type
	if not cards_by_class.has(unit_class_name):
		cards_by_class[unit_class_name] = []
	cards_by_class[unit_class_name].append(card_data)
	
	var rarity = card_data.rarity
	if not cards_by_rarity.has(rarity):
		cards_by_rarity[rarity] = []
	cards_by_rarity[rarity].append(card_data)

func _sync_with_rust() -> void:
	# Sync card data from Rust GDExtension
	var rust_cards = data_registry.get_all_cards()
	for rust_card in rust_cards:
		if not cards.has(rust_card.id):
			# Create Godot resource from Rust data
			var card_res = _create_card_resource(rust_card)
			_register_card(card_res)

func _create_card_resource(rust_card: Dictionary) -> Resource:
	# Create a CardResource from Rust data
	var script = load("res://scripts/resources/CardResource.gd")
	var card = script.new()
	card.card_id = rust_card.id
	card.name = rust_card.name
	card.description = rust_card.description
	card.class_type = rust_card.class_type
	card.rarity = rust_card.rarity
	card.cost = rust_card.cost
	card.effects = rust_card.effects
	return card

func get_card(card_id: String) -> Resource:
	return cards.get(card_id, null)

func get_cards_by_class(class_type: String) -> Array:
	return cards_by_class.get(class_type, [])

func get_cards_by_rarity(rarity: String) -> Array:
	return cards_by_rarity.get(rarity, [])

func get_random_card(rarity: String = "", class_type: String = "") -> Resource:
	var pool = cards.values()
	if rarity:
		pool = cards_by_rarity.get(rarity, [])
	if class_type:
		pool = cards_by_class.get(class_type, [])
	if pool.size() == 0:
		return null
	return pool.pick_random()
