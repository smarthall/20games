extends CharacterBody2D

signal ball_out_on_left
signal ball_out_on_right

@onready var sound_hit_wall := $SoundHitWall
@onready var sound_hit_paddle := $SoundHitPaddle

@export var speed: float = 200.0
@export var direction: Vector2 = Vector2.LEFT
@export var in_motion: bool = true

const distance_off_screen := 20.0

func _physics_process(delta: float) -> void:
	if not in_motion:
		return

	var collision = move_and_collide(direction * speed * delta)
	if collision:
		direction = direction.bounce(collision.get_normal())
		_play_collision_sound(collision)

	if position.x < -distance_off_screen:
		emit_signal("ball_out_on_left")

	elif position.x > get_viewport_rect().size.x + distance_off_screen:
		emit_signal("ball_out_on_right")

func _play_collision_sound(collision: KinematicCollision2D) -> void:
	if collision.get_collider():
		var collider_name: String = collision.get_collider().name
		if collider_name == "LeftPaddle" or collider_name == "RightPaddle":
			sound_hit_paddle.play()
		elif collider_name == "TopWall" or collider_name == "BottomWall":
			sound_hit_wall.play()
