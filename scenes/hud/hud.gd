extends Control

class_name Hud

@onready var level_label: Label = $MC/VB/HB/LevelLabel
@onready var moves_label: Label = $MC/VB/HB2/MovesLabel
@onready var best_score_label: Label = $MC/VB/HB3/BestScoreLabel

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	pass

# We could / should use signals here but we don't only to show this is possible
func new_game(lvl: String) -> void:
	var best_score: int = ScoreSync.get_level_best_score(lvl)
	best_score_label.text = "-" if best_score == ScoreSync.DEFAULT_SCORE else str(best_score)
	
	level_label.text = lvl
	set_moves_label(0)

func set_moves_label(moves: int) -> void:
	moves_label.text = str(moves)
