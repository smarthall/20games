extends Node2D

@export var initial_lives :int = 3

@onready var ball_holding_node : Node2D = $Player/BallHoldingNode
@onready var ui : CanvasLayer = $UI

@onready var lives : int = 0: set = update_lives_display

const ball_scene : PackedScene = preload("res://ball.tscn")

var held_ball: Ball = null

func _ready() -> void:
	lives = initial_lives
	new_ball()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Action") && held_ball:
		launch_ball()

	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func update_lives_display(value: int) -> void:
	lives = value
	ui.hearts = value

func new_ball() -> void:
	held_ball = ball_scene.instantiate()
	ball_holding_node.add_child.call_deferred(held_ball)

func launch_ball() -> void:
	if not held_ball:
		push_error("No held_ball instance to launch!")
		return

	held_ball.reparent(self)
	held_ball.start()

func _on_ball_killer_body_entered(body: Node2D) -> void:
	if body is Ball:
		lives -= 1
		if lives <= 0:
			get_tree().quit()

		else:
			body.queue_free()
			new_ball()
