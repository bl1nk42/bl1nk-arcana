#!/usr/bin/env bash
# Lint all code
# Usage: ./scripts/lint.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Linting Code ==="

# Rust Clippy
echo "--- Clippy"
cargo clippy --all-targets --all-features -- -D warnings

# GDScript lint
if command -v gdlint &> /dev/null; then
    echo "--- GDLint"
    gdlint godot/scripts/
else
    echo "gdlint not installed, skipping"
fi

# Spell check
if command -v typos &> /dev/null; then
    echo "--- Typos"
    typos .
else
    echo "typos not installed, skipping"
fi

# Security audit
if command -v cargo-audit &> /dev/null; then
    echo "--- Cargo Audit"
    cargo audit
else
    echo "cargo-audit not installed, skipping"
fi

if command -v cargo-deny &> /dev/null; then
    echo "--- Cargo Deny"
    cargo deny check
else
    echo "cargo-deny not installed, skipping"
fi

echo "=== Lint complete ==="
