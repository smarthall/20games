extends RefCounted
class_name WFC

#   ____                _              _       
#  / ___|___  _ __  ___| |_ __ _ _ __ | |_ ___ 
# | |   / _ \| '_ \/ __| __/ _` | '_ \| __/ __|
# | |__| (_) | | | \__ \ || (_| | | | | |_\__ \
#  \____\___/|_| |_|___/\__\__,_|_| |_|\__|___/

enum CellType {
	EMPTY,
	TERRAIN_SURROUNDED,
	TERRAIN_GRASS_TOP,
	TERRAIN_HARD_LEFT,
	TERRAIN_HARD_RIGHT,
	TERRAIN_RAMP_UP_UPPER,
	TERRAIN_RAMP_UP_LOWER,
	TERRAIN_RAMP_DOWN_UPPER,
	TERRAIN_RAMP_DOWN_LOWER,
}

static func type_all() -> Array[CellType]:
	var all:Array[CellType] = []
	for type in CellType.values():
		all.append(type as CellType)
	return all

enum Layer {
	TERRAIN,
	HAZARD,
	PICKUP,
	CLEAR,
}

const VECTOR2I_UL = Vector2i.UP + Vector2i.LEFT
const VECTOR2I_UR = Vector2i.UP + Vector2i.RIGHT
const VECTOR2I_DL = Vector2i.DOWN + Vector2i.LEFT
const VECTOR2I_DR = Vector2i.DOWN + Vector2i.RIGHT

const NEIGHBOURS: Array[Vector2i] = [
	VECTOR2I_UL,
	Vector2i.UP,
	VECTOR2I_UR,
	Vector2i.LEFT,
	Vector2i.RIGHT,
	VECTOR2I_DL,
	Vector2i.DOWN,
	VECTOR2I_DR
]

const EMPTY_SOURCE := -1
const TERRAIN_SOURCE := 37
const HAZARD_SOURCE := 1
const PICKUP_SOURCE := 0

const MAX_X := 17
const MAX_Y := 11

class WFCData:
	var cell_type: CellType
	var layer: Layer
	var atlas_source: int
	var atlas_loc: Vector2i
	var flip_h: bool
	var flip_v: bool

	var neighbours_allowed: Dictionary[Vector2i, Array]

	static func from_dict(data: Dictionary) -> WFCData:
		var instance := WFCData.new()
		instance.cell_type = data.get("cell_type", CellType.EMPTY)
		instance.layer = data.get("layer", Layer.TERRAIN)
		instance.atlas_source = data.get("atlas_source", -1)
		instance.atlas_loc = data.get("atlas_loc", Vector2i(-1, -1))
		instance.flip_h = data.get("flip_h", false)
		instance.flip_v = data.get("flip_v", false)

		var got_neighbours_allowed = data.get("neighbours_allowed", {})
		instance.neighbours_allowed = {}
		for n in NEIGHBOURS:
			# If not specified, allow all tiles
			var valid_cell_types: Array[CellType] = [] 
			for t in got_neighbours_allowed.get(n, WFC.type_all()):
				valid_cell_types.append(t)
			instance.neighbours_allowed[n] = valid_cell_types

		return instance

	func get_allowed(neighbour: Vector2i) -> Array[CellType]:
		return neighbours_allowed.get(neighbour, []).duplicate()

	func set_tilemaps(coords: Vector2i, terrain: TileMapLayer, hazards: TileMapLayer, pickups: TileMapLayer) -> void:
		if layer == Layer.TERRAIN:
			set_tilemap_cell(terrain, coords)

			hazards.erase_cell(coords)
			pickups.erase_cell(coords)

		elif layer == Layer.HAZARD:
			set_tilemap_cell(hazards, coords)

			terrain.erase_cell(coords)
			pickups.erase_cell(coords)

		elif layer == Layer.PICKUP:
			set_tilemap_cell(pickups, coords)

			terrain.erase_cell(coords)
			hazards.erase_cell(coords)

		elif layer == Layer.CLEAR:
			terrain.erase_cell(coords)
			hazards.erase_cell(coords)
			pickups.erase_cell(coords)

	func set_tilemap_cell(tilemap: TileMapLayer, coords: Vector2i):
		assert(atlas_loc != Vector2i(0, 0), "Zero atlas location")
		var alt: int = 0

		if flip_h:
			alt |= TileSetAtlasSource.TRANSFORM_FLIP_H
		if flip_v:
			alt |= TileSetAtlasSource.TRANSFORM_FLIP_V

		tilemap.set_cell(coords, atlas_source, atlas_loc, alt)

#  _____ _ _      ____        _        
# |_   _(_) | ___|  _ \  __ _| |_ __ _ 
#   | | | | |/ _ \ | | |/ _` | __/ _` |
#   | | | | |  __/ |_| | (_| | || (_| |
#   |_| |_|_|\___|____/ \__,_|\__\__,_|

var tile_data: Array[Dictionary] = [
	# EMPTY
	{
		"cell_type": CellType.EMPTY,
		"layer": Layer.CLEAR,
		"atlas_source": EMPTY_SOURCE,
		"atlas_loc": Vector2i(-1, -1),
		"neighbours_allowed": {
			Vector2i.UP: [CellType.EMPTY],
			Vector2i.DOWN: [CellType.TERRAIN_GRASS_TOP],
			Vector2i.LEFT: [CellType.EMPTY],
			Vector2i.RIGHT: [CellType.EMPTY]
		}
	},
	# TERRAIN_SURROUNDED
	{
		"cell_type": CellType.TERRAIN_SURROUNDED,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(7, 0),
		"neighbours_allowed": {
			Vector2i.UP: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_SURROUNDED],
			Vector2i.DOWN: [CellType.TERRAIN_SURROUNDED],
			Vector2i.LEFT: [CellType.TERRAIN_SURROUNDED],
			Vector2i.RIGHT: [CellType.TERRAIN_SURROUNDED]
		}
	},
	# TERRAIN_GRASS_TOP
	{
		"cell_type": CellType.TERRAIN_GRASS_TOP,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(0, 1),
		"neighbours_allowed": {
			Vector2i.UP: [CellType.EMPTY],
			Vector2i.DOWN: [CellType.TERRAIN_SURROUNDED],
			Vector2i.LEFT: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_UP_UPPER, CellType.TERRAIN_RAMP_DOWN_LOWER],
			Vector2i.RIGHT: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_UP_UPPER, CellType.TERRAIN_RAMP_DOWN_LOWER]
		}
	},
	# TERRAIN_HARD_LEFT
	{
		"cell_type": CellType.TERRAIN_HARD_LEFT,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(4, 1),
		"neighbours_allowed": {
			Vector2i.UP: [CellType.TERRAIN_HARD_LEFT],
			Vector2i.DOWN: [CellType.TERRAIN_HARD_LEFT],
			Vector2i.LEFT: [CellType.EMPTY],
			Vector2i.RIGHT: [CellType.TERRAIN_SURROUNDED]
		}
	},
	# TERRAIN_HARD_RIGHT
	{
		"cell_type": CellType.TERRAIN_HARD_RIGHT,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(2, 4),
		"neighbours_allowed": {
			Vector2i.UP: [CellType.TERRAIN_HARD_RIGHT],
			Vector2i.DOWN: [CellType.TERRAIN_HARD_RIGHT],
			Vector2i.LEFT: [CellType.TERRAIN_SURROUNDED],
			Vector2i.RIGHT: [CellType.EMPTY]
		}
	},
	# TERRAIN_RAMP_UP_UPPER
	{
		"cell_type": CellType.TERRAIN_RAMP_UP_UPPER,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(0, 2),
		"flip_h": true,
		"neighbours_allowed": {
			Vector2i.UP: [CellType.EMPTY],
			Vector2i.DOWN: [CellType.TERRAIN_RAMP_UP_LOWER],
			Vector2i.LEFT: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_UP_LOWER, CellType.TERRAIN_RAMP_DOWN_UPPER],
			Vector2i.RIGHT: [CellType.EMPTY]
		}
	},
	# TERRAIN_RAMP_UP_LOWER
	{
		"cell_type": CellType.TERRAIN_RAMP_UP_LOWER,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(7, 1),
		"flip_h": true,
		"neighbours_allowed": {
			Vector2i.UP: [CellType.TERRAIN_RAMP_UP_UPPER],
			Vector2i.DOWN: [CellType.TERRAIN_SURROUNDED],
			Vector2i.LEFT: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_UP_UPPER, CellType.TERRAIN_RAMP_DOWN_LOWER],
			Vector2i.RIGHT: [CellType.TERRAIN_SURROUNDED]
		}
	},
	# TERRAIN_RAMP_DOWN_UPPER
	{
		"cell_type": CellType.TERRAIN_RAMP_DOWN_UPPER,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(0, 3),
		"neighbours_allowed": {
			Vector2i.UP: [CellType.EMPTY],
			Vector2i.DOWN: [CellType.TERRAIN_RAMP_DOWN_LOWER],
			Vector2i.LEFT: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_DOWN_LOWER, CellType.TERRAIN_RAMP_UP_UPPER],
			Vector2i.RIGHT: [CellType.EMPTY]
		}
	},
	# TERRAIN_RAMP_DOWN_LOWER
	{
		"cell_type": CellType.TERRAIN_RAMP_DOWN_LOWER,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(7, 3),
		"neighbours_allowed": {
			Vector2i.UP: [CellType.TERRAIN_RAMP_DOWN_UPPER],
			Vector2i.DOWN: [CellType.TERRAIN_SURROUNDED],
			Vector2i.LEFT: [CellType.TERRAIN_SURROUNDED],
			Vector2i.RIGHT: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_DOWN_UPPER, CellType.TERRAIN_RAMP_UP_LOWER]
		}
	},
]

class TileResolver:
	var collapsed: bool = false
	var options: Array[CellType] = WFC.type_all() # By default everything is an option

	func get_tile() -> CellType:
		assert(collapsed)

		return options[0]

	func is_collapsed() -> bool:
		if collapsed:
			return true

		if options.size() == 1:
			collapsed = true
		else:
			collapsed = false

		return collapsed
	
	func count_options() -> int:
		if options.size() == 1:
			collapsed = true
			return 1

		return options.size()

	func apply_allowed(allowed: Array[CellType]) -> bool:
		var changed: bool = false
		var result: Array[CellType] = []
		for cell_type in options:
			if cell_type in allowed and cell_type not in result:
				result.append(cell_type)

		assert(result.size() > 0, "No options left for tile")

		if result.size() != options.size():
			options = result
			changed = true

		return changed

	func collapse() -> CellType:
		assert(not collapsed)
		assert(options.size() > 0)

		var chosen := options[randi() % options.size()]
		options = [chosen]
		collapsed = true
		return chosen

class Map:
	var _map: Array[TileResolver] = []
	var _bounds: Vector2i = Vector2i(0, 0)

	var type_dict: Dictionary[CellType, WFCData] = {}
	var setup: bool = false

	func _init(tile_data) -> void:
		for t in tile_data:
			var data := WFCData.from_dict(t)
			type_dict[data.cell_type] = data

	func set_bounds(bounds: Vector2i) -> void:
		_bounds = bounds
		_map.resize(bounds.x * bounds.y)
		for i in range(_map.size()):
			_map[i] = TileResolver.new()

	func in_bounds(coords: Vector2i) -> bool:
		return coords.x >= 0 and coords.x < _bounds.x and coords.y >= 0 and coords.y < _bounds.y

	func get_tile(coords: Vector2i) -> TileResolver:
		assert(in_bounds(coords))

		return _map[index_from_coords(coords)]

	func index_from_coords(coords: Vector2i) -> int:
		assert(in_bounds(coords))

		assert(coords.y >= 0 and coords.y < _bounds.y)

		return coords.x + (coords.y * _bounds.x)

	func coords_from_index(index: int) -> Vector2i:
		assert(index >= 0 and index < _map.size())
		assert(index % _bounds.x < _bounds.x)
		assert(index / _bounds.x < _bounds.y)

		return Vector2i(index % _bounds.x, index / _bounds.x)

	func is_collapsed() -> bool:
		for tile in _map:
			if not tile.is_collapsed():
				return false
		return true

	func lowest_entropy() -> Array[Vector2i]:
		var lowest_entropy_val := 99999
		var lowest_coords: Array[Vector2i]= []
		for i in range(_map.size()):
			var options_left = _map[i].count_options()
			if _map[i].is_collapsed():
				continue

			elif options_left < lowest_entropy_val:
				lowest_entropy_val = options_left
				lowest_coords = [coords_from_index(i)]

			elif options_left == lowest_entropy_val:
				lowest_coords.append(coords_from_index(i))

		return lowest_coords

	func recalculate_neighbours(coords: Vector2i) -> Array[Vector2i]:
		var tile := get_tile(coords)
		var changed_neighbours := []
		for n in NEIGHBOURS:
			var neighbour_coords := coords + n
			if not in_bounds(neighbour_coords):
				continue

			var neighbour := get_tile(neighbour_coords)
			if neighbour.is_collapsed():
				continue

			for m in NEIGHBOURS:
				if not in_bounds(neighbour_coords + m):
					continue

				var allowed := type_dict[get_tile(coords).get_tile()].get_allowed(-1 * m)
				var change := neighbour.apply_allowed(allowed)
				if change:
					changed_neighbours.append(neighbour)

		return changed_neighbours

	func collapse_waveform() -> void:
		# FIXME: If this is the second generation, apply constraints to the first column

		while not is_collapsed():
			var lowest := lowest_entropy()
			if lowest.size() == 0:
				return

			var chosen := lowest[randi() % lowest.size()]
			get_tile(chosen).collapse()

			var to_recalculate: Array[Vector2i] = [chosen]
			while to_recalculate.size() > 0:
				var coords: Vector2i = to_recalculate.pop_front()
				var changed_neighbours := recalculate_neighbours(coords)
				for neighbour in changed_neighbours:
					if neighbour not in to_recalculate:
						to_recalculate.append(neighbour)

	func to_tilemaps(terrain: TileMapLayer, hazards: TileMapLayer, pickups: TileMapLayer) -> void:
		for i in range(_map.size()):
			var coords := coords_from_index(i)
			var tile := _map[i]

			if not tile.is_collapsed():
				continue

			var cell_type := tile.get_tile()
			var data := type_dict[cell_type]
			data.set_tilemaps(coords, terrain, hazards, pickups)

func generate(terrain: TileMapLayer, hazards: TileMapLayer, pickups: TileMapLayer) -> void:
	var bounds := Vector2i(MAX_X, MAX_Y)
	var map = Map.new(tile_data)

	map.set_bounds(bounds)

	map.collapse_waveform()

	map.to_tilemaps(terrain, hazards, pickups)
