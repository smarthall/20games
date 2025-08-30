@tool
extends Node2D
class_name Obstacle

signal rewind

@export var config: ObstacleConfig

@onready var _collision_shape: CollisionShape2D = $ObstacleBody/CollisionShape2D
@onready var _collision_body: StaticBody2D = $ObstacleBody
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var _half_width: float = config.width / 2
@onready var _min_x: float = - _half_width
@onready var _max_x: float = get_viewport().size.x + _half_width

const COLLISION_MARGIN := 10.0

func is_landable() -> bool:
	return config.landable

func _ready() -> void:
	update_objects()

func _process(delta: float) -> void:
	# If running in the editor, don't process
	if Engine.is_editor_hint():
		update_objects()
		return

	# Update the obstacle's position based on its speed
	position.x += config.speed * delta

	if config.speed < 0 and position.x < _min_x:
		position.x = _max_x
		rewind.emit()

	elif config.speed > 0 and position.x > _max_x:
		position.x = _min_x
		rewind.emit()

func update_objects() -> void:
	if config.animation and _sprite and _sprite.sprite_frames != config.animation:
		_sprite.sprite_frames = config.animation

	if _collision_shape and _collision_shape.shape.size.x != config.width - COLLISION_MARGIN:
		_collision_shape.shape.size.x = config.width - COLLISION_MARGIN

	if _collision_shape and _collision_shape.position.x != config.collision_x_offset:
		_collision_shape.position.x = config.collision_x_offset

	if _collision_body and config.landable:
		_collision_body.add_to_group("platforms")
		_collision_body.remove_from_group("killers")
	elif _collision_body and not config.landable:
		_collision_body.remove_from_group("platforms")
		_collision_body.add_to_group("killers")
