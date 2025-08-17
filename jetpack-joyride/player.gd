extends CharacterBody2D
class_name Player

@onready var exhaust: CPUParticles2D = $Exhaust
@onready var sprite: AnimatedSprite2D = $Sprite

const X_LOCATION := 250.0
const X_LOCATION_DEAD_ZONE := 5.0
const X_RETURN_VELOCITY := 500.0
const X_DISTANCE_MAX := 55.0

const GRAVITY := 2000.0
const JETPACK_POWER := 4000.0
const TERMINAL_VELOCITY := 5000.0

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("jetpack"):
		velocity.y += -JETPACK_POWER * delta
		exhaust.emitting = true
	else:
		exhaust.emitting = false

	if is_on_floor():
		sprite.play("default")
	else:
		sprite.play("jump")

	velocity.y += GRAVITY * delta

	velocity.y = clamp(velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)

	var x_distance_offset = position.x - X_LOCATION
	if abs(x_distance_offset) > X_LOCATION_DEAD_ZONE:
		if x_distance_offset > 0:
			velocity.x = -lerp(X_RETURN_VELOCITY, 0.0, abs(x_distance_offset) / X_DISTANCE_MAX)
		else:
			velocity.x = lerp(-X_RETURN_VELOCITY, 0.0, abs(x_distance_offset) / X_DISTANCE_MAX)
	else:
		velocity.x = 0

	move_and_slide()
