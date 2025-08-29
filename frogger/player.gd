extends Node2D
class_name Player

signal player_death

@export var jump_distance: float = 0.0
@export var move_speed: float = 200.0

@onready var _ray: ShapeCast2D = $ShapeCast2D

var _in_air := false

const ROTATION_UP := 0.0
const ROTATION_DOWN := 180.0
const ROTATION_LEFT := -90.0
const ROTATION_RIGHT := 90.0

func _physics_process(delta: float) -> void:
	if _in_air:
		return

	if Input.is_action_pressed("left"):
		position.x -= move_speed * delta
		rotation_degrees = ROTATION_LEFT

	elif Input.is_action_pressed("right"):
		position.x += move_speed * delta
		rotation_degrees = ROTATION_RIGHT

	elif Input.is_action_just_pressed("up"):
		position.y -= jump_distance
		rotation_degrees = ROTATION_UP

	elif Input.is_action_just_pressed("down"):
		position.y += jump_distance
		rotation_degrees = ROTATION_DOWN

	_ray.force_shapecast_update()
	if _ray.is_colliding():
		var collider = _ray.get_collider(0)
		print("Collision: ", collider.name)
