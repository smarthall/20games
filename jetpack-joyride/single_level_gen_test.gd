extends Node2D

@onready var terrainLayer: TileMapLayer = $Terrain
@onready var hazardLayer: TileMapLayer = $Hazards
@onready var pickupLayer: TileMapLayer = $Pickups

@onready var timer: Timer = $Timer

var level := WFC.new()
var map := level.Map.new(level.tile_data)

var marked_cell: Vector2i

var to_recalculate: Array[Vector2i] = []

func _ready() -> void:
	seed(2)

	map.set_bounds(Vector2i(level.MAX_X, level.MAX_Y))

func _process(delta: float) -> void:
	# If the mouse was clicked
	if Input.is_action_just_pressed("click"):
		var mouse_pos: Vector2 = get_global_mouse_position()
		var cell: Vector2i = terrainLayer.local_to_map(terrainLayer.to_local(mouse_pos))
		print("Cell at " + str(cell) + " is " + str(terrainLayer.get_cell_atlas_coords(cell)))
		if not map.in_bounds(cell):
			print("Cell is out of bounds")
			return
		if map.get_tile(cell).is_collapsed():
			print(".. has collapsed to " + str(map.get_tile(cell).get_tile()))
		else:
			print(".. has not yet collapsed.")
			var ops: String = ""
			for o in map.get_tile(cell).options:
				ops += map.get_type_name(o) + ", "
			print("Options are: " + ops)

	if Input.is_action_just_pressed("jetpack"):
		timer.stop()

func _on_timer_timeout() -> void:
	if map.is_collapsed():
		timer.stop()
		print("Map has collapsed, stopping timer.")

	if marked_cell:
		pickupLayer.set_cell(marked_cell, -1, Vector2i(-1, -1))

	if to_recalculate.size() == 0:
		var chosen: Vector2i = map.random_collapse()
		map.queue_neighbours(chosen, to_recalculate)
	else:
		var recalc: Vector2i = to_recalculate.pop_front()

		if map.recalculate_tile(recalc):
			map.queue_neighbours(recalc, to_recalculate)

		if map.get_tile(recalc).is_collapsed():
			print("Tile ", recalc, " has collapsed to ", map.get_tile(recalc).get_tile())

	map.to_tilemaps(terrainLayer, hazardLayer, pickupLayer)

	if to_recalculate.size() > 0:
		marked_cell = to_recalculate[0]
		pickupLayer.set_cell(marked_cell, 0, Vector2i(1, 0))
