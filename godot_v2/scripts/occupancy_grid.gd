class_name OccupancyGrid
extends RefCounted

var _cells: Dictionary = {}
var _owner_cells: Dictionary = {}

func can_place(origin: Vector2i, footprint: Vector2i, room_size: Vector2i, ignore_owner: Object = null) -> bool:
	if origin.x < 0 or origin.y < 0:
		return false
	if origin.x + footprint.x > room_size.x or origin.y + footprint.y > room_size.y:
		return false

	for cell in footprint_cells(origin, footprint):
		if not _cells.has(cell):
			continue
		var owner: Object = _cells[cell]
		if ignore_owner != null and owner == ignore_owner:
			continue
		return false

	return true

func reserve(origin: Vector2i, footprint: Vector2i, owner: Object, room_size: Vector2i) -> bool:
	if not can_place(origin, footprint, room_size, owner):
		return false

	release(owner)
	var owned: Array[Vector2i] = footprint_cells(origin, footprint)
	for cell in owned:
		_cells[cell] = owner
	_owner_cells[owner] = owned
	return true

func release(owner: Object) -> void:
	if not _owner_cells.has(owner):
		return
	for cell in _owner_cells[owner]:
		if _cells.get(cell) == owner:
			_cells.erase(cell)
	_owner_cells.erase(owner)

func owner_at(cell: Vector2i) -> Object:
	return _cells.get(cell)

func footprint_cells(origin: Vector2i, footprint: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for y in range(footprint.y):
		for x in range(footprint.x):
			result.append(origin + Vector2i(x, y))
	return result

func occupied_count() -> int:
	return _cells.size()
