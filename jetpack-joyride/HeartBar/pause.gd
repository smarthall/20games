extends CanvasLayer

signal paused(paused: bool)

var _paused := false

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_resume_button_pressed() -> void:
	_paused = false
	paused.emit(false)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_paused = not _paused
		paused.emit(_paused)
