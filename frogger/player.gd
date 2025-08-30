extends Node2D
class_name Player

signal player_death
signal player_score

@export var jump_distance: float = 0.0
@export var jump_time: float = 0.15
@export var move_speed: float = 300.0

@onready var _ray: ShapeCast2D = $ShapeCast2D
@onready var _default_parent: Node2D = get_parent()
@onready var _initial_pos := global_position

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
		_in_air = true
	
		reparent(get_tree().get_root())

		var tween := create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:y", position.y - jump_distance, jump_time)
		tween.tween_callback(land)

		rotation_degrees = ROTATION_UP

	elif Input.is_action_just_pressed("down"):
		_in_air = true

		reparent(get_tree().get_root())

		var tween := create_tween()
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "position:y", position.y + jump_distance, jump_time)
		tween.tween_callback(land)

		rotation_degrees = ROTATION_DOWN

	_ray.force_shapecast_update()
	if _ray.is_colliding():
		var collider = _ray.get_collider(0)
		if collider.is_in_group("killers"):
			_die()

func _reset_position() -> void:
	if get_parent() != _default_parent:
		_default_parent.add_child(self)

	global_position = _initial_pos

func _score() -> void:
	_reset_position()
	player_score.emit()

func _die():
	_reset_position()
	player_death.emit()

func land() -> void:
	_in_air = false

	_ray.force_shapecast_update()
	if _ray.is_colliding():
		var collider = _ray.get_collider(0)
		if collider.is_in_group("platforms"):
			reparent(collider)

		elif collider.is_in_group("goal"):
			collider.get_parent().score()
			_score()
