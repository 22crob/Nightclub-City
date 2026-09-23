class_name Bar01
extends FurnitureBase

const BAR_TEXTURE: Texture2D = preload("res://assets/furniture/bar_module_01.png")
const BAR_FOOTPRINT := Vector2i(1, 3)
const COUNTER_ROW := 2

@onready var shelf_sprite: Sprite2D = $ShelfSprite
@onready var counter_sprite: Sprite2D = $CounterSprite
@onready var shelf_ground_anchor: Marker2D = $ShelfGroundAnchor
@onready var bartender_row_marker: Marker2D = $BartenderRowMarker
@onready var counter_ground_anchor: Marker2D = $CounterGroundAnchor

static var _cached_shelf_texture: Texture2D
static var _cached_counter_texture: Texture2D
static var _cached_shelf_contact_local := Vector2.ZERO
static var _cached_counter_contact_local := Vector2.ZERO

func _ready() -> void:
	footprint = BAR_FOOTPRINT
	_prepare_visual_parts()
	_refresh_visual_positions()

func configure_placement(cell: Vector2i, _new_footprint: Vector2i, tile_map: TileMapLayer) -> void:
	super.configure_placement(cell, BAR_FOOTPRINT, tile_map)
	_refresh_visual_positions()
	queue_redraw()

func _refresh_visual_positions() -> void:
	if grid_layer == null:
		return

	# Shelf belongs to the back-wall seam of row 0.
	shelf_ground_anchor.position = _back_wall_contact(anchor_cell)

	# Bartender occupies the middle logical row.
	bartender_row_marker.position = _cell_center(anchor_cell + Vector2i(0, 1))

	# Counter is grounded on the customer-facing vertex of row 2.
	counter_ground_anchor.position = _floor_front_contact(anchor_cell + Vector2i(0, COUNTER_ROW))

	if shelf_sprite.texture != null:
		shelf_sprite.position = shelf_ground_anchor.position - _cached_shelf_contact_local
	if counter_sprite.texture != null:
		counter_sprite.position = counter_ground_anchor.position - _cached_counter_contact_local

	queue_redraw()

func _cell_center(cell: Vector2i) -> Vector2:
	return grid_layer.map_to_local(cell) - position

func _back_wall_contact(cell: Vector2i) -> Vector2:
	var center := _cell_center(cell)
	var half_w := float(grid_layer.tile_set.tile_size.x) * 0.5
	var half_h := float(grid_layer.tile_set.tile_size.y) * 0.5

	# For the y=0 back boundary, the wall seam is the upper-right edge of the
	# isometric diamond. Its midpoint is the physical shelf/floor contact point.
	return center + Vector2(half_w * 0.5, -half_h * 0.5)

func _floor_front_contact(cell: Vector2i) -> Vector2:
	var center := _cell_center(cell)
	var half_h := float(grid_layer.tile_set.tile_size.y) * 0.5
	return center + Vector2(0.0, half_h)

func _draw() -> void:
	if grid_layer == null:
		return

	_draw_contact_shadow(shelf_ground_anchor.position + Vector2(1, 1), 18.0)
	_draw_contact_shadow(counter_ground_anchor.position - Vector2(0, 2), 27.0)

	# Tiny calibration dots make the two real anchors visible in the lab.
	draw_circle(shelf_ground_anchor.position, 2.5, Color(0.25, 0.90, 1.0, 0.95))
	draw_circle(counter_ground_anchor.position, 2.5, Color(1.0, 0.55, 0.25, 0.95))

func _draw_contact_shadow(contact: Vector2, radius: float) -> void:
	draw_set_transform(contact, 0.0, Vector2(1.0, 0.34))
	draw_circle(Vector2.ZERO, radius, Color(0.0, 0.0, 0.0, 0.42))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _prepare_visual_parts() -> void:
	if _cached_shelf_texture != null and _cached_counter_texture != null:
		shelf_sprite.texture = _cached_shelf_texture
		counter_sprite.texture = _cached_counter_texture
		return

	var source := BAR_TEXTURE.get_image()
	if source == null:
		_fallback_to_full_texture()
		return

	var width := source.get_width()
	var height := source.get_height()
	if width <= 0 or height <= 0:
		_fallback_to_full_texture()
		return

	var visited := PackedByteArray()
	visited.resize(width * height)

	var components: Array = []
	var directions: Array[Vector2i] = [
		Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
		Vector2i(-1, 0),                       Vector2i(1, 0),
		Vector2i(-1, 1),  Vector2i(0, 1),  Vector2i(1, 1)
	]

	for py in range(height):
		for px in range(width):
			var start_index := py * width + px
			if visited[start_index] != 0:
				continue
			visited[start_index] = 1

			if source.get_pixel(px, py).a <= 0.02:
				continue

			var queue: Array[Vector2i] = [Vector2i(px, py)]
			var queue_index := 0
			var pixels: Array[Vector2i] = []
			var center_sum := Vector2.ZERO

			while queue_index < queue.size():
				var point := queue[queue_index]
				queue_index += 1
				pixels.append(point)
				center_sum += Vector2(point)

				for direction in directions:
					var neighbor := point + direction
					if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= width or neighbor.y >= height:
						continue

					var neighbor_index := neighbor.y * width + neighbor.x
					if visited[neighbor_index] != 0:
						continue
					visited[neighbor_index] = 1

					if source.get_pixel(neighbor.x, neighbor.y).a > 0.02:
						queue.append(neighbor)

			components.append({
				"pixels": pixels,
				"center": center_sum / float(pixels.size()),
				"size": pixels.size()
			})

	if components.size() < 2:
		_fallback_to_full_texture()
		return

	var largest_index := -1
	var second_index := -1
	var largest_size := -1
	var second_size := -1

	for i in range(components.size()):
		var component_size := int(components[i]["size"])
		if component_size > largest_size:
			second_index = largest_index
			second_size = largest_size
			largest_index = i
			largest_size = component_size
		elif component_size > second_size:
			second_index = i
			second_size = component_size

	if largest_index < 0 or second_index < 0:
		_fallback_to_full_texture()
		return

	var center_a: Vector2 = components[largest_index]["center"]
	var center_b: Vector2 = components[second_index]["center"]
	var shelf_center := center_a
	var counter_center := center_b

	# The rear shelf is the upper-right visual cluster in the Blender render.
	if (center_b.x - center_b.y) > (center_a.x - center_a.y):
		shelf_center = center_b
		counter_center = center_a

	var shelf_image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	var counter_image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	shelf_image.fill(Color(0, 0, 0, 0))
	counter_image.fill(Color(0, 0, 0, 0))

	for component in components:
		var component_center: Vector2 = component["center"]
		var target: Image = shelf_image
		if component_center.distance_squared_to(counter_center) < component_center.distance_squared_to(shelf_center):
			target = counter_image

		for point in component["pixels"]:
			target.set_pixel(point.x, point.y, source.get_pixel(point.x, point.y))

	var shelf_rect := shelf_image.get_used_rect()
	var counter_rect := counter_image.get_used_rect()
	if shelf_rect.size == Vector2i.ZERO or counter_rect.size == Vector2i.ZERO:
		_fallback_to_full_texture()
		return

	var shelf_region := shelf_image.get_region(shelf_rect)
	var counter_region := counter_image.get_region(counter_rect)

	_cached_shelf_texture = ImageTexture.create_from_image(shelf_region)
	_cached_counter_texture = ImageTexture.create_from_image(counter_region)
	_cached_shelf_contact_local = _find_visual_ground_contact(shelf_region)
	_cached_counter_contact_local = _find_visual_ground_contact(counter_region)

	shelf_sprite.texture = _cached_shelf_texture
	counter_sprite.texture = _cached_counter_texture

func _find_visual_ground_contact(image: Image) -> Vector2:
	var width := image.get_width()
	var height := image.get_height()
	var bottom_y := -1

	for y in range(height - 1, -1, -1):
		var found := false
		for x in range(width):
			if image.get_pixel(x, y).a > 0.05:
				found = true
				break
		if found:
			bottom_y = y
			break

	if bottom_y < 0:
		return Vector2.ZERO

	# Average the bottom few opaque rows so a single anti-aliased corner pixel
	# cannot become the furniture's pivot.
	var x_sum := 0.0
	var sample_count := 0
	var band_start := maxi(0, bottom_y - 3)
	for y in range(band_start, bottom_y + 1):
		for x in range(width):
			if image.get_pixel(x, y).a > 0.15:
				x_sum += float(x)
				sample_count += 1

	var contact_x := float(width) * 0.5
	if sample_count > 0:
		contact_x = x_sum / float(sample_count)

	# Sprite2D is centered, so convert the visual pixel into local sprite space.
	return Vector2(
		contact_x - float(width) * 0.5,
		float(bottom_y) - float(height) * 0.5
	)

func _fallback_to_full_texture() -> void:
	_cached_shelf_texture = BAR_TEXTURE
	_cached_counter_texture = null
	_cached_shelf_contact_local = _find_visual_ground_contact(BAR_TEXTURE.get_image())
	_cached_counter_contact_local = Vector2.ZERO
	shelf_sprite.texture = BAR_TEXTURE
	counter_sprite.texture = null
