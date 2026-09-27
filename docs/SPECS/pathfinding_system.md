# Spec Sheet: Pathfinding System
**Feature ID:** PATH-001
**Status:** Draft
**Priority:** P0 (Core)
**Owner:** Lead Developer
**Created:** 2026-09-27
**Last Updated:** 2026-09-27

---

## 1. Overview
ระบบ Pathfinding แบบ A* สำหรับ Grid 8x8 รองรับ 8-directional movement, Terrain Cost, Unit Movement Type, และ Zone of Control

---

## 2. Scope
### In Scope
- A* Pathfinding (8-directional)
- Movement Cost by Terrain + Unit Move Type
- Reachable Tiles Calculation (Movement Range)
- Zone of Control (ZOC) / Threat Zones
- Path Reconstruction
- Obstacle Handling (Units, Walls, Impassable)

### Out of Scope
- AI Decision Making (see AI Spec)
- Combat Resolution (see Combat Spec)
- Data Loading (see Data Spec)
- Fog of War (Phase 3+)

---

## 3. Data Structures

### 3.1 GridMap (protobuf)
```protobuf
message GridMap {
  int32 width = 1;      // 8
  int32 height = 2;     // 8
  repeated TileRow rows = 3;
}

message TileRow {
  repeated Tile tiles = 1;
}

message Tile {
  int32 x = 1;
  int32 y = 2;
  TerrainType terrain = 3;
  bool passable = 4;
  int32 unit_id = 5;        // 0 = empty
  int32 movement_cost = 6;  // Computed per unit type
  bool is_objective = 7;
}
```

### 3.2 GridPos (protobuf)
```protobuf
message GridPos {
  int32 x = 1;
  int32 y = 2;
}
```

### 3.3 PathResult (protobuf)
```protobuf
message PathResult {
  bool found = 1;
  repeated GridPos path = 2;      // Including start, excluding start if empty
  int32 total_cost = 3;
  int32 steps = 4;
  repeated GridPos alternatives = 5; // Same-cost alternatives
}
```

### 3.4 ReachableResult (protobuf)
```protobuf
message ReachableResult {
  repeated GridPos tiles = 1;     // All reachable positions
  map<GridPos, int32> cost_map = 2; // Position -> movement cost
  repeated GridPos attack_range = 3; // Tiles that can attack from reachable
}
```

### 3.5 MoveType (enum)
```protobuf
enum MoveType {
  FOOT = 0;       // Standard infantry
  MOUNTED = 1;    // Cavalry (penalty on forest/rough)
  FLYING = 2;     // Ignores terrain cost, passable over obstacles
  ARMORED = 3;    // Heavy (penalty on sand/swamp)
  SPECIAL = 4;    // Custom (thief, etc.)
}
```

---

## 4. Terrain Movement Costs (จาก GDD.md)

| Terrain | FOOT | MOUNTED | FLYING | ARMORED |
|---|---:|---:|---:|---:|
| Plain | 1 | 1 | 1 | 1 |
| Road | 1 | 1 | 1 | 1 |
| Forest | 2 | **3** | 1 | 2 |
| Mountain | **Impassable** | **Impassable** | 1 | **Impassable** |
| Water | **Impassable** | **Impassable** | 1 | **Impassable** |
| Sand | 2 | 2 | 1 | **3** |
| Swamp | 3 | 3 | 1 | **4** |
| Stairs | 1 | 2 | 1 | 1 |
| Wall | **Impassable** | **Impassable** | **Impassable** | **Impassable** |

> **Note**: FLYING ignores all terrain costs (always 1) and can pass over units/obstacles (but cannot end turn on impassable).

---

## 5. Algorithms

### 5.1 A* Search
```
Open Set: Priority Queue (f = g + h)
Closed Set: HashSet<GridPos>
Heuristic: Octile Distance (8-directional)
  h = max(dx, dy) + (√2 - 1) × min(dx, dy)
  ≈ 1.414 × min + max - min = max + 0.414 × min
```

### 5.2 Movement Cost Calculation
```
cost = TerrainBaseCost[terrain][move_type]
if target_tile.has_unit && target_tile.unit != moving_unit:
    cost = IMPASSABLE
if target_tile.is_zoc && !moving_unit.has_skill("Ignore ZOC"):
    cost += ZOC_PENALTY (2)
```

### 5.3 Zone of Control (ZOC)
- Enemy units exert ZOC on 4 adjacent tiles (N/E/S/W)
- Entering ZOC costs +2 movement (unless Flying or has Ignore ZOC)
- Cannot move through ZOC if no movement left after penalty

### 5.4 Reachable Tiles (Movement Range)
ใช้ Dijkstra-like BFS จาก Start Position:
```
queue = [(start, 0)]
while queue not empty:
  (pos, cost) = pop_min(queue)
  if cost > max_mov: continue
  for neighbor in neighbors(pos):
    move_cost = get_movement_cost(neighbor, move_type)
    new_cost = cost + move_cost
    if new_cost ≤ max_mov AND new_cost < best_cost[neighbor]:
      best_cost[neighbor] = new_cost
      push(queue, (neighbor, new_cost))
```

---

## 6. Functions (Rust API)

### 6.1 `find_path(grid: &GridMap, start: GridPos, goal: GridPos, move_type: MoveType, max_mov: i32) -> Result<PathResult, PathfindingError>`
หา Path จาก start ถึง goal

### 6.2 `get_reachable(grid: &GridMap, start: GridPos, max_mov: i32, move_type: MoveType) -> ReachableResult`
คืน Tiles ทั้งหมดที่เดินถึงได้ใน Turn นี้

### 6.3 `get_attack_range(grid: &GridMap, reachable: &ReachableResult, unit: UnitData, weapon: WeaponData) -> Vec<GridPos>`
จาก Reachable tiles คำนวณ Attack Range (รวม Weapon Range)

### 6.4 `get_threat_zones(grid: &GridMap, enemies: &[UnitData]) -> Vec<GridPos>`
คืน Tiles ที่อยู่ใน ZOC ของ Enemy (สำหรับ UI แสดง Danger Zone)

### 6.5 `calculate_movement_cost(tile: &Tile, move_type: MoveType, has_zoc: bool) -> i32`
Pure function - คำนวณ Cost ของ Tile เดียว

---

## 7. Edge Cases
| Case | Handling |
|---|---|
| Start == Goal | Return empty path, cost 0 |
| Goal unreachable | Return `found=false`, empty path |
| Goal occupied by ally | Find adjacent tile |
| Goal occupied by enemy | Find adjacent tile (for attack) |
| Multiple equal-cost paths | Return first found, store alternatives |
| Unit on impassable terrain | Treat as passable for that unit only |
| Flying over enemy | Allowed, but cannot end on enemy |

---

## 8. Error Types
```rust
enum PathfindingError {
    InvalidGrid(String),
    InvalidPosition(GridPos),
    StartEqualsGoal,
    GoalUnreachable,
    ImpassableTerrain,
    MovementExceeded,
}
```

---

## 9. Testing Requirements
- [ ] A* finds optimal path on empty grid
- [ ] Terrain costs applied correctly per MoveType
- [ ] ZOC penalty applied
- [ ] Flying ignores terrain costs
- [ ] Reachable matches manual calculation
- [ ] Attack range from reachable correct
- [ ] Performance: < 1ms for 8x8 grid
- [ ] Deterministic with same inputs

---

## 10. Integration Points
- **AI System**: Calls `get_reachable` + `get_attack_range` for decision making
- **Combat System**: Uses path for movement validation
- **Data System**: Loads GridMap from Map Data (.tres/JSON)
- **Godot Layer**: Receives PathResult, animates unit movement, highlights reachable/attack tiles

---

## 11. Performance Targets
- `find_path`: < 0.5ms (8x8, 12 units)
- `get_reachable`: < 1ms (8x8, 12 units)
- `get_threat_zones`: < 0.5ms
- Memory: < 1MB for grid + cache

---

## 12. References
- PDR.md Section 3 (Architecture)
- GDD.md (Terrain System, Movement)
- CLASS_TREE.md (Class Move Types)
- SKILL_SYSTEM.md (Movement Skills: Ignore ZOC, Fly, etc.)
