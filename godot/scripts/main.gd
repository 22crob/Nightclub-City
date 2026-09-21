extends Node2D

const TILE_W: float = 72.0
const TILE_H: float = 36.0
const CLUB_W: int = 14
const CLUB_H: int = 11
const WALL_H: float = 108.0

@onready var camera: Camera2D = $Camera2D
@onready var zoom_out_button: Button = $HUD/ZoomControls/ZoomOut
@onready var zoom_in_button: Button = $HUD/ZoomControls/ZoomIn

var dragging: bool = false
var zoom_level: float = 1.0
var anim_time: float = 0.0

var npc_positions: Array[Vector2] = [
	Vector2(5.3, 5.3),
	Vector2(6.4, 4.8),
	Vector2(7.4, 5.5),
	Vector2(8.2, 4.9),
	Vector2(6.0, 6.6),
	Vector2(7.6, 6.7),
	Vector2(2.9, 5.2),
	Vector2(3.1, 6.8),
	Vector2(10.7, 4.9),
	Vector2(9.5, 8.1)
]

var npc_colors: Array[Color] = [
	Color("#ff4fa3"),
	Color("#51d9ff"),
	Color("#9b65ff"),
	Color("#ffbd45"),
	Color("#66e39a"),
	Color("#ff6470"),
	Color("#d46dff"),
	Color("#50c8ff"),
	Color("#f56cff"),
	Color("#6fe4c2")
]

func _ready() -> void:
	print("Nightclub City Level 1 safe visual pass loaded.")
	zoom_out_button.pressed.connect(_zoom_out)
	zoom_in_button.pressed.connect(_zoom_in)
	queue_redraw()

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_set_zoom(zoom_level + 0.08)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_set_zoom(zoom_level - 0.08)
	elif event is InputEventMouseMotion and dragging:
		camera.position -= event.relative / camera.zoom.x

func _set_zoom(value: float) -> void:
	zoom_level = clamp(value, 0.70, 1.55)
	camera.zoom = Vector2.ONE * zoom_level

func _zoom_out() -> void:
	_set_zoom(zoom_level - 0.10)

func _zoom_in() -> void:
	_set_zoom(zoom_level + 0.10)

func _iso(tile_x: float, tile_y: float) -> Vector2:
	return Vector2(
		(tile_x - tile_y) * TILE_W * 0.5,
		(tile_x + tile_y) * TILE_H * 0.5
	)

func _tile_points(x: float, y: float, width: float, depth: float) -> PackedVector2Array:
	return PackedVector2Array([
		_iso(x, y),
		_iso(x + width, y),
		_iso(x + width, y + depth),
		_iso(x, y + depth)
	])

func _draw() -> void:
	draw_rect(Rect2(-5000, -5000, 10000, 10000), Color("#08060f"))
	_draw_room_shadow()
	_draw_floor()
	_draw_dance_floor()
	_draw_walls()
	_draw_entrance()
	_draw_dj_booth()
	_draw_bar()
	_draw_lounges()
	_draw_tables()
	_draw_npcs()
	_draw_light_accents()

func _draw_room_shadow() -> void:
	var shadow: PackedVector2Array = _tile_points(-0.3, -0.3, float(CLUB_W) + 0.6, float(CLUB_H) + 0.6)
	for i in range(shadow.size()):
		shadow[i] += Vector2(0, 22)
	draw_polygon(shadow, PackedColorArray([Color(0.0, 0.0, 0.0, 0.42)]))

func _draw_floor() -> void:
	for y in range(CLUB_H):
		for x in range(CLUB_W):
			var base: Color = Color("#1b1726")
			if (x + y) % 2 == 1:
				base = Color("#171420")
			draw_polygon(_tile_points(float(x), float(y), 1.0, 1.0), PackedColorArray([base]))
			var tile: PackedVector2Array = _tile_points(float(x), float(y), 1.0, 1.0)
			for i in range(4):
				draw_line(tile[i], tile[(i + 1) % 4], Color(0.27, 0.22, 0.36, 0.24), 0.8)

	var edge: PackedVector2Array = _tile_points(0.0, 0.0, float(CLUB_W), float(CLUB_H))
	for i in range(4):
		draw_line(edge[i], edge[(i + 1) % 4], Color("#3a2d4d"), 3.0)

func _draw_dance_floor() -> void:
	var colors: Array[Color] = [
		Color("#7c36ff"),
		Color("#ff3ebf"),
		Color("#24d8ff"),
		Color("#543aff")
	]

	for y in range(4, 8):
		for x in range(5, 10):
			var c: Color = colors[(x + y) % colors.size()]
			var pulse: float = 0.03 * sin(anim_time * 2.0 + float(x + y))
			draw_polygon(
				_tile_points(float(x), float(y), 1.0, 1.0),
				PackedColorArray([c.darkened(0.30 - pulse)])
			)
			var tile: PackedVector2Array = _tile_points(float(x), float(y), 1.0, 1.0)
			for i in range(4):
				draw_line(tile[i], tile[(i + 1) % 4], c.lightened(0.10), 1.4)

func _draw_walls() -> void:
	for x in range(CLUB_W):
		if x == 10 or x == 11:
			continue
		var a: Vector2 = _iso(float(x), 0.0)
		var b: Vector2 = _iso(float(x + 1), 0.0)
		var wall: PackedVector2Array = PackedVector2Array([
			a,
			b,
			b - Vector2(0, WALL_H),
			a - Vector2(0, WALL_H)
		])
		var shade: Color = Color("#261a33")
		if x % 2 == 1:
			shade = Color("#2b1d39")
		draw_polygon(wall, PackedColorArray([shade]))
		draw_line(a - Vector2(0, WALL_H), b - Vector2(0, WALL_H), Color("#b03fff"), 2.2)

	for y in range(CLUB_H):
		var a: Vector2 = _iso(0.0, float(y))
		var b: Vector2 = _iso(0.0, float(y + 1))
		var wall: PackedVector2Array = PackedVector2Array([
			a,
			b,
			b - Vector2(0, WALL_H),
			a - Vector2(0, WALL_H)
		])
		var shade: Color = Color("#18283b")
		if y % 2 == 1:
			shade = Color("#1b2c40")
		draw_polygon(wall, PackedColorArray([shade]))
		draw_line(a - Vector2(0, WALL_H), b - Vector2(0, WALL_H), Color("#28dbff"), 2.2)

	var logo_pos: Vector2 = _iso(7.0, 0.0) - Vector2(0, 67)
	draw_circle(logo_pos, 23.0, Color(0.60, 0.15, 1.0, 0.16))
	draw_circle(logo_pos, 16.0, Color("#7d30d9"))
	draw_circle(logo_pos, 10.0, Color("#15101d"))
	draw_string(ThemeDB.fallback_font, logo_pos + Vector2(-8, 5), "NC", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#f3ddff"))

func _draw_iso_box(
	x: float,
	y: float,
	width: float,
	depth: float,
	height: float,
	top: Color,
	left: Color,
	right: Color
) -> void:
	var a: Vector2 = _iso(x, y)
	var b: Vector2 = _iso(x + width, y)
	var c: Vector2 = _iso(x + width, y + depth)
	var d: Vector2 = _iso(x, y + depth)
	var up: Vector2 = Vector2(0, height)

	draw_polygon(PackedVector2Array([d - up, c - up, c, d]), PackedColorArray([left]))
	draw_polygon(PackedVector2Array([b - up, c - up, c, b]), PackedColorArray([right]))
	draw_polygon(PackedVector2Array([a - up, b - up, c - up, d - up]), PackedColorArray([top]))

func _draw_entrance() -> void:
	var a: Vector2 = _iso(10.0, 0.0)
	var b: Vector2 = _iso(12.0, 0.0)
	var h: float = 88.0
	draw_polygon(
		PackedVector2Array([a, b, b - Vector2(0, h), a - Vector2(0, h)]),
		PackedColorArray([Color("#091118")])
	)

	var glow: Color = Color("#29e7ff")
	draw_line(a, a - Vector2(0, h), glow, 4.0)
	draw_line(b, b - Vector2(0, h), glow, 4.0)
	draw_line(a - Vector2(0, h), b - Vector2(0, h), glow, 4.0)

	var sign_pos: Vector2 = (a + b) * 0.5 - Vector2(0, h + 14)
	draw_string(ThemeDB.fallback_font, sign_pos + Vector2(-27, 0), "ENTRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#b8f7ff"))

func _draw_dj_booth() -> void:
	_draw_iso_box(4.8, 1.0, 4.4, 1.8, 10.0, Color("#21172f"), Color("#130f1b"), Color("#191223"))
	_draw_iso_box(5.3, 1.35, 3.4, 1.0, 46.0, Color("#51256f"), Color("#281535"), Color("#351a47"))

	var front_a: Vector2 = _iso(5.55, 2.35) - Vector2(0, 28)
	var front_b: Vector2 = _iso(8.45, 2.35) - Vector2(0, 28)
	draw_line(front_a, front_b, Color("#2de1ff"), 3.0)

	var left_deck: Vector2 = _iso(6.25, 1.85) - Vector2(0, 52)
	var right_deck: Vector2 = _iso(7.75, 1.85) - Vector2(0, 52)
	_draw_deck(left_deck)
	_draw_deck(right_deck)

func _draw_deck(pos: Vector2) -> void:
	draw_set_transform(pos, 0.0, Vector2(1.0, 0.48))
	draw_circle(Vector2.ZERO, 11.0, Color("#17131d"))
	draw_circle(Vector2.ZERO, 6.5, Color("#dc4cff"))
	draw_circle(Vector2.ZERO, 2.0, Color("#0c0a10"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_bar() -> void:
	_draw_iso_box(0.95, 2.7, 1.15, 5.5, 38.0, Color("#315f7b"), Color("#142b3a"), Color("#1d3e52"))
	_draw_iso_box(0.62, 2.45, 0.42, 5.8, 22.0, Color("#183244"), Color("#10222f"), Color("#142a39"))

	var bar_start: Vector2 = _iso(1.15, 3.0) - Vector2(0, 41)
	var bar_end: Vector2 = _iso(1.15, 7.7) - Vector2(0, 41)
	draw_line(bar_start, bar_end, Color("#2de3ff"), 3.0)

	for i in range(4):
		var stool: Vector2 = _iso(2.45, 3.55 + float(i) * 1.05)
		draw_set_transform(stool - Vector2(0, 10), 0.0, Vector2(1.0, 0.52))
		draw_circle(Vector2.ZERO, 9.0, Color("#a943cc"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_line(stool - Vector2(0, 6), stool + Vector2(0, 9), Color("#40334a"), 3.0)

func _draw_lounges() -> void:
	_draw_booth(10.25, 2.8, Color("#512761"), Color("#a64fc6"))
	_draw_booth(10.35, 5.85, Color("#283f63"), Color("#4fcfff"))
	_draw_booth(2.6, 8.0, Color("#4b275e"), Color("#d054ff"))

func _draw_booth(x: float, y: float, base: Color, neon: Color) -> void:
	_draw_iso_box(x, y, 2.4, 0.85, 22.0, base.lightened(0.10), base.darkened(0.30), base.darkened(0.15))
	_draw_iso_box(x + 0.10, y - 0.18, 2.2, 0.34, 36.0, base.lightened(0.05), base.darkened(0.34), base.darkened(0.20))
	var a: Vector2 = _iso(x + 0.2, y + 0.82) - Vector2(0, 14)
	var b: Vector2 = _iso(x + 2.2, y + 0.82) - Vector2(0, 14)
	draw_line(a, b, neon, 2.4)

func _draw_tables() -> void:
	_draw_round_table(11.2, 8.1, Color("#352348"))
	_draw_round_table(3.6, 6.7, Color("#2c334f"))

func _draw_round_table(x: float, y: float, top_color: Color) -> void:
	var pos: Vector2 = _iso(x, y)
	draw_line(pos - Vector2(0, 4), pos + Vector2(0, 14), Color("#3c3446"), 4.0)
	draw_set_transform(pos - Vector2(0, 9), 0.0, Vector2(1.0, 0.48))
	draw_circle(Vector2.ZERO, 18.0, top_color)
	draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 30, Color("#9d5bc3"), 1.4)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_npcs() -> void:
	for i in range(npc_positions.size()):
		var pos: Vector2 = _iso(npc_positions[i].x, npc_positions[i].y)
		var bob: float = sin(anim_time * 2.6 + float(i) * 0.7) * 1.6
		_draw_avatar(pos - Vector2(0, bob), npc_colors[i], i < 6)

func _draw_avatar(pos: Vector2, shirt: Color, dancing: bool) -> void:
	var skin: Color = Color("#e0aa84")
	var hair: Color = Color("#211720")
	var sway: float = 0.0
	if dancing:
		sway = sin(anim_time * 3.2 + pos.x * 0.01) * 2.5

	draw_set_transform(pos + Vector2(0, 9), 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, 14.0, Color(0.0, 0.0, 0.0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var hip: Vector2 = pos - Vector2(0, 3)
	var shoulder: Vector2 = pos - Vector2(sway * 0.25, 19)
	var torso: PackedVector2Array = PackedVector2Array([
		shoulder + Vector2(-7, 0),
		shoulder + Vector2(7, 0),
		hip + Vector2(5, 0),
		hip + Vector2(-5, 0)
	])
	draw_polygon(torso, PackedColorArray([shirt]))

	draw_line(hip + Vector2(-2, 0), pos + Vector2(-5, 12), Color("#211d2b"), 4.0)
	draw_line(hip + Vector2(2, 0), pos + Vector2(5, 12), Color("#211d2b"), 4.0)

	var arm_y: float = shoulder.y + 6.0
	if dancing:
		draw_line(Vector2(shoulder.x - 5, arm_y), Vector2(shoulder.x - 11 - sway, arm_y - 6), skin, 3.0)
		draw_line(Vector2(shoulder.x + 5, arm_y), Vector2(shoulder.x + 11 + sway, arm_y - 3), skin, 3.0)
	else:
		draw_line(Vector2(shoulder.x - 5, arm_y), Vector2(shoulder.x - 8, arm_y + 8), skin, 3.0)
		draw_line(Vector2(shoulder.x + 5, arm_y), Vector2(shoulder.x + 8, arm_y + 8), skin, 3.0)

	var head: Vector2 = shoulder - Vector2(0, 12)
	draw_circle(head, 10.0, skin)
	draw_arc(head - Vector2(0, 2), 9.5, PI, TAU, 16, hair, 5.5)

func _draw_light_accents() -> void:
	var center: Vector2 = _iso(7.2, 5.8)
	var pulse: float = 0.55 + sin(anim_time * 1.6) * 0.10
	draw_arc(center, 160.0, PI * 1.10, PI * 1.90, 44, Color(0.52, 0.20, 1.0, 0.10 * pulse), 4.0)
	draw_arc(center, 198.0, PI * 1.08, PI * 1.92, 44, Color(0.10, 0.80, 1.0, 0.06 * pulse), 3.0)
