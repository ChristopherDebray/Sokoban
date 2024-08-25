extends Node

const LEVEL_DATA_PATH: String = "res://data/level_data.json"
const TILE_SIZE: int = 32

var _level_data: Dictionary = {} 

func _ready() -> void:
	load_level_data()
	pass # Replace with function body.

func add_tiles_for_layer(
	layout: LevelLayout,
	layer_type: TileLayers.LayerType,
	tile_coords: Array
) -> void:
	for tile_coord in tile_coords:
		layout.add_tile_to_layer(tile_coord.x, tile_coord.y, layer_type)

func setup_level(lns: String, raw_lvl_data: Dictionary) -> LevelLayout:
	var layout: LevelLayout = LevelLayout.new()
	var raw_tiles: Dictionary = raw_lvl_data.tiles
	var ps: Dictionary = raw_lvl_data['player_start']
	
	add_tiles_for_layer(layout, TileLayers.LayerType.FLOOR, raw_tiles.Floor)
	add_tiles_for_layer(layout, TileLayers.LayerType.WALL, raw_tiles.Walls)
	add_tiles_for_layer(layout, TileLayers.LayerType.TARGET, raw_tiles.Targets)
	add_tiles_for_layer(layout, TileLayers.LayerType.BOX, raw_tiles.Boxes)
	add_tiles_for_layer(layout, TileLayers.LayerType.TARGET_BOX, raw_tiles.TargetBoxes)
	layout.set_player_start(ps.x, ps.y)
	
	return layout

func load_level_data() -> void:
	var file = FileAccess.open(LEVEL_DATA_PATH, FileAccess.READ)
	var raw_data = JSON.parse_string(file.get_as_text())
	
	for lns in raw_data.keys():
		_level_data[lns] = setup_level(lns, raw_data[lns])

func get_level_data(lvl_number: String) -> LevelLayout:
	return _level_data[lvl_number]
