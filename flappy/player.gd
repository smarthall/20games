extends RigidBody2D
class_name Player

signal hit_obstacle

@export var flap_strength: float = 700.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var exhaust: CPUParticles2D = $Exhaust

const obstacle_layer = 1
const score_layer = 2

var reset_position: bool = false
var stored_position: Vector2

## Physics integration callback.
## When [code]reset_position[/code] is true (set by [code]reset_to()[/code]),
## teleports the player to [code]stored_position[/code], clears rotation and
## linear/angular velocities, and resets interpolation. This ensures a clean
## restart without residual physics from the previous state.
func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	if reset_position:
		global_position = stored_position
		rotation = 0.0
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		reset_physics_interpolation.call_deferred()
		reset_position = false

## Begins player activity: plays the idle/flight animation and starts the
## exhaust particle emission. Call when the run starts or the player becomes
## controllable.
func start() -> void:
	animated_sprite.play("default")
	exhaust.emitting = true

## Halts player activity: stops the animation and exhaust particles. Call on
## game over, pause, or when disabling player control.
func stop() -> void:
	animated_sprite.stop()
	exhaust.emitting = false

## Schedules a safe reset of the player's transform for the next physics tick.
##
## Params:
## - [code]new_position[/code] (Vector2): World position to move the player to.
##
## Effect: On the next call to [_integrate_forces], the player is teleported to
## [code]new_position[/code], rotation and velocities are cleared, and physics
## interpolation is reset.
func reset_to(new_position) -> void:
	stored_position = new_position
	reset_position = true

## Applies an upward impulse to make the player "flap". Magnitude is set by
## [code]flap_strength[/code]. Call in response to input.
func flap() -> void:
	apply_impulse(Vector2.UP * flap_strength, Vector2.ZERO)

## Collision callback for bodies entering the player's collider. Emits the
## [code]hit_obstacle[/code] signal when contacting static geometry (e.g.,
## rocks/ground), allowing the game to react (end run, play SFX, etc.).
func _on_body_entered(body: Node) -> void:
	if body is StaticBody2D:
		hit_obstacle.emit()
