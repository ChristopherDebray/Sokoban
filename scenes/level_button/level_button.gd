extends NinePatchRect

class_name LevelButton

@onready var level_label: Label = $LevelLabel
@onready var completed_mark: TextureRect = $CompletedMark

var _level_number: String = "1"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	level_label.text = _level_number
	if ScoreSync.has_level_score(_level_number) == true:
		completed_mark.show()

func set_level_number(lvl: String) -> void:
	_level_number = lvl

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("select"):
		SignalManager.on_level_selected.emit(_level_number)
