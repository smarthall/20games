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

	func validate() -> bool:
		for n in NEIGHBOURS:
			assert(n in neighbours_allowed, "Missing neighbour: " + str(n))
			assert(neighbours_allowed[n].size() > 0, "No allowed neighbours for: " + str(n))

		return true

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
			Vector2i.DOWN: [CellType.EMPTY, CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_UP_UPPER, CellType.TERRAIN_RAMP_DOWN_UPPER],
			Vector2i.LEFT: [CellType.EMPTY, CellType.TERRAIN_RAMP_DOWN_UPPER, CellType.TERRAIN_HARD_LEFT],
			Vector2i.RIGHT: [CellType.EMPTY, CellType.TERRAIN_RAMP_UP_UPPER, CellType.TERRAIN_HARD_RIGHT]
		}
	},
	# TERRAIN_SURROUNDED
	{
		"cell_type": CellType.TERRAIN_SURROUNDED,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(7, 0),
		"neighbours_allowed": {
			Vector2i.UP: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_SURROUNDED, CellType.TERRAIN_RAMP_UP_LOWER, CellType.TERRAIN_RAMP_DOWN_LOWER],
			Vector2i.DOWN: [CellType.TERRAIN_SURROUNDED],
			Vector2i.LEFT: [CellType.TERRAIN_SURROUNDED, CellType.TERRAIN_HARD_RIGHT, CellType.TERRAIN_HARD_LEFT, CellType.TERRAIN_RAMP_UP_LOWER],
			Vector2i.RIGHT: [CellType.TERRAIN_SURROUNDED, CellType.TERRAIN_HARD_RIGHT, CellType.TERRAIN_HARD_LEFT, CellType.TERRAIN_RAMP_DOWN_LOWER]
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
			Vector2i.RIGHT: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_UP_LOWER, CellType.TERRAIN_RAMP_DOWN_UPPER]
		}
	},
	# TERRAIN_HARD_LEFT
	{
		"cell_type": CellType.TERRAIN_HARD_LEFT,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(1, 4),
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
			Vector2i.LEFT: [CellType.EMPTY],
			Vector2i.RIGHT: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_DOWN_UPPER, CellType.TERRAIN_RAMP_UP_LOWER]
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
			Vector2i.RIGHT: [CellType.TERRAIN_SURROUNDED, CellType.TERRAIN_RAMP_DOWN_LOWER]
		}
	},
	# TERRAIN_RAMP_DOWN_UPPER
	{
		"cell_type": CellType.TERRAIN_RAMP_DOWN_UPPER,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(0, 2),
		"neighbours_allowed": {
			Vector2i.UP: [CellType.EMPTY],
			Vector2i.DOWN: [CellType.TERRAIN_RAMP_DOWN_LOWER],
			Vector2i.LEFT: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_UP_UPPER, CellType.TERRAIN_RAMP_DOWN_LOWER],
			Vector2i.RIGHT: [CellType.EMPTY]
		}
	},
	# TERRAIN_RAMP_DOWN_LOWER
	{
		"cell_type": CellType.TERRAIN_RAMP_DOWN_LOWER,
		"layer": Layer.TERRAIN,
		"atlas_source": TERRAIN_SOURCE,
		"atlas_loc": Vector2i(7, 1),
		"neighbours_allowed": {
			Vector2i.UP: [CellType.TERRAIN_RAMP_DOWN_UPPER],
			Vector2i.DOWN: [CellType.TERRAIN_SURROUNDED],
			Vector2i.LEFT: [CellType.TERRAIN_SURROUNDED, CellType.TERRAIN_RAMP_UP_LOWER],
			Vector2i.RIGHT: [CellType.TERRAIN_GRASS_TOP, CellType.TERRAIN_RAMP_UP_LOWER, CellType.TERRAIN_RAMP_DOWN_UPPER]
		}
	},
]

class TileResolver:
	var collapsed: bool = false
	var options: Array[CellType] = WFC.type_all() # By default everything is an option

	func get_tile() -> CellType:
		assert(collapsed, "Tile has not been collapsed")

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
		var start_size := options.size()

		for cell_type in options:
			if cell_type in allowed and cell_type not in result:
				result.append(cell_type)

		if result.size() != options.size():
			options = result
			changed = true

		return changed

	func collapse() -> CellType:
		assert(not collapsed, "Tile has already been collapsed")
		assert(options.size() > 0, "No options left for tile")

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

		#assert(verify_tile_data())

	func verify_tile_data() -> bool:
		for cell_type in type_dict.keys():
			var data := type_dict[cell_type]
			
			assert(data.validate())

			for n in NEIGHBOURS:
				assert(check_backreferences(data, n))

		return true

	func get_type_name(type: CellType) -> String:
		return CellType.keys()[type]

	func get_neighbour_name(neighbour: Vector2i) -> String:
		match neighbour:
			Vector2i.UP: return "UP"
			Vector2i.DOWN: return "DOWN"
			Vector2i.LEFT: return "LEFT"
			Vector2i.RIGHT: return "RIGHT"
			Vector2i(1, 1): return "UP-RIGHT"
			Vector2i(-1, 1): return "UP-LEFT"
			Vector2i(1, -1): return "DOWN-RIGHT"
			Vector2i(-1, -1): return "DOWN-LEFT"
			_ : return "UNKNOWN"

	func check_backreferences(data: WFCData, n: Vector2i) -> bool:
		var my_type := data.cell_type
		var opposite := n * -1

		for option in data.neighbours_allowed[n]:
			assert(option in type_dict.keys(), "Neighbour type not found")
			var referenced_type := type_dict[option]

			assert(opposite in referenced_type.neighbours_allowed.keys())
			var backreferences := referenced_type.neighbours_allowed[opposite]
			if not my_type in backreferences:
				var error := "Reference from %s to %s in direction %s found, " % [get_type_name(my_type), get_type_name(option), get_neighbour_name(n)]
				error += "but no backreference from %s to %s in direction %s found" % [get_type_name(option), get_type_name(my_type), get_neighbour_name(opposite)]

				assert(false, error)

		return true

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

	func options_from_options(us: Vector2i, them: Vector2i) -> Array[CellType]:
		assert(in_bounds(us))
		assert(in_bounds(them))

		var neighbour := us - them

		var their_options := get_tile(them).options
		var our_options: Array[CellType] = []
		for option in their_options:
			var allowed := type_dict[option].get_allowed(neighbour)
			for a in allowed:
				if a not in our_options:
					our_options.append(a)

		return our_options

	func recalculate_tile(coords: Vector2i) -> bool:
		assert(in_bounds(coords))
		var tile := get_tile(coords)
		var changed: bool = false
		
		if tile.is_collapsed():
			print("Tile at ", coords, " is already collapsed.")
			return false

		for n in NEIGHBOURS:
			var neighbour_coords := coords + n
			if not in_bounds(neighbour_coords):
				continue

			var allowed := options_from_options(coords, neighbour_coords)
			changed = tile.apply_allowed(allowed) or changed
			assert(tile.options.size() > 0, "No options left for tile at: " + str(coords) + " due to " + get_neighbour_name(n))

		return changed

	func queue_neighbours(coords: Vector2i, to_recalculate: Array[Vector2i]) -> void:
		for n in NEIGHBOURS:
			var neighbour_coords := coords + n
			if neighbour_coords not in to_recalculate and in_bounds(neighbour_coords) and not get_tile(neighbour_coords).is_collapsed():
				to_recalculate.append(neighbour_coords)

	func recalculate_neighbours(coords: Vector2i) -> void:
		var to_recalculate: Array[Vector2i] = []

		queue_neighbours(coords, to_recalculate)

		while to_recalculate.size() > 0:
			var recalc: Vector2i = to_recalculate.pop_front()
			if recalculate_tile(recalc):
				queue_neighbours(recalc, to_recalculate)

	func random_collapse() -> Vector2i:
		var lowest := lowest_entropy()

		if lowest.size() == 0:
			print("No tiles left to collapse, returning empty tile.")
			return Vector2i(-1, -1)

		var chosen := lowest[randi() % lowest.size()]
		get_tile(chosen).collapse()

		return chosen

	func collapse_waveform() -> void:
		# FIXME: If this is the second generation, apply constraints to the first column

		while not is_collapsed():
			var chosen := random_collapse()
			recalculate_neighbours(chosen)

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
	seed(1)
	var bounds := Vector2i(MAX_X, MAX_Y)
	var map = Map.new(tile_data)

	map.set_bounds(bounds)

	map.collapse_waveform()

	map.to_tilemaps(terrain, hazards, pickups)
