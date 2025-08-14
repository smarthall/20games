extends Node2D

signal player_scored

@export var width :float = 806.0

@onready var ground_sprite: Sprite2D = $Ground/Sprite2D

@onready var up_sprite: Sprite2D = $Up/Obstacle/Sprite2D
@onready var up: Node2D = $Up

@onready var down_sprite: Sprite2D = $Down/Obstacle/Sprite2D
@onready var down: Node2D = $Down

const obstacle_min_x := 100
const obstacle_max_x := 700

func set_obstacle_positions() -> void:
	up.position.x = randf_range(obstacle_min_x, obstacle_max_x)
	down.position.x = randf_range(obstacle_max_x, obstacle_max_x)

func set_biome(new_biome: Biome) -> void:
	ground_sprite.texture = new_biome.ground
	up_sprite.texture = new_biome.up
	down_sprite.texture = new_biome.down

func _on_score_body_entered(_body: Node2D) -> void:
	player_scored.emit()
