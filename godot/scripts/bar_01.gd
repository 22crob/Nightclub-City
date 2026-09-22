extends Node2D

const TILE_W: float = 72.0
const TILE_H: float = 36.0
const FOOTPRINT_W: int = 3
const FOOTPRINT_D: int = 1

@export var show_debug_markers: bool = true

@onready var placement_anchor: Marker2D = $PlacementAnchor
@onready var bartender_point: Marker2D = $BartenderPoint
@onready var customer_point_1: Marker2D = $CustomerPoint1
@onready var customer_point_2: Marker2D = $CustomerPoint2
@onready var customer_point_3: Marker2D = $CustomerPoint3

func _ready() -> void:
	queue_redraw()

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
	var up: Vector2 = Vector2(0.0, height)

	draw_polygon(PackedVector2Array([d - up, c - up, c, d]), PackedColorArray([left]))
	draw_polygon(PackedVector2Array([b - up, c - up, c, b]), PackedColorArray([right]))
	draw_polygon(PackedVector2Array([a - up, b - up, c - up, d - up]), PackedColorArray([top]))

func _draw() -> void:
	# Exact logical footprint: 3 x 1 of the production 72 x 36 isometric tiles.
	var footprint: PackedVector2Array = _tile_points(0.0, 0.0, float(FOOTPRINT_W), float(FOOTPRINT_D))
	draw_polygon(footprint, PackedColorArray([Color(0.20, 0.75, 1.0, 0.10)]))
	for i in range(footprint.size()):
		draw_line(footprint[i], footprint[(i + 1) % footprint.size()], Color(0.25, 0.85, 1.0, 0.75), 1.5)

	# Proxy back shelf. This is deliberately simple: geometry first, final art later.
	_draw_iso_box(
		0.08, 0.05, 2.84, 0.24, 70.0,
		Color("#44315e"), Color("#251b37"), Color("#322346")
	)

	# Proxy front counter. Kept fully inside the 3 x 1 logical footprint.
	_draw_iso_box(
		0.08, 0.55, 2.84, 0.34, 35.0,
		Color("#315f78"), Color("#1f3d50"), Color("#274d63")
	)

	# Small counter glow to make visual seams easy to inspect between copies.
	var glow_a: Vector2 = _iso(0.08, 0.55) - Vector2(0.0, 36.0)
	var glow_b: Vector2 = _iso(2.92, 0.55) - Vector2(0.0, 36.0)
	draw_line(glow_a, glow_b, Color("#38d8ff"), 2.0)

	if show_debug_markers:
		_draw_marker(placement_anchor.position, Color("#f6d365"), 5.0)
		_draw_marker(bartender_point.position, Color("#66e39a"), 5.0)
		_draw_marker(customer_point_1.position, Color("#ff6fae"), 5.0)
		_draw_marker(customer_point_2.position, Color("#ff6fae"), 5.0)
		_draw_marker(customer_point_3.position, Color("#ff6fae"), 5.0)

func _draw_marker(pos: Vector2, color: Color, radius: float) -> void:
	draw_circle(pos, radius + 2.0, Color(0.0, 0.0, 0.0, 0.65))
	draw_circle(pos, radius, color)

func get_footprint() -> Vector2i:
	return Vector2i(FOOTPRINT_W, FOOTPRINT_D)

func get_placement_anchor() -> Vector2:
	return placement_anchor.position

func get_bartender_point() -> Vector2:
	return bartender_point.position

func get_customer_points() -> Array[Vector2]:
	return [
		customer_point_1.position,
		customer_point_2.position,
		customer_point_3.position
	]
