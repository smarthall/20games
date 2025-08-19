extends CanvasLayer

@onready var game_scene: PackedScene = preload("res://infinite_level.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jetpack"):
		# Start the game when the jetpack action is pressed
		_on_start_game_pressed()
	elif event.is_action_pressed("ui_cancel"):
		# Exit the game when the cancel action is pressed
		_on_exit_pressed()
