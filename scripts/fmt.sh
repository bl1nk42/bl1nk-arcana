#!/usr/bin/env bash
# Format all code
# Usage: ./scripts/fmt.sh [check]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

CHECK_ONLY="${1:-}"

echo "=== Formatting Code ==="

# Rust
if [[ "$CHECK_ONLY" == "check" ]]; then
    cargo fmt --all -- --check
else
    cargo fmt --all
fi

# GDScript
if command -v gdformat &> /dev/null; then
    if [[ "$CHECK_ONLY" == "check" ]]; then
        gdformat --check godot/scripts/
    else
        gdformat godot/scripts/
    fi
else
    echo "gdformat not installed, skipping GDScript format"
fi

# TOML
if command -v taplo &> /dev/null; then
    if [[ "$CHECK_ONLY" == "check" ]]; then
        taplo fmt --check **/*.toml
    else
        taplo fmt **/*.toml
    fi
else
    echo "taplo not installed, skipping TOML format"
fi

# Protobuf
if command -v clang-format &> /dev/null; then
    find proto -name "*.proto" -exec clang-format -i {} \;
fi

echo "=== Format complete ==="
