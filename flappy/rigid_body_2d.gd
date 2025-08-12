extends RigidBody2D

func _input(event):
	if event.is_action_pressed("Flap"):
		apply_impulse(Vector2.UP * 500, Vector2.ZERO)
