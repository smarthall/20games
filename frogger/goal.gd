extends Node2D

@onready var _frog_scored: AnimatedSprite2D = $FrogScored

var _scored := false

func is_scored() -> bool:
	return _scored

func score() -> void:
	if not _scored:
		_scored = true
		_frog_scored.show()
