extends Node2D

@export var biome_scene: PackedScene = preload("res://biome_objects.tscn")

const speed := 300
const BIOMES := [
	preload("res://Resources/Biomes/dirt.tres"),
	preload("res://Resources/Biomes/ice.tres"),
	preload("res://Resources/Biomes/rock.tres"),
	preload("res://Resources/Biomes/snow.tres"),
]

@onready var biome_scenes := $BiomeScenes
@onready var player: Player = $Player
@onready var score_label: Label = $CanvasLayer/Control/ScoreLabel
@onready var game_over_label: Label = $CanvasLayer/Control/GameOverLabel
@onready var high_score_label: Label = $CanvasLayer/Control/HighScoreLabel

@onready var initial_player_pos: Vector2 = $Player.position

var biome_instances: Array = []
var high_score := 0
var score := 0
var gameover := false

func _ready() -> void:
	randomize()

	# Create three biomes to make sure the screen is covered at all times
	for i in range(3):
		var instance = biome_scene.instantiate()

		biome_instances.append(instance)
		biome_scenes.add_child(instance)

		instance.set_obstacle_positions()
		instance.set_biome(BIOMES[randi() % BIOMES.size()])
		
		instance.player_scored.connect(increment_score)

	load_high_score()
	start_game()

func _input(event):
	if event.is_action_pressed("Flap") and not gameover:
		player.flap()

	elif event.is_action_pressed("Restart") and gameover:
		start_game()

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

		var last_biome: Node = biome_instances[biome_instances.size() - 1]
		instance.position.x = last_biome.position.x + last_biome.width

		biome_instances.append(instance)

# Player went too far off the top of the screen
func _on_too_high_body_entered(_body: Node2D) -> void:
	end_game()

# Player hit an obstacle
func _on_player_hit_obstacle() -> void:
	end_game()

func start_game() -> void:
	var add_at_x := 0.0

	for i in range(3):
		var instance: Node2D = biome_instances[i]
		instance.position.x = add_at_x
		add_at_x += instance.width

	player.reset_to(initial_player_pos)
	player.start()

	game_over_label.hide()

	zero_score()
	gameover = false

func increment_score() -> void:
	if gameover:
		return

	score += 1

	score_label.text = str(score)

func zero_score() -> void:
	score = 0
	score_label.text = str(score)

func load_high_score() -> void:
	if FileAccess.file_exists("user://high_score.save"):
		var save_file := FileAccess.open("user://high_score.save", FileAccess.READ)
		high_score = save_file.get_var()
		save_file.close()
	print("High Score Loaded: ", high_score)

	display_high_score()

func save_high_score() -> void:
	var save_file := FileAccess.open("user://high_score.save", FileAccess.WRITE)
	save_file.store_var(high_score)
	save_file.close()

func display_high_score() -> void:
	high_score_label.text = "High Score: " + str(high_score)

func end_game() -> void:
	gameover = true
	player.stop()
	game_over_label.show()

	if score > high_score:
		high_score = score

		display_high_score()
		save_high_score()
