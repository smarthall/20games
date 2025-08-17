extends CharacterBody2D
class_name Player

signal hazard_collision

@onready var exhaust: CPUParticles2D = $Exhaust
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collector: RayCast2D = $Collector

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

	velocity.y += GRAVITY * delta

	velocity.y = clamp(velocity.y, -TERMINAL_VELOCITY, TERMINAL_VELOCITY)

	# Bounce back to X = 250
	var x_distance_offset = position.x - X_LOCATION
	if abs(x_distance_offset) > X_LOCATION_DEAD_ZONE:
		if x_distance_offset > 0:
			velocity.x = -lerp(X_RETURN_VELOCITY, 0.0, abs(x_distance_offset) / X_DISTANCE_MAX)
		else:
			velocity.x = lerp(-X_RETURN_VELOCITY, 0.0, abs(x_distance_offset) / X_DISTANCE_MAX)
	else:
		velocity.x = 0

	move_and_slide()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()

		if collider.is_in_group("Hazards"):
			handle_hazard_collision(collision)

	if collector.is_colliding() && collector.get_collider() is TileMapLayer && collector.get_collider().is_in_group("Pickups"):
		handle_pickup_collision(collector.get_collision_point(), collector.get_collider())

	if is_on_floor():
		sprite.play("default")
	else:
		sprite.play("jump")

func handle_hazard_collision(_collision: KinematicCollision2D) -> void:
	hazard_collision.emit()

func handle_pickup_collision(collision_point: Vector2, body: TileMapLayer) -> void:
	# TODO Get the map tile collided with
	# TODO Fire a signal with the body, and the tile
	pass
