extends CharacterBody2D

@export var direction: Vector2 = Vector2.ZERO

func _physics_process(_delta: float) -> void:
    position += direction * _delta
