extends Node2D

const CELL_SIZE := 64
const GRID_WIDTH := 10
const GRID_HEIGHT := 8
const GRID_ORIGIN := Vector2(160, 120)

var selected_size := Vector2i(1, 1)
var hover_cell := Vector2i(-999, -999)
var occupied: Dictionary = {}
var placed_objects: Array[Dictionary] = []
var next_object_id := 1

var title_label: Label
var info_label: Label
var status_label: Label


func _ready() -> void:
	_build_ui()
	queue_redraw()


func _build_ui() -> void:
	title_label = Label.new()
	title_label.text = "PLACEMENT FOUNDATION TEST"
	title_label.position = Vector2(20, 18)
	title_label.add_theme_font_size_override("font_size", 24)
	add_child(title_label)

	info_label = Label.new()
	info_label.position = Vector2(20, 52)
	info_label.add_theme_font_size_override("font_size", 16)
	add_child(info_label)

	status_label = Label.new()
	status_label.position = Vector2(20, 82)
	status_label.add_theme_font_size_override("font_size", 15)
	add_child(status_label)

	_update_ui()


func _update_ui() -> void:
	if info_label:
		info_label.text = "1: 1x1   2: 2x1   3: 2x2   R: rotate   Left click: place   Right click: remove"
	if status_label:
		status_label.text = "Selected footprint: %dx%d   |   Placed objects: %d" % [
			selected_size.x,
			selected_size.y,
			placed_objects.size()
		]


func _process(_delta: float) -> void:
	var new_hover := _world_to_cell(get_global_mouse_position())
	if new_hover != hover_cell:
		hover_cell = new_hover
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				selected_size = Vector2i(1, 1)
			KEY_2:
				selected_size = Vector2i(2, 1)
			KEY_3:
				selected_size = Vector2i(2, 2)
			KEY_R:
				selected_size = Vector2i(selected_size.y, selected_size.x)
		_update_ui()
		queue_redraw()
		return

	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_try_place(hover_cell)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_remove_at(hover_cell)


func _world_to_cell(world_pos: Vector2) -> Vector2i:
	var local := world_pos - GRID_ORIGIN
	return Vector2i(floori(local.x / CELL_SIZE), floori(local.y / CELL_SIZE))


func _cell_to_world(cell: Vector2i) -> Vector2:
	return GRID_ORIGIN + Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)


func _cell_in_bounds(cell: Vector2i) -> bool:
	return (
		cell.x >= 0
		and cell.y >= 0
		and cell.x < GRID_WIDTH
		and cell.y < GRID_HEIGHT
	)


func _cells_for(anchor: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(footprint.y):
		for x in range(footprint.x):
			cells.append(anchor + Vector2i(x, y))
	return cells


func _can_place(anchor: Vector2i, footprint: Vector2i) -> bool:
	for cell in _cells_for(anchor, footprint):
		if not _cell_in_bounds(cell):
			return false
		if occupied.has(cell):
			return false
	return true


func _try_place(anchor: Vector2i) -> void:
	if not _can_place(anchor, selected_size):
		return

	var object_id := next_object_id
	next_object_id += 1

	var cells := _cells_for(anchor, selected_size)
	for cell in cells:
		occupied[cell] = object_id

	placed_objects.append({
		"id": object_id,
		"anchor": anchor,
		"size": selected_size,
		"cells": cells
	})

	_update_ui()
	queue_redraw()


func _remove_at(cell: Vector2i) -> void:
	if not occupied.has(cell):
		return

	var object_id: int = occupied[cell]
	for i in range(placed_objects.size() - 1, -1, -1):
		var obj := placed_objects[i]
		if int(obj["id"]) == object_id:
			for occupied_cell in obj["cells"]:
				occupied.erase(occupied_cell)
			placed_objects.remove_at(i)
			break

	_update_ui()
	queue_redraw()


func _draw() -> void:
	_draw_grid()
	_draw_placed_objects()
	_draw_preview()


func _draw_grid() -> void:
	var grid_rect := Rect2(
		GRID_ORIGIN,
		Vector2(GRID_WIDTH * CELL_SIZE, GRID_HEIGHT * CELL_SIZE)
	)
	draw_rect(grid_rect, Color(0.09, 0.10, 0.13), true)

	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			var cell_pos := _cell_to_world(Vector2i(x, y))
			var rect := Rect2(cell_pos, Vector2(CELL_SIZE, CELL_SIZE))
			draw_rect(rect, Color(0.22, 0.24, 0.30), false, 1.0)


func _draw_placed_objects() -> void:
	for obj in placed_objects:
		var anchor: Vector2i = obj["anchor"]
		var footprint: Vector2i = obj["size"]
		var pos := _cell_to_world(anchor)
		var size_px := Vector2(footprint.x * CELL_SIZE, footprint.y * CELL_SIZE)
		var rect := Rect2(pos + Vector2(3, 3), size_px - Vector2(6, 6))

		var fill := Color(0.25, 0.55, 0.90, 0.92)
		if footprint == Vector2i(2, 2):
			fill = Color(0.55, 0.36, 0.88, 0.92)
		elif footprint.x != footprint.y:
			fill = Color(0.18, 0.72, 0.55, 0.92)

		draw_rect(rect, fill, true)
		draw_rect(rect, Color(0.92, 0.95, 1.0), false, 2.0)


func _draw_preview() -> void:
	if hover_cell.x < -100:
		return

	var footprint_cells := _cells_for(hover_cell, selected_size)
	var valid := _can_place(hover_cell, selected_size)
	var preview_color := Color(0.20, 0.95, 0.45, 0.36) if valid else Color(1.0, 0.20, 0.25, 0.42)
	var border_color := Color(0.25, 1.0, 0.50, 0.95) if valid else Color(1.0, 0.28, 0.32, 0.95)

	for cell in footprint_cells:
		var pos := _cell_to_world(cell)
		var rect := Rect2(pos + Vector2(2, 2), Vector2(CELL_SIZE - 4, CELL_SIZE - 4))
		draw_rect(rect, preview_color, true)
		draw_rect(rect, border_color, false, 2.0)
