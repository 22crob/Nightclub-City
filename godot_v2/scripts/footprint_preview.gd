extends Node2D

var grid_layer: TileMapLayer
var anchor_cell: Vector2i = Vector2i.ZERO
var footprint: Vector2i = Vector2i.ONE
var placement_valid: bool = false
var active: bool = false

func setup(tile_map: TileMapLayer) -> void:
	grid_layer = tile_map

func show_preview(cell: Vector2i, size: Vector2i, valid: bool) -> void:
	anchor_cell = cell
	footprint = size
	placement_valid = valid
	active = true
	queue_redraw()

func hide_preview() -> void:
	active = false
	queue_redraw()

func _draw() -> void:
	if not active or grid_layer == null:
		return

	var fill := Color(0.20, 0.95, 0.55, 0.20) if placement_valid else Color(1.0, 0.20, 0.30, 0.22)
	var line := Color(0.35, 1.0, 0.65, 0.95) if placement_valid else Color(1.0, 0.30, 0.40, 0.95)
	var half_w: float = float(grid_layer.tile_set.tile_size.x) * 0.5
	var half_h: float = float(grid_layer.tile_set.tile_size.y) * 0.5

	for y in range(footprint.y):
		for x in range(footprint.x):
			var cell := anchor_cell + Vector2i(x, y)
			var center := grid_layer.map_to_local(cell)
			var diamond := PackedVector2Array([
				center + Vector2(0, -half_h),
				center + Vector2(half_w, 0),
				center + Vector2(0, half_h),
				center + Vector2(-half_w, 0)
			])
			draw_polygon(diamond, PackedColorArray([fill]))
			for i in range(4):
				draw_line(diamond[i], diamond[(i + 1) % 4], line, 2.0)

	var anchor := grid_layer.map_to_local(anchor_cell)
	draw_circle(anchor, 4.5, line)
