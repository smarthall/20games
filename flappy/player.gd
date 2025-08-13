extends RigidBody2D

const flap_strength = 500

func _ready() -> void:
	$AnimatedSprite2D.play("default")

func _input(event):
	if event.is_action_pressed("Flap"):
		apply_impulse(Vector2.UP * flap_strength, Vector2.ZERO)
