extends Node2D

const BAR_TEXTURE: Texture2D = preload("res://assets/bar/bar_module_01.png")

const TILE_W: float = 72.0
const TILE_H: float = 36.0
const FOOTPRINT_W: int = 1
const FOOTPRINT_D: int = 3

# Side-to-side uses the normal 72x36 isometric wall step.
const WALL_STEP: Vector2 = Vector2(36.0, 18.0)

# Three bar depth slots span the same distance as two full floor tiles.
# This keeps the asset's real proportions while preserving shelf/aisle/counter logic.
const DEPTH_STEP: Vector2 = Vector2(-27.0, 13.5)

# Shift the whole Blender render toward the wall as one rigid visual.
# Internal shelf / aisle / counter spacing is unchanged.
const ART_OFFSET: Vector2 = Vector2(-65.0, -71.0)

@export var show_debug_markers: bool = true
@export var show_debug_tiles: bool = true

@onready var placement_anchor: Marker2D = $PlacementAnchor
@onready var bartender_point: Marker2D = $BartenderPoint
@onready var customer_point: Marker2D = $CustomerPoint

func _ready() -> void:
	placement_anchor.position = Vector2.ZERO
	bartender_point.position = _bar_point(0.5, 1.5)
	customer_point.position = _bar_point(0.5, 3.5)
	queue_redraw()

func _bar_point(wall_units: float, depth_slots: float) -> Vector2:
	return WALL_STEP * wall_units + DEPTH_STEP * depth_slots

func _bar_tile_points(depth_slot: int) -> PackedVector2Array:
	var a: Vector2 = _bar_point(0.0, float(depth_slot))
	var b: Vector2 = _bar_point(1.0, float(depth_slot))
	var c: Vector2 = _bar_point(1.0, float(depth_slot + 1))
	var d: Vector2 = _bar_point(0.0, float(depth_slot + 1))
	return PackedVector2Array([a, b, c, d])

func _draw() -> void:
	if show_debug_tiles:
		_draw_debug_tile(0, Color(0.20, 0.75, 1.0, 0.07), Color(0.25, 0.85, 1.0, 0.55))
		_draw_debug_tile(1, Color(0.35, 0.95, 0.55, 0.07), Color(0.35, 0.95, 0.55, 0.55))
		_draw_debug_tile(2, Color(1.0, 0.35, 0.65, 0.05), Color(1.0, 0.35, 0.65, 0.35))

	# Real Blender art. The Node2D origin remains the exact wall-grid snap anchor.
	draw_texture(BAR_TEXTURE, ART_OFFSET)

	if show_debug_markers:
		_draw_marker(placement_anchor.position, Color("#f6d365"), 4.0)
		_draw_marker(bartender_point.position, Color("#66e39a"), 4.0)
		_draw_marker(customer_point.position, Color("#ff6fae"), 4.0)

func _draw_debug_tile(row: int, fill: Color, line: Color) -> void:
	var tile: PackedVector2Array = _bar_tile_points(row)
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

func get_wall_step() -> Vector2:
	return WALL_STEP

func get_depth_step() -> Vector2:
	return DEPTH_STEP
