extends Node2D

@onready var background: ScrollingTilemap = $Background
@onready var hud: HUD = $HUD
@onready var player: Player = $Player

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


func _on_background_tilemap_recycle(tilemap: TileMapLayer) -> void:
	randomize_background_timemap(tilemap)

func _on_player_hazard_collision() -> void:
	if not player.is_invincible():
		hud.hp -= 1
		player.invincible(2.0)

	if hud.hp == 0:
		get_tree().quit()

func _on_player_pickup_collision(body: TileMapLayer, coords: Vector2i):
	print("Player picked up item from ", body, " at ", coords)

	body.erase_cell(coords)
