extends Node2D

var level := WFC.new()

func _on_level_scroller_setup_scroll_node(scroll_node: ScrollNode) -> void:
	var terrainLayer: TileMapLayer = scroll_node.get_node("Terrain")
	var hazardLayer: TileMapLayer = scroll_node.get_node("Hazards")
	var pickupLayer: TileMapLayer = scroll_node.get_node("Pickups")

	print("-- Generating new chunk...")
	level.generate(terrainLayer, hazardLayer, pickupLayer)
	print("-- Done")
