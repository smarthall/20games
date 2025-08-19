extends CanvasLayer
class_name GameOverScreen

@export var score: int
@export var distance: float
@export var coins: int

@onready var score_label: Label = $%ScoreLabel
@onready var distance_label: Label = $%DistanceScoreLabel
@onready var coins_label: Label = $%CoinScoreLabel

func _ready() -> void:
	score_label.text = str(score)
	distance_label.text = str(roundi(distance)) + " m"
	coins_label.text = str(coins)

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_exit_button_pressed()
