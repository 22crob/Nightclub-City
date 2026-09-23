extends FurnitureBase

const BAR_TEXTURE: Texture2D = preload("res://assets/furniture/bar_module_01.png")
const BAR_FOOTPRINT := Vector2i(1, 3)
const COUNTER_ROW := 2

@onready var shelf_sprite: Sprite2D = $ShelfSprite
@onready var counter_sprite: Sprite2D = $CounterSprite

static var _cached_shelf_texture: Texture2D
static var _cached_counter_texture: Texture2D

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

	var shelf_contact := _ground_contact(anchor_cell)
	var counter_contact := _ground_contact(anchor_cell + Vector2i(0, COUNTER_ROW))

	if shelf_sprite.texture != null:
		shelf_sprite.position = shelf_contact - Vector2(0.0, shelf_sprite.texture.get_height() * 0.5)
	if counter_sprite.texture != null:
		counter_sprite.position = counter_contact - Vector2(0.0, counter_sprite.texture.get_height() * 0.5)

	queue_redraw()

func _ground_contact(cell: Vector2i) -> Vector2:
	var cell_center := grid_layer.map_to_local(cell) - position
	var half_tile_height := float(grid_layer.tile_set.tile_size.y) * 0.5
	# map_to_local() returns the center of an isometric diamond. Furniture art
	# needs its base on the front/bottom vertex of that diamond, not its center.
	return cell_center + Vector2(0.0, half_tile_height)

func _draw() -> void:
	if grid_layer == null:
		return

	var shelf_contact := _ground_contact(anchor_cell)
	var counter_contact := _ground_contact(anchor_cell + Vector2i(0, COUNTER_ROW))

	_draw_contact_shadow(shelf_contact - Vector2(0, 2), 20.0)
	_draw_contact_shadow(counter_contact - Vector2(0, 2), 27.0)

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

	_cached_shelf_texture = ImageTexture.create_from_image(shelf_image.get_region(shelf_rect))
	_cached_counter_texture = ImageTexture.create_from_image(counter_image.get_region(counter_rect))
	shelf_sprite.texture = _cached_shelf_texture
	counter_sprite.texture = _cached_counter_texture

func _fallback_to_full_texture() -> void:
	_cached_shelf_texture = BAR_TEXTURE
	_cached_counter_texture = null
	shelf_sprite.texture = BAR_TEXTURE
	counter_sprite.texture = null
