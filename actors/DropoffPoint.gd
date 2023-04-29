extends Sprite2D

@onready var _area2d: Area2D = %Area2D

func _process(delta):
  global_position -= Vector2(Store.state.move_speed * delta, 0.0)

func _ready():
  _area2d.area_entered.connect(func(_area: Area2D): queue_free())
