extends Node2D

var _left_score: int = 0
var _right_score: int = 0

func _on_ball_ball_out_on_right() -> void:
    _left_score += 1
    _update_scores()

func _on_ball_ball_out_on_left() -> void:
    _right_score += 1
    _update_scores()

func _update_scores() -> void:
    $CanvasLayer/ScoreGUI.left_score = _left_score
    $CanvasLayer/ScoreGUI.right_score = _right_score
