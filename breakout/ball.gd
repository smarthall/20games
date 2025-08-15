extends CharacterBody2D
class_name Ball

const speed: float = 400.0

func start() -> void:
	velocity = Vector2.UP * speed

func stop() -> void:
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		resolve_collision(collision)

func resolve_collision(collision: KinematicCollision2D) -> void:
	var collider_layer : int = collision.get_collider().collision_layer
	if collider_layer & 2:
		resolve_collision_with_walls(collision)
	elif collider_layer & 1:
		resolve_collision_with_paddle(collision)
	else:
		print("Collided with layer: ", collider_layer)

func resolve_collision_with_walls(collision: KinematicCollision2D) -> void:
	velocity = velocity.bounce(collision.get_normal())

func resolve_collision_with_paddle(collision: KinematicCollision2D) -> void:
	var paddle : Node2D = collision.get_collider() as Node2D
	velocity = paddle.global_position.direction_to(global_position).normalized() * speed
