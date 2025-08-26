extends Node2D
class_name Obstacle

signal off_screen

@export var config: ObstacleConfig

func _process(delta: float) -> void:
	# Update the obstacle's position based on its speed
	position.x -= config.speed * delta

	if position.x < -config.width / 2:
		off_screen.emit()
