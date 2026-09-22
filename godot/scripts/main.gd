extends Node2D

const TILE_W: float = 72.0
const TILE_H: float = 36.0
const CLUB_W: int = 14
const CLUB_H: int = 11
const WALL_H: float = 108.0

@onready var camera: Camera2D = $Camera2D
@onready var zoom_out_button: Button = $HUD/ZoomControls/ZoomOut
@onready var zoom_in_button: Button = $HUD/ZoomControls/ZoomIn
@onready var design_button: Button = $HUD/DesignButton
@onready var design_drawer: ColorRect = $HUD/DesignDrawer
@onready var close_design_button: Button = $HUD/DesignDrawer/Close
@onready var bars_button: Button = $HUD/DesignDrawer/Bars
@onready var seating_button: Button = $HUD/DesignDrawer/Seating
@onready var dance_button: Button = $HUD/DesignDrawer/Dance
@onready var walls_button: Button = $HUD/DesignDrawer/Walls
@onready var decor_button: Button = $HUD/DesignDrawer/Decor
@onready var item_button_1: Button = $HUD/DesignDrawer/Item1
@onready var item_button_2: Button = $HUD/DesignDrawer/Item2
@onready var item_button_3: Button = $HUD/DesignDrawer/Item3
@onready var design_hint: Label = $HUD/DesignDrawer/Hint
@onready var selection_panel: ColorRect = $HUD/SelectionPanel
@onready var selected_name: Label = $HUD/SelectionPanel/SelectedName
@onready var move_button: Button = $HUD/SelectionPanel/Move
@onready var rotate_button: Button = $HUD/SelectionPanel/Rotate
@onready var delete_button: Button = $HUD/SelectionPanel/Delete
@onready var done_button: Button = $HUD/SelectionPanel/Done

var dragging: bool = false
var zoom_level: float = 1.0
var anim_time: float = 0.0
var selected_category: String = "Bars"
var current_item: Dictionary = {}
var hover_tile: Vector2i = Vector2i(-1, -1)
var placed_objects: Array = []
var selected_object_index: int = -1
var moving_object_index: int = -1
const SAVE_PATH: String = "user://club_layout.json"

var item_catalog: Dictionary = {
	"Bars": [
		{"id": "starter_bar", "name": "Starter Bar", "w": 1, "d": 3, "kind": "bar", "color": Color("#2f6582")},
		{"id": "compact_bar", "name": "Compact Bar", "w": 2, "d": 2, "kind": "bar", "color": Color("#5b337b")},
		{"id": "neon_bar", "name": "Neon Bar", "w": 1, "d": 4, "kind": "bar", "color": Color("#315f78")}
	],
	"Seating": [
		{"id": "booth", "name": "Lounge Booth", "w": 2, "d": 1, "kind": "seat", "color": Color("#5b2d70")},
		{"id": "sofa", "name": "Club Sofa", "w": 2, "d": 1, "kind": "seat", "color": Color("#294a70")},
		{"id": "chair", "name": "Accent Chair", "w": 1, "d": 1, "kind": "seat", "color": Color("#7a3f82")}
	],
	"Dance": [
		{"id": "dance_tile", "name": "Dance Tile", "w": 1, "d": 1, "kind": "dance", "color": Color("#7c36ff")},
		{"id": "dance_block", "name": "2x2 Dance Floor", "w": 2, "d": 2, "kind": "dance", "color": Color("#ff3ebf")}
	],
	"Walls": [
		{"id": "neon_divider", "name": "Neon Divider", "w": 2, "d": 1, "kind": "wall", "color": Color("#2ddfff")},
		{"id": "purple_divider", "name": "Purple Divider", "w": 2, "d": 1, "kind": "wall", "color": Color("#a13dff")}
	],
	"Decor": [
		{"id": "round_table", "name": "Round Table", "w": 1, "d": 1, "kind": "table", "color": Color("#4b335e")},
		{"id": "neon_pillar", "name": "Neon Pillar", "w": 1, "d": 1, "kind": "pillar", "color": Color("#28dfff")},
		{"id": "purple_pillar", "name": "Purple Pillar", "w": 1, "d": 1, "kind": "pillar", "color": Color("#c24cff")}
	]
}

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
	print("Nightclub City Design Mode v1 loaded.")
	zoom_out_button.pressed.connect(_zoom_out)
	zoom_in_button.pressed.connect(_zoom_in)
	design_button.pressed.connect(_toggle_design_drawer)
	close_design_button.pressed.connect(_close_design_drawer)
	bars_button.pressed.connect(_set_category.bind("Bars"))
	seating_button.pressed.connect(_set_category.bind("Seating"))
	dance_button.pressed.connect(_set_category.bind("Dance"))
	walls_button.pressed.connect(_set_category.bind("Walls"))
	decor_button.pressed.connect(_set_category.bind("Decor"))
	item_button_1.pressed.connect(_select_item.bind(0))
	item_button_2.pressed.connect(_select_item.bind(1))
	item_button_3.pressed.connect(_select_item.bind(2))
	move_button.pressed.connect(_move_selected_object)
	rotate_button.pressed.connect(_rotate_selected_object)
	delete_button.pressed.connect(_delete_selected_object)
	done_button.pressed.connect(_deselect_object)
	_load_layout()
	_set_category("Bars")
	queue_redraw()

func _process(delta: float) -> void:
	anim_time += delta
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if not current_item.is_empty():
			_cancel_placement()
		else:
			_deselect_object()
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_set_zoom(zoom_level + 0.08)
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_set_zoom(zoom_level - 0.08)
			return

		if not current_item.is_empty():
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				hover_tile = _world_to_tile(get_global_mouse_position())
				if _can_place_current(hover_tile):
					_place_current_item(hover_tile)
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				_cancel_placement()
			return

		if design_drawer.visible and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var clicked_tile: Vector2i = _world_to_tile(get_global_mouse_position())
			var object_index: int = _find_object_at_tile(clicked_tile)
			if object_index >= 0:
				_select_placed_object(object_index)
			else:
				_deselect_object()
			return

		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed

	elif event is InputEventMouseMotion:
		if not current_item.is_empty():
			hover_tile = _world_to_tile(get_global_mouse_position())
			queue_redraw()
		elif dragging:
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
	_draw_placed_objects()
	_draw_selection_highlight()
	_draw_npcs()
	_draw_light_accents()
	_draw_placement_preview()

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


func _toggle_design_drawer() -> void:
	design_drawer.visible = not design_drawer.visible
	if not design_drawer.visible:
		_cancel_placement()
		_deselect_object()

func _close_design_drawer() -> void:
	design_drawer.visible = false
	_cancel_placement()
	_deselect_object()

func _set_category(category: String) -> void:
	selected_category = category
	_cancel_placement()
	var items: Array = item_catalog[category]
	var buttons: Array[Button] = [item_button_1, item_button_2, item_button_3]
	for i in range(buttons.size()):
		if i < items.size():
			buttons[i].visible = true
			buttons[i].text = str(items[i]["name"])
		else:
			buttons[i].visible = false
	design_hint.text = category + " selected • choose an item to place"

func _select_item(index: int) -> void:
	var items: Array = item_catalog[selected_category]
	if index < 0 or index >= items.size():
		return
	moving_object_index = -1
	_deselect_object()
	current_item = items[index].duplicate(true)
	hover_tile = _world_to_tile(get_global_mouse_position())
	design_hint.text = str(current_item["name"]) + " selected • click floor to place • right-click/Esc cancels"
	queue_redraw()

func _cancel_placement() -> void:
	current_item = {}
	moving_object_index = -1
	hover_tile = Vector2i(-1, -1)
	if design_drawer.visible:
		design_hint.text = selected_category + " selected • choose an item to place"
	queue_redraw()

func _world_to_tile(world_pos: Vector2) -> Vector2i:
	var tile_x: float = world_pos.y / TILE_H + world_pos.x / TILE_W
	var tile_y: float = world_pos.y / TILE_H - world_pos.x / TILE_W
	return Vector2i(int(floor(tile_x)), int(floor(tile_y)))

func _can_place_current(tile: Vector2i) -> bool:
	if current_item.is_empty():
		return false
	return _can_place_dimensions(
		tile,
		int(current_item["w"]),
		int(current_item["d"]),
		moving_object_index
	)

func _can_place_dimensions(tile: Vector2i, width: int, depth: int, skip_index: int = -1) -> bool:
	if tile.x < 0 or tile.y < 0:
		return false
	if tile.x + width > CLUB_W or tile.y + depth > CLUB_H:
		return false

	for i in range(placed_objects.size()):
		if i == skip_index:
			continue
		var obj: Dictionary = placed_objects[i]
		var ox: int = int(obj["x"])
		var oy: int = int(obj["y"])
		var ow: int = int(obj["w"])
		var od: int = int(obj["d"])
		var overlaps: bool = tile.x < ox + ow and tile.x + width > ox and tile.y < oy + od and tile.y + depth > oy
		if overlaps:
			return false
	return true

func _place_current_item(tile: Vector2i) -> void:
	if not _can_place_current(tile):
		return

	if moving_object_index >= 0 and moving_object_index < placed_objects.size():
		placed_objects[moving_object_index]["x"] = tile.x
		placed_objects[moving_object_index]["y"] = tile.y
		selected_object_index = moving_object_index
		moving_object_index = -1
		current_item = {}
		hover_tile = Vector2i(-1, -1)
		_refresh_selection_panel()
		_save_layout()
		queue_redraw()
		return

	var placed: Dictionary = current_item.duplicate(true)
	placed["x"] = tile.x
	placed["y"] = tile.y
	placed_objects.append(placed)
	design_hint.text = str(current_item["name"]) + " placed • click again to place another"
	_save_layout()
	queue_redraw()

func _draw_placed_objects() -> void:
	for obj in placed_objects:
		_draw_build_item(obj)

func _draw_build_item(obj: Dictionary) -> void:
	var x: float = float(obj["x"])
	var y: float = float(obj["y"])
	var width: float = float(obj["w"])
	var depth: float = float(obj["d"])
	var kind: String = str(obj["kind"])
	var color: Color = obj["color"]

	if kind == "bar":
		_draw_iso_box(x, y, width, depth, 34.0, color.lightened(0.08), color.darkened(0.34), color.darkened(0.18))
		var a: Vector2 = _iso(x + 0.10, y + depth) - Vector2(0, 22)
		var b: Vector2 = _iso(x + width - 0.10, y + depth) - Vector2(0, 22)
		draw_line(a, b, Color("#2de3ff"), 2.5)
	elif kind == "seat":
		_draw_iso_box(x, y, width, depth, 20.0, color.lightened(0.10), color.darkened(0.30), color.darkened(0.15))
		_draw_iso_box(x + 0.08, y, width - 0.16, 0.28, 34.0, color.lightened(0.04), color.darkened(0.34), color.darkened(0.20))
	elif kind == "dance":
		for dy in range(int(depth)):
			for dx in range(int(width)):
				var c: Color = color
				if (dx + dy) % 2 == 1:
					c = color.lightened(0.16)
				draw_polygon(_tile_points(x + dx, y + dy, 1.0, 1.0), PackedColorArray([c.darkened(0.16)]))
				var tile: PackedVector2Array = _tile_points(x + dx, y + dy, 1.0, 1.0)
				for i in range(4):
					draw_line(tile[i], tile[(i + 1) % 4], c.lightened(0.18), 1.5)
	elif kind == "wall":
		_draw_iso_box(x, y, width, depth, 64.0, color.darkened(0.25), color.darkened(0.50), color.darkened(0.36))
		var wall_a: Vector2 = _iso(x, y + depth) - Vector2(0, 48)
		var wall_b: Vector2 = _iso(x + width, y + depth) - Vector2(0, 48)
		draw_line(wall_a, wall_b, color, 3.0)
	elif kind == "table":
		_draw_round_table(x + 0.5, y + 0.5, color)
	elif kind == "pillar":
		_draw_iso_box(x + 0.30, y + 0.30, 0.40, 0.40, 58.0, color.lightened(0.18), color.darkened(0.42), color.darkened(0.26))
		var glow_pos: Vector2 = _iso(x + 0.5, y + 0.5) - Vector2(0, 62)
		draw_circle(glow_pos, 8.0, color)

func _draw_placement_preview() -> void:
	if current_item.is_empty() or hover_tile.x < 0 or hover_tile.y < 0:
		return
	var width: float = float(current_item["w"])
	var depth: float = float(current_item["d"])
	var valid: bool = _can_place_current(hover_tile)
	var preview_color: Color = Color(0.18, 0.95, 0.58, 0.28)
	var line_color: Color = Color("#55f0a0")
	if not valid:
		preview_color = Color(1.0, 0.20, 0.32, 0.28)
		line_color = Color("#ff4a63")

	var footprint: PackedVector2Array = _tile_points(float(hover_tile.x), float(hover_tile.y), width, depth)
	draw_polygon(footprint, PackedColorArray([preview_color]))
	for i in range(4):
		draw_line(footprint[i], footprint[(i + 1) % 4], line_color, 2.5)


func _find_object_at_tile(tile: Vector2i) -> int:
	var found: int = -1
	for i in range(placed_objects.size()):
		var obj: Dictionary = placed_objects[i]
		var ox: int = int(obj["x"])
		var oy: int = int(obj["y"])
		var ow: int = int(obj["w"])
		var od: int = int(obj["d"])
		if tile.x >= ox and tile.x < ox + ow and tile.y >= oy and tile.y < oy + od:
			found = i
	return found

func _select_placed_object(index: int) -> void:
	if index < 0 or index >= placed_objects.size():
		return
	selected_object_index = index
	moving_object_index = -1
	current_item = {}
	hover_tile = Vector2i(-1, -1)
	_refresh_selection_panel()
	queue_redraw()

func _deselect_object() -> void:
	selected_object_index = -1
	moving_object_index = -1
	selection_panel.visible = false
	queue_redraw()

func _refresh_selection_panel() -> void:
	if selected_object_index < 0 or selected_object_index >= placed_objects.size():
		selection_panel.visible = false
		return
	selection_panel.visible = true
	var obj: Dictionary = placed_objects[selected_object_index]
	selected_name.text = str(obj["name"])

func _move_selected_object() -> void:
	if selected_object_index < 0 or selected_object_index >= placed_objects.size():
		return
	moving_object_index = selected_object_index
	current_item = placed_objects[selected_object_index].duplicate(true)
	hover_tile = Vector2i(int(current_item["x"]), int(current_item["y"]))
	design_hint.text = "Moving " + str(current_item["name"]) + " • click a new tile • Esc cancels"
	queue_redraw()

func _rotate_selected_object() -> void:
	if selected_object_index < 0 or selected_object_index >= placed_objects.size():
		return

	var obj: Dictionary = placed_objects[selected_object_index]
	var old_w: int = int(obj["w"])
	var old_d: int = int(obj["d"])
	var tile: Vector2i = Vector2i(int(obj["x"]), int(obj["y"]))
	var new_w: int = old_d
	var new_d: int = old_w

	if not _can_place_dimensions(tile, new_w, new_d, selected_object_index):
		if design_drawer.visible:
			design_hint.text = "Not enough room to rotate " + str(obj["name"])
		return

	placed_objects[selected_object_index]["w"] = new_w
	placed_objects[selected_object_index]["d"] = new_d
	_save_layout()
	_refresh_selection_panel()
	queue_redraw()

func _delete_selected_object() -> void:
	if selected_object_index < 0 or selected_object_index >= placed_objects.size():
		return
	placed_objects.remove_at(selected_object_index)
	selected_object_index = -1
	moving_object_index = -1
	selection_panel.visible = false
	if design_drawer.visible:
		design_hint.text = "Item deleted • choose another item or select an existing object"
	_save_layout()
	queue_redraw()

func _draw_selection_highlight() -> void:
	if selected_object_index < 0 or selected_object_index >= placed_objects.size():
		return
	var obj: Dictionary = placed_objects[selected_object_index]
	var footprint: PackedVector2Array = _tile_points(
		float(obj["x"]),
		float(obj["y"]),
		float(obj["w"]),
		float(obj["d"])
	)
	draw_polygon(footprint, PackedColorArray([Color(0.20, 0.82, 1.0, 0.16)]))
	for i in range(4):
		draw_line(footprint[i], footprint[(i + 1) % 4], Color("#58dcff"), 3.0)

func _save_layout() -> void:
	var save_data: Array = []
	for obj in placed_objects:
		var color: Color = obj["color"]
		save_data.append({
			"id": str(obj["id"]),
			"name": str(obj["name"]),
			"kind": str(obj["kind"]),
			"w": int(obj["w"]),
			"d": int(obj["d"]),
			"x": int(obj["x"]),
			"y": int(obj["y"]),
			"color": [color.r, color.g, color.b, color.a]
		})

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(save_data))
		file.close()

func _load_layout() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var raw_text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(raw_text)
	if typeof(parsed) != TYPE_ARRAY:
		return

	placed_objects.clear()
	for raw in parsed:
		if typeof(raw) != TYPE_DICTIONARY:
			continue
		var raw_obj: Dictionary = raw
		var color_values: Array = raw_obj.get("color", [1.0, 1.0, 1.0, 1.0])
		var restored_color: Color = Color(
			float(color_values[0]),
			float(color_values[1]),
			float(color_values[2]),
			float(color_values[3])
		)
		placed_objects.append({
			"id": str(raw_obj.get("id", "saved_item")),
			"name": str(raw_obj.get("name", "Saved Item")),
			"kind": str(raw_obj.get("kind", "decor")),
			"w": int(raw_obj.get("w", 1)),
			"d": int(raw_obj.get("d", 1)),
			"x": int(raw_obj.get("x", 0)),
			"y": int(raw_obj.get("y", 0)),
			"color": restored_color
		})
