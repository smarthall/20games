extends Node2D

@onready var ground_sprite: Sprite2D = $Ground/Sprite2D
@onready var up_sprite: Sprite2D = $Up/Sprite2D
@onready var down_sprite: Sprite2D = $Down/Sprite2D

func _ready() -> void:
	pass

func set_biome(new_biome: Biome) -> void:
	ground_sprite.texture = new_biome.ground
	up_sprite.texture = new_biome.up
	down_sprite.texture = new_biome.down
