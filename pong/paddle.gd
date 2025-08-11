@tool
extends CharacterBody2D

@export var color : Color:
	set(value):
		color = value
		$ColorRect.color = value
	get:
		return color

@export var speed: float = 200.0

@export var action_up: String = "LocalUp"
@export var action_down: String = "LocalDown"

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if Input.is_action_pressed(action_up):
		var collision = move_and_collide(Vector2(0, -speed * delta))
		if collision:
			resolve_collision(collision)

	if Input.is_action_pressed(action_down):
		var collision = move_and_collide(Vector2(0, speed * delta))
		if collision:
			resolve_collision(collision)

func resolve_collision(collision: KinematicCollision2D) -> void:
	position.y = position.y - collision.get_remainder().y
