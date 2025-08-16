extends ColorRect

@export var spawn_count: Vector2i = Vector2i(5, 3)

const brick_scene: PackedScene = preload("res://brick.tscn")

func _ready() -> void:
    var parent: Node2D = get_parent()
    var distance_between_x = size.x / spawn_count.x
    var distance_between_y = size.y / spawn_count.y

    var destroy_handle_function = get_parent().get_parent().handle_brick_destroyed

    for x in range(spawn_count.x):
        for y in range(spawn_count.y):
            var brick: Brick = brick_scene.instantiate()

            brick.position = Vector2(
                distance_between_x / 2 + x * distance_between_x,
                distance_between_y / 2 + y * distance_between_y) + position

            brick.connect("destroyed", destroy_handle_function)

            parent.add_child.call_deferred(brick)
            brick.set_meta("spawned", true)

    queue_free()
