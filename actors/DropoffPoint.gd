extends Sprite2D

@onready var _area2d: Area2D = %Area2D

func _ready():
  _area2d.area_entered.connect(func(_area: Area2D): queue_free())
