extends Node2D

@onready var _area2d: Area2D = %Area2D

func _on_area_entered(_area: Area2D) -> void:
  set_deferred("monitorable", false)
  set_deferred("monitoring", false)

func _ready():
  _area2d.area_entered.connect(_on_area_entered)
