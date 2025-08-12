extends Node2D

enum ServeState {
	LEFT,
	RIGHT,
}

@onready var gui := $CanvasLayer/ScoreGUI
@onready var ball := $Ball
@onready var game_over_sound := $GameEndSound
@onready var score_sound := $ScoreSound

const winning_score := 6

const left_player_name := "Green"
const right_player_name := "Red"

const ball_spawn_x = 576.0
const ball_spawn_min_y = 200.0
const ball_spawn_max_y = 448.0
const ball_spawn_direction_fudge = 0.3

var _left_score: int = 0
var _right_score: int = 0
var _serve_state: ServeState = ServeState.LEFT
var _is_game_over: bool = false

func _ready() -> void:
	randomize()
	_ball_reset()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
	elif event.is_action_pressed("StartGame") and _is_game_over:
		_restart_game()

func _on_ball_ball_out_on_right() -> void:
	_left_score += 1
	score_sound.play()
	_update_scores()
	_ball_reset()

func _on_ball_ball_out_on_left() -> void:
	_right_score += 1
	score_sound.play()
	_update_scores()
	_ball_reset()

func _ball_reset() -> void:
	ball.position = Vector2(ball_spawn_x, randf_range(ball_spawn_min_y, ball_spawn_max_y))
	ball.direction = _get_serve_direction()

func _update_scores() -> void:
	gui.left_score = _left_score
	gui.right_score = _right_score

	if _left_score >= winning_score:
		_game_over(left_player_name)

	elif _right_score >= winning_score:
		_game_over(right_player_name)

	else:
		gui.win_text = ""

func _restart_game() -> void:
	_left_score = 0
	_right_score = 0
	_is_game_over = false
	_update_scores()

	ball.in_motion = true
	_ball_reset()

func _game_over(winner: String) -> void:
	_is_game_over = true
	gui.win_text = winner + " Wins"
	ball.in_motion = false
	game_over_sound.play()

func _get_serve_direction() -> Vector2:
	var vector := Vector2.LEFT

	# Player to serve at
	if _serve_state == ServeState.LEFT:
		_serve_state = ServeState.RIGHT
		vector = Vector2.RIGHT
	else:
		_serve_state = ServeState.LEFT
		vector = Vector2.LEFT

	# Fudge factor
	return vector.rotated(randf_range(-ball_spawn_direction_fudge, ball_spawn_direction_fudge))
