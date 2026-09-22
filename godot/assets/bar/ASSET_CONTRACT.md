# Bar Asset Contract

This folder is the production source of truth for Godot bar art.

## Why this exists

The old connected-bar test used 144px-wide left/middle/right sprites for every 1x1 bar tile. In this isometric camera, moving one tile along the top wall advances only 36px horizontally and 18px vertically. Those sprites therefore painted over one another even when grid snapping was correct.

The new rule is simple: **one logical bar tile may only own one tile of horizontal visual space.** Art may extend upward for height, shelves, bottles, signs, and glow, but it must not place opaque pixels into the neighboring bar tile.

## Grid constants

- Tile width: 72px
- Tile height: 36px
- Top-wall one-tile screen delta: (36, 18)
- Wall height: 108px
- Back-bar panel height: 75% of wall height

## Current clean module

The starter bar is temporarily assembled from two authored textures:

- `front_counter_module.png.b64`
- `back_shelf_module.png.b64`

Godot maps those textures onto exact grid edges instead of drawing them at guessed pixel offsets.

### Counter calibration

The authored counter's source edge:

- A: (6, 44)
- B: (45, 62)

maps to the customer-facing edge of one floor tile:

- A: `_iso(x, y + 1)`
- B: `_iso(x + 1, y + 1)`

### Back shelf calibration

The shelf art is transformed into the exact top-wall tile panel from `_iso(x, 0)` to `_iso(x + 1, 0)`, rising vertically to 75% of wall height.

## Rules for every new bar asset

1. Transparent background.
2. Same isometric camera and lighting direction as the game.
3. No opaque side bleed into a neighboring tile.
4. Vertical overhang is allowed.
5. Glow may cross the boundary only if it fades to transparent before becoming visually solid.
6. Do not bake neighboring wall/floor tiles into the object.
7. Keep the contact edge/pivot consistent across every asset in the family.
8. Shop icon is a separate crop; never reuse a badly cropped world sprite as the icon.
9. Test three copies side by side before approving the asset.
10. Test NPCs in front of and behind the bar before approving layering.

## Production progression

Planned starter family:

- Starter Bar — Level 1
- Neon Corner Bar — Level 3
- Lounge Bar — Level 5
- Premium Glow Bar — Level 8
- VIP Signature Bar — Level 12

The code should treat grid occupancy and visual rendering separately. Connected tiles can later be rendered as one full run sprite when we have final run-length assets, but placement/collision should remain tile-based.
