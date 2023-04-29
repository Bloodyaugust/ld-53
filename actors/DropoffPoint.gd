extends Sprite2D

func _process(delta):
  global_position -= Vector2(Store.state.move_speed * delta, 0.0)
