extends FurnitureBase

func _draw() -> void:
	if grid_layer == null:
		return

	var body_color := Color("#7c36ff")
	var accent := Color("#2ddfff")
	var base := Color(0.05, 0.03, 0.08, 0.92)

	for y in range(footprint.y):
		for x in range(footprint.x):
			var cell := anchor_cell + Vector2i(x, y)
			var center := grid_layer.map_to_local(cell) - position
			draw_circle(center, 7.0, Color(0.0, 0.0, 0.0, 0.26))

	var anchor := Vector2.ZERO
	draw_rect(Rect2(anchor + Vector2(-17, -46), Vector2(34, 42)), base)
	draw_rect(Rect2(anchor + Vector2(-13, -42), Vector2(26, 30)), body_color)
	draw_line(anchor + Vector2(-13, -12), anchor + Vector2(13, -12), accent, 3.0)
	draw_circle(anchor, 4.0, Color("#f6d365"))

func configure_placement(cell: Vector2i, new_footprint: Vector2i, tile_map: TileMapLayer) -> void:
	super.configure_placement(cell, new_footprint, tile_map)
	queue_redraw()
