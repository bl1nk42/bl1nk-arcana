# Runbook: Deployment & Export
**Version:** 1.0
**Last Updated:** 2026-09-27
**Owner:** Lead Developer

---

## Purpose
Build and export Blink Arcana for all target platforms.

---

## Prerequisites
- `just build` successful (release build)
- All tests passing (`just test-all`)
- Export templates installed for Godot 4.7
- Docker available for container builds

---

## Platform Exports

### Linux (x86_64)
```bash
just godot-export-linux
# Output: build/linux/blink-arcana
# Run: ./build/linux/blink-arcana
```

**Requirements:**
- Export template: `Linux/X11`
- Godot 4.7 export template installed

### Windows (x86_64)
```bash
just godot-export-windows
# Output: build/windows/blink-arcana.exe
```

**Requirements:**
- Export template: `Windows Desktop`
- Cross-compile Rust: `rustup target add x86_64-pc-windows-msvc`
- Install mingw-w64 or use Docker

### macOS (Universal)
```bash
just godot-export-macos
# Output: build/macos/blink-arcana.dmg
```

**Requirements:**
- Export template: `macOS`
- **Must build on macOS** (codesigning)
- Rust targets: `x86_64-apple-darwin`, `aarch64-apple-darwin`

### Web (WASM)
```bash
just godot-export-web
# Output: build/web/ (index.html, .wasm, .pck, .js)
```

**Requirements:**
- Export template: `Web`
- Rust target: `wasm32-unknown-unknown`
- `cargo install wasm-bindgen-cli`
- Godot Web export settings: Threads OFF, GDScript OFF

### Android (ARM64/ARM32)
```bash
just godot-export-android
# Output: build/android/blink-arcana.apk
```

**Requirements:**
- Export template: `Android`
- Android SDK/NDK installed
- Rust targets: `aarch64-linux-android`, `armv7-linux-androideabi`
- Keystore for signing (release)

### All Platforms
```bash
just godot-export-all
# Runs all exports sequentially
```

---

## Docker Build

### Production Image
```bash
# Build
just docker-build
# Or manually:
docker build -t blink-arcana:latest -f docker/Dockerfile .

# Run
docker run --rm -it blink-arcana:latest
# Runs Godot with --main-pack
```

### Development Image
```bash
just docker-dev
# Mounts current directory, runs Godot Editor
```

### Multi-arch Build (CI)
```bash
docker buildx create --use
docker buildx build --platform linux/amd64,linux/arm64 -t blink-arcana:latest -f docker/Dockerfile .
```

---

## Release Process

### 1. Pre-Release Checklist
```bash
# Full quality check
just ci-check

# Version bump
# Edit Cargo.toml workspace version
# Edit PDR.md version
# Edit distribution.yaml version

# Tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### 2. GitHub Release (Automated via CI)
```yaml
# .github/workflows/release.yml triggers on tag
# 1. Build all platforms
# 2. Create GitHub Release
# 3. Upload artifacts
# 4. Generate changelog
```

### 3. Manual Release (if needed)
```bash
# Build all
just godot-export-all

# Create release directory
mkdir -p release/v1.0.0
cp build/linux/blink-arcana release/v1.0.0/blink-arcana-linux
cp build/windows/blink-arcana.exe release/v1.0.0/blink-arcana-windows.exe
cp build/macos/blink-arcana.dmg release/v1.0.0/blink-arcana-macos.dmg
cp -r build/web release/v1.0.0/web
cp build/android/blink-arcana.apk release/v1.0.0/blink-arcana-android.apk

# Checksums
cd release/v1.0.0
sha256sum * > SHA256SUMS
```

### 4. Steam/itch.io Upload
```bash
# Steam
steamcmd +login USER +run_app_build ../steamworks/app_build.vdf +quit

# itch.io
butler push release/v1.0.0/user/blink-arcana:linux
butler push release/v1.0.0/blink-arcana-windows.exe user/blink-arcana:windows
# etc.
```

---

## Export Troubleshooting

| Issue | Solution |
|-------|----------|
| "Export template not found" | Godot → Editor → Manage Export Templates → Download 4.7 |
| GDExtension not in export | Check .gdextension has all platform entries |
| WASM memory error | Increase `initial_memory` in export preset |
| Android keystore error | Generate keystore: `keytool -genkey -v -keystore release.keystore` |
| macOS codesign failed | `codesign --force --deep --sign "Developer ID Application" build/macos/blink-arcana.app` |
| Missing DLLs on Windows | Ensure `blink_gdext.dll` in `addons/blink_core/bin/` |

---

## Post-Deploy Verification
```bash
# Linux
./build/linux/blink-arcana --headless --quit  # Should exit 0

# Windows (via Wine)
wine build/windows/blink-arcana.exe --headless --quit

# Web
cd build/web && python3 -m http.server 8080
# Open http://localhost:8080

# Android
adb install build/android/blink-arcana.apk
adb shell am start -n org.godotengine.blinkarcana/.GodotApp
```

---

## Related Runbooks
- `dev_setup.md` — Initial setup
- `gdextension_debug.md` — GDExtension issues
- `ci_cd_debug.md` — CI/CD pipeline issues
