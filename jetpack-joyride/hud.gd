extends CanvasLayer
class_name HUD

@export var hp: int = 6: set=set_hp, get=get_hp

func set_hp(value: int) -> void:
	hp = value

func get_hp() -> int:
	return hp

func _ready() -> void:
	set_hp(hp)
