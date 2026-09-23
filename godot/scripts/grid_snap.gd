extends RefCounted

const TILE_W: float = 48.0
const TILE_H: float = 24.0

static func grid_to_world(cell: Vector2i) -> Vector2:
	return Vector2(
		float(cell.x - cell.y) * TILE_W * 0.5,
		float(cell.x + cell.y) * TILE_H * 0.5
	)

static func grid_to_world_f(tile_x: float, tile_y: float) -> Vector2:
	return Vector2(
		(tile_x - tile_y) * TILE_W * 0.5,
		(tile_x + tile_y) * TILE_H * 0.5
	)

static func world_to_grid(world_pos: Vector2) -> Vector2i:
	var tile_x: float = world_pos.y / TILE_H + world_pos.x / TILE_W
	var tile_y: float = world_pos.y / TILE_H - world_pos.x / TILE_W
	return Vector2i(int(floor(tile_x)), int(floor(tile_y)))

static func snap_world(world_pos: Vector2) -> Vector2:
	return grid_to_world(world_to_grid(world_pos))

static func footprint_cells(origin: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for dy in range(footprint.y):
		for dx in range(footprint.x):
			cells.append(origin + Vector2i(dx, dy))
	return cells
