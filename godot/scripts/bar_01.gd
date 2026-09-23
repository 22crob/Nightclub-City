extends Node2D

const BAR_TEXTURE: Texture2D = preload("res://assets/bar/bar_module_01.png")

const TILE_W: float = 72.0
const TILE_H: float = 36.0
const FOOTPRINT_W: int = 1
const FOOTPRINT_D: int = 3

@export var show_debug_markers: bool = true

@onready var placement_anchor: Marker2D = $PlacementAnchor
@onready var bartender_point: Marker2D = $BartenderPoint
@onready var customer_point: Marker2D = $CustomerPoint

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

func _draw() -> void:
	# Production footprint: 1 tile wide x 3 tiles deep.
	# Tile 1 = rear shelf, Tile 2 = bartender/service aisle, Tile 3 = front counter.
	var footprint: PackedVector2Array = _tile_points(0.0, 0.0, 1.0, 3.0)
	draw_polygon(footprint, PackedColorArray([Color(0.20, 0.75, 1.0, 0.08)]))
	for i in range(footprint.size()):
		draw_line(footprint[i], footprint[(i + 1) % footprint.size()], Color(0.25, 0.85, 1.0, 0.70), 1.5)

	var service_tile: PackedVector2Array = _tile_points(0.0, 1.0, 1.0, 1.0)
	draw_polygon(service_tile, PackedColorArray([Color(0.35, 0.95, 0.55, 0.08)]))
	for i in range(service_tile.size()):
		draw_line(service_tile[i], service_tile[(i + 1) % service_tile.size()], Color(0.35, 0.95, 0.55, 0.45), 1.0)

	# Blender v2 calibration render using the existing Godot-imported texture path.
	draw_texture(BAR_TEXTURE, Vector2(-92.0, -50.0))

	if show_debug_markers:
		_draw_marker(placement_anchor.position, Color("#f6d365"), 4.0)
		_draw_marker(bartender_point.position, Color("#66e39a"), 4.0)
		_draw_marker(customer_point.position, Color("#ff6fae"), 4.0)

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
