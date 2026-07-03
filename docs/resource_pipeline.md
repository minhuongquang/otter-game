# Resource Pipeline

> **Purpose**: Define the asset creation and import pipeline for art, audio, and fonts.  
> **Scope**: Asset creation tools, Godot import settings, file formats, naming.  
> **Status**: Draft — to be refined as asset production begins.

---

## Overview

The resource pipeline covers how assets are created, exported, imported into Godot, and organized. Consistent naming and format choices ensure maintainability.

---

## Art Pipeline

### File Formats

| Asset Type | Source Format | Godot Import Format | Notes |
|------------|--------------|---------------------|-------|
| Character sprites | .psd / .png | .png (sprite sheet) | Transparent background |
| Backgrounds | .psd / .png | .png | Full-screen VN backgrounds |
| Tilesets | .png | .png (tileset) | Grid-based tiles |
| UI elements | .svg / .png | .png / .svg | SVG preferred for scalable |
| Icons | .svg / .png | .png / .svg | 32x32 or 64x64 |
| Portraits | .psd / .png | .png | Multiple emotion states |
| Effects | .png | .png (sprite sheet) | Particle textures |

### Resolution Guidelines

| Asset | Resolution | DPI |
|-------|------------|-----|
| VN Background | 1920x1080 | 72 |
| Character Sprite | 64x64 per frame | 72 |
| Portrait | 400x600 | 72 |
| Tile Size | 32x32 | 72 |
| UI Element | Variable | 72 |
| Icon | 32x32 | 72 |

### Naming Convention

```
type_subject_variant_emotion.png

Examples:
sprite_hero_walk_01.png
portrait_hero_happy.png
bg_forest_clearing.png
icon_potion_small.png
ui_button_primary.png
```

---

## Animation Pipeline

| Type | Tool | Export Format | Notes |
|------|------|---------------|-------|
| Sprite animations | Aseprite / Pyxel Edit | .png sheet | Grid-based frames |
| Spine animations | Spine | .json + atlas | Bone animation |
| Simple animations | Godot AnimationPlayer | .tres | Built-in |

### Sprite Sheet Format

```gdscript
@export var frames: SpriteFrames
# Configure in Godot SpriteFrames editor
# Or import as horizontal sprite sheet
```

---

## Audio Pipeline

### File Formats

| Asset Type | Source Format | Godot Format | Notes |
|------------|--------------|--------------|-------|
| BGM | .wav (48kHz/24bit) | .ogg | Compressed for size |
| SFX | .wav (48kHz/24bit) | .wav | Low latency |
| Voice | .wav (44.1kHz/16bit) | .ogg | Future feature |
| Ambient | .wav (48kHz/24bit) | .ogg | Loopable audio |

### Naming Convention

```
type_context_variant.ext

Examples:
bgm_field_exploration.ogg
sfx_battle_sword_01.wav
sfx_ui_confirm.wav
ambient_forest_day.ogg
voice_hero_greeting_01.ogg
```

---

## Font Pipeline

| Type | Format | Notes |
|------|--------|-------|
| UI Text | .ttf / .otf | System font or custom |
| Dialogue Text | .ttf / .otf | Readable, serif preferred |
| Title Text | .ttf / .otf | Decorative for titles |
| Icon Font | .ttf (icon glyphs) | Custom icon set |

---

## Import Settings

### Textures

| Setting | Value |
|---------|-------|
| Filter | Linear (pixel art: Nearest) |
| Repeat | Disabled |
| Mipmaps | Enabled (scaled sprites) |
| Compress | Lossless (VRAM compressed) |
| Flags | Repeat disabled |

### Audio

| Setting | Value |
|---------|-------|
| Loop | Enabled for BGM/ambient |
| Trim | Enabled |
| Normalize | Disabled (control in DAW) |

---

## Asset Folder Structure

```
assets/
├── art/
│   ├── backgrounds/
│   ├── characters/
│   │   ├── hero/
│   │   ├── npc/
│   │   └── portraits/
│   ├── enemies/
│   ├── environment/
│   │   ├── tilesets/
│   │   └── props/
│   ├── effects/
│   ├── items/
│   ├── ui/
│   └── world/
├── audio/
│   ├── bgm/
│   ├── sfx/
│   │   ├── battle/
│   │   ├── ui/
│   │   └── world/
│   └── voice/
├── fonts/
├── shaders/
└── vfx/
```

---

## Related

- [folder_structure.md](folder_structure.md) — Asset folder layout
- [content_pipeline.md](content_pipeline.md) — Content authoring workflow
- [database.md](database.md) — Resource definitions
