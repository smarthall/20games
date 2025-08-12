extends CharacterBody2D

signal ball_out_on_left
signal ball_out_on_right

@export var speed: float = 200.0
@export var direction: Vector2 = Vector2.LEFT
@export var in_motion: bool = true

func _physics_process(delta: float) -> void:
    if not in_motion:
        return

    var collision = move_and_collide(direction * speed * delta)
    if collision:
        direction = direction.bounce(collision.get_normal())

    if position.x < -20:
        reset()
        emit_signal("ball_out_on_left")

    elif position.x > get_viewport_rect().size.x + 20:
        reset()
        emit_signal("ball_out_on_right")

func reset():
    position = get_viewport_rect().size / 2
    direction = Vector2.LEFT
    in_motion = true
