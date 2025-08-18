extends Node2D
class_name ScrollingTilemap

signal tilemap_recycle(tilemap: TileMapLayer)

@export var speed := 100.0

const LEADING_MAP_INDEX := 0

var maps: Array[TileMapLayer]

func _ready() -> void:
	var children := get_children().filter(func(c): return c as TileMapLayer)

	for i in range(children.size()):
		maps.append(children[i] as TileMapLayer)
		tilemap_recycle.emit(children[i] as TileMapLayer)

	position_tilemaps()

func _physics_process(delta: float) -> void:
	position.x -= speed * delta

	var leading_tile_size := tilemap_pixel_size(LEADING_MAP_INDEX).x * scale.x
	if position.x <= -leading_tile_size:
		position.x += leading_tile_size
		swap_tilemap()

func swap_tilemap() -> void:
	var leading_tilemap := maps[LEADING_MAP_INDEX]
	maps.remove_at(LEADING_MAP_INDEX)
	maps.append(leading_tilemap)

	tilemap_recycle.emit(leading_tilemap)

	position_tilemaps()

func position_tilemaps() -> void:
	var accumulative_position_x := 0.0

	for i in range(maps.size()):
		var child := maps[i]
		child.position.x = accumulative_position_x
		accumulative_position_x += tilemap_pixel_size(i).x

func tilemap_pixel_size(index: int) -> Vector2:
	if index < 0 or index >= maps.size():
		return Vector2.ZERO

	var tilemap := maps[index]

	return tilemap.get_used_rect().size * tilemap.tile_set.tile_size
