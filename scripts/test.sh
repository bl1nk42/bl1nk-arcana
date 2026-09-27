#!/usr/bin/env bash
# Test script for local development and CI
# Usage: ./scripts/test.sh [unit|integration|all]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

TEST_TYPE="${1:-all}"

echo "=== Testing Blink Arcana ==="
echo "Test type: $TEST_TYPE"

# Rust tests
if [[ "$TEST_TYPE" == "unit" || "$TEST_TYPE" == "all" ]]; then
    echo "--- Running Rust unit tests"
    cargo test --workspace --all-features -- --test-threads=4
fi

# Integration tests (Godot headless)
if [[ "$TEST_TYPE" == "integration" || "$TEST_TYPE" == "all" ]]; then
    echo "--- Running Godot headless tests"

    # Build debug first for testing
    cargo build --profile dev --workspace

    # Copy to Godot
    mkdir -p godot/addons/blink_core/bin/
    cp target/debug/libblink_gdext.so godot/addons/blink_core/bin/ 2>/dev/null || true
    cp target/debug/libblink_gdext.dylib godot/addons/blink_core/bin/ 2>/dev/null || true
    cp target/debug/blink_gdext.dll godot/addons/blink_core/bin/ 2>/dev/null || true

    # Run Godot script check
    if command -v godot &> /dev/null; then
        godot --headless --script-check godot/project.godot
        echo "Godot script check passed"
    else
        echo "Godot not found, skipping headless test"
    fi
fi

# Clippy
if [[ "$TEST_TYPE" == "lint" || "$TEST_TYPE" == "all" ]]; then
    echo "--- Running Clippy"
    cargo clippy --all-targets --all-features -- -D warnings
fi

# Format check
if [[ "$TEST_TYPE" == "fmt" || "$TEST_TYPE" == "all" ]]; then
    echo "--- Checking format"
    cargo fmt --all -- --check
fi

echo "=== All tests passed ==="
