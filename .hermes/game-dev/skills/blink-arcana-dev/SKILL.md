---
name: blink-arcana-dev
description: "Blink Arcana Game Development Workflow — Tactical RPG + Roguelike with Godot 4 + Rust GDExtension. Use when working on blink-arcana project."
category: game-dev
---

# Blink Arcana Development Skill

## Trigger
Use when working on the Blink Arcana project (Tactical RPG + Roguelike, Godot 4 + Rust GDExtension).

## Workflow

### 1. Orientation (Every Session)
```bash
cd /data/data/com.termux/files/home/plugins/bl1nk-arcana
just --list
git status --short
cat PDR.md | head -50
```

### 2. Spec-Driven Development
- Read relevant Spec Sheet in `docs/SPECS/`
- Use `/spec` command to understand requirements
- Use `/understand` to confirm understanding
- Implement following Spec exactly

### 3. Quality Gates (Before Commit)
```bash
just fmt        # Format all code
just lint       # Lint all code
just quality    # All quality gates
just test       # Run tests
just build      # Build project
```

### 4. Common Commands
| Command | Purpose |
|---------|---------|
| `just build` | Build Rust + copy GDExtension to Godot |
| `just build-debug` | Debug build |
| `just test` | Rust unit tests |
| `just test-all` | Rust + Godot headless tests |
| `just godot` | Open Godot Editor |
| `just precommit` | Pre-commit checks |
| `just ci-check` | Simulate CI locally |
| `just clean-dev` | Clean dev cache |
| `just clean-all` | Complete cleanup |
| `just docker-build` | Build Docker image |
| `just docker-dev` | Run dev Docker container |

### 5. Project Structure
```
blink-arcana/
├── godot/              # Godot 4 project
│   ├── project.godot
│   ├── addons/blink_core/  # GDExtension binaries
│   ├── scenes/         # .tscn files
│   ├── scripts/        # .gd files
│   └── resources/      # .tres files
├── rust/               # Rust workspace
│   ├── crates/blink-core/    # Pure Rust logic
│   ├── crates/blink-proto/   # Protobuf
│   └── crates/blink-gdext/   # GDExtension binding
├── proto/blink_v1.proto      # Data schema
├── docs/SPECS/               # Feature Spec Sheets
├── .hermes/game-dev/         # Hermes profile
└── justfile                  # Task runner
```

### 6. Rust Conventions
- **No `unwrap()`/`expect()`/`panic!()`** — use `?`, `thiserror`, `Result`
- Edition 2024, MSRV 1.98.1
- `cargo clippy -- -D warnings` must pass
- `cargo fmt` must pass
- Protobuf via `prost` crate

### 7. Godot Conventions
- GDScript: Type hints, Early Return, Signals
- Autoload: Singletons only
- Scenes: Composition > Inheritance
- Naming: PascalCase (Class), snake_case (vars/funcs)

### 8. Documentation Standards
- Thai comments: Explain "Why" not "What"
- TODO must have Task ID
- Spec Sheets in `docs/SPECS/` for every feature
- Update PDR.md if architecture changes

### 9. Git Workflow
- Conventional Commits: `feat(combat): ...`, `fix(ai): ...`
- Branch: `feature/xxx` or `fix/xxx`
- PR required for main/develop

### 10. Escalation
- Spec ambiguity → Ask User (Producer/Lead)
- Design decision → Ask User
- Blocker > 30 min → Document → Ask User
