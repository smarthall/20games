extends Node2D

@export var jump_distance: float = 0.0

func _process(delta: float) -> void:
    if Input.is_action_pressed("left"):
        position.x -= 200 * delta
    elif Input.is_action_pressed("right"):
        position.x += 200 * delta
    elif Input.is_action_just_pressed("up"):
        position.y -= jump_distance
    elif Input.is_action_just_pressed("down"):
        position.y += jump_distance
