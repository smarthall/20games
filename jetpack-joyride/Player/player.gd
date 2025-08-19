extends CharacterBody2D
class_name Player

signal hazard_collision
signal pickup_collision(body: TileMapLayer, coords: Vector2i)

@onready var exhaust: CPUParticles2D = $Exhaust
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collector: ShapeCast2D = $Collector

const X_LOCATION := 250.0
const X_LOCATION_DEAD_ZONE := 5.0
const X_RETURN_VELOCITY := 500.0
const X_DISTANCE_MAX := 55.0

const GRAVITY := 2000.0
const JETPACK_POWER := 4000.0
const TERMINAL_VELOCITY := 5000.0

var invincible_until: float = 0.0
var _paused := false

func _physics_process(delta: float) -> void:
	if _paused:
		return

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

	if collector.is_colliding():
		for i in collector.get_collision_count():
			var collider := collector.get_collider(i)
			var collision_point := collector.get_collision_point(i)
			if collider is TileMapLayer:
				handle_pickup_collision(collision_point, collider)

	if is_on_floor():
		sprite.play("default")
	else:
		sprite.play("jump")

	if is_invincible():
		sprite.material.set_shader_parameter("strength", 0.5)
	else:
		sprite.material.set_shader_parameter("strength", 0.0)

func invincible(time_seconds: float) -> void:
	var now := Time.get_ticks_msec()
	if invincible_until < now:
		invincible_until = now + time_seconds * 1000
	else:
		invincible_until += time_seconds * 1000

func is_invincible() -> bool:
	return invincible_until > Time.get_ticks_msec()

func pause(paused: bool):
	_paused = paused

	set_physics_process(not paused)

	if paused:
		# FIXME: This does not seem to have any effect
		sprite.stop()
		exhaust.emitting = false

func handle_hazard_collision(_collision: KinematicCollision2D) -> void:
	hazard_collision.emit()

func handle_pickup_collision(collision_point: Vector2, body: TileMapLayer) -> void:
	var local_collision_point := body.to_local(collision_point)
	var map_collision_point := body.local_to_map(local_collision_point)

	if body.get_cell_tile_data(map_collision_point) != null:
		pickup_collision.emit(body, map_collision_point)
