extends RigidBody2D
class_name Player

signal hit_obstacle

const flap_strength = 500
const obstacle_layer = 1
const score_layer = 2

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func flap() -> void:
	apply_impulse(Vector2.UP * flap_strength, Vector2.ZERO)

func _on_body_entered(body:Node) -> void:
	if body is StaticBody2D:
		hit_obstacle.emit()
