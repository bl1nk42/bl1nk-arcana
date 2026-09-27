//! Registration helpers for GDExtension

use gdext::{prelude::*, classes::*};

pub fn register_types(handle: gdext::InitHandle) {
    handle.register_class::<crate::BlinkCombat>();
    handle.register_class::<crate::BlinkAI>();
    handle.register_class::<crate::BlinkPathfinding>();
    handle.register_class::<crate::BlinkStats>();
    handle.register_class::<crate::BlinkDataRegistry>();
}
