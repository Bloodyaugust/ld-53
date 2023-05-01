extends Node2D

const MAILBOX_DELIVERED: Texture2D = preload("res://sprites/mailbox.png")

@onready var _sprite: Sprite2D = %Sprite2D

var _delivered: bool = false

func deliver() -> bool:
  if _delivered:
    return false

  _delivered = true
  _sprite.texture = MAILBOX_DELIVERED
  return true
