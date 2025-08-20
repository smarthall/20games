extends RefCounted
class_name LevelData

enum CellContent {
	EMPTY,
	TERRAIN,
	WATER,
	LAVA,
	BRONZE,
	SILVER,
	GOLD,
	HEART,
	SHARP_BLOCK,
	BOMB,
	BLADE,
	SPIKE_UP,
	SPIKE_DOWN,
	SPIKE_LEFT,
	SPIKE_RIGHT,
}

enum Layer {
	TERRAIN,
	HAZARD,
	PICKUP,
	CLEAR,
}

const CLEAR_SOURCE := -1
const TERRAIN_SOURCE := 37
const HAZARD_SOURCE := 1
const PICKUP_SOURCE := 0

const MAX_X := 17
const MAX_Y := 10

const TERRAIN_ATLAS_EMPTY := Vector2i(-1, -1)
const TERRAIN_ATLAS_SURROUNDED := Vector2i(7, 0)
const TERRAIN_ATLAS_GRASS_TOP := Vector2i(0, 1)

var _level_data: Dictionary[Vector2i, CellContent]
var iteration: int = 0

func generate_next():
	var last_level := _level_data
	_make_empty()

	for x in range(MAX_X + 1):
		for y in range(MAX_Y - 1, MAX_Y + 1):
			var coords := Vector2i(x, y)
			_level_data[coords] = CellContent.TERRAIN


	iteration += 1
	return _level_data

func _make_empty():
	var empty: Dictionary[Vector2i, CellContent] = {}

	for x in range(MAX_X + 1):
		for y in range(MAX_Y + 1):
			empty[Vector2i(x, y)] = CellContent.EMPTY

	_level_data = empty

func _set_layer(terrainLayer: TileMapLayer, hazardLayer: TileMapLayer, pickupLayer: TileMapLayer, layer: Layer, coords: Vector2i, val: Vector2i = Vector2i(-1, -1)) -> void:
	match layer:
		Layer.TERRAIN:
			terrainLayer.set_cell(coords, TERRAIN_SOURCE, val)
			hazardLayer.set_cell(coords, CLEAR_SOURCE)
			pickupLayer.set_cell(coords, CLEAR_SOURCE)
		Layer.HAZARD:
			terrainLayer.set_cell(coords, CLEAR_SOURCE)
			hazardLayer.set_cell(coords, HAZARD_SOURCE, val)
			pickupLayer.set_cell(coords, CLEAR_SOURCE)
		Layer.PICKUP:
			terrainLayer.set_cell(coords, CLEAR_SOURCE)
			hazardLayer.set_cell(coords, CLEAR_SOURCE)
			pickupLayer.set_cell(coords, PICKUP_SOURCE, val)
		Layer.CLEAR:
			terrainLayer.set_cell(coords, CLEAR_SOURCE)
			hazardLayer.set_cell(coords, CLEAR_SOURCE)
			pickupLayer.set_cell(coords, CLEAR_SOURCE)

func _get_neighbours(coords: Vector2i) -> Dictionary[Vector2i, CellContent]:
	var neighbours: Dictionary[Vector2i, CellContent] = {}
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			var offset := Vector2i(dx, dy)
			var neighbour := coords + offset
			if neighbour in _level_data:
				neighbours[offset] = _level_data[neighbour]
	return neighbours

func _get_terrain_type(neighbours: Dictionary[Vector2i, CellContent]) -> Vector2i:
	print(neighbours)
	if neighbours.get(Vector2i.UP) == CellContent.EMPTY:
		return TERRAIN_ATLAS_GRASS_TOP

	return TERRAIN_ATLAS_SURROUNDED

func _get_cell_atlas(coords: Vector2i) -> Vector2i:
	var content := _level_data[coords]
	var neighbours := _get_neighbours(coords)

	match content:
		CellContent.TERRAIN:
			return _get_terrain_type(neighbours)
		CellContent.EMPTY:
			return TERRAIN_ATLAS_EMPTY
		_:
			print("Unhandled content at: ", coords, " - ", content)
			return TERRAIN_ATLAS_EMPTY

func _get_cell_layer(coords: Vector2i) -> Layer:
	var content := _level_data[coords]
	match content:
		CellContent.TERRAIN:
			return Layer.TERRAIN
		CellContent.EMPTY:
			return Layer.CLEAR
		_:
			print("Unhandled content at: ", coords, " - ", content)
			return Layer.CLEAR

func to_tilemap(terrainLayer: TileMapLayer, hazardLayer: TileMapLayer, pickupLayer: TileMapLayer) -> void:
	for key in _level_data:
		var layer := _get_cell_layer(key)
		var atlas := _get_cell_atlas(key)
		print("Layer: ", Layer.keys()[layer], ", Atlas: ", atlas)
		_set_layer(terrainLayer, hazardLayer, pickupLayer, layer, key, atlas)
