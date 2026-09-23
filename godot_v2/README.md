# Nightclub City V2

This folder is a clean Godot 4 project built around Godot's native isometric tile system.

## Foundation rules

- The floor is a real `TileMapLayer`.
- The TileSet is 48x24, `TILE_SHAPE_ISOMETRIC`, `TILE_LAYOUT_DIAMOND_DOWN`.
- Mouse snapping uses `TileMapLayer.local_to_map()`.
- Furniture placement uses `TileMapLayer.map_to_local()`.
- Furniture is scene-based; it is never painted by the main scene.
- Every furniture scene owns an integer footprint such as 1x1, 2x2, or 1x3.
- `OccupancyGrid` reserves every cell in that footprint.
- Move/delete operate on the same occupancy data used by placement.

## First test scene

Open and run:

`res://scenes/testing/PlacementLab.tscn`

Controls:

- 1 = 1x1 footprint
- 2 = 2x2 footprint
- 3 = 1x3 bar footprint
- Left click = place
- M = pick up the object under the cursor, then left click to place it again
- Right click = delete
- Esc = cancel a move

Do not migrate nightclub artwork into V2 until this placement lab feels exact.
