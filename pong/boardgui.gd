extends Control

@export var left_score: int = 0
@export var right_score: int = 0

func _process(_delta: float) -> void:
	$HBoxContainer/LeftPlayerScore.text = str(left_score)
	$HBoxContainer/RightPlayerScore.text = str(right_score)
