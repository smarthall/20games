extends CharacterBody2D

enum WhichPlayer {
    LOCAL,
    REMOTE
}

@export var player_type: WhichPlayer

func _physics_process(_delta: float) -> void:
    if player_type == WhichPlayer.LOCAL:
        if Input.is_action_pressed("LocalUp"):
            position.y -= 5
        if Input.is_action_pressed("LocalDown"):
            position.y += 5
    elif player_type == WhichPlayer.REMOTE:
        if Input.is_action_pressed("RemoteUp"):
            position.y -= 5
        if Input.is_action_pressed("RemoteDown"):
            position.y += 5
