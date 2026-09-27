# Spec Sheet: {{FEATURE_NAME}}
**Feature ID:** {{FEATURE_ID}}-001
**Status:** Draft
**Priority:** P0 (Core)
**Owner:** Lead Developer
**Created:** {{DATE}}
**Last Updated:** {{DATE}}

---

## 1. Overview
Brief description of the combat feature.

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

### 3.1 Input/Output (protobuf)
```protobuf
message FeatureInput {
  // Define input structure
}

message FeatureOutput {
  // Define output structure
}
```

---

## 4. Algorithms / Formulas
Detailed algorithms and formulas.

---

## 5. Functions (Rust API)

### 5.1 `function_name(input: InputType) -> Result<OutputType, ErrorType>`
Description of function.

---

## 6. Edge Cases
| Case | Handling |
|---|---|
| Case 1 | Handling |

---

## 7. Error Types
```rust
enum FeatureError {
    ErrorVariant(String),
}
```

---

## 8. Testing Requirements
- [ ] Unit test for function
- [ ] Edge case test
- [ ] Integration test

---

## 9. Integration Points
- **System A**: How it integrates
- **System B**: How it integrates

---

## 10. References
- PDR.md Section X
- GDD.md Section Y
