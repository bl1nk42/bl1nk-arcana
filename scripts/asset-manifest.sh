#!/bin/bash
# asset-manifest.sh - Generate asset manifest JSON
# Usage: ./scripts/asset-manifest.sh [path]

set -euo pipefail

PROJECT_ROOT="${1:-$(pwd)}"
GODOT_DIR="$PROJECT_ROOT/godot"
ASSETS_DIR="$GODOT_DIR/assets"
MANIFEST_FILE="$PROJECT_ROOT/godot/assets/manifest.json"

echo "═══ Asset Manifest Generator ═══"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

section() {
    echo -e "${BLUE}▶ $1${NC}"
}

success() {
    echo -e "${GREEN}  ✓ $1${NC}"
}

# Create manifest JSON
cat > "$MANIFEST_FILE" << 'EOF'
{
  "version": "1.0",
  "generated": "",
  "assets": {
    "sprites": [],
    "ui": [],
    "maps": [],
    "fonts": []
  }
}
EOF

# Update timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
sed -i "s/\"generated\": \"\"/\"generated\": \"$TIMESTAMP\"/" "$MANIFEST_FILE"

# Helper to add asset to manifest
add_asset() {
    local category="$1"
    local filepath="$2"
    local filename=$(basename "$filepath")
    local name="${filename%.*}"
    local ext="${filename##*.}"
    local size=$(stat -c%s "$filepath" 2>/dev/null || stat -f%z "$filepath" 2>/dev/null)
    local modified=$(stat -c%Y "$filepath" 2>/dev/null || stat -f%m "$filepath" 2>/dev/null)
    local rel_path="${filepath#$GODOT_DIR/}"

    # Create JSON entry
    local entry="{\"name\": \"$name\", \"filename\": \"$filename\", \"path\": \"$rel_path\", \"size\": $size, \"modified\": $modified, \"extension\": \"$ext\"}"

    # Add to manifest using jq if available, otherwise manual
    if command -v jq &> /dev/null; then
        jq ".assets.$category += [$entry]" "$MANIFEST_FILE" > "$MANIFEST_FILE.tmp" && mv "$MANIFEST_FILE.tmp" "$MANIFEST_FILE"
    else
        # Manual insertion (simplified)
        sed -i "s/\"$category\": \[\]/\"$category\": [$entry]/" "$MANIFEST_FILE"
        # For multiple entries, this won't work perfectly without jq
    fi
}

# Process sprites
section "Processing sprites..."
for f in "$ASSETS_DIR/sprites"/*; do
    if [ -f "$f" ]; then
        add_asset "sprites" "$f"
    fi
done

# Process UI
section "Processing UI assets..."
for f in "$ASSETS_DIR/ui"/*; do
    if [ -f "$f" ]; then
        add_asset "ui" "$f"
    fi
done

# Process maps
section "Processing maps..."
for f in "$ASSETS_DIR/maps"/*; do
    if [ -f "$f" ]; then
        add_asset "maps" "$f"
    fi
done

# Process fonts
section "Processing fonts..."
for f in "$ASSETS_DIR/fonts"/*; do
    if [ -f "$f" ]; then
        add_asset "fonts" "$f"
    fi
done

# If jq not available, create simplified manifest
if ! command -v jq &> /dev/null; then
    cat > "$MANIFEST_FILE" << EOF
{
  "version": "1.0",
  "generated": "$TIMESTAMP",
  "assets": {
    "sprites": $(find "$ASSETS_DIR/sprites" -type f -printf '{"name": "%f", "path": "assets/sprites/%f", "size": %s},\n' 2>/dev/null | sed '$s/,$//' | paste -sd '' || echo '[]'),
    "ui": $(find "$ASSETS_DIR/ui" -type f -printf '{"name": "%f", "path": "assets/ui/%f", "size": %s},\n' 2>/dev/null | sed '$s/,$//' | paste -sd '' || echo '[]'),
    "maps": $(find "$ASSETS_DIR/maps" -type f -printf '{"name": "%f", "path": "assets/maps/%f", "size": %s},\n' 2>/dev/null | sed '$s/,$//' | paste -sd '' || echo '[]'),
    "fonts": $(find "$ASSETS_DIR/fonts" -type f -printf '{"name": "%f", "path": "assets/fonts/%f", "size": %s},\n' 2>/dev/null | sed '$s/,$//' | paste -sd '' || echo '[]')
  }
}
EOF
fi

success "Manifest generated: $MANIFEST_FILE"

# Print summary
echo ""
echo "═══ Asset Manifest Summary ═══"
if command -v jq &> /dev/null; then
    jq '.assets | to_entries[] | "\(.key): \(.value | length) files"' "$MANIFEST_FILE"
else
    for dir in sprites ui maps fonts; do
        count=$(find "$ASSETS_DIR/$dir" -type f 2>/dev/null | wc -l)
        echo "  $dir: $count files"
    done
fi
echo "Manifest: $MANIFEST_FILE"
