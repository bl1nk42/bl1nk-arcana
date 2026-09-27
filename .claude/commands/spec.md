# /spec — Read/Create Spec Sheet

Read or create a Feature Spec Sheet in docs/SPECS/

## Usage

```
/spec read <feature_name>
/spec create <feature_name>
```

## Spec Template (docs/SPECS/<feature_name>.md)

```markdown
# Spec: <Feature Name>

**PRD Reference:** PDR.md#<section>
**Status:** Draft / Approved / Implemented
**Created:** <date>
**Author:** <name>

---

## 1. Overview
Brief description of the feature.

## 2. UI/UX
- Mockups/Layout references
- User flow

## 3. Data Structures
- Protobuf messages (proto/blink_v1.proto)
- Rust structs (blink-core)
- Godot Resources (.tres)

## 4. Functions/API
- Input/Output types
- Error cases

## 5. Edge Cases
- Boundary conditions
- Error handling

## 6. Tests
- Unit tests
- Integration tests
```

## Example

```
/spec create "Card Draw System"
```
