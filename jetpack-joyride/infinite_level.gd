extends Node2D

# TODO Refactor onto the background Node2D

@onready var background: Node2D = $Background
@onready var tilemap_a: TileMapLayer = $Background/TileMapA
@onready var tilemap_b: TileMapLayer = $Background/TileMapB

var tilemap_a_leader := true

const BACKGROUND_SCROLL_SPEED = 1000.0

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

func _ready() -> void:
	position_background_tilemaps()
	randomize_timemap(get_leading_tilemap())
	randomize_timemap(get_following_tilemap())

func _process(delta: float) -> void:
	background.position.x -= BACKGROUND_SCROLL_SPEED * delta

	if background.position.x <= -1 * get_leading_tilemap_size().x * background.scale.x:
		background.position.x = 0
		swap_background_tilemaps()
		randomize_timemap(get_following_tilemap())

func randomize_timemap(tm : TileMapLayer) -> void:
	for x in range(tm.get_used_rect().size.x):
		var tile_position := Vector2i(x, 1)
		var random_tile := get_random_background_tile()
		tm.set_cell(tile_position, 1, random_tile)

func swap_background_tilemaps() -> void:
	tilemap_a_leader = not tilemap_a_leader
	position_background_tilemaps()

func position_background_tilemaps() -> void:
	var leading_tilemap := get_leading_tilemap()
	var following_tilemap := get_following_tilemap()

	leading_tilemap.position.x = 0
	following_tilemap.position.x = get_leading_tilemap_size().x

func get_random_background_tile() -> Vector2i:
	var rand := randi_range(0, 100)

	for weight in BACKTILES.keys():
		if rand < weight:
			return BACKTILES[weight]

	return BACKTILES[BACKTILES.keys()[0]]

func get_leading_tilemap() -> TileMapLayer:
	return tilemap_a if tilemap_a_leader else tilemap_b

func get_following_tilemap() -> TileMapLayer:
	return tilemap_b if tilemap_a_leader else tilemap_a

func get_leading_tilemap_size() -> Vector2:
	return get_leading_tilemap().get_used_rect().size * get_leading_tilemap().tile_set.tile_size
