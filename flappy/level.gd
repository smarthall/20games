extends Node2D

@export var biome_scene: PackedScene = preload("res://biome_objects.tscn")

const speed := 300
const BIOMES := [
	preload("res://Resources/Biomes/dirt.tres"),
	preload("res://Resources/Biomes/ice.tres"),
	preload("res://Resources/Biomes/rock.tres"),
	preload("res://Resources/Biomes/snow.tres"),
]

# Level
@onready var biome_scenes := $BiomeScenes

# Sounds
@onready var high_score_sound: AudioStreamPlayer = $HighScoreSound
@onready var game_over_sound: AudioStreamPlayer = $GameOverSound

# Player
@onready var player: Player = $Player
@onready var initial_player_pos: Vector2 = $Player.position

# Labels
@onready var score_label: Label = $CanvasLayer/Control/ScoreLabel
@onready var game_over_label: Label = $CanvasLayer/Control/GameOverLabel
@onready var high_score_label: Label = $CanvasLayer/Control/HighScoreLabel

var biome_instances: Array = []
var new_high_score := false
var high_score := 0
var score := 0
var gameover := false

## Called when the node is added to the scene. Initializes biomes, connects signals,
## loads high score, and starts the game.
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

## Handles player input for flapping, restarting, and quitting the game.
## - Flap: Makes the player jump if not game over.
## - Restart: Restarts the game if game over.
## - ui_cancel: Quits the game.
func _input(event):
	if event.is_action_pressed("Flap") and not gameover:
		player.flap()

	elif event.is_action_pressed("Restart") and gameover:
		start_game()

	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()

## Moves biome instances to the left each frame, recycles them when off-screen,
## and manages biome repositioning. Skips processing if game is over.
##
## Params:
## - delta (float): Frame time step.
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

## Called when the player collides with the 'too high' area (top of screen).
## Ends the game.
func _on_too_high_body_entered(_body: Node2D) -> void:
	play_hit_noise()
	end_game()

## Called when the player hits an obstacle. Ends the game.
func _on_player_hit_obstacle() -> void:
	play_hit_noise()
	end_game()

## Resets all game state and positions to start a new run. Repositions biomes,
## resets player, hides game over label, and zeroes score.
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
	new_high_score = false
	gameover = false

# Plays the hit noise from the players location
func play_hit_noise() -> void:
	player.hit()

## Increments the player's score by 1 and updates the score label.
## Does nothing if the game is over.
func increment_score() -> void:
	if gameover:
		return

	player.score()

	score += 1

	if score > high_score && not new_high_score:
		new_high_score = true
		high_score_sound.play()

	score_label.text = str(score)

## Resets the score to zero and updates the score label.
func zero_score() -> void:
	score = 0
	score_label.text = str(score)

## Loads the high score from disk if it exists, prints it, and updates the display.
func load_high_score() -> void:
	if FileAccess.file_exists("user://high_score.save"):
		var save_file := FileAccess.open("user://high_score.save", FileAccess.READ)
		high_score = save_file.get_var()
		save_file.close()

	display_high_score()

## Saves the current high score to disk.
func save_high_score() -> void:
	var save_file := FileAccess.open("user://high_score.save", FileAccess.WRITE)
	save_file.store_var(high_score)
	save_file.close()

## Updates the high score label with the current high score value.
func display_high_score() -> void:
	high_score_label.text = "High Score: " + str(high_score)

## Ends the game: sets gameover, stops the player, shows game over label,
## and updates/saves high score if a new record is set.
func end_game() -> void:
	if gameover:
		return

	gameover = true
	player.stop()
	game_over_label.show()
	game_over_sound.play()

	if score > high_score:
		high_score = score

		display_high_score()
		save_high_score()
