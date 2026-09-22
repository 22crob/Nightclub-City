extends Node2D

const TILE_W: float = 72.0
const TILE_H: float = 36.0
const GRID_W: int = 12
const GRID_H: int = 8
const WALL_H: float = 108.0
const ORIGIN: Vector2 = Vector2(500.0, 185.0)

@export var bar_scene: PackedScene

func _ready() -> void:
	_spawn_bar_test_run()
	queue_redraw()

func _iso(tile_x: float, tile_y: float) -> Vector2:
	return Vector2(
		(tile_x - tile_y) * TILE_W * 0.5,
		(tile_x + tile_y) * TILE_H * 0.5
	)

func _world_iso(tile_x: float, tile_y: float) -> Vector2:
	return ORIGIN + _iso(tile_x, tile_y)

func _tile_points(x: float, y: float, width: float, depth: float) -> PackedVector2Array:
	return PackedVector2Array([
		_world_iso(x, y),
		_world_iso(x + width, y),
		_world_iso(x + width, y + depth),
		_world_iso(x, y + depth)
	])

func _spawn_bar_test_run() -> void:
	if bar_scene == null:
		push_warning("AssetTestRoom has no Bar_01 PackedScene assigned.")
		return

	# Three 3x1 bars placed exactly next to one another on the top wall.
	# Their logical footprints are [0..3], [3..6], [6..9].
	for i in range(3):
		var bar: Node2D = bar_scene.instantiate()
		bar.name = "Bar_01_Test_%d" % (i + 1)
		bar.position = _world_iso(float(i * 3), 0.0)
		add_child(bar)

func _draw() -> void:
	draw_rect(Rect2(0.0, 0.0, 1280.0, 720.0), Color("#08060f"))

	# Production-sized 72x36 isometric test grid.
	for y in range(GRID_H):
		for x in range(GRID_W):
			var tile: PackedVector2Array = _tile_points(float(x), float(y), 1.0, 1.0)
			var fill: Color = Color("#181421") if (x + y) % 2 == 0 else Color("#1d1828")
			draw_polygon(tile, PackedColorArray([fill]))
			for i in range(tile.size()):
				draw_line(tile[i], tile[(i + 1) % tile.size()], Color(0.42, 0.34, 0.56, 0.40), 1.0)

	# Top wall uses the same 108px wall height as the current club.
	for x in range(GRID_W):
		var a: Vector2 = _world_iso(float(x), 0.0)
		var b: Vector2 = _world_iso(float(x + 1), 0.0)
		var wall: PackedVector2Array = PackedVector2Array([
			a,
			b,
			b - Vector2(0.0, WALL_H),
			a - Vector2(0.0, WALL_H)
		])
		draw_polygon(wall, PackedColorArray([Color("#261a33")]))
		draw_line(a - Vector2(0.0, WALL_H), b - Vector2(0.0, WALL_H), Color("#b03fff"), 1.5)

	# Highlight the exact 9x1 logical area occupied by the three bars.
	var test_strip: PackedVector2Array = _tile_points(0.0, 0.0, 9.0, 1.0)
	for i in range(test_strip.size()):
		draw_line(test_strip[i], test_strip[(i + 1) % test_strip.size()], Color("#f6d365"), 2.0)

	# Legend: yellow = placement anchor, green = bartender, pink = customers.
	draw_circle(Vector2(32.0, 625.0), 5.0, Color("#f6d365"))
	draw_circle(Vector2(190.0, 625.0), 5.0, Color("#66e39a"))
	draw_circle(Vector2(354.0, 625.0), 5.0, Color("#ff6fae"))
