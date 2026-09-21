extends Node2D

const TILE_W := 72.0
const TILE_H := 36.0
const CLUB_W := 14
const CLUB_H := 11
const WALL_H := 112.0

@onready var camera: Camera2D = $Camera2D

var dragging := false
var zoom_level := 1.0
var anim_time := 0.0

var npc_data := [
	{"p": Vector2(5.4, 5.4), "shirt": Color("#ff4fa3"), "skin": Color("#e9b08c"), "hair": Color("#241625"), "phase": 0.2},
	{"p": Vector2(6.5, 4.8), "shirt": Color("#51d9ff"), "skin": Color("#c88462"), "hair": Color("#171118"), "phase": 1.1},
	{"p": Vector2(7.4, 5.6), "shirt": Color("#9b65ff"), "skin": Color("#f0bf9a"), "hair": Color("#4b2e1f"), "phase": 2.0},
	{"p": Vector2(8.2, 4.9), "shirt": Color("#ffbd45"), "skin": Color("#8f573f"), "hair": Color("#18141a"), "phase": 2.7},
	{"p": Vector2(6.0, 6.6), "shirt": Color("#66e39a"), "skin": Color("#d99a75"), "hair": Color("#34221c"), "phase": 3.4},
	{"p": Vector2(7.5, 6.7), "shirt": Color("#ff6470"), "skin": Color("#f2c7a7"), "hair": Color("#24151c"), "phase": 4.1},
	{"p": Vector2(2.8, 5.1), "shirt": Color("#d46dff"), "skin": Color("#bf7e5d"), "hair": Color("#15131a"), "phase": 0.8},
	{"p": Vector2(3.1, 6.7), "shirt": Color("#50c8ff"), "skin": Color("#e4ae86"), "hair": Color("#6b4027"), "phase": 1.8},
	{"p": Vector2(10.8, 4.8), "shirt": Color("#f56cff"), "skin": Color("#8a533d"), "hair": Color("#181218"), "phase": 2.3},
	{"p": Vector2(9.4, 8.2), "shirt": Color("#6fe4c2"), "skin": Color("#edbe9e"), "hair": Color("#3b261d"), "phase": 3.0}
]

func _ready() -> void:
	print("Nightclub City Level 1 visual pass loaded.")
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
	draw_rect(Rect2(-5000, -5000, 10000, 10000), Color("#08060f"))
	_draw_room_shadow()
	_draw_floor()
	_draw_dance_floor_glow()
	_draw_walls()
	_draw_wall_details()
	_draw_dj_zone()
	_draw_bar_zone()
	_draw_lounge_zone()
	_draw_tables()
	_draw_entrance()
	_draw_npcs()
	_draw_ambient_accents()

func _draw_room_shadow() -> void:
	var poly := _tile_points(-0.25, -0.25, CLUB_W + 0.5, CLUB_H + 0.5)
	for i in range(poly.size()):
		poly[i] += Vector2(0, 20)
	draw_polygon(poly, PackedColorArray([Color(0, 0, 0, 0.42)]))

func _draw_floor() -> void:
	for y in range(CLUB_H):
		for x in range(CLUB_W):
			var base := Color("#171420")
			if (x + y) % 2 == 0:
				base = Color("#1b1726")
			if x < 2 or y < 2:
				base = base.darkened(0.08)
			draw_polygon(_tile_points(x, y), PackedColorArray([base]))

			var p := _tile_points(x, y)
			for i in range(4):
				draw_line(p[i], p[(i + 1) % 4], Color(0.27, 0.22, 0.36, 0.24), 0.8)

	var edge := _tile_points(0, 0, CLUB_W, CLUB_H)
	for i in range(4):
		draw_line(edge[i], edge[(i + 1) % 4], Color("#322742"), 3.0)

func _draw_walls() -> void:
	for x in range(CLUB_W):
		if x == 10 or x == 11:
			continue
		var a := _iso(x, 0)
		var b := _iso(x + 1, 0)
		var wall := PackedVector2Array([a, b, b - Vector2(0, WALL_H), a - Vector2(0, WALL_H)])
		var shade := Color("#24192f") if x % 2 == 0 else Color("#291d36")
		draw_polygon(wall, PackedColorArray([shade]))
		draw_line(a - Vector2(0, WALL_H), b - Vector2(0, WALL_H), Color("#a93eff"), 2.4)

	for y in range(CLUB_H):
		var a := _iso(0, y)
		var b := _iso(0, y + 1)
		var wall := PackedVector2Array([a, b, b - Vector2(0, WALL_H), a - Vector2(0, WALL_H)])
		var shade := Color("#172536") if y % 2 == 0 else Color("#1a2a3d")
		draw_polygon(wall, PackedColorArray([shade]))
		draw_line(a - Vector2(0, WALL_H), b - Vector2(0, WALL_H), Color("#24d8ff"), 2.4)

func _draw_wall_details() -> void:
	var logo_pos := _iso(6.8, 0.0) - Vector2(0, 68)
	draw_circle(logo_pos, 25.0, Color(0.65, 0.20, 1.0, 0.14))
	draw_circle(logo_pos, 18.0, Color("#7c2cff"))
	draw_circle(logo_pos, 12.0, Color("#171020"))
	draw_string(ThemeDB.fallback_font, logo_pos + Vector2(-8, 5), "NC", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#f1d9ff"))

	var strip_a := _iso(3.0, 0) - Vector2(0, 48)
	var strip_b := _iso(4.5, 0) - Vector2(0, 48)
	draw_line(strip_a, strip_b, Color("#ff3fc8"), 4.0)
	draw_line(strip_a + Vector2(0, 8), strip_b + Vector2(0, 8), Color(1.0, 0.25, 0.78, 0.22), 8.0)

	var strip_c := _iso(1.2, 1.8) - Vector2(0, 62)
	var strip_d := _iso(1.2, 3.4) - Vector2(0, 62)
	draw_line(strip_c, strip_d, Color("#2ee5ff"), 3.5)

func _draw_dance_floor_glow() -> void:
	var center := _iso(7.0, 5.9)
	for r in [180.0, 145.0, 110.0]:
		var alpha := 0.018 + (180.0 - r) * 0.00018
		draw_circle(center, r, Color(0.44, 0.15, 0.92, alpha))

	var colors := [
		Color("#7c36ff"),
		Color("#ff3ebf"),
		Color("#24d8ff"),
		Color("#543aff")
	]

	for y in range(4, 8):
		for x in range(5, 10):
			var c: Color = colors[(x + y) % colors.size()]
			var pulse := 0.04 * sin(anim_time * 1.8 + float(x + y))
			draw_polygon(_tile_points(x, y), PackedColorArray([c.darkened(0.32 - pulse)]))
			var p := _tile_points(x, y)
			for i in range(4):
				draw_line(p[i], p[(i + 1) % 4], c.lightened(0.12), 1.4)

func _draw_iso_box(x: float, y: float, width: float, depth: float, height: float, top: Color, left: Color, right: Color, outline := Color.TRANSPARENT) -> void:
	var a := _iso(x, y)
	var b := _iso(x + width, y)
	var c := _iso(x + width, y + depth)
	var d := _iso(x, y + depth)
	var up := Vector2(0, height)

	draw_polygon(PackedVector2Array([d - up, c - up, c, d]), PackedColorArray([left]))
	draw_polygon(PackedVector2Array([b - up, c - up, c, b]), PackedColorArray([right]))
	draw_polygon(PackedVector2Array([a - up, b - up, c - up, d - up]), PackedColorArray([top]))

	if outline.a > 0.0:
		var top_poly := PackedVector2Array([a - up, b - up, c - up, d - up])
		for i in range(4):
			draw_line(top_poly[i], top_poly[(i + 1) % 4], outline, 1.4)

func _draw_dj_zone() -> void:
	_draw_iso_box(4.7, 1.0, 4.6, 2.0, 10.0, Color("#21172f"), Color("#130f1b"), Color("#191223"), Color("#52306b"))
	_draw_iso_box(5.25, 1.30, 3.5, 1.05, 47.0, Color("#4b2468"), Color("#261532"), Color("#341943"), Color("#b44cff"))

	var front_a := _iso(5.55, 2.35) - Vector2(0, 27)
	var front_b := _iso(8.45, 2.35) - Vector2(0, 27)
	draw_line(front_a, front_b, Color("#27e1ff"), 3.0)
	draw_line(front_a + Vector2(0, 6), front_b + Vector2(0, 6), Color(0.15, 0.88, 1.0, 0.20), 8.0)

	for offset in [-0.75, 0.75]:
		var deck := _iso(7.0 + offset, 1.82) - Vector2(0, 53)
		draw_set_transform(deck, 0.0, Vector2(1.0, 0.48))
		draw_circle(Vector2.ZERO, 12.0, Color("#17131d"))
		draw_circle(Vector2.ZERO, 7.0, Color("#de4cff"))
		draw_circle(Vector2.ZERO, 2.5, Color("#0c0a10"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var dj := _iso(7.0, 1.75)
	_draw_avatar_at_screen(dj - Vector2(0, 45), Color("#d84cff"), Color("#e4ac87"), Color("#161217"), 0.0, false)

func _draw_bar_zone() -> void:
	_draw_iso_box(0.95, 2.75, 1.15, 5.45, 39.0, Color("#2d5872"), Color("#142b3a"), Color("#1d3e52"), Color("#2adfff"))
	_draw_iso_box(0.65, 2.45, 0.45, 5.75, 22.0, Color("#183244"), Color("#10222f"), Color("#142a39"))

	for shelf in range(3):
		var shelf_start := _iso(0.25, 3.1 + shelf * 1.45) - Vector2(0, 74)
		var shelf_end := _iso(0.25, 4.0 + shelf * 1.45) - Vector2(0, 74)
		draw_line(shelf_start, shelf_end, Color("#33ddff"), 2.0)
		for bottle in range(3):
			var t := float(bottle + 1) / 4.0
			var bp := shelf_start.lerp(shelf_end, t)
			draw_line(bp, bp - Vector2(0, 8), Color("#e852ff") if bottle % 2 == 0 else Color("#45e6c1"), 3.0)

	for i in range(4):
		var stool := _iso(2.45, 3.55 + i * 1.05)
		draw_set_transform(stool - Vector2(0, 10), 0.0, Vector2(1.0, 0.52))
		draw_circle(Vector2.ZERO, 9.0, Color("#a943cc"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		draw_line(stool - Vector2(0, 6), stool + Vector2(0, 9), Color("#40334a"), 3.0)

func _draw_lounge_zone() -> void:
	_draw_booth(10.25, 2.8, Color("#512761"), Color("#a64fc6"))
	_draw_booth(10.35, 5.85, Color("#283f63"), Color("#4fcfff"))
	_draw_booth(2.6, 8.0, Color("#4b275e"), Color("#d054ff"))

func _draw_booth(x: float, y: float, base: Color, neon: Color) -> void:
	_draw_iso_box(x, y, 2.4, 0.85, 22.0, base.lightened(0.10), base.darkened(0.30), base.darkened(0.15), neon)
	_draw_iso_box(x + 0.10, y - 0.18, 2.2, 0.34, 38.0, base.lightened(0.05), base.darkened(0.34), base.darkened(0.20))
	var glow_a := _iso(x + 0.2, y + 0.82) - Vector2(0, 14)
	var glow_b := _iso(x + 2.2, y + 0.82) - Vector2(0, 14)
	draw_line(glow_a, glow_b, neon, 2.5)

func _draw_tables() -> void:
	_draw_round_table(11.2, 8.1, Color("#352348"))
	_draw_round_table(3.6, 6.7, Color("#2c334f"))

func _draw_round_table(x: float, y: float, top: Color) -> void:
	var pos := _iso(x, y)
	draw_line(pos - Vector2(0, 4), pos + Vector2(0, 14), Color("#3c3446"), 4.0)
	draw_set_transform(pos - Vector2(0, 9), 0.0, Vector2(1.0, 0.48))
	draw_circle(Vector2.ZERO, 18.0, top)
	draw_arc(Vector2.ZERO, 18.0, 0.0, TAU, 30, Color("#9d5bc3"), 1.4)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_entrance() -> void:
	var a := _iso(10.0, 0.0)
	var b := _iso(12.0, 0.0)
	var h := 91.0
	var door_poly := PackedVector2Array([a, b, b - Vector2(0, h), a - Vector2(0, h)])
	draw_polygon(door_poly, PackedColorArray([Color("#091118")]))

	var glow := Color("#27e7ff")
	draw_line(a, a - Vector2(0, h), glow, 4.0)
	draw_line(b, b - Vector2(0, h), glow, 4.0)
	draw_line(a - Vector2(0, h), b - Vector2(0, h), glow, 4.0)

	var sign_pos := (a + b) * 0.5 - Vector2(0, h + 14)
	draw_string(ThemeDB.fallback_font, sign_pos + Vector2(-28, 0), "ENTRY", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#b8f7ff"))

	var mat := _tile_points(10.0, 0.7, 2.0, 1.15)
	draw_polygon(mat, PackedColorArray([Color("#111a26")]))

func _draw_npcs() -> void:
	for i in range(npc_data.size()):
		var data = npc_data[i]
		var pos: Vector2 = _iso(data["p"].x, data["p"].y)
		var bob := sin(anim_time * 2.7 + float(data["phase"])) * 2.0
		var dance := i < 6
		_draw_avatar_at_screen(pos - Vector2(0, bob), data["shirt"], data["skin"], data["hair"], float(data["phase"]), dance)

func _draw_avatar_at_screen(pos: Vector2, shirt: Color, skin: Color, hair: Color, phase: float, dancing: bool) -> void:
	var sway := 0.0
	if dancing:
		sway = sin(anim_time * 3.4 + phase) * 3.0

	draw_set_transform(pos + Vector2(0, 9), 0.0, Vector2(1.0, 0.42))
	draw_circle(Vector2.ZERO, 14.0, Color(0, 0, 0, 0.28))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var hip := pos - Vector2(0, 3)
	var shoulder := pos - Vector2(sway * 0.25, 19)
	var torso := PackedVector2Array([
		shoulder + Vector2(-7, 0),
		shoulder + Vector2(7, 0),
		hip + Vector2(5, 0),
		hip + Vector2(-5, 0)
	])
	draw_polygon(torso, PackedColorArray([shirt]))

	var leg_color := Color("#211d2b")
	draw_line(hip + Vector2(-2, 0), pos + Vector2(-5, 12), leg_color, 4.0)
	draw_line(hip + Vector2(2, 0), pos + Vector2(5, 12), leg_color, 4.0)

	var arm_y := shoulder.y + 6
	if dancing:
		draw_line(Vector2(shoulder.x - 5, arm_y), Vector2(shoulder.x - 11 - sway, arm_y - 6), skin, 3.2)
		draw_line(Vector2(shoulder.x + 5, arm_y), Vector2(shoulder.x + 11 + sway, arm_y - 3), skin, 3.2)
	else:
		draw_line(Vector2(shoulder.x - 5, arm_y), Vector2(shoulder.x - 8, arm_y + 8), skin, 3.2)
		draw_line(Vector2(shoulder.x + 5, arm_y), Vector2(shoulder.x + 8, arm_y + 8), skin, 3.2)

	var head := shoulder - Vector2(0, 12)
	draw_circle(head, 10.5, skin)
	draw_arc(head - Vector2(0, 2), 10.0, PI, TAU, 16, hair, 6.0)
	draw_circle(head + Vector2(-3.2, 1.0), 1.1, Color("#1b1520"))
	draw_circle(head + Vector2(3.2, 1.0), 1.1, Color("#1b1520"))

func _draw_ambient_accents() -> void:
	var dance_center := _iso(7.3, 5.8)
	var pulse := 0.55 + sin(anim_time * 1.7) * 0.10
	draw_arc(dance_center, 165.0, PI * 1.10, PI * 1.90, 44, Color(0.52, 0.20, 1.0, 0.12 * pulse), 5.0)
	draw_arc(dance_center, 205.0, PI * 1.08, PI * 1.92, 44, Color(0.10, 0.80, 1.0, 0.07 * pulse), 4.0)
