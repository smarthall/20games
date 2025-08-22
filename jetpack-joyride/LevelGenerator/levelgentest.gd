extends Node2D

var level := WFC.new()
var map := level.setup()

func _on_level_scroller_setup_scroll_node(scroll_node: ScrollNode) -> void:
	var terrainLayer: TileMapLayer = scroll_node.get_node("Terrain")
	var hazardLayer: TileMapLayer = scroll_node.get_node("Hazards")
	var pickupLayer: TileMapLayer = scroll_node.get_node("Pickups")

	print("-- Generating new chunk...")
	level.next(map)
	print("--- Reading")
	map.to_tilemaps(terrainLayer, hazardLayer, pickupLayer)
	print("-- Done")
