//! Error types for blink-core

use thiserror::Error;

#[derive(Error, Debug)]
pub enum CombatError {
    #[error("Invalid attacker: {0}")]
    InvalidAttacker(String),
    #[error("Invalid defender: {0}")]
    InvalidDefender(String),
    #[error("Weapon not equipped: {0}")]
    WeaponNotEquipped(String),
    #[error("Calculation error: {0}")]
    CalculationError(String),
}

#[derive(Error, Debug)]
pub enum AIError {
    #[error("No valid action found for unit: {0}")]
    NoValidAction(String),
    #[error("Pathfinding failed: {0}")]
    PathfindingFailed(String),
    #[error("Invalid personality: {0}")]
    InvalidPersonality(String),
}

#[derive(Error, Debug)]
pub enum PathfindingError {
    #[error("No path found from ({x1},{y1}) to ({x2},{y2})")]
    NoPath { x1: i32, y1: i32, x2: i32, y2: i32 },
    #[error("Invalid grid dimensions: {width}x{height}")]
    InvalidGrid { width: i32, height: i32 },
    #[error("Position out of bounds: ({x},{y})")]
    OutOfBounds { x: i32, y: i32 },
}

#[derive(Error, Debug)]
pub enum DataError {
    #[error("Unit not found: {0}")]
    UnitNotFound(String),
    #[error("Skill not found: {0}")]
    SkillNotFound(String),
    #[error("Weapon not found: {0}")]
    WeaponNotFound(String),
    #[error("Invalid class line: {0}")]
    InvalidClassLine(String),
    #[error("Invalid element: {0}")]
    InvalidElement(String),
}

#[derive(Error, Debug)]
pub enum StatsError {
    #[error("Invalid stat value: {stat} = {value} (min: {min}, max: {max})")]
    InvalidStat { stat: String, value: i32, min: i32, max: i32 },
    #[error("Insufficient slots: need {need}, have {have}")]
    InsufficientSlots { need: u8, have: u8 },
    #[error("Skill already equipped: {0}")]
    SkillAlreadyEquipped(String),
}
