//! blink-core: Core logic for Blink Arcana
//! Combat, AI, Pathfinding, Stats, Data Structures
//!
//! This crate has NO dependency on Godot — pure Rust for testability.

pub mod combat;
pub mod ai;
pub mod pathfinding;
pub mod stats;
pub mod data;
pub mod error;

pub use ai::*;
pub use combat::*;
pub use data::*;
pub use error::*;
pub use pathfinding::*;
pub use stats::*;
