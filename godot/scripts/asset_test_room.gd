extends Node2D

const TILE_W: float = 72.0
const TILE_H: float = 36.0
const GRID_W: int = 12
const GRID_H: int = 10
const WALL_H: float = 108.0
const ORIGIN: Vector2 = Vector2(500.0, 185.0)
const TEST_MODULE_COUNT: int = 6

@export var bar_scene: PackedScene

var spawned_bars: Array[Node2D] = []

func _ready() -> void:
	_spawn_bar_test_run()
	_update_snap_status()
	queue_redraw()

func _iso(tile_x: float, tile_y: float) -> Vector2:
	return Vector2(
		(tile_x - tile_y) * TILE_W * 0.5,
		(tile_x + tile_y) * TILE_H * 0.5
	)

func _world_iso(tile_x: float, tile_y: float) -> Vector2:
	return ORIGIN + _iso(tile_x, tile_y)

func _snap_cell(cell: Vector2i) -> Vector2:
	# Integer grid cells always resolve to the same exact screen-space anchor.
	return _world_iso(float(cell.x), float(cell.y)).round()

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

	spawned_bars.clear()

	# Six 1x3 modules snap to consecutive wall cells. Never position the visual
	# texture directly here; each module's Node2D origin is the snap anchor.
	for i in range(TEST_MODULE_COUNT):
		var bar: Node2D = bar_scene.instantiate()
		bar.name = "Bar_01_Module_%02d" % (i + 1)
		bar.position = _snap_cell(Vector2i(i, 0))
		bar.z_index = i
		add_child(bar)
		spawned_bars.append(bar)

func _update_snap_status() -> void:
	var problems: Array[String] = []
	var expected_step: Vector2 = _iso(1.0, 0.0)

	for i in range(spawned_bars.size()):
		var expected: Vector2 = _snap_cell(Vector2i(i, 0))
		if spawned_bars[i].position != expected:
			problems.append("module %d off grid" % (i + 1))

	for i in range(1, spawned_bars.size()):
		var actual_step: Vector2 = spawned_bars[i].position - spawned_bars[i - 1].position
		if actual_step != expected_step:
			problems.append("module %d spacing drift" % (i + 1))

	var status: Label = $HUD/Status
	if problems.is_empty():
		status.text = "YELLOW  Snap Anchor      GREEN  Bartender Tile      PINK  Customer Point\nSNAP PASS = 1 wall tile = (36,18) px • module footprint = 1x3 • no placement drift"
	else:
		status.text = "SNAP FAIL: " + str(problems)

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

	# Six modules wide and three tiles deep.
	var test_strip: PackedVector2Array = _tile_points(0.0, 0.0, float(TEST_MODULE_COUNT), 3.0)
	for i in range(test_strip.size()):
		draw_line(test_strip[i], test_strip[(i + 1) % test_strip.size()], Color("#f6d365"), 2.0)

	# Middle row = shared bartender/service aisle.
	var service_strip: PackedVector2Array = _tile_points(0.0, 1.0, float(TEST_MODULE_COUNT), 1.0)
	draw_polygon(service_strip, PackedColorArray([Color(0.35, 0.95, 0.55, 0.05)]))
	for i in range(service_strip.size()):
		draw_line(service_strip[i], service_strip[(i + 1) % service_strip.size()], Color(0.35, 0.95, 0.55, 0.35), 1.0)

	# Legend.
	draw_circle(Vector2(32.0, 625.0), 5.0, Color("#f6d365"))
	draw_circle(Vector2(190.0, 625.0), 5.0, Color("#66e39a"))
	draw_circle(Vector2(354.0, 625.0), 5.0, Color("#ff6fae"))
