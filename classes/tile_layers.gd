class_name TileLayers

enum LayerType {FLOOR, WALL, TARGET, BOX, TARGET_BOX}

var _floor: Array[Vector2i]
var _wall: Array[Vector2i]
var _target: Array[Vector2i]
var _box: Array[Vector2i]
var _target_box: Array[Vector2i]

var _layer_coords: Dictionary = {
	LayerType.FLOOR: _floor,
	LayerType.WALL: _wall,
	LayerType.TARGET: _target,
	LayerType.BOX: _box,
	LayerType.TARGET_BOX: _target_box,
}

func add_coord(coord: Vector2i, type: LayerType) -> void:
	_layer_coords[type].push_back(coord)

func get_tiles_for_layer_coords(type: LayerType) -> Array[Vector2i]:
	return _layer_coords[type]
