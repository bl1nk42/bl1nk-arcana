# Blink Arcana

Tactical RPG + Roguelike · Godot 4 + Rust (GDExtension)

---

## Overview

**Blink Arcana** is a tactical RPG with roguelike elements, inspired by Fire Emblem, Slay the Spire, Into the Breach, and Final Fantasy Record Keeper.

- **Engine:** Godot 4.x (GDScript for UI/Scene) + Rust 1.98.1 (GDExtension for Core Logic)
- **Platform:** PC (Windows/macOS/Linux)
- **Mode:** Single-player

---

## Core Loop

1. **EXPLORE** — Choose path on map (Slay the Spire style)
2. **BATTLE** — Tactical turn-based combat on grid (Fire Emblem style)
3. **UPGRADE** — Upgrade units after victory
4. **LOOP** — Start new run or end (Roguelike)

---

## Documentation

| Document | Description |
| --- | --- |
| [PDR.md](PDR.md) | Foundation Document (Source of Truth) |
| [GDD.md](GDD.md) | Game Design — Unit/Stats/Element/Terrain/Combat Formula/Smart AI |
| [CLASS_TREE.md](CLASS_TREE.md) | Class Tree + Promotion Rules + Skill Unlock Table |
| [SKILL_SYSTEM.md](SKILL_SYSTEM.md) | Skill Types, CP, Bank, Guard Rule, Aura, Pool |
| [WEAPON_SYSTEM.md](WEAPON_SYSTEM.md) | Weapon Type, Rank, Ability, Durability |
| [TASK_PLAN.md](TASK_PLAN.md) | Task Tracker — Phase 1-5 |
| [CHARACTER_TEMPLATE.md](CHARACTER_TEMPLATE.md) | Character Sheet Template |
| [docs/GLOSSARY.md](docs/GLOSSARY.md) | Glossary + Banned Terms |
| [docs/architecture.md](docs/architecture.md) | Architecture Overview |
| [docs/CHANGELOG.md](docs/CHANGELOG.md) | Version History |

---

## Quick Start

```bash
# Install dev tools (first time)
just setup

# Build everything
just build

# Run tests
just test-all

# Open Godot Editor
just godot

# Format & lint
just fmt && just lint
```

---

## Repository Structure

```
blink-arcana/
├── godot/           # Godot 4 project
├── rust/            # Rust workspace (blink-core, blink-proto, blink-gdext)
├── proto/           # Protobuf schema (blink_v1.proto)
├── docs/            # Documentation
├── .claude/         # Slash commands & rules
├── .github/workflows/
├── docker/
└── *.md             # Root docs (PDR, GDD, CLASS_TREE, etc.)
```

---

## Development Phases

| Phase | Duration | Deliverable |
| --- | --- | --- |
| 1: Foundation | 1-2 weeks | Dev Environment ready |
| 2: Core Prototype | 4-6 weeks | Playable Battle |
| 3: Systems | 4-6 weeks | Class Tree (5 Lines × 3 Tiers) + Skill Pool + Element System complete |
| 4: Content & Polish | 4-6 weeks | Full game loop playable |
| 5: Smart AI & Balance | 2-4 weeks | Fun, balanced AI |
| 6: Release | 2-4 weeks | Shippable build |

---

## License

MIT License — see [LICENSE](LICENSE)
