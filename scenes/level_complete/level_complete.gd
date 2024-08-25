extends MarginContainer

class_name LevelCompleteUi

@onready var moves_label: Label = $NinePatchRect/VB/HB/MovesLabel
@onready var new_record_label: Label = $NinePatchRect/VB/NewRecordLabel

func new_game() -> void:
	new_record_label.hide()
	hide()

func game_over(lvl: String, moves: int) -> void:
	moves_label.text = "%d  Moves taken !" % moves
	new_record_label.visible = ScoreSync.score_is_new_best(lvl, moves)
	show()
