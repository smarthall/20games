extends Node2D

@onready var background: Node2D = $Background
@onready var tilemap_a: TileMapLayer = $Background/TileMapA
@onready var tilemap_b: TileMapLayer = $Background/TileMapB

var tilemap_a_leader := true

const BACKGROUND_SCROLL_SPEED = 1000.0

func _ready() -> void:
	position_background_tilemaps()

func _process(delta: float) -> void:
	background.position.x -= BACKGROUND_SCROLL_SPEED * delta

	if background.position.x <= -1 * get_leading_tilemap_size().x * background.scale.x:
		background.position.x = 0
		swap_background_tilemaps()
		randomize_following_tilemap()

func randomize_following_tilemap() -> void:
	# TODO Randomise the background layer for the following tileset
	pass

func swap_background_tilemaps() -> void:
	tilemap_a_leader = not tilemap_a_leader
	position_background_tilemaps()

func position_background_tilemaps() -> void:
	var leading_tilemap := get_leading_tilemap()
	var following_tilemap := get_following_tilemap()

	leading_tilemap.position.x = 0
	following_tilemap.position.x = get_leading_tilemap_size().x

func get_leading_tilemap() -> TileMapLayer:
	return tilemap_a if tilemap_a_leader else tilemap_b

func get_following_tilemap() -> TileMapLayer:
	return tilemap_b if tilemap_a_leader else tilemap_a

func get_leading_tilemap_size() -> Vector2:
	return get_leading_tilemap().get_used_rect().size * get_leading_tilemap().tile_set.tile_size
