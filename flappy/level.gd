extends Node2D

@export var biome_scene: PackedScene = preload("res://biome_objects.tscn")

const speed := 100
const BIOMES := [
	preload("res://Resources/Biomes/dirt.tres"),
	preload("res://Resources/Biomes/ice.tres"),
	preload("res://Resources/Biomes/rock.tres"),
	preload("res://Resources/Biomes/snow.tres"),
]

@onready var biome_scenes := $BiomeScenes

var biome_instances: Array = []

func _ready() -> void:
	randomize()

	var add_at_x := 0.0

	for i in range(3):
		var instance = biome_scene.instantiate()

		biome_instances.append(instance)
		biome_scenes.add_child(instance)

		instance.set_obstacle_positions()
		instance.set_biome(BIOMES[randi() % BIOMES.size()])

		instance.position.x = add_at_x
		add_at_x += instance.width

func _physics_process(delta: float) -> void:
	var to_remove: Array = []

	for instance in biome_instances:
		instance.position.x -= speed * delta

		if instance.position.x < -instance.width:
			to_remove.append(instance)

	for instance in to_remove:
		biome_instances.erase(instance)
		
		instance.set_obstacle_positions()
		instance.set_biome(BIOMES[randi() % BIOMES.size()])

		var last_biome := biome_instances.size() - 1
		instance.position.x = biome_instances[last_biome].position.x + biome_instances[last_biome].width

		biome_instances.append(instance)
