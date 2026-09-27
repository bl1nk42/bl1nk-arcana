# Asset Pipeline Documentation
**Version:** 1.0
**Last Updated:** 2026-09-27
**Owner:** Artist / Visual Designer

---

## Purpose
Define the asset creation, organization, and integration pipeline for Blink Arcana.

---

## Directory Structure
```
godot/assets/
├── sprites/          # Unit, Enemy, Effect sprites
│   ├── units/        # Player unit sprites (64x64 or 128x128)
│   ├── enemies/      # Enemy sprites
│   ├── effects/      # VFX sprites (hit, crit, miss, etc.)
│   └── portraits/    # Character portraits (256x256)
├── ui/               # UI assets
│   ├── icons/        # Skill, Item, Status icons (32x32, 64x64)
│   ├── hud/          # HUD elements (HP bar, MP bar, etc.)
│   ├── menus/        # Menu backgrounds, buttons
│   └── fonts/        # Custom fonts (.ttf, .otf)
├── maps/             # Map/Tilemap assets
│   ├── tilesets/     # TileSet resources (.tres)
│   ├── tilemaps/     # TileMap scenes (.tscn)
│   └── backgrounds/  # Parallax backgrounds
└── fonts/            # Font files
    └── *.ttf, *.otf
```

---

## Naming Conventions
| Asset Type | Convention | Example |
|------------|------------|---------|
| Sprites | `category_name_variant.ext` | `unit_alex_idle.png`, `enemy_goblin_attack.png` |
| UI Icons | `icon_category_name.ext` | `icon_skill_fireball.png`, `icon_item_potion.png` |
| UI Elements | `ui_element_state.ext` | `ui_hp_bar_full.png`, `ui_button_hover.png` |
| Portraits | `portrait_character.ext` | `portrait_alex.png` |
| Tilemaps | `map_chapter_area.ext` | `map_ch01_forest.tscn` |
| Fonts | `FontName-Style.ttf` | `NotoSans-Regular.ttf` |

**Rules:**
- ✅ lowercase with underscores (snake_case)
- ✅ descriptive names
- ✅ version suffix if needed (`_v2`, `_alt`)
- ❌ No spaces
- ❌ No uppercase
- ❌ No special characters except `_` and `-`

---

## Asset Specifications

### Unit Sprites
| Property | Value |
|----------|-------|
| Format | PNG (transparent background) |
| Size | 64x64 (standard), 128x128 (boss/large) |
| Frames | Idle (4), Walk (6-8), Attack (6-8), Hit (3), Death (6), Skill (8-12) |
| Naming | `unit_{name}_{animation}_{frame}.png` |
| Pivot | Center-bottom (feet) |

### Enemy Sprites
| Property | Value |
|----------|-------|
| Format | PNG |
| Size | 64x64 (standard), 96x96 (elite), 128x128 (boss) |
| Frames | Same as units |
| Naming | `enemy_{type}_{animation}_{frame}.png` |

### Effect Sprites
| Property | Value |
|----------|-------|
| Format | PNG (additive blending ready) |
| Size | 32x32 to 128x128 |
| Frames | 4-8 frames |
| Naming | `effect_{type}_{variant}_{frame}.png` |

### UI Icons
| Property | Value |
|----------|-------|
| Format | PNG (transparent) |
| Size | 32x32 (small), 64x64 (large) |
| Style | Consistent outline, color-coded by element |
| Naming | `icon_{category}_{name}.png` |

### Portraits
| Property | Value |
|----------|-------|
| Format | PNG |
| Size | 256x256 (display), 512x512 (source) |
| Style | Half-body, consistent lighting |
| Naming | `portrait_{character}.png` |

### Tilemaps
| Property | Value |
|----------|-------|
| Format | Godot TileMap (.tscn) + TileSet (.tres) |
| Grid | 32x32 or 64x64 |
| Layers | Ground, Decoration, Collision, Events |
| Naming | `tileset_{theme}.tres`, `map_{chapter}_{area}.tscn` |

---

## Import Settings (Godot)

### Sprites (2D)
```
Import → Texture
- Compress: Lossless (PNG)
- Detect 3D: Off
- Filter: On (for pixel art: Off, use Nearest)
- Mipmaps: Off
- Repeat: Disabled
- Size Limit: 2048
```

### UI Icons
```
Import → Texture
- Compress: Lossless
- Filter: Off (crisp edges)
- Mipmaps: Off
```

### TileSets
```
Import → TileSet
- Create Atlas: On
- Margin: 0
- Separation: 0
```

---

## Workflow

### 1. Creation (Artist)
1. Create asset in Aseprite/Photoshop/Krita
2. Export to `godot/assets/{category}/`
3. Follow naming convention
4. Run `just asset-check` to verify

### 2. Import (Godot)
1. Open Godot Editor
2. Assets auto-import (watch for import dialog)
3. Verify import settings in Import tab
4. Create TileSet/TileMap if needed

### 3. Reference (Developer)
1. Reference in scenes: `res://assets/sprites/unit_alex_idle.png`
2. Reference in resources: `preload("res://assets/ui/icon_skill_fireball.png")`
3. Run `just asset-manifest` to update manifest

### 4. Validation (CI)
```yaml
# CI step
- name: Check assets
  run: just asset-check
```

---

## Automation Scripts

| Script | Purpose | Command |
|--------|---------|---------|
| `asset-check.sh` | Find missing/unreferenced assets | `just asset-check` |
| `asset-manifest.sh` | Generate `manifest.json` | `just asset-manifest` |
| `fmt-fix.sh` | Fix formatting (includes asset naming) | `just fmt-fix` |

---

## Asset Manifest (`godot/assets/manifest.json`)
```json
{
  "version": "1.0",
  "generated": "2026-09-27T12:00:00Z",
  "assets": {
    "sprites": [
      {"name": "alex_idle", "path": "assets/sprites/units/alex_idle.png", "size": 4096, "modified": 1695000000}
    ],
    "ui": [...],
    "maps": [...],
    "fonts": [...]
  }
}
```

Use in code:
```gdscript
var manifest = load("res://assets/manifest.json")
var sprite_path = manifest.assets.sprites[0].path
```

---

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Asset not found in export | Not in `assets/` folder | Move to correct folder, reimport |
| Blurry sprites | Filter enabled | Disable Filter in Import settings |
| Large file size | Uncompressed PNG | Use lossless compression, optimize |
| Missing in manifest | Added after manifest gen | Run `just asset-manifest` |
| Naming convention violation | Manual rename | Run `just fmt-fix` or rename manually |

---

## Performance Budgets

| Category | Budget |
|----------|--------|
| Total sprites | < 500 MB |
| Single sprite | < 512 KB |
| UI atlas | < 2 MB |
| TileSet atlas | < 4 MB |
| Font files | < 10 MB total |

---

## Tools
- **Aseprite** - Pixel art animation (recommended)
- **Krita** - Free alternative
- **TexturePacker** - Atlas generation (if needed)
- **Godot Editor** - TileMap/TileSet editing
- **pngcrush / oxipng** - PNG optimization

---

## Related Documents
- `docs/SPECS/ui_system.md` - UI Spec Sheet
- `docs/RUNBOOKS/deployment.md` - Export includes assets
- `CLAUDE.md` - AI context for asset tasks
