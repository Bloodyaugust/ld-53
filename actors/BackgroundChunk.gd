extends Node2D

func _process(delta):
  position = position + Vector2(-Store.state.move_speed * delta, 0.0)
