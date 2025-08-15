extends Node2D

@onready var ball_holding_node : Node2D = $Player/BallHoldingNode
@onready var ball : Ball = $Player/BallHoldingNode/Ball

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Action") && ball.get_parent() == ball_holding_node:
		launch_ball()

func launch_ball() -> void:
	ball.reparent(self)
	ball.start()
