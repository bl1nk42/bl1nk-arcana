# Spec Sheet: {{FEATURE_NAME}}
**Feature ID:** {{FEATURE_ID}}-001
**Status:** Draft
**Priority:** P0 (Core)
**Owner:** Lead Developer
**Created:** {{DATE}}
**Last Updated:** {{DATE}}

---

## 1. Overview
Brief description of the AI feature.

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

### 3.1 AIContext / AIDecision (protobuf)
```protobuf
message AIContext {
  // Define context structure
}

message AIDecision {
  // Define decision structure
}
```

---

## 4. Algorithms
Decision algorithm details.

---

## 5. Functions (Rust API)

### 5.1 `decide_action(ctx: AIContext) -> Result<AIDecision, AIError>`
Main decision function.

---

## 6. Edge Cases
| Case | Handling |
|---|---|

---

## 7. Error Types
```rust
enum AIError {
    ErrorVariant(String),
}
```

---

## 8. Testing Requirements
- [ ] Unit test
- [ ] Deterministic test with fixed seed
- [ ] Performance test (< 5ms)

---

## 9. Integration Points
- **Combat System**: Simulation
- **Pathfinding**: Movement options

---

## 10. References
- PDR.md Section 2.5
- GDD.md Smart AI System
