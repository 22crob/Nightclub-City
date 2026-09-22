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
@onready var stats_label: Label = $HUD/StatsPanel/Stats
@onready var club_status_label: Label = $HUD/BrandPanel/Status
@onready var level_up_panel: ColorRect = $HUD/LevelUpPanel
@onready var level_up_title: Label = $HUD/LevelUpPanel/Title
@onready var level_up_detail: Label = $HUD/LevelUpPanel/Detail

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
const ECONOMY_SAVE_PATH: String = "user://economy.json"
const NPC_SPEED: float = 0.95
const NPC_PERSONAL_SPACE: float = 0.42
const NO_SPOT: Vector2 = Vector2(-99.0, -99.0)
const LEVEL_2_XP: int = 100
const LEVEL_3_XP: int = 250
const MAX_TEST_LEVEL: int = 3

var npc_agents: Array = []
var npc_cycle_count: int = 0
var cash: int = 2500
var xp: int = 0
var completed_activities: int = 0
var current_level: int = 1
var level_up_timer: float = 0.0

var item_catalog: Dictionary = {
	"Bars": [
		{"id": "starter_bar", "name": "Starter Bar", "w": 1, "d": 3, "kind": "bar", "unlock_level": 1, "color": Color("#2f6582")},
		{"id": "compact_bar", "name": "Compact Bar", "w": 2, "d": 2, "kind": "bar", "unlock_level": 2, "color": Color("#5b337b")},
		{"id": "neon_bar", "name": "Neon Bar", "w": 1, "d": 4, "kind": "bar", "unlock_level": 3, "color": Color("#315f78")}
	],
	"Seating": [
		{"id": "booth", "name": "Lounge Booth", "w": 2, "d": 1, "kind": "seat", "unlock_level": 1, "color": Color("#5b2d70")},
		{"id": "sofa", "name": "Club Sofa", "w": 2, "d": 1, "kind": "seat", "unlock_level": 2, "color": Color("#294a70")},
		{"id": "chair", "name": "Accent Chair", "w": 1, "d": 1, "kind": "seat", "unlock_level": 3, "color": Color("#7a3f82")}
	],
	"Dance": [
		{"id": "dance_tile", "name": "Dance Tile", "w": 1, "d": 1, "kind": "dance", "unlock_level": 1, "color": Color("#7c36ff")},
		{"id": "dance_block", "name": "2x2 Dance Floor", "w": 2, "d": 2, "kind": "dance", "unlock_level": 2, "color": Color("#ff3ebf")}
	],
	"Walls": [
		{"id": "neon_divider", "name": "Neon Divider", "w": 2, "d": 1, "kind": "wall", "unlock_level": 2, "color": Color("#2ddfff")},
		{"id": "purple_divider", "name": "Purple Divider", "w": 2, "d": 1, "kind": "wall", "unlock_level": 3, "color": Color("#a13dff")}
	],
	"Decor": [
		{"id": "round_table", "name": "Round Table", "w": 1, "d": 1, "kind": "table", "unlock_level": 1, "color": Color("#4b335e")},
		{"id": "neon_pillar", "name": "Neon Pillar", "w": 1, "d": 1, "kind": "pillar", "unlock_level": 2, "color": Color("#28dfff")},
		{"id": "purple_pillar", "name": "Purple Pillar", "w": 1, "d": 1, "kind": "pillar", "unlock_level": 3, "color": Color("#c24cff")}
	]
}

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
	print("Nightclub City Level Progression v1 loaded.")
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
	_load_economy()
	current_level = _level_for_xp(xp)
	_initialize_npcs()
	_update_stats_hud()
	_set_category("Bars")
	queue_redraw()

func _process(delta: float) -> void:
	anim_time += delta
	_update_npcs(delta)

	if level_up_timer > 0.0:
		level_up_timer -= delta
		if level_up_timer <= 0.0:
			level_up_panel.visible = false

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
	for i in range(npc_agents.size()):
		var npc: Dictionary = npc_agents[i]
		if float(npc["spawn_delay"]) > 0.0:
			continue

		var tile_pos: Vector2 = npc["pos"]
		var state: String = str(npc["state"])
		if state == "entering" or state == "walking" or state == "leaving":
			var lane_offset: Vector2 = npc["lane_offset"]
			tile_pos += lane_offset
		var screen_pos: Vector2 = _iso(tile_pos.x, tile_pos.y)
		var activity: String = str(npc["activity"])
		var dancing: bool = state == "activity" and activity == "dance"
		var shirt_color: Color = npc["color"]
		var bob: float = 0.0

		if state == "entering" or state == "walking" or state == "leaving":
			bob = sin(anim_time * 8.0 + float(i)) * 1.2
		elif dancing:
			bob = sin(anim_time * 3.0 + float(i) * 0.7) * 1.8

		_draw_avatar(screen_pos - Vector2(0, bob), shirt_color, dancing)

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
	_refresh_design_buttons()
	design_hint.text = category + " selected • choose an unlocked item"

func _refresh_design_buttons() -> void:
	var items: Array = item_catalog[selected_category]
	var buttons: Array[Button] = [item_button_1, item_button_2, item_button_3]

	for i in range(buttons.size()):
		if i >= items.size():
			buttons[i].visible = false
			continue

		var item: Dictionary = items[i]
		var unlock_level: int = int(item.get("unlock_level", 1))
		var unlocked: bool = current_level >= unlock_level
		buttons[i].visible = true
		buttons[i].disabled = not unlocked

		if unlocked:
			buttons[i].text = str(item["name"])
		else:
			buttons[i].text = "LOCKED • L" + str(unlock_level)

func _select_item(index: int) -> void:
	var items: Array = item_catalog[selected_category]
	if index < 0 or index >= items.size():
		return

	var item: Dictionary = items[index]
	var unlock_level: int = int(item.get("unlock_level", 1))
	if current_level < unlock_level:
		design_hint.text = str(item["name"]) + " unlocks at Level " + str(unlock_level)
		return

	moving_object_index = -1
	_deselect_object()
	current_item = item.duplicate(true)
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
		_refresh_npc_targets_after_layout_change()
		queue_redraw()
		return

	var placed: Dictionary = current_item.duplicate(true)
	placed["x"] = tile.x
	placed["y"] = tile.y
	placed_objects.append(placed)

	selected_object_index = placed_objects.size() - 1
	moving_object_index = -1
	current_item = {}
	hover_tile = Vector2i(-1, -1)
	_refresh_selection_panel()
	design_hint.text = str(placed["name"]) + " placed • use Move / Rotate / Delete, or choose another item"
	_save_layout()
	_refresh_npc_targets_after_layout_change()
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
	_refresh_npc_targets_after_layout_change()
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
	_refresh_npc_targets_after_layout_change()
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


func _initialize_npcs() -> void:
	npc_agents.clear()
	for i in range(npc_colors.size()):
		var activity: String = _activity_for_index(i)
		var activity_target: Vector2 = _choose_activity_target(activity, i, i)
		var agent: Dictionary = {
			"pos": Vector2(11.0, 0.55),
			"target": Vector2(10.6, 1.65),
			"state": "waiting",
			"activity": activity,
			"activity_target": activity_target,
			"timer": 0.0,
			"spawn_delay": 0.15 + float(i) * 0.75,
			"path": [],
			"path_index": 0,
			"reserved_spot": NO_SPOT,
			"lane_offset": _lane_offset_for_index(i),
			"color": npc_colors[i]
		}
		agent["reserved_spot"] = activity_target
		npc_agents.append(agent)

func _lane_offset_for_index(index: int) -> Vector2:
	var lane: int = index % 3
	if lane == 0:
		return Vector2(-0.07, 0.04)
	if lane == 1:
		return Vector2(0.07, -0.04)
	return Vector2.ZERO

func _activity_for_index(index: int) -> String:
	var slot: int = index % 3
	if slot == 0:
		return "dance"
	if slot == 1:
		return "bar"
	return "lounge"

func _choose_activity_target(activity: String, seed: int, npc_index: int) -> Vector2:
	var targets: Array[Vector2] = _activity_targets(activity)
	if targets.is_empty():
		return Vector2(7.0, 5.5)

	var start_index: int = seed % targets.size()
	for offset in range(targets.size()):
		var candidate_index: int = (start_index + offset) % targets.size()
		var candidate: Vector2 = targets[candidate_index]
		if _is_nav_tile_blocked(_nav_tile_from_position(candidate)):
			continue
		if not _spot_is_reserved(candidate, npc_index):
			return candidate

	for candidate in targets:
		if not _is_nav_tile_blocked(_nav_tile_from_position(candidate)):
			return candidate

	return targets[start_index]

func _spot_is_reserved(candidate: Vector2, ignore_index: int) -> bool:
	for i in range(npc_agents.size()):
		if i == ignore_index:
			continue
		var other: Dictionary = npc_agents[i]
		var reserved: Vector2 = NO_SPOT
		if other.has("reserved_spot"):
			reserved = other["reserved_spot"]
		if reserved == NO_SPOT:
			continue
		if reserved.distance_to(candidate) < 0.28:
			return true
	return false

func _activity_targets(activity: String) -> Array[Vector2]:
	var targets: Array[Vector2] = []

	if activity == "dance":
		targets.append(Vector2(5.7, 5.0))
		targets.append(Vector2(6.8, 5.3))
		targets.append(Vector2(8.1, 5.1))
		targets.append(Vector2(6.1, 6.5))
		targets.append(Vector2(7.6, 6.4))
		targets.append(Vector2(8.7, 6.1))
		targets.append(Vector2(5.5, 7.0))
	elif activity == "bar":
		targets.append(Vector2(2.55, 3.8))
		targets.append(Vector2(2.55, 4.9))
		targets.append(Vector2(2.55, 6.0))
		targets.append(Vector2(2.55, 7.0))
	else:
		targets.append(Vector2(9.6, 4.15))
		targets.append(Vector2(10.5, 4.15))
		targets.append(Vector2(9.7, 7.1))
		targets.append(Vector2(10.6, 7.1))
		targets.append(Vector2(3.4, 7.45))
		targets.append(Vector2(4.3, 7.45))

	for obj in placed_objects:
		var kind: String = str(obj["kind"])
		if activity == "dance" and kind == "dance":
			_append_dance_spots(targets, obj)
		elif activity == "bar" and kind == "bar":
			_append_bar_spots(targets, obj)
		elif activity == "lounge" and kind == "seat":
			_append_seat_spots(targets, obj)

	return targets

func _append_dance_spots(targets: Array[Vector2], obj: Dictionary) -> void:
	var x: int = int(obj["x"])
	var y: int = int(obj["y"])
	var width: int = int(obj["w"])
	var depth: int = int(obj["d"])

	for dy in range(depth):
		for dx in range(width):
			targets.append(Vector2(float(x + dx) + 0.5, float(y + dy) + 0.5))

func _append_bar_spots(targets: Array[Vector2], obj: Dictionary) -> void:
	var x: float = float(obj["x"])
	var y: float = float(obj["y"])
	var width: int = int(obj["w"])
	var depth: int = int(obj["d"])

	if depth >= width:
		var side_x: float = x + float(width) + 0.45
		if side_x >= float(CLUB_W) - 0.15:
			side_x = x - 0.45
		for i in range(depth):
			var spot: Vector2 = Vector2(side_x, y + float(i) + 0.5)
			targets.append(_clamp_activity_spot(spot))
	else:
		var side_y: float = y + float(depth) + 0.45
		if side_y >= float(CLUB_H) - 0.15:
			side_y = y - 0.45
		for i in range(width):
			var spot: Vector2 = Vector2(x + float(i) + 0.5, side_y)
			targets.append(_clamp_activity_spot(spot))

func _append_seat_spots(targets: Array[Vector2], obj: Dictionary) -> void:
	var x: float = float(obj["x"])
	var y: float = float(obj["y"])
	var width: int = int(obj["w"])
	var depth: int = int(obj["d"])
	var side_y: float = y + float(depth) + 0.45

	if side_y >= float(CLUB_H) - 0.15:
		side_y = y - 0.45

	for i in range(width):
		var spot: Vector2 = Vector2(x + float(i) + 0.5, side_y)
		targets.append(_clamp_activity_spot(spot))

func _clamp_activity_spot(point: Vector2) -> Vector2:
	return Vector2(
		clamp(point.x, 0.35, float(CLUB_W) - 0.35),
		clamp(point.y, 0.35, float(CLUB_H) - 0.35)
	)

func _object_center(obj: Dictionary) -> Vector2:
	return Vector2(
		float(obj["x"]) + float(obj["w"]) * 0.5,
		float(obj["y"]) + float(obj["d"]) * 0.5
	)

func _bar_interaction_point(obj: Dictionary) -> Vector2:
	var x: float = float(obj["x"])
	var y: float = float(obj["y"])
	var width: float = float(obj["w"])
	var depth: float = float(obj["d"])
	var point: Vector2 = Vector2(x + width + 0.45, y + depth * 0.5)

	if point.x >= float(CLUB_W) - 0.15:
		point.x = x - 0.45

	point.x = clamp(point.x, 0.35, float(CLUB_W) - 0.35)
	point.y = clamp(point.y, 0.35, float(CLUB_H) - 0.35)
	return point

func _seat_interaction_point(obj: Dictionary) -> Vector2:
	var x: float = float(obj["x"])
	var y: float = float(obj["y"])
	var width: float = float(obj["w"])
	var depth: float = float(obj["d"])
	var point: Vector2 = Vector2(x + width * 0.5, y + depth + 0.45)

	if point.y >= float(CLUB_H) - 0.15:
		point.y = y - 0.45

	point.x = clamp(point.x, 0.35, float(CLUB_W) - 0.35)
	point.y = clamp(point.y, 0.35, float(CLUB_H) - 0.35)
	return point

func _refresh_npc_targets_after_layout_change() -> void:
	for i in range(npc_agents.size()):
		var npc: Dictionary = npc_agents[i]
		var state: String = str(npc["state"])
		if state != "activity":
			npc["reserved_spot"] = NO_SPOT
		npc_agents[i] = npc

	for i in range(npc_agents.size()):
		var npc: Dictionary = npc_agents[i]
		var state: String = str(npc["state"])
		var activity: String = str(npc["activity"])

		if state == "activity":
			npc["reserved_spot"] = npc["pos"]
			npc_agents[i] = npc
			continue

		var refreshed_target: Vector2 = _choose_activity_target(activity, i + npc_cycle_count, i)
		npc["activity_target"] = refreshed_target
		npc["reserved_spot"] = refreshed_target

		if state == "walking":
			_set_npc_destination(npc, refreshed_target)
		elif state == "entering" or state == "leaving":
			_set_npc_destination(npc, npc["target"])

		npc_agents[i] = npc

func _update_npcs(delta: float) -> void:
	for i in range(npc_agents.size()):
		var npc: Dictionary = npc_agents[i]
		var spawn_delay: float = float(npc["spawn_delay"])

		if spawn_delay > 0.0:
			spawn_delay -= delta
			npc["spawn_delay"] = spawn_delay
			if spawn_delay <= 0.0:
				npc["state"] = "entering"
				npc["pos"] = Vector2(11.0, 0.55)
				_set_npc_destination(npc, Vector2(10.6, 1.65))
			npc_agents[i] = npc
			continue

		var state: String = str(npc["state"])

		if state == "entering":
			if _move_agent_along_path(npc, delta, i):
				npc["state"] = "walking"
				_set_npc_destination(npc, npc["activity_target"])

		elif state == "walking":
			if _move_agent_along_path(npc, delta, i):
				npc["state"] = "activity"
				npc["timer"] = 4.5 + float(i % 4) * 1.1

		elif state == "activity":
			npc["timer"] = float(npc["timer"]) - delta
			if float(npc["timer"]) <= 0.0:
				_complete_activity_reward(str(npc["activity"]))
				npc["reserved_spot"] = NO_SPOT
				npc["state"] = "leaving"
				_set_npc_destination(npc, Vector2(10.6, 1.65))

		elif state == "leaving":
			if _move_agent_along_path(npc, delta, i):
				npc_cycle_count += 1
				var next_activity: String = _activity_for_index(i + npc_cycle_count)
				var next_target: Vector2 = _choose_activity_target(next_activity, i + npc_cycle_count, i)
				npc["activity"] = next_activity
				npc["activity_target"] = next_target
				npc["reserved_spot"] = next_target
				npc["state"] = "waiting"
				npc["pos"] = Vector2(11.0, 0.55)
				npc["target"] = Vector2(10.6, 1.65)
				npc["path"] = []
				npc["path_index"] = 0
				npc["spawn_delay"] = 2.0 + float(i % 3) * 0.65

		npc_agents[i] = npc

func _set_npc_destination(npc: Dictionary, target: Vector2) -> void:
	var requested_tile: Vector2i = _nav_tile_from_position(target)
	var safe_tile: Vector2i = _nearest_open_nav_tile(requested_tile)
	var safe_target: Vector2 = target

	if safe_tile != requested_tile:
		safe_target = Vector2(float(safe_tile.x) + 0.5, float(safe_tile.y) + 0.5)

	npc["target"] = safe_target
	npc["path"] = _find_nav_path(npc["pos"], safe_target)
	npc["path_index"] = 0

func _move_agent_along_path(npc: Dictionary, delta: float, npc_index: int) -> bool:
	var path: Array = npc["path"]
	var path_index: int = int(npc["path_index"])

	if path.is_empty():
		var current_pos: Vector2 = npc["pos"]
		var direct_target: Vector2 = npc["target"]
		if current_pos.distance_to(direct_target) <= 0.08:
			npc["pos"] = direct_target
			return true
		return false

	if path_index >= path.size():
		npc["pos"] = npc["target"]
		return true

	var pos: Vector2 = npc["pos"]
	var next_point: Vector2 = path[path_index]
	var speed_scale: float = _crowd_speed_scale(npc_index, pos, next_point)
	var step: float = NPC_SPEED * speed_scale * delta

	if pos.distance_to(next_point) <= step:
		npc["pos"] = next_point
		path_index += 1
		npc["path_index"] = path_index

		if path_index >= path.size():
			npc["pos"] = npc["target"]
			return true
		return false

	npc["pos"] = pos.move_toward(next_point, step)
	return false

func _crowd_speed_scale(npc_index: int, pos: Vector2, next_point: Vector2) -> float:
	var scale: float = 1.0
	var direction: Vector2 = (next_point - pos).normalized()

	for i in range(npc_agents.size()):
		if i == npc_index:
			continue

		var other: Dictionary = npc_agents[i]
		if float(other["spawn_delay"]) > 0.0:
			continue

		var other_state: String = str(other["state"])
		if other_state == "waiting":
			continue

		var other_pos: Vector2 = other["pos"]
		var distance: float = pos.distance_to(other_pos)
		if distance >= NPC_PERSONAL_SPACE:
			continue

		var toward_other: Vector2 = other_pos - pos
		if toward_other.length() > 0.001 and direction.dot(toward_other.normalized()) < 0.15:
			continue

		if npc_index > i:
			if distance < 0.24:
				return 0.12
			if scale > 0.38:
				scale = 0.38
		else:
			if scale > 0.72:
				scale = 0.72

	return scale

func _find_nav_path(start_pos: Vector2, target_pos: Vector2) -> Array:
	var start: Vector2i = _nav_tile_from_position(start_pos)
	var goal: Vector2i = _nearest_open_nav_tile(_nav_tile_from_position(target_pos))

	if start == goal:
		return [target_pos]

	var frontier: Array = [start]
	var frontier_index: int = 0
	var came_from: Dictionary = {}
	came_from[start] = start
	var directions: Array[Vector2i] = [
		Vector2i(1, 0),
		Vector2i(-1, 0),
		Vector2i(0, 1),
		Vector2i(0, -1)
	]

	while frontier_index < frontier.size():
		var current: Vector2i = frontier[frontier_index]
		frontier_index += 1

		if current == goal:
			break

		for direction in directions:
			var next_tile: Vector2i = current + direction
			if not _is_nav_tile_valid(next_tile):
				continue
			if next_tile != goal and _is_nav_tile_blocked(next_tile):
				continue
			if came_from.has(next_tile):
				continue

			came_from[next_tile] = current
			frontier.append(next_tile)

	if not came_from.has(goal):
		return []

	var reverse_cells: Array = []
	var cursor: Vector2i = goal

	while cursor != start:
		reverse_cells.append(cursor)
		cursor = came_from[cursor]

	reverse_cells.reverse()

	var path: Array = []
	for cell in reverse_cells:
		path.append(Vector2(float(cell.x) + 0.5, float(cell.y) + 0.5))

	if path.is_empty():
		path.append(target_pos)
	else:
		path[path.size() - 1] = target_pos

	return path

func _nav_tile_from_position(pos: Vector2) -> Vector2i:
	return Vector2i(
		int(clamp(floor(pos.x), 0.0, float(CLUB_W - 1))),
		int(clamp(floor(pos.y), 0.0, float(CLUB_H - 1)))
	)

func _nearest_open_nav_tile(origin: Vector2i) -> Vector2i:
	if _is_nav_tile_valid(origin) and not _is_nav_tile_blocked(origin):
		return origin

	for radius in range(1, 5):
		for y_offset in range(-radius, radius + 1):
			for x_offset in range(-radius, radius + 1):
				if abs(x_offset) != radius and abs(y_offset) != radius:
					continue
				var candidate: Vector2i = origin + Vector2i(x_offset, y_offset)
				if _is_nav_tile_valid(candidate) and not _is_nav_tile_blocked(candidate):
					return candidate

	return origin

func _is_nav_tile_valid(tile: Vector2i) -> bool:
	return tile.x >= 0 and tile.y >= 0 and tile.x < CLUB_W and tile.y < CLUB_H

func _is_nav_tile_blocked(tile: Vector2i) -> bool:
	if _is_static_nav_blocked(tile):
		return true

	for obj in placed_objects:
		var kind: String = str(obj["kind"])
		if kind == "dance":
			continue

		var ox: int = int(obj["x"])
		var oy: int = int(obj["y"])
		var ow: int = int(obj["w"])
		var od: int = int(obj["d"])

		if tile.x >= ox and tile.x < ox + ow and tile.y >= oy and tile.y < oy + od:
			return true

	return false

func _is_static_nav_blocked(tile: Vector2i) -> bool:
	# Starter bar.
	if tile.x >= 0 and tile.x <= 1 and tile.y >= 2 and tile.y <= 7:
		return true

	# Starter DJ booth.
	if tile.x >= 5 and tile.x <= 8 and tile.y >= 1 and tile.y <= 2:
		return true

	# Starter lounge booths.
	if tile.x >= 10 and tile.x <= 12 and tile.y >= 2 and tile.y <= 3:
		return true
	if tile.x >= 10 and tile.x <= 12 and tile.y >= 5 and tile.y <= 6:
		return true
	if tile.x >= 2 and tile.x <= 4 and tile.y == 8:
		return true

	# Starter cocktail tables.
	if tile == Vector2i(11, 8) or tile == Vector2i(3, 6):
		return true

	return false


func _complete_activity_reward(activity: String) -> void:
	var cash_reward: int = 0
	var xp_reward: int = 0

	if activity == "bar":
		cash_reward = 18
		xp_reward = 2
	elif activity == "dance":
		cash_reward = 6
		xp_reward = 5
	else:
		cash_reward = 9
		xp_reward = 3

	var previous_level: int = current_level
	cash += cash_reward
	xp += xp_reward
	completed_activities += 1
	current_level = _level_for_xp(xp)

	if current_level > previous_level:
		_show_level_up(current_level)

	_update_stats_hud()
	_save_economy()

func _update_stats_hud() -> void:
	club_status_label.text = "LEVEL " + str(current_level) + "  •  STARTER CLUB"

	if current_level == 1:
		stats_label.text = "$ " + str(cash) + "        XP  " + str(xp) + " / " + str(LEVEL_2_XP) + "\nNext unlocks at Level 2"
	elif current_level == 2:
		var level_two_progress: int = xp - LEVEL_2_XP
		var level_two_goal: int = LEVEL_3_XP - LEVEL_2_XP
		stats_label.text = "$ " + str(cash) + "        XP  " + str(level_two_progress) + " / " + str(level_two_goal) + "\nNext unlocks at Level 3"
	else:
		stats_label.text = "$ " + str(cash) + "        XP  " + str(xp) + "  •  LEVEL 3\nProgression test cap reached"

func _level_for_xp(total_xp: int) -> int:
	if total_xp >= LEVEL_3_XP:
		return 3
	if total_xp >= LEVEL_2_XP:
		return 2
	return 1

func _show_level_up(new_level: int) -> void:
	level_up_title.text = "LEVEL UP!  LEVEL " + str(new_level)
	level_up_detail.text = _unlock_summary_for_level(new_level)
	level_up_panel.visible = true
	level_up_timer = 3.5
	_refresh_design_buttons()

func _unlock_summary_for_level(level: int) -> String:
	if level == 2:
		return "Unlocked: Compact Bar • Club Sofa • 2x2 Dance Floor • Neon Divider • Neon Pillar"
	if level == 3:
		return "Unlocked: Neon Bar • Accent Chair • Purple Divider • Purple Pillar"
	return "New club items unlocked"

func _save_economy() -> void:
	var save_data: Dictionary = {
		"cash": cash,
		"xp": xp,
		"completed_activities": completed_activities
	}

	var file: FileAccess = FileAccess.open(ECONOMY_SAVE_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(save_data))
		file.close()

func _load_economy() -> void:
	if not FileAccess.file_exists(ECONOMY_SAVE_PATH):
		return

	var file: FileAccess = FileAccess.open(ECONOMY_SAVE_PATH, FileAccess.READ)
	if file == null:
		return

	var raw_text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(raw_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var data: Dictionary = parsed
	cash = int(data.get("cash", 2500))
	xp = int(data.get("xp", 0))
	completed_activities = int(data.get("completed_activities", 0))
