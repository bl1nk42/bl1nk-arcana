#!/usr/bin/env bash
# Validate referenced Godot assets and report an inventory.
# Usage: ./scripts/asset-check.sh [project-root]
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${1:-$(cd -- "$SCRIPT_DIR/.." && pwd)}"
GODOT_DIR="$PROJECT_ROOT/godot"
ASSETS_DIR="$GODOT_DIR/assets"

if [[ ! -d "$GODOT_DIR" ]]; then
  printf 'ERROR: Godot project directory not found: %s\n' "$GODOT_DIR" >&2
  exit 2
fi

python3 - "$GODOT_DIR" "$ASSETS_DIR" <<'PY'
from collections import Counter
from pathlib import Path
import re
import sys

root = Path(sys.argv[1])
assets = Path(sys.argv[2])
if not assets.is_dir():
    print(f"ERROR: Assets directory not found: {assets}")
    raise SystemExit(2)

asset_refs = re.compile(r"res://assets/([^\"'\s)]+)")
asset_files = {p.resolve() for p in assets.rglob("*") if p.is_file()}
missing: list[tuple[Path, str]] = []
source_files = [p for p in root.rglob("*") if p.is_file() and p.suffix.lower() in {".tscn", ".tres", ".gd", ".godot", ".cfg"}]
for source in source_files:
    try:
        text = source.read_text(encoding="utf-8")
    except (OSError, UnicodeError):
        continue
    for match in asset_refs.finditer(text):
        relative = match.group(1)
        if "%" in relative or "$" in relative or "{" in relative:
            continue  # A runtime path template, not a literal asset reference.
        target = (root / "assets" / relative).resolve()
        if not target.is_file():
            missing.append((source, "res://assets/" + relative))

print("Blink Arcana asset validation")
print(f"Godot project: {root}")
print(f"Asset files: {len(asset_files)}")
print(f"Source files scanned: {len(source_files)}")
if missing:
    for source, ref in missing:
        print(f"MISSING: {source.relative_to(root)} -> {ref}")
    print(f"FAILED: {len(missing)} missing asset reference(s)")
    raise SystemExit(1)
print("PASS: no missing asset references")

counts = Counter(p.relative_to(assets).parts[0] if len(p.relative_to(assets).parts) > 1 else "(root)" for p in asset_files)
print("Asset inventory:")
for category in ("sprites", "ui", "maps", "fonts", "audio"):
    print(f"  {category}: {counts.get(category, 0)} file(s)")
for category, count in sorted(counts.items()):
    if category not in {"sprites", "ui", "maps", "fonts", "audio", "(root)"}:
        print(f"  {category}: {count} file(s)")
PY
