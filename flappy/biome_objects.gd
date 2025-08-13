extends Node2D

@export var width :float = 806.0

@onready var ground_sprite: Sprite2D = $Ground/Sprite2D

@onready var up_sprite: Sprite2D = $Up/Sprite2D
@onready var up: StaticBody2D = $Up

@onready var down_sprite: Sprite2D = $Down/Sprite2D
@onready var down: StaticBody2D = $Down

const obstacle_min_x := 100
const obstacle_max_x := 700

func set_obstacle_positions() -> void:
	up.position.x = randf_range(obstacle_min_x, obstacle_max_x)
	down.position.x = randf_range(obstacle_max_x, obstacle_max_x)

func set_biome(new_biome: Biome) -> void:
	ground_sprite.texture = new_biome.ground
	up_sprite.texture = new_biome.up
	down_sprite.texture = new_biome.down
