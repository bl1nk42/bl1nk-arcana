# Spec Sheet: AI System
**Feature ID:** AI-001
**Status:** Draft
**Priority:** P0 (Core)
**Owner:** Lead Developer
**Created:** 2026-09-27
**Last Updated:** 2026-09-27

---

## 1. Overview
ระบบ AI แบบ "Smart but Fun" - AI ต้องสื่อสารเจตนา (Intention) ให้ผู้เล่นรู้ล่วงหน้า มีบุคลิกภาพ (Personality) ที่แตกต่างกัน และปรับความยากแบบ Adaptive

---

## 2. Scope
### In Scope
- Intention System (แสดงเจตนาก่อนกระทำ)
- AI Personalities (Aggressive/Defensive/Support/Opportunist)
- Adaptive Difficulty (ปรับตาม Performance ผู้เล่น)
- Decision Scoring (Utility-based)
- Rewind/Debug System (สำหรับ QA)

### Out of Scope
- Combat Resolution (see Combat Spec)
- Pathfinding (see Pathfinding Spec)
- Data Loading (see Data Spec)
- Learning/AI Training (Phase 5+)

---

## 3. Data Structures

### 3.1 AIContext (protobuf)
```protobuf
message AIContext {
  UnitData acting_unit = 1;
  repeated UnitData allies = 2;
  repeated UnitData enemies = 3;
  GridMap grid = 4;
  BattleState battle_state = 5;
  AIPersonality personality = 6;
  float difficulty = 7;        // 0.0 - 1.0
  repeated Intention previous_intentions = 8;
}
```

### 3.2 AIDecision (protobuf)
```protobuf
message AIDecision {
  ActionType action = 1;        // MOVE, ATTACK, SKILL, ITEM, WAIT, END_TURN
  GridPos target_pos = 2;       // สำหรับ MOVE/ATTACK
  int32 skill_id = 3;           // สำหรับ SKILL
  int32 item_id = 4;            // สำหรับ ITEM
  GridPos move_destination = 5; // ถ้า ACTION=ATTACK/SKILL ต้องเดินไปก่อน
  repeated Intention intentions = 6; // จุดประสงค์ที่จะทำ (แสดงให้ผู้เล่นเห็น)
  string reasoning = 7;         // Debug/Logging
  float confidence = 8;         // 0.0 - 1.0
}
```

### 3.3 Intention (protobuf)
```protobuf
message Intention {
  ActionType type = 1;
  GridPos target = 2;
  int32 target_unit_id = 3;
  int32 skill_id = 4;
  ThreatLevel threat = 5;       // LOW, MEDIUM, HIGH, CRITICAL
  string description = 6;       // Human-readable for UI
}
```

### 3.4 AIPersonality (enum)
```protobuf
enum AIPersonality {
  AGGRESSIVE = 0;   // มุ่งโจมตี Deal damage สูงสุด
  DEFENSIVE = 1;    // มุ่งกันรับ เข้า Terrain ดี เลือก Action ปลอดภัย
  SUPPORT = 2;      // มุ่ง Heal/Buff เพื่อนร่วมทีม
  OPPORTUNIST = 3;  // มุ่ง Target อ่อนแอ / Flank / Backstab
  BALANCED = 4;     // ผสมผสาน (Default)
}
```

---

## 4. Decision Algorithm

### 4.1 Utility Scoring
แต่ละ Action ได้คะแนนจาก:
```
Score = BaseScore × PersonalityWeight × DifficultyMod × SituationalMod
```

### 4.2 Personality Weights
| Action | AGGRESSIVE | DEFENSIVE | SUPPORT | OPPORTUNIST | BALANCED |
|---|---|---|---|---|---|
| ATTACK | 1.5 | 0.5 | 0.3 | 1.2 | 1.0 |
| MOVE_TO_ATTACK | 1.4 | 0.6 | 0.4 | 1.3 | 1.0 |
| HEAL_ALLY | 0.2 | 0.8 | **2.0** | 0.5 | 1.0 |
| BUFF_ALLY | 0.3 | 0.9 | **1.8** | 0.4 | 1.0 |
| SEEK_COVER | 0.4 | **1.5** | 0.6 | 0.7 | 1.0 |
| FLANK | 1.2 | 0.4 | 0.2 | **1.6** | 1.0 |
| RETREAT | 0.3 | 1.3 | 0.8 | 0.6 | 1.0 |

### 4.3 Difficulty Modifier
- **Easy (0.0-0.3)**: -20% score for optimal actions, +10% for suboptimal
- **Normal (0.4-0.6)**: No modifier
- **Hard (0.7-1.0)**: +20% score for optimal actions, -10% for suboptimal

### 4.4 Intention Generation
หลังเลือก Action แล้ว สร้าง Intention 2-3 อันดับแรก ให้ UI แสดง:
1. Primary Intention (Action ที่เลือก)
2. Secondary Intention (Backup plan)
3. Threat Intention (Enemy ที่อันตรายที่สุด)

---

## 5. Functions (Rust API)

### 5.1 `decide_action(ctx: AIContext) -> Result<AIDecision, AIError>`
Main entry point - คืน Action + Intention list

### 5.2 `generate_intentions(ctx: AIContext, top_n: usize) -> Vec<Intention>`
สร้าง Intention list สำหรับ UI (เรียกแยกจาก decide_action ได้)

### 5.3 `evaluate_threats(ctx: AIContext) -> Vec<ThreatAssessment>`
ประเมิน Enemy แต่ละตัว: Damage Potential, Reachability, Priority

### 5.4 `simulate_outcome(ctx: AIContext, action: Action) -> SimulatedResult`
รัน Combat Simulation แบบหัวใจ (headless) เพื่อประเมินผลลัพธ์

### 5.5 `adjust_difficulty(player_perf: PlayerPerformance) -> f32`
Adaptive Difficulty: วัด Win Rate, Turn Count, HP Lost → ปรับ difficulty 0.0-1.0

---

## 6. Adaptive Difficulty

### 6.1 Metrics Tracked
```rust
struct PlayerPerformance {
    win_rate: f32,           // Last 10 battles
    avg_turns: f32,          // Turn efficiency
    avg_hp_lost_pct: f32,    // Damage taken
    retreat_count: u32,      // จำนวนครั้งที่หนี
    perfect_wins: u32,       // Win without unit death
}
```

### 6.2 Adjustment Rules
| Condition | Difficulty Change |
|---|---|
| Win Rate > 80% | +0.1 |
| Win Rate < 40% | -0.1 |
| Avg HP Lost > 50% | -0.05 |
| Perfect Win Streak ≥ 3 | +0.15 |
| Retreat > 2 in row | -0.15 |
| Clamp | 0.0 ≤ difficulty ≤ 1.0 |

---

## 7. Rewind/Debug System
- บันทึก AIContext + AIDecision ทุก Turn
- รองรับ `rewind(turn: u32)` → replay จาก Turn นั้น
- Export JSON สำหรับ QA Bug Report

---

## 8. Error Types
```rust
enum AIError {
    NoValidAction,
    InvalidContext(String),
    SimulationFailed(String),
    PersonalityNotFound(AIPersonality),
}
```

---

## 9. Testing Requirements
- [ ] Unit tests for each personality weight
- [ ] Deterministic decisions with fixed seed
- [ ] Intention generation matches chosen action
- [ ] Adaptive difficulty converges
- [ ] No action returns invalid target
- [ ] Performance: < 5ms per decision (8x8 grid, 12 units)

---

## 10. Integration Points
- **Combat System**: Calls `simulate_outcome` → uses `resolve_combat`
- **Pathfinding**: Uses `get_reachable` for movement options
- **Data System**: Loads Personality data, Skill data
- **Godot Layer**: Receives AIDecision + Intentions, shows Intention UI, executes Action

---

## 11. References
- PDR.md Section 2.5 (Smart AI System)
- GDD.md (Intention System, AI Personality, Adaptive Difficulty, Rewind System)
- CLASS_TREE.md (Class AI Tendencies)
- SKILL_SYSTEM.md (AI Skill Usage Priority)
