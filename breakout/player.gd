extends CharacterBody2D

@export var speed: float = 400.0
@export var paddle_margin: float = 10.0

@onready var collision_shape: CollisionShape2D = $Collision

func _physics_process(delta: float) -> void:
    var screen_size = get_viewport_rect().size
    var paddle_size = collision_shape.get_shape().get_rect().size

    var paddle_min_x = paddle_margin + paddle_size.x / 2
    var paddle_max_x = screen_size.x - paddle_size.x / 2 - paddle_margin

    if Input.is_action_pressed("PaddleLeft"):
        position.x += - speed * delta
    elif Input.is_action_pressed("PaddleRight"):
        position.x += speed * delta

    position.x = clamp(position.x, paddle_min_x, paddle_max_x)
