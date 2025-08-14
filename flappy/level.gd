extends Node2D

@export var biome_scene: PackedScene = preload("res://biome_objects.tscn")

const speed := 150
const BIOMES := [
	preload("res://Resources/Biomes/dirt.tres"),
	preload("res://Resources/Biomes/ice.tres"),
	preload("res://Resources/Biomes/rock.tres"),
	preload("res://Resources/Biomes/snow.tres"),
]

@onready var biome_scenes := $BiomeScenes
@onready var player: Player = $Player
@onready var score_label: Label = $CanvasLayer/Control/HBoxContainer/ScoreLabel

var biome_instances: Array = []
var score := 0
var gameover := false

func _ready() -> void:
	randomize()

	var add_at_x := 0.0

	for i in range(3):
		var instance = biome_scene.instantiate()

		biome_instances.append(instance)
		biome_scenes.add_child(instance)

		instance.set_obstacle_positions()
		instance.set_biome(BIOMES[randi() % BIOMES.size()])
		
		instance.player_scored.connect(increment_score)

		instance.position.x = add_at_x
		add_at_x += instance.width

func _input(event):
	if event.is_action_pressed("Flap") and not gameover:
		player.flap()
		
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _physics_process(delta: float) -> void:
	if gameover:
		return

	var to_remove: Array = []

	for instance in biome_instances:
		instance.position.x -= speed * delta

		if instance.position.x < -instance.width:
			to_remove.append(instance)

	for instance in to_remove:
		biome_instances.erase(instance)
		
		instance.set_obstacle_positions()
		instance.set_biome(BIOMES[randi() % BIOMES.size()])

		var last_biome :Node = biome_instances[biome_instances.size() - 1]
		instance.position.x = last_biome.position.x + last_biome.width

		biome_instances.append(instance)

# Player went too far off the top of the screen
func _on_too_high_body_entered(_body: Node2D) -> void:
	end_game()

# Player hit an obstacle
func _on_player_hit_obstacle() -> void:
	end_game()

func increment_score() -> void:
	score += 1

	score_label.text = str(score)

func end_game():
	gameover = true
