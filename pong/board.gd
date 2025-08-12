extends Node2D

@onready var gui := $CanvasLayer/ScoreGUI
@onready var ball := $Ball

var _left_score: int = 0
var _right_score: int = 0
var _is_game_over: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("StartGame") and _is_game_over:
		_restart_game()

func _restart_game() -> void:
	_left_score = 0
	_right_score = 0
	_is_game_over = false
	_update_scores()
	ball.reset()

func _on_ball_ball_out_on_right() -> void:
	_left_score += 1
	_update_scores()

func _on_ball_ball_out_on_left() -> void:
	_right_score += 1
	_update_scores()

func _update_scores() -> void:
	gui.left_score = _left_score
	gui.right_score = _right_score

	if _left_score >= 5:
		_game_over("Green")

	elif _right_score >= 5:
		_game_over("Red")

	else:
		gui.win_text = ""

func _game_over(winner: String) -> void:
	_is_game_over = true
	gui.win_text = winner + " Wins"
	ball.in_motion = false
