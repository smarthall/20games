extends CanvasLayer
class_name HUD

@export var hp: int = 6: set=set_hp, get=get_hp
@export var coins: int = 0: set=set_coin_count, get=get_coin_count

@onready var hearts_bar := $Control/HeartsBar
@onready var coin_label := $Control/MarginContainer/HBoxContainer/CoinCount

func set_hp(value: int) -> void:
	hp = value
	update_hearts_bar()

func get_hp() -> int:
	return hp

func set_coin_count(value: int) -> void:
	coins = value
	update_coin_count()

func get_coin_count() -> int:
	return coins

func update_hearts_bar() -> void:
	hearts_bar.hp = hp

func update_coin_count() -> void:
	coin_label.text = str(coins)

func _ready() -> void:
	set_hp(hp)
	set_coin_count(coins)
