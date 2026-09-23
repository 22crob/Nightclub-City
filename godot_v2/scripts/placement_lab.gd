extends Node2D

const ROOM_SIZE := Vector2i(16, 12)
const TILE_SIZE := Vector2i(48, 24)
const FLOOR_TEXTURE: Texture2D = preload("res://assets/grid/floor_tile.svg")
const DEBUG_FURNITURE: PackedScene = preload("res://scenes/furniture/DebugFurniture.tscn")
const BAR_SCENE: PackedScene = preload("res://scenes/furniture/Bar01.tscn")
const OCCUPANCY_GRID = preload("res://scripts/occupancy_grid.gd")

@onready var floor: TileMapLayer = $World/Floor
@onready var back_wall = $World/BackWall
@onready var furniture_layer: Node2D = $World/FurnitureLayer
@onready var preview = $World/FootprintPreview
@onready var status_label: Label = $UI/Panel/Status
@onready var controls_label: Label = $UI/Panel/Controls

var occupancy = OCCUPANCY_GRID.new()
var hover_cell := Vector2i(-999, -999)
var selected_footprint := Vector2i(1, 3)

var moving_owner: FurnitureBase
var moving_original_cell := Vector2i.ZERO
var moving_original_footprint := Vector2i.ONE

func _ready() -> void:
	_build_native_tileset()
	_fill_floor()
	back_wall.setup(floor, ROOM_SIZE.x)
	preview.setup(floor)
	_update_hover()
	_update_status()

func _process(_delta: float) -> void:
	_update_hover()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_place_or_finish_move()
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_delete_at_hover()
			get_viewport().set_input_as_handled()

	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_cancel_move()
				selected_footprint = Vector2i(1, 1)
			KEY_2:
				_cancel_move()
				selected_footprint = Vector2i(2, 2)
			KEY_3:
				_cancel_move()
				selected_footprint = Vector2i(1, 3)
			KEY_M:
				_begin_move_at_hover()
			KEY_ESCAPE:
				_cancel_move()
		_update_hover()
		_update_status()

func _build_native_tileset() -> void:
	var tile_set := TileSet.new()
	tile_set.tile_shape = TileSet.TILE_SHAPE_ISOMETRIC
	tile_set.tile_layout = TileSet.TILE_LAYOUT_DIAMOND_DOWN
	tile_set.tile_size = TILE_SIZE

	var atlas := TileSetAtlasSource.new()
	atlas.texture = FLOOR_TEXTURE
	atlas.texture_region_size = TILE_SIZE
	atlas.create_tile(Vector2i.ZERO)
	tile_set.add_source(atlas, 0)

	floor.tile_set = tile_set

func _fill_floor() -> void:
	for y in range(ROOM_SIZE.y):
		for x in range(ROOM_SIZE.x):
			floor.set_cell(Vector2i(x, y), 0, Vector2i.ZERO, 0)

func _mouse_grid_cell() -> Vector2i:
	var mouse_in_floor: Vector2 = floor.to_local(get_global_mouse_position())
	return floor.local_to_map(mouse_in_floor)

func _update_hover() -> void:
	hover_cell = _mouse_grid_cell()
	var footprint := selected_footprint
	var ignore_owner: Object = null

	if moving_owner != null:
		footprint = moving_owner.get_footprint()
		ignore_owner = moving_owner

	var valid := _placement_is_valid(hover_cell, footprint, ignore_owner)
	preview.show_preview(hover_cell, footprint, valid)

func _placement_is_valid(cell: Vector2i, footprint: Vector2i, ignore_owner: Object = null) -> bool:
	if not occupancy.can_place(cell, footprint, ROOM_SIZE, ignore_owner):
		return false

	# The real bar includes a rear shelf, so its anchor belongs on the y=0
	# back-wall row. Test furniture remains free-placement.
	if footprint == Vector2i(1, 3) and cell.y != 0:
		return false

	return true

func _place_or_finish_move() -> void:
	var footprint := selected_footprint

	if moving_owner != null:
		footprint = moving_owner.get_footprint()
		if not _placement_is_valid(hover_cell, footprint, moving_owner):
			return

		moving_owner.visible = true
		moving_owner.configure_placement(hover_cell, footprint, floor)
		occupancy.reserve(hover_cell, footprint, moving_owner, ROOM_SIZE)
		moving_owner = null
		_update_status()
		return

	if not _placement_is_valid(hover_cell, footprint):
		return

	var scene_to_place: PackedScene = DEBUG_FURNITURE
	if footprint == Vector2i(1, 3):
		scene_to_place = BAR_SCENE

	var furniture := scene_to_place.instantiate() as FurnitureBase
	furniture_layer.add_child(furniture)
	furniture.configure_placement(hover_cell, footprint, floor)
	occupancy.reserve(hover_cell, furniture.get_footprint(), furniture, ROOM_SIZE)
	_update_status()

func _begin_move_at_hover() -> void:
	if moving_owner != null:
		return

	var owner := occupancy.owner_at(hover_cell)
	if owner == null or not is_instance_valid(owner):
		return
	if not owner is FurnitureBase:
		return

	moving_owner = owner as FurnitureBase
	moving_original_cell = moving_owner.get_anchor_cell()
	moving_original_footprint = moving_owner.get_footprint()
	occupancy.release(moving_owner)
	moving_owner.visible = false
	selected_footprint = moving_original_footprint
	_update_status()

func _cancel_move() -> void:
	if moving_owner == null:
		return

	moving_owner.visible = true
	moving_owner.configure_placement(moving_original_cell, moving_original_footprint, floor)
	occupancy.reserve(moving_original_cell, moving_original_footprint, moving_owner, ROOM_SIZE)
	moving_owner = null

func _delete_at_hover() -> void:
	if moving_owner != null:
		return

	var owner := occupancy.owner_at(hover_cell)
	if owner == null or not is_instance_valid(owner):
		return
	if not owner is FurnitureBase:
		return

	var furniture := owner as FurnitureBase
	occupancy.release(furniture)
	furniture.queue_free()
	_update_status()

func _update_status() -> void:
	var mode := "PLACE"
	if moving_owner != null:
		mode = "MOVE"

	status_label.text = "Native TileMapLayer Placement Lab  |  %s  |  Footprint %dx%d  |  Occupied cells: %d" % [
		mode,
		selected_footprint.x,
		selected_footprint.y,
		occupancy.occupied_count()
	]

	controls_label.text = "1 = 1x1 TEST   2 = 2x2 TEST   3 = REAL BAR 1x3   |   Left click = place   M = move   Right click = delete   Esc = cancel"
