extends Node2D

@onready var background: ScrollingTilemap = $Background
@onready var hud: HUD = $HUD
@onready var player: Player = $Player
@onready var level_scroller: Scroller = $LevelScroller

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
		player.invincible(2.0)

func _process(delta: float) -> void:
	hud.distance += (delta * level_scroller.speed) / 100

func _on_background_tilemap_recycle(tilemap: TileMapLayer) -> void:
	randomize_background_timemap(tilemap)

func _on_player_hazard_collision() -> void:
	if not player.is_invincible():
		hud.hp -= 1
		player.invincible(1.0)

	if hud.hp == 0:
		get_tree().quit()

func _on_player_pickup_collision(body: TileMapLayer, coords: Vector2i):
	var type = body.get_cell_tile_data(coords).get_custom_data("type")

	print("Player picked up item from ", body, " at ", coords)
	print("Item Type: ", type)

	body.erase_cell(coords)

	if type == PICKUP_TILE_HEART:
		heart_pickup()
	elif type == PICKUP_TILE_BRONZE_COIN:
		hud.coins += BRONZE_VALUE
	elif type == PICKUP_TILE_SILVER_COIN:
		hud.coins += SILVER_VALUE
	elif type == PICKUP_TILE_GOLD_COIN:
		hud.coins += GOLD_VALUE
