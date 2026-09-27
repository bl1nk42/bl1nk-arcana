# Justfile — Task Runner for Blink Arcana
# Usage: just <command> [args...]
# List all: just --list

# --- Variables ---
RUST_VERSION := "1.98.1"
EDITION := "2024"
GODOT_PROJECT := "godot"
RUST_WORKSPACE := "rust"
BUILD_PROFILE := "release"

# --- Setup ---
setup:
	@echo "=== Installing Dev Tools ==="
	rustup toolchain install {{RUST_VERSION}} --component rustfmt clippy
	rustup default {{RUST_VERSION}}
	rustup target add wasm32-unknown-unknown x86_64-pc-windows-msvc aarch64-linux-android armv7-linux-androideabi
	cargo install cargo-generate cargo-audit cargo-deny cargo-udeps prost-build cargo-nextest
	# Godot 4.x (install manually or via package manager)
	@echo "=== Setup complete ==="

setup-ci:
	@echo "=== CI Setup ==="
	rustup toolchain install {{RUST_VERSION}} --component rustfmt clippy
	rustup default {{RUST_VERSION}}
	rustup target add wasm32-unknown-unknown
	cargo install cargo-generate cargo-audit cargo-deny cargo-udeps prost-build cargo-nextest --locked

# --- Format ---
fmt:
	@echo "=== Formatting Rust ==="
	cd {{RUST_WORKSPACE}} && cargo fmt --all
	@echo "=== Formatting GDScript ==="
	gdformat -r {{GODOT_PROJECT}}/scripts/
	@echo "=== Formatting TOML ==="
	taplo fmt **/*.toml

fmt-check:
	@echo "=== Checking Format ==="
	cd {{RUST_WORKSPACE}} && cargo fmt --all -- --check
	gdformat --check {{GODOT_PROJECT}}/scripts/
	taplo fmt --check **/*.toml

# --- Lint ---
lint:
	@echo "=== Linting Rust ==="
	cd {{RUST_WORKSPACE}} && cargo clippy --all-targets --all-features -- -D warnings
	@echo "=== Linting GDScript ==="
	gdlint -r {{GODOT_PROJECT}}/scripts/
	@echo "=== Spell Check ==="
	typos .

lint-rust:
	cd {{RUST_WORKSPACE}} && cargo clippy --all-targets --all-features -- -D warnings

lint-godot:
	gdlint -r {{GODOT_PROJECT}}/scripts/

# --- Quality Gates ---
quality: fmt lint
	@echo "=== Quality Gates Passed ==="

# --- Build ---
build:
	@echo "=== Building Rust Workspace ({{BUILD_PROFILE}}) ==="
	cd {{RUST_WORKSPACE}} && cargo build --profile {{BUILD_PROFILE}} --workspace
	@echo "=== Copying GDExtension to Godot ==="
	mkdir -p {{GODOT_PROJECT}}/addons/blink_core/bin
	cp {{RUST_WORKSPACE}}/target/{{BUILD_PROFILE}}/libblink_gdext.so {{GODOT_PROJECT}}/addons/blink_core/bin/ 2>/dev/null || \
	cp {{RUST_WORKSPACE}}/target/{{BUILD_PROFILE}}/libblink_gdext.dylib {{GODOT_PROJECT}}/addons/blink_core/bin/ 2>/dev/null || \
	cp {{RUST_WORKSPACE}}/target/{{BUILD_PROFILE}}/blink_gdext.dll {{GODOT_PROJECT}}/addons/blink_core/bin/ 2>/dev/null
	@echo "=== Build complete ==="

build-debug:
	@echo "=== Building Debug ==="
	cd {{RUST_WORKSPACE}} && cargo build --profile dev --workspace
	@echo "=== Copying GDExtension to Godot ==="
	mkdir -p {{GODOT_PROJECT}}/addons/blink_core/bin
	cp {{RUST_WORKSPACE}}/target/debug/libblink_gdext.so {{GODOT_PROJECT}}/addons/blink_core/bin/ 2>/dev/null || \
	cp {{RUST_WORKSPACE}}/target/debug/libblink_gdext.dylib {{GODOT_PROJECT}}/addons/blink_core/bin/ 2>/dev/null || \
	cp {{RUST_WORKSPACE}}/target/debug/blink_gdext.dll {{GODOT_PROJECT}}/addons/blink_core/bin/ 2>/dev/null
	@echo "=== Debug Build complete ==="

build-all-targets:
	@echo "=== Building All Targets ==="
	cd {{RUST_WORKSPACE}} && cargo build --release --workspace
	cd {{RUST_WORKSPACE}} && cargo build --release --target wasm32-unknown-unknown -p blink-gdext
	cd {{RUST_WORKSPACE}} && cargo build --release --target x86_64-pc-windows-msvc -p blink-gdext 2>/dev/null || echo "Windows target not available"
	cd {{RUST_WORKSPACE}} && cargo build --release --target aarch64-linux-android -p blink-gdext
	cd {{RUST_WORKSPACE}} && cargo build --release --target armv7-linux-androideabi -p blink-gdext
	@echo "=== Copying all GDExtension binaries ==="
	mkdir -p {{GODOT_PROJECT}}/addons/blink_core/bin
	cp {{RUST_WORKSPACE}}/target/release/libblink_gdext.so {{GODOT_PROJECT}}/addons/blink_core/bin/ 2>/dev/null || true
	cp {{RUST_WORKSPACE}}/target/release/libblink_gdext.dylib {{GODOT_PROJECT}}/addons/blink_core/bin/ 2>/dev/null || true
	cp {{RUST_WORKSPACE}}/target/release/blink_gdext.dll {{GODOT_PROJECT}}/addons/blink_core/bin/ 2>/dev/null || true
	cp {{RUST_WORKSPACE}}/target/wasm32-unknown-unknown/release/blink_gdext.wasm {{GODOT_PROJECT}}/addons/blink_core/bin/ 2>/dev/null || true
	cp {{RUST_WORKSPACE}}/target/aarch64-linux-android/release/libblink_gdext.so {{GODOT_PROJECT}}/addons/blink_core/bin/libblink_gdext_arm64.so 2>/dev/null || true
	cp {{RUST_WORKSPACE}}/target/armv7-linux-androideabi/release/libblink_gdext.so {{GODOT_PROJECT}}/addons/blink_core/bin/libblink_gdext_arm32.so 2>/dev/null || true
	@echo "=== Multi-target build complete ==="

# --- Protobuf ---
proto:
	@echo "=== Generating Protobuf ==="
	cd {{RUST_WORKSPACE}}/crates/blink-proto && cargo build

# --- Test ---
test:
	@echo "=== Running Rust Tests ==="
	cd {{RUST_WORKSPACE}} && cargo nextest run --workspace --all-features

test-rust:
	cd {{RUST_WORKSPACE}} && cargo test --workspace --all-features

test-godot:
	@echo "=== Godot Headless Check ==="
	godot --headless --script-check {{GODOT_PROJECT}}/project.godot

test-all: test test-godot
	@echo "=== All Tests Complete ==="

# --- Security ---
audit:
	@echo "=== Security Audit ==="
	cargo audit
	cargo deny check

# --- Godot ---
godot:
	godot {{GODOT_PROJECT}}/project.godot

godot-export-linux: build
	@echo "=== Exporting Linux ==="
	mkdir -p build/linux
	godot --headless --export-release "Linux/X11" build/linux/blink-arcana

godot-export-windows: build
	@echo "=== Exporting Windows ==="
	mkdir -p build/windows
	godot --headless --export-release "Windows Desktop" build/windows/blink-arcana.exe

godot-export-macos: build
	@echo "=== Exporting macOS ==="
	mkdir -p build/macos
	godot --headless --export-release "macOS" build/macos/blink-arcana.dmg

godot-export-web: build
	@echo "=== Exporting Web ==="
	cd {{RUST_WORKSPACE}} && cargo build --release --target wasm32-unknown-unknown -p blink-gdext
	mkdir -p build/web
	cp {{RUST_WORKSPACE}}/target/wasm32-unknown-unknown/release/blink_gdext.wasm {{GODOT_PROJECT}}/addons/blink_core/bin/
	godot --headless --export-release "Web" build/web/

godot-export-android: build
	@echo "=== Exporting Android ==="
	cd {{RUST_WORKSPACE}} && cargo build --release --target aarch64-linux-android -p blink-gdext
	cd {{RUST_WORKSPACE}} && cargo build --release --target armv7-linux-androideabi -p blink-gdext
	mkdir -p build/android
	cp {{RUST_WORKSPACE}}/target/aarch64-linux-android/release/libblink_gdext.so {{GODOT_PROJECT}}/addons/blink_core/bin/libblink_gdext_arm64.so
	cp {{RUST_WORKSPACE}}/target/armv7-linux-androideabi/release/libblink_gdext.so {{GODOT_PROJECT}}/addons/blink_core/bin/libblink_gdext_arm32.so
	godot --headless --export-release "Android" build/android/blink-arcana.apk

godot-export-all: godot-export-linux godot-export-windows godot-export-macos godot-export-web godot-export-android
	@echo "=== All exports complete ==="

# --- Docker ---
docker-build:
	@echo "=== Building Docker Image ==="
	docker build -t blink-arcana:latest -f docker/Dockerfile .

docker-run:
	docker run --rm -it blink-arcana:latest

docker-dev:
	docker run --rm -it -v $(pwd):/app blink-arcana:dev

# --- Pre-commit ---
precommit: quality
	@echo "=== Pre-commit checks passed ==="

# --- CI Check ---
ci-check:
	@echo "=== Simulating CI Pipeline ==="
	just fmt-check
	just lint
	just test
	just build
	just audit
	@echo "=== CI Check Complete ==="

# --- Clean ---
clean:
	cargo clean
	rm -rf {{GODOT_PROJECT}}/addons/blink_core/bin/*
	rm -rf build/

clean-dev: clean
	rm -rf ~/.cargo/registry/cache/*
	rm -rf ~/.cargo/git/checkouts/*
	cargo sweep --max-days 0 2>/dev/null || true
	@echo "=== Dev cache cleaned ==="

clean-all: clean-dev
	rm -rf target/
	rm -rf {{RUST_WORKSPACE}}/target/
	rm -rf ~/.cargo/registry/cache/*
	rm -rf ~/.cargo/git/checkouts/*
	@echo "=== Complete cleanup done ==="

# --- Docker Clean ---
docker-clean:
	docker system prune -f
	docker builder prune -f
	@echo "=== Docker cleaned ==="

# --- Helper Scripts ---
find-errors:
	@echo "=== Finding Errors ==="
	./scripts/find-errors.sh

fmt-fix:
	@echo "=== Auto-fixing Format ==="
	./scripts/fmt-fix.sh

# --- Asset Pipeline ---
asset-check:
	@echo "=== Checking Assets ==="
	./scripts/asset-check.sh

asset-manifest:
	@echo "=== Generating Asset Manifest ==="
	./scripts/asset-manifest.sh

# --- Generate ---
gen-proto:
	@echo "=== Regenerating Protobuf ==="
	cd {{RUST_WORKSPACE}}/crates/blink-proto && cargo build

# --- Docs ---
docs:
	cd {{RUST_WORKSPACE}} && cargo doc --all-features --no-deps --open

# --- Check outdated ---
outdated:
	cargo outdated -w

# --- Update ---
update:
	cargo update -w