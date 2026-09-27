# Runbook: Development Environment Setup
**Version:** 1.0
**Last Updated:** 2026-09-27
**Owner:** Lead Developer

---

## Purpose
Complete setup of Blink Arcana development environment on a new machine.

---

## Prerequisites
- Linux/macOS/Windows (WSL2)
- Git 2.40+
- Docker 24.0+
- 16GB+ RAM recommended
- 20GB+ disk space

---

## Step-by-Step

### 1. Clone Repository
```bash
git clone https://github.com/bl1nk-team/bl1nk-arcana.git
cd bl1nk-arcana
```

### 2. Install Rust Toolchain
```bash
# Via rustup (recommended)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup toolchain install 1.98.1
rustup default 1.98.1
rustup component add rustfmt clippy
rustup target add wasm32-unknown-unknown x86_64-pc-windows-msvc aarch64-linux-android armv7-linux-androideabi
```

### 3. Install Cargo Tools
```bash
cargo install cargo-generate cargo-audit cargo-deny cargo-udeps prost-build cargo-nextest cargo-sweep cargo-outdated
```

### 4. Install Just (Task Runner)
```bash
# Linux/macOS
cargo install just

# Or via package manager
# apt install just
# brew install just
```

### 5. Install Godot 4.7
```bash
# Linux (Flatpak)
flatpak install flathub org.godotengine.Godot

# Linux (Official)
wget https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_linux.x86_64.zip
unzip Godot_v4.3-stable_linux.x86_64.zip -d ~/.local/bin/
ln -s ~/.local/bin/Godot_v4.3-stable_linux.x86_64 ~/.local/bin/godot

# macOS
brew install --cask godot

# Windows
# Download from https://godotengine.org/download/windows/
```

### 6. Install Node.js (for MCP servers)
```bash
# Via fnm (recommended)
curl -fsSL https://fnm.vercel.app/install | bash
fnm install 20
fnm use 20

# Or nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
```

### 7. Install Python Tools (for CI/GDScript)
```bash
pip install gdformat gdlint typos-cli taplo
```

### 8. Environment Variables
```bash
cp .env.example .env
# Edit .env with your values
```

### 9. Verify Setup
```bash
# Check all tools
just --list
rustc --version        # Should be 1.98.1
cargo --version
godot --version        # Should be 4.3 (Godot 4.7)
docker --version
node --version         # Should be 20+

# Run setup
just setup

# Build test
just build-debug

# Open Godot
just godot
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `cargo: command not found` | `source "$HOME/.cargo/env"` or restart shell |
| `godot: command not found` | Add Godot to PATH |
| `just: command not found` | Install just via cargo or package manager |
| Rust version mismatch | `rustup default 1.98.1` |
| Godot export fails | Check export templates installed |
| Docker build fails | Check Docker daemon running |

---

## Verification Checklist
- [ ] `just build-debug` succeeds
- [ ] `just test` passes
- [ ] `just godot` opens editor
- [ ] Godot project loads without errors
- [ ] GDExtension appears in Project → Project Settings → Extensions
- [ ] Can run battle scene
