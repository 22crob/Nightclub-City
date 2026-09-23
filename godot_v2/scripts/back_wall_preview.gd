extends Node2D

var grid_layer: TileMapLayer
var room_width: int = 0
var wall_height: float = 96.0

func setup(tile_map: TileMapLayer, width: int) -> void:
	grid_layer = tile_map
	room_width = width
	queue_redraw()

func _draw() -> void:
	if grid_layer == null or room_width <= 0:
		return

	var half_w := float(grid_layer.tile_set.tile_size.x) * 0.5
	var half_h := float(grid_layer.tile_set.tile_size.y) * 0.5
	var up := Vector2(0, wall_height)

	for x in range(room_width):
		var center := grid_layer.map_to_local(Vector2i(x, 0))
		var seam_a := center + Vector2(0, -half_h)
		var seam_b := center + Vector2(half_w, 0)

		var shade := Color("#252033")
		if x % 2 == 1:
			shade = Color("#2b2439")

		draw_polygon(
			PackedVector2Array([
				seam_a,
				seam_b,
				seam_b - up,
				seam_a - up
			]),
			PackedColorArray([shade])
		)

		draw_line(seam_a, seam_b, Color("#443657"), 2.0)
		draw_line(seam_a - up, seam_b - up, Color("#a442ff"), 1.6)

	# Slight base shadow makes the wall/floor seam readable.
	for x in range(room_width):
		var center := grid_layer.map_to_local(Vector2i(x, 0))
		var seam_a := center + Vector2(0, -half_h)
		var seam_b := center + Vector2(half_w, 0)
		draw_line(seam_a + Vector2(0, 2), seam_b + Vector2(0, 2), Color(0, 0, 0, 0.35), 4.0)
