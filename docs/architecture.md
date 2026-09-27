# Architecture Overview — Blink Arcana

> โครงสร้างรายละเอียดดูที่ [[PDR.md#3-สถาปัตยกรรมเทคนิค]]

---

## Hybrid Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Godot 4 (GDScript)                   │
│  UI Layer, Scene Management, Animation, Input, Display     │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Scenes (.tscn)  │ Scripts (.gd)  │ Resources (.tres) │   │
│  └─────────────────────────────────────────────────────┘   │
└───────────────────────────┬─────────────────────────────────┘
                            │ GDExtension API
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      Rust (GDExtension)                     │
│  Core Engine: Combat, AI, Pathfinding, Stats, Data         │
│  ┌──────────────┐ ┌──────────────┐ ┌────────────────────┐  │
│  │ blink-core   │ │ blink-proto  │ │ blink-gdext        │  │
│  │ (pure logic) │ │ (protobuf)   │ │ (thin binding)     │  │
│  └──────────────┘ └──────────────┘ └────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                      proto/blink_v1.proto                   │
│  Shared Schema: Unit, Skill, Item, Tile, Map,              │
│  BattleState, CombatResult, AIDecision, ...                │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Flow

1. **Godot** สร้าง Battle Scene → โหลด Unit/Map data จาก `.tres`
2. **GDExtension** แปลง Godot types → Protobuf messages
3. **blink-core** ประมวลผล Combat/AI/Pathfinding (pure Rust)
4. **GDExtension** แปลง Result กลับเป็น Godot types
5. **Godot** อัปเดต UI/Animation ตาม Result

---

## Crate Responsibilities

| Crate | Responsibility | Depends on |
| --- | --- | --- |
| `blink-core` | Combat, AI, Pathfinding, Stats, Error | `thiserror`, `prost-types` |
| `blink-proto` | Protobuf build.rs, message types | `prost`, `prost-build` |
| `blink-gdext` | Godot ↔ Protobuf ↔ Core conversion | `gdext`, `blink-core`, `blink-proto` |

---

## Build Pipeline

```bash
just build
# 1. cargo build --release -p blink-core -p blink-proto -p blink-gdext
# 2. copy libblink_gdext.so → godot/addons/blink_core/bin/
# 3. Godot loads .gdextension automatically
```

---

## Key Design Decisions

| Decision | Rationale |
| --- | --- |
| Separate `blink-core` from Godot | Testable without Godot, no circular deps |
| Protobuf as data layer | Stable schema, language-agnostic, versioned |
| Thin `blink-gdext` binding | Single responsibility: conversion only |
| `rust-toolchain.toml` pinned | Reproducible builds across team/CI/Docker |
| `just` as task runner | Cross-platform, simple, composable |
