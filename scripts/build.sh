#!/usr/bin/env bash
# Build script for local development and CI
# Usage: ./scripts/build.sh [debug|release] [target]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

PROFILE="${1:-release}"
TARGET="${2:-}"

echo "=== Building Blink Arcana ==="
echo "Profile: $PROFILE"
echo "Target: ${TARGET:-host}"

# Build Rust workspace
echo "--- Building Rust workspace"
if [ -n "$TARGET" ]; then
    cargo build --profile "$PROFILE" --target "$TARGET" --workspace
else
    cargo build --profile "$PROFILE" --workspace
fi

# Copy GDExtension to Godot addons
echo "--- Copying GDExtension to Godot"
mkdir -p godot/addons/blink_core/bin/

if [ -n "$TARGET" ]; then
    TARGET_DIR="target/$TARGET/$PROFILE"
else
    TARGET_DIR="target/$PROFILE"
fi

# Linux
if [ -f "$TARGET_DIR/libblink_gdext.so" ]; then
    cp "$TARGET_DIR/libblink_gdext.so" godot/addons/blink_core/bin/
    echo "Copied libblink_gdext.so"
fi

# macOS
if [ -f "$TARGET_DIR/libblink_gdext.dylib" ]; then
    cp "$TARGET_DIR/libblink_gdext.dylib" godot/addons/blink_core/bin/
    echo "Copied libblink_gdext.dylib"
fi

# Windows
if [ -f "$TARGET_DIR/blink_gdext.dll" ]; then
    cp "$TARGET_DIR/blink_gdext.dll" godot/addons/blink_core/bin/
    echo "Copied blink_gdext.dll"
fi

# WebAssembly
if [ -f "$TARGET_DIR/blink_gdext.wasm" ]; then
    cp "$TARGET_DIR/blink_gdext.wasm" godot/addons/blink_core/bin/
    echo "Copied blink_gdext.wasm"
fi

# Android (arm64)
if [ -f "$TARGET_DIR/libblink_gdext.so" ] && [[ "$TARGET" == *"android"* ]]; then
    cp "$TARGET_DIR/libblink_gdext.so" "godot/addons/blink_core/bin/libblink_gdext_${TARGET}.so"
    echo "Copied Android libblink_gdext.so"
fi

echo "=== Build complete ==="
