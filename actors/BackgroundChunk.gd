extends Node2D

func get_dropoff_points() -> Array:
  return %Dropoffs.get_children()

func _process(delta):
  position = position + Vector2(-Store.state.move_speed * delta, 0.0)
