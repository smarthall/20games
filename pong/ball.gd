extends CharacterBody2D

@export var speed: float = 200.0
@export var direction: Vector2 = Vector2.LEFT

func _physics_process(delta: float) -> void:
    var collision = move_and_collide(direction * speed * delta)
    if collision:
        direction = direction.bounce(collision.get_normal())
