extends CharacterBody2D
class_name Ball

const speed: float = 400.0
const paddle_collision_layer: int = 1
const wall_collision_layer: int = 2
const brick_collision_layer: int = 8

func start() -> void:
	velocity = Vector2.UP * speed

func stop() -> void:
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		resolve_collision(collision)

func resolve_collision(collision: KinematicCollision2D) -> void:
	var collider : Node = collision.get_collider()
	var collider_layer : int = collider.collision_layer

	if collider_layer & paddle_collision_layer:
		resolve_collision_with_paddle(collision)

	elif collider_layer & wall_collision_layer:
		resolve_collision_with_walls(collision)

	elif collider_layer & brick_collision_layer:
		resolve_collision_with_brick(collision)

	else:
		print("Unhandled Collision in layer: ", collider_layer)
		print("  with node:", collider.get_name())

func resolve_collision_with_walls(collision: KinematicCollision2D) -> void:
	velocity = velocity.bounce(collision.get_normal())

func resolve_collision_with_paddle(collision: KinematicCollision2D) -> void:
	var paddle : Node2D = collision.get_collider() as Node2D
	velocity = paddle.global_position.direction_to(global_position).normalized() * speed

func resolve_collision_with_brick(collision: KinematicCollision2D) -> void:
	var brick : Node2D = collision.get_collider() as Node2D
	velocity = velocity.bounce(collision.get_normal())

	brick.queue_free()
