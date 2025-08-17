extends Node2D

@onready var background: ScrollingTilemap = $Background

const TILE_BLANK = Vector2i(2, 0)
const TILE_CACTUS = Vector2i(2, 1)
const TILE_TREES = Vector2i(3, 1)
const TILE_MUSHROOM = Vector2i(1, 3)
const BACKTILES : Dictionary[int, Vector2i] = {
	50: TILE_BLANK,
	75: TILE_CACTUS,
	98: TILE_TREES,
	99: TILE_MUSHROOM,
}

func randomize_background_timemap(tm : TileMapLayer) -> void:
	for x in range(tm.get_used_rect().size.x):
		var tile_position := Vector2i(x, 1)
		var random_tile := get_random_background_tile()
		tm.set_cell(tile_position, 1, random_tile)

func get_random_background_tile() -> Vector2i:
	var rand := randi_range(0, 100)

	for weight in BACKTILES.keys():
		if rand < weight:
			return BACKTILES[weight]

	return BACKTILES[BACKTILES.keys()[0]]


func _on_background_tilemap_recycle(tilemap: TileMapLayer) -> void:
	randomize_background_timemap(tilemap)

func _on_player_hazard_collision() -> void:
	pass # Replace with function body.

func _on_player_pickup_collision(body:TileMapLayer, coords:Vector2i):
	print("Player picked up item from ", body, " at ", coords)

	body.erase_cell(coords)
