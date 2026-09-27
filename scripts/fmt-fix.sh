#!/bin/bash
# fmt-fix.sh - Auto-fix common formatting issues
# Usage: ./scripts/fmt-fix.sh [path]

set -euo pipefail

PROJECT_ROOT="${1:-$(pwd)}"
RUST_DIR="$PROJECT_ROOT/rust"
GODOT_DIR="$PROJECT_ROOT/godot"

echo "═══ Format Fixer for Blink Arcana ═══"
echo "Project: $PROJECT_ROOT"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

section() {
    echo -e "${BLUE}▶ $1${NC}"
}

success() {
    echo -e "${GREEN}  ✓ $1${NC}"
}

warning() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
}

# 1. Rust formatting
section "Formatting Rust code..."
cd "$RUST_DIR"
cargo fmt --all
success "Rust formatted"

# 2. TOML formatting
section "Formatting TOML files..."
cd "$PROJECT_ROOT"
if command -v taplo &> /dev/null; then
    taplo fmt **/*.toml
    success "TOML formatted"
else
    warning "taplo not installed, skipping TOML formatting"
fi

# 3. GDScript formatting
section "Formatting GDScript..."
if [ -d "$GODOT_DIR/scripts" ]; then
    if command -v gdformat &> /dev/null; then
        gdformat -r "$GODOT_DIR/scripts/"
        success "GDScript formatted"
    else
        warning "gdformat not installed, skipping GDScript formatting"
    fi
else
    echo "  Godot scripts directory not found, skipping"
fi

# 4. Fix common Rust issues automatically
section "Applying Clippy fixes (safe only)..."
cd "$RUST_DIR"
cargo clippy --all-targets --all-features --fix --allow-dirty --allow-staged -p blink-core -p blink-proto -p blink-gdext -p blink-cli 2>/dev/null || true
success "Clippy fixes applied"

# 5. Remove trailing whitespace
section "Removing trailing whitespace..."
find "$PROJECT_ROOT" -type f \( -name "*.rs" -o -name "*.gd" -o -name "*.toml" -o -name "*.md" -o -name "*.sh" -o -name "*.yaml" -o -name "*.yml" \) \
    -not -path "*/target/*" -not -path "*/.git/*" -not -path "*/node_modules/*" \
    -exec sed -i 's/[[:space:]]*$//' {} \;
success "Trailing whitespace removed"

# 6. Ensure newline at end of file
section "Ensuring newline at end of files..."
find "$PROJECT_ROOT" -type f \( -name "*.rs" -o -name "*.gd" -o -name "*.toml" -o -name "*.md" -o -name "*.sh" -o -name "*.yaml" -o -name "*.yml" \) \
    -not -path "*/target/*" -not -path "*/.git/*" -not -path "*/node_modules/*" \
    -exec sh -c 'tail -c1 "$1" | read _ || echo >> "$1"' _ {} \;
success "Newlines ensured"

# 7. Sort imports (Rust)
section "Sorting Rust imports..."
cd "$RUST_DIR"
cargo fmt --all -- --config imports_granularity=crate --config group_imports=StdExternalCrate 2>/dev/null || true
success "Imports sorted"

echo ""
echo "═══ Format Fix Complete ═══"
echo "Run 'blink check' to verify all quality gates pass"
