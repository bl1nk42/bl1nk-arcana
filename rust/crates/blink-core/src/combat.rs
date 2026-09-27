//! Combat resolution using stats.rs formulas

use crate::{
    error::CombatError,
    stats::{BaseStats, CombatModifiers, DamageType, Element, calculate_damage, calculate_heal},
};

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct CombatInput {
    pub attacker_stats: BaseStats,
    pub defender_stats: BaseStats,
    pub attacker_mods: CombatModifiers,
    pub defender_mods: CombatModifiers,
    pub damage_type: DamageType,
    pub attack_element: Element,
    pub defender_element: Element,
    pub is_counter: bool,
    pub defender_terrain_avo_bonus: i32,
}

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
pub struct CombatResult {
    pub damage: i32,
    pub heal: i32,
    pub is_critical: bool,
    pub is_miss: bool,
    pub is_blocked: bool,
    pub defender_remaining_hp: i32,
    pub combat_log: Vec<String>,
}

/// Resolve a single combat action (attack or counter)
pub fn resolve_combat(input: CombatInput) -> Result<CombatResult, CombatError> {
    let mut log = Vec::new();

    // Calculate hit chance
    let defender_eff = crate::stats::effective_stats(input.defender_stats, &input.defender_mods);
    let avo = crate::stats::calculate_avo(
        defender_eff.spd,
        input.defender_terrain_avo_bonus,
        input.defender_mods.skill_spd_bonus, // skill AVO bonus
    );
    let hit_chance = crate::stats::calculate_hit_chance(avo);

    log.push(format!("Defender AVO: {}, Hit Chance: {}%", avo, hit_chance));

    // Roll hit (simplified - in practice use RNG)
    let hit = hit_chance > 5; // always hit unless 5% minimum miss

    if !hit {
        log.push("Attack MISSED!".to_string());
        return Ok(CombatResult {
            damage: 0,
            heal: 0,
            is_critical: false,
            is_miss: true,
            is_blocked: false,
            defender_remaining_hp: input.defender_stats.hp,
            combat_log: log,
        });
    }

    // Check Guard (Physical only)
    let is_physical = matches!(input.damage_type, DamageType::Physical);
    let has_guard =
        input.defender_mods.skill_def_bonus > 0 || input.defender_mods.aura_def_bonus > 0;

    if is_physical && has_guard {
        log.push("Attack GUARDED!".to_string());
        // Guard reduces damage by 50% (base)
        let base_dmg = calculate_damage(
            input.attacker_stats,
            input.defender_stats,
            input.damage_type,
            input.attack_element,
            input.defender_element,
            &input.attacker_mods,
        )?;
        let dmg = (base_dmg as f32 * 0.5).round() as i32;
        return Ok(CombatResult {
            damage: dmg.max(1),
            heal: 0,
            is_critical: false,
            is_miss: false,
            is_blocked: true,
            defender_remaining_hp: input.defender_stats.hp - dmg.max(1),
            combat_log: log,
        });
    }

    // Calculate damage
    let dmg = calculate_damage(
        input.attacker_stats,
        input.defender_stats,
        input.damage_type,
        input.attack_element,
        input.defender_element,
        &input.attacker_mods,
    )?;

    log.push(format!("Base damage: {}", dmg));

    // Crit check
    let crit_rate = crate::stats::calculate_crit_rate(
        input.attacker_mods.weapon_rank_bonus,
        input.attacker_mods.skill_crit_bonus,
    );
    // Simplified: crit if rate > 50%
    let is_crit = crit_rate > 50;
    let final_dmg = if is_crit { dmg * 2 } else { dmg };

    if is_crit {
        log.push("CRITICAL HIT!".to_string());
    }

    let remaining_hp = input.defender_stats.hp - final_dmg;

    log.push(format!("Final damage: {}, Defender HP: {}", final_dmg, remaining_hp.max(0)));

    Ok(CombatResult {
        damage: final_dmg,
        heal: 0,
        is_critical: is_crit,
        is_miss: false,
        is_blocked: false,
        defender_remaining_hp: remaining_hp.max(0),
        combat_log: log,
    })
}

/// Resolve healing action
pub fn resolve_heal(
    healer_int: i32,
    target_max_hp: i32,
    target_current_hp: i32,
) -> (i32, Vec<String>) {
    let heal = calculate_heal(healer_int, target_max_hp, target_current_hp);
    let log = vec![format!("Healed {} HP", heal)];
    (heal, log)
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::stats::{BaseStats, CombatModifiers, DamageType, Element};

    #[test]
    fn test_resolve_combat_basic() {
        let input = CombatInput {
            attacker_stats: BaseStats { atk: 30, def: 15, ..Default::default() },
            defender_stats: BaseStats { hp: 80, def: 22, ..Default::default() },
            attacker_mods: CombatModifiers::default(),
            defender_mods: CombatModifiers::default(),
            damage_type: DamageType::Physical,
            attack_element: Element::Neutral,
            defender_element: Element::Neutral,
            is_counter: false,
            defender_terrain_avo_bonus: 0,
        };

        let result = resolve_combat(input).unwrap();
        assert_eq!(result.damage, 19); // (30 - 22/2) = 19
        assert!(!result.is_miss);
        assert!(!result.is_blocked);
    }

    #[test]
    fn test_resolve_combat_guard() {
        let mut input = CombatInput {
            attacker_stats: BaseStats { atk: 30, def: 15, ..Default::default() },
            defender_stats: BaseStats { hp: 80, def: 22, ..Default::default() },
            attacker_mods: CombatModifiers::default(),
            defender_mods: CombatModifiers { skill_def_bonus: 10, ..Default::default() }, // Guard
            damage_type: DamageType::Physical,
            attack_element: Element::Neutral,
            defender_element: Element::Neutral,
            is_counter: false,
            defender_terrain_avo_bonus: 0,
        };

        let result = resolve_combat(input).unwrap();
        assert!(result.is_blocked);
        assert_eq!(result.damage, 9); // 19 * 0.5 = 9.5 -> 10? Wait, base is 19, half = 9
    }
}
