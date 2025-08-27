@tool
extends Node2D
class_name Obstacle

signal rewind

@export var config: ObstacleConfig

@onready var _collision_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var _half_width: float = config.width / 2
@onready var _min_x: float = - _half_width
@onready var _max_x: float = get_viewport().size.x + _half_width

const COLLISION_MARGIN := 10.0

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
	if config.animation && _sprite && _sprite.sprite_frames != config.animation:
		_sprite.sprite_frames = config.animation

	if _collision_shape && _collision_shape.shape.size.x != config.width - COLLISION_MARGIN:
		_collision_shape.shape.size.x = config.width - COLLISION_MARGIN
