# Rust Rules for Blink Arcana

## Forbidden Patterns

```rust
// ❌ NEVER use unwrap() in production code
let x = option.unwrap();
let x = result.unwrap();

// ✅ Use ? operator
let x = option.ok_or(Error::Missing)?;
let x = result?;

// ✅ Use unwrap_or / unwrap_or_else for defaults
let x = option.unwrap_or(default);
let x = option.unwrap_or_else(|| compute_default());

// ✅ Use if let / match for pattern matching
if let Some(x) = option { ... }
match result {
    Ok(x) => ...,
    Err(e) => return Err(e.into()),
}
```

## Error Handling

```rust
// Use thiserror for error types
use thiserror::Error;

#[derive(Error, Debug)]
pub enum CombatError {
    #[error("Invalid attacker: {0}")]
    InvalidAttacker(String),
    #[error("Calculation error: {0}")]
    Calculation(#[from] std::num::TryFromIntError),
}

// Return Result<T, Error> from fallible functions
pub fn calculate_damage(...) -> Result<i32, CombatError> { ... }

// Propagate with ?
let dmg = calculate_damage(...)?;
```

## Protobuf Integration

```rust
// Protobuf messages generated in blink-proto
use blink_proto::{Unit, Skill, Weapon, BattleState, CombatResult};

// Convert between Godot (via GDExtension) ↔ Protobuf ↔ Core
// blink-gdext handles: Godot Variant/Dictionary ↔ Protobuf ↔ Rust structs

// In blink-gdext:
fn godot_dict_to_proto_unit(dict: Dictionary) -> proto::Unit { ... }
fn proto_unit_to_godot_dict(unit: &proto::Unit) -> Dictionary { ... }
```

## Builder Pattern for Complex Structs

```rust
// Instead of large struct constructors
pub struct UnitBuilder {
    base_stats: BaseStats,
    skills: Vec<String>,
    equipment: Equipment,
}

impl UnitBuilder {
    pub fn new(class: &ClassData) -> Self { ... }
    pub fn with_level(mut self, level: u8) -> Self { ... }
    pub fn with_skills(mut self, skills: Vec<String>) -> Self { ... }
    pub fn build(self) -> Unit { ... }
}

// Usage:
let unit = UnitBuilder::new(&myrmidon_class)
    .with_level(5)
    .with_skills(vec!["sword_e".into(), "dodge_5".into()])
    .build();
```

## Async & Concurrency

- Combat/AI/Pathfinding are **sync** — called from Godot main thread
- Use `rayon` for parallel computation if needed (e.g., batch pathfinding)
- No `tokio` — GDExtension runs in Godot's thread

## Testing

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_physical_damage() {
        let atk = BaseStats { atk: 30, def: 15, ..Default::default() };
        let def = BaseStats { def: 22, ..Default::default() };
        let dmg = calculate_damage(atk, def, DamageType::Physical, ...).unwrap();
        assert_eq!(dmg, 19);
    }
}
```

## Cargo Features

```toml
# In Cargo.toml
[features]
default = ["std"]
std = ["thiserror/std", "prost/std"]
```

## Clippy Compliance

```bash
# Must pass without warnings
cargo clippy --all-targets --all-features -- -D warnings

# Common fixes:
# - Replace unwrap() with ? or unwrap_or()
# - Use `..Default::default()` for struct updates
# - Prefer `map`/`and_then` over match for Option/Result
```
