# Asset Test Room

This is the calibration scene for production furniture assets.

## Run it

Open `res://scenes/test/asset_test_room.tscn` in Godot and run the current scene.

The main game scene is unchanged.

## Locked production dimensions

- Isometric tile: 72 x 36 px
- Wall height: 108 px
- Master bar footprint: 1 x 3 tiles
- Module width: 1 tile along the wall
- Module depth: 3 tiles outward from the wall
- Bar system: one universal repeatable module
- Six identical copies are spawned on consecutive wall columns

## Module layout

Each 1 x 3 module is divided by function:

1. Rear tile: back shelf / bottle storage
2. Middle tile: bartender service aisle
3. Front tile: customer-facing bar counter

The customer interaction point sits just outside the front counter.

## Debug markers

Each module owns:

- Yellow: placement anchor at the wall-side origin
- Green: bartender position centered in the service aisle
- Pink: customer interaction point outside the front counter

## Blender artwork

The test room displays `assets/bar/bar_module_01.png`, the current Blender render.
The image remains under calibration while the new 1 x 3 logical contract is validated.
Do not redesign the Blender model yet; first confirm that its rear shelf, open service
space, and front counter can be aligned to these three depth rows.

The main nightclub scene is unchanged.

## Review checklist

Before adopting the asset in the main club:

1. Six modules repeat cleanly along the wall.
2. Rear shelves align as one continuous back-bar run.
3. Front counters align as one continuous customer-facing run.
4. The middle row remains visibly open for bartender movement.
5. Neighboring modules do not overlap.
6. There are no unintended gaps between matching module edges.
7. Bartender markers sit in the open service aisle.
8. Customer markers remain outside the front counter.
9. The Blender render can be calibrated to the 1 x 3 footprint without changing gameplay geometry.

Once approved, this universal 1 x 3 module becomes the reference implementation for modular bars.
