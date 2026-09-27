# Godot/GDScript Rules for Blink Arcana

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Scenes (.tscn) | PascalCase | `BattleScene.tscn`, `UnitSelector.tscn` |
| Scripts (.gd) | PascalCase | `BattleManager.gd`, `Unit.gd` |
| Resources (.tres) | PascalCase | `UnitData.tres`, `WeaponData.tres` |
| Nodes | PascalCase | `UnitSprite`, `HPBar` |
| Signals | snake_case | `unit_died`, `turn_changed` |
| Variables | snake_case | `current_hp`, `max_mov` |
| Constants | UPPER_SNAKE_CASE | `MAX_PARTY_SIZE` |
| Enums | PascalCase | `UnitState.IDLE` |

## Signal Pattern

```gdscript
# Emit with typed parameters
signal unit_died(unit_id: String, killer_id: String)
signal turn_changed(turn: int, is_player_turn: bool)

# Connect in _ready()
func _ready() -> void:
    unit_selector.unit_selected.connect(_on_unit_selected)
    battle_manager.combat_resolved.connect(_on_combat_resolved)

# Handler naming: _on_<signal_source>_<signal_name>
func _on_unit_selector_unit_selected(unit_id: String) -> void:
    pass
```

## Autoload Singletons

- Register in `project.godot` under `[autoload]`
- Access via `get_node("/root/AutoloadName")` or `AutoloadName` (if global)
- Use for: GameManager, CardDatabase, DataRegistry, AudioManager

```gdscript
# Example: GameManager.gd
extends Node

static var instance: GameManager

func _ready() -> void:
    instance = self

func get_current_battle() -> BattleState:
    return current_battle
```

## Type Hints (Required)

```gdscript
# Always type hint variables and function signatures
var current_hp: int = 0
var unit_data: Dictionary = {}
var units: Array[Unit] = []

func take_damage(amount: int) -> void:
    current_hp -= amount

func get_unit_at(x: int, y: int) -> Unit?:
    return grid.get_unit(x, y)
```

## Early Return Pattern

```gdscript
# Good: Early return reduces nesting
func can_attack(target: Unit) -> bool:
    if not target or target.is_dead():
        return false
    if distance_to(target) > attack_range:
        return false
    if current_turn != Turn.PLAYER:
        return false
    return true

# Avoid: Deep nesting
func can_attack_bad(target: Unit) -> bool:
    if target:
        if not target.is_dead():
            if distance_to(target) <= attack_range:
                if current_turn == Turn.PLAYER:
                    return true
    return false
```

## Scene Structure

```
BattleScene.tscn
├── BattleManager (Node)
├── Grid (TileMap)
├── UnitContainer (Node)
│   ├── Unit_0 (CharacterBody2D)
│   │   ├── Sprite2D
│   │   ├── CollisionShape2D
│   │   └── HPBar (CanvasLayer)
│   └── Unit_1 ...
├── UILayer (CanvasLayer)
│   ├── TurnIndicator
│   ├── HandPanel
│   └── ActionLog
└── Camera2D
```

## Resource Management

- Unit/Weapon/Skill data in `.tres` files under `godot/resources/`
- Load with `preload()` for static, `load()` for dynamic
- Use `ResourceLoader.load_threaded_request()` for async

## Input Handling

- Use `_unhandled_input()` for game input
- Use `_input()` for UI input
- Action map in `project.godot` → Input Map

## Performance

- Avoid `get_node()` in loops — cache references
- Use `Object.is_valid()` before calling on potentially freed nodes
- Pool frequently instantiated objects (damage numbers, particles)
