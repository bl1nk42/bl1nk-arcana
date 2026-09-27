//! blink-gdext: GDExtension binding for Blink Arcana
//!
//! Thin binding layer: Godot <-> Protobuf <-> blink-core

use blink_core::{combat, data, stats};
use godot::{
    builtin::{Array, Dictionary, GString, Variant},
    init::*,
    prelude::*,
};

// ============================================================
// GDExtension Entry Point (godot-rust 0.5 with api-4-6)
// ============================================================

struct BlinkExtension;

#[gdextension]
unsafe impl ExtensionLibrary for BlinkExtension {
    fn on_stage_init(stage: InitStage) {
        if stage == InitStage::MainLoop {
            // Classes are auto-registered by the trait impl
            // No manual registration needed
        }
    }

    fn on_stage_deinit(_stage: InitStage) {}
}

// ============================================================
// Combat Binding
// ============================================================

#[derive(GodotClass)]
#[class(base=RefCounted, init)]
pub struct BlinkCombat;

#[godot_api]
impl BlinkCombat {
    #[func]
    fn resolve_combat(
        _attacker_stats: Dictionary<Variant, Variant>,
        _defender_stats: Dictionary<Variant, Variant>,
        _attacker_mods: Dictionary<Variant, Variant>,
        _defender_mods: Dictionary<Variant, Variant>,
        _damage_type: i32,
        _attack_element: i32,
        _defender_element: i32,
        _is_counter: bool,
        _defender_terrain_avo_bonus: i32,
    ) -> Variant {
        let result = combat::CombatResult {
            damage: 0,
            heal: 0,
            is_critical: false,
            is_miss: false,
            is_blocked: false,
            defender_remaining_hp: 0,
            combat_log: vec!["Stub".to_string()],
        };

        Self::result_to_variant(result)
    }

    fn result_to_variant(result: combat::CombatResult) -> Variant {
        let mut dict: Dictionary<Variant, Variant> = Dictionary::new();
        let _ = dict.insert("damage", result.damage);
        let _ = dict.insert("heal", result.heal);
        let _ = dict.insert("is_critical", result.is_critical);
        let _ = dict.insert("is_miss", result.is_miss);
        let _ = dict.insert("is_blocked", result.is_blocked);
        let _ = dict.insert("defender_remaining_hp", result.defender_remaining_hp);

        let combat_log: Array<Variant> = Array::from_iter(
            result.combat_log.iter().map(|s| Variant::from(GString::from(s.as_str()))),
        );
        let _ = dict.insert("combat_log", &combat_log);

        dict.to_variant()
    }
}

// ============================================================
// AI Binding
// ============================================================

#[derive(GodotClass)]
#[class(base=RefCounted, init)]
pub struct BlinkAI;

#[godot_api]
impl BlinkAI {
    #[func]
    fn decide_action(
        _unit: Dictionary<Variant, Variant>,
        _allies: Array<Variant>,
        _enemies: Array<Variant>,
        _grid: Dictionary<Variant, Variant>,
        _personality: i32,
        _difficulty: f64,
    ) -> Variant {
        let mut dict: Dictionary<Variant, Variant> = Dictionary::new();
        let _ = dict.insert("action", "wait");
        let _ = dict.insert("confidence", 0.5_f64);
        let _ = dict.insert("reasoning", "Stub");
        dict.to_variant()
    }

    #[func]
    fn get_intentions() -> Variant {
        let arr: Array<Variant> = Array::new();
        arr.to_variant()
    }
}

// ============================================================
// Pathfinding Binding
// ============================================================

#[derive(GodotClass)]
#[class(base=RefCounted, init)]
pub struct BlinkPathfinding;

#[godot_api]
impl BlinkPathfinding {
    #[func]
    fn find_path(
        _grid: Dictionary<Variant, Variant>,
        _start_x: i32,
        _start_y: i32,
        _goal_x: i32,
        _goal_y: i32,
        _max_mov: i32,
        _move_type: i32,
    ) -> Variant {
        let arr: Array<Variant> = Array::new();
        arr.to_variant()
    }

    #[func]
    fn get_reachable(
        _grid: Dictionary<Variant, Variant>,
        _start_x: i32,
        _start_y: i32,
        _max_mov: i32,
        _move_type: i32,
    ) -> Variant {
        let arr: Array<Variant> = Array::new();
        arr.to_variant()
    }
}

// ============================================================
// Stats Binding
// ============================================================

#[derive(GodotClass)]
#[class(base=RefCounted, init)]
pub struct BlinkStats;

#[godot_api]
impl BlinkStats {
    #[func]
    fn calculate_damage(
        _attacker_stats: Dictionary<Variant, Variant>,
        _defender_stats: Dictionary<Variant, Variant>,
        _mods: Dictionary<Variant, Variant>,
        _damage_type: i32,
        _attack_element: i32,
        _defender_element: i32,
    ) -> i32 {
        0
    }

    #[func]
    fn calculate_heal(healer_int: i32, target_max_hp: i32, target_current_hp: i32) -> i32 {
        stats::calculate_heal(healer_int, target_max_hp, target_current_hp)
    }

    #[func]
    fn calculate_avo(spd: i32, terrain_bonus: i32, skill_bonus: i32) -> i32 {
        stats::calculate_avo(spd, terrain_bonus, skill_bonus)
    }

    #[func]
    fn calculate_hit_chance(avo: i32) -> i32 {
        stats::calculate_hit_chance(avo)
    }

    #[func]
    fn calculate_crit_rate(weapon_rank_bonus: i32, skill_bonus: i32) -> i32 {
        stats::calculate_crit_rate(weapon_rank_bonus, skill_bonus)
    }
}

// ============================================================
// Data Registry Binding
// ============================================================

#[derive(GodotClass)]
#[class(base=RefCounted, init)]
pub struct BlinkDataRegistry {
    registry: std::sync::Mutex<Option<data::DataRegistry>>,
}

#[godot_api]
impl BlinkDataRegistry {
    #[func]
    fn load_from_dir(&mut self, path: GString) -> bool {
        let mut reg = self.registry.lock().unwrap();
        if reg.is_none() {
            *reg = Some(data::DataRegistry::new());
        }

        match reg.as_mut().unwrap().load_from_dir(&path.to_string()) {
            Ok(_) => true,
            Err(e) => {
                godot_error!("Failed to load data: {:?}", e);
                false
            },
        }
    }

    #[func]
    fn get_unit(&self, id: GString) -> Variant {
        let reg = self.registry.lock().unwrap();
        if let Some(reg) = reg.as_ref() {
            if let Ok(unit) = reg.get_unit(&id.to_string()) {
                return Self::unit_to_variant(unit);
            }
        }
        Variant::nil()
    }

    fn unit_to_variant(unit: &data::UnitData) -> Variant {
        let mut dict: Dictionary<Variant, Variant> = Dictionary::new();
        let _ = dict.insert("id", unit.id.clone());
        let _ = dict.insert("name", unit.name.clone());
        let _ = dict.insert("class_line", unit.class_line.clone());
        let _ = dict.insert("class", unit.class.clone());
        let _ = dict.insert("class_tier", unit.class_tier as i32);
        let _ = dict.insert("element", unit.element.clone());
        let _ = dict.insert("level", unit.level as i32);

        let mut stats_dict: Dictionary<Variant, Variant> = Dictionary::new();
        let _ = stats_dict.insert("hp", unit.base_stats.hp);
        let _ = stats_dict.insert("atk", unit.base_stats.atk);
        let _ = stats_dict.insert("def", unit.base_stats.def);
        let _ = stats_dict.insert("int", unit.base_stats.int);
        let _ = stats_dict.insert("spd", unit.base_stats.spd);
        let _ = stats_dict.insert("mov", unit.base_stats.mov);
        let _ = stats_dict.insert("rng", unit.base_stats.rng);
        let _ = stats_dict.insert("res", unit.base_stats.res);
        let _ = dict.insert("base_stats", &stats_dict);

        dict.to_variant()
    }
}
