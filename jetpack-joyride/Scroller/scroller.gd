extends Node2D
class_name Scroller

signal setup_scroll_node(scroll_node: ScrollNode)

@export var speed := 100.0

const LEADING_NODE_INDEX := 0

var scroll_nodes: Array[ScrollNode]

func _ready() -> void:
	var children := get_children().filter(func(c): return c as ScrollNode)

	for i in range(children.size()):
		var scroll_node := children[i] as ScrollNode
		scroll_node.show()
		
		scroll_nodes.append(scroll_node)
		setup_scroll_node.emit(scroll_node)

	position_scroll_nodes()

func _physics_process(delta: float) -> void:
	position.x -= speed * delta

	var leading_scroll_node_size := scroll_nodes[LEADING_NODE_INDEX].size.x * scale.x
	if position.x <= -leading_scroll_node_size:
		position.x += leading_scroll_node_size
		swap_nodes()

func swap_nodes() -> void:
	var leading_scroll_node := scroll_nodes[LEADING_NODE_INDEX]
	scroll_nodes.remove_at(LEADING_NODE_INDEX)
	scroll_nodes.append(leading_scroll_node)

	setup_scroll_node.emit(leading_scroll_node)

	position_scroll_nodes()

func position_scroll_nodes() -> void:
	var x_accumulator := 0.0

	for i in range(scroll_nodes.size()):
		var scroll_node := scroll_nodes[i]
		scroll_node.position.x = x_accumulator

		x_accumulator += scroll_node.size.x
