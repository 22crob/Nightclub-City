extends Node2D

const BAR_TEXTURE: Texture2D = preload("res://assets/bar/bar_module_01.png")

const TILE_W: float = 72.0
const TILE_H: float = 36.0
const FOOTPRINT_W: int = 1
const FOOTPRINT_D: int = 3

# The Blender render is shifted toward the back wall as one rigid visual.
# Internal shelf / aisle / counter spacing is unchanged.
const ART_OFFSET: Vector2 = Vector2(-97.0, -55.0)

@export var show_debug_markers: bool = true
@export var show_debug_tiles: bool = true

@onready var placement_anchor: Marker2D = $PlacementAnchor
@onready var bartender_point: Marker2D = $BartenderPoint
@onready var customer_point: Marker2D = $CustomerPoint

func _ready() -> void:
	# Keep all interaction points derived from the same 72x36 grid contract.
	placement_anchor.position = _iso(0.0, 0.0)
	bartender_point.position = _tile_center(0, 1)
	customer_point.position = _iso(0.5, 3.5)
	queue_redraw()

func _iso(tile_x: float, tile_y: float) -> Vector2:
	return Vector2(
		(tile_x - tile_y) * TILE_W * 0.5,
		(tile_x + tile_y) * TILE_H * 0.5
	)

func _tile_center(tile_x: int, tile_y: int) -> Vector2:
	return _iso(float(tile_x) + 0.5, float(tile_y) + 0.5)

func _tile_points(x: float, y: float, width: float, depth: float) -> PackedVector2Array:
	return PackedVector2Array([
		_iso(x, y),
		_iso(x + width, y),
		_iso(x + width, y + depth),
		_iso(x, y + depth)
	])

func _draw() -> void:
	if show_debug_tiles:
		_draw_debug_tile(0, Color(0.20, 0.75, 1.0, 0.07), Color(0.25, 0.85, 1.0, 0.55))
		_draw_debug_tile(1, Color(0.35, 0.95, 0.55, 0.07), Color(0.35, 0.95, 0.55, 0.55))
		_draw_debug_tile(2, Color(1.0, 0.35, 0.65, 0.05), Color(1.0, 0.35, 0.65, 0.35))

	# Real Blender art. Do not move the Node2D to calibrate the art; only this
	# local offset changes. The Node2D origin remains the grid snap anchor.
	draw_texture(BAR_TEXTURE, ART_OFFSET)

	if show_debug_markers:
		_draw_marker(placement_anchor.position, Color("#f6d365"), 4.0)
		_draw_marker(bartender_point.position, Color("#66e39a"), 4.0)
		_draw_marker(customer_point.position, Color("#ff6fae"), 4.0)

func _draw_debug_tile(row: int, fill: Color, line: Color) -> void:
	var tile: PackedVector2Array = _tile_points(0.0, float(row), 1.0, 1.0)
	draw_polygon(tile, PackedColorArray([fill]))
	for i in range(tile.size()):
		draw_line(tile[i], tile[(i + 1) % tile.size()], line, 1.0)

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
	return [customer_point.position]

func get_art_offset() -> Vector2:
	return ART_OFFSET
