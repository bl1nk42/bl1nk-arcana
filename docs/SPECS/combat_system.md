# Spec Sheet: Combat System
**Feature ID:** COMBAT-001
**Status:** Draft
**Priority:** P0 (Core)
**Owner:** Lead Developer
**Created:** 2026-09-27
**Last Updated:** 2026-09-27

---

## 1. Overview
ระบบต่อสู้แบบ Turn-based Tactical บน Grid 8x8 ใช้สูตร Damage แบบ Fire Emblem พร้อม Element System 5 ธาตุ + Neutral

---

## 2. Scope
### In Scope
- Physical/Magic Damage Calculation
- Element Effectiveness (Weak/Resist/Immune)
- Hit/Miss/Critical/Block Mechanics
- Healing Formula
- Combat Log Generation
- Status Effect Application (Dot, Buff, Debuff)

### Out of Scope
- AI Decision Making (see AI Spec)
- Pathfinding/Movement (see Pathfinding Spec)
- Data Loading (see Data Spec)
- UI/Animation (Godot layer)

---

## 3. Data Structures

### 3.1 CombatInput (protobuf)
```protobuf
message CombatInput {
  UnitStats attacker = 1;
  UnitStats defender = 2;
  WeaponData weapon = 3;
  int32 terrain_bonus = 4;        // จาก Tile
  repeated StatusEffect attacker_buffs = 5;
  repeated StatusEffect defender_buffs = 6;
  int32 support_bonus = 7;        // Pair-up bonus
  bool is_counter = 8;
}
```

### 3.2 CombatResult (protobuf)
```protobuf
message CombatResult {
  int32 damage = 1;
  int32 heal = 2;
  bool is_critical = 3;
  bool is_miss = 4;
  bool is_blocked = 5;
  int32 defender_remaining_hp = 6;
  repeated string combat_log = 7;
  repeated StatusEffect applied_effects = 8;
}
```

### 3.3 UnitStats (protobuf)
```protobuf
message UnitStats {
  int32 hp = 1;
  int32 max_hp = 2;
  int32 atk = 3;
  int32 def = 4;
  int32 int = 5;      // Intelligence
  int32 spd = 6;
  int32 mov = 7;
  int32 rng = 8;
  int32 res = 9;
  Element element = 10;
  ClassType class_type = 11;
  int32 level = 12;
}
```

---

## 4. Formulas (Authoritative Source)

### 4.1 Physical Damage
```
Base Damage = ATK - (DEF / 2)
Final Damage = Base Damage × Element Multiplier
Min Damage = 1 (if hit)
```

### 4.2 Magic Damage
```
Base Damage = INT - (RES / 2)
Final Damage = Base Damage × Element Multiplier
Min Damage = 1 (if hit)
```

### 4.3 Hit Chance
```
AVO = (SPD × 2) + Terrain Bonus + Support Bonus
Hit Chance = 100 - AVO
Clamp: 5% ≤ Hit Chance ≤ 95%
```

### 4.4 Critical Rate
```
Base Crit = Weapon Crit + (SPD / 2) + Skill Bonus
Crit Roll: 1d100 ≤ Crit Rate → Critical Hit
Critical Multiplier: ×3 (Physical), ×2 (Magic)
```

### 4.5 Healing
```
Heal Amount = INT × 0.5
Clamp: Heal ≤ Target Max HP - Current HP
```

### 4.6 Element Multipliers (จาก GDD.md)
| Attacker \ Defender | Fire | Water | Wind | Earth | Light | Dark | Neutral |
|---|---|---|---|---|---|---|---|
| **Fire** | 1.0 | **0.5** | **2.0** | 1.0 | 1.0 | 1.0 | 1.0 |
| **Water** | **2.0** | 1.0 | **0.5** | 1.0 | 1.0 | 1.0 | 1.0 |
| **Wind** | 1.0 | **2.0** | 1.0 | **0.5** | 1.0 | 1.0 | 1.0 |
| **Earth** | 1.0 | 1.0 | **2.0** | 1.0 | 1.0 | 1.0 | 1.0 |
| **Light** | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | **2.0** | 1.0 |
| **Dark** | 1.0 | 1.0 | 1.0 | 1.0 | **2.0** | 1.0 | 1.0 |
| **Neutral** | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 | 1.0 |

---

## 5. Functions (Rust API)

### 5.1 `resolve_combat(input: CombatInput) -> Result<CombatResult, CombatError>`
Main entry point - resolves one combat exchange.

### 5.2 `calculate_damage(attacker: UnitStats, defender: UnitStats, weapon: WeaponData, terrain: i32) -> i32`
Pure damage calculation (no RNG).

### 5.3 `calculate_hit_chance(attacker: UnitStats, defender: UnitStats, terrain: i32, support: i32) -> i32`
Returns 5-95.

### 5.4 `calculate_heal(healer: UnitStats, target: UnitStats) -> i32`
Pure heal calculation.

### 5.5 `calculate_crit_rate(attacker: UnitStats, weapon: WeaponData, skills: Vec<Skill>) -> i32`
Returns 0-100.

---

## 6. Edge Cases
| Case | Handling |
|---|---|
| DEF ≥ ATK×2 | Damage = 1 (minimum) |
| RES ≥ INT×2 | Magic Damage = 1 (minimum) |
| AVO ≥ 95 | Hit Chance = 5% |
| AVO ≤ 5 | Hit Chance = 95% |
| Heal > Missing HP | Clamp to Missing HP |
| Counter Attack | Uses defender's stats as attacker |
| Status Immunity | Skip application, log "Immune" |

---

## 7. Error Types
```rust
enum CombatError {
    InvalidInput(String),
    UnitNotFound(String),
    WeaponNotFound(String),
    CalculationOverflow,
}
```

---

## 8. Testing Requirements
- [ ] Unit tests for each formula (100% coverage)
- [ ] Property-based tests for damage bounds
- [ ] Element effectiveness table verification
- [ ] Critical hit distribution (statistical)
- [ ] Healing clamp verification
- [ ] Counter attack symmetry

---

## 9. Integration Points
- **AI System**: Calls `resolve_combat` for simulation
- **Pathfinding**: Uses `calculate_hit_chance` for threat assessment
- **Data System**: Loads WeaponData, UnitStats from .tres/JSON
- **Godot Layer**: Receives CombatResult via GDExtension, plays animations

---

## 10. References
- PDR.md Section 2.4 (Combat Formula)
- GDD.md (Element Table, Weapon System)
- CLASS_TREE.md (Class Stat Growth)
- WEAPON_SYSTEM.md (Weapon Rank, Crit, Ability)
- SKILL_SYSTEM.md (Combat Skills, Passive Effects)
