extends RigidBody2D
class_name Player

signal hit_obstacle

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var exhaust: CPUParticles2D = $Exhaust

const flap_strength = 700
const obstacle_layer = 1
const score_layer = 2

func start() -> void:
	animated_sprite.play("default")
	exhaust.emitting = true

func stop() -> void:
	animated_sprite.stop()
	exhaust.emitting = false

func flap() -> void:
	apply_impulse(Vector2.UP * flap_strength, Vector2.ZERO)

func _on_body_entered(body:Node) -> void:
	if body is StaticBody2D:
		hit_obstacle.emit()
