@tool

extends CanvasLayer

@export var hearts: int = 3: set = _set_health, get = _get_health

const heart_full_texture = preload("res://Resources/hud_heart.svg")
const heart_empty_texture = preload("res://Resources/hud_heart_empty.svg")

@onready var heart_one_sprite = $Control/MarginContainer/HBoxContainer/HeartOne
@onready var heart_two_sprite = $Control/MarginContainer/HBoxContainer/HeartTwo
@onready var heart_three_sprite = $Control/MarginContainer/HBoxContainer/HeartThree

func _set_health(value: int) -> void:
	hearts = clamp(value, 0, 3)

	if hearts < 3:
		heart_three_sprite.texture = heart_empty_texture
	else:
		heart_three_sprite.texture = heart_full_texture

	if hearts < 2:
		heart_two_sprite.texture = heart_empty_texture
	else:
		heart_two_sprite.texture = heart_full_texture

	if hearts < 1:
		heart_one_sprite.texture = heart_empty_texture
	else:
		heart_one_sprite.texture = heart_full_texture

func _get_health() -> int:
	return hearts
