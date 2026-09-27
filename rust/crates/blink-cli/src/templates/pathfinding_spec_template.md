# Spec Sheet: {{FEATURE_NAME}}
**Feature ID:** {{FEATURE_ID}}-001
**Status:** Draft
**Priority:** P0 (Core)
**Owner:** Lead Developer
**Created:** {{DATE}}
**Last Updated:** {{DATE}}

---

## 1. Overview
Brief description of the pathfinding feature.

---

## 2. Scope
### In Scope
- Item 1
- Item 2

### Out of Scope
- Item 1
- Item 2

---

## 3. Data Structures

### 3.1 GridMap / PathResult (protobuf)
```protobuf
message GridMap {
  // Define grid structure
}

message PathResult {
  // Define path result
}
```

---

## 4. Algorithms
A* / Dijkstra algorithm details.

---

## 5. Functions (Rust API)

### 5.1 `find_path(grid: &GridMap, start: GridPos, goal: GridPos, ...) -> Result<PathResult, PathfindingError>`
Main pathfinding function.

---

## 6. Edge Cases
| Case | Handling |
|---|---|

---

## 7. Error Types
```rust
enum PathfindingError {
    ErrorVariant(String),
}
```

---

## 8. Testing Requirements
- [ ] Optimal path test
- [ ] Terrain cost test
- [ ] Performance test (< 1ms)

---

## 9. Integration Points
- **AI System**: Movement options
- **Combat**: Movement validation

---

## 10. References
- PDR.md Section 3
- GDD.md Terrain System
