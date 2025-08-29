extends Node2D

@onready var _player: Player = $%Player
@onready var _start_zone := $StartZone
@onready var _initial_player_pos := _player.global_position

func _on_player_player_death() -> void:
	_player.reparent(_start_zone)
	_player.global_position = _initial_player_pos
