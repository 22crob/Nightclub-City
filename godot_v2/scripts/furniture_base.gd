class_name FurnitureBase
extends Node2D

@export var footprint: Vector2i = Vector2i.ONE

var anchor_cell: Vector2i = Vector2i.ZERO
var grid_layer: TileMapLayer

func configure_placement(cell: Vector2i, new_footprint: Vector2i, tile_map: TileMapLayer) -> void:
	anchor_cell = cell
	footprint = new_footprint
	grid_layer = tile_map
	position = grid_layer.map_to_local(anchor_cell)
	set_meta("anchor_cell", anchor_cell)
	set_meta("footprint", footprint)
	queue_redraw()

func set_anchor_cell(cell: Vector2i) -> void:
	anchor_cell = cell
	if grid_layer != null:
		position = grid_layer.map_to_local(anchor_cell)
	set_meta("anchor_cell", anchor_cell)
	queue_redraw()

func get_anchor_cell() -> Vector2i:
	return anchor_cell

func get_footprint() -> Vector2i:
	return footprint
