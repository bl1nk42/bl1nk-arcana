//! Combat unit tests - testing public API only
use blink_core::stats;

#[test]
fn test_calculate_heal() {
    // Heal = INT * 0.5, clamped to missing HP
    let heal = stats::calculate_heal(20, 100, 50); // 20 * 0.5 = 10, missing=50 -> 10
    assert_eq!(heal, 10);

    // Clamp to missing HP
    let heal = stats::calculate_heal(100, 100, 95); // 50, missing=5 -> 5
    assert_eq!(heal, 5);
}

#[test]
fn test_calculate_avo() {
    // AVO = SPD * 2 + terrain_bonus
    let avo = stats::calculate_avo(10, 5, 0); // 10 * 2 + 5 = 25
    assert_eq!(avo, 25);
}

#[test]
fn test_calculate_hit_chance() {
    // Hit chance = 100 - AVO, clamped 5-95
    assert_eq!(stats::calculate_hit_chance(0), 95); // Max 95%
    assert_eq!(stats::calculate_hit_chance(95), 5); // Min 5%
    assert_eq!(stats::calculate_hit_chance(50), 50); // Middle
}

#[test]
fn test_calculate_crit_rate() {
    let crit = stats::calculate_crit_rate(10, 5); // 15%
    assert_eq!(crit, 15);
}
