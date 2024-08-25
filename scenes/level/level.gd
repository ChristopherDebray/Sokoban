extends Node2D

const FLOOR_SOURCE_ID = 0

@onready var tile_layers: Node2D = $TileLayers
@onready var floors: TileMapLayer = $TileLayers/Floors
@onready var walls: TileMapLayer = $TileLayers/Walls
@onready var targets: TileMapLayer = $TileLayers/Targets
@onready var boxes: TileMapLayer = $TileLayers/Boxes
@onready var player: AnimatedSprite2D = $Player
@onready var camera_2d: Camera2D = $Camera2D
@onready var hud: Hud = $CanvasLayer2/Hud
@onready var level_complete: LevelCompleteUi = $CanvasLayer2/LevelComplete

var _total_moves: int = 0
var _player_tile: Vector2i = Vector2i.ZERO
var _game_over: bool = false

func _ready() -> void:
	setup_level()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reload"):
		setup_level()

	if Input.is_action_just_pressed("exit"):
		GameManager.load_main_scene()

	if _game_over == true:
		return

	var mv_direction: Vector2i
	
	if Input.is_action_just_pressed("up") == true:
		mv_direction = Vector2i.UP
		player_move(mv_direction)
	if Input.is_action_just_pressed("right") == true:
		mv_direction = Vector2i.RIGHT
		player.flip_h = false
		player_move(mv_direction)
	if Input.is_action_just_pressed("left") == true:
		mv_direction = Vector2i.LEFT
		player.flip_h = true
		player_move(mv_direction)
	if Input.is_action_just_pressed("down") == true:
		mv_direction = Vector2i.DOWN
		player_move(mv_direction)
		
	

func clear_tiles() -> void:
	for tile_layer in tile_layers.get_children():
		tile_layer.clear()

func setup_level() -> void:
	var lvl_nb: String = GameManager.get_level_selected()
	hud.new_game(lvl_nb)
	level_complete.new_game()
	var layout: LevelLayout = LevelData.get_level_data(lvl_nb)
	_total_moves = 0
	
	clear_tiles()
	
	setup_layer(TileLayers.LayerType.FLOOR, floors, layout)
	setup_layer(TileLayers.LayerType.WALL, walls, layout)
	setup_layer(TileLayers.LayerType.TARGET, targets, layout)
	setup_layer(TileLayers.LayerType.BOX, boxes, layout)
	setup_layer(TileLayers.LayerType.TARGET_BOX, boxes, layout)
	
	place_player_on_tile(layout.get_player_start())
	
	setup_camera()

func place_player_on_tile(tile_coord: Vector2i) -> void:
	var position: Vector2 = Vector2(
		tile_coord.x * LevelData.TILE_SIZE,
		tile_coord.y * LevelData.TILE_SIZE,
	) + tile_layers.position
	
	player.position = position
	_player_tile = tile_coord

func player_move(direction: Vector2i) -> void:
	var new_tile: Vector2i = _player_tile + direction
	var can_move: bool = true
	var box_seen: bool = false
	
	if cell_is_wall(new_tile):
		can_move = false
		return
	
	if cell_is_box(new_tile):
		box_seen = true
		can_move = can_box_move(new_tile, direction)

	if can_move == true:
		_total_moves += 1
		hud.set_moves_label(_total_moves)
		if box_seen == true:
			move_box(new_tile, direction)
		place_player_on_tile(new_tile)
		check_game_state()

func cell_is_wall(tile_pos: Vector2i) -> bool:
	return tile_pos in walls.get_used_cells()

func cell_is_box(tile_pos: Vector2i) -> bool:
	return tile_pos in boxes.get_used_cells()

func cell_is_empty(tile_pos: Vector2i) -> bool:
	return !cell_is_box(tile_pos) and !cell_is_wall(tile_pos)

func can_box_move(box_tile: Vector2i, direction: Vector2i) -> bool:
	return cell_is_empty(box_tile + direction)

func move_box(box_tile: Vector2i, direction: Vector2i) -> void:
	var destination: Vector2i = box_tile + direction
	boxes.erase_cell(box_tile)
	var cell_type = TileLayers.LayerType.BOX
	
	if destination in targets.get_used_cells():
		cell_type = TileLayers.LayerType.TARGET_BOX
	
	boxes.set_cell(
		destination,
		FLOOR_SOURCE_ID,
		get_atlas_coord_for_layer_type(cell_type)
	)

func check_game_state() -> void:
	for tile in targets.get_used_cells():
		if cell_is_box(tile) == false:
			return
	
	_game_over == true
	level_complete.game_over(GameManager.get_level_selected(), _total_moves)
	ScoreSync.level_completed(GameManager.get_level_selected(), _total_moves)

func get_atlas_coord_for_layer_type(type: TileLayers.LayerType) -> Vector2i:
	match type:
		TileLayers.LayerType.FLOOR:
			return Vector2i(randi_range(3, 8), 0)
		TileLayers.LayerType.WALL:
			return Vector2i(2, 0)
		TileLayers.LayerType.TARGET:
			return Vector2i(9, 0)
		TileLayers.LayerType.BOX:
			return Vector2i(1, 0)
		TileLayers.LayerType.TARGET_BOX:
			return Vector2i(0, 0)
	
	return Vector2i.ZERO

func add_tile(
	type: TileLayers.LayerType,
	tile_coord: Vector2i,
	map_layer: TileMapLayer
) -> void:
	var atlas_coord = get_atlas_coord_for_layer_type(type)
	map_layer.set_cell(tile_coord, FLOOR_SOURCE_ID, atlas_coord)

func setup_layer(
	type: TileLayers.LayerType,
	map_layer: TileMapLayer,
	level_layout: LevelLayout
) -> void:
	var tiles_array: Array[Vector2i] = level_layout.get_tiles_for_layer(type)
	for tile_coord in tiles_array:
		add_tile(type, tile_coord, map_layer)

func setup_camera() -> void:
	var tmr: Rect2i = floors.get_used_rect()
	# Get the 'map' width and height
	var tmr_w_x: float = tmr.size.x * LevelData.TILE_SIZE
	var tmr_w_y: float = tmr.size.y * LevelData.TILE_SIZE
	
	# Calculates the middle for x and y axis to place the camera
	var mid_x: float = tmr_w_x / 2 + (tmr.position.x * LevelData.TILE_SIZE)
	var mid_y: float = tmr_w_y / 2 + (tmr.position.y * LevelData.TILE_SIZE)
	camera_2d.position = Vector2(mid_x, mid_y)
