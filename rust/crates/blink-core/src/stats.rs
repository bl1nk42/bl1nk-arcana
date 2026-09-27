//! Stats calculations — Base formulas from PDR.md Section 2.4
//!
//! Bonus from Card/Weapon Rank/Skill/Aura/Class are applied externally
//! via SkillEffect / WeaponAbility / Class modifiers.

use std::collections::HashMap;

use crate::error::{CombatError, StatsError};

#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub struct BaseStats {
    pub hp: i32,
    pub atk: i32,
    pub def: i32,
    pub int: i32,
    pub spd: i32,
    pub mov: i32,
    pub rng: i32,
    pub res: i32,
}

impl Default for BaseStats {
    fn default() -> Self {
        Self { hp: 0, atk: 0, def: 0, int: 0, spd: 0, mov: 0, rng: 1, res: 0 }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum DamageType {
    Physical,
    Magic,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum Element {
    Fire,
    Water,
    Wind,
    Earth,
    Light,
    Dark,
    Neutral,
}

impl Element {
    /// Returns damage multiplier (1.0 = neutral, 1.3 = advantage, 0.7 = disadvantage)
    pub fn effectiveness(attack: Element, defense: Element) -> f32 {
        use Element::*;
        match (attack, defense) {
            (Fire, Water) => 0.7,
            (Water, Fire) => 1.3,
            (Wind, Water) => 0.7,
            (Wind, Earth) => 0.7,
            (Earth, Wind) => 1.3,
            (Light, Dark) => 0.7,
            (Dark, Light) => 0.7,
            _ => 1.0,
        }
    }
}

#[derive(Debug, Clone, Copy, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct CombatModifiers {
    pub weapon_atk_bonus: i32,
    pub weapon_rank_bonus: i32, // crit rate
    pub skill_atk_bonus: i32,
    pub skill_def_bonus: i32,
    pub skill_int_bonus: i32,
    pub skill_res_bonus: i32,
    pub skill_spd_bonus: i32,
    pub skill_crit_bonus: i32,
    pub skill_damage_mult: f32, // e.g., 1.15 for Strong Hit +15%
    pub aura_def_bonus: i32,
    pub aura_res_bonus: i32,
    pub terrain_def_bonus: i32,
    pub terrain_avo_bonus: i32,
}

impl Default for CombatModifiers {
    fn default() -> Self {
        Self {
            weapon_atk_bonus: 0,
            weapon_rank_bonus: 0,
            skill_atk_bonus: 0,
            skill_def_bonus: 0,
            skill_int_bonus: 0,
            skill_res_bonus: 0,
            skill_spd_bonus: 0,
            skill_crit_bonus: 0,
            skill_damage_mult: 1.0,
            aura_def_bonus: 0,
            aura_res_bonus: 0,
            terrain_def_bonus: 0,
            terrain_avo_bonus: 0,
        }
    }
}

/// Calculate effective stats with all modifiers
pub fn effective_stats(base: BaseStats, mods: &CombatModifiers) -> BaseStats {
    BaseStats {
        hp: base.hp,
        atk: base.atk + mods.weapon_atk_bonus + mods.skill_atk_bonus,
        def: base.def + mods.skill_def_bonus + mods.aura_def_bonus + mods.terrain_def_bonus,
        int: base.int + mods.skill_int_bonus,
        spd: base.spd + mods.skill_spd_bonus,
        mov: base.mov,
        rng: base.rng,
        res: base.res + mods.skill_res_bonus + mods.aura_res_bonus,
    }
}

/// Physical Damage = (ATK - DEF/2) × Element Multiplier
/// Magic Damage = (INT - RES/2) × Element Multiplier
pub fn calculate_damage(
    attacker: BaseStats,
    defender: BaseStats,
    dmg_type: DamageType,
    attack_element: Element,
    defender_element: Element,
    mods: &CombatModifiers,
) -> Result<i32, CombatError> {
    let eff_stats = effective_stats(attacker, mods);
    let def_stats = effective_stats(defender, mods);
    let elem_mult = Element::effectiveness(attack_element, defender_element);

    let base_dmg = match dmg_type {
        DamageType::Physical => {
            let atk = eff_stats.atk as f32;
            let def = def_stats.def as f32;
            (atk - def / 2.0).max(1.0)
        },
        DamageType::Magic => {
            let int = eff_stats.int as f32;
            let res = def_stats.res as f32;
            (int - res / 2.0).max(1.0)
        },
    };

    let mut dmg = (base_dmg * elem_mult * mods.skill_damage_mult).round() as i32;
    dmg = dmg.max(1);
    Ok(dmg)
}

/// Heal Amount = INT × 0.5 (capped at Max HP)
pub fn calculate_heal(healer_int: i32, target_max_hp: i32, target_current_hp: i32) -> i32 {
    let heal = (healer_int as f32 * 0.5).round() as i32;
    let max_heal = target_max_hp - target_current_hp;
    heal.min(max_heal).max(0)
}

/// AVO = (SPD × 2) + Terrain Bonus + Skill Bonus (Cap 100%)
pub fn calculate_avo(spd: i32, terrain_bonus: i32, skill_bonus: i32) -> i32 {
    let avo = (spd * 2) + terrain_bonus + skill_bonus;
    avo.clamp(0, 100)
}

/// Hit Chance = 100 - AVO (Clamp 5%-95%)
pub fn calculate_hit_chance(avo: i32) -> i32 {
    (100 - avo).clamp(5, 95)
}

/// Crit Rate = Weapon Rank Bonus + Skill Bonus
pub fn calculate_crit_rate(weapon_rank_bonus: i32, skill_bonus: i32) -> i32 {
    (weapon_rank_bonus + skill_bonus).clamp(0, 100)
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct UnitStats {
    pub base: BaseStats,
    pub current_hp: i32,
    pub modifiers: CombatModifiers,
    pub equipped_skills: Vec<String>, // Skill IDs
}

impl UnitStats {
    pub fn new(base: BaseStats) -> Self {
        Self {
            base,
            current_hp: base.hp,
            modifiers: CombatModifiers::default(),
            equipped_skills: vec![],
        }
    }

    pub fn effective(&self) -> BaseStats {
        effective_stats(self.base, &self.modifiers)
    }

    pub fn is_alive(&self) -> bool {
        self.current_hp > 0
    }
    pub fn hp_ratio(&self) -> f32 {
        self.current_hp as f32 / self.base.hp as f32
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_physical_damage_basic() {
        let atk = BaseStats { atk: 30, def: 15, ..Default::default() };
        let def = BaseStats { def: 22, ..Default::default() };
        let dmg = calculate_damage(
            atk,
            def,
            DamageType::Physical,
            Element::Neutral,
            Element::Neutral,
            &CombatModifiers::default(),
        )
        .unwrap();
        // (30 - 22/2) = 30 - 11 = 19
        assert_eq!(dmg, 19);
    }

    #[test]
    fn test_magic_damage_basic() {
        let atk = BaseStats { int: 20, res: 12, ..Default::default() };
        let def = BaseStats { res: 18, ..Default::default() };
        let dmg = calculate_damage(
            atk,
            def,
            DamageType::Magic,
            Element::Neutral,
            Element::Neutral,
            &CombatModifiers::default(),
        )
        .unwrap();
        // (20 - 18/2) = 20 - 9 = 11
        assert_eq!(dmg, 11);
    }

    #[test]
    fn test_element_advantage() {
        let atk = BaseStats { atk: 30, def: 15, ..Default::default() };
        let def = BaseStats { def: 22, ..Default::default() };
        let dmg = calculate_damage(
            atk,
            def,
            DamageType::Physical,
            Element::Water,
            Element::Fire,
            &CombatModifiers::default(),
        )
        .unwrap();
        // Base 19 * 1.3 = 24.7 -> 25
        assert_eq!(dmg, 25);
    }

    #[test]
    fn test_element_disadvantage() {
        let atk = BaseStats { atk: 30, def: 15, ..Default::default() };
        let def = BaseStats { def: 22, ..Default::default() };
        let dmg = calculate_damage(
            atk,
            def,
            DamageType::Physical,
            Element::Fire,
            Element::Water,
            &CombatModifiers::default(),
        )
        .unwrap();
        // Base 19 * 0.7 = 13.3 -> 13
        assert_eq!(dmg, 13);
    }

    #[test]
    fn test_avo_calculation() {
        let avo = calculate_avo(10, 10, 5); // SPD=10, Terrain=10%, Skill=5%
        assert_eq!(avo, 35);
    }

    #[test]
    fn test_hit_chance_clamp() {
        assert_eq!(calculate_hit_chance(100), 5); // min 5%
        assert_eq!(calculate_hit_chance(0), 95); // max 95%
        assert_eq!(calculate_hit_chance(50), 50); // normal
    }

    #[test]
    fn test_crit_rate() {
        assert_eq!(calculate_crit_rate(5, 10), 15);
        assert_eq!(calculate_crit_rate(100, 50), 100); // cap 100%
    }

    #[test]
    fn test_heal_calculation() {
        assert_eq!(calculate_heal(20, 80, 50), 10); // INT=20 -> 10 heal, max 30
        assert_eq!(calculate_heal(20, 80, 75), 5); // capped at 5 (max HP)
        assert_eq!(calculate_heal(20, 80, 80), 0); // full HP
    }
}
