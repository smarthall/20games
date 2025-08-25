extends Node2D

@onready var game_over_scene: PackedScene = preload("res://gameover_screen.tscn")

@onready var background: Scroller = $BackgroundScroller
@onready var hud: HUD = $HUD
@onready var player: Player = $Player
@onready var level_scroller: Scroller = $LevelScroller
@onready var pause: CanvasLayer = $Pause

const LEVEL_PARTS: Array[PackedScene] = [
	preload("res://LevelParts/hill.tscn"),
	preload("res://LevelParts/lake.tscn"),
	preload("res://LevelParts/lava.tscn"),
	preload("res://LevelParts/waterfall.tscn"),
	preload("res://LevelParts/platforms.tscn"),
]

const BACKGROUND_TILE_BLANK = Vector2i(2, 0)
const BACKGROUND_TILE_CACTUS = Vector2i(2, 1)
const BACKGROUND_TILE_TREES = Vector2i(3, 1)
const BACKGROUND_TILE_MUSHROOM = Vector2i(1, 3)
const BACKGROUND_TILE_WEIGHTS: Dictionary[int, Vector2i] = {
	50: BACKGROUND_TILE_BLANK,
	75: BACKGROUND_TILE_CACTUS,
	98: BACKGROUND_TILE_TREES,
	99: BACKGROUND_TILE_MUSHROOM,
}

const PICKUP_TILE_BRONZE_COIN = "bronze"
const BRONZE_VALUE = 1
const PICKUP_TILE_SILVER_COIN = "silver"
const SILVER_VALUE = 3
const PICKUP_TILE_GOLD_COIN = "gold"
const GOLD_VALUE = 5
const PICKUP_TILE_HEART = "heart"

const HEART_PICKUP_INVINCIBLE_SECONDS := 2.0
const HURT_INVINCIBLE_SECONDS := 0.5

func _on_level_scroller_setup_scroll_node(scroll_node:ScrollNode) -> void:
	# Delete all the scroll_node children
	for child in scroll_node.get_children():
		child.queue_free()

	# Load a random level part
	var level_part := LEVEL_PARTS[randi_range(0, LEVEL_PARTS.size() - 1)]
	var instance := level_part.instantiate()
	scroll_node.add_child(instance)

func randomize_background_timemap(tm: TileMapLayer) -> void:
	for x in range(tm.get_used_rect().size.x):
		var tile_position := Vector2i(x, 1)
		var random_tile := get_random_background_tile()
		tm.set_cell(tile_position, 1, random_tile)

func get_random_background_tile() -> Vector2i:
	var rand := randi_range(0, 100)

	for weight in BACKGROUND_TILE_WEIGHTS.keys():
		if rand < weight:
			return BACKGROUND_TILE_WEIGHTS[weight]

	return BACKGROUND_TILE_WEIGHTS[BACKGROUND_TILE_WEIGHTS.keys()[0]]

func heart_pickup() -> void:
	if hud.hp < 6:
		hud.hp += 1
	else:
		player.invincible(HEART_PICKUP_INVINCIBLE_SECONDS)

func hurt_player():
	if not player.is_invincible():
		hud.hp -= 1
		player.invincible(HURT_INVINCIBLE_SECONDS)

	if hud.hp == 0:
		gameover.call_deferred()

func gameover():
	var tree := get_tree()
	var cur_scene := tree.get_current_scene()

	var game_over: GameOverScreen = game_over_scene.instantiate()
	game_over.distance = hud.distance
	game_over.coins = hud.coins
	game_over.score = roundi(hud.distance + hud.coins * 10)

	tree.get_root().add_child(game_over)
	tree.set_current_scene(game_over)

	# Delete this scene in the next frame
	tree.get_root().remove_child.call_deferred(cur_scene)

func _process(delta: float) -> void:
	hud.distance += (delta * level_scroller.speed) / 100

func _on_background_tilemap_recycle(tilemap: TileMapLayer) -> void:
	randomize_background_timemap(tilemap)

func _on_background_scroller_setup_scroll_node(scroll_node: ScrollNode) -> void:
	var bg: TileMapLayer = scroll_node.get_node("Background")
	randomize_background_timemap(bg)

func _on_player_hazard_collision() -> void:
	hurt_player()

func _on_player_pickup_collision(body: TileMapLayer, coords: Vector2i):
	var type = body.get_cell_tile_data(coords).get_custom_data("type")

	body.erase_cell(coords)

	if type == PICKUP_TILE_HEART:
		heart_pickup()
	elif type == PICKUP_TILE_BRONZE_COIN:
		hud.coins += BRONZE_VALUE
	elif type == PICKUP_TILE_SILVER_COIN:
		hud.coins += SILVER_VALUE
	elif type == PICKUP_TILE_GOLD_COIN:
		hud.coins += GOLD_VALUE

func _on_pause_paused(paused: bool) -> void:
	if paused:
		player.set_physics_process(false)
		level_scroller.speed = 0.0
		background.speed = 0.0
		pause.show()
	else:
		player.set_physics_process(true)
		level_scroller.speed = 500.0
		background.speed = 100.0
		pause.hide()


func _on_back_wall_body_entered(body: Node2D) -> void:
	if body is Player:
		hurt_player()
