extends Node2D

const TILE_W := 64.0
const TILE_H := 32.0
const CLUB_W := 12
const CLUB_H := 10

@onready var camera: Camera2D = $Camera2D

var dragging := false
var zoom_level := 1.0
var npc_positions := [
	Vector2(5.0, 6.0),
	Vector2(6.0, 5.0),
	Vector2(7.0, 6.0),
	Vector2(4.5, 5.0),
	Vector2(8.0, 5.0),
	Vector2(3.0, 7.2),
	Vector2(8.8, 7.0)
]

func _ready() -> void:
	print("Nightclub City club shell loaded.")
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_set_zoom(zoom_level + 0.10)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_set_zoom(zoom_level - 0.10)
	elif event is InputEventMouseMotion and dragging:
		camera.position -= event.relative / camera.zoom.x

func _set_zoom(value: float) -> void:
	zoom_level = clamp(value, 0.65, 1.65)
	camera.zoom = Vector2.ONE * zoom_level

func _iso(tile_x: float, tile_y: float) -> Vector2:
	return Vector2(
		(tile_x - tile_y) * TILE_W * 0.5,
		(tile_x + tile_y) * TILE_H * 0.5
	)

func _tile_points(x: float, y: float, width := 1.0, depth := 1.0) -> PackedVector2Array:
	return PackedVector2Array([
		_iso(x, y),
		_iso(x + width, y),
		_iso(x + width, y + depth),
		_iso(x, y + depth)
	])

func _draw() -> void:
	draw_rect(Rect2(-4000, -4000, 8000, 8000), Color("#090714"))

	_draw_floor()
	_draw_back_walls()
	_draw_dance_floor()
	_draw_dj_booth()
	_draw_bar()
	_draw_seating()
	_draw_entrance()
	_draw_npcs()
	_draw_neon_accents()

func _draw_floor() -> void:
	for y in range(CLUB_H):
		for x in range(CLUB_W):
			var base := Color("#171521") if (x + y) % 2 == 0 else Color("#1d1a29")
			draw_polygon(_tile_points(x, y), PackedColorArray([base]))

			var p := _tile_points(x, y)
			for i in range(4):
				draw_line(p[i], p[(i + 1) % 4], Color(0.24, 0.21, 0.34, 0.55), 1.0)

func _draw_back_walls() -> void:
	var wall_h := 88.0
	for x in range(CLUB_W):
		var a := _iso(x, 0)
		var b := _iso(x + 1, 0)
		var wall := PackedVector2Array([
			a,
			b,
			b - Vector2(0, wall_h),
			a - Vector2(0, wall_h)
		])
		var shade := Color("#2b2040") if x % 2 == 0 else Color("#241b37")
		draw_polygon(wall, PackedColorArray([shade]))
		draw_line(a - Vector2(0, wall_h), b - Vector2(0, wall_h), Color("#b34cff"), 2.0)

	for y in range(CLUB_H):
		var a := _iso(0, y)
		var b := _iso(0, y + 1)
		var wall := PackedVector2Array([
			a,
			b,
			b - Vector2(0, wall_h),
			a - Vector2(0, wall_h)
		])
		var shade := Color("#1c2940") if y % 2 == 0 else Color("#182237")
		draw_polygon(wall, PackedColorArray([shade]))
		draw_line(a - Vector2(0, wall_h), b - Vector2(0, wall_h), Color("#26d9ff"), 2.0)

func _draw_dance_floor() -> void:
	for y in range(4, 8):
		for x in range(4, 8):
			var colors := [
				Color("#7f35ff"),
				Color("#ff3ccf"),
				Color("#20d9ff"),
				Color("#5736ff")
			]
			var c: Color = colors[(x + y) % colors.size()]
			draw_polygon(_tile_points(x, y), PackedColorArray([c.darkened(0.28)]))
			var p := _tile_points(x, y)
			for i in range(4):
				draw_line(p[i], p[(i + 1) % 4], c.lightened(0.14), 1.5)

func _draw_iso_box(x: float, y: float, width: float, depth: float, height: float, top: Color, left: Color, right: Color) -> void:
	var a := _iso(x, y)
	var b := _iso(x + width, y)
	var c := _iso(x + width, y + depth)
	var d := _iso(x, y + depth)
	var up := Vector2(0, height)

	draw_polygon(PackedVector2Array([d - up, c - up, c, d]), PackedColorArray([left]))
	draw_polygon(PackedVector2Array([b - up, c - up, c, b]), PackedColorArray([right]))
	draw_polygon(PackedVector2Array([a - up, b - up, c - up, d - up]), PackedColorArray([top]))

func _draw_dj_booth() -> void:
	_draw_iso_box(5.0, 1.1, 2.8, 1.0, 42.0, Color("#55278d"), Color("#251c42"), Color("#38205e"))
	var center := _iso(6.4, 1.6) - Vector2(0, 44)
	draw_circle(center, 11.0, Color("#ff45db"))
	draw_circle(center, 5.0, Color("#130f1c"))
	draw_line(center + Vector2(-36, 8), center + Vector2(36, 8), Color("#48e6ff"), 3.0)

func _draw_bar() -> void:
	_draw_iso_box(1.0, 3.1, 1.1, 4.0, 34.0, Color("#284d70"), Color("#15283d"), Color("#1c3852"))
	var start := _iso(1.2, 3.4) - Vector2(0, 38)
	var finish := _iso(1.2, 6.7) - Vector2(0, 38)
	draw_line(start, finish, Color("#2de3ff"), 3.0)

	for i in range(3):
		var stool := _iso(2.4, 4.0 + i * 1.0)
		draw_circle(stool - Vector2(0, 10), 8.0, Color("#d146ff"))
		draw_line(stool - Vector2(0, 4), stool + Vector2(0, 10), Color("#40344f"), 3.0)

func _draw_seating() -> void:
	_draw_iso_box(8.7, 2.4, 2.2, 0.8, 22.0, Color("#54256c"), Color("#2f173c"), Color("#3c1b4c"))
	_draw_iso_box(9.2, 3.4, 1.0, 1.2, 18.0, Color("#2a5f78"), Color("#163340"), Color("#204b5f"))
	_draw_iso_box(2.5, 7.7, 2.2, 0.8, 22.0, Color("#54256c"), Color("#2f173c"), Color("#3c1b4c"))

func _draw_entrance() -> void:
	var a := _iso(9.2, 0.0)
	var b := _iso(10.8, 0.0)
	var h := 74.0
	var door := PackedVector2Array([
		a,
		b,
		b - Vector2(0, h),
		a - Vector2(0, h)
	])
	draw_polygon(door, PackedColorArray([Color("#0c1721")]))
	draw_line(a - Vector2(0, h), b - Vector2(0, h), Color("#27e4ff"), 4.0)
	draw_line(a, a - Vector2(0, h), Color("#27e4ff"), 3.0)
	draw_line(b, b - Vector2(0, h), Color("#27e4ff"), 3.0)

	var sign_pos := (a + b) * 0.5 - Vector2(0, h + 14)
	draw_string(ThemeDB.fallback_font, sign_pos + Vector2(-28, 0), "ENTRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#a8f5ff"))

func _draw_npcs() -> void:
	var body_colors := [
		Color("#ff477e"),
		Color("#5ee1ff"),
		Color("#bd66ff"),
		Color("#f5bf42"),
		Color("#67df8f")
	]

	for i in range(npc_positions.size()):
		var pos := _iso(npc_positions[i].x, npc_positions[i].y)
		var body_color: Color = body_colors[i % body_colors.size()]

		draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, 0.45))
		draw_circle(Vector2(pos.x, pos.y + 6), 14.0, Color(0, 0, 0, 0.25))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

		draw_line(pos - Vector2(0, 21), pos - Vector2(0, 4), body_color, 8.0)
		draw_circle(pos - Vector2(0, 30), 8.0, Color("#e5b08d"))
		draw_line(pos - Vector2(0, 2), pos + Vector2(-5, 11), Color("#272235"), 4.0)
		draw_line(pos - Vector2(0, 2), pos + Vector2(5, 11), Color("#272235"), 4.0)

func _draw_neon_accents() -> void:
	var center := _iso(6.0, 5.5)
	draw_arc(center, 115.0, PI, TAU, 32, Color(0.48, 0.19, 1.0, 0.16), 6.0)
	draw_arc(center, 150.0, PI, TAU, 32, Color(0.1, 0.82, 1.0, 0.10), 5.0)
