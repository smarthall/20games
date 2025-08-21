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
const MAX_Y := 10

class WFCData:
	var cell_type: CellType
	var layer: Layer
	var atlas_source: int
	var atlas_loc: Vector2i

	var neighbours_allowed: Dictionary[Vector2i, Array]

	static func from_dict(data: Dictionary) -> WFCData:
		var instance := WFCData.new()
		instance.cell_type = data.get("cell_type", CellType.EMPTY)
		instance.layer = data.get("layer", Layer.TERRAIN)
		instance.atlas_source = data.get("atlas_source", -1)
		instance.atlas_loc = data.get("atlas_loc", Vector2i(-1, -1))

		var got_neighbours_allowed = data.get("neighbours_allowed", {})
		instance.neighbours_allowed = {}
		for n in NEIGHBOURS:
			# If not specified, allow all tiles
			var valid_cell_types: Array[CellType] = got_neighbours_allowed.get(n, CellType.values())
			instance.neighbours_allowed[n] = valid_cell_types

		return instance

#  _____ _ _      ____        _        
# |_   _(_) | ___|  _ \  __ _| |_ __ _ 
#   | | | | |/ _ \ | | |/ _` | __/ _` |
#   | | | | |  __/ |_| | (_| | || (_| |
#   |_| |_|_|\___|____/ \__,_|\__\__,_|

var tile_data: Array[Dictionary] = [
	# EMPTY
	{
		"cell_type": CellType.EMPTY,
		"layer": Layer.TERRAIN,
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
			Vector2i.LEFT: [CellType.TERRAIN_GRASS_TOP],
			Vector2i.RIGHT: [CellType.TERRAIN_GRASS_TOP]
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
]
