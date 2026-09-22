# Asset Test Room

This is the calibration scene for production furniture assets.

## Run it

Open `res://scenes/test/asset_test_room.tscn` in Godot and run the current scene.

The main game scene is unchanged.

## Locked production dimensions

- Isometric tile: 72 x 36 px
- Wall height: 108 px
- Master bar footprint: 1 x 1 tile
- Bar system: one universal repeatable module
- Six identical copies are spawned on consecutive wall tiles

## Debug markers

Each 1 x 1 module owns:

- Yellow: placement anchor
- Green: one bartender position
- Pink: one customer interaction position

## Blender artwork

The test room now displays `assets/bar/bar_module_01.png`, an original Blender
render with a dark counter, bottle shelves, and cyan/violet trim. The 144x144
transparent canvas contains a 72x36 ground footprint. Its ground center is
(72,112); drawing at (-72,-94) aligns it to the existing tile center (0,18).
One module step remains (36,18). Placement and interaction markers are unchanged.
The main club still uses its existing artwork; this scene is the calibration gate.

## Review checklist

Review the Blender artwork against these criteria before adopting it in the main club:

1. Six identical 1 x 1 copies align continuously.
2. Neighboring copies do not visually overlap.
3. There are no unintended gaps between modules.
4. The back of each module fits the wall line.
5. Visible geometry stays inside its 1 x 1 footprint except vertically upward.
6. Bartender and customer markers remain outside solid furniture.
7. Final artwork can replace the proxy without changing the logical footprint or interaction markers.

Once approved, this universal 1 x 1 module becomes the reference implementation for all modular bars.
