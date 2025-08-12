extends Control

@export var left_score: int = 0
@export var right_score: int = 0

@export var win_text: String = ""

@onready var left_player_score_label = $HBoxContainer/LeftPlayerScore
@onready var right_player_score_label = $HBoxContainer/RightPlayerScore
@onready var win_label = $WinLabel

func _process(_delta: float) -> void:
	left_player_score_label.text = str(left_score)
	right_player_score_label.text = str(right_score)

	if win_text != "":
		win_label.text = win_text
		win_label.show()
	else:
		win_label.hide()
