# Asset Test Room

This is the calibration scene for production furniture assets.

## Run it

Open `res://scenes/test/asset_test_room.tscn` in Godot and run the current scene (F6).

The main game scene is unchanged.

## Locked production dimensions

- Isometric tile: 72 x 36 px
- Wall height: 108 px
- Master Bar 01 footprint: 3 x 1 tiles
- Three copies are spawned edge-to-edge against the top wall

## Debug markers

- Yellow: placement anchor
- Green: bartender position
- Pink: customer interaction positions

## Approval rule

Do not replace the proxy with polished artwork until all of these pass:

1. Three copies align with no gaps.
2. Three copies do not visually overlap their neighbors.
3. The back of the bar fits the wall line.
4. No visible geometry extends outside the 3 x 1 footprint except vertically upward.
5. Bartender and customer markers are not inside solid furniture.
6. Final artwork can replace the proxy without changing the logical footprint or interaction markers.

Once approved, Bar_01 becomes the reference implementation for future bars.
