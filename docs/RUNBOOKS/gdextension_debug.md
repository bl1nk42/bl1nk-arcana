# Runbook: Debugging GDExtension Issues
**Version:** 1.0
**Last Updated:** 2026-09-27
**Owner:** Lead Developer

---

## Purpose
Troubleshoot common GDExtension (Rust ↔ Godot) integration issues.

---

## Common Issues & Solutions

### 1. GDExtension Not Loading

**Symptoms:**
- Godot shows "Failed to load extension" error
- Extension not in Project Settings → Extensions
- No BlinkCombat/BlinkAI classes in Autoload

**Diagnosis:**
```bash
# Check if library built
ls -la godot/addons/blink_core/bin/

# Check .gdextension file
cat godot/addons/blink_core/blink_core.gdextension

# Check Godot logs
godot --headless --script-check godot/project.godot 2>&1
```

**Solutions:**
```bash
# Rebuild and copy
just build-debug

# Verify architecture match
file godot/addons/blink_core/bin/libblink_gdext.so
# Should match: ELF 64-bit LSB shared object, x86-64

# Check .gdextension entry_symbol
# Must be: gdextension_rust_init (for godot crate 0.5)
```

---

### 2. "Could not find entry symbol" Error

**Error:**
```
ERROR: Could not find entry symbol 'gdextension_rust_init' in library
```

**Cause:** Wrong entry symbol in .gdextension or wrong crate version.

**Fix:**
```ini
# godot/addons/blink_core/blink_core.gdextension
[configuration]
entry_symbol = "gdextension_rust_init"
compatibility_minimum = "4.3"
```

**Verify Rust crate uses correct macro:**
```rust
// rust/crates/blink-gdext/src/lib.rs
use godot::prelude::*;

#[gdextension]
unsafe impl ExtensionLibrary for BlinkExtension { ... }
```

---

### 3. Class Not Registered

**Symptoms:**
- `BlinkCombat.new()` returns null
- `get_node("/root/BlinkCombat")` fails
- "Class not found: BlinkCombat"

**Diagnosis:**
```rust
// Check register_class calls in lib.rs
#[gdextension]
unsafe impl ExtensionLibrary for BlinkExtension {
    fn on_level_init(level: InitLevel) {
        if level == InitLevel::Scene {
            let mut app = get_engine().unwrap();
            app.register_class::<BlinkCombat>();  // ← Must be here
            app.register_class::<BlinkAI>();
            // ...
        }
    }
}
```

**Fix:**
1. Verify all 5 classes registered
2. Rebuild: `just build-debug`
3. Restart Godot Editor completely

---

### 4. Variant Conversion Errors

**Symptoms:**
- "Invalid variant type" in Godot logs
- Functions return empty/null
- Crash when calling from GDScript

**Common Causes:**
```rust
// ❌ Wrong: Dictionary without type params
let dict = Dictionary::new();

// ✅ Correct: Dictionary<Variant, Variant>
let dict: Dictionary<Variant, Variant> = Dictionary::new();

// ❌ Wrong: Array without type
let arr = Array::new();

// ✅ Correct: Array<Variant>
let arr: Array<Variant> = Array::new();

// ❌ Wrong: Insert owned array
dict.insert("key", arr);

// ✅ Correct: Insert reference
dict.insert("key", &arr);
```

**Debug Helper:**
```rust
// Add to conversion functions
fn debug_variant(v: &Variant) {
    godot_print!("Variant type: {:?}, value: {:?}", v.get_type(), v);
}
```

---

### 5. Thread Safety / Mutex Issues

**Symptoms:**
- Deadlock on Registry access
- "Mutex poisoned" panic
- Freeze when calling Registry from multiple threads

**Fix:**
```rust
// Use try_lock with timeout
fn get_unit(&self, id: GString) -> Variant {
    let reg = self.registry.try_lock()
        .or_else(|_| {
            godot_warn!("Registry lock contention, retrying...");
            std::thread::sleep(std::time::Duration::from_millis(1));
            self.registry.lock()
        })
        .unwrap();
    // ...
}

// Or use parking_lot for better performance
use parking_lot::Mutex;
```

---

### 6. Protobuf Version Mismatch

**Symptoms:**
- "Failed to decode message" errors
- Missing fields in converted data
- Schema mismatch between Rust and Godot

**Fix:**
```bash
# Regenerate protobuf
cd rust/crates/blink-proto
cargo build

# Verify generated code
cat rust/crates/blink-proto/src/lib.rs | head -100
```

---

### 7. Debug Logging

**Enable Rust logging in Godot:**
```rust
// In lib.rs init
use tracing_subscriber::fmt::init;
init(); // Or use godot_log crate
```

**Godot Debug Settings:**
```
Project → Project Settings → Debug → Settings
- Enable "Print Errors"
- Enable "Verbose Stdout"
```

**View Logs:**
```bash
# Terminal
godot --headless --script-check godot/project.godot 2>&1 | grep -i blink

# Godot Output Log
# Debug → Output Log in Editor
```

---

### 8. Performance Profiling

**Rust-side:**
```bash
# Build with debug symbols
just build-debug

# Profile with perf (Linux)
perf record --call-graph=dwarf godot --headless ...
perf report
```

**Godot-side:**
```
Debug → Profiler → Start
Run battle scene
Debug → Profiler → Stop → Analyze
```

---

## Emergency Recovery

### Reset Everything
```bash
just clean-all
just build-debug
```

### Nuclear Option
```bash
rm -rf rust/target/
rm -rf godot/addons/blink_core/bin/*
rm -rf ~/.cargo/registry/cache/*
rustup update
just build-debug
```

---

## Related Runbooks
- `dev_setup.md` — Initial setup
- `ci_cd_debug.md` — CI/CD pipeline issues
- `deployment.md` — Export/Deploy issues
