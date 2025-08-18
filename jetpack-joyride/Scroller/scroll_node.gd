extends Node2D
class_name ScrollNode

@export var size: Vector2

func queue_free_children() -> void:
	for child in get_children():
		child.queue_free()
