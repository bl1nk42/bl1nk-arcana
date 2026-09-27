//! AI Personalities for Blink Arcana
//! Aggressive, Defensive, Tactical, Unpredictable

use serde::{Deserialize, Serialize};

use crate::error::AIError;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum AIPersonality {
    Aggressive,
    Defensive,
    Tactical,
    Unpredictable,
}

impl AIPersonality {
    pub fn name(&self) -> &'static str {
        match self {
            Self::Aggressive => "Aggressive",
            Self::Defensive => "Defensive",
            Self::Tactical => "Tactical",
            Self::Unpredictable => "Unpredictable",
        }
    }

    pub fn description(&self) -> &'static str {
        match self {
            Self::Aggressive => "Attacks directly, prioritizes dealing damage",
            Self::Defensive => "Protects allies, holds position, avoids risks",
            Self::Tactical => "Plans ahead, uses terrain, flanks, manages resources",
            Self::Unpredictable => "Mixes strategies with random elements",
        }
    }

    /// Weight modifiers for decision scoring
    pub fn weights(&self) -> PersonalityWeights {
        match self {
            Self::Aggressive => PersonalityWeights {
                attack_weight: 1.5,
                defense_weight: 0.5,
                support_weight: 0.3,
                safety_weight: 0.3,
                mobility_weight: 1.0,
                risk_tolerance: 0.8,
            },
            Self::Defensive => PersonalityWeights {
                attack_weight: 0.5,
                defense_weight: 1.5,
                support_weight: 1.2,
                safety_weight: 1.5,
                mobility_weight: 0.5,
                risk_tolerance: 0.2,
            },
            Self::Tactical => PersonalityWeights {
                attack_weight: 1.0,
                defense_weight: 1.0,
                support_weight: 1.0,
                safety_weight: 1.0,
                mobility_weight: 1.0,
                risk_tolerance: 0.5,
            },
            Self::Unpredictable => PersonalityWeights {
                attack_weight: 1.0,
                defense_weight: 1.0,
                support_weight: 1.0,
                safety_weight: 1.0,
                mobility_weight: 1.0,
                risk_tolerance: 0.5,
            },
        }
    }
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct PersonalityWeights {
    pub attack_weight: f32,
    pub defense_weight: f32,
    pub support_weight: f32,
    pub safety_weight: f32,
    pub mobility_weight: f32,
    pub risk_tolerance: f32,
}

impl Default for PersonalityWeights {
    fn default() -> Self {
        Self {
            attack_weight: 1.0,
            defense_weight: 1.0,
            support_weight: 1.0,
            safety_weight: 1.0,
            mobility_weight: 1.0,
            risk_tolerance: 0.5,
        }
    }
}

/// Adaptive Difficulty System
/// Adjusts AI difficulty based on player performance
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AdaptiveDifficulty {
    pub base_difficulty: f32, // 0.5 - 2.0
    pub current_difficulty: f32,
    pub player_wins: u32,
    pub player_losses: u32,
    pub win_streak: u32,
    pub loss_streak: u32,
    pub adjustment_rate: f32, // How fast to adapt
    pub min_difficulty: f32,
    pub max_difficulty: f32,
}

impl Default for AdaptiveDifficulty {
    fn default() -> Self {
        Self {
            base_difficulty: 1.0,
            current_difficulty: 1.0,
            player_wins: 0,
            player_losses: 0,
            win_streak: 0,
            loss_streak: 0,
            adjustment_rate: 0.1,
            min_difficulty: 0.5,
            max_difficulty: 2.0,
        }
    }
}

impl AdaptiveDifficulty {
    pub fn record_win(&mut self) {
        self.player_wins += 1;
        self.win_streak += 1;
        self.loss_streak = 0;
        self.adjust_up();
    }

    pub fn record_loss(&mut self) {
        self.player_losses += 1;
        self.loss_streak += 1;
        self.win_streak = 0;
        self.adjust_down();
    }

    fn adjust_up(&mut self) {
        // Increase difficulty on win streak
        if self.win_streak >= 2 {
            self.current_difficulty =
                (self.current_difficulty + self.adjustment_rate).min(self.max_difficulty);
        }
    }

    fn adjust_down(&mut self) {
        // Decrease difficulty on loss streak
        if self.loss_streak >= 2 {
            self.current_difficulty =
                (self.current_difficulty - self.adjustment_rate).max(self.min_difficulty);
        }
    }

    pub fn get_ai_config(&self, base_personality: AIPersonality) -> crate::ai::AIConfig {
        crate::ai::AIConfig {
            personality: base_personality,
            difficulty: self.current_difficulty,
            enable_intention: true,
            enable_adaptive: true,
        }
    }

    pub fn get_difficulty_multiplier(&self) -> f32 {
        // Returns multiplier for enemy stats based on difficulty
        match self.current_difficulty {
            d if d < 0.75 => 0.85, // Easy
            d if d < 1.25 => 1.0,  // Normal
            d if d < 1.75 => 1.15, // Hard
            _ => 1.3,              // Very Hard
        }
    }
}

/// Rewind System (Into the Breach style)
/// Player can undo last turn
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RewindSystem {
    pub max_charges: u8,
    pub current_charges: u8,
    pub history: Vec<BattleSnapshot>,
    pub max_history: usize,
}

impl Default for RewindSystem {
    fn default() -> Self {
        Self { max_charges: 2, current_charges: 2, history: Vec::new(), max_history: 10 }
    }
}

impl RewindSystem {
    pub fn new(max_charges: u8) -> Self {
        Self { max_charges, current_charges: max_charges, history: Vec::new(), max_history: 10 }
    }

    pub fn can_rewind(&self) -> bool {
        self.current_charges > 0 && !self.history.is_empty()
    }

    pub fn save_snapshot(&mut self, snapshot: BattleSnapshot) {
        self.history.push(snapshot);
        if self.history.len() > self.max_history {
            self.history.remove(0);
        }
    }

    pub fn rewind(&mut self) -> Option<BattleSnapshot> {
        if self.can_rewind() {
            self.current_charges -= 1;
            self.history.pop()
        } else {
            None
        }
    }

    pub fn recharge(&mut self, amount: u8) {
        self.current_charges = (self.current_charges + amount).min(self.max_charges);
    }

    pub fn reset(&mut self) {
        self.current_charges = self.max_charges;
        self.history.clear();
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BattleSnapshot {
    pub turn: u32,
    pub player_units: Vec<UnitSnapshot>,
    pub enemy_units: Vec<UnitSnapshot>,
    pub player_gold: u32,
    pub rng_state: u64, // For deterministic replay
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UnitSnapshot {
    pub unit_id: String,
    pub x: i32,
    pub y: i32,
    pub hp: i32,
    pub max_hp: i32,
    pub has_acted: bool,
    pub has_moved: bool,
    pub status_effects: Vec<String>,
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_adaptive_difficulty_win_streak() {
        let mut ad = AdaptiveDifficulty::default();
        assert_eq!(ad.current_difficulty, 1.0);

        ad.record_win(); // win 1
        assert_eq!(ad.current_difficulty, 1.0); // no change yet
        assert_eq!(ad.win_streak, 1);

        ad.record_win(); // win 2
        assert!(ad.current_difficulty > 1.0); // increased
        assert_eq!(ad.win_streak, 2);
    }

    #[test]
    fn test_adaptive_difficulty_loss_streak() {
        let mut ad = AdaptiveDifficulty::default();
        ad.current_difficulty = 1.2;

        ad.record_loss();
        ad.record_loss();
        assert!(ad.current_difficulty < 1.2); // decreased
        assert_eq!(ad.loss_streak, 2);
    }

    #[test]
    fn test_difficulty_bounds() {
        let mut ad = AdaptiveDifficulty {
            current_difficulty: 1.9,
            max_difficulty: 2.0,
            min_difficulty: 0.5,
            ..Default::default()
        };

        // Try to exceed max
        for _ in 0..10 {
            ad.record_win();
        }
        assert_eq!(ad.current_difficulty, 2.0);

        // Try to go below min
        let mut ad2 = AdaptiveDifficulty { current_difficulty: 0.6, ..Default::default() };
        for _ in 0..10 {
            ad2.record_loss();
        }
        assert_eq!(ad2.current_difficulty, 0.5);
    }

    #[test]
    fn test_rewind_system() {
        let mut rs = RewindSystem::new(2);
        assert!(rs.can_rewind() == false); // no history

        rs.save_snapshot(BattleSnapshot {
            turn: 1,
            player_units: vec![],
            enemy_units: vec![],
            player_gold: 100,
            rng_state: 42,
        });

        assert!(rs.can_rewind());
        assert_eq!(rs.current_charges, 2);

        let snapshot = rs.rewind().unwrap();
        assert_eq!(snapshot.turn, 1);
        assert_eq!(rs.current_charges, 1);

        // Second rewind fails (no history)
        assert!(rs.rewind().is_none());

        // Recharge
        rs.recharge(1);
        assert_eq!(rs.current_charges, 2);
    }

    #[test]
    fn test_personality_weights() {
        assert!(AIPersonality::Aggressive.weights().attack_weight > 1.0);
        assert!(AIPersonality::Defensive.weights().defense_weight > 1.0);
        assert!(AIPersonality::Tactical.weights().attack_weight == 1.0);
    }
}
