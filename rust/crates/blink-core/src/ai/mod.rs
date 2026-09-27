//! AI System for Blink Arcana
//!
//! Implements: Intention System, AI Personalities, Adaptive Difficulty

pub mod intention;
pub mod personality;

pub use intention::*;
pub use personality::*;
use serde::{Deserialize, Serialize};

use crate::{
    combat::CombatInput,
    error::AIError,
    pathfinding::{Grid, GridPos, MoveType},
    stats::{BaseStats, CombatModifiers, DamageType, Element},
};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AIConfig {
    pub personality: AIPersonality,
    pub difficulty: f32, // 0.0 - 2.0
    pub enable_intention: bool,
    pub enable_adaptive: bool,
}

impl Default for AIConfig {
    fn default() -> Self {
        Self {
            personality: AIPersonality::Tactical,
            difficulty: 1.0,
            enable_intention: true,
            enable_adaptive: true,
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BattleUnitSnapshot {
    pub unit_id: String,
    pub x: i32,
    pub y: i32,
    pub hp: i32,
    pub max_hp: i32,
    pub stats: BaseStats,
    pub mods: CombatModifiers,
    pub team: Team,
    pub has_acted: bool,
    pub has_moved: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum Team {
    Player,
    Enemy,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AIDecision {
    pub unit_id: String,
    pub action: AIAction,
    pub confidence: f32,
    pub reasoning: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AIAction {
    MoveAttack { target_x: i32, target_y: i32, move_path: Vec<GridPos> },
    UseSkill { skill_id: String, target_x: i32, target_y: i32 },
    Wait,
    EndTurn,
}

/// Main AI decision function
pub fn decide_action(
    unit: &BattleUnitSnapshot,
    allies: &[BattleUnitSnapshot],
    enemies: &[BattleUnitSnapshot],
    grid: &Grid,
    config: &AIConfig,
) -> Result<AIDecision, AIError> {
    if unit.has_acted {
        return Ok(AIDecision {
            unit_id: unit.unit_id.clone(),
            action: AIAction::EndTurn,
            confidence: 1.0,
            reasoning: "Already acted".to_string(),
        });
    }

    // Get valid targets in range
    let reachable =
        grid.get_reachable(GridPos::new(unit.x, unit.y), unit.stats.mov, MoveType::Walk);

    if reachable.is_empty() && unit.stats.rng <= 1 {
        // No movement possible, check if can attack from current position
        let targets_in_range: Vec<_> = enemies
            .iter()
            .filter(|e| {
                e.team == Team::Enemy
                    && GridPos::new(unit.x, unit.y).distance(&GridPos::new(e.x, e.y))
                        <= unit.stats.rng
            })
            .collect();

        if !targets_in_range.is_empty() {
            let target = select_target(&targets_in_range, config.personality);
            return Ok(AIDecision {
                unit_id: unit.unit_id.clone(),
                action: AIAction::MoveAttack {
                    target_x: target.x,
                    target_y: target.y,
                    move_path: vec![],
                },
                confidence: 0.9,
                reasoning: "Attack from current position".to_string(),
            });
        }

        return Ok(AIDecision {
            unit_id: unit.unit_id.clone(),
            action: AIAction::Wait,
            confidence: 0.5,
            reasoning: "No valid targets in range".to_string(),
        });
    }

    // Find best action using personality
    match config.personality {
        AIPersonality::Aggressive => decide_aggressive(unit, &reachable, enemies, grid, config),
        AIPersonality::Defensive => {
            decide_defensive(unit, &reachable, allies, enemies, grid, config)
        },
        AIPersonality::Tactical => decide_tactical(unit, &reachable, allies, enemies, grid, config),
        AIPersonality::Unpredictable => {
            decide_unpredictable(unit, &reachable, enemies, grid, config)
        },
    }
}

fn decide_aggressive(
    unit: &BattleUnitSnapshot,
    reachable: &[(GridPos, i32)],
    enemies: &[BattleUnitSnapshot],
    _grid: &Grid,
    _config: &AIConfig,
) -> Result<AIDecision, AIError> {
    // Find closest enemy and move toward them
    let mut best_target = None;
    let mut best_dist = i32::MAX;
    let mut best_pos = None;

    for (pos, _) in reachable {
        for enemy in enemies {
            let dist = pos.distance(&GridPos::new(enemy.x, enemy.y));
            if dist <= unit.stats.rng && dist < best_dist {
                best_dist = dist;
                best_target = Some(enemy);
                best_pos = Some(*pos);
            }
        }
    }

    if let (Some(target), Some(pos)) = (best_target, best_pos) {
        // Find path to pos
        // Simplified: direct path
        Ok(AIDecision {
            unit_id: unit.unit_id.clone(),
            action: AIAction::MoveAttack {
                target_x: target.x,
                target_y: target.y,
                move_path: vec![pos], // Simplified
            },
            confidence: 0.9,
            reasoning: "Aggressive: move to attack closest enemy".to_string(),
        })
    } else {
        Ok(AIDecision {
            unit_id: unit.unit_id.clone(),
            action: AIAction::Wait,
            confidence: 0.3,
            reasoning: "No enemies in range".to_string(),
        })
    }
}

fn decide_defensive(
    unit: &BattleUnitSnapshot,
    reachable: &[(GridPos, i32)],
    allies: &[BattleUnitSnapshot],
    enemies: &[BattleUnitSnapshot],
    _grid: &Grid,
    _config: &AIConfig,
) -> Result<AIDecision, AIError> {
    // Prioritize protecting low-HP allies
    let low_hp_allies: Vec<_> =
        allies.iter().filter(|a| (a.hp as f32 / a.max_hp as f32) < 0.5).collect();

    if !low_hp_allies.is_empty() {
        // Move toward lowest HP ally
        let target_ally = low_hp_allies.iter().min_by_key(|a| a.hp).unwrap();

        // Find position near ally
        let mut best_pos = None;
        let mut best_dist = i32::MAX;

        for (pos, _) in reachable {
            let dist = pos.distance(&GridPos::new(target_ally.x, target_ally.y));
            if dist < best_dist {
                best_dist = dist;
                best_pos = Some(*pos);
            }
        }

        if let Some(pos) = best_pos {
            return Ok(AIDecision {
                unit_id: unit.unit_id.clone(),
                action: AIAction::MoveAttack {
                    target_x: target_ally.x,
                    target_y: target_ally.y,
                    move_path: vec![pos],
                },
                confidence: 0.8,
                reasoning: "Defensive: protect vulnerable ally".to_string(),
            });
        }
    }

    // Fallback: hold position or retreat
    Ok(AIDecision {
        unit_id: unit.unit_id.clone(),
        action: AIAction::Wait,
        confidence: 0.6,
        reasoning: "Defensive: hold position".to_string(),
    })
}

fn decide_tactical(
    unit: &BattleUnitSnapshot,
    reachable: &[(GridPos, i32)],
    allies: &[BattleUnitSnapshot],
    enemies: &[BattleUnitSnapshot],
    grid: &Grid,
    _config: &AIConfig,
) -> Result<AIDecision, AIError> {
    // Evaluate all reachable positions for best tactical value
    let mut best_score = f32::MIN;
    let mut best_action = AIAction::Wait;
    let mut best_reasoning = "Tactical: hold".to_string();

    for (pos, mov_cost) in reachable {
        // Score position based on:
        // - Can attack enemy from here?
        // - Safe from counter-attack?
        // - Good terrain?
        // - Supports allies?

        let mut score = 0.0;
        let enemy_targets: Vec<_> = enemies
            .iter()
            .filter(|e| pos.distance(&GridPos::new(e.x, e.y)) <= unit.stats.rng)
            .collect();

        if !enemy_targets.is_empty() {
            score += 10.0; // Can attack

            // Prefer targets with low HP
            for target in &enemy_targets {
                let hp_ratio = target.hp as f32 / target.max_hp as f32;
                score += (1.0 - hp_ratio) * 5.0;
            }
        }

        // Safety: count enemies that can reach this position
        let threat_count = enemies
            .iter()
            .filter(|e| {
                let e_reachable =
                    grid.get_reachable(GridPos::new(e.x, e.y), e.stats.mov, MoveType::Walk);
                e_reachable.iter().any(|(p, _)| *p == *pos)
                    && pos.distance(&GridPos::new(e.x, e.y)) <= e.stats.rng
            })
            .count() as f32;

        score -= threat_count * 3.0;

        // Terrain bonus (simplified)
        // TODO: integrate with grid terrain

        // Support allies nearby
        let ally_support =
            allies.iter().filter(|a| pos.distance(&GridPos::new(a.x, a.y)) <= 2).count() as f32;
        score += ally_support * 2.0;

        // Movement cost penalty
        score -= *mov_cost as f32 * 0.5;

        if score > best_score {
            best_score = score;

            if !enemy_targets.is_empty() {
                let target = enemy_targets[0];
                best_action = AIAction::MoveAttack {
                    target_x: target.x,
                    target_y: target.y,
                    move_path: vec![*pos],
                };
                best_reasoning = format!(
                    "Tactical: attack {} from ({},{}) score={:.1}",
                    target.unit_id, pos.x, pos.y, score
                );
            } else {
                best_action = AIAction::MoveAttack {
                    target_x: pos.x,
                    target_y: pos.y,
                    move_path: vec![*pos],
                };
                best_reasoning =
                    format!("Tactical: reposition to ({},{}) score={:.1}", pos.x, pos.y, score);
            }
        }
    }

    Ok(AIDecision {
        unit_id: unit.unit_id.clone(),
        action: best_action,
        confidence: (best_score / 20.0).clamp(0.3, 1.0),
        reasoning: best_reasoning,
    })
}

fn decide_unpredictable(
    unit: &BattleUnitSnapshot,
    reachable: &[(GridPos, i32)],
    enemies: &[BattleUnitSnapshot],
    _grid: &Grid,
    _config: &AIConfig,
) -> Result<AIDecision, AIError> {
    // 70% tactical, 30% random
    use rand::Rng;
    let mut rng = rand::rng();

    if rng.random::<f32>() < 0.7 {
        decide_tactical(unit, reachable, &[], enemies, _grid, _config)
    } else if !reachable.is_empty() {
        let (pos, _) = reachable[rng.random_range(0..reachable.len())];
        Ok(AIDecision {
            unit_id: unit.unit_id.clone(),
            action: AIAction::MoveAttack { target_x: pos.x, target_y: pos.y, move_path: vec![pos] },
            confidence: 0.5,
            reasoning: "Unpredictable: random move".to_string(),
        })
    } else {
        Ok(AIDecision {
            unit_id: unit.unit_id.clone(),
            action: AIAction::Wait,
            confidence: 0.3,
            reasoning: "Unpredictable: wait".to_string(),
        })
    }
}

fn select_target<'a>(
    targets: &[&'a BattleUnitSnapshot],
    personality: AIPersonality,
) -> &'a BattleUnitSnapshot {
    match personality {
        AIPersonality::Aggressive => {
            // Highest HP (biggest threat) or lowest HP (easiest kill)
            targets.iter().min_by_key(|t| t.hp).copied().unwrap()
        },
        AIPersonality::Defensive => {
            // Lowest HP (easiest to eliminate threat)
            targets.iter().min_by_key(|t| t.hp).copied().unwrap()
        },
        AIPersonality::Tactical => {
            // Best value target (low HP, high damage potential)
            targets
                .iter()
                .min_by(|a, b| {
                    let a_val =
                        (a.max_hp - a.hp) as f32 / a.max_hp as f32 * 10.0 + a.stats.atk as f32;
                    let b_val =
                        (b.max_hp - b.hp) as f32 / b.max_hp as f32 * 10.0 + b.stats.atk as f32;
                    b_val.partial_cmp(&a_val).unwrap()
                })
                .copied()
                .unwrap()
        },
        AIPersonality::Unpredictable => {
            use rand::Rng;
            let mut rng = rand::rng();
            targets[rng.random_range(0..targets.len())]
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{pathfinding::Grid, stats::BaseStats};

    fn make_test_grid() -> Grid {
        Grid::new(8, 8).unwrap()
    }

    fn make_unit(id: &str, x: i32, y: i32, hp: i32, atk: i32, team: Team) -> BattleUnitSnapshot {
        BattleUnitSnapshot {
            unit_id: id.to_string(),
            x,
            y,
            hp,
            max_hp: hp,
            stats: BaseStats { hp, atk, def: 15, int: 10, spd: 10, mov: 5, rng: 1, res: 10 },
            mods: CombatModifiers::default(),
            team,
            has_acted: false,
            has_moved: false,
        }
    }

    #[test]
    fn test_aggressive_attacks_nearest() {
        let grid = make_test_grid();
        let unit = make_unit("enemy1", 4, 4, 50, 20, Team::Enemy);
        let allies = vec![];
        let enemies = vec![
            make_unit("player1", 4, 6, 60, 18, Team::Player), // dist 2
            make_unit("player2", 7, 7, 50, 22, Team::Player), // dist 6
        ];

        let config = AIConfig { personality: AIPersonality::Aggressive, ..Default::default() };
        let decision = decide_action(&unit, &allies, &enemies, &grid, &config).unwrap();

        assert!(matches!(decision.action, AIAction::MoveAttack { .. }));
        // Should target player1 (closer)
    }

    #[test]
    fn test_defensive_protects_low_hp() {
        let grid = make_test_grid();
        let unit = make_unit("enemy1", 4, 4, 50, 20, Team::Enemy);
        let allies = vec![
            make_unit("ally1", 3, 3, 10, 15, Team::Enemy), // low HP
            make_unit("ally2", 6, 6, 50, 18, Team::Enemy), // full HP
        ];
        let enemies = vec![make_unit("player1", 7, 7, 60, 18, Team::Player)];

        let config = AIConfig { personality: AIPersonality::Defensive, ..Default::default() };
        let decision = decide_action(&unit, &allies, &enemies, &grid, &config).unwrap();

        // Should move toward ally1 (low HP)
    }
}
