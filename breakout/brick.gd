extends StaticBody2D
class_name Brick

signal destroyed(ball: Ball)

func hit(ball: Ball) -> void:
    emit_signal("destroyed", ball)
    queue_free()
