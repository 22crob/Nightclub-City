extends Node2D

const BAR_TEXTURE: Texture2D = preload("res://assets/bar/bar_module_01.png")

const TILE_W: float = 48.0
const TILE_H: float = 24.0
const FOOTPRINT_W: int = 1
const FOOTPRINT_D: int = 3

# One wall module = one 48x24 isometric tile along the wall.
const WALL_STEP: Vector2 = Vector2(24.0, 12.0)

# One logical depth row = one full 48x24 floor tile.
# Slot 0 rear shelf, slot 1 bartender lane, slot 2 front counter.
const DEPTH_STEP: Vector2 = Vector2(-24.0, 12.0)

# The shelf keeps the calibrated wall fit. The counter is separated from the
# source render and pulled one exact grid row toward the wall.
const ART_OFFSET: Vector2 = Vector2(-90.0, -58.0)
const COUNTER_TOWARD_WALL_SHIFT: Vector2 = Vector2(24.0, -12.0)

@export var show_debug_markers: bool = true
@export var show_debug_tiles: bool = true

@onready var placement_anchor: Marker2D = $PlacementAnchor
@onready var bartender_point: Marker2D = $BartenderPoint
@onready var customer_point: Marker2D = $CustomerPoint
@onready var shelf_sprite: Sprite2D = $ShelfSprite
@onready var counter_sprite: Sprite2D = $CounterSprite

var shelf_texture: Texture2D
var counter_texture: Texture2D

func _ready() -> void:
	_prepare_bar_parts()
	placement_anchor.position = Vector2.ZERO
	bartender_point.position = _bar_point(0.5, 1.5)
	customer_point.position = _bar_point(0.5, 3.5)

	shelf_sprite.texture = shelf_texture
	shelf_sprite.position = ART_OFFSET
	shelf_sprite.visible = shelf_texture != null

	counter_sprite.texture = counter_texture
	counter_sprite.position = ART_OFFSET + COUNTER_TOWARD_WALL_SHIFT
	counter_sprite.visible = counter_texture != null

	# Fallback: if the render could not be separated, show the source image as
	# one real Sprite2D rather than painting it from _draw().
	if shelf_texture == null and counter_texture == null:
		shelf_sprite.texture = BAR_TEXTURE
		shelf_sprite.position = ART_OFFSET
		shelf_sprite.visible = true

	queue_redraw()

func _bar_point(wall_units: float, depth_slots: float) -> Vector2:
	return WALL_STEP * wall_units + DEPTH_STEP * depth_slots

func _bar_tile_points(depth_slot: int) -> PackedVector2Array:
	var a: Vector2 = _bar_point(0.0, float(depth_slot))
	var b: Vector2 = _bar_point(1.0, float(depth_slot))
	var c: Vector2 = _bar_point(1.0, float(depth_slot + 1))
	var d: Vector2 = _bar_point(0.0, float(depth_slot + 1))
	return PackedVector2Array([a, b, c, d])

func _prepare_bar_parts() -> void:
	var source: Image = BAR_TEXTURE.get_image()
	if source == null:
		return

	var width: int = source.get_width()
	var height: int = source.get_height()
	if width <= 0 or height <= 0:
		return

	var visited: PackedByteArray = PackedByteArray()
	visited.resize(width * height)
	var components: Array = []
	var directions: Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0),                       Vector2i(1, 0),
		Vector2i(-1, 1),  Vector2i(0, 1),  Vector2i(1, 1)
	]

	for py in range(height):
		for px in range(width):
			var start_index: int = py * width + px
			if visited[start_index] != 0:
				continue
			visited[start_index] = 1
			if source.get_pixel(px, py).a <= 0.02:
				continue

			var queue: Array[Vector2i] = [Vector2i(px, py)]
			var queue_index: int = 0
			var pixels: Array[Vector2i] = []
			var sum: Vector2 = Vector2.ZERO

			while queue_index < queue.size():
				var point: Vector2i = queue[queue_index]
				queue_index += 1
				pixels.append(point)
				sum += Vector2(point.x, point.y)

				for direction in directions:
					var neighbor: Vector2i = point + direction
					if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= width or neighbor.y >= height:
						continue
					var neighbor_index: int = neighbor.y * width + neighbor.x
					if visited[neighbor_index] != 0:
						continue
					visited[neighbor_index] = 1
					if source.get_pixel(neighbor.x, neighbor.y).a > 0.02:
						queue.append(neighbor)

			components.append({
				"pixels": pixels,
				"center": sum / float(pixels.size()),
				"size": pixels.size()
			})

	if components.size() < 2:
		shelf_texture = BAR_TEXTURE
		counter_texture = null
		return

	var largest_index: int = -1
	var second_index: int = -1
	var largest_size: int = -1
	var second_size: int = -1

	for i in range(components.size()):
		var component_size: int = int(components[i]["size"])
		if component_size > largest_size:
			second_index = largest_index
			second_size = largest_size
			largest_index = i
			largest_size = component_size
		elif component_size > second_size:
			second_index = i
			second_size = component_size

	var center_a: Vector2 = components[largest_index]["center"]
	var center_b: Vector2 = components[second_index]["center"]
	var shelf_center: Vector2 = center_a
	var counter_center: Vector2 = center_b

	if (center_b.x - center_b.y) > (center_a.x - center_a.y):
		shelf_center = center_b
		counter_center = center_a

	var shelf_image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	var counter_image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	shelf_image.fill(Color(0, 0, 0, 0))
	counter_image.fill(Color(0, 0, 0, 0))

	for component in components:
		var component_center: Vector2 = component["center"]
		var shelf_distance: float = component_center.distance_squared_to(shelf_center)
		var counter_distance: float = component_center.distance_squared_to(counter_center)
		var target: Image = shelf_image if shelf_distance <= counter_distance else counter_image
		for point in component["pixels"]:
			target.set_pixel(point.x, point.y, source.get_pixel(point.x, point.y))

	shelf_texture = ImageTexture.create_from_image(shelf_image)
	counter_texture = ImageTexture.create_from_image(counter_image)

func _draw() -> void:
	if show_debug_tiles:
		_draw_debug_tile(0, Color(0.20, 0.75, 1.0, 0.07), Color(0.25, 0.85, 1.0, 0.55))
		_draw_debug_tile(1, Color(0.35, 0.95, 0.55, 0.07), Color(0.35, 0.95, 0.55, 0.55))
		_draw_debug_tile(2, Color(1.0, 0.35, 0.65, 0.05), Color(1.0, 0.35, 0.65, 0.35))

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
