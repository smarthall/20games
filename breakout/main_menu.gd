extends Control

const game_scene := preload("res://game_space.tscn")

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_exit_pressed() -> void:
	get_tree().quit()
