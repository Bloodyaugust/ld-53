extends TextureRect

const HEART_EMPTY: Texture2D = preload("res://sprites/buttons/heart2.png")
const HEART_FULL: Texture2D = preload("res://sprites/buttons/heart1.png")

func set_full(full: bool) -> void:
  if full:
    texture = HEART_FULL
  else:
    texture = HEART_EMPTY
