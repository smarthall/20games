extends Node2D
class_name Brick

signal destroyed(ball: Ball)

@onready var brick_body: StaticBody2D = $BrickBody
@onready var hit_sound: AudioStreamPlayer2D = $HitSound

func hit(ball: Ball) -> void:
	emit_signal("destroyed", ball)
	hit_sound.play()
	brick_body.queue_free()

func _on_hit_sound_finished() -> void:
	queue_free()
