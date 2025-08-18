extends CanvasLayer
class_name HUD

@export var hp: int = 6: set=set_hp, get=get_hp

@onready var hearts_bar := $Control/Top/HeartsBar

func set_hp(value: int) -> void:
	hp = value
	update_hearts_bar()

func get_hp() -> int:
	return hp

func update_hearts_bar() -> void:
	hearts_bar.hp = hp

func _ready() -> void:
	set_hp(hp)
