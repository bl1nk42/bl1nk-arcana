# Spec Sheet: {{FEATURE_NAME}}
**Feature ID:** {{FEATURE_ID}}-001
**Status:** Draft
**Priority:** P0 (Core)
**Owner:** Lead Developer
**Created:** {{DATE}}
**Last Updated:** {{DATE}}

---

## 1. Overview
Brief description of the data system feature.

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

### 3.1 Data Types (protobuf)
```protobuf
message DataType {
  // Define data structure
}
```

---

## 4. File Formats
JSON / .tres format specifications.

---

## 5. Functions (Rust API)

### 5.1 `load_data(path: &str) -> Result<(), DataError>`
Load data from directory.

---

## 6. Validation Rules
| Rule | Severity |
|---|---|

---

## 7. Error Types
```rust
enum DataError {
    ErrorVariant(String),
}
```

---

## 8. Testing Requirements
- [ ] Load test
- [ ] Validation test
- [ ] Round-trip test

---

## 9. Integration Points
- **All Systems**: Data queries

---

## 10. References
- PDR.md Section 3.3
- CHARACTER_TEMPLATE.md
