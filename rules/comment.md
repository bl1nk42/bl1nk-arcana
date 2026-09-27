# Comment Rules for Blink Arcana

## Language

- **All comments in Thai language**
- English only for: API names, technical terms, code references

## Style: Explain WHY, not WHAT

```rust
// ❌ Bad: Explains what code does (obvious from reading)
fn calculate_damage(atk: i32, def: i32) -> i32 {
    atk - def / 2  // คำนวณดาเมจจาก ATK ลบ DEF หาร 2
}

// ✅ Good: Explains why this formula
fn calculate_damage(atk: i32, def: i32) -> i32 {
    // สูตร PDR 2.4: Physical Damage = ATK - (DEF / 2)
    // ใช้การหารแบบ integer เพื่อให้ DEF มีผลชัดเจนต่อดาเมจต่ำ
    // Cap ที่ 1 เพื่อไม่ให้ดาเมจเป็น 0 หรือติดลบ
    (atk - def / 2).max(1)
}
```

## Required Comment Types

### 1. Function/Module Documentation

```rust
//! Combat resolution using formulas from PDR.md Section 2.4
//!
//! Handles: Physical/Magic damage, Crit, Guard, Element effectiveness
//!
//! References:
//! - PDR.md: Combat Formula (Base Formula)
//! - GDD.md: Element System, Weapon Abilities
//! - SKILL_SYSTEM.md: Skill Effects, Guard Rule

/// Resolve a single combat action (attack or counter)
///
/// # Arguments
/// * `input` - CombatInput with attacker/defender stats and modifiers
///
/// # Returns
/// * `CombatResult` - Damage, crit, miss, block, remaining HP
///
/// # Errors
/// * `CombatError::InvalidAttacker` - Missing weapon or invalid stats
pub fn resolve_combat(input: CombatInput) -> Result<CombatResult, CombatError> { ... }
```

### 2. TODO Comments (Must have Task ID)

```rust
// TODO(TASK-42): Implement Element Shift skill effect
// TODO(TASK-15): Add terrain MOV penalty to pathfinding
// FIXME(TASK-8): Guard currently blocks all physical - should respect Weapon Ability "Pierce Guard"
// HACK: Temporary workaround for Godot signal timing issue
```

### 3. Complex Logic Explanation

```rust
fn decide_tactical(...) -> Result<AIDecision, AIError> {
    // Score each reachable position based on:
    // 1. Attack opportunity (can hit enemy from here?)
    // 2. Safety (enemies that can counter-attack this position)
    // 3. Terrain bonus (DEF/AVO from terrain)
    // 4. Ally support (nearby allies for aura/guard)
    // 5. Movement cost efficiency
    //
    // Weights from PersonalityWeights (see personality.rs)
    // Higher score = better tactical position
    //
    // Reference: PDR.md Section 2.5 Smart AI System
}
```

### 4. Cross-Reference Links

```rust
// See: PDR.md#24-สู่ตรการต่อส-ยง-combat-formula--base-formula
// See: GDD.md#Element-System
// See: CLASS_TREE.md#Promotion-Rules
// See: SKILL_SYSTEM.md#Guard-Rule
// See: WEAPON_SYSTEM.md#Weapon-Ability
```

## GDScript Comments

```gdscript
# สูตร PDR 2.4: Physical Damage = ATK - (DEF / 2)
# Element multiplier จาก GDD.md Element System
# Skill/Weapon bonus คำนวณแยกใน CombatModifiers

func calculate_damage(attacker: Dictionary, defender: Dictionary) -> int:
    var base_damage = attacker.atk - (defender.def / 2)
    return max(base_damage, 1)
```

## Commit Messages (Conventional Commits)

```
feat(combat): เพิ่มระบบธาตุ 5 ธาตุ
fix(battle): แก้ Damage ติดลบเมื่อ DEF > ATK
docs: อัปเดต PRD ส่วน Battle System
refactor(ai): แยก Personality ออกเป็น module แยก
test(combat): เพิ่ม test case สำหรับ Element effectiveness
```

## Banned Comment Patterns

```rust
// ❌ ไม่ต้อง comment ทุกบรรทัด
let x = 5; // กำหนด x เป็น 5

// ❌ ไม่ใช่ภาษาไทย
// This function calculates damage

// ❌ ไม่มี Task ID ใน TODO
// TODO: Fix this later
```
