//! Intention System — Shows AI's planned action 1 turn in advance
//! Based on Into the Breach mechanic

use serde::{Deserialize, Serialize};

use crate::{
    ai::{AIAction, AIDecision, BattleUnitSnapshot, Team},
    pathfinding::GridPos,
};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AIIntention {
    pub unit_id: String,
    pub action_type: IntentionType,
    pub target_x: i32,
    pub target_y: i32,
    pub skill_id: Option<String>,
    pub description: String,
    pub certainty: f32, // 0.0 - 1.0
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
pub enum IntentionType {
    MoveAttack,
    UseSkill,
    Wait,
    EndTurn,
}

impl From<AIAction> for AIIntention {
    fn from(action: AIAction) -> Self {
        match action {
            AIAction::MoveAttack { target_x, target_y, .. } => Self {
                unit_id: String::new(), // filled by caller
                action_type: IntentionType::MoveAttack,
                target_x,
                target_y,
                skill_id: None,
                description: "Will move and attack".to_string(),
                certainty: 0.9,
            },
            AIAction::UseSkill { skill_id, target_x, target_y } => Self {
                unit_id: String::new(),
                action_type: IntentionType::UseSkill,
                target_x,
                target_y,
                skill_id: Some(skill_id),
                description: "Will use skill".to_string(),
                certainty: 0.85,
            },
            AIAction::Wait => Self {
                unit_id: String::new(),
                action_type: IntentionType::Wait,
                target_x: 0,
                target_y: 0,
                skill_id: None,
                description: "Will wait".to_string(),
                certainty: 0.5,
            },
            AIAction::EndTurn => Self {
                unit_id: String::new(),
                action_type: IntentionType::EndTurn,
                target_x: 0,
                target_y: 0,
                skill_id: None,
                description: "Ending turn".to_string(),
                certainty: 1.0,
            },
        }
    }
}

/// Intention System Manager
pub struct IntentionSystem {
    pub intentions: Vec<AIIntention>,
    pub show_to_player: bool,
}

impl IntentionSystem {
    pub fn new() -> Self {
        Self { intentions: Vec::new(), show_to_player: true }
    }

    pub fn clear(&mut self) {
        self.intentions.clear();
    }

    pub fn add_intention(&mut self, decision: &AIDecision, unit: &BattleUnitSnapshot) {
        let intention = AIIntention {
            unit_id: decision.unit_id.clone(),
            action_type: match &decision.action {
                AIAction::MoveAttack { .. } => IntentionType::MoveAttack,
                AIAction::UseSkill { .. } => IntentionType::UseSkill,
                AIAction::Wait => IntentionType::Wait,
                AIAction::EndTurn => IntentionType::EndTurn,
            },
            target_x: match &decision.action {
                AIAction::MoveAttack { target_x, target_y, .. }
                | AIAction::UseSkill { target_x, target_y, .. } => *target_x,
                _ => unit.x,
            },
            target_y: match &decision.action {
                AIAction::MoveAttack { target_x, target_y, .. }
                | AIAction::UseSkill { target_x, target_y, .. } => *target_y,
                _ => unit.y,
            },
            skill_id: match &decision.action {
                AIAction::UseSkill { skill_id, .. } => Some(skill_id.clone()),
                _ => None,
            },
            description: decision.reasoning.clone(),
            certainty: decision.confidence,
        };

        self.intentions.push(intention);
    }

    pub fn get_visible_intentions(&self, team: Team) -> Vec<&AIIntention> {
        if !self.show_to_player {
            return vec![];
        }

        // In Into the Breach, you see ALL enemy intentions
        // Here we show based on team
        self.intentions
            .iter()
            .filter(|i| {
                // For now, show all. Could filter by team if needed.
                true
            })
            .collect()
    }

    pub fn get_intention_for_unit(&self, unit_id: &str) -> Option<&AIIntention> {
        self.intentions.iter().find(|i| i.unit_id == unit_id)
    }

    pub fn toggle_visibility(&mut self) {
        self.show_to_player = !self.show_to_player;
    }
}

impl Default for IntentionSystem {
    fn default() -> Self {
        Self::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::{
        ai::{AIAction, AIDecision, BattleUnitSnapshot, Team},
        stats::BaseStats,
    };

    fn make_unit() -> BattleUnitSnapshot {
        BattleUnitSnapshot {
            unit_id: "test_unit".to_string(),
            x: 3,
            y: 3,
            hp: 50,
            max_hp: 50,
            stats: BaseStats {
                hp: 50,
                atk: 20,
                def: 15,
                int: 10,
                spd: 10,
                mov: 5,
                rng: 1,
                res: 10,
            },
            mods: crate::stats::CombatModifiers::default(),
            team: Team::Enemy,
            has_acted: false,
            has_moved: false,
        }
    }

    #[test]
    fn test_intention_from_action() {
        let mut system = IntentionSystem::new();
        let unit = make_unit();

        let decision = AIDecision {
            unit_id: "test_unit".to_string(),
            action: AIAction::MoveAttack { target_x: 4, target_y: 3, move_path: vec![] },
            confidence: 0.9,
            reasoning: "Attack player".to_string(),
        };

        system.add_intention(&decision, &unit);

        let intentions = system.get_visible_intentions(Team::Player);
        assert_eq!(intentions.len(), 1);
        assert_eq!(intentions[0].unit_id, "test_unit");
        assert_eq!(intentions[0].action_type, IntentionType::MoveAttack);
        assert_eq!(intentions[0].target_x, 4);
        assert_eq!(intentions[0].target_y, 3);
        assert_eq!(intentions[0].certainty, 0.9);
    }

    #[test]
    fn test_intention_wait() {
        let mut system = IntentionSystem::new();
        let unit = make_unit();

        let decision = AIDecision {
            unit_id: "test_unit".to_string(),
            action: AIAction::Wait,
            confidence: 0.5,
            reasoning: "No targets".to_string(),
        };

        system.add_intention(&decision, &unit);

        let intentions = system.get_visible_intentions(Team::Player);
        assert_eq!(intentions[0].action_type, IntentionType::Wait);
    }
}
