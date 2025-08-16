extends Node2D

@export var initial_lives :int = 3

@onready var ball_holding_node : Node2D = $Player/BallHoldingNode
@onready var player: Player = $Player
@onready var ui : CanvasLayer = $UI
@onready var bricks: Node2D = $Bricks

@onready var lives : int = 0: set = update_lives_display
@onready var score : int = 0: set = update_score_display

const ball_scene := preload("res://ball.tscn")
const menu_scene := "res://main_menu.tscn"

var held_ball: Ball = null
var game_ended: bool = false

func _ready() -> void:
	lives = initial_lives
	new_ball()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Action") && held_ball:
		launch_ball()

	elif event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_packed(load(menu_scene))

func _on_ball_killer_body_entered(body: Node2D) -> void:
	if body is Ball:
		handle_ball_loss(body)

func update_lives_display(value: int) -> void:
	lives = value
	ui.hearts = value

func update_score_display(value: int) -> void:
	score = value
	ui.score = value

func handle_brick_destroyed(_ball: Ball) -> void:
	update_score_display(score + 1)

	# If the last brick was destroyed
	if bricks.get_child_count() == 1:
		gameover(true)

func handle_ball_loss(ball: Ball) -> void:
	lives -= 1
	if lives <= 0:
		gameover(false)

	else:
		replace_ball(ball)

func new_ball() -> void:
	held_ball = ball_scene.instantiate()
	ball_holding_node.add_child.call_deferred(held_ball)

func replace_ball(ball: Ball) -> void:
	ball.queue_free()

	if not game_ended:
		new_ball()

func launch_ball() -> void:
	if not held_ball or game_ended:
		return

	held_ball.reparent(self)
	held_ball.start()
	held_ball = null

func gameover(won: bool) -> void:
	game_ended = true
	player.active = false
	
	ui.game_over = not won
	ui.won = won
