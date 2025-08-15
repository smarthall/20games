extends CharacterBody2D

@export var speed: float = 400.0

func _physics_process(delta: float) -> void:
    var movement := Vector2.ZERO

    if Input.is_action_pressed("PaddleLeft"):
        movement.x = - speed * delta
    elif Input.is_action_pressed("PaddleRight"):
        movement.x = speed * delta

    var collision := move_and_collide(movement)
    if collision:
        resolve_collision(collision)

func resolve_collision(collision: KinematicCollision2D) -> void:
    position.x -= collision.get_remainder().x
