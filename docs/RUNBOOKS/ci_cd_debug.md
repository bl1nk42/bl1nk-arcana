# Runbook: CI/CD Pipeline Debugging
**Version:** 1.0
**Last Updated:** 2026-09-27
**Owner:** Lead Developer

---

## Purpose
Troubleshoot GitHub Actions / Buildkite CI pipeline failures.

---

## Pipeline Overview
```
Format Check → Clippy → GDLint → Unit Tests → Integration Tests
    → Security Audit → Dependency Check → Build (Linux/Windows)
    → Godot Export → Docker Build → Deploy (main only)
```

---

## Common Failures & Fixes

### 1. Format Check Fails
**Error:** `cargo fmt --check` or `gdformat --check` or `taplo fmt --check`

**Fix:**
```bash
# Local fix
just fmt
git add -u
git commit -m "style: fix formatting"
git push
```

**CI Debug:**
```yaml
# In workflow, add debug step:
- name: Show format diff
  run: |
    cargo fmt --all -- --check 2>&1 || true
    gdformat --check godot/scripts/ 2>&1 || true
    taplo fmt --check **/*.toml 2>&1 || true
```

---

### 2. Clippy Fails
**Error:** `cargo clippy -- -D warnings` returns warnings as errors

**Common Clippy Issues:**
```rust
// ❌ unwrap_used
let x = some_option.unwrap();

// ✅ Fix
let x = some_option.ok_or(Error::Missing)?;

// ❌ needless_borrow
let x = &some_vec[0];

// ✅ Fix
let x = some_vec[0];

// ❌ unused_import
use std::collections::HashMap;  // Not used

// ✅ Fix
// Remove import
```

**Fix:**
```bash
just lint-rust  # Shows exact errors
# Fix each, then commit
```

---

### 3. GDLint Fails
**Error:** GDScript linting errors

**Common Issues:**
```gdscript
# ❌ Missing type hint
var health = 100

# ✅ Fix
var health: int = 100

# ❌ Unused variable
func _ready():
    var unused = 5

# ✅ Fix
func _ready():
    var _unused = 5  # Prefix with _

# ❌ No early return
func take_damage(amount):
    if amount > 0:
        health -= amount

# ✅ Fix
func take_damage(amount: int) -> void:
    if amount <= 0:
        return
    health -= amount
```

---

### 4. Tests Fail
**Error:** `cargo test` or `cargo nextest run` failures

**Debug:**
```bash
# Run specific test
cargo test --package blink-core combat_tests::test_damage_calculation -- --nocapture

# Run with debug output
cargo test --package blink-core -- --nocapture 2>&1 | head -100

# Check test output in CI
# Look for: "test result: FAILED"
```

**Common Issues:**
- Test assumptions changed (update test)
- Race conditions (add synchronization)
- Flaky tests (mark with `#[ignore]` and fix later)

---

### 5. Security Audit Fails
**Error:** `cargo audit` or `cargo deny check` failures

**cargo audit:**
```bash
# Check locally
cargo audit

# If vulnerability in transitive dep
# Option 1: Update direct dependency
cargo update -p vulnerable-crate

# Option 2: Add to deny.toml exceptions (with justification)
# deny.toml:
# [advisories.allow]
# yanked = ["CVE-XXXX-XXXX"]  # Document why
```

**cargo deny:**
```bash
cargo deny check

# Common: License issues
# Fix: Add allowed licenses in deny.toml
# [licenses]
# allow = ["MIT", "Apache-2.0", "BSD-3-Clause"]
```

---

### 6. Build Fails
**Error:** `cargo build --release --workspace` fails

**Common Issues:**
```bash
# Linker errors (Windows cross-compile)
# Fix: Use Docker for Windows builds

# Missing system deps (Linux)
# Fix: Install pkg-config, libssl-dev, protobuf-compiler

# Protobuf generation failed
# Fix: Check proto/blink_v1.proto syntax
cd rust/crates/blink-proto && cargo build
```

**Debug in CI:**
```yaml
- name: Debug build
  run: |
    cd rust
    cargo build --release --workspace --verbose 2>&1 | tail -50
```

---

### 7. Godot Export Fails
**Error:** `godot --headless --export-release` fails

**Common Issues:**
```bash
# Export template missing
# Fix: Download in CI setup step
- name: Install Godot export templates
  run: |
    wget https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz
    unzip -o Godot_v4.3-stable_export_templates.tpz -d ~/.local/share/godot/export_templates/4.3.stable

# GDExtension not found
# Fix: Ensure build step copies .so/.dll/.dylib to godot/addons/blink_core/bin/
```

---

### 8. Docker Build Fails
**Error:** `docker build` fails

**Common Issues:**
```dockerfile
# Cache issues
# Fix: Use --no-cache or change base image tag

# Multi-arch failures
# Fix: Use docker buildx
docker buildx build --platform linux/amd64,linux/arm64 ...

# Permission denied
# Fix: Check Docker daemon running, user in docker group
```

---

## Local CI Simulation
```bash
# Run full CI locally
just ci-check

# Individual steps
just fmt-check
just lint
just test
just build
just audit
```

---

## Buildkite Specific

### Pipeline Debug
```bash
# View build logs
buildkite-agent artifact download "logs/*" .

# Trigger retry
buildkite-agent pipeline upload --build <BUILD_ID>

# Check agent health
buildkite-agent meta-data get "agent-health"
```

### Common Buildkite Issues
| Issue | Fix |
|-------|-----|
| Agent offline | Restart buildkite-agent service |
| Artifact upload fail | Check disk space, network |
| Timeout | Increase `timeout` in pipeline.yml |
| Plugin version | Pin plugin versions in pipeline.yml |

---

## GitHub Actions Specific

### Re-run Failed Jobs
```bash
# Via CLI
gh run rerun <RUN_ID> --failed

# Via Web
# Actions tab → Re-run failed jobs
```

### Debug with SSH (Ubuntu)
```yaml
# Add to failing job:
- name: Setup tmate
  uses: mxschmitt/action-tmate@v3
  if: failure()
  with:
    limit-access-to-actor: true
```

### Cache Issues
```bash
# Clear cache
gh cache delete --all
# Or in workflow:
- name: Clear cache
  run: |
    rm -rf ~/.cargo/registry/cache/*
    rm -rf ~/.cargo/git/checkouts/*
```

---

## Escalation Matrix

| Failure Type | First Response | Escalation |
|--------------|----------------|------------|
| Format/Lint | Local fix + push | Team lead |
| Test flaky | Mark ignore + file issue | QA lead |
| Security vuln | Update dep + audit | Security lead |
| Build broken | Revert last commit | Platform lead |
| Export broken | Check templates | Platform lead |

---

## Related Runbooks
- `dev_setup.md` — Initial setup
- `gdextension_debug.md` — GDExtension issues
- `deployment.md` — Export/Deploy issues
