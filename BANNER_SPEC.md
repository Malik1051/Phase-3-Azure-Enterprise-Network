# GitHub Banner — Design Specification

Use this spec to recreate the repository banner in **Canva** or **Figma**. Recommended export size: **1280 × 640px** (GitHub social preview) or **1600 × 400px** (in-README banner).

## Layout

```
┌──────────────────────────────────────────────────────────────────┐
│  [Azure icon]                                                     │
│                                                                     │
│   PHASE 3                                                          │
│   AZURE ENTERPRISE NETWORK                                          │
│   Infrastructure as Code · Terraform · Microsoft Azure                │
│                                                                     │
│                                        [Terraform icon]  [Network icon]│
└──────────────────────────────────────────────────────────────────┘
```

- **Alignment**: Left-aligned text block, vertically centered.
- **Icon cluster**: Azure logo top-left (small, ~48px), Terraform + network/topology icons bottom-right, subtly watermarked at ~40% opacity.
- **Margins**: 64px safe margin on all sides — keep all text and icons well inside this to avoid GitHub crop/preview cutoff.

## Typography

| Element | Font | Weight | Size (at 1600px width) | Color |
|---|---|---|---|---|
| Eyebrow ("PHASE 3") | Inter / Segoe UI | SemiBold, letter-spaced | 22px | `#8AB4F8` (light Azure blue) |
| Title ("AZURE ENTERPRISE NETWORK") | Inter / Segoe UI | Bold | 56px | `#FFFFFF` |
| Subtitle (tech stack line) | Inter / Segoe UI | Regular | 24px | `#C7D3E0` |

## Color Palette

| Role | Hex | Usage |
|---|---|---|
| Primary background (dark) | `#0B1F3A` | Base banner background |
| Secondary background (gradient end) | `#0D2A52` | Diagonal gradient from top-left to bottom-right |
| Azure brand accent | `#0078D4` | Icon accents, thin divider line under title |
| Terraform brand accent | `#844FBA` | Secondary icon glow / accent dot |
| Text primary | `#FFFFFF` | Title |
| Text secondary | `#C7D3E0` | Subtitle / tech stack line |
| Highlight accent | `#8AB4F8` | Eyebrow label, small UI accents |

**Background treatment**: Subtle diagonal linear gradient (`#0B1F3A` → `#0D2A52`, 135°), with a faint, low-opacity network-topology line pattern (hexagons or connected nodes) in the background at ~8–12% opacity to reinforce the "network" theme without competing with text.

## Icons / Graphics

- Official **Azure** logo (simplified, monochrome/white or brand blue) — top-left corner.
- **Terraform** logo mark (the purple "T" glyph) — bottom-right, paired with a simple network/node icon (three connected circles representing subnets) to visually nod to the three-tier architecture.
- Keep icon usage minimal — 2–3 icons max — to maintain a clean, enterprise (not cluttered) feel.

## Spacing & Grid

- Use an 8px spacing grid throughout.
- Title sits ~48px below the eyebrow label.
- Subtitle sits ~24px below the title.
- Icon cluster bottom-right is inset 48px from the right and bottom edges.

## Tone

Enterprise, technical, restrained — closer to an Azure Solutions Architect slide than a flashy startup banner. No exaggerated 3D effects, no stock-photo cloud imagery, no drop shadows on text. Flat, modern, confident.

## Suggested Canva/Figma Steps

1. Create a frame at 1600×400px.
2. Apply the diagonal gradient background.
3. Add a low-opacity node/hex pattern layer (search Canva elements: "network pattern," "hexagon grid").
4. Place the Azure logo top-left at 48px from edges.
5. Add text block: eyebrow → title → subtitle, left-aligned, starting ~64px from the left edge.
6. Add Terraform + network icons bottom-right, 40% opacity, layered behind or beside the text block.
7. Export as PNG (transparent background not needed) at 2x resolution for crispness, save to `images/banner.png`.
