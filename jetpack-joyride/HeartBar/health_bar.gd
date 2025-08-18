@tool
extends HBoxContainer
class_name HeartsBar

@export var max_hp: int = 6: set=set_max_hp, get=get_max_hp
@export var hp: int = 6: set=set_hp, get=get_hp

@export var heart_full: Texture2D
@export var heart_half: Texture2D
@export var heart_empty: Texture2D

var heart_prototype: PackedScene = preload("res://HeartBar/heart_prototype.tscn")
var _heart_textures: Array[TextureRect] = []

func _ready() -> void:
	create_hearts()
	update_hearts()

func clear_hearts() -> void:
	for heart in _heart_textures:
		heart.queue_free()
	_heart_textures.clear()

func create_hearts() -> void:
	var heart_count: int = ceil(max_hp / 2.0)
	for i in range(heart_count):
		var heart = heart_prototype.instantiate()
		add_child(heart)
		_heart_textures.append(heart)
		print("Heart created")

func update_hearts() -> void:
	print("-- Setting Hearts")
	print("HP: ", hp)
	for i in range(max_hp, 0, -2):
		print("i=", i)
		var this_heart: int = floor(i / 2.0) - 1
		var heart_hp: int = hp - i + 2
		print("Setting Heart ", this_heart, " with HP: ", heart_hp)
		if heart_hp <= 0:
			print("Heart Empty")
			_heart_textures[this_heart].texture = heart_empty
		elif heart_hp == 1:
			print("Heart Half")
			_heart_textures[this_heart].texture = heart_half
		else: # heart_hp > 1
			print("Heart Full")
			_heart_textures[this_heart].texture = heart_full
	print("-- Done")

func set_hp(value: int) -> void:
	hp = clamp(value, 0, max_hp)
	update_hearts()

func get_hp() -> int:
	return hp

func set_max_hp(value: int) -> void:
	max_hp = value
	clear_hearts()
	create_hearts()

	set_hp(hp)
	update_hearts()

func get_max_hp() -> int:
	return max_hp
