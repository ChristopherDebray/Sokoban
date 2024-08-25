extends Node

const SCORE_FILE = "user://SOKOBAN.dat"
const DEFAULT_SCORE: int = 9999

var best_scores: Dictionary = {}

func _ready() -> void:
	load_scores()

func load_scores() -> void:
	if FileAccess.file_exists(SCORE_FILE) == false:
		return
	
	var file = FileAccess.open(SCORE_FILE, FileAccess.READ)
	best_scores = JSON.parse_string(file.get_as_text())

func save_scores() -> void:
	var file = FileAccess.open(SCORE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(best_scores))

func has_level_score(lvl: String) -> bool:
	return lvl in best_scores

func get_level_best_score(lvl: String) -> int:
	if has_level_score(lvl) == true:
		return best_scores[lvl]
	return DEFAULT_SCORE

func score_is_new_best(lvl: String, moves: int) -> bool:
	if has_level_score(lvl) == false:
		return true
	if get_level_best_score(lvl) > moves:
		return true
	return false

func level_completed(lvl: String, moves: int) -> void:
	if score_is_new_best(lvl, moves) == true:
		best_scores[lvl] = moves
		save_scores()
