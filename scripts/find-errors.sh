#!/bin/bash
# find-errors.sh - Find and categorize common Rust/GDScript errors
# Usage: ./scripts/find-errors.sh [path]

PROJECT_ROOT="${1:-$(pwd)}"
RUST_DIR="$PROJECT_ROOT/rust"
GODOT_DIR="$PROJECT_ROOT/godot"

echo "═══ Error Finder for Blink Arcana ═══"
echo "Project: $PROJECT_ROOT"
echo ""

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print section header
section() {
    echo -e "${BLUE}▶ $1${NC}"
}

# Function to print error
error() {
    echo -e "${RED}  ✗ $1${NC}"
}

# Function to print warning
warning() {
    echo -e "${YELLOW}  ⚠ $1${NC}"
}

# Function to print success
success() {
    echo -e "${GREEN}  ✓ $1${NC}"
}

# Check Rust unwrap/expect/panic usage
section "Checking for unwrap()/expect()/panic! in Rust..."
UNWRAP_COUNT=$(grep -r "\.unwrap()" "$RUST_DIR/crates" --include="*.rs" 2>/dev/null | grep -v "// " | grep -v "#\[cfg(test)\]" | grep -v "test" | wc -l)
EXPECT_COUNT=$(grep -r "\.expect(" "$RUST_DIR/crates" --include="*.rs" 2>/dev/null | grep -v "// " | grep -v "#\[cfg(test)\]" | grep -v "test" | wc -l)
PANIC_COUNT=$(grep -r "panic!" "$RUST_DIR/crates" --include="*.rs" 2>/dev/null | grep -v "// " | grep -v "#\[cfg(test)\]" | grep -v "test" | wc -l)

if [ "$UNWRAP_COUNT" -gt 0 ]; then
    error "Found $UNWRAP_COUNT .unwrap() calls (non-test)"
    grep -r "\.unwrap()" "$RUST_DIR/crates" --include="*.rs" 2>/dev/null | grep -v "// " | grep -v "#\[cfg(test)\]" | grep -v "test" | head -5
else
    success "No .unwrap() in production code"
fi

if [ "$EXPECT_COUNT" -gt 0 ]; then
    error "Found $EXPECT_COUNT .expect() calls (non-test)"
    grep -r "\.expect(" "$RUST_DIR/crates" --include="*.rs" 2>/dev/null | grep -v "// " | grep -v "#\[cfg(test)\]" | grep -v "test" | head -5
else
    success "No .expect() in production code"
fi

if [ "$PANIC_COUNT" -gt 0 ]; then
    error "Found $PANIC_COUNT panic! calls (non-test)"
    grep -r "panic!" "$RUST_DIR/crates" --include="*.rs" 2>/dev/null | grep -v "// " | grep -v "#\[cfg(test)\]" | grep -v "test" | head -5
else
    success "No panic! in production code"
fi

echo ""

# Check for TODO/FIXME in specs
section "Checking for TODO/FIXME in Spec Sheets..."
TODO_COUNT=$(grep -r "TODO\|FIXME" "$PROJECT_ROOT/docs/SPECS" --include="*.md" 2>/dev/null | wc -l)
if [ "$TODO_COUNT" -gt 0 ]; then
    warning "Found $TODO_COUNT TODO/FIXME in specs"
    grep -r "TODO\|FIXME" "$PROJECT_ROOT/docs/SPECS" --include="*.md" 2>/dev/null | head -5
else
    success "No TODO/FIXME in specs"
fi

echo ""

# Check for missing spec sections
section "Validating Spec Sheets..."
for spec in "$PROJECT_ROOT/docs/SPECS"/*.md; do
    if [ -f "$spec" ]; then
        name=$(basename "$spec")
        missing=""
        for req in "## 1. Overview" "## 2. Scope" "## 3. Data Structures" "## 4." "## 5. Error Types" "## 6. Testing Requirements" "## 7. Integration Points"; do
            if ! grep -q "$req" "$spec"; then
                missing="$missing $req"
            fi
        done
        if [ -n "$missing" ]; then
            warning "$name missing sections:$missing"
        else
            success "$name - all required sections present"
        fi
    fi
done

echo ""

# Check GDScript common issues
section "Checking GDScript common issues..."
if [ -d "$GODOT_DIR/scripts" ]; then
    # Missing type hints
    NO_TYPE=$(grep -r "var [a-z_][a-z0-9_]* =" "$GODOT_DIR/scripts" --include="*.gd" 2>/dev/null | grep -v ":" | grep -v "@export" | wc -l)
    if [ "$NO_TYPE" -gt 0 ]; then
        warning "Found $NO_TYPE variables without type hints"
    else
        success "All variables have type hints"
    fi

    # Missing early returns (simple heuristic)
    NO_EARLY=$(grep -r "if .*:" "$GODOT_DIR/scripts" --include="*.gd" 2>/dev/null | grep -v "return" | grep -v "elif" | grep -v "else" | wc -l)
    if [ "$NO_EARLY" -gt 0 ]; then
        warning "Found $NO_EARLY if blocks without early return (check manually)"
    fi

    # Signal naming
    BAD_SIGNALS=$(grep -r "signal " "$GODOT_DIR/scripts" --include="*.gd" 2>/dev/null | grep -v "_[a-z]" | grep -v "^signal [a-z_][a-z0-9_]*$" | wc -l)
    if [ "$BAD_SIGNALS" -gt 0 ]; then
        warning "Found $BAD_SIGNALS signals not in snake_case"
    fi
else
    warning "Godot scripts directory not found"
fi

echo ""

# Check for conventional commit format in recent commits
section "Checking recent commit messages..."
cd "$PROJECT_ROOT"
RECENT=$(git log --oneline -10 --pretty=format:"%s" 2>/dev/null || echo "")
if [ -n "$RECENT" ]; then
    BAD_COMMITS=0
    while IFS= read -r commit; do
        if ! echo "$commit" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\(.+\))?: .+"; then
            error "Non-conventional: $commit"
            BAD_COMMITS=$((BAD_COMMITS + 1))
        fi
    done <<< "$RECENT"
    if [ "$BAD_COMMITS" -eq 0 ]; then
        success "All recent commits follow Conventional Commits"
    fi
fi

echo ""

# Check for large files
section "Checking for large files (>10MB)..."
LARGE_FILES=$(find "$PROJECT_ROOT" -type f -size +10M 2>/dev/null | grep -v ".git" | grep -v "target/" | grep -v "node_modules" | head -5)
if [ -n "$LARGE_FILES" ]; then
    warning "Large files found:"
    echo "$LARGE_FILES"
else
    success "No large files"
fi

echo ""

# Summary
section "Summary"
TOTAL_ISSUES=$((UNWRAP_COUNT + EXPECT_COUNT + PANIC_COUNT + TODO_COUNT + BAD_COMMITS))
if [ "$TOTAL_ISSUES" -eq 0 ]; then
    success "No critical issues found!"
else
    error "Total issues found: $TOTAL_ISSUES"
    echo "Run 'blink check' to run full quality gates"
fi
